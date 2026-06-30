import { v4 as uuidv4 } from 'uuid';
import type {
  PublishJob,
  PublishQueueItem,
  PublishResult,
  PublishHistory,
  ScheduleConfig,
  PlatformPublishConfig,
  CrossPostConfig,
  QueuePriority,
} from './types';

export class PublishingService {
  private db: any;
  private redis: any;
  private pluginRegistry: any;

  constructor(db: any, redis: any, pluginRegistry: any) {
    this.db = db;
    this.redis = redis;
    this.pluginRegistry = pluginRegistry;
  }

  async publish(
    postId: string,
    accounts: PlatformPublishConfig[],
    options?: {
      priority?: QueuePriority;
      crossPost?: CrossPostConfig;
      retry?: { maxRetries: number; backoffMs: number; backoffMultiplier: number };
    }
  ): Promise<PublishJob> {
    const job: PublishJob = {
      id: uuidv4(),
      workspaceId: await this.getWorkspaceId(postId),
      postId,
      status: 'pending',
      priority: options?.priority ?? 'normal',
      platforms: accounts,
      crossPost: options?.crossPost,
      retry: options?.retry ?? { maxRetries: 3, backoffMs: 1000, backoffMultiplier: 2, retryOn: ['timeout', 'rate_limit'] },
      attempts: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await this.db.publishJob.create({ data: job });
    await this.redis.publish('publish:job', JSON.stringify(job));

    return job;
  }

  async schedule(
    postId: string,
    scheduledAt: Date | string,
    accounts: PlatformPublishConfig[]
  ): Promise<PublishJob> {
    const job: PublishJob = {
      id: uuidv4(),
      workspaceId: await this.getWorkspaceId(postId),
      postId,
      status: 'scheduled',
      priority: 'normal',
      platforms: accounts,
      schedule: { scheduledAt },
      retry: { maxRetries: 3, backoffMs: 1000, backoffMultiplier: 2, retryOn: ['timeout'] },
      attempts: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await this.db.publishJob.create({ data: job });

    const delay = new Date(scheduledAt).getTime() - Date.now();
    if (delay > 0) {
      await this.redis.zadd('publish:scheduled', Date.now() + delay, job.id);
    } else {
      await this.redis.publish('publish:job', JSON.stringify(job));
    }

    return job;
  }

  async cancel(jobId: string): Promise<void> {
    await this.db.publishJob.update({
      where: { id: jobId },
      data: { status: 'cancelled', updatedAt: new Date() },
    });
    await this.redis.zrem('publish:scheduled', jobId);
  }

  async retry(jobId: string): Promise<PublishJob> {
    const job = await this.db.publishJob.findUnique({ where: { id: jobId } });
    if (!job) throw new Error('Job not found');

    const updated = await this.db.publishJob.update({
      where: { id: jobId },
      data: { status: 'retrying', attempts: job.attempts + 1, updatedAt: new Date() },
    });

    await this.redis.publish('publish:job', JSON.stringify(updated));
    return updated;
  }

  async getQueue(
    workspaceId: string,
    filters?: { status?: string; priority?: QueuePriority; limit?: number; offset?: number }
  ): Promise<PublishQueueItem[]> {
    const where: any = { workspaceId };
    if (filters?.status) where.status = filters.status;
    if (filters?.priority) where.priority = filters.priority;

    return this.db.publishQueueItem.findMany({
      where,
      orderBy: { position: 'asc' },
      take: filters?.limit ?? 50,
      skip: filters?.offset ?? 0,
    });
  }

  async getHistory(
    workspaceId: string,
    filters?: { startDate?: Date; endDate?: Date; platform?: string; limit?: number; offset?: number }
  ): Promise<PublishHistory[]> {
    const where: any = { workspaceId };
    if (filters?.startDate || filters?.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    return this.db.publishHistory.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: filters?.limit ?? 50,
      skip: filters?.offset ?? 0,
    });
  }

  async reorder(queueIds: string[], newOrder: number[]): Promise<void> {
    const updates = queueIds.map((id, index) =>
      this.db.publishQueueItem.update({
        where: { id },
        data: { position: newOrder[index] },
      })
    );
    await this.db.$transaction(updates);
  }

  async pauseQueue(workspaceId: string): Promise<void> {
    await this.redis.set(`publish:queue:paused:${workspaceId}`, '1');
  }

  async resumeQueue(workspaceId: string): Promise<void> {
    await this.redis.del(`publish:queue:paused:${workspaceId}`);
  }

  async getBestTimes(workspaceId: string, platform: string): Promise<Array<{ day: number; hour: number; score: number }>> {
    const cacheKey = `analytics:best_times:${workspaceId}:${platform}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const posts = await this.db.post.findMany({
      where: { workspaceId, platform, status: 'published' },
      select: { publishedAt: true, engagementRate: true },
    });

    const hourScores: Record<number, number> = {};
    for (const post of posts) {
      const hour = new Date(post.publishedAt).getHours();
      hourScores[hour] = (hourScores[hour] || 0) + (post.engagementRate || 0);
    }

    const best = Object.entries(hourScores)
      .map(([hour, score]) => ({ day: 0, hour: parseInt(hour), score }))
      .sort((a, b) => b.score - a.score)
      .slice(0, 5);

    await this.redis.setex(cacheKey, 3600, JSON.stringify(best));
    return best;
  }

  private async getWorkspaceId(postId: string): Promise<string> {
    const post = await this.db.post.findUnique({ where: { id: postId }, select: { workspaceId: true } });
    return post?.workspaceId ?? '';
  }
}
