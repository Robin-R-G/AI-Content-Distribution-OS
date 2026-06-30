# Worker Queue Architecture

## Overview

BullMQ with Redis provides reliable job processing for async operations including publishing, analytics, notifications, and AI processing.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     QUEUE LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    BullMQ + Redis                        │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │Publishing│  │Analytics │  │   AI     │  │  Media  ││   │
│  │  │  Queue   │  │  Queue   │  │  Queue   │  │  Queue  ││   │
│  │  │ Priority │  │ Priority │  │ Priority │  │Priority ││   │
│  │  │ 1-10     │  │ 5-10     │  │ 1-5      │  │ 5-10    ││   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘│   │
│  │       │              │              │              │      │   │
│  │  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐  ┌────▼────┐│   │
│  │  │Publisher │  │Analytics │  │    AI    │  │  Media  ││   │
│  │  │ Workers  │  │ Workers  │  │ Workers  │  │ Workers ││   │
│  │  │ (3-5)    │  │ (2-3)    │  │ (5-10)   │  │ (2-3)   ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │   │
│  │  │Notificat.│  │  Email   │  │    Scheduled Tasks   │  │   │
│  │  │  Queue   │  │  Queue   │  │      (Cron)          │  │   │
│  │  └────┬─────┘  └────┬─────┘  └──────────┬───────────┘  │   │
│  │       │              │                    │              │   │
│  │  ┌────▼─────┐  ┌────▼─────┐  ┌──────────▼───────────┐  │   │
│  │  │Notificat.│  │  Email   │  │      Scheduler       │  │   │
│  │  │ Workers  │  │ Workers  │  │      Workers         │  │   │
│  │  │ (2-3)    │  │ (2-3)    │  │      (1)             │  │   │
│  │  └──────────┘  └──────────┘  └──────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  Monitoring Dashboard                    │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │  Queue   │  │   Job    │  │  Worker  │  │  Error  ││   │
│  │  │  Stats   │  │  Metrics │  │  Health  │  │  Log    ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## BullMQ Setup

### Queue Configuration

```typescript
import { Queue, Worker, QueueScheduler } from 'bullmq';
import Redis from 'ioredis';

// Redis connection
const connection = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  maxRetriesPerRequest: null,
  enableReadyCheck: false
});

// Queue definitions
const queues = {
  publishing: new Queue('publishing', { connection }),
  analytics: new Queue('analytics', { connection }),
  ai: new Queue('ai-processing', { connection }),
  media: new Queue('media-processing', { connection }),
  notifications: new Queue('notifications', { connection }),
  email: new Queue('email', { connection }),
  scheduled: new Queue('scheduled-tasks', { connection })
};

// Queue schedulers
const schedulers = {
  publishing: new QueueScheduler('publishing', { connection }),
  analytics: new QueueScheduler('analytics', { connection }),
  ai: new QueueScheduler('ai-processing', { connection }),
  media: new QueueScheduler('media-processing', { connection }),
  notifications: new QueueScheduler('notifications', { connection }),
  email: new QueueScheduler('email', { connection }),
  scheduled: new QueueScheduler('scheduled-tasks', { connection })
};
```

## Queue Types

### 1. Publishing Queue

```typescript
interface PublishingJobData {
  postId: string;
  contentId: string;
  channelIds: string[];
  scheduledAt: string;
  retryCount?: number;
  metadata?: Record<string, any>;
}

// Job options
const publishingOptions = {
  priority: 1, // High priority
  delay: 0,
  attempts: 3,
  backoff: {
    type: 'exponential',
    delay: 5000 // 5 seconds
  },
  removeOnComplete: {
    age: 7 * 24 * 3600, // 7 days
    count: 1000
  },
  removeOnFail: {
    age: 30 * 24 * 3600 // 30 days
  }
};

// Add job
await queues.publishing.add('publish-post', jobData, publishingOptions);

// Worker
const publishingWorker = new Worker('publishing', async (job) => {
  const { postId, channelIds, scheduledAt } = job.data;

  for (const channelId of channelIds) {
    try {
      await job.updateProgress({ channelId, status: 'publishing' });
      await publishToChannel(postId, channelId);
      await job.updateProgress({ channelId, status: 'completed' });
    } catch (error) {
      await job.updateProgress({ channelId, status: 'failed', error: error.message });
      throw error;
    }
  }
}, {
  connection,
  concurrency: 5,
  limiter: {
    max: 10,
    duration: 60000 // 10 jobs per minute
  }
});
```

### 2. Analytics Queue

```typescript
interface AnalyticsJobData {
  type: 'collect' | 'aggregate' | 'report';
  postId?: string;
  channelId?: string;
  period?: 'hourly' | 'daily' | 'weekly';
  dateRange?: { start: string; end: string };
}

const analyticsOptions = {
  priority: 5,
  attempts: 3,
  backoff: {
    type: 'exponential',
    delay: 10000 // 10 seconds
  }
};

// Add collection job
await queues.analytics.add('collect-analytics', {
  type: 'collect',
  channelId: 'channel-123',
  postId: 'post-456'
}, analyticsOptions);

// Worker
const analyticsWorker = new Worker('analytics', async (job) => {
  switch (job.data.type) {
    case 'collect':
      await collectAnalytics(job.data);
      break;
    case 'aggregate':
      await aggregateAnalytics(job.data.period, job.data.dateRange);
      break;
    case 'report':
      await generateReport(job.data);
      break;
  }
}, { connection, concurrency: 3 });
```

### 3. AI Processing Queue

```typescript
interface AIJobData {
  type: 'generate' | 'improve' | 'translate' | 'summarize';
  contentId?: string;
  prompt: string;
  provider: string;
  model: string;
  userId: string;
  organizationId: string;
  options?: {
    temperature?: number;
    maxTokens?: number;
    language?: string;
  };
}

const aiOptions = {
  priority: 3,
  attempts: 3,
  backoff: {
    type: 'exponential',
    delay: 5000
  },
  timeout: 60000 // 60 seconds
};

// Worker
const aiWorker = new Worker('ai-processing', async (job) => {
  const { type, prompt, provider, model, options } = job.data;

  // Check budget
  const budget = await checkAIBudget(job.data.organizationId);
  if (budget.exceeded) {
    throw new BudgetExceededError();
  }

  // Generate content
  const result = await aiProvider.generate({
    prompt,
    model,
    ...options
  });

  // Track usage
  await trackAIUsage(job.data.userId, result.usage, provider);

  return result;
}, {
  connection,
  concurrency: 10,
  limiter: {
    max: 20,
    duration: 60000
  }
});
```

### 4. Media Processing Queue

```typescript
interface MediaJobData {
  type: 'upload' | 'resize' | 'optimize' | 'transcode';
  mediaId: string;
  filePath: string;
  options?: {
    width?: number;
    height?: number;
    quality?: number;
    format?: string;
  };
}

const mediaOptions = {
  priority: 5,
  attempts: 3,
  backoff: {
    type: 'exponential',
    delay: 10000
  },
  timeout: 120000 // 2 minutes
};

// Worker
const mediaWorker = new Worker('media-processing', async (job) => {
  const { type, mediaId, filePath, options } = job.data;

  switch (type) {
    case 'resize':
      return await resizeMedia(filePath, options);
    case 'optimize':
      return await optimizeMedia(filePath, options);
    case 'transcode':
      return await transcodeVideo(filePath, options);
  }
}, { connection, concurrency: 3 });
```

### 5. Notifications Queue

```typescript
interface NotificationJobData {
  type: 'in-app' | 'email' | 'push';
  userId: string;
  title: string;
  body: string;
  data?: Record<string, any>;
  channels?: string[];
}

const notificationOptions = {
  priority: 7,
  attempts: 5,
  backoff: {
    type: 'exponential',
    delay: 5000
  }
};

// Worker
const notificationWorker = new Worker('notifications', async (job) => {
  const { type, userId, title, body, data } = job.data;

  switch (type) {
    case 'in-app':
      await sendInAppNotification(userId, { title, body, data });
      break;
    case 'email':
      await sendEmailNotification(userId, { title, body, data });
      break;
    case 'push':
      await sendPushNotification(userId, { title, body, data });
      break;
  }
}, { connection, concurrency: 5 });
```

## Job Priorities

| Priority | Queue | Job Type |
|----------|-------|----------|
| 1 | Publishing | Immediate publish |
| 2 | Publishing | Scheduled publish |
| 3 | AI | Content generation |
| 4 | Media | Critical processing |
| 5 | Analytics | Data collection |
| 6 | Media | Standard processing |
| 7 | Notifications | Urgent notifications |
| 8 | Email | Transactional email |
| 9 | Notifications | Digest notifications |
| 10 | Analytics | Report generation |

## Retry Strategies

```typescript
interface RetryStrategy {
  type: 'fixed' | 'exponential' | 'linear';
  delay: number;
  maxRetries: number;
  maxDelay?: number;
}

const retryStrategies: Record<string, RetryStrategy> = {
  publishing: {
    type: 'exponential',
    delay: 5000,
    maxRetries: 3,
    maxDelay: 300000 // 5 minutes
  },
  analytics: {
    type: 'exponential',
    delay: 10000,
    maxRetries: 3,
    maxDelay: 600000 // 10 minutes
  },
  ai: {
    type: 'exponential',
    delay: 5000,
    maxRetries: 3,
    maxDelay: 60000 // 1 minute
  },
  media: {
    type: 'exponential',
    delay: 10000,
    maxRetries: 3,
    maxDelay: 300000
  },
  notifications: {
    type: 'exponential',
    delay: 5000,
    maxRetries: 5,
    maxDelay: 120000 // 2 minutes
  }
};

// Retry logic
async function retryJob(job: Job, strategy: RetryStrategy): Promise<void> {
  const delay = calculateDelay(job.attemptsMade, strategy);
  await job.retry({ delay });
}

function calculateDelay(attempt: number, strategy: RetryStrategy): number {
  switch (strategy.type) {
    case 'fixed':
      return strategy.delay;
    case 'linear':
      return strategy.delay * attempt;
    case 'exponential':
      return Math.min(strategy.delay * Math.pow(2, attempt), strategy.maxDelay || Infinity);
  }
}
```

## Concurrency Control

```typescript
interface ConcurrencyConfig {
  queue: string;
  concurrency: number;
  rateLimit?: {
    max: number;
    duration: number;
  };
}

const concurrencyConfigs: ConcurrencyConfig[] = [
  { queue: 'publishing', concurrency: 5, rateLimit: { max: 10, duration: 60000 } },
  { queue: 'analytics', concurrency: 3 },
  { queue: 'ai-processing', concurrency: 10, rateLimit: { max: 20, duration: 60000 } },
  { queue: 'media-processing', concurrency: 3 },
  { queue: 'notifications', concurrency: 5 },
  { queue: 'email', concurrency: 3 },
  { queue: 'scheduled-tasks', concurrency: 1 }
];

// Worker with concurrency
function createWorker(queueName: string, processor: Processor) {
  const config = concurrencyConfigs.find(c => c.queue === queueName);

  return new Worker(queueName, processor, {
    connection,
    concurrency: config?.concurrency || 5,
    limiter: config?.rateLimit
  });
}
```

## Dead Letter Queues

```typescript
class DeadLetterManager {
  private dlqQueue: Queue;

  constructor() {
    this.dlqQueue = new Queue('dead-letter', { connection });
  }

  async moveToDLQ(job: Job, error: Error): Promise<void> {
    await this.dlqQueue.add('failed-job', {
      originalQueue: job.queueName,
      jobId: job.id,
      data: job.data,
      error: {
        message: error.message,
        stack: error.stack,
        timestamp: new Date().toISOString()
      },
      attemptsMade: job.attemptsMade,
      failedReason: job.failedReason
    });
  }

  async retryFromDLQ(dlqJobId: string): Promise<void> {
    const dlqJob = await this.dlqQueue.getJob(dlqJobId);
    if (!dlqJob) throw new Error('DLQ job not found');

    const { originalQueue, data } = dlqJob.data;
    const queue = queues[originalQueue as keyof typeof queues];

    await queue.add('retried-job', data, {
      attempts: 3,
      backoff: { type: 'exponential', delay: 5000 }
    });

    await dlqJob.remove();
  }

  async getDLQJobs(queueName?: string): Promise<Job[]> {
    const jobs = await this.dlqQueue.getJobs(['waiting', 'completed']);
    if (queueName) {
      return jobs.filter(j => j.data.originalQueue === queueName);
    }
    return jobs;
  }
}
```

### DLQ Monitoring

```typescript
// Alert on DLQ jobs
const dlqWorker = new Worker('dead-letter', async (job) => {
  const { originalQueue, error } = job.data;

  // Send alert
  await sendAlert({
    level: 'warning',
    title: `Job failed in ${originalQueue}`,
    message: error.message,
    metadata: {
      queue: originalQueue,
      jobId: job.id,
      attempts: job.data.attemptsMade
    }
  });
}, { connection, concurrency: 1 });
```

## Scheduled Tasks

```typescript
// Cron-based scheduled tasks
interface ScheduledTask {
  name: string;
  cron: string;
  queue: string;
  jobType: string;
  data: Record<string, any>;
}

const scheduledTasks: ScheduledTask[] = [
  {
    name: 'collect-daily-analytics',
    cron: '0 1 * * *', // Daily at 1 AM
    queue: 'analytics',
    jobType: 'aggregate',
    data: { type: 'aggregate', period: 'daily' }
  },
  {
    name: 'send-daily-digest',
    cron: '0 9 * * *', // Daily at 9 AM
    queue: 'email',
    jobType: 'send-digest',
    data: { type: 'digest' }
  },
  {
    name: 'cleanup-expired-sessions',
    cron: '0 * * * *', // Every hour
    queue: 'scheduled-tasks',
    jobType: 'cleanup',
    data: { type: 'sessions' }
  }
];

// Scheduler worker
const schedulerWorker = new Worker('scheduled-tasks', async (job) => {
  const task = scheduledTasks.find(t => t.name === job.data.taskName);
  if (!task) return;

  const queue = queues[task.queue as keyof typeof queues];
  await queue.add(task.jobType, task.data);
}, { connection, concurrency: 1 });
```
