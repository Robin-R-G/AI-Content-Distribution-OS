import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface JWTPayload {
  userId: string;
  orgId: string;
  role: string;
  iat: number;
  exp: number;
}

export function authMiddleware(secret: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const token = extractToken(req);
    if (!token) return res.status(401).json({ error: 'Authentication required' });

    try {
      const payload = jwt.verify(token, secret) as JWTPayload;
      (req as any).user = {
        userId: payload.userId,
        orgId: payload.orgId,
        role: payload.role,
      };
      next();
    } catch (error: any) {
      if (error.name === 'TokenExpiredError') return res.status(401).json({ error: 'Token expired' });
      return res.status(401).json({ error: 'Invalid token' });
    }
  };
}

export function sessionMiddleware(sessionStore: any) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const sessionId = req.cookies?.sid || req.headers['x-session-id'];
    if (!sessionId) return next();

    try {
      const session = await sessionStore.get(sessionId);
      if (session) {
        (req as any).session = session;
        (req as any).user = { userId: session.userId, orgId: session.orgId, role: session.role };
      }
    } catch { /* session expired or invalid */ }

    next();
  };
}

export function apiKeyMiddleware(db: any) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const apiKey = req.headers['x-api-key'] as string;
    if (!apiKey) return next();

    try {
      const key = await db.apiKey.findFirst({
        where: { key: apiKey, active: true, expiresAt: { gt: new Date() } },
      });

      if (!key) return res.status(401).json({ error: 'Invalid API key' });

      await db.apiKey.update({ where: { id: key.id }, data: { lastUsedAt: new Date() } });

      (req as any).user = { userId: key.userId, orgId: key.orgId, role: 'api_key' };
      next();
    } catch {
      return res.status(401).json({ error: 'Invalid API key' });
    }
  };
}

export function rateLimitMiddleware(redis: any, options: { windowMs: number; max: number; keyGenerator?: (req: Request) => string }) {
  const { windowMs, max, keyGenerator } = options;

  return async (req: Request, res: Response, next: NextFunction) => {
    const key = keyGenerator ? keyGenerator(req) : `${req.ip}:${req.path}`;
    const windowKey = `ratelimit:${key}:${Math.floor(Date.now() / windowMs)}`;

    try {
      const current = await redis.incr(windowKey);
      if (current === 1) {
        await redis.pexpire(windowKey, windowMs);
      }

      const ttl = await redis.pttl(windowKey);
      res.setHeader('X-RateLimit-Limit', max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, max - current));
      res.setHeader('X-RateLimit-Reset', Math.ceil((Date.now() + ttl) / 1000));

      if (current > max) {
        return res.status(429).json({
          error: 'Too many requests',
          retryAfter: Math.ceil(ttl / 1000),
        });
      }

      next();
    } catch {
      next();
    }
  };
}

function extractToken(req: Request): string | null {
  const authHeader = req.headers.authorization;
  if (authHeader?.startsWith('Bearer ')) return authHeader.slice(7);
  if (req.query?.token) return req.query.token as string;
  return null;
}

export function generateToken(payload: { userId: string; orgId: string; role: string }, secret: string, expiresIn: string = '7d'): string {
  return jwt.sign(payload, secret, { expiresIn } as any);
}
