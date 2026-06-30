# Logging Architecture

## Overview

Centralized logging with structured format, multiple destinations, and audit trail support.

## Log Levels

| Level | Usage | When to Use |
|-------|-------|-------------|
| DEBUG | Detailed diagnostic info | Development debugging only |
| INFO | General operational events | Request completed, job finished |
| WARN | Unexpected but recoverable | Rate limit approaching, retry |
| ERROR | Operation failures | API errors, validation failures |
| FATAL | Critical system failures | Database down, auth service failure |

### Level Configuration

```typescript
// lib/logging/config.ts
interface LoggingConfig {
  level: LogLevel;
  format: 'json' | 'text';
  destinations: LogDestination[];
  sensitiveFields: string[];
}

type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'fatal';

interface LogDestination {
  type: 'console' | 'file' | 'remote' | 'elk';
  level: LogLevel;
  options?: Record<string, any>;
}

const loggingConfig: Record<string, LoggingConfig> = {
  development: {
    level: 'debug',
    format: 'text',
    destinations: [
      { type: 'console', level: 'debug' }
    ],
    sensitiveFields: ['password', 'token', 'secret']
  },
  staging: {
    level: 'info',
    format: 'json',
    destinations: [
      { type: 'console', level: 'info' },
      { type: 'remote', level: 'info', options: { endpoint: process.env.LOG_DRAIN_URL } }
    ],
    sensitiveFields: ['password', 'token', 'secret', 'credentials']
  },
  production: {
    level: 'info',
    format: 'json',
    destinations: [
      { type: 'console', level: 'info' },
      { type: 'remote', level: 'info', options: { endpoint: process.env.LOG_DRAIN_URL } },
      { type: 'elk', level: 'info', options: { cluster: process.env.ELK_URL } }
    ],
    sensitiveFields: ['password', 'token', 'secret', 'credentials', 'authorization']
  }
};
```

## Log Format

### Standard Log Entry

```typescript
interface LogEntry {
  timestamp: string;          // ISO 8601
  level: string;              // DEBUG, INFO, WARN, ERROR, FATAL
  message: string;
  service: string;            // microservice name
  version: string;            // app version
  environment: string;        // dev, staging, prod
  trace_id?: string;          // distributed trace ID
  span_id?: string;           // current span ID
  request_id?: string;        // unique request ID
  user_id?: string;           // authenticated user
  org_id?: string;            // organization context
  duration_ms?: number;       // operation duration
  http?: {                    // HTTP request context
    method: string;
    url: string;
    status_code: number;
    user_agent?: string;
    ip?: string;
  };
  error?: {                   // Error context
    name: string;
    message: string;
    stack?: string;
    code?: string;
  };
  metadata?: Record<string, any>;  // Additional context
}

// Example log entry
const exampleLog: LogEntry = {
  timestamp: '2026-01-15T10:30:45.123Z',
  level: 'INFO',
  message: 'Content published successfully',
  service: 'publishing-service',
  version: '1.0.0',
  environment: 'production',
  trace_id: 'abc123def456',
  span_id: 'span789',
  request_id: 'req-001',
  user_id: 'user-123',
  org_id: 'org-456',
  duration_ms: 1250,
  http: {
    method: 'POST',
    url: '/api/v1/publish/now',
    status_code: 200,
    user_agent: 'Mozilla/5.0',
    ip: '192.168.1.1'
  },
  metadata: {
    platform: 'twitter',
    post_id: 'post-789',
    channel_id: 'channel-012'
  }
};
```

### Log Sanitization

```typescript
// lib/logging/sanitizer.ts
class LogSanitizer {
  private sensitiveFields: Set<string>;

  constructor(sensitiveFields: string[]) {
    this.sensitiveFields = new Set(sensitiveFields);
  }

  sanitize(data: any): any {
    if (data === null || data === undefined) {
      return data;
    }

    if (typeof data === 'string') {
      return this.sanitizeString(data);
    }

    if (typeof data === 'object') {
      return this.sanitizeObject(data);
    }

    return data;
  }

  private sanitizeObject(obj: any): any {
    if (Array.isArray(obj)) {
      return obj.map(item => this.sanitize(item));
    }

    const sanitized: any = {};
    for (const [key, value] of Object.entries(obj)) {
      if (this.sensitiveFields.has(key.toLowerCase())) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = this.sanitize(value);
      }
    }
    return sanitized;
  }

  private sanitizeString(str: string): string {
    // Redact email addresses
    str = str.replace(/[\w.-]+@[\w.-]+\.\w+/g, '[EMAIL_REDACTED]');

    // Redact credit card numbers
    str = str.replace(/\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g, '[CARD_REDACTED]');

    // Redact SSN
    str = str.replace(/\b\d{3}-\d{2}-\d{4}\b/g, '[SSN_REDACTED]');

    return str;
  }
}
```

## Log Storage

### Storage Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    LOG STORAGE PIPELINE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │ App      │────►│  Log     │────►│ Central  │               │
│  │ (Edge    │     │  Drain   │     │  Store   │               │
│  │ Functions│     │ (Vector) │     │  (ELK)   │               │
│  └──────────┘     └──────────┘     └────┬─────┘               │
│                                          │                      │
│                                    ┌─────▼─────┐               │
│                                    │  Query    │               │
│                                    │  (Kibana) │               │
│                                    └───────────┘               │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Retention Policies                    │   │
│  │  Hot Storage:  7 days  (SSD, full fidelity)            │   │
│  │  Warm Storage: 30 days (HDD, indexed)                  │   │
│  │  Cold Storage: 1 year  (S3, compressed)                │   │
│  │  Archive:      7 years ( Glacier, compressed)          │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Supabase Log Drain

```sql
-- Enable log drain in Supabase
-- supabase/config.toml
[logs]
enabled = true
backend = "postgres"
```

### Remote Log Destination

```typescript
// lib/logging/destinations/remote.ts
class RemoteLogDestination {
  private endpoint: string;
  private batchSize: number;
  private flushInterval: number;
  private buffer: LogEntry[] = [];

  constructor(config: { endpoint: string; batchSize?: number; flushInterval?: number }) {
    this.endpoint = config.endpoint;
    this.batchSize = config.batchSize || 100;
    this.flushInterval = config.flushInterval || 5000;

    // Periodic flush
    setInterval(() => this.flush(), this.flushInterval);
  }

  async write(entry: LogEntry): Promise<void> {
    this.buffer.push(entry);

    if (this.buffer.length >= this.batchSize) {
      await this.flush();
    }
  }

  private async flush(): Promise<void> {
    if (this.buffer.length === 0) return;

    const logs = [...this.buffer];
    this.buffer = [];

    try {
      await fetch(this.endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ logs })
      });
    } catch (error) {
      // Re-queue failed logs
      this.buffer.unshift(...logs);
      console.error('Failed to send logs:', error);
    }
  }
}
```

## Log Rotation

### Rotation Strategy

```typescript
// lib/logging/rotation.ts
interface RotationConfig {
  maxSize: string;        // e.g., '100MB', '1GB'
  maxFiles: number;
  compress: boolean;
  datePattern: string;    // e.g., 'YYYY-MM-DD'
}

const rotationConfigs: Record<string, RotationConfig> = {
  application: {
    maxSize: '100MB',
    maxFiles: 30,
    compress: true,
    datePattern: 'YYYY-MM-DD'
  },
  access: {
    maxSize: '500MB',
    maxFiles: 90,
    compress: true,
    datePattern: 'YYYY-MM-DD'
  },
  error: {
    maxSize: '50MB',
    maxFiles: 60,
    compress: true,
    datePattern: 'YYYY-MM-DD'
  },
  audit: {
    maxSize: '200MB',
    maxFiles: 365,
    compress: true,
    datePattern: 'YYYY-MM-DD'
  }
};
```

### File-based Logging (Edge Functions)

```typescript
// lib/logging/file-logger.ts
class FileLogger {
  private baseDir: string;
  private rotation: RotationConfig;

  constructor(baseDir: string, rotation: RotationConfig) {
    this.baseDir = baseDir;
    this.rotation = rotation;
  }

  private getLogFilePath(level: string): string {
    const date = new Date().toISOString().split('T')[0];
    return `${this.baseDir}/${level}/${date}.log`;
  }

  async write(entry: LogEntry): Promise<void> {
    const filePath = this.getLogFilePath(entry.level.toLowerCase());
    const logLine = JSON.stringify(entry) + '\n';

    await Deno.writeTextFile(filePath, logLine, { append: true });

    // Check rotation
    await this.checkRotation(filePath);
  }

  private async checkRotation(filePath: string): Promise<void> {
    const stat = await Deno.stat(filePath);
    const maxSizeBytes = this.parseSize(this.rotation.maxSize);

    if (stat.size >= maxSizeBytes) {
      await this.rotate(filePath);
    }
  }

  private async rotate(filePath: string): Promise<void> {
    const timestamp = Date.now();
    const rotatedPath = `${filePath}.${timestamp}`;

    await Deno.rename(filePath, rotatedPath);

    if (this.rotation.compress) {
      await this.compress(rotatedPath);
    }

    await this.cleanupOldFiles();
  }

  private async cleanupOldFiles(): Promise<void> {
    const dir = `${this.baseDir}/${level}`;
    const files = await Deno.readDir(dir);
    const logFiles = Array.from(files)
      .filter(f => f.name.endsWith('.log'))
      .sort((a, b) => a.name.localeCompare(b.name));

    while (logFiles.length > this.rotation.maxFiles) {
      const oldest = logFiles.shift();
      await Deno.remove(`${dir}/${oldest!.name}`);
    }
  }

  private parseSize(size: string): number {
    const units: Record<string, number> = {
      'KB': 1024,
      'MB': 1024 * 1024,
      'GB': 1024 * 1024 * 1024
    };
    const match = size.match(/^(\d+)(KB|MB|GB)$/);
    if (!match) return 100 * 1024 * 1024; // Default 100MB
    return parseInt(match[1]) * units[match[2]];
  }
}
```

## Audit Logging

### Audit Event Types

```typescript
// lib/audit/event-types.ts
enum AuditEvent {
  // Auth events
  USER_LOGIN = 'user.login',
  USER_LOGOUT = 'user.logout',
  USER_REGISTER = 'user.register',
  USER_PASSWORD_CHANGE = 'user.password_change',
  USER_MFA_ENABLE = 'user.mfa_enable',
  USER_MFA_DISABLE = 'user.mfa_disable',

  // Organization events
  ORG_CREATE = 'organization.create',
  ORG_UPDATE = 'organization.update',
  ORG_DELETE = 'organization.delete',
  ORG_MEMBER_INVITE = 'organization.member_invite',
  ORG_MEMBER_REMOVE = 'organization.member_remove',
  ORG_MEMBER_ROLE_CHANGE = 'organization.member_role_change',
  ORG_PLAN_CHANGE = 'organization.plan_change',

  // Content events
  CONTENT_CREATE = 'content.create',
  CONTENT_UPDATE = 'content.update',
  CONTENT_DELETE = 'content.delete',
  CONTENT_PUBLISH = 'content.publish',

  // Channel events
  CHANNEL_CONNECT = 'channel.connect',
  CHANNEL_DISCONNECT = 'channel.disconnect',

  // Billing events
  BILLING_SUBSCRIPTION_CREATE = 'billing.subscription_create',
  BILLING_SUBSCRIPTION_UPDATE = 'billing.subscription_update',
  BILLING_SUBSCRIPTION_CANCEL = 'billing.subscription_cancel',
  BILLING_PAYMENT_SUCCESS = 'billing.payment_success',
  BILLING_PAYMENT_FAILURE = 'billing.payment_failure',

  // Admin events
  ADMIN_USER_SUSPEND = 'admin.user_suspend',
  ADMIN_USER_REACTIVATE = 'admin.user_reactivate',
  ADMIN_ORG_SUSPEND = 'admin.organization_suspend',
  ADMIN_CONFIG_CHANGE = 'admin.config_change'
}
```

### Audit Logger

```typescript
// lib/audit/logger.ts
interface AuditLog {
  id: string;
  event: AuditEvent;
  actor: {
    id: string;
    type: 'user' | 'system' | 'admin';
    email?: string;
    ip?: string;
  };
  target: {
    type: string;
    id: string;
  };
  details: Record<string, any>;
  timestamp: string;
  status: 'success' | 'failure';
}

class AuditLogger {
  async log(audit: Omit<AuditLog, 'id' | 'timestamp'>): Promise<void> {
    const entry: AuditLog = {
      ...audit,
      id: generateId(),
      timestamp: new Date().toISOString()
    };

    // Store in database
    await db.audit_logs.create(entry);

    // Send to log drain
    await loggers.audit.info(`Audit: ${entry.event}`, {
      metadata: entry
    });

    // Alert on critical events
    if (this.isCriticalEvent(entry.event)) {
      await this.sendAlert(entry);
    }
  }

  private isCriticalEvent(event: AuditEvent): boolean {
    const criticalEvents = [
      AuditEvent.ADMIN_USER_SUSPEND,
      AuditEvent.ADMIN_ORG_SUSPEND,
      AuditEvent.ADMIN_CONFIG_CHANGE,
      AuditEvent.ORG_DELETE,
      AuditEvent.BILLING_SUBSCRIPTION_CANCEL
    ];
    return criticalEvents.includes(event);
  }

  private async sendAlert(audit: AuditLog): Promise<void> {
    await sendAlert({
      level: 'warning',
      title: `Audit Event: ${audit.event}`,
      message: `Actor ${audit.actor.id} performed ${audit.event} on ${audit.target.type} ${audit.target.id}`,
      metadata: audit
    });
  }
}

export const auditLogger = new AuditLogger();
```

### Audit Query API

```typescript
// lib/audit/query.ts
interface AuditQuery {
  startDate?: string;
  endDate?: string;
  event?: AuditEvent | AuditEvent[];
  actorId?: string;
  targetType?: string;
  targetId?: string;
  status?: 'success' | 'failure';
  limit?: number;
  offset?: number;
}

async function queryAuditLogs(query: AuditQuery): Promise<AuditLog[]> {
  let sql = 'SELECT * FROM audit_logs WHERE 1=1';
  const params: any[] = [];

  if (query.startDate) {
    sql += ' AND timestamp >= $' + (params.length + 1);
    params.push(query.startDate);
  }

  if (query.endDate) {
    sql += ' AND timestamp <= $' + (params.length + 1);
    params.push(query.endDate);
  }

  if (query.event) {
    const events = Array.isArray(query.event) ? query.event : [query.event];
    sql += ' AND event = ANY($' + (params.length + 1) + ')';
    params.push(events);
  }

  if (query.actorId) {
    sql += ' AND actor_id = $' + (params.length + 1);
    params.push(query.actorId);
  }

  if (query.targetType) {
    sql += ' AND target_type = $' + (params.length + 1);
    params.push(query.targetType);
  }

  sql += ' ORDER BY timestamp DESC';

  if (query.limit) {
    sql += ' LIMIT $' + (params.length + 1);
    params.push(query.limit);
  }

  if (query.offset) {
    sql += ' OFFSET $' + (params.length + 1);
    params.push(query.offset);
  }

  return db.query(sql, params);
}
```

### Audit Database Schema

```sql
CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event TEXT NOT NULL,
  actor_id TEXT NOT NULL,
  actor_type TEXT NOT NULL DEFAULT 'user',
  actor_email TEXT,
  actor_ip INET,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  details JSONB DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'success',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_audit_logs_event ON public.audit_logs(event);
CREATE INDEX idx_audit_logs_actor ON public.audit_logs(actor_id);
CREATE INDEX idx_audit_logs_target ON public.audit_logs(target_type, target_id);
CREATE INDEX idx_audit_logs_timestamp ON public.audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_status ON public.audit_logs(status);
```
