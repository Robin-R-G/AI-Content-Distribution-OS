import { Worker, Job } from 'bullmq';

interface PublishJobData {
  jobId: string;
  workspaceId: string;
  postId: string;
  platforms: Array<{
    platform: string;
    accountId: string;
    content: Record<string, unknown>;
    media?: Array<{ url: string; type: string }>;
  }>;
  retry: { maxRetries: number; backoffMs: number; backoffMultiplier: number };
}

export function createPublishWorker(redis: any, pluginRegistry: any, db: any, notificationService: any) {
  const worker = new Worker(
    'publish',
    async (job: Job<PublishJobData>) => {
      const { jobId, platforms } = job.data;
      const results: any[] = [];

      await db.publishJob.update({
        where: { id: jobId },
        data: { status: 'processing', updatedAt: new Date() },
      });

      for (const platformConfig of platforms) {
        try {
          const plugin = pluginRegistry.get(platformConfig.platform);
          if (!plugin) throw new Error(`Plugin not found: ${platformConfig.platform}`);

          const result = await plugin.publish(platformConfig.accountId, {
            content: platformConfig.content,
            media: platformConfig.media,
          });

          results.push({
            platform: platformConfig.platform,
            accountId: platformConfig.accountId,
            success: true,
            postId: result.postId,
            postUrl: result.postUrl,
            publishedAt: new Date(),
          });
        } catch (error: any) {
          results.push({
            platform: platformConfig.platform,
            accountId: platformConfig.accountId,
            success: false,
            error: error.message,
            publishedAt: new Date(),
          });
        }
      }

      const successCount = results.filter((r) => r.success).length;
      const failCount = results.filter((r) => !r.success).length;

      await db.publishJob.update({
        where: { id: jobId },
        data: {
          status: failCount === platforms.length ? 'failed' : 'published',
          publishedAt: new Date(),
          updatedAt: new Date(),
        },
      });

      await db.publishHistory.create({
        data: {
          jobId,
          workspaceId: job.data.workspaceId,
          postId: job.data.postId,
          results,
          totalPlatforms: platforms.length,
          successfulPlatforms: successCount,
          failedPlatforms: failCount,
          createdAt: new Date(),
        },
      });

      if (successCount > 0) {
        await notificationService.send(job.data.workspaceId, 'publish_success',
          'Content Published', `${successCount} platform(s) published successfully`);
      }
      if (failCount > 0) {
        await notificationService.send(job.data.workspaceId, 'publish_failed',
          'Publish Failed', `${failCount} platform(s) failed to publish`);
      }

      return results;
    },
    {
      connection: redis,
      concurrency: 5,
      limiter: { max: 10, duration: 60000 },
    }
  );

  worker.on('failed', async (job, error) => {
    if (job) {
      const { jobId, retry } = job.data;
      const jobRecord = await db.publishJob.findUnique({ where: { id: jobId } });

      if (jobRecord && jobRecord.attempts < retry.maxRetries) {
        const delay = retry.backoffMs * Math.pow(retry.backoffMultiplier, jobRecord.attempts);
        await db.publishJob.update({
          where: { id: jobId },
          data: { status: 'retrying', lastError: error.message, attempts: { increment: 1 }, updatedAt: new Date() },
        });
        await job.retry({ delay });
      } else {
        await db.publishJob.update({
          where: { id: jobId },
          data: { status: 'failed', lastError: error.message, updatedAt: new Date() },
        });
      }
    }
  });

  return worker;
}
