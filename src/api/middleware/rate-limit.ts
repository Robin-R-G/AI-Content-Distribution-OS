import { Request, Response, NextFunction } from 'express';

interface RateLimitConfig {
  windowMs: number;
  max: number;
  message?: string;
  keyGenerator?: (req: Request) => string;
  skip?: (req: Request) => boolean;
}

interface SlidingWindowEntry {
  count: number;
  resetTime: number;
}

export function slidingWindowRateLimit(redis: any, config: RateLimitConfig) {
  const { windowMs, max, message, keyGenerator, skip } = config;

  return async (req: Request, res: Response, next: NextFunction) => {
    if (skip?.(req)) return next();

    const key = keyGenerator ? keyGenerator(req) : `${req.ip}:${req.baseUrl}${req.path}`;
    const now = Date.now();
    const windowStart = now - windowMs;
    const rateLimitKey = `sliding:${key}`;

    try {
      const pipeline = redis.pipeline();
      pipeline.zremrangebyscore(rateLimitKey, 0, windowStart);
      pipeline.zadd(rateLimitKey, now, `${now}-${Math.random()}`);
      pipeline.zcard(rateLimitKey);
      pipeline.pexpire(rateLimitKey, windowMs);

      const results = await pipeline.exec();
      const count = results[2][1] as number;

      const resetTime = Math.ceil((now + windowMs) / 1000);
      res.setHeader('X-RateLimit-Limit', max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, max - count));
      res.setHeader('X-RateLimit-Reset', resetTime);

      if (count > max) {
        return res.status(429).json({
          error: message || 'Too many requests',
          retryAfter: Math.ceil(windowMs / 1000),
        });
      }

      next();
    } catch {
      next();
    }
  };
}

const endpointLimits: Record<string, { max: number; windowMs: number }> = {
  'POST /api/auth/login': { max: 5, windowMs: 900000 },
  'POST /api/auth/register': { max: 3, windowMs: 3600000 },
  'POST /api/ai/generate': { max: 20, windowMs: 60000 },
  'POST /api/publish': { max: 30, windowMs: 60000 },
  'GET /api/analytics': { max: 60, windowMs: 60000 },
  'POST /api/webhooks': { max: 10, windowMs: 60000 },
};

export function endpointRateLimit(redis: any) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const endpointKey = `${req.method} ${req.baseUrl}${req.path}`;
    const limit = endpointLimits[endpointKey];

    if (!limit) return next();

    const user = (req as any).user;
    const key = `endpoint:${endpointKey}:${user?.userId ?? req.ip}`;
    const now = Date.now();
    const windowStart = now - limit.windowMs;

    try {
      const pipeline = redis.pipeline();
      pipeline.zremrangebyscore(key, 0, windowStart);
      pipeline.zadd(key, now, `${now}-${Math.random()}`);
      pipeline.zcard(key);
      pipeline.pexpire(key, limit.windowMs);

      const results = await pipeline.exec();
      const count = results[2][1] as number;

      res.setHeader('X-RateLimit-Limit', limit.max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, limit.max - count));

      if (count > limit.max) {
        return res.status(429).json({
          error: 'Rate limit exceeded for this endpoint',
          retryAfter: Math.ceil(limit.windowMs / 1000),
        });
      }

      next();
    } catch {
      next();
    }
  };
}

export function userRateLimit(redis: any, config: { max: number; windowMs: number }) {
  return slidingWindowRateLimit(redis, {
    ...config,
    keyGenerator: (req) => {
      const user = (req as any).user;
      return `user:${user?.userId ?? req.ip}`;
    },
  });
}

export function ipRateLimit(redis: any, config: { max: number; windowMs: number }) {
  return slidingWindowRateLimit(redis, {
    ...config,
    keyGenerator: (req) => `ip:${req.ip}`,
  });
}
