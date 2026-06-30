# Storage Architecture

## Overview

Multi-tier storage strategy using PostgreSQL for relational data, Cloudflare R2 for media, and Redis for caching.

## PostgreSQL Schema Organization

### Schema Structure

```
supabase/
├── migrations/
│   ├── 001_create_extensions.sql
│   ├── 002_create_auth_tables.sql
│   ├── 003_create_organization_tables.sql
│   ├── 004_create_workspace_tables.sql
│   ├── 005_create_content_tables.sql
│   ├── 006_create_publishing_tables.sql
│   ├── 007_create_analytics_tables.sql
│   ├── 008_create_billing_tables.sql
│   ├── 009_create_notification_tables.sql
│   └── 010_create_admin_tables.sql
```

### Core Tables

```sql
-- Users (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  timezone TEXT DEFAULT 'UTC',
  locale TEXT DEFAULT 'en',
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Organizations
CREATE TABLE public.organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  owner_id UUID NOT NULL REFERENCES public.users(id),
  plan TEXT DEFAULT 'free',
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Organization Members
CREATE TABLE public.organization_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',
  invited_by UUID REFERENCES public.users(id),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

-- Workspaces
CREATE TABLE public.workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Channels (Social Media Connections)
CREATE TABLE public.channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  platform TEXT NOT NULL,
  platform_user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  avatar_url TEXT,
  credentials JSONB NOT NULL, -- Encrypted
  settings JSONB DEFAULT '{}',
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(workspace_id, platform, platform_user_id)
);

-- Contents
CREATE TABLE public.contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id),
  title TEXT,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'post',
  status TEXT DEFAULT 'draft',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at TIMESTAMPTZ
);

-- Content Versions
CREATE TABLE public.content_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id UUID NOT NULL REFERENCES public.contents(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  title TEXT,
  body TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_by UUID NOT NULL REFERENCES public.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(content_id, version_number)
);

-- Scheduled Posts
CREATE TABLE public.scheduled_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id UUID NOT NULL REFERENCES public.contents(id) ON DELETE CASCADE,
  channel_id UUID NOT NULL REFERENCES public.channels(id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  published_at TIMESTAMPTZ,
  status TEXT DEFAULT 'pending',
  platform_post_id TEXT,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Media
CREATE TABLE public.media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id),
  filename TEXT NOT NULL,
  original_url TEXT NOT NULL,
  r2_key TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  width INTEGER,
  height INTEGER,
  duration INTEGER,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- AI Generations
CREATE TABLE public.ai_generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id),
  organization_id UUID NOT NULL REFERENCES public.organizations(id),
  content_id UUID REFERENCES public.contents(id),
  prompt TEXT NOT NULL,
  provider TEXT NOT NULL,
  model TEXT NOT NULL,
  response TEXT,
  prompt_tokens INTEGER,
  completion_tokens INTEGER,
  total_tokens INTEGER,
  cost DECIMAL(10, 6),
  latency_ms INTEGER,
  status TEXT DEFAULT 'pending',
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Analytics
CREATE TABLE public.analytics_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL,
  channel_id UUID NOT NULL,
  date DATE NOT NULL,
  impressions INTEGER DEFAULT 0,
  reach INTEGER DEFAULT 0,
  engagement INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, channel_id, date)
);

-- Notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscriptions
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES public.organizations(id),
  plan TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  cancel_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Usage Records
CREATE TABLE public.usage_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES public.organizations(id),
  metric TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Indexes

```sql
-- Performance indexes
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_orgs_owner ON public.organizations(owner_id);
CREATE INDEX idx_org_members_user ON public.organization_members(user_id);
CREATE INDEX idx_org_members_org ON public.organization_members(organization_id);
CREATE INDEX idx_workspaces_org ON public.workspaces(organization_id);
CREATE INDEX idx_channels_workspace ON public.channels(workspace_id);
CREATE INDEX idx_contents_workspace ON public.contents(workspace_id);
CREATE INDEX idx_contents_user ON public.contents(user_id);
CREATE INDEX idx_contents_status ON public.contents(status);
CREATE INDEX idx_contents_created ON public.contents(created_at DESC);
CREATE INDEX idx_content_versions_content ON public.content_versions(content_id);
CREATE INDEX idx_scheduled_posts_scheduled ON public.scheduled_posts(scheduled_at);
CREATE INDEX idx_scheduled_posts_status ON public.scheduled_posts(status);
CREATE INDEX idx_media_workspace ON public.media(workspace_id);
CREATE INDEX idx_ai_generations_user ON public.ai_generations(user_id);
CREATE INDEX idx_ai_generations_org ON public.ai_generations(organization_id);
CREATE INDEX idx_analytics_daily_post ON public.analytics_daily(post_id);
CREATE INDEX idx_analytics_daily_date ON public.analytics_daily(date);
CREATE INDEX idx_notifications_user ON public.notifications(user_id);
CREATE INDEX idx_notifications_unread ON public.notifications(user_id) WHERE read_at IS NULL;
CREATE INDEX idx_subscriptions_org ON public.subscriptions(organization_id);
CREATE INDEX idx_usage_records_org ON public.usage_records(organization_id);
CREATE INDEX idx_usage_records_date ON public.usage_records(recorded_at);
```

## Cloudflare R2 for Media

### R2 Configuration

```typescript
// lib/storage/r2.ts
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const r2Client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID!,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY!
  }
});

const BUCKET_NAME = process.env.R2_BUCKET_NAME || 'contentos-media';

export class R2Storage {
  async uploadFile(
    key: string,
    body: Buffer,
    contentType: string
  ): Promise<string> {
    await r2Client.send(new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      Body: body,
      ContentType: contentType
    }));

    return `https://media.contentos.ai/${key}`;
  }

  async getSignedUploadUrl(
    key: string,
    contentType: string,
    expiresIn: number = 3600
  ): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      ContentType: contentType
    });

    return getSignedUrl(r2Client, command, { expiresIn });
  }

  async getSignedDownloadUrl(
    key: string,
    expiresIn: number = 3600
  ): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key
    });

    return getSignedUrl(r2Client, command, { expiresIn });
  }

  async deleteFile(key: string): Promise<void> {
    await r2Client.send(new DeleteObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key
    }));
  }

  generateKey(
    workspaceId: string,
    filename: string,
    type: 'media' | 'thumbnail' | 'processed'
  ): string {
    const timestamp = Date.now();
    const ext = filename.split('.').pop();
    const name = filename.replace(/\.[^/.]+$/, '').replace(/[^a-zA-Z0-9]/g, '_');
    return `${workspaceId}/${type}/${timestamp}_${name}.${ext}`;
  }
}
```

### Media Processing Pipeline

```typescript
// lib/storage/media-processor.ts
import sharp from 'sharp';

export class MediaProcessor {
  async processImage(
    input: Buffer,
    options: ImageOptions
  ): Promise<ProcessedImage> {
    const image = sharp(input);
    const metadata = await image.metadata();

    // Resize if needed
    if (options.width || options.height) {
      image.resize(options.width, options.height, {
        fit: options.fit || 'inside',
        withoutEnlargement: true
      });
    }

    // Convert format
    if (options.format) {
      image.toFormat(options.format, { quality: options.quality || 80 });
    }

    // Generate variants
    const variants: ProcessedImageVariant[] = [];

    // Original
    variants.push({
      key: options.outputKey,
      buffer: await image.toBuffer(),
      width: metadata.width!,
      height: metadata.height!
    });

    // Thumbnail
    const thumbnail = sharp(input)
      .resize(150, 150, { fit: 'cover' })
      .jpeg({ quality: 80 });

    variants.push({
      key: options.thumbnailKey || options.outputKey.replace('.', '_thumb.'),
      buffer: await thumbnail.toBuffer(),
      width: 150,
      height: 150
    });

    // Medium size
    const medium = sharp(input)
      .resize(800, 600, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 80 });

    variants.push({
      key: options.mediumKey || options.outputKey.replace('.', '_medium.'),
      buffer: await medium.toBuffer(),
      width: 800,
      height: 600
    });

    return { variants, metadata };
  }

  async optimizeForPlatform(
    input: Buffer,
    platform: string
  ): Promise<Buffer> {
    const platformConfigs: Record<string, ImageOptions> = {
      twitter: { width: 1200, height: 675, fit: 'cover', format: 'jpeg', quality: 85 },
      instagram: { width: 1080, height: 1080, fit: 'cover', format: 'jpeg', quality: 85 },
      linkedin: { width: 1200, height: 627, fit: 'cover', format: 'jpeg', quality: 85 },
      facebook: { width: 1200, height: 630, fit: 'cover', format: 'jpeg', quality: 85 }
    };

    const config = platformConfigs[platform] || { format: 'jpeg', quality: 80 };
    return sharp(input).resize(config.width, config.height, { fit: config.fit }).toBuffer();
  }
}
```

## Redis for Caching and Sessions

### Redis Configuration

```typescript
// lib/cache/redis.ts
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  db: 0,
  maxRetriesPerRequest: 3,
  retryDelayOnFailover: 100,
  enableReadyCheck: true,
  lazyConnect: true
});

// Cache namespaces
export const cacheKeys = {
  session: (id: string) => `session:${id}`,
  user: (id: string) => `user:${id}`,
  organization: (id: string) => `org:${id}`,
  workspace: (id: string) => `workspace:${id}`,
  content: (id: string) => `content:${id}`,
  analytics: (workspaceId: string, date: string) => `analytics:${workspaceId}:${date}`,
  rateLimit: (key: string) => `ratelimit:${key}`,
  aiCache: (hash: string) => `ai:cache:${hash}`
};

export class CacheManager {
  async get<T>(key: string): Promise<T | null> {
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  }

  async set<T>(key: string, value: T, ttl: number = 3600): Promise<void> {
    await redis.setex(key, ttl, JSON.stringify(value));
  }

  async del(key: string): Promise<void> {
    await redis.del(key);
  }

  async delPattern(pattern: string): Promise<void> {
    const keys = await redis.keys(pattern);
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  }

  async increment(key: string, ttl: number = 60): Promise<number> {
    const count = await redis.incr(key);
    if (count === 1) {
      await redis.expire(key, ttl);
    }
    return count;
  }

  // Session management
  async createSession(userId: string, session: SessionData): Promise<string> {
    const sessionId = generateId();
    await this.set(cacheKeys.session(sessionId), {
      userId,
      ...session,
      createdAt: Date.now()
    }, 7 * 24 * 3600); // 7 days
    return sessionId;
  }

  async getSession(sessionId: string): Promise<SessionData | null> {
    return this.get(cacheKeys.session(sessionId));
  }

  async destroySession(sessionId: string): Promise<void> {
    await this.del(cacheKeys.session(sessionId));
  }
}
```

### Cache Strategies

```typescript
// Cache-aside pattern
async function getCachedContent(id: string): Promise<Content | null> {
  const cacheKey = cacheKeys.content(id);

  // Try cache first
  const cached = await cache.get<Content>(cacheKey);
  if (cached) return cached;

  // Fetch from database
  const content = await db.contents.findById(id);
  if (content) {
    await cache.set(cacheKey, content, 3600); // 1 hour TTL
  }

  return content;
}

// Write-through cache
async function updateContent(id: string, data: Partial<Content>): Promise<Content> {
  const content = await db.contents.update(id, data);
  await cache.set(cacheKeys.content(id), content, 3600);
  return content;
}

// Cache invalidation
async function deleteContent(id: string): Promise<void> {
  await db.contents.delete(id);
  await cache.del(cacheKeys.content(id));
}
```

## Backup Strategy

### Database Backups

```yaml
# supabase/config.toml
[db]
backup_schedule = "0 2 * * *"  # Daily at 2 AM
backup_retention_days = 30
backup_bucket = "contentos-backups"
```

### Backup Procedures

| Type | Frequency | Retention | Storage |
|------|-----------|-----------|---------|
| Full Backup | Daily | 30 days | R2 |
| WAL Archival | Continuous | 7 days | R2 |
| Schema Snapshot | On migration | Permanent | Git |
| Media Backup | Daily | 90 days | R2 |

### Recovery Procedures

```bash
# Restore from backup
supabase db restore --backup-id <backup_id>

# Point-in-time recovery
supabase db restore --point-in-time "2026-01-15T10:30:00Z"

# Verify backup integrity
supabase db verify-backup <backup_id>
```

## Data Retention Policies

### Retention Rules

| Data Type | Retention Period | Action |
|-----------|------------------|--------|
| User Accounts | Until deletion request | Anonymize |
| Content | 2 years after last update | Archive |
| Analytics | 1 year | Aggregate then delete |
| Media | 1 year after last use | Delete |
| AI Generations | 90 days | Delete |
| Notifications | 30 days | Delete |
| Audit Logs | 1 year | Archive |
| Session Data | 7 days | Delete |
| Rate Limit Data | 24 hours | Delete |

### Automated Cleanup

```typescript
// Scheduled cleanup job
const cleanupJob = {
  name: 'data-cleanup',
  cron: '0 3 * * *', // Daily at 3 AM
  handler: async () => {
    // Clean old analytics
    await db.query(`
      DELETE FROM analytics_daily
      WHERE date < NOW() - INTERVAL '1 year'
    `);

    // Clean old notifications
    await db.query(`
      DELETE FROM notifications
      WHERE created_at < NOW() - INTERVAL '30 days'
    `);

    // Clean old AI generations
    await db.query(`
      DELETE FROM ai_generations
      WHERE created_at < NOW() - INTERVAL '90 days'
    `);

    // Clean expired sessions
    await cache.delPattern('session:*');
  }
};
```
