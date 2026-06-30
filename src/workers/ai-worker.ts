import { Worker, Job } from 'bullmq';

interface AIJobData {
  jobId: string;
  userId: string;
  workspaceId: string;
  type: string;
  request: any;
  preferredProvider?: string;
}

export function createAIWorker(redis: any, db: any, aiService: any) {
  const worker = new Worker(
    'ai',
    async (job: Job<AIJobData>) => {
      const { jobId, userId, type, request } = job.data;

      await db.aIJob.update({
        where: { id: jobId },
        data: { status: 'processing', updatedAt: new Date() },
      });

      const balance = await db.creditBalance.findUnique({ where: { userId } });
      if (!balance || balance.credits <= 0) {
        throw new Error('Insufficient credits');
      }

      let response: any;
      switch (type) {
        case 'caption':
          response = await aiService.generateCaption(request);
          break;
        case 'title':
          response = await aiService.generateTitle(request);
          break;
        case 'hashtags':
          response = await aiService.generateHashtags(request);
          break;
        case 'thumbnail':
          response = await aiService.generateThumbnail(request);
          break;
        case 'translate':
          response = await aiService.translate(request.text, request.targetLang, request);
          break;
        case 'rewrite':
          response = await aiService.rewrite(request.text, request.style, request);
          break;
        case 'trend':
          response = await aiService.predictTrend(request.niche, request.dateRange);
          break;
        case 'viral':
          response = await aiService.predictViral(request.content, request.platform);
          break;
        case 'content_ideas':
          response = await aiService.generateContentIdeas(request.niche, request.count, request.platform);
          break;
        case 'script':
          response = await aiService.generateScript(request.type, request.topic, request);
          break;
        default:
          throw new Error(`Unknown AI job type: ${type}`);
      }

      const cost = await aiService.estimateCost(response.provider, response.model, response.tokensUsed);

      await db.creditBalance.update({
        where: { userId },
        data: { credits: { decrement: cost.estimatedCost }, lifetimeUsed: { increment: cost.estimatedCost }, lastUpdated: new Date() },
      });

      await db.aIJob.update({
        where: { id: jobId },
        data: { status: 'completed', response, cost, completedAt: new Date(), updatedAt: new Date() },
      });

      await db.usageRecord.create({
        data: { userId, provider: response.provider, model: response.model, tokens: response.tokensUsed, cost: cost.estimatedCost, type, createdAt: new Date() },
      });

      return response;
    },
    {
      connection: redis,
      concurrency: 5,
      limiter: { max: 30, duration: 60000 },
    }
  );

  worker.on('failed', async (job, error) => {
    if (job) {
      await db.aIJob.update({
        where: { id: job.data.jobId },
        data: { status: 'failed', error: error.message, updatedAt: new Date() },
      });
    }
  });

  return worker;
}
