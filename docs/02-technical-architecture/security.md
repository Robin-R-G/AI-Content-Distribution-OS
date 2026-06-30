# Security Architecture

## Authentication Flow (Supabase Auth + JWT)

### Token Structure

```typescript
interface JWTPayload {
  sub: string;           // User ID
  email: string;
  org_id: string;
  role: 'owner' | 'admin' | 'member' | 'viewer';
  scopes: string[];
  aud: 'authenticated';
  exp: number;
  iat: number;
  iss: string;
  session_id: string;
}
```

### Token Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│  Supabase│────►│ Database │               │
│  │  (App)   │     │   Auth   │     │ (Users)  │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │  1. Login      │                │                       │
│       │  (email/pass)  │                │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 2. Validate    │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 3. User data   │                       │
│       │                │◄───────────────│                       │
│       │                │                │                       │
│       │  4. JWT Token  │                │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │  5. API Call   │                │                       │
│       │  + JWT Header  │                │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 6. Validate JWT│                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │  7. Response   │                │                       │
│       │◄───────────────│                │                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### JWT Validation

```typescript
// lib/auth/jwt-validator.ts
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: `${process.env.SUPABASE_URL}/auth/v1/.well-known/jwks.json`,
  cache: true,
  cacheMaxAge: 600000, // 10 minutes
  rateLimit: true,
  jwksRequestsPerMinute: 10
});

async function getSigningKey(header: jwt.JwtHeader): Promise<string> {
  return new Promise((resolve, reject) => {
    client.getSigningKey(header.kid, (err, key) => {
      if (err) return reject(err);
      resolve(key!.getPublicKey());
    });
  });
}

export async function validateToken(token: string): Promise<JWTPayload> {
  const decoded = jwt.decode(token, { complete: true });
  if (!decoded) throw new InvalidTokenError('Invalid token format');

  const signingKey = await getSigningKey(decoded.header);

  return new Promise((resolve, reject) => {
    jwt.verify(token, signingKey, {
      algorithms: ['RS256'],
      issuer: `${process.env.SUPABASE_URL}/auth/v1`,
      audience: 'authenticated'
    }, (err, payload) => {
      if (err) return reject(new InvalidTokenError(err.message));
      resolve(payload as JWTPayload);
    });
  });
}
```

## Authorization (RBAC + RLS)

### Role Definitions

```typescript
interface RoleDefinition {
  name: string;
  permissions: Permission[];
  inherits?: string[];
}

type Permission = 
  | 'org:create' | 'org:read' | 'org:update' | 'org:delete'
  | 'workspace:create' | 'workspace:read' | 'workspace:update' | 'workspace:delete'
  | 'content:create' | 'content:read' | 'content:update' | 'content:delete' | 'content:publish'
  | 'channel:create' | 'channel:read' | 'channel:update' | 'channel:delete'
  | 'analytics:read' | 'analytics:export'
  | 'billing:read' | 'billing:update'
  | 'member:invite' | 'member:remove' | 'member:update-role'
  | 'admin:access';

const roles: Record<string, RoleDefinition> = {
  owner: {
    name: 'Owner',
    permissions: [
      'org:create', 'org:read', 'org:update', 'org:delete',
      'workspace:create', 'workspace:read', 'workspace:update', 'workspace:delete',
      'content:create', 'content:read', 'content:update', 'content:delete', 'content:publish',
      'channel:create', 'channel:read', 'channel:update', 'channel:delete',
      'analytics:read', 'analytics:export',
      'billing:read', 'billing:update',
      'member:invite', 'member:remove', 'member:update-role',
      'admin:access'
    ]
  },
  admin: {
    name: 'Admin',
    inherits: ['member'],
    permissions: [
      'member:invite', 'member:remove', 'member:update-role',
      'billing:read',
      'admin:access'
    ]
  },
  member: {
    name: 'Member',
    permissions: [
      'workspace:create', 'workspace:read', 'workspace:update',
      'content:create', 'content:read', 'content:update', 'content:delete', 'content:publish',
      'channel:create', 'channel:read', 'channel:update', 'channel:delete',
      'analytics:read'
    ]
  },
  viewer: {
    name: 'Viewer',
    permissions: [
      'workspace:read',
      'content:read',
      'channel:read',
      'analytics:read'
    ]
  }
};
```

### RLS Policies

```sql
-- Organization access
CREATE POLICY "org_select_members"
  ON public.organizations FOR SELECT
  USING (
    id IN (
      SELECT organization_id
      FROM public.organization_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "org_insert_owner"
  ON public.organizations FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "org_update_owner"
  ON public.organizations FOR UPDATE
  USING (owner_id = auth.uid());

CREATE POLICY "org_delete_owner"
  ON public.organizations FOR DELETE
  USING (owner_id = auth.uid());

-- Workspace access
CREATE POLICY "workspace_select_org_members"
  ON public.workspaces FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id
      FROM public.organization_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "workspace_insert_members"
  ON public.workspaces FOR INSERT
  WITH CHECK (
    organization_id IN (
      SELECT organization_id
      FROM public.organization_members
      WHERE user_id = auth.uid()
      AND role IN ('owner', 'admin')
    )
  );

-- Content access
CREATE POLICY "content_select_workspace_members"
  ON public.contents FOR SELECT
  USING (
    workspace_id IN (
      SELECT w.id
      FROM public.workspaces w
      JOIN public.organization_members om
        ON w.organization_id = om.organization_id
      WHERE om.user_id = auth.uid()
    )
  );

CREATE POLICY "content_insert_members"
  ON public.contents FOR INSERT
  WITH CHECK (
    workspace_id IN (
      SELECT w.id
      FROM public.workspaces w
      JOIN public.organization_members om
        ON w.organization_id = om.organization_id
      WHERE om.user_id = auth.uid()
      AND om.role IN ('owner', 'admin', 'member')
    )
  );

CREATE POLICY "content_update_author"
  ON public.contents FOR UPDATE
  USING (
    user_id = auth.uid()
    OR workspace_id IN (
      SELECT w.id
      FROM public.workspaces w
      JOIN public.organization_members om
        ON w.organization_id = om.organization_id
      WHERE om.user_id = auth.uid()
      AND om.role IN ('owner', 'admin')
    )
  );

CREATE POLICY "content_delete_author"
  ON public.contents FOR DELETE
  USING (
    user_id = auth.uid()
    OR workspace_id IN (
      SELECT w.id
      FROM public.workspaces w
      JOIN public.organization_members om
        ON w.organization_id = om.organization_id
      WHERE om.user_id = auth.uid()
      AND om.role IN ('owner', 'admin')
    )
  );
```

## Data Encryption

### At Rest

```typescript
// lib/security/encryption.ts
import crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const TAG_LENGTH = 16;

export class EncryptionService {
  private key: Buffer;

  constructor() {
    this.key = Buffer.from(process.env.ENCRYPTION_KEY!, 'hex');
  }

  encrypt(plaintext: string): EncryptedData {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipher(ALGORITHM, this.key);

    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    const tag = cipher.getAuthTag();

    return {
      encrypted,
      iv: iv.toString('hex'),
      tag: tag.toString('hex')
    };
  }

  decrypt(data: EncryptedData): string {
    const decipher = crypto.createDecipher(ALGORITHM, this.key);
    decipher.setAuthTag(Buffer.from(data.tag, 'hex'));

    let decrypted = decipher.update(data.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  }

  // Hash for non-reversible data
  hash(data: string): string {
    return crypto.createHash('sha256').update(data).digest('hex');
  }
}

interface EncryptedData {
  encrypted: string;
  iv: string;
  tag: string;
}
```

### In Transit

```typescript
// TLS Configuration
const tlsConfig = {
  minVersion: 'TLSv1.2',
  ciphers: [
    'ECDHE-ECDSA-AES128-GCM-SHA256',
    'ECDHE-RSA-AES128-GCM-SHA256',
    'ECDHE-ECDSA-AES256-GCM-SHA384',
    'ECDHE-RSA-AES256-GCM-SHA384'
  ].join(':'),
  honorCipherOrder: true
};

// HSTS Header
const hstsHeader = 'max-age=31536000; includeSubDomains; preload';
```

### Field-Level Encryption

```typescript
// Sensitive fields encryption
const sensitiveFields = {
  channels: ['credentials'],
  users: ['phone_number'],
  subscriptions: ['stripe_customer_id', 'stripe_subscription_id']
};

async function encryptRecord(table: string, record: any): Promise<any> {
  const fields = sensitiveFields[table] || [];
  const encrypted = { ...record };

  for (const field of fields) {
    if (encrypted[field]) {
      encrypted[field] = encryptionService.encrypt(
        typeof encrypted[field] === 'string'
          ? encrypted[field]
          : JSON.stringify(encrypted[field])
      );
    }
  }

  return encrypted;
}
```

## API Security

### Rate Limiting

```typescript
// lib/security/rate-limiter.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL!);

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  keyGenerator: (req: Request) => string;
}

const rateLimits: Record<string, RateLimitConfig> = {
  global: { windowMs: 60000, maxRequests: 1000, keyGenerator: (req) => getClientIp(req) },
  auth: { windowMs: 900000, maxRequests: 5, keyGenerator: (req) => getClientIp(req) },
  api: { windowMs: 60000, maxRequests: 100, keyGenerator: (req) => getUserId(req) },
  ai: { windowMs: 60000, maxRequests: 10, keyGenerator: (req) => getUserId(req) }
};

export async function checkRateLimit(
  route: string,
  req: Request
): Promise<RateLimitResult> {
  const config = rateLimits[route] || rateLimits.global;
  const key = `ratelimit:${route}:${config.keyGenerator(req)}`;

  const pipeline = redis.pipeline();
  pipeline.incr(key);
  pipeline.expire(key, Math.ceil(config.windowMs / 1000));

  const results = await pipeline.exec();
  const count = results![0][1] as number;

  return {
    allowed: count <= config.maxRequests,
    remaining: Math.max(0, config.maxRequests - count),
    resetAt: Date.now() + config.windowMs
  };
}
```

### Input Validation

```typescript
// lib/security/input-validator.ts
import Joi from 'joi';

// Content validation
const contentSchema = Joi.object({
  title: Joi.string().max(200).optional(),
  body: Joi.string().max(50000).required(),
  type: Joi.string().valid('post', 'thread', 'story', 'article').required(),
  metadata: Joi.object().optional()
});

// User input sanitization
function sanitizeInput(input: any): any {
  if (typeof input === 'string') {
    return input
      .replace(/<[^>]*>/g, '') // Remove HTML tags
      .replace(/[<>]/g, '') // Remove angle brackets
      .trim();
  }

  if (typeof input === 'object' && input !== null) {
    const sanitized: any = Array.isArray(input) ? [] : {};
    for (const [key, value] of Object.entries(input)) {
      sanitized[key] = sanitizeInput(value);
    }
    return sanitized;
  }

  return input;
}
```

### CSRF Protection

```typescript
// lib/security/csrf.ts
import crypto from 'crypto';

export class CSRFProtection {
  private secret: string;

  constructor() {
    this.secret = process.env.CSRF_SECRET!;
  }

  generateToken(): string {
    return crypto.randomBytes(32).toString('hex');
  }

  hashToken(token: string): string {
    return crypto
      .createHmac('sha256', this.secret)
      .update(token)
      .digest('hex');
  }

  validateToken(token: string, hash: string): boolean {
    return this.hashToken(token) === hash;
  }
}
```

## OWASP Compliance

### Security Headers

```typescript
// lib/security/headers.ts
export const securityHeaders = {
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=(), payment=()',
  'Content-Security-Policy': [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data: https:",
    "font-src 'self' data:",
    "connect-src 'self' https://api.contentos.ai https://*.supabase.co wss://*.supabase.co",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'"
  ].join('; ')
};
```

### OWASP Top 10 Mitigations

| Risk | Mitigation |
|------|------------|
| A01: Broken Access Control | RBAC + RLS + JWT validation |
| A02: Cryptographic Failures | AES-256-GCM + TLS 1.2+ |
| A03: Injection | Parameterized queries + input validation |
| A04: Insecure Design | Threat modeling + security reviews |
| A05: Security Misconfiguration | Automated security scans |
| A06: Vulnerable Components | Dependency scanning + updates |
| A07: Auth Failures | MFA + rate limiting + session management |
| A08: Data Integrity | Signed requests + checksums |
| A09: Logging Failures | Audit logging + monitoring |
| A10: SSRF | Input validation + allowlists |

### Security Scanning

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'

      - name: Run ESLint Security
        run: npm run lint:security
```
