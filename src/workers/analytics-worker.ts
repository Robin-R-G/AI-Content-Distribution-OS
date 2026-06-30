import { Worker, Job } from 'bullmq';

interface AnalyticsJobData {
  workspaceId: string;
  accountId?: string;
  dateRange?: { start: string; end: string };
  type: 'fetch' | 'aggregate' | 'snapshot';
}

export function createAnalyticsWorker(redis: any, pluginRegistry: any, db: any, analyticsService: any) {
  const worker = new Worker(
    'analytics',
    async (job: Job<AnalyticsJobData>) => {
      const { workspaceId, accountId, dateRange, type } = job.data;

      switch (type) {
        case 'fetch': {
          const accounts = accountId
            ? [await db.account.findUnique({ where: { id: accountId } })]
            : await db.account.findMany({ where: { workspaceId } });

          for (const account of accounts) {
            if (!account) continue;
            const plugin = pluginRegistry.get(account.platform);
            if (!plugin) continue;

            try {
              const metrics = await plugin.getAnalytics(
                account.accessToken,
                account.platformAccountId,
                { start: new Date(dateRange?.start ?? Date.now() - 86400000), end: new Date(dateRange?.end ?? Date.now()) }
              );

              await db.platformMetric.create({
                data: {
                  accountId: account.id,
                  platform: account.platform,
                  ...metrics,
                  fetchedAt: new Date(),
                },
              });
            } catch (error: any) {
              console.error(`Failed to fetch analytics for ${account.id}:`, error.message);
            }
          }
          break;
        }

        case 'aggregate': {
          const posts = await db.post.findMany({
            where: {
              workspaceId,
              publishedAt: {
                gte: new Date(dateRange?.start ?? Date.now() - 7 * 86400000),
                lte: new Date(dateRange?.end ?? Date.now()),
              },
            },
          });

          const aggregated = {
            totalImpressions: posts.reduce((sum: number, p: any) => sum + (p.impressions ?? 0), 0),
            totalEngagement: posts.reduce((sum: number, p: any) => sum + (p.likes ?? 0) + (p.comments ?? 0) + (p.shares ?? 0), 0),
            avgEngagementRate: posts.reduce((sum: number, p: any) => sum + (p.engagementRate ?? 0), 0) / (posts.length || 1),
            topPost: posts.sort((a: any, b: any) => (b.engagementRate ?? 0) - (a.engagementRate ?? 0))[0],
          };

          await db.analyticsAggregate.upsert({
            where: { workspaceId_dateRange: { workspaceId, dateRange: `${dateRange?.start ?? ''}-${dateRange?.end ?? ''}` } },
            update: aggregated,
            create: { workspaceId, dateRange: `${dateRange?.start ?? ''}-${dateRange?.end ?? ''}`, ...aggregated, createdAt: new Date() },
          });
          break;
        }

        case 'snapshot': {
          const snapshot = await analyticsService.getOverview(workspaceId, {
            start: dateRange?.start ?? new Date(Date.now() - 30 * 86400000),
            end: dateRange?.end ?? new Date(),
          });

          await db.analyticsSnapshot.create({
            data: { ...snapshot, createdAt: new Date() },
          });
          break;
        }
      }

      return { success: true, type };
    },
    {
      connection: redis,
      concurrency: 3,
      limiter: { max: 20, duration: 60000 },
    }
  );

  worker.on('failed', (job, error) => {
    console.error(`Analytics job ${job?.id} failed:`, error.message);
  });

  return worker;
}
