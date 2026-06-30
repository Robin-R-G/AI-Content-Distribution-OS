# Rate Limiting Strategy

## Overview

Multi-tier rate limiting to protect the platform from abuse while ensuring fair usage across users, organizations, and endpoints.

## Rate Limit Tiers

```
┌─────────────────────────────────────────────────────────────────┐
│                   RATE LIMITING TIERS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Global Rate Limit                     │   │
│  │  Maximum: 10,000 requests/minute                        │   │
│  │  Scope: All traffic                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Endpoint Rate Limits                   │   │
│  │  Auth:        5 requests/15 minutes                      │   │
│  │  AI Generate: 10 requests/minute                         │   │
│  │  Upload:      20 requests/minute                         │   │
│  │  API General: 100 requests/minute                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     User Rate Limits                     │   │
│  │  Free:     60 requests/minute                           │   │
│  │  Pro:      300 requests/minute                          │   │
│  │  Business: 1,000 requests/minute                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 Organization Rate Limits                 │   │
│  │  Free:     500 requests/minute                          │   │
│  │  Pro:      2,000 requests/minute                        │   │
│  │  Business: 5,000 requests/minute                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Implementation

### Rate Limiter Service

```typescript
// lib/rate-limiter/rate-limiter.ts
import Redis from 'ioredis';

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  keyPrefix: string;
  blockDurationMs?: number;
}

interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetAt: number;
  retryAfter?: number;
  total: number;
}

class RateLimiter {
  private redis: Redis;
  private configs: Map<string, RateLimitConfig>;

  constructor(redis: Redis) {
    this.redis = redis;
    this.configs = new Map();
  }

  addConfig(name: string, config: RateLimitConfig): void {
    this.configs.set(name, config);
  }

  async checkLimit(
    configName: string,
    identifier: string
  ): Promise<RateLimitResult> {
    const config = this.configs.get(configName);
    if (!config) {
      throw new Error(`Rate limit config '${configName}' not found`);
    }

    const key = `${config.keyPrefix}:${identifier}`;
    const now = Date.now();
    const windowStart = now - config.windowMs;

    // Use sliding window counter
    const pipeline = this.redis.pipeline();

    // Remove old entries
    pipeline.zremrangebyscore(key, 0, windowStart);

    // Add current request
    pipeline.zadd(key, now, `${now}`);

    // Count requests in window
    pipeline.zcard(key);

    // Set expiry
    pipeline.pexpire(key, config.windowMs);

    const results = await pipeline.exec();
    const requestCount = results![2][1] as number;

    const resetAt = now + config.windowMs;
    const remaining = Math.max(0, config.maxRequests - requestCount);
    const allowed = requestCount <= config.maxRequests;

    let retryAfter: number | undefined;
    if (!allowed) {
      // Get oldest request in window
      const oldest = await this.redis.zrange(key, 0, 0, 'WITHSCORES');
      if (oldest.length >= 2) {
        retryAfter = Math.ceil(
          (parseInt(oldest[1]) + config.windowMs - now) / 1000
        );
      }
    }

    return {
      allowed,
      remaining,
      resetAt,
      retryAfter,
      total: config.maxRequests
    };
  }

  async blockIdentifier(
    configName: string,
    identifier: string,
    durationMs: number
  ): Promise<void> {
    const config = this.configs.get(configName);
    if (!config) return;

    const key = `blocked:${config.keyPrefix}:${identifier}`;
    await this.redis.setex(key, Math.ceil(durationMs / 1000), '1');
  }

  async isBlocked(configName: string, identifier: string): Promise<boolean> {
    const config = this.configs.get(configName);
    if (!config) return false;

    const key = `blocked:${config.keyPrefix}:${identifier}`;
    const blocked = await this.redis.exists(key);
    return blocked === 1;
  }
}
```

### Rate Limit Configurations

```typescript
// lib/rate-limiter/configs.ts
export const rateLimitConfigs: Record<string, RateLimitConfig> = {
  // Global
  global: {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 10000,
    keyPrefix: 'rl:global'
  },

  // Auth endpoints
  'auth:register': {
    windowMs: 15 * 60 * 1000, // 15 minutes
    maxRequests: 5,
    keyPrefix: 'rl:auth:register'
  },
  'auth:login': {
    windowMs: 15 * 60 * 1000, // 15 minutes
    maxRequests: 5,
    keyPrefix: 'rl:auth:login',
    blockDurationMs: 30 * 60 * 1000 // Block for 30 minutes after 5 failures
  },
  'auth:password-reset': {
    windowMs: 60 * 60 * 1000, // 1 hour
    maxRequests: 3,
    keyPrefix: 'rl:auth:password-reset'
  },

  // API endpoints
  'api:general': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 100,
    keyPrefix: 'rl:api:general'
  },
  'api:content:create': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 20,
    keyPrefix: 'rl:api:content:create'
  },
  'api:upload': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 20,
    keyPrefix: 'rl:api:upload'
  },

  // AI endpoints
  'ai:generate': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 10,
    keyPrefix: 'rl:ai:generate'
  },
  'ai:generate:batch': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 5,
    keyPrefix: 'rl:ai:generate:batch'
  },

  // Publishing
  'publish:schedule': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 30,
    keyPrefix: 'rl:publish:schedule'
  },
  'publish:now': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 10,
    keyPrefix: 'rl:publish:now'
  }
};

// Plan-based limits
export const planLimits: Record<string, PlanLimits> = {
  free: {
    requestsPerMinute: 60,
    aiRequestsPerDay: 50,
    storageGb: 1,
    contentPerMonth: 100
  },
  pro: {
    requestsPerMinute: 300,
    aiRequestsPerDay: 500,
    storageGb: 10,
    contentPerMonth: 1000
  },
  business: {
    requestsPerMinute: 1000,
    aiRequestsPerDay: 5000,
    storageGb: 100,
    contentPerMonth: 10000
  }
};
```

### Middleware Implementation

```typescript
// lib/middleware/rate-limit.ts
import { Context, Next } from 'hono';

export function rateLimitMiddleware(configName: string) {
  return async (c: Context, next: Next) => {
    const rateLimiter = c.get('rateLimiter') as RateLimiter;

    // Generate identifier based on config
    const identifier = getIdentifier(c, configName);

    // Check if blocked
    const isBlocked = await rateLimiter.isBlocked(configName, identifier);
    if (isBlocked) {
      return c.json(
        {
          success: false,
          error: {
            code: 'RATE_LIMITED',
            message: 'Too many requests. Please try again later.'
          }
        },
        429
      );
    }

    // Check rate limit
    const result = await rateLimiter.checkLimit(configName, identifier);

    // Set rate limit headers
    c.header('X-RateLimit-Limit', result.total.toString());
    c.header('X-RateLimit-Remaining', result.remaining.toString());
    c.header('X-RateLimit-Reset', Math.ceil(result.resetAt / 1000).toString());

    if (!result.allowed) {
      c.header('Retry-After', result.retryAfter?.toString() || '60');

      // Block identifier if configured
      const config = rateLimiter.getConfig(configName);
      if (config.blockDurationMs) {
        await rateLimiter.blockIdentifier(
          configName,
          identifier,
          config.blockDurationMs
        );
      }

      return c.json(
        {
          success: false,
          error: {
            code: 'RATE_LIMITED',
            message: 'Rate limit exceeded',
            retryAfter: result.retryAfter
          }
        },
        429
      );
    }

    await next();
  };
}

function getIdentifier(c: Context, configName: string): string {
  // Use user ID if authenticated
  const userId = c.get('userId');
  if (userId) return `user:${userId}`;

  // Use organization ID if available
  const orgId = c.get('organizationId');
  if (orgId) return `org:${orgId}`;

  // Fall back to IP
  return `ip:${c.req.header('x-forwarded-for') || c.req.header('x-real-ip') || 'unknown'}`;
}
```

## Per-Endpoint Limits

| Endpoint | Window | Limit | Scope |
|----------|--------|-------|-------|
| POST /auth/register | 15 min | 5 | IP |
| POST /auth/login | 15 min | 5 | IP |
| POST /auth/forgot-password | 1 hour | 3 | IP |
| POST /auth/mfa/verify | 5 min | 10 | User |
| GET /contents | 1 min | 100 | User |
| POST /contents | 1 min | 20 | User |
| PUT /contents/:id | 1 min | 50 | User |
| DELETE /contents/:id | 1 min | 20 | User |
| POST /ai/generate | 1 min | 10 | User |
| POST /ai/generate/batch | 1 min | 5 | User |
| POST /media/upload | 1 min | 20 | User |
| POST /publish/schedule | 1 min | 30 | User |
| POST /publish/now | 1 min | 10 | User |
| GET /analytics/dashboard | 1 min | 30 | User |
| GET /analytics/export | 5 min | 5 | User |
| POST /billing/subscription | 1 hour | 10 | User |

## Per-User Limits

```typescript
export const userLimits: Record<string, UserLimits> = {
  free: {
    contentPerMonth: 100,
    aiRequestsPerDay: 50,
    storageGb: 1,
    channels: 3,
    workspaces: 1,
    teamMembers: 1
  },
  pro: {
    contentPerMonth: 1000,
    aiRequestsPerDay: 500,
    storageGb: 10,
    channels: 10,
    workspaces: 5,
    teamMembers: 10
  },
  business: {
    contentPerMonth: 10000,
    aiRequestsPerDay: 5000,
    storageGb: 100,
    channels: 50,
    workspaces: 25,
    teamMembers: 50
  }
};

async function checkUserLimits(
  userId: string,
  resource: string
): Promise<boolean> {
  const user = await db.users.findById(userId);
  const org = await db.organizations.findById(user.organization_id);
  const limits = userLimits[org.plan] || userLimits.free;

  const usage = await getUserUsage(userId, resource);

  switch (resource) {
    case 'content':
      return usage < limits.contentPerMonth;
    case 'ai':
      return usage < limits.aiRequestsPerDay;
    case 'storage':
      return usage < limits.storageGb * 1024 * 1024 * 1024;
    case 'channels':
      return usage < limits.channels;
    default:
      return true;
  }
}
```

## Per-Organization Limits

```typescript
export const orgLimits: Record<string, OrgLimits> = {
  free: {
    requestsPerMinute: 500,
    storageGb: 1,
    teamMembers: 1,
    workspaces: 1
  },
  pro: {
    requestsPerMinute: 2000,
    storageGb: 10,
    teamMembers: 10,
    workspaces: 5
  },
  business: {
    requestsPerMinute: 5000,
    storageGb: 100,
    teamMembers: 50,
    workspaces: 25
  }
};

async function checkOrgLimits(
  orgId: string,
  resource: string
): Promise<boolean> {
  const org = await db.organizations.findById(orgId);
  const limits = orgLimits[org.plan] || orgLimits.free;

  const usage = await getOrgUsage(orgId, resource);

  switch (resource) {
    case 'requests':
      return usage < limits.requestsPerMinute;
    case 'storage':
      return usage < limits.storageGb * 1024 * 1024 * 1024;
    case 'teamMembers':
      return usage < limits.teamMembers;
    case 'workspaces':
      return usage < limits.workspaces;
    default:
      return true;
  }
}
```

## Plugin Rate Limits

```typescript
export const pluginRateLimits: Record<string, PluginRateLimit> = {
  'social-posting': {
    requestsPerMinute: 30,
    requestsPerHour: 500,
    burstLimit: 10
  },
  'ai-generation': {
    requestsPerMinute: 10,
    requestsPerHour: 200,
    burstLimit: 5
  },
  'analytics-fetch': {
    requestsPerMinute: 20,
    requestsPerHour: 300,
    burstLimit: 10
  }
};

class PluginRateLimiter {
  async checkPluginLimit(
    pluginId: string,
    userId: string
  ): Promise<RateLimitResult> {
    const config = pluginRateLimits[pluginId];
    if (!config) return { allowed: true, remaining: 999, resetAt: 0, total: 999 };

    const key = `plugin:${pluginId}:${userId}`;

    // Check per-minute limit
    const minuteResult = await this.checkWindow(key, 'minute', config.requestsPerMinute);
    if (!minuteResult.allowed) return minuteResult;

    // Check per-hour limit
    const hourResult = await this.checkWindow(key, 'hour', config.requestsPerHour);
    return hourResult;
  }
}
```

## AI Provider Rate Limits

```typescript
export const aiProviderLimits: Record<string, AIProviderLimit> = {
  openai: {
    requestsPerMinute: 60,
    tokensPerMinute: 90000,
    requestsPerDay: 10000
  },
  anthropic: {
    requestsPerMinute: 40,
    tokensPerMinute: 80000,
    requestsPerDay: 8000
  },
  google: {
    requestsPerMinute: 60,
    tokensPerMinute: 120000,
    requestsPerDay: 15000
  }
};

class AIProviderRateLimiter {
  private usage: Map<string, ProviderUsage> = new Map();

  async checkProviderLimit(
    provider: string,
    estimatedTokens: number
  ): Promise<AIProviderRateLimitResult> {
    const config = aiProviderLimits[provider];
    if (!config) return { allowed: true, remaining: { requests: 999, tokens: 999999 } };

    const usage = this.getUsage(provider);

    // Check request limit
    if (usage.requests >= config.requestsPerMinute) {
      return {
        allowed: false,
        remaining: {
          requests: 0,
          tokens: config.tokensPerMinute - usage.tokens
        },
        retryAfter: this.getRetryAfter(usage.windowStart, 60000)
      };
    }

    // Check token limit
    if (usage.tokens + estimatedTokens > config.tokensPerMinute) {
      return {
        allowed: false,
        remaining: {
          requests: config.requestsPerMinute - usage.requests,
          tokens: 0
        },
        retryAfter: this.getRetryAfter(usage.windowStart, 60000)
      };
    }

    // Update usage
    usage.requests++;
    usage.tokens += estimatedTokens;

    return {
      allowed: true,
      remaining: {
        requests: config.requestsPerMinute - usage.requests,
        tokens: config.tokensPerMinute - usage.tokens
      }
    };
  }

  private getUsage(provider: string): ProviderUsage {
    const now = Date.now();
    const usage = this.usage.get(provider);

    if (!usage || now - usage.windowStart > 60000) {
      const newUsage: ProviderUsage = {
        requests: 0,
        tokens: 0,
        windowStart: now
      };
      this.usage.set(provider, newUsage);
      return newUsage;
    }

    return usage;
  }

  private getRetryAfter(windowStart: number, windowMs: number): number {
    return Math.ceil((windowStart + windowMs - Date.now()) / 1000);
  }
}
```

### Rate Limit Headers

```typescript
// Standard rate limit response headers
const rateLimitHeaders = {
  'X-RateLimit-Limit': '100',
  'X-RateLimit-Remaining': '95',
  'X-RateLimit-Reset': '1640995200',
  'Retry-After': '30' // Only when rate limited
};

// AI-specific headers
const aiRateLimitHeaders = {
  'X-AI-RateLimit-Limit': '10',
  'X-AI-RateLimit-Remaining': '8',
  'X-AI-RateLimit-Reset': '1640995200',
  'X-AI-Tokens-Remaining': '85000'
};
```

### Rate Limit Monitoring

```typescript
// Track rate limit hits
async function trackRateLimitHit(
  configName: string,
  identifier: string,
  blocked: boolean
): Promise<void> {
  await analytics.track('rate_limit_hit', {
    config: configName,
    identifier,
    blocked,
    timestamp: new Date().toISOString()
  });
}

// Alert on high rate limit usage
async function checkRateLimitAlerts(): Promise<void> {
  const stats = await getRateLimitStats();

  for (const [config, stat] of Object.entries(stats)) {
    if (stat.blockedPercentage > 10) {
      await sendAlert({
        level: 'warning',
        title: `High rate limit blocks for ${config}`,
        message: `${stat.blockedPercentage}% of requests are being rate limited`,
        metadata: stat
      });
    }
  }
}
```
