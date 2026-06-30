# Production Monitoring Guide

## Overview

This guide covers production monitoring, including health checks, metrics dashboards, alerting rules, and on-call procedures.

## Health Checks

### Health Check Implementation

```typescript
// src/services/health.service.ts
import { DataSource } from 'typeorm';
import { Redis } from 'ioredis';

export class HealthService {
  private dataSource: DataSource;
  private redis: Redis;

  constructor(dataSource: DataSource, redis: Redis) {
    this.dataSource = dataSource;
    this.redis = redis;
  }

  async check(): Promise<HealthStatus> {
    const checks = await Promise.allSettled([
      this.checkDatabase(),
      this.checkCache(),
      this.checkExternalServices(),
      this.checkDiskSpace(),
      this.checkMemory(),
    ]);

    const healthy = checks.every(
      (result) => result.status === 'fulfilled' && result.value.status === 'healthy'
    );

    return {
      status: healthy ? 'healthy' : 'unhealthy',
      timestamp: new Date().toISOString(),
      checks: {
        database: this.getResult(checks[0]),
        cache: this.getResult(checks[1]),
        externalServices: this.getResult(checks[2]),
        diskSpace: this.getResult(checks[3]),
        memory: this.getResult(checks[4]),
      },
    };
  }

  async readiness(): Promise<boolean> {
    try {
      await this.dataSource.query('SELECT 1');
      await this.redis.ping();
      return true;
    } catch (error) {
      return false;
    }
  }

  async liveness(): Promise<boolean> {
    return true;
  }

  private async checkDatabase(): Promise<CheckResult> {
    try {
      const start = Date.now();
      await this.dataSource.query('SELECT 1');
      const duration = Date.now() - start;

      return {
        status: 'healthy',
        duration,
        message: 'Database connection successful',
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        message: `Database connection failed: ${error.message}`,
      };
    }
  }

  private async checkCache(): Promise<CheckResult> {
    try {
      const start = Date.now();
      await this.redis.ping();
      const duration = Date.now() - start;

      return {
        status: 'healthy',
        duration,
        message: 'Cache connection successful',
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        message: `Cache connection failed: ${error.message}`,
      };
    }
  }

  private async checkExternalServices(): Promise<CheckResult> {
    try {
      // Check external API connectivity
      const response = await fetch('https://api.openai.com/v1/models', {
        method: 'HEAD',
        timeout: 5000,
      });

      if (response.ok) {
        return {
          status: 'healthy',
          message: 'External services accessible',
        };
      } else {
        return {
          status: 'unhealthy',
          message: 'External services returned error',
        };
      }
    } catch (error) {
      return {
        status: 'unhealthy',
        message: `External services check failed: ${error.message}`,
      };
    }
  }

  private async checkDiskSpace(): Promise<CheckResult> {
    try {
      const fs = require('fs');
      const stats = fs.statSync('/');
      const freeSpace = stats.bfree * stats.bsize;
      const totalSpace = stats.blocks * stats.bsize;
      const usedPercentage = ((totalSpace - freeSpace) / totalSpace) * 100;

      if (usedPercentage < 90) {
        return {
          status: 'healthy',
          message: `Disk usage: ${usedPercentage.toFixed(1)}%`,
        };
      } else {
        return {
          status: 'unhealthy',
          message: `Disk usage critical: ${usedPercentage.toFixed(1)}%`,
        };
      }
    } catch (error) {
      return {
        status: 'unknown',
        message: `Disk space check failed: ${error.message}`,
      };
    }
  }

  private async checkMemory(): Promise<CheckResult> {
    try {
      const memUsage = process.memoryUsage();
      const usedPercentage = (memUsage.heapUsed / memUsage.heapTotal) * 100;

      if (usedPercentage < 90) {
        return {
          status: 'healthy',
          message: `Memory usage: ${usedPercentage.toFixed(1)}%`,
        };
      } else {
        return {
          status: 'unhealthy',
          message: `Memory usage critical: ${usedPercentage.toFixed(1)}%`,
        };
      }
    } catch (error) {
      return {
        status: 'unknown',
        message: `Memory check failed: ${error.message}`,
      };
    }
  }

  private getResult(result: PromiseSettledResult<CheckResult>): CheckResult {
    if (result.status === 'fulfilled') {
      return result.value;
    } else {
      return {
        status: 'unhealthy',
        message: result.reason?.message || 'Check failed',
      };
    }
  }
}

interface HealthStatus {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  checks: {
    database: CheckResult;
    cache: CheckResult;
    externalServices: CheckResult;
    diskSpace: CheckResult;
    memory: CheckResult;
  };
}

interface CheckResult {
  status: 'healthy' | 'unhealthy' | 'unknown';
  duration?: number;
  message: string;
}
```

### Health Check Routes

```typescript
// src/routes/health.ts
import { Router } from 'express';
import { HealthService } from '../services/health.service';

export function createHealthRoutes(healthService: HealthService): Router {
  const router = Router();

  // Full health check
  router.get('/health', async (req, res) => {
    try {
      const health = await healthService.check();
      
      if (health.status === 'healthy') {
        res.status(200).json(health);
      } else {
        res.status(503).json(health);
      }
    } catch (error) {
      res.status(503).json({
        status: 'unhealthy',
        error: error.message,
      });
    }
  });

  // Readiness check
  router.get('/health/ready', async (req, res) => {
    try {
      const ready = await healthService.readiness();
      
      if (ready) {
        res.status(200).json({ status: 'ready' });
      } else {
        res.status(503).json({ status: 'not ready' });
      }
    } catch (error) {
      res.status(503).json({
        status: 'not ready',
        error: error.message,
      });
    }
  });

  // Liveness check
  router.get('/health/live', async (req, res) => {
    try {
      const alive = await healthService.liveness();
      
      if (alive) {
        res.status(200).json({ status: 'alive' });
      } else {
        res.status(503).json({ status: 'dead' });
      }
    } catch (error) {
      res.status(503).json({
        status: 'dead',
        error: error.message,
      });
    }
  });

  return router;
}
```

## Metrics Dashboards

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'social-media-ai'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['localhost:9187']

  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['localhost:9121']
```

### Metrics Implementation

```typescript
// src/metrics/index.ts
import { Registry, Counter, Histogram, Gauge, collectDefaultMetrics } from 'prom-client';

// Create a Registry
const register = new Registry();

// Collect default metrics (CPU, memory, etc.)
collectDefaultMetrics({ register });

// Custom metrics
export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  registers: [register],
});

export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
  registers: [register],
});

export const databaseQueryDuration = new Histogram({
  name: 'database_query_duration_seconds',
  help: 'Duration of database queries in seconds',
  labelNames: ['operation', 'table'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  registers: [register],
});

export const cacheHits = new Counter({
  name: 'cache_hits_total',
  help: 'Total number of cache hits',
  labelNames: ['cache'],
  registers: [register],
});

export const cacheMisses = new Counter({
  name: 'cache_misses_total',
  help: 'Total number of cache misses',
  labelNames: ['cache'],
  registers: [register],
});

export const aiRequestsTotal = new Counter({
  name: 'ai_requests_total',
  help: 'Total number of AI requests',
  labelNames: ['model', 'status'],
  registers: [register],
});

export const aiRequestDuration = new Histogram({
  name: 'ai_request_duration_seconds',
  help: 'Duration of AI requests in seconds',
  labelNames: ['model'],
  buckets: [0.1, 0.5, 1, 2, 5, 10, 30],
  registers: [register],
});

// Metrics endpoint
export async function getMetrics(): Promise<string> {
  return register.metrics();
}

export async function getMetricsContentType(): Promise<string> {
  return register.contentType;
}
```

### Grafana Dashboard

```json
// grafana/dashboards/production.json
{
  "dashboard": {
    "title": "Production Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}} {{status}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P50"
          },
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P95"
          },
          {
            "expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P99"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          },
          {
            "expr": "rate(http_requests_total{status=~\"4..\"}[5m])",
            "legendFormat": "4xx errors"
          }
        ]
      },
      {
        "title": "Active Connections",
        "type": "singlestat",
        "targets": [
          {
            "expr": "active_connections",
            "legendFormat": "Connections"
          }
        ]
      },
      {
        "title": "Database Query Duration",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(database_query_duration_seconds_bucket[5m]))",
            "legendFormat": "{{operation}} {{table}}"
          }
        ]
      },
      {
        "title": "Cache Hit Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(cache_hits_total[5m]) / (rate(cache_hits_total[5m]) + rate(cache_misses_total[5m]))",
            "legendFormat": "Hit Rate"
          }
        ]
      },
      {
        "title": "AI Request Duration",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(ai_request_duration_seconds_bucket[5m]))",
            "legendFormat": "{{model}}"
          }
        ]
      }
    ],
    "refresh": "30s",
    "time": {
      "from": "now-1h",
      "to": "now"
    }
  }
}
```

## Alerting Rules

### Alertmanager Configuration

```yaml
# alertmanager.yml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@socialmediaai.com'
  smtp_auth_username: 'alerts@socialmediaai.com'
  smtp_auth_password: 'password'

route:
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    email_configs:
      - to: 'team@socialmediaai.com'
        subject: '{{ .GroupLabels.alertname }}'
        body: '{{ .CommonAnnotations.description }}'
    webhook_configs:
      - url: 'http://localhost:5001/'
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
```

### Prometheus Alert Rules

```yaml
# prometheus/rules/alerts.yml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% (threshold: 1%)"
          
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "P95 response time is {{ $value }}s (threshold: 1s)"
          
      - alert: LowAvailability
        expr: 1 - (rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) < 0.999
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low availability detected"
          description: "Availability is {{ $value }}% (threshold: 99.9%)"
          
      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes / process_virtual_memory_max_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is {{ $value }}% (threshold: 90%)"
          
      - alert: HighCPUUsage
        expr: rate(process_cpu_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is {{ $value }}% (threshold: 80%)"

  - name: database
    rules:
      - alert: HighDatabaseQueryDuration
        expr: histogram_quantile(0.95, rate(database_query_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database query duration"
          description: "P95 query duration is {{ $value }}s (threshold: 0.5s)"
          
      - alert: DatabaseConnectionPoolExhausted
        expr: database_connection_pool_active / database_connection_pool_max > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool nearly exhausted"
          description: "Connection pool usage is {{ $value }}% (threshold: 90%)"

  - name: cache
    rules:
      - alert: LowCacheHitRate
        expr: rate(cache_hits_total[5m]) / (rate(cache_hits_total[5m]) + rate(cache_misses_total[5m])) < 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low cache hit rate"
          description: "Cache hit rate is {{ $value }}% (threshold: 80%)"
          
      - alert: HighCacheEvictionRate
        expr: rate(cache_evictions_total[5m]) > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High cache eviction rate"
          description: "Cache eviction rate is {{ $value }}/s (threshold: 100/s)"

  - name: ai
    rules:
      - alert: HighAIFailureRate
        expr: rate(ai_requests_total{status="error"}[5m]) / rate(ai_requests_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High AI failure rate"
          description: "AI failure rate is {{ $value }}% (threshold: 10%)"
          
      - alert: HighAIDuration
        expr: histogram_quantile(0.95, rate(ai_request_duration_seconds_bucket[5m])) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High AI request duration"
          description: "P95 AI duration is {{ $value }}s (threshold: 10s)"
```

### Alertmanager Rules

```yaml
# alertmanager/rules.yml
groups:
  - name: critical
    rules:
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} is down"
          
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate"
          description: "Error rate is {{ $value }}%"
          
      - alert: DatabaseDown
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database is down"
          description: "PostgreSQL is down"
          
      - alert: RedisDown
        expr: redis_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Redis is down"
          description: "Redis is down"

  - name: warning
    rules:
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time"
          description: "P95 response time is {{ $value }}s"
          
      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes / process_virtual_memory_max_bytes > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}%"
          
      - alert: HighCPUUsage
        expr: rate(process_cpu_seconds_total[5m]) > 0.7
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"
          
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space low"
          description: "Disk space is {{ $value }}% free"
```

## On-Call Procedures

### On-Call Schedule

```yaml
# oncall/schedule.yml
schedule:
  primary:
    - name: "John Doe"
      email: "john@example.com"
      phone: "+1234567890"
      slack: "@john"
      
    - name: "Jane Smith"
      email: "jane@example.com"
      phone: "+0987654321"
      slack: "@jane"
      
  secondary:
    - name: "Bob Johnson"
      email: "bob@example.com"
      phone: "+1122334455"
      slack: "@bob"
      
    - name: "Alice Brown"
      email: "alice@example.com"
      phone: "+5566778899"
      slack: "@alice"

rotation:
  primary:
    frequency: weekly
    start: "2024-01-01"
    
  secondary:
    frequency: weekly
    start: "2024-01-08"
```

### Incident Response Procedures

```markdown
## Incident Response Procedures

### Severity Levels

#### P1 - Critical
- Complete service outage
- Data loss or corruption
- Security breach
- Response time: 15 minutes
- Escalation: Immediate

#### P2 - High
- Major feature unavailable
- Performance degradation
- Partial outage
- Response time: 30 minutes
- Escalation: 1 hour

#### P3 - Medium
- Minor feature issue
- Non-critical bug
- Performance issue
- Response time: 2 hours
- Escalation: 4 hours

#### P4 - Low
- Cosmetic issue
- Enhancement request
- Documentation update
- Response time: 24 hours
- Escalation: Next business day

### Incident Response Steps

#### 1. Detection and Alert
- Monitor alerting channels
- Acknowledge alert
- Assess severity
- Create incident ticket

#### 2. Investigation
- Gather information
- Identify root cause
- Assess impact
- Document findings

#### 3. Mitigation
- Implement immediate fix
- Restore service
- Verify resolution
- Communicate status

#### 4. Resolution
- Implement permanent fix
- Test thoroughly
- Deploy changes
- Verify resolution

#### 5. Post-Incident
- Conduct post-mortem
- Document lessons learned
- Update procedures
- Share knowledge
```

### Escalation Matrix

```yaml
# oncall/escalation.yml
escalation:
  P1:
    - level: 1
      time: 0
      contacts:
        - primary_oncall
        
    - level: 2
      time: 15m
      contacts:
        - secondary_oncall
        - engineering_manager
        
    - level: 3
      time: 30m
      contacts:
        - vp_engineering
        - cto
        
    - level: 4
      time: 1h
      contacts:
        - ceo
        - all_hands

  P2:
    - level: 1
      time: 0
      contacts:
        - primary_oncall
        
    - level: 2
      time: 30m
      contacts:
        - secondary_oncall
        
    - level: 3
      time: 2h
      contacts:
        - engineering_manager
        
    - level: 4
      time: 4h
      contacts:
        - vp_engineering

  P3:
    - level: 1
      time: 0
      contacts:
        - primary_oncall
        
    - level: 2
      time: 2h
      contacts:
        - secondary_oncall
        
    - level: 3
      time: 8h
      contacts:
        - engineering_manager

  P4:
    - level: 1
      time: 0
      contacts:
        - primary_oncall
        
    - level: 2
      time: 24h
      contacts:
        - secondary_oncall
```

### Communication Templates

```markdown
## Communication Templates

### Initial Alert
```
[INCIDENT] P{severity} - {title}

Status: Investigating
Impact: {description}
Start Time: {time}
On-Call: {name}

Updates will follow every {interval}.
```

### Status Update
```
[INCIDENT UPDATE] P{severity} - {title}

Status: {status}
Impact: {description}
Next Update: {time}

Current Actions:
- {action1}
- {action2}
```

### Resolution
```
[RESOLVED] P{severity} - {title}

Status: Resolved
Duration: {duration}
Root Cause: {cause}

Resolution:
- {resolution1}
- {resolution2}

Post-mortem scheduled for {time}.
```

### Post-Mortem
```
[POST-MORTEM] P{severity} - {title}

Date: {date}
Duration: {duration}
Impact: {description}

Timeline:
- {time}: {event}
- {time}: {event}

Root Cause:
- {cause}

Resolution:
- {resolution}

Action Items:
- [ ] {action1}
- [ ] {action2}

Lessons Learned:
- {lesson1}
- {lesson2}
```

## Running Monitoring Commands

### Commands

```bash
# Start monitoring services
npm run monitoring:start

# Stop monitoring services
npm run monitoring:stop

# View metrics
npm run metrics:view

# Check alerts
npm run alerts:check

# View logs
npm run logs:view

# Run health check
npm run health:check
```

### CI/CD Integration

```yaml
# .github/workflows/monitoring.yml
name: Monitoring Setup

on:
  push:
    branches: [main]

jobs:
  monitoring:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup monitoring
        run: |
          npm run monitoring:setup
          
      - name: Deploy dashboards
        run: |
          npm run dashboards:deploy
          
      - name: Configure alerts
        run: |
          npm run alerts:configure
          
      - name: Verify monitoring
        run: |
          npm run monitoring:verify
```

## Best Practices

### 1. Monitoring Strategy
- Monitor what matters
- Set meaningful thresholds
- Use multiple alert channels
- Document runbooks

### 2. Alerting
- Avoid alert fatigue
- Use appropriate severity levels
- Include actionable information
- Test alerts regularly

### 3. Dashboards
- Keep dashboards simple
- Focus on key metrics
- Use consistent naming
- Share dashboards

### 4. On-Call
- Rotate on-call regularly
- Provide proper training
- Document procedures
- Conduct post-mortems

### 5. Continuous Improvement
- Review alerts regularly
- Update procedures
- Share knowledge
- Learn from incidents