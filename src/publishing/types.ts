export type QueuePriority = 'high' | 'normal' | 'low' | 'bulk';

export interface ScheduleConfig {
  scheduledAt: Date | string;
  timezone?: string;
  recurring?: {
    frequency: 'daily' | 'weekly' | 'monthly';
    interval: number;
    endDate?: Date | string;
  };
}

export interface RetryConfig {
  maxRetries: number;
  backoffMs: number;
  backoffMultiplier: number;
  retryOn: string[];
}

export interface PlatformPublishConfig {
  platform: string;
  accountId: string;
  content: Record<string, unknown>;
  media?: Array<{ url: string; type: string; alt?: string }>;
  tags?: string[];
  location?: { lat: number; lng: number; name: string };
  settings?: Record<string, unknown>;
}

export interface CrossPostConfig {
  enabled: boolean;
  adaptContent: boolean;
  platformOverrides: Record<string, Partial<PlatformPublishConfig>>;
}

export interface PublishJob {
  id: string;
  workspaceId: string;
  postId: string;
  status: 'pending' | 'scheduled' | 'processing' | 'published' | 'failed' | 'cancelled' | 'retrying';
  priority: QueuePriority;
  platforms: PlatformPublishConfig[];
  crossPost?: CrossPostConfig;
  schedule?: ScheduleConfig;
  retry: RetryConfig;
  attempts: number;
  lastError?: string;
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface PublishQueueItem {
  id: string;
  jobId: string;
  workspaceId: string;
  position: number;
  priority: QueuePriority;
  status: 'queued' | 'processing' | 'completed' | 'failed';
  scheduledFor?: Date;
  createdAt: Date;
}

export interface PublishResult {
  jobId: string;
  platform: string;
  accountId: string;
  success: boolean;
  postId?: string;
  postUrl?: string;
  error?: string;
  metadata?: Record<string, unknown>;
  publishedAt: Date;
}

export interface PublishHistory {
  id: string;
  jobId: string;
  workspaceId: string;
  postId: string;
  results: PublishResult[];
  totalPlatforms: number;
  successfulPlatforms: number;
  failedPlatforms: number;
  createdAt: Date;
}
