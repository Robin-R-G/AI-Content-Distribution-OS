# Production Logging Guide

## Overview

This guide covers production logging, including log aggregation, search and analysis, retention policies, and debugging production issues.

## Log Aggregation

### Logging Configuration

```typescript
// src/config/logging.ts
export const loggingConfig = {
  level: process.env.LOG_LEVEL || 'info',
  format: process.env.NODE_ENV === 'production' ? 'json' : 'pretty',
  transports: ['console', 'file', 'external'],
  
  console: {
    level: 'info',
    format: 'pretty',
  },
  
  file: {
    level: 'debug',
    filename: 'logs/app.log',
    maxSize: '10m',
    maxFiles: '14d',
    datePattern: 'YYYY-MM-DD',
  },
  
  external: {
    level: 'info',
    service: 'social-media-ai',
    environment: process.env.NODE_ENV,
  },
};
```

### Winston Logger Implementation

```typescript
// src/logger/index.ts
import winston from 'winston';
import { loggingConfig } from '../config/logging';

const { combine, timestamp, errors, json, printf, colorize } = winston.format;

// Custom format for development
const devFormat = printf(({ level, message, timestamp, stack, ...metadata }) => {
  let msg = `${timestamp} [${level}]: ${message}`;
  if (stack) {
    msg += `\n${stack}`;
  }
  if (Object.keys(metadata).length > 0) {
    msg += `\n${JSON.stringify(metadata, null, 2)}`;
  }
  return msg;
});

// Create logger
export const logger = winston.createLogger({
  level: loggingConfig.level,
  format: combine(
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    errors({ stack: true }),
    json()
  ),
  defaultMeta: {
    service: 'social-media-ai',
    environment: process.env.NODE_ENV,
  },
  transports: [
    // Console transport
    new winston.transports.Console({
      format: process.env.NODE_ENV === 'production'
        ? combine(json())
        : combine(colorize(), devFormat),
    }),
    
    // File transport
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 10 * 1024 * 1024, // 10MB
      maxFiles: 5,
    }),
    
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 10 * 1024 * 1024, // 10MB
      maxFiles: 14,
    }),
  ],
  exceptionHandlers: [
    new winston.transports.File({ filename: 'logs/exceptions.log' }),
  ],
  rejectionHandlers: [
    new winston.transports.File({ filename: 'logs/rejections.log' }),
  ],
});

// Stream for Morgan (HTTP logging)
export const loggerStream = {
  write: (message: string) => {
    logger.http(message.trim());
  },
};

// Request logging middleware
export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: (req as any).userId,
    };
    
    if (res.statusCode >= 400) {
      logger.error('Request failed', logData);
    } else if (res.statusCode >= 300) {
      logger.warn('Request redirected', logData);
    } else {
      logger.info('Request completed', logData);
    }
  });
  
  next();
}

// Error logging middleware
export function errorLogger(err: Error, req: Request, res: Response, next: NextFunction) {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    method: req.method,
    url: req.originalUrl,
    userId: (req as any).userId,
  });
  
  next(err);
}
```

### Structured Logging

```typescript
// src/logger/structured.ts
import { logger } from './index';

export class StructuredLogger {
  private context: Record<string, any>;

  constructor(context: Record<string, any> = {}) {
    this.context = context;
  }

  info(message: string, metadata: Record<string, any> = {}): void {
    logger.info(message, {
      ...this.context,
      ...metadata,
      timestamp: new Date().toISOString(),
    });
  }

  warn(message: string, metadata: Record<string, any> = {}): void {
    logger.warn(message, {
      ...this.context,
      ...metadata,
      timestamp: new Date().toISOString(),
    });
  }

  error(message: string, error?: Error, metadata: Record<string, any> = {}): void {
    logger.error(message, {
      ...this.context,
      ...metadata,
      error: error ? {
        message: error.message,
        stack: error.stack,
        name: error.name,
      } : undefined,
      timestamp: new Date().toISOString(),
    });
  }

  debug(message: string, metadata: Record<string, any> = {}): void {
    logger.debug(message, {
      ...this.context,
      ...metadata,
      timestamp: new Date().toISOString(),
    });
  }

  child(context: Record<string, any>): StructuredLogger {
    return new StructuredLogger({
      ...this.context,
      ...context,
    });
  }
}

// Usage examples
export const apiLogger = new StructuredLogger({ component: 'api' });
export const dbLogger = new StructuredLogger({ component: 'database' });
export const authLogger = new StructuredLogger({ component: 'auth' });
export const aiLogger = new StructuredLogger({ component: 'ai' });
```

### Log Types

```typescript
// src/logger/log-types.ts
export enum LogLevel {
  ERROR = 'error',
  WARN = 'warn',
  INFO = 'info',
  HTTP = 'http',
  DEBUG = 'debug',
}

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  context?: string;
  metadata?: Record<string, any>;
  error?: {
    name: string;
    message: string;
    stack?: string;
  };
  request?: {
    method: string;
    url: string;
    ip: string;
    userAgent: string;
    userId?: string;
  };
  response?: {
    statusCode: number;
    duration: number;
  };
}

export interface AuditLog {
  timestamp: string;
  userId: string;
  action: string;
  resource: string;
  resourceId: string;
  changes?: Record<string, any>;
  ip: string;
  userAgent: string;
}

export interface SecurityLog {
  timestamp: string;
  type: 'authentication' | 'authorization' | 'validation' | 'rate_limit';
  userId?: string;
  ip: string;
  userAgent: string;
  details: Record<string, any>;
}
```

## Search and Analysis

### ELK Stack Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - 9200:9200
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    container_name: logstash
    ports:
      - 5000:5000
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    container_name: kibana
    ports:
      - 5601:5601
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch-data:
```

### Logstash Pipeline

```ruby
# logstash/pipeline/logstash.conf
input {
  beats {
    port => 5000
  }
  
  tcp {
    port => 5001
    codec => json
  }
}

filter {
  if [type] == "application" {
    json {
      source => "message"
      target => "parsed"
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    mutate {
      add_field => { "environment" => "%{[parsed][environment]}" }
      add_field => { "service" => "%{[parsed][service]}" }
    }
  }
  
  if [type] == "access" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
    
    geoip {
      source => "clientip"
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

### Kibana Dashboards

```json
// kibana/dashboards/application-logs.json
{
  "objects": [
    {
      "attributes": {
        "title": "Application Logs",
        "visState": {
          "title": "Log Level Distribution",
          "aggs": [
            {
              "id": "1",
              "type": "count",
              "params": {}
            }
          ]
        }
      }
    },
    {
      "attributes": {
        "title": "Error Logs",
        "visState": {
          "title": "Error Logs Over Time",
          "aggs": [
            {
              "id": "1",
              "type": "date_histogram",
              "params": {
                "field": "timestamp",
                "interval": "auto"
              }
            }
          ]
        }
      }
    },
    {
      "attributes": {
        "title": "Request Logs",
        "visState": {
          "title": "Request Distribution",
          "aggs": [
            {
              "id": "1",
              "type": "terms",
              "params": {
                "field": "request.method"
              }
            }
          ]
        }
      }
    }
  ]
}
```

### Log Analysis Scripts

```typescript
// scripts/analyze-logs.ts
import { Client } from '@elastic/elasticsearch';

const client = new Client({ node: 'http://localhost:9200' });

export async function analyzeLogs(timeRange: string = '1h') {
  console.log(`Analyzing logs for the last ${timeRange}...`);

  // Get error rate
  const errorRate = await client.search({
    index: 'logs-*',
    body: {
      query: {
        bool: {
          must: [
            {
              range: {
                timestamp: {
                  gte: `now-${timeRange}`,
                },
              },
            },
            {
              term: {
                level: 'error',
              },
            },
          ],
        },
      },
      aggs: {
        errors_over_time: {
          date_histogram: {
            field: 'timestamp',
            fixed_interval: '1m',
          },
        },
      },
    },
  });

  console.log('Error rate:', errorRate.aggregations?.errors_over_time.buckets);

  // Get slow requests
  const slowRequests = await client.search({
    index: 'logs-*',
    body: {
      query: {
        bool: {
          must: [
            {
              range: {
                timestamp: {
                  gte: `now-${timeRange}`,
                },
              },
            },
            {
              range: {
                'response.duration': {
                  gte: 1000,
                },
              },
            },
          ],
        },
      },
      sort: [{ 'response.duration': { order: 'desc' } }],
      size: 10,
    },
  });

  console.log('Slow requests:', slowRequests.hits.hits);

  // Get most common errors
  const commonErrors = await client.search({
    index: 'logs-*',
    body: {
      query: {
        bool: {
          must: [
            {
              range: {
                timestamp: {
                  gte: `now-${timeRange}`,
                },
              },
            },
            {
              term: {
                level: 'error',
              },
            },
          ],
        },
      },
      aggs: {
        error_messages: {
          terms: {
            field: 'message.keyword',
            size: 10,
          },
        },
      },
    },
  });

  console.log('Common errors:', commonErrors.aggregations?.error_messages.buckets);

  // Get requests by endpoint
  const requestsByEndpoint = await client.search({
    index: 'logs-*',
    body: {
      query: {
        range: {
          timestamp: {
            gte: `now-${timeRange}`,
          },
        },
      },
      aggs: {
        endpoints: {
          terms: {
            field: 'request.url.keyword',
            size: 20,
          },
          aggs: {
            avg_duration: {
              avg: {
                field: 'response.duration',
              },
            },
          },
        },
      },
    },
  });

  console.log('Requests by endpoint:', requestsByEndpoint.aggregations?.endpoints.buckets);
}
```

## Retention Policies

### Log Retention Configuration

```typescript
// src/config/retention.ts
export const retentionConfig = {
  logs: {
    application: {
      retentionDays: 30,
      archiveAfterDays: 7,
      compressionEnabled: true,
    },
    access: {
      retentionDays: 90,
      archiveAfterDays: 30,
      compressionEnabled: true,
    },
    audit: {
      retentionDays: 365,
      archiveAfterDays: 90,
      compressionEnabled: true,
    },
    security: {
      retentionDays: 365,
      archiveAfterDays: 90,
      compressionEnabled: true,
    },
  },
  
  storage: {
    hot: {
      retentionDays: 7,
      storageType: 'ssd',
    },
    warm: {
      retentionDays: 30,
      storageType: 'hdd',
    },
    cold: {
      retentionDays: 90,
      storageType: 'archive',
    },
  },
  
  cleanup: {
    schedule: '0 2 * * *', // Daily at 2 AM
    enabled: true,
  },
};
```

### Retention Script

```typescript
// scripts/retention.ts
import { Client } from '@elastic/elasticsearch';
import { retentionConfig } from '../src/config/retention';

const client = new Client({ node: 'http://localhost:9200' });

export async function enforceRetention() {
  console.log('Enforcing log retention policies...');

  for (const [logType, config] of Object.entries(retentionConfig.logs)) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - config.retentionDays);

    console.log(`Cleaning ${logType} logs older than ${cutoffDate.toISOString()}`);

    try {
      const result = await client.deleteByQuery({
        index: `logs-${logType}-*`,
        body: {
          query: {
            range: {
              timestamp: {
                lt: cutoffDate.toISOString(),
              },
            },
          },
        },
      });

      console.log(`Deleted ${result.deleted} ${logType} logs`);
    } catch (error) {
      console.error(`Error cleaning ${logType} logs:`, error);
    }
  }
}

export async function archiveOldLogs() {
  console.log('Archiving old logs...');

  for (const [logType, config] of Object.entries(retentionConfig.logs)) {
    if (!config.archiveAfterDays) continue;

    const archiveDate = new Date();
    archiveDate.setDate(archiveDate.getDate() - config.archiveAfterDays);

    console.log(`Archiving ${logType} logs older than ${archiveDate.toISOString()}`);

    try {
      // Create archive index
      const archiveIndex = `logs-${logType}-archive-${archiveDate.getFullYear()}-${archiveDate.getMonth() + 1}`;
      
      await client.indices.create({
        index: archiveIndex,
        body: {
          settings: {
            number_of_shards: 1,
            number_of_replicas: 0,
          },
        },
      });

      // Reindex to archive
      await client.reindex({
        source: {
          index: `logs-${logType}-*`,
          query: {
            bool: {
              must: [
                {
                  range: {
                    timestamp: {
                      lt: archiveDate.toISOString(),
                    },
                  },
                },
              ],
            },
          },
        },
        dest: {
          index: archiveIndex,
        },
      });

      // Delete original logs
      await client.deleteByQuery({
        index: `logs-${logType}-*`,
        body: {
          query: {
            range: {
              timestamp: {
                lt: archiveDate.toISOString(),
              },
            },
          },
        },
      });

      console.log(`Archived ${logType} logs to ${archiveIndex}`);
    } catch (error) {
      console.error(`Error archiving ${logType} logs:`, error);
    }
  }
}
```

### Cron Job for Retention

```typescript
// src/jobs/retention.job.ts
import cron from 'node-cron';
import { enforceRetention, archiveOldLogs } from '../../scripts/retention';

export function startRetentionJob() {
  // Run daily at 2 AM
  cron.schedule('0 2 * * *', async () => {
    console.log('Starting retention job...');
    
    try {
      await enforceRetention();
      await archiveOldLogs();
      console.log('Retention job completed successfully');
    } catch (error) {
      console.error('Retention job failed:', error);
    }
  });

  console.log('Retention job scheduled');
}
```

## Debugging Production Issues

### Debugging Tools

```typescript
// src/debug/index.ts
import { logger } from '../logger';

export class DebugTools {
  static async inspectRequest(req: Request) {
    const debugInfo = {
      method: req.method,
      url: req.originalUrl,
      headers: req.headers,
      query: req.query,
      body: req.body,
      ip: req.ip,
      userId: (req as any).userId,
      timestamp: new Date().toISOString(),
    };

    logger.debug('Request inspection', debugInfo);
    return debugInfo;
  }

  static async inspectResponse(res: Response) {
    const debugInfo = {
      statusCode: res.statusCode,
      headers: res.getHeaders(),
      timestamp: new Date().toISOString(),
    };

    logger.debug('Response inspection', debugInfo);
    return debugInfo;
  }

  static async inspectDatabase(query: string, params: any[]) {
    const debugInfo = {
      query,
      params,
      timestamp: new Date().toISOString(),
    };

    logger.debug('Database inspection', debugInfo);
    return debugInfo;
  }

  static async inspectCache(key: string) {
    const debugInfo = {
      key,
      timestamp: new Date().toISOString(),
    };

    logger.debug('Cache inspection', debugInfo);
    return debugInfo;
  }

  static async generateReport(timeRange: string = '1h') {
    const report = {
      timeRange,
      timestamp: new Date().toISOString(),
      system: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        cpu: process.cpuUsage(),
      },
    };

    logger.info('Debug report generated', report);
    return report;
  }
}
```

### Debug Endpoints

```typescript
// src/routes/debug.ts
import { Router } from 'express';
import { DebugTools } from '../debug';
import { logger } from '../logger';

const router = Router();

// Only enable in development/staging
if (process.env.NODE_ENV !== 'production') {
  router.get('/debug/health', async (req, res) => {
    const health = await DebugTools.generateReport();
    res.json(health);
  });

  router.get('/debug/logs', async (req, res) => {
    const { level, limit } = req.query;
    // Fetch recent logs
    res.json({ logs: [] });
  });

  router.post('/debug/inspect', async (req, res) => {
    const { type, id } = req.body;
    // Inspect specific resource
    res.json({ inspection: {} });
  });
}

export default router;
```

### Production Debugging Guide

```markdown
## Production Debugging Guide

### Step 1: Identify the Issue
1. Check error tracking (Sentry, etc.)
2. Review recent deployments
3. Check monitoring dashboards
4. Review logs for errors

### Step 2: Gather Information
1. Collect error messages
2. Gather user reports
3. Check system metrics
4. Review recent changes

### Step 3: Analyze Logs
1. Search for error patterns
2. Check request/response logs
3. Review database queries
4. Check external service calls

### Step 4: Reproduce the Issue
1. Identify reproduction steps
2. Test in staging environment
3. Verify with same conditions
4. Document reproduction steps

### Step 5: Fix and Verify
1. Implement fix
2. Test in staging
3. Deploy to production
4. Verify resolution

### Step 6: Document and Learn
1. Document root cause
2. Update runbooks
3. Share knowledge
4. Prevent recurrence
```

### Log Query Examples

```typescript
// scripts/query-logs.ts
import { Client } from '@elastic/elasticsearch';

const client = new Client({ node: 'http://localhost:9200' });

export async function queryLogs() {
  // Get all errors in the last hour
  const errors = await client.search({
    index: 'logs-*',
    body: {
      query: {
        bool: {
          must: [
            {
              range: {
                timestamp: {
                  gte: 'now-1h',
                },
              },
            },
            {
              term: {
                level: 'error',
              },
            },
          ],
        },
      },
      sort: [{ timestamp: { order: 'desc' } }],
      size: 100,
    },
  });

  console.log('Recent errors:', errors.hits.hits);

  // Get slow requests
  const slowRequests = await client.search({
    index: 'logs-*',
    body: {
      query: {
        bool: {
          must: [
            {
              range: {
                timestamp: {
                  gte: 'now-1h',
                },
              },
            },
            {
              range: {
                'response.duration': {
                  gte: 1000,
                },
              },
            },
          ],
        },
      },
      sort: [{ 'response.duration': { order: 'desc' } }],
      size: 50,
    },
  });

  console.log('Slow requests:', slowRequests.hits.hits);

  // Get logs for specific user
  const userLogs = await client.search({
    index: 'logs-*',
    body: {
      query: {
        bool: {
          must: [
            {
              range: {
                timestamp: {
                  gte: 'now-24h',
                },
              },
            },
            {
              term: {
                'request.userId': 'user-123',
              },
            },
          ],
        },
      },
      sort: [{ timestamp: { order: 'desc' } }],
      size: 100,
    },
  });

  console.log('User logs:', userLogs.hits.hits);
}
```

## Running Logging Commands

### Commands

```bash
# View logs
npm run logs:view

# Search logs
npm run logs:search "error"

# Analyze logs
npm run logs:analyze

# Clean old logs
npm run logs:clean

# Archive logs
npm run logs:archive

# Export logs
npm run logs:export
```

### CI/CD Integration

```yaml
# .github/workflows/logging.yml
name: Logging Setup

on:
  push:
    branches: [main]

jobs:
  logging:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup logging
        run: |
          npm run logging:setup
          
      - name: Deploy log aggregation
        run: |
          npm run logging:deploy
          
      - name: Configure retention
        run: |
          npm run logging:retention
          
      - name: Verify logging
        run: |
          npm run logging:verify
```

## Best Practices

### 1. Log Structure
- Use structured logging
- Include context information
- Use consistent formats
- Avoid sensitive data

### 2. Log Levels
- Use appropriate log levels
- Don't log sensitive information
- Include useful context
- Keep logs concise

### 3. Log Management
- Implement log rotation
- Set up retention policies
- Monitor log volume
- Archive old logs

### 4. Debugging
- Use correlation IDs
- Include request context
- Log important events
- Document debugging procedures

### 5. Performance
- Async logging
- Batch log shipping
- Optimize log queries
- Monitor logging performance