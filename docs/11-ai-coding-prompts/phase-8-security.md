# Phase 8: Security Prompts

## 8.1 Generate JWT Implementation

**Phase:** 8-Security
**Output:** `lib/core/auth/`
**Inputs:** Security requirements, JWT specs

```
Generate JWT implementation for Social Media AI.

## JWT Service

### Token Generation
```typescript
class JWTService {
  private privateKey: string;
  private publicKey: string;
  private accessExpiresIn: number = 15 * 60; // 15 minutes
  private refreshExpiresIn: number = 7 * 24 * 60 * 60; // 7 days
  
  async generateTokenPair(user: User): Promise<TokenPair> {
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);
    
    return {
      accessToken,
      refreshToken,
      expiresIn: this.accessExpiresIn,
      tokenType: 'Bearer'
    };
  }
  
  private generateAccessToken(user: User): string {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      workspaceId: user.workspaceId,
      type: 'access'
    };
    
    return jwt.sign(payload, this.privateKey, {
      algorithm: 'RS256',
      expiresIn: this.accessExpiresIn,
      issuer: 'socialmediaai',
      audience: 'api'
    });
  }
  
  private generateRefreshToken(user: User): string {
    const payload = {
      sub: user.id,
      type: 'refresh',
      jti: crypto.randomUUID()
    };
    
    return jwt.sign(payload, this.privateKey, {
      algorithm: 'RS256',
      expiresIn: this.refreshExpiresIn,
      issuer: 'socialmediaai'
    });
  }
}
```

### Token Validation
```typescript
async validateToken(token: string, type: 'access' | 'refresh'): Promise<TokenPayload> {
  try {
    const payload = jwt.verify(token, this.publicKey, {
      algorithms: ['RS256'],
      issuer: 'socialmediaai'
    }) as TokenPayload;
    
    if (payload.type !== type) {
      throw new InvalidTokenError('Invalid token type');
    }
    
    // Check if token is revoked
    if (await this.isRevoked(payload.jti)) {
      throw new InvalidTokenError('Token has been revoked');
    }
    
    return payload;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new TokenExpiredError('Token has expired');
    }
    throw new InvalidTokenError('Invalid token');
  }
}
```

### Token Revocation
```typescript
private async revokeToken(jti: string, expiresIn: number): Promise<void> {
  await this.redis.setex(`revoked:${jti}`, expiresIn, 'true');
}

private async isRevoked(jti: string): Promise<boolean> {
  return await this.redis.exists(`revoked:${jti}`);
}
```

### Token Refresh Flow
```typescript
async refreshTokens(refreshToken: string): Promise<TokenPair> {
  // Validate refresh token
  const payload = await this.validateToken(refreshToken, 'refresh');
  
  // Revoke old refresh token
  await this.revokeToken(payload.jti, this.refreshExpiresIn);
  
  // Get user
  const user = await this.userService.getById(payload.sub);
  
  // Generate new token pair
  return this.generateTokenPair(user);
}
```

## Auth Middleware

```typescript
async function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Missing or invalid authorization header'
    });
  }
  
  const token = authHeader.substring(7);
  
  try {
    const payload = await jwtService.validateToken(token, 'access');
    
    // Attach user to request
    req.user = {
      id: payload.sub,
      email: payload.email,
      role: payload.role,
      workspaceId: payload.workspaceId
    };
    
    next();
  } catch (error) {
    return res.status(401).json({
      error: 'Invalid or expired token'
    });
  }
}
```

## Key Management

```typescript
class KeyManager {
  async rotateKeys(): Promise<void> {
    // Generate new key pair
    const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
      modulusLength: 2048,
      publicKeyEncoding: { type: 'spki', format: 'pem' },
      privateKeyEncoding: { type: 'pkcs8', format: 'pem' }
    });
    
    // Store new keys
    await this.storeKeys(publicKey, privateKey);
    
    // Schedule old key deletion
    await this.scheduleKeyDeletion();
  }
}
```

Generate complete JWT implementation with key management and middleware.
```

**Expected Output:** Complete JWT system with token generation, validation, revocation, and middleware.

---

## 8.2 Generate RBAC System

**Phase:** 8-Security
**Output:** `lib/core/authorization/`
**Inputs:** Permission model, roles

```
Generate Role-Based Access Control (RBAC) system for Social Media AI.

## Role Definitions

```typescript
enum Role {
  OWNER = 'owner',
  ADMIN = 'admin',
  EDITOR = 'editor',
  VIEWER = 'viewer'
}

const roleHierarchy: Record<Role, number> = {
  [Role.OWNER]: 4,
  [Role.ADMIN]: 3,
  [Role.EDITOR]: 2,
  [Role.VIEWER]: 1
};
```

## Permission Definitions

```typescript
enum Permission {
  // Workspace
  WORKSPACE_READ = 'workspace:read',
  WORKSPACE_UPDATE = 'workspace:update',
  WORKSPACE_DELETE = 'workspace:delete',
  
  // Members
  MEMBER_READ = 'member:read',
  MEMBER_INVITE = 'member:invite',
  MEMBER_UPDATE = 'member:update',
  MEMBER_REMOVE = 'member:remove',
  
  // Posts
  POST_READ = 'post:read',
  POST_CREATE = 'post:create',
  POST_UPDATE = 'post:update',
  POST_DELETE = 'post:delete',
  POST_PUBLISH = 'post:publish',
  
  // Social Accounts
  SOCIAL_READ = 'social:read',
  SOCIAL_CONNECT = 'social:connect',
  SOCIAL_DISCONNECT = 'social:disconnect',
  
  // Analytics
  ANALYTICS_READ = 'analytics:read',
  ANALYTICS_EXPORT = 'analytics:export',
  
  // AI
  AI_USE = 'ai:use',
  AI_HISTORY = 'ai:history',
  
  // Billing
  BILLING_READ = 'billing:read',
  BILLING_UPDATE = 'billing:update'
}
```

## Role-Permission Mapping

```typescript
const rolePermissions: Record<Role, Permission[]> = {
  [Role.OWNER]: Object.values(Permission), // All permissions
  
  [Role.ADMIN]: [
    Permission.WORKSPACE_READ,
    Permission.WORKSPACE_UPDATE,
    Permission.MEMBER_READ,
    Permission.MEMBER_INVITE,
    Permission.MEMBER_UPDATE,
    Permission.MEMBER_REMOVE,
    Permission.POST_READ,
    Permission.POST_CREATE,
    Permission.POST_UPDATE,
    Permission.POST_DELETE,
    Permission.POST_PUBLISH,
    Permission.SOCIAL_READ,
    Permission.SOCIAL_CONNECT,
    Permission.SOCIAL_DISCONNECT,
    Permission.ANALYTICS_READ,
    Permission.ANALYTICS_EXPORT,
    Permission.AI_USE,
    Permission.AI_HISTORY
  ],
  
  [Role.EDITOR]: [
    Permission.WORKSPACE_READ,
    Permission.MEMBER_READ,
    Permission.POST_READ,
    Permission.POST_CREATE,
    Permission.POST_UPDATE,
    Permission.POST_DELETE,
    Permission.POST_PUBLISH,
    Permission.SOCIAL_READ,
    Permission.ANALYTICS_READ,
    Permission.AI_USE,
    Permission.AI_HISTORY
  ],
  
  [Role.VIEWER]: [
    Permission.WORKSPACE_READ,
    Permission.MEMBER_READ,
    Permission.POST_READ,
    Permission.SOCIAL_READ,
    Permission.ANALYTICS_READ
  ]
};
```

## Authorization Service

```typescript
class AuthorizationService {
  async checkPermission(
    userId: string,
    workspaceId: string,
    permission: Permission
  ): Promise<boolean> {
    // Get user's role in workspace
    const role = await this.getUserRole(userId, workspaceId);
    
    if (!role) {
      return false; // Not a member
    }
    
    // Check if role has permission
    const permissions = rolePermissions[role];
    return permissions.includes(permission);
  }
  
  async requirePermission(
    userId: string,
    workspaceId: string,
    permission: Permission
  ): Promise<void> {
    const hasPermission = await this.checkPermission(userId, workspaceId, permission);
    
    if (!hasPermission) {
      throw new ForbiddenError(
        `User ${userId} lacks permission ${permission} in workspace ${workspaceId}`
      );
    }
  }
  
  private async getUserRole(userId: string, workspaceId: string): Promise<Role | null> {
    const member = await this.db.workspace_members.findOne({
      user_id: userId,
      workspace_id: workspaceId
    });
    
    return member?.role || null;
  }
}
```

## Authorization Middleware

```typescript
function authorize(permission: Permission) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user.id;
    const workspaceId = req.params.workspaceId || req.user.workspaceId;
    
    try {
      await authorizationService.requirePermission(userId, workspaceId, permission);
      next();
    } catch (error) {
      return res.status(403).json({
        error: 'Insufficient permissions',
        required: permission
      });
    }
  };
}

// Usage
router.post('/posts', 
  authMiddleware, 
  authorize(Permission.POST_CREATE),
  postController.create
);
```

## Resource Ownership Check

```typescript
async function checkOwnership(
  userId: string,
  resourceType: string,
  resourceId: string
): Promise<boolean> {
  const resource = await db[resourceType].findOne({ id: resourceId });
  
  if (!resource) return false;
  
  // Check direct ownership
  if (resource.author_id === userId || resource.owner_id === userId) {
    return true;
  }
  
  // Check workspace membership with admin role
  const role = await getUserRole(userId, resource.workspace_id);
  return role === Role.OWNER || role === Role.ADMIN;
}
```

Generate complete RBAC system with permissions, roles, and middleware.
```

**Expected Output:** Complete RBAC system with roles, permissions, and authorization middleware.

---

## 8.3 Generate Rate Limiting

**Phase:** 8-Security
**Output:** Rate limiting middleware
**Inputs:** Rate limit requirements

```
Generate rate limiting system for Social Media AI.

## Rate Limiter Implementation

### Token Bucket Algorithm
```typescript
class TokenBucketRateLimiter {
  private redis: Redis;
  
  async isAllowed(
    key: string,
    limit: number,
    windowMs: number
  ): Promise<RateLimitResult> {
    const now = Date.now();
    const windowStart = now - windowMs;
    
    // Remove old entries
    await this.redis.zremrangebyscore(key, 0, windowStart);
    
    // Count current requests
    const count = await this.redis.zcard(key);
    
    if (count >= limit) {
      // Get oldest request to calculate retry-after
      const oldest = await this.redis.zrange(key, 0, 0, 'WITHSCORES');
      const retryAfter = oldest.length > 0 
        ? parseInt(oldest[1]) + windowMs - now
        : windowMs;
      
      return {
        allowed: false,
        remaining: 0,
        retryAfter: Math.ceil(retryAfter / 1000)
      };
    }
    
    // Add current request
    await this.redis.zadd(key, now, `${now}-${Math.random()}`);
    await this.redis.expire(key, Math.ceil(windowMs / 1000));
    
    return {
      allowed: true,
      remaining: limit - count - 1,
      retryAfter: 0
    };
  }
}
```

### Rate Limit Configuration
```typescript
const rateLimitConfig = {
  // Global limits
  global: {
    windowMs: 60 * 1000, // 1 minute
    limits: {
      free: 100,
      starter: 500,
      pro: 1000,
      business: 5000,
      enterprise: 10000
    }
  },
  
  // Endpoint-specific limits
  endpoints: {
    '/auth/login': { windowMs: 15 * 60 * 1000, limit: 5 },
    '/auth/register': { windowMs: 60 * 60 * 1000, limit: 3 },
    '/ai/generate': { windowMs: 60 * 1000, limit: 20 },
    '/posts': { windowMs: 60 * 1000, limit: 30 }
  },
  
  // AI-specific limits
  ai: {
    windowMs: 60 * 1000,
    limits: {
      free: 10,
      starter: 50,
      pro: 200,
      business: 1000,
      enterprise: 5000
    }
  }
};
```

### Rate Limit Middleware
```typescript
function rateLimit(options: RateLimitOptions) {
  const limiter = new TokenBucketRateLimiter();
  
  return async (req: Request, res: Response, next: NextFunction) => {
    const key = generateKey(req, options);
    const limit = getLimit(req, options);
    
    const result = await limiter.isAllowed(
      key,
      limit,
      options.windowMs
    );
    
    // Set rate limit headers
    res.setHeader('X-RateLimit-Limit', limit);
    res.setHeader('X-RateLimit-Remaining', result.remaining);
    res.setHeader('X-RateLimit-Reset', Math.ceil(Date.now() / 1000 + result.retryAfter));
    
    if (!result.allowed) {
      res.setHeader('Retry-After', result.retryAfter);
      
      return res.status(429).json({
        error: 'Too many requests',
        retryAfter: result.retryAfter
      });
    }
    
    next();
  };
}

function generateKey(req: Request, options: RateLimitOptions): string {
  const userId = req.user?.id || req.ip;
  const endpoint = options.keyGenerator?.(req) || req.path;
  
  return `ratelimit:${endpoint}:${userId}`;
}

function getLimit(req: Request, options: RateLimitOptions): number {
  const tier = req.user?.subscription?.tier || 'free';
  return options.limits?.[tier] || options.limit || 100;
}
```

### Usage Examples
```typescript
// Global rate limit
app.use(rateLimit(rateLimitConfig.global));

// AI endpoint rate limit
app.post('/ai/generate', 
  rateLimit(rateLimitConfig.ai),
  aiController.generate
);

// Login rate limit
app.post('/auth/login',
  rateLimit(rateLimitConfig.endpoints['/auth/login']),
  authController.login
);
```

### Sliding Window Counter
```typescript
class SlidingWindowRateLimiter {
  async isAllowed(
    key: string,
    limit: number,
    windowMs: number
  ): Promise<RateLimitResult> {
    const now = Date.now();
    const windowStart = now - windowMs;
    
    // Get count from previous window
    const prevWindowKey = `${key}:${Math.floor(windowStart / windowMs)}`;
    const prevCount = await this.redis.get(prevWindowKey) || 0;
    
    // Get count from current window
    const currWindowKey = `${key}:${Math.floor(now / windowMs)}`;
    const currCount = await this.redis.incr(currWindowKey);
    await this.redis.pexpire(currWindowKey, windowMs * 2);
    
    // Calculate weighted count
    const weight = (now % windowMs) / windowMs;
    const weightedCount = parseInt(prevCount) * (1 - weight) + currCount;
    
    if (weightedCount > limit) {
      return { allowed: false, remaining: 0, retryAfter: windowMs / 1000 };
    }
    
    return {
      allowed: true,
      remaining: Math.floor(limit - weightedCount),
      retryAfter: 0
    };
  }
}
```

Generate complete rate limiting system with multiple algorithms.
```

**Expected Output:** Complete rate limiting system with token bucket and sliding window algorithms.

---

## 8.4 Generate Security Headers

**Phase:** 8-Security
**Output:** Security middleware
**Inputs:** OWASP guidelines

```
Generate security headers middleware for Social Media AI.

## Security Headers

### Complete Headers Configuration
```typescript
const securityHeaders = {
  // Strict Transport Security
  'Strict-Transport-Security': {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  
  // Content Type Options
  'X-Content-Type-Options': 'nosniff',
  
  // Frame Options
  'X-Frame-Options': 'DENY',
  
  // XSS Protection
  'X-XSS-Protection': '1; mode=block',
  
  // Content Security Policy
  'Content-Security-Policy': {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:', 'https:'],
    fontSrc: ["'self'"],
    connectSrc: ["'self'", 'https://api.supabase.co'],
    frameSrc: ["'none'"],
    objectSrc: ["'none'"],
    baseUri: ["'self'"],
    formAction: ["'self'"],
    frameAncestors: ["'none'"],
    upgradeInsecureRequests: []
  },
  
  // Referrer Policy
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  
  // Permissions Policy
  'Permissions-Policy': {
    camera: [],
    microphone: [],
    geolocation: [],
    payment: [],
    usb: [],
    magnetometer: [],
    gyroscope: [],
    accelerometer: []
  },
  
  // Cross-Origin Policies
  'Cross-Origin-Opener-Policy': 'same-origin',
  'Cross-Origin-Resource-Policy': 'same-origin',
  'Cross-Origin-Embedder-Policy': 'require-corp',
  
  // Cache Control for sensitive endpoints
  'Cache-Control': 'no-store, no-cache, must-revalidate, private',
  'Pragma': 'no-cache',
  'Expires': '0'
};
```

### Middleware Implementation
```typescript
function securityMiddleware(req: Request, res: Response, next: NextFunction) {
  // Apply security headers
  Object.entries(securityHeaders).forEach(([key, value]) => {
    if (typeof value === 'object' && !Array.isArray(value)) {
      // Handle CSP and Permissions-Policy
      res.setHeader(key, formatPolicy(value));
    } else {
      res.setHeader(key, value);
    }
  });
  
  // Remove potentially dangerous headers
  res.removeHeader('X-Powered-By');
  res.removeHeader('Server');
  
  next();
}

function formatPolicy(policy: Record<string, any>): string {
  return Object.entries(policy)
    .map(([key, value]) => {
      if (Array.isArray(value) && value.length === 0) {
        return key;
      }
      return `${key} ${Array.isArray(value) ? value.join(' ') : value}`;
    })
    .join('; ');
}
```

### CORS Configuration
```typescript
const corsConfig = {
  origin: (origin: string, callback: Function) => {
    const allowedOrigins = [
      'https://socialmediaai.com',
      'https://app.socialmediaai.com',
      'http://localhost:3000'
    ];
    
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-API-Key'
  ],
  exposedHeaders: [
    'X-RateLimit-Limit',
    'X-RateLimit-Remaining',
    'X-RateLimit-Reset'
  ],
  maxAge: 86400
};
```

### Request Validation
```typescript
function requestValidation(req: Request, res: Response, next: NextFunction) {
  // Check Content-Type for POST/PUT/PATCH
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    const contentType = req.headers['content-type'];
    if (!contentType || !contentType.includes('application/json')) {
      return res.status(415).json({
        error: 'Unsupported Media Type',
        message: 'Content-Type must be application/json'
      });
    }
  }
  
  // Check for suspicious patterns
  const suspiciousPatterns = [
    /(<script[^>]*>)/i,
    /(javascript:)/i,
    /(on\w+\s*=)/i,
    /(union\s+select)/i,
    /(drop\s+table)/i
  ];
  
  const requestBody = JSON.stringify(req.body);
  for (const pattern of suspiciousPatterns) {
    if (pattern.test(requestBody)) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Request contains suspicious content'
      });
    }
  }
  
  next();
}
```

Generate complete security headers middleware with CORS and validation.
```

**Expected Output:** Complete security headers system with CSP, CORS, and request validation.

---

## 8.5 Generate Audit Logging

**Phase:** 8-Security
**Output:** Audit logging service
**Inputs:** Compliance requirements

```
Generate audit logging system for Social Media AI.

## Audit Logger

### Event Types
```typescript
enum AuditEvent {
  // Auth events
  USER_LOGIN = 'user.login',
  USER_LOGOUT = 'user.logout',
  USER_REGISTER = 'user.register',
  PASSWORD_CHANGE = 'password.change',
  PASSWORD_RESET = 'password.reset',
  MFA_ENABLE = 'mfa.enable',
  MFA_DISABLE = 'mfa.disable',
  
  // Resource events
  RESOURCE_CREATE = 'resource.create',
  RESOURCE_READ = 'resource.read',
  RESOURCE_UPDATE = 'resource.update',
  RESOURCE_DELETE = 'resource.delete',
  
  // Workspace events
  WORKSPACE_CREATE = 'workspace.create',
  WORKSPACE_UPDATE = 'workspace.update',
  MEMBER_INVITE = 'member.invite',
  MEMBER_REMOVE = 'member.remove',
  ROLE_CHANGE = 'role.change',
  
  // Social account events
  SOCIAL_CONNECT = 'social.connect',
  SOCIAL_DISCONNECT = 'social.disconnect',
  POST_PUBLISH = 'post.publish',
  POST_DELETE = 'post.delete',
  
  // AI events
  AI_GENERATE = 'ai.generate',
  
  // Billing events
  SUBSCRIPTION_CHANGE = 'subscription.change',
  PAYMENT_SUCCESS = 'payment.success',
  PAYMENT_FAILURE = 'payment.failure',
  
  // Security events
  RATE_LIMIT_HIT = 'security.rate_limit',
  UNAUTHORIZED_ACCESS = 'security.unauthorized',
  SUSPICIOUS_ACTIVITY = 'security.suspicious'
}
```

### Audit Log Entry
```typescript
interface AuditLogEntry {
  id: string;
  timestamp: Date;
  event: AuditEvent;
  userId: string;
  workspaceId?: string;
  resourceType?: string;
  resourceId?: string;
  action: string;
  details?: Record<string, any>;
  ipAddress: string;
  userAgent: string;
  sessionId?: string;
  success: boolean;
  errorMessage?: string;
}
```

### Audit Service
```typescript
class AuditService {
  async log(entry: Omit<AuditLogEntry, 'id' | 'timestamp'>): Promise<void> {
    const logEntry: AuditLogEntry = {
      id: crypto.randomUUID(),
      timestamp: new Date(),
      ...entry
    };
    
    // Store in database
    await this.db.audit_logs.create(logEntry);
    
    // Send to analytics pipeline
    await this.analytics.track('audit_event', logEntry);
    
    // Alert on critical events
    if (this.isCriticalEvent(entry.event)) {
      await this.alertCritical(logEntry);
    }
  }
  
  async query(filters: AuditQueryFilters): Promise<AuditLogEntry[]> {
    return this.db.audit_logs.findMany({
      where: {
        userId: filters.userId,
        workspaceId: filters.workspaceId,
        event: filters.event,
        timestamp: {
          gte: filters.startDate,
          lte: filters.endDate
        }
      },
      orderBy: { timestamp: 'desc' },
      take: filters.limit || 100
    });
  }
  
  private isCriticalEvent(event: AuditEvent): boolean {
    const criticalEvents = [
      AuditEvent.UNAUTHORIZED_ACCESS,
      AuditEvent.SUSPICIOUS_ACTIVITY,
      AuditEvent.PASSWORD_RESET,
      AuditEvent.MFA_DISABLE,
      AuditEvent.ROLE_CHANGE
    ];
    return criticalEvents.includes(event);
  }
}
```

### Audit Middleware
```typescript
function auditMiddleware(event: AuditEvent) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const startTime = Date.now();
    
    // Capture original response method
    const originalJson = res.json;
    let responseStatus: number;
    
    res.json = function(body: any) {
      responseStatus = res.statusCode;
      return originalJson.call(this, body);
    };
    
    // Continue with request
    next();
    
    // Log after response
    res.on('finish', async () => {
      const duration = Date.now() - startTime;
      
      await auditService.log({
        event,
        userId: req.user?.id || 'anonymous',
        workspaceId: req.params.workspaceId,
        resourceType: req.baseUrl.split('/')[1],
        resourceId: req.params.id,
        action: req.method,
        details: {
          method: req.method,
          path: req.path,
          statusCode: responseStatus,
          duration,
          query: req.query,
          body: sanitizeBody(req.body)
        },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'] || '',
        success: responseStatus < 400
      });
    });
  };
}

function sanitizeBody(body: any): any {
  const sensitiveFields = ['password', 'token', 'secret', 'apiKey'];
  const sanitized = { ...body };
  
  for (const field of sensitiveFields) {
    if (sanitized[field]) {
      sanitized[field] = '[REDACTED]';
    }
  }
  
  return sanitized;
}
```

### Usage Examples
```typescript
// Apply to routes
router.post('/login', 
  auditMiddleware(AuditEvent.USER_LOGIN),
  authController.login
);

router.post('/posts',
  auditMiddleware(AuditEvent.RESOURCE_CREATE),
  postController.create
);

router.delete('/posts/:id',
  auditMiddleware(AuditEvent.RESOURCE_DELETE),
  postController.delete
);
```

Generate complete audit logging system with middleware and query capabilities.
```

**Expected Output:** Complete audit logging system with event tracking and compliance features.

---

## 8.6 Generate GDPR Compliance

**Phase:** 8-Security
**Output:** GDPR compliance module
**Inputs:** GDPR requirements

```
Generate GDPR compliance module for Social Media AI.

## Data Subject Rights

### Right to Access (Article 15)
```typescript
class DataAccessService {
  async exportUserData(userId: string): Promise<UserDataExport> {
    const user = await this.db.users.findOne({ id: userId });
    const workspaces = await this.db.workspace_members.findMany({ user_id: userId });
    const posts = await this.db.posts.findMany({ author_id: userId });
    const media = await this.db.media.findMany({ uploaded_by: userId });
    
    return {
      personalData: {
        profile: {
          email: user.email,
          fullName: user.fullName,
          avatarUrl: user.avatarUrl,
          timezone: user.timezone,
          language: user.language,
          createdAt: user.createdAt
        },
        preferences: user.preferences
      },
      contentData: {
        posts: posts.map(p => ({
          id: p.id,
          content: p.content,
          createdAt: p.createdAt
        })),
        media: media.map(m => ({
          id: m.id,
          fileName: m.fileName,
          createdAt: m.createdAt
        }))
      },
      usageData: {
        workspaces: workspaces.map(w => ({
          workspaceId: w.workspaceId,
          role: w.role,
          joinedAt: w.joinedAt
        })),
        loginHistory: await this.getLoginHistory(userId)
      },
      exportedAt: new Date().toISOString()
    };
  }
}
```

### Right to Erasure (Article 17)
```typescript
class DataErasureService {
  async deleteUserData(userId: string, confirmationToken: string): Promise<void> {
    // Verify confirmation token
    await this.verifyDeletionToken(userId, confirmationToken);
    
    // Soft delete user
    await this.db.users.update({
      id: userId,
      deletedAt: new Date()
    });
    
    // Anonymize content
    await this.db.posts.updateMany({
      authorId: userId,
      data: { authorId: null, content: '[DELETED]' }
    });
    
    // Remove media
    const media = await this.db.media.findMany({ uploadedBy: userId });
    for (const m of media) {
      await this.storage.delete(m.storagePath);
    }
    
    // Remove from workspaces
    await this.db.workspace_members.deleteMany({ userId });
    
    // Schedule permanent deletion (30 days)
    await this.schedulePermanentDeletion(userId);
    
    // Log deletion
    await this.auditService.log({
      event: AuditEvent.USER_DATA_DELETED,
      userId,
      action: 'DELETE'
    });
  }
  
  private async schedulePermanentDeletion(userId: string): Promise<void> {
    await this.queue.add('permanent-deletion', { userId }, {
      delay: 30 * 24 * 60 * 60 * 1000 // 30 days
    });
  }
}
```

### Right to Rectification (Article 16)
```typescript
class DataRectificationService {
  async updateUserData(
    userId: string,
    updates: Partial<UserProfile>
  ): Promise<void> {
    await this.db.users.update({
      id: userId,
      ...updates
    });
    
    // Log update
    await this.auditService.log({
      event: AuditEvent.USER_DATA_UPDATED,
      userId,
      action: 'UPDATE',
      details: { fields: Object.keys(updates) }
    });
  }
}
```

### Right to Data Portability (Article 20)
```typescript
class DataPortabilityService {
  async exportPortableData(userId: string): Promise<PortableDataExport> {
    const data = await this.dataAccessService.exportUserData(userId);
    
    return {
      format: 'JSON',
      schema: 'socialmediaai-portable-v1',
      data: {
        profile: data.personalData,
        content: data.contentData,
        metadata: {
          exportedAt: new Date().toISOString(),
          version: '1.0'
        }
      }
    };
  }
}
```

## Consent Management

### Consent Service
```typescript
class ConsentService {
  async recordConsent(
    userId: string,
    consentType: ConsentType,
    granted: boolean
  ): Promise<void> {
    await this.db.user_consents.upsert({
      userId,
      consentType,
      granted,
      grantedAt: granted ? new Date() : null,
      revokedAt: !granted ? new Date() : null,
      ipAddress: await this.getClientIp(),
      version: this.getConsentVersion()
    });
  }
  
  async getConsentStatus(userId: string): Promise<ConsentStatus> {
    const consents = await this.db.user_consents.findMany({
      where: { userId }
    });
    
    return {
      analytics: consents.find(c => c.consentType === 'analytics')?.granted || false,
      marketing: consents.find(c => c.consentType === 'marketing')?.granted || false,
      thirdParty: consents.find(c => c.consentType === 'third_party')?.granted || false
    };
  }
  
  async revokeAllConsent(userId: string): Promise<void> {
    await this.db.user_consents.updateMany({
      userId,
      granted: false,
      revokedAt: new Date()
    });
  }
}
```

### Consent Types
```typescript
enum ConsentType {
  ANALYTICS = 'analytics',
  MARKETING = 'marketing',
  THIRD_PARTY = 'third_party',
  AI_TRAINING = 'ai_training'
}
```

## Data Processing Agreement

```typescript
interface DPA {
  version: string;
  effectiveDate: Date;
  processor: {
    name: string;
    address: string;
    contact: string;
  };
  dataCategories: string[];
  processingPurposes: string[];
  dataRetention: Record<string, string>;
  securityMeasures: string[];
  subProcessors: string[];
}
```

## Privacy by Design

### Data Minimization
```typescript
function minimizeData<T>(data: T, fields: (keyof T)[]): Partial<T> {
  const minimized: any = {};
  for (const field of fields) {
    if (data[field] !== undefined) {
      minimized[field] = data[field];
    }
  }
  return minimized;
}
```

### Purpose Limitation
```typescript
enum DataPurpose {
  ACCOUNT_MANAGEMENT = 'account_management',
  SERVICE_DELIVERY = 'service_delivery',
  ANALYTICS = 'analytics',
  MARKETING = 'marketing',
  LEGAL_COMPLIANCE = 'legal_compliance'
}

function checkPurpose(data: any, purpose: DataPurpose): boolean {
  return data.allowedPurposes?.includes(purpose) || false;
}
```

## Cookie Consent

```typescript
class CookieConsent {
  async setConsentPreferences(
    userId: string,
    preferences: CookiePreferences
  ): Promise<void> {
    await this.db.cookie_preferences.upsert({
      userId,
      necessary: true, // Always true
      analytics: preferences.analytics,
      marketing: preferences.marketing,
      updatedAt: new Date()
    });
  }
  
  async getConsentPreferences(userId: string): Promise<CookiePreferences> {
    const prefs = await this.db.cookie_preferences.findOne({ userId });
    return prefs || this.getDefaultPreferences();
  }
}
```

Generate complete GDPR compliance module with all data subject rights.
```

**Expected Output:** Complete GDPR compliance module with data rights, consent management, and privacy features.
