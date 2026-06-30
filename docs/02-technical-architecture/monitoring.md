# Observability

## Overview

Comprehensive monitoring stack with structured logging, metrics collection, distributed tracing, and alerting.

## Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MONITORING STACK                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Application Layer                     │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │ PostHog  │  │ Plausible│  │  Sentry  │  │ Custom  ││   │
│  │  │Analytics │  │   Web    │  │  Error   │  │ Metrics ││   │
│  │  │          │  │Analytics │  │ Tracking │  │  (API)  ││   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘│   │
│  └───────┼──────────────┼──────────────┼──────────────┼──────┘   │
│          │              │              │              │           │
│  ┌───────▼──────────────▼──────────────▼──────────────▼──────┐   │
│  │                   Data Collection                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │  Event   │  │  Metric  │  │   Log    │  │  Trace  ││   │
│  │  │  Store   │  │  Store   │  │  Store   │  │  Store  ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Analysis & Alerting                    │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │ Grafana  │  │ PagerDuty│  │ Slack    │  │ Email   ││   │
│  │  │Dashboard │  │  Alerts  │  │ Alerts   │  │ Alerts  ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Structured Logging

### Log Format

```typescript
// lib/logging/logger.ts
interface LogEntry {
  timestamp: string;
  level: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
  message: string;
  service: string;
  traceId?: string;
  spanId?: string;
  userId?: string;
  organizationId?: string;
  requestId?: string;
  duration?: number;
  metadata?: Record<string, any>;
  error?: {
    name: string;
    message: string;
    stack: string;
    code?: string;
  };
}

class Logger {
  private service: string;

  constructor(service: string) {
    this.service = service;
  }

  private createEntry(
    level: LogEntry['level'],
    message: string,
    data?: Partial<LogEntry>
  ): LogEntry {
    return {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: this.service,
      ...data
    };
  }

  debug(message: string, data?: Partial<LogEntry>): void {
    console.log(JSON.stringify(this.createEntry('debug', message, data)));
  }

  info(message: string, data?: Partial<LogEntry>): void {
    console.log(JSON.stringify(this.createEntry('info', message, data)));
  }

  warn(message: string, data?: Partial<LogEntry>): void {
    console.warn(JSON.stringify(this.createEntry('warn', message, data)));
  }

  error(message: string, error?: Error, data?: Partial<LogEntry>): void {
    console.error(JSON.stringify(this.createEntry('error', message, {
      ...data,
      error: error ? {
        name: error.name,
        message: error.message,
        stack: error.stack
      } : undefined
    })));
  }

  fatal(message: string, error?: Error, data?: Partial<LogEntry>): void {
    console.error(JSON.stringify(this.createEntry('fatal', message, {
      ...data,
      error: error ? {
        name: error.name,
        message: error.message,
        stack: error.stack
      } : undefined
    })));
  }

  // Request logging middleware
  request(req: Request, res: Response, duration: number): void {
    this.info('Request completed', {
      requestId: req.headers.get('x-request-id'),
      method: req.method,
      url: req.url,
      statusCode: res.status,
      duration,
      userAgent: req.headers.get('user-agent'),
      ip: req.headers.get('x-forwarded-for')
    });
  }
}

// Service-specific loggers
export const loggers = {
  api: new Logger('api-gateway'),
  auth: new Logger('auth-service'),
  content: new Logger('content-service'),
  publishing: new Logger('publishing-service'),
  ai: new Logger('ai-service'),
  analytics: new Logger('analytics-service'),
  notification: new Logger('notification-service'),
  billing: new Logger('billing-service')
};
```

### Request Logging Middleware

```typescript
// lib/middleware/logging.ts
import { Context, Next } from 'hono';

export async function loggingMiddleware(c: Context, next: Next) {
  const startTime = Date.now();
  const requestId = c.req.header('x-request-id') || generateRequestId();

  // Add request ID to context
  c.set('requestId', requestId);
  c.header('X-Request-Id', requestId);

  try {
    await next();
  } finally {
    const duration = Date.now() - startTime;

    loggers.api.request(c.req.raw, new Response(null, { status: c.res.status }), duration);
  }
}
```

## Metrics Collection

### Custom Metrics

```typescript
// lib/metrics/metrics.ts
class MetricsCollector {
  private counters: Map<string, number> = new Map();
  private histograms: Map<string, number[]> = new Map();
  private gauges: Map<string, number> = new Map();

  // Counter: incremented for events
  increment(name: string, tags?: Record<string, string>): void {
    const key = this.buildKey(name, tags);
    const current = this.counters.get(key) || 0;
    this.counters.set(key, current + 1);
  }

  // Histogram: tracks distribution of values
  histogram(name: string, value: number, tags?: Record<string, string>): void {
    const key = this.buildKey(name, tags);
    const values = this.histograms.get(key) || [];
    values.push(value);
    this.histograms.set(key, values);
  }

  // Gauge: tracks current value
  gauge(name: string, value: number, tags?: Record<string, string>): void {
    const key = this.buildKey(name, tags);
    this.gauges.set(key, value);
  }

  // Timer: tracks duration
  timer(name: string, tags?: Record<string, string>): () => void {
    const startTime = Date.now();
    return () => {
      const duration = Date.now() - startTime;
      this.histogram(name, duration, tags);
    };
  }

  // Get metrics for export
  getMetrics(): MetricsSnapshot {
    return {
      counters: Object.fromEntries(this.counters),
      histograms: Object.fromEntries(
        Array.from(this.histograms.entries()).map(([key, values]) => [
          key,
          {
            count: values.length,
            sum: values.reduce((a, b) => a + b, 0),
            min: Math.min(...values),
            max: Math.max(...values),
            avg: values.reduce((a, b) => a + b, 0) / values.length,
            p50: percentile(values, 50),
            p95: percentile(values, 95),
            p99: percentile(values, 99)
          }
        ])
      ),
      gauges: Object.fromEntries(this.gauges)
    };
  }

  private buildKey(name: string, tags?: Record<string, string>): string {
    if (!tags) return name;
    const tagString = Object.entries(tags)
      .map(([k, v]) => `${k}=${v}`)
      .join(',');
    return `${name}{${tagString}}`;
  }
}

export const metrics = new MetricsCollector();
```

### Application Metrics

```typescript
// lib/metrics/app-metrics.ts
export const appMetrics = {
  // API Metrics
  api: {
    requestCount: (method: string, path: string, status: number) =>
      metrics.increment('http_requests_total', { method, path, status: status.toString() }),

    requestDuration: (method: string, path: string, duration: number) =>
      metrics.histogram('http_request_duration_ms', duration, { method, path }),

    activeConnections: (delta: number) =>
      metrics.gauge('http_active_connections', delta)
  },

  // Auth Metrics
  auth: {
    loginAttempts: (method: string, success: boolean) =>
      metrics.increment('auth_login_attempts', { method, success: success.toString() }),

    mfaAttempts: (success: boolean) =>
      metrics.increment('auth_mfa_attempts', { success: success.toString() })
  },

  // Content Metrics
  content: {
    created: (type: string) =>
      metrics.increment('content_created', { type }),

    published: (platform: string) =>
      metrics.increment('content_published', { platform }),

    aiGenerated: (provider: string, model: string) =>
      metrics.increment('ai_content_generated', { provider, model })
  },

  // Queue Metrics
  queue: {
    jobAdded: (queue: string) =>
      metrics.increment('queue_jobs_added', { queue }),

    jobCompleted: (queue: string, duration: number) =>
      metrics.histogram('queue_job_duration_ms', duration, { queue }),

    jobFailed: (queue: string, error: string) =>
      metrics.increment('queue_jobs_failed', { queue, error }),

    queueSize: (queue: string, size: number) =>
      metrics.gauge('queue_size', size, { queue })
  },

  // AI Metrics
  ai: {
    tokenUsage: (provider: string, model: string, tokens: number) =>
      metrics.histogram('ai_tokens_used', tokens, { provider, model }),

    generationDuration: (provider: string, duration: number) =>
      metrics.histogram('ai_generation_duration_ms', duration, { provider }),

    generationErrors: (provider: string, error: string) =>
      metrics.increment('ai_generation_errors', { provider, error })
  },

  // Storage Metrics
  storage: {
    fileUploaded: (type: string, size: number) =>
      metrics.histogram('storage_file_size', size, { type }),

    storageUsed: (orgId: string, size: number) =>
      metrics.gauge('storage_used_bytes', size, { orgId })
  }
};
```

### Prometheus Endpoint

```typescript
// lib/metrics/prometheus.ts
export function prometheusEndpoint(): string {
  const metrics = collector.getMetrics();
  const lines: string[] = [];

  // Counters
  for (const [key, value] of Object.entries(metrics.counters)) {
    lines.push(`# TYPE ${key.replace(/[{}]/g, '_')} counter`);
    lines.push(`${key.replace(/[{}]/g, '_')} ${value}`);
  }

  // Histograms
  for (const [key, value] of Object.entries(metrics.histograms)) {
    const name = key.replace(/[{}]/g, '_');
    lines.push(`# TYPE ${name} histogram`);
    lines.push(`${name}_count ${value.count}`);
    lines.push(`${name}_sum ${value.sum}`);
    lines.push(`${name}_bucket{le="50"} ${value.p50}`);
    lines.push(`${name}_bucket{le="95"} ${value.p95}`);
    lines.push(`${name}_bucket{le="99"} ${value.p99}`);
  }

  // Gauges
  for (const [key, value] of Object.entries(metrics.gauges)) {
    lines.push(`# TYPE ${key.replace(/[{}]/g, '_')} gauge`);
    lines.push(`${key.replace(/[{}]/g, '_')} ${value}`);
  }

  return lines.join('\n');
}
```

## Distributed Tracing

### Trace Implementation

```typescript
// lib/tracing/tracer.ts
interface Span {
  traceId: string;
  spanId: string;
  parentSpanId?: string;
  operation: string;
  startTime: number;
  endTime?: number;
  status: 'ok' | 'error';
  attributes: Record<string, any>;
  events: SpanEvent[];
}

interface SpanEvent {
  name: string;
  timestamp: number;
  attributes?: Record<string, any>;
}

class Tracer {
  private spans: Map<string, Span> = new Map();

  startSpan(
    operation: string,
    parentSpanId?: string,
    attributes?: Record<string, any>
  ): Span {
    const traceId = parentSpanId
      ? this.spans.get(parentSpanId)?.traceId || generateId()
      : generateId();

    const span: Span = {
      traceId,
      spanId: generateId(),
      parentSpanId,
      operation,
      startTime: Date.now(),
      status: 'ok',
      attributes: attributes || {},
      events: []
    };

    this.spans.set(span.spanId, span);
    return span;
  }

  endSpan(spanId: string, status: 'ok' | 'error' = 'ok'): void {
    const span = this.spans.get(spanId);
    if (span) {
      span.endTime = Date.now();
      span.status = status;
    }
  }

  addEvent(spanId: string, name: string, attributes?: Record<string, any>): void {
    const span = this.spans.get(spanId);
    if (span) {
      span.events.push({
        name,
        timestamp: Date.now(),
        attributes
      });
    }
  }

  getTrace(traceId: string): Span[] {
    return Array.from(this.spans.values())
      .filter(s => s.traceId === traceId)
      .sort((a, b) => a.startTime - b.startTime);
  }
}

export const tracer = new Tracer();
```

### Tracing Middleware

```typescript
// lib/middleware/tracing.ts
import { Context, Next } from 'hono';

export async function tracingMiddleware(c: Context, next: Next) {
  const traceId = c.req.header('x-trace-id') || generateId();
  const parentSpanId = c.req.header('x-span-id');

  const span = tracer.startSpan('http.request', parentSpanId, {
    method: c.req.method,
    url: c.req.url,
    traceId
  });

  c.set('traceId', traceId);
  c.set('spanId', span.spanId);
  c.header('X-Trace-Id', traceId);

  try {
    await next();
    tracer.endSpan(span.spanId, 'ok');
  } catch (error) {
    tracer.endSpan(span.spanId, 'error');
    throw error;
  }
}
```

## Alerting Rules

### Alert Configuration

```typescript
// lib/alerting/rules.ts
interface AlertRule {
  name: string;
  condition: string;
  threshold: number;
  window: number;
  severity: 'low' | 'medium' | 'high' | 'critical';
  channels: string[];
  message: string;
}

const alertRules: AlertRule[] = [
  {
    name: 'high_error_rate',
    condition: 'error_rate > threshold',
    threshold: 0.05, // 5%
    window: 300, // 5 minutes
    severity: 'high',
    channels: ['slack', 'pagerduty'],
    message: 'Error rate exceeded 5% in the last 5 minutes'
  },
  {
    name: 'slow_api_response',
    condition: 'p95_latency > threshold',
    threshold: 2000, // 2 seconds
    window: 300,
    severity: 'medium',
    channels: ['slack'],
    message: 'API P95 latency exceeded 2 seconds'
  },
  {
    name: 'queue_backlog',
    condition: 'queue_size > threshold',
    threshold: 1000,
    window: 60,
    severity: 'high',
    channels: ['slack', 'pagerduty'],
    message: 'Queue backlog exceeded 1000 jobs'
  },
  {
    name: 'ai_provider_errors',
    condition: 'ai_error_rate > threshold',
    threshold: 0.1, // 10%
    window: 300,
    severity: 'critical',
    channels: ['slack', 'pagerduty', 'email'],
    message: 'AI provider error rate exceeded 10%'
  },
  {
    name: 'database_connections',
    condition: 'db_connections > threshold',
    threshold: 80, // 80% of max
    window: 60,
    severity: 'high',
    channels: ['slack', 'pagerduty'],
    message: 'Database connection pool usage exceeded 80%'
  },
  {
    name: 'memory_usage',
    condition: 'memory_usage > threshold',
    threshold: 85, // 85%
    window: 300,
    severity: 'medium',
    channels: ['slack'],
    message: 'Memory usage exceeded 85%'
  }
];
```

### Alert Manager

```typescript
// lib/alerting/manager.ts
class AlertManager {
  private activeAlerts: Map<string, Alert> = new Map();

  async evaluateRule(rule: AlertRule, metrics: MetricsSnapshot): Promise<void> {
    const currentValue = this.getMetricValue(rule.condition, metrics);
    const shouldAlert = this.evaluateCondition(currentValue, rule);

    if (shouldAlert && !this.activeAlerts.has(rule.name)) {
      const alert: Alert = {
        name: rule.name,
        severity: rule.severity,
        message: rule.message,
        currentValue,
        threshold: rule.threshold,
        timestamp: new Date().toISOString()
      };

      this.activeAlerts.set(rule.name, alert);
      await this.sendAlert(alert, rule.channels);
    } else if (!shouldAlert && this.activeAlerts.has(rule.name)) {
      this.activeAlerts.delete(rule.name);
      await this.resolveAlert(rule.name);
    }
  }

  private async sendAlert(alert: Alert, channels: string[]): Promise<void> {
    for (const channel of channels) {
      switch (channel) {
        case 'slack':
          await this.sendSlackAlert(alert);
          break;
        case 'pagerduty':
          await this.sendPagerDutyAlert(alert);
          break;
        case 'email':
          await this.sendEmailAlert(alert);
          break;
      }
    }
  }

  private async sendSlackAlert(alert: Alert): Promise<void> {
    const color = {
      low: '#36a64f',
      medium: '#ff9900',
      high: '#ff0000',
      critical: '#9b59b6'
    }[alert.severity];

    await fetch(process.env.SLACK_WEBHOOK_URL!, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        attachments: [{
          color,
          title: `Alert: ${alert.name}`,
          text: alert.message,
          fields: [
            { title: 'Severity', value: alert.severity, short: true },
            { title: 'Current Value', value: alert.currentValue.toString(), short: true },
            { title: 'Threshold', value: alert.threshold.toString(), short: true },
            { title: 'Time', value: alert.timestamp, short: true }
          ]
        }]
      })
    });
  }
}
```

## Dashboard Setup

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "ContentOS Platform Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [{
          "expr": "rate(http_requests_total[5m])",
          "legendFormat": "{{method}} {{path}}"
        }]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [{
          "expr": "rate(http_requests_total{status=~'5..'}[5m]) / rate(http_requests_total[5m])",
          "legendFormat": "Error Rate"
        }]
      },
      {
        "title": "Latency Distribution",
        "type": "heatmap",
        "targets": [{
          "expr": "histogram_quantile(0.95, rate(http_request_duration_ms_bucket[5m]))",
          "legendFormat": "P95 Latency"
        }]
      },
      {
        "title": "Queue Size",
        "type": "stat",
        "targets": [{
          "expr": "queue_size",
          "legendFormat": "{{queue}}"
        }]
      },
      {
        "title": "AI Token Usage",
        "type": "graph",
        "targets": [{
          "expr": "rate(ai_tokens_used[1h])",
          "legendFormat": "{{provider}} {{model}}"
        }]
      }
    ]
  }
}
```

### Health Check Endpoint

```typescript
// lib/health/health-check.ts
interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  services: ServiceHealth[];
  version: string;
  uptime: number;
}

interface ServiceHealth {
  name: string;
  status: 'healthy' | 'degraded' | 'unhealthy';
  latency?: number;
  error?: string;
}

export async function healthCheck(): Promise<HealthStatus> {
  const services: ServiceHealth[] = [];

  // Check database
  const dbHealth = await checkDatabase();
  services.push(dbHealth);

  // Check Redis
  const redisHealth = await checkRedis();
  services.push(redisHealth);

  // Check AI providers
  const aiHealth = await checkAIProviders();
  services.push(aiHealth);

  // Check queue
  const queueHealth = await checkQueue();
  services.push(queueHealth);

  const overallStatus = services.every(s => s.status === 'healthy')
    ? 'healthy'
    : services.some(s => s.status === 'unhealthy')
    ? 'unhealthy'
    : 'degraded';

  return {
    status: overallStatus,
    timestamp: new Date().toISOString(),
    services,
    version: process.env.APP_VERSION || '1.0.0',
    uptime: process.uptime()
  };
}

async function checkDatabase(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    await db.query('SELECT 1');
    return {
      name: 'postgresql',
      status: 'healthy',
      latency: Date.now() - start
    };
  } catch (error) {
    return {
      name: 'postgresql',
      status: 'unhealthy',
      error: error.message
    };
  }
}

async function checkRedis(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    await redis.ping();
    return {
      name: 'redis',
      status: 'healthy',
      latency: Date.now() - start
    };
  } catch (error) {
    return {
      name: 'redis',
      status: 'unhealthy',
      error: error.message
    };
  }
}
```
