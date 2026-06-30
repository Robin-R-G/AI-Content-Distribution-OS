# API Gateway Design

## Overview

The API Gateway serves as the single entry point for all client requests, handling routing, authentication, rate limiting, and request transformation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        API GATEWAY                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Request Pipeline                      │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │   TLS    │→ │  CORS    │→ │  Rate    │→ │   Auth  ││   │
│  │  │Terminal  │  │  Handler │  │ Limiter  │  │Middleware││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │ Request  │→ │ Routing  │→ │  Service │→ │ Response││   │
│  │  │Transform │  │  Engine  │  │  Proxy   │  │Transform││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Route Registry                        │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │ /api/v1/auth/*      → auth-service              │    │   │
│  │  │ /api/v1/orgs/*      → organization-service      │    │   │
│  │  │ /api/v1/workspaces/*→ workspace-service         │    │   │
│  │  │ /api/v1/contents/*  → content-service           │    │   │
│  │  │ /api/v1/publish/*   → publishing-service        │    │   │
│  │  │ /api/v1/ai/*        → ai-service                │    │   │
│  │  │ /api/v1/analytics/* → analytics-service         │    │   │
│  │  │ /api/v1/billing/*   → billing-service           │    │   │
│  │  │ /api/v1/plugins/*   → plugin-service            │    │   │
│  │  │ /api/admin/*        → admin-service             │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Request Routing

### Route Definition

```typescript
interface Route {
  path: string;
  method: HttpMethod;
  service: string;
  auth: AuthRequirement;
  rateLimit: RateLimitConfig;
  transform?: TransformConfig;
  cache?: CacheConfig;
  timeout: number;
}

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';

interface AuthRequirement {
  required: boolean;
  roles?: string[];
  scopes?: string[];
}

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  keyGenerator: 'user' | 'org' | 'ip' | 'endpoint';
}

interface TransformConfig {
  request?: RequestTransform;
  response?: ResponseTransform;
}

interface CacheConfig {
  ttl: number;
  key: string;
  invalidateOn?: string[];
}
```

### Route Configuration

```typescript
const routes: Route[] = [
  {
    path: '/api/v1/auth/login',
    method: 'POST',
    service: 'auth',
    auth: { required: false },
    rateLimit: {
      windowMs: 15 * 60 * 1000,
      maxRequests: 5,
      keyGenerator: 'ip'
    },
    timeout: 10000
  },
  {
    path: '/api/v1/contents',
    method: 'GET',
    service: 'content',
    auth: { required: true },
    rateLimit: {
      windowMs: 60 * 1000,
      maxRequests: 100,
      keyGenerator: 'user'
    },
    cache: {
      ttl: 60,
      key: 'contents:list:${userId}:${workspaceId}'
    },
    timeout: 30000
  },
  {
    path: '/api/v1/ai/generate',
    method: 'POST',
    service: 'ai',
    auth: { required: true },
    rateLimit: {
      windowMs: 60 * 1000,
      maxRequests: 10,
      keyGenerator: 'user'
    },
    timeout: 60000
  }
];
```

## Rate Limiting

### Implementation

```typescript
interface RateLimiter {
  algorithm: 'token-bucket' | 'sliding-window' | 'fixed-window';
  storage: 'redis' | 'memory';
  limits: RateLimit[];
}

interface RateLimit {
  scope: 'global' | 'user' | 'org' | 'endpoint' | 'ip';
  windowMs: number;
  maxRequests: number;
  burst?: number;
}

class RedisRateLimiter implements RateLimiter {
  algorithm = 'sliding-window';
  storage = 'redis';

  async checkLimit(key: string, limit: RateLimit): Promise<RateLimitResult> {
    const now = Date.now();
    const windowStart = now - limit.windowMs;

    const pipeline = redis.pipeline();
    pipeline.zremrangebyscore(key, 0, windowStart);
    pipeline.zadd(key, now, `${now}`);
    pipeline.zcard(key);
    pipeline.expire(key, Math.ceil(limit.windowMs / 1000));

    const results = await pipeline.exec();
    const requestCount = results[2][1] as number;

    return {
      allowed: requestCount <= limit.maxRequests,
      remaining: Math.max(0, limit.maxRequests - requestCount),
      resetAt: windowStart + limit.windowMs,
      retryAfter: requestCount > limit.maxRequests
        ? Math.ceil((windowStart + limit.windowMs - now) / 1000)
        : 0
    };
  }
}
```

### Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
Retry-After: 30  (only when rate limited)
```

### Per-Scope Limits

| Scope | Window | Limit | Burst |
|-------|--------|-------|-------|
| Global | 1 min | 1000 | 50 |
| User (free) | 1 min | 60 | 10 |
| User (pro) | 1 min | 300 | 50 |
| User (enterprise) | 1 min | 1000 | 100 |
| Org | 1 min | 500 | 50 |
| AI generate | 1 min | 10 | 5 |
| Auth (login) | 15 min | 5 | 1 |
| Upload | 1 min | 20 | 10 |

## Authentication Middleware

### JWT Validation

```typescript
interface AuthMiddleware {
  validateToken(token: string): Promise<TokenPayload>;
  extractToken(request: Request): string | null;
  refreshToken(refreshToken: string): Promise<TokenPair>;
}

interface TokenPayload {
  sub: string;          // User ID
  org_id: string;       // Organization ID
  workspace_id?: string;
  role: string;
  scopes: string[];
  exp: number;
  iat: number;
}

class SupabaseAuthMiddleware implements AuthMiddleware {
  async validateToken(token: string): Promise<TokenPayload> {
    const { data, error } = await supabase.auth.getUser(token);

    if (error) throw new UnauthorizedError('Invalid token');

    return {
      sub: data.user.id,
      org_id: data.user.user_metadata.org_id,
      role: data.user.user_metadata.role,
      scopes: data.user.app_metadata.scopes || [],
      exp: data.user.aud === 'authenticated' ? Date.now() / 1000 + 3600 : 0,
      iat: Date.now() / 1000
    };
  }

  extractToken(request: Request): string | null {
    const authHeader = request.headers.get('Authorization');
    if (authHeader?.startsWith('Bearer ')) {
      return authHeader.slice(7);
    }
    return null;
  }
}
```

### Authorization

```typescript
interface AuthorizationConfig {
  roles: string[];
  scopes: string[];
  ownership?: boolean;
}

function authorize(config: AuthorizationConfig) {
  return async (request: Request, payload: TokenPayload): Promise<boolean> => {
    // Check role
    if (config.roles.length > 0 && !config.roles.includes(payload.role)) {
      return false;
    }

    // Check scopes
    if (config.scopes.length > 0) {
      const hasScope = config.scopes.some(scope =>
        payload.scopes.includes(scope)
      );
      if (!hasScope) return false;
    }

    // Check ownership
    if (config.ownership) {
      const resourceId = extractResourceId(request);
      const isOwner = await checkOwnership(payload.sub, resourceId);
      if (!isOwner) return false;
    }

    return true;
  };
}
```

## Request/Response Transformation

### Request Transformation

```typescript
interface RequestTransform {
  headers?: Record<string, string>;
  body?: (body: any) => any;
  query?: (query: Record<string, string>) => Record<string, string>;
  path?: (path: string) => string;
}

const transforms: Record<string, RequestTransform> = {
  '/api/v1/contents': {
    headers: {
      'X-Request-Id': generateRequestId(),
      'X-Forwarded-For': getClientIp()
    },
    body: (body) => ({
      ...body,
      workspace_id: body.workspace_id || getDefaultWorkspace()
    }),
    query: (query) => ({
      ...query,
      page: query.page || '1',
      limit: Math.min(parseInt(query.limit || '20'), 100).toString()
    })
  }
};
```

### Response Transformation

```typescript
interface ResponseTransform {
  headers?: Record<string, string>;
  body?: (body: any) => any;
  pagination?: boolean;
}

const responseTransforms: Record<string, ResponseTransform> = {
  default: {
    body: (body) => ({
      success: true,
      data: body,
      timestamp: new Date().toISOString()
    })
  },
  error: {
    body: (error) => ({
      success: false,
      error: {
        code: error.code,
        message: error.message,
        details: error.details
      },
      timestamp: new Date().toISOString()
    })
  }
};
```

## API Versioning

### Version Strategy

```typescript
interface ApiVersion {
  version: string;
  status: 'current' | 'deprecated' | 'sunset';
  deprecatedAt?: string;
  sunsetAt?: string;
}

const versions: ApiVersion[] = [
  { version: 'v1', status: 'current' },
  { version: 'v2', status: 'deprecated', deprecatedAt: '2026-06-01', sunsetAt: '2026-12-01' }
];
```

### Version Detection

```typescript
function detectVersion(request: Request): string {
  // 1. Check URL path
  const pathMatch = request.url.match(/\/api\/(v\d+)\//);
  if (pathMatch) return pathMatch[1];

  // 2. Check Accept header
  const accept = request.headers.get('Accept');
  const acceptMatch = accept?.match(/application\/vnd\.api\.(v\d+)\+json/);
  if (acceptMatch) return acceptMatch[1];

  // 3. Check X-API-Version header
  const headerVersion = request.headers.get('X-API-Version');
  if (headerVersion) return headerVersion;

  // 4. Default
  return 'v1';
}
```

## OpenAPI Spec Generation

### Auto-Generation

```typescript
import { generateOpenApi } from '@asteasolutions/zod-to-openapi';

const openApiSpec = {
  openapi: '3.0.3',
  info: {
    title: 'AI Content Distribution OS API',
    version: '1.0.0',
    description: 'API for AI-powered content distribution platform'
  },
  servers: [
    { url: 'https://api.contentos.ai', description: 'Production' },
    { url: 'https://staging-api.contentos.ai', description: 'Staging' }
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT'
      }
    }
  },
  security: [{ bearerAuth: [] }]
};
```

### Endpoint Documentation

```typescript
// Each route auto-generates OpenAPI documentation
const contentEndpoints = {
  '/api/v1/contents': {
    post: {
      summary: 'Create content',
      tags: ['Content'],
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: ContentCreateSchema
          }
        }
      },
      responses: {
        201: { description: 'Content created' },
        400: { description: 'Validation error' },
        401: { description: 'Unauthorized' }
      }
    }
  }
};
```

## Error Handling

### Error Response Format

```typescript
interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
    requestId: string;
  };
  timestamp: string;
}

// Error codes
enum ErrorCode {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  RATE_LIMITED = 'RATE_LIMITED',
  SERVICE_UNAVAILABLE = 'SERVICE_UNAVAILABLE',
  INTERNAL_ERROR = 'INTERNAL_ERROR'
}
```

### Error Mapping

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Authentication required |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict |
| 422 | UNPROCESSABLE | Semantic validation error |
| 429 | RATE_LIMITED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | Service temporarily unavailable |
