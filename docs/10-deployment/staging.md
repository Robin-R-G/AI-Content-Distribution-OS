# Staging Environment Guide

## Overview

The staging environment is a pre-production environment used for final testing, UAT, and validation before production deployment.

## Purpose and Setup

### Purpose

```markdown
## Staging Environment Purpose

### Primary Objectives
1. **Final Validation**: Last check before production deployment
2. **UAT Environment**: User acceptance testing
3. **Integration Testing**: Verify all integrations work
4. **Performance Testing**: Load and stress testing
5. **Security Testing**: Final security validation

### Key Characteristics
- Mirrors production configuration
- Uses production-like data
- Accessible to stakeholders
- Monitored and logged
- Isolated from production
```

### Setup Process

```bash
# Staging environment setup

# 1. Clone production configuration
cp -r config/production config/staging

# 2. Update environment variables
cp .env.staging .env

# 3. Deploy to staging
npm run deploy:staging

# 4. Run database migrations
npm run db:migrate:staging

# 5. Seed staging data
npm run db:seed:staging

# 6. Verify deployment
npm run verify:staging
```

### Staging Configuration

```typescript
// src/config/staging.ts
export const stagingConfig = {
  app: {
    name: 'Social Media AI - Staging',
    url: process.env.STAGING_URL || 'https://staging.socialmediaai.com',
    port: parseInt(process.env.PORT || '3000'),
  },
  
  database: {
    url: process.env.STAGING_DB_URL,
    ssl: true,
    poolSize: 10,
  },
  
  redis: {
    url: process.env.STAGING_REDIS_URL,
  },
  
  supabase: {
    url: process.env.STAGING_SUPABASE_URL,
    anonKey: process.env.STAGING_SUPABASE_ANON_KEY,
    serviceRoleKey: process.env.STAGING_SUPABASE_SERVICE_ROLE_KEY,
  },
  
  ai: {
    apiKey: process.env.STAGING_AI_API_KEY,
    model: 'gpt-4',
  },
  
  email: {
    host: process.env.STAGING_SMTP_HOST,
    port: parseInt(process.env.STAGING_SMTP_PORT || '587'),
    secure: true,
  },
  
  storage: {
    bucket: process.env.STAGING_STORAGE_BUCKET,
    endpoint: process.env.STAGING_STORAGE_ENDPOINT,
  },
  
  logging: {
    level: 'info',
    format: 'json',
  },
  
  features: {
    enableAI: true,
    enableAnalytics: true,
    enableNotifications: true,
  },
};
```

## Data Seeding

### Staging Data Strategy

```typescript
// scripts/seed-staging.ts
import { DataSource } from 'typeorm';
import { User } from '../src/entities/User';
import { Post } from '../src/entities/Post';
import { Comment } from '../src/entities/Comment';

export async function seedStagingData(dataSource: DataSource): Promise<void> {
  console.log('Seeding staging data...');
  
  const userRepository = dataSource.getRepository(User);
  const postRepository = dataSource.getRepository(Post);
  const commentRepository = dataSource.getRepository(Comment);

  // Create test users
  const users = await userRepository.save([
    {
      email: 'admin@staging.com',
      name: 'Staging Admin',
      password: 'hashed_password',
      role: 'admin',
      isTestData: true,
    },
    {
      email: 'user1@staging.com',
      name: 'Staging User 1',
      password: 'hashed_password',
      role: 'user',
      isTestData: true,
    },
    {
      email: 'user2@staging.com',
      name: 'Staging User 2',
      password: 'hashed_password',
      role: 'user',
      isTestData: true,
    },
    {
      email: 'test@staging.com',
      name: 'Test User',
      password: 'password123',
      role: 'user',
      isTestData: true,
    },
  ]);

  // Create test posts
  const posts = await postRepository.save([
    {
      title: 'Welcome to Staging',
      content: 'This is a test post in the staging environment.',
      author: users[0],
      status: 'published',
      isTestData: true,
    },
    {
      title: 'Test Post 1',
      content: 'This is test post 1 content for staging.',
      author: users[1],
      status: 'published',
      isTestData: true,
    },
    {
      title: 'Test Post 2',
      content: 'This is test post 2 content for staging.',
      author: users[2],
      status: 'published',
      isTestData: true,
    },
    {
      title: 'Draft Post',
      content: 'This is a draft post in staging.',
      author: users[0],
      status: 'draft',
      isTestData: true,
    },
  ]);

  // Create test comments
  await commentRepository.save([
    {
      content: 'Great post!',
      author: users[1],
      post: posts[0],
      isTestData: true,
    },
    {
      content: 'Thanks for sharing!',
      author: users[2],
      post: posts[1],
      isTestData: true,
    },
    {
      content: 'Very informative.',
      author: users[0],
      post: posts[2],
      isTestData: true,
    },
  ]);

  console.log('Staging data seeded successfully');
}
```

### Staging Data Management

```bash
# Staging data commands

# Seed staging data
npm run db:seed:staging

# Clean staging data
npm run db:clean:staging

# Reset staging data
npm run db:reset:staging

# Backup staging data
npm run db:backup:staging

# Restore staging data
npm run db:restore:staging
```

### Data Anonymization

```typescript
// scripts/anonymize-staging-data.ts
import { DataSource } from 'typeorm';
import { faker } from '@faker-js/faker';

export async function anonymizeStagingData(dataSource: DataSource): Promise<void> {
  console.log('Anonymizing staging data...');
  
  const userRepository = dataSource.getRepository(User);
  const postRepository = dataSource.getRepository(Post);
  const commentRepository = dataSource.getRepository(Comment);

  // Anonymize users
  const users = await userRepository.find();
  for (const user of users) {
    user.email = faker.internet.email();
    user.name = faker.person.fullName();
    user.password = 'hashed_password';
    await userRepository.save(user);
  }

  // Anonymize posts
  const posts = await postRepository.find();
  for (const post of posts) {
    post.title = faker.lorem.sentence();
    post.content = faker.lorem.paragraphs(2);
    await postRepository.save(post);
  }

  // Anonymize comments
  const comments = await commentRepository.find();
  for (const comment of comments) {
    comment.content = faker.lorem.sentence();
    await commentRepository.save(comment);
  }

  console.log('Staging data anonymized successfully');
}
```

## Testing in Staging

### Staging Test Suite

```typescript
// tests/staging/staging.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('Staging Environment Tests', () => {
  describe('Health Checks', () => {
    it('should return healthy status', async () => {
      const response = await request(app)
        .get('/api/health');

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
    });

    it('should check database connection', async () => {
      const response = await request(app)
        .get('/api/health/db');

      expect(response.status).toBe(200);
      expect(response.body.database).toBe('connected');
    });
  });

  describe('API Endpoints', () => {
    it('should access all main endpoints', async () => {
      const endpoints = [
        '/api/posts',
        '/api/users/me',
        '/api/health',
      ];

      for (const endpoint of endpoints) {
        const response = await request(app)
          .get(endpoint)
          .set('Authorization', `Bearer ${stagingToken}`);

        expect(response.status).toBeLessThan(500);
      }
    });
  });

  describe('External Integrations', () => {
    it('should connect to AI services', async () => {
      const response = await request(app)
        .post('/api/ai/generate')
        .set('Authorization', `Bearer ${stagingToken}`)
        .send({
          prompt: 'Test prompt',
          maxTokens: 100,
        });

      expect(response.status).toBe(200);
      expect(response.body.text).toBeDefined();
    });

    it('should connect to email service', async () => {
      const response = await request(app)
        .post('/api/email/send')
        .set('Authorization', `Bearer ${stagingToken}`)
        .send({
          to: 'test@staging.com',
          subject: 'Test Email',
          body: 'Test email body',
        });

      expect(response.status).toBe(200);
    });
  });
});
```

### Performance Testing

```javascript
// tests/staging/load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.1'],
  },
};

export default function () {
  const response = http.get('https://staging.socialmediaai.com/api/posts');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

### Security Testing

```typescript
// tests/staging/security.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('Staging Security Tests', () => {
  describe('Authentication', () => {
    it('should reject invalid tokens', async () => {
      const response = await request(app)
        .get('/api/posts')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
    });

    it('should enforce rate limiting', async () => {
      const requests = Array(100).fill(null).map(() =>
        request(app)
          .get('/api/posts')
          .set('Authorization', `Bearer ${stagingToken}`)
      );

      const responses = await Promise.all(requests);
      const rateLimited = responses.some(r => r.status === 429);

      expect(rateLimited).toBe(true);
    });
  });

  describe('Input Validation', () => {
    it('should prevent SQL injection', async () => {
      const response = await request(app)
        .get('/api/posts/search?q=1%27%20OR%201%3D1--')
        .set('Authorization', `Bearer ${stagingToken}`);

      expect(response.status).toBe(200);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('should prevent XSS', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${stagingToken}`)
        .send({
          title: '<script>alert("xss")</script>',
          content: 'Test content',
        });

      expect(response.status).toBe(201);
      expect(response.body.title).not.toContain('<script>');
    });
  });
});
```

## Monitoring

### Staging Monitoring Setup

```typescript
// src/monitoring/staging.ts
export const stagingMonitoring = {
  metrics: {
    enabled: true,
    endpoint: '/metrics',
    labels: {
      environment: 'staging',
    },
  },
  
  logging: {
    level: 'info',
    format: 'json',
    transports: ['console', 'file'],
    filename: 'logs/staging.log',
  },
  
  tracing: {
    enabled: true,
    serviceName: 'social-media-ai-staging',
    endpoint: process.env.JAEGER_ENDPOINT,
  },
  
  alerting: {
    enabled: true,
    rules: [
      {
        name: 'High Error Rate',
        condition: 'error_rate > 0.05',
        duration: '5m',
        severity: 'critical',
      },
      {
        name: 'High Response Time',
        condition: 'response_time_p95 > 1000',
        duration: '5m',
        severity: 'warning',
      },
    ],
  },
};
```

### Staging Alerts

```yaml
# alerting/staging.yml
groups:
  - name: staging
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
          environment: staging
        annotations:
          summary: High error rate in staging
          description: Error rate is {{ $value }}%
          
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
          environment: staging
        annotations:
          summary: High response time in staging
          description: P95 response time is {{ $value }}s
          
      - alert: ServiceDown
        expr: up{job="social-media-ai-staging"} == 0
        for: 1m
        labels:
          severity: critical
          environment: staging
        annotations:
          summary: Service down in staging
          description: Service is down in staging environment
```

### Monitoring Dashboard

```json
// dashboards/staging.json
{
  "dashboard": {
    "title": "Staging Environment Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P95"
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
          }
        ]
      },
      {
        "title": "Active Users",
        "type": "singlestat",
        "targets": [
          {
            "expr": "active_users{environment=\"staging\"}",
            "legendFormat": "Users"
          }
        ]
      }
    ]
  }
}
```

## Staging Workflow

### Daily Staging Operations

```bash
# Daily staging operations

# 1. Check staging health
npm run health:staging

# 2. Review staging logs
npm run logs:staging

# 3. Check staging metrics
npm run metrics:staging

# 4. Clean staging data (if needed)
npm run db:clean:staging

# 5. Seed fresh data (if needed)
npm run db:seed:staging

# 6. Run staging tests
npm run test:staging
```

### Staging Deployment Process

```markdown
## Staging Deployment Process

### Pre-Deployment
1. [ ] Code review completed
2. [ ] All tests passing
3. [ ] Security scan completed
4. [ ] Performance tests passed
5. [ ] Stakeholders notified

### Deployment
1. [ ] Deploy to staging
2. [ ] Run database migrations
3. [ ] Seed test data
4. [ ] Verify deployment
5. [ ] Run smoke tests

### Post-Deployment
1. [ ] Monitor for issues
2. [ ] Run full test suite
3. [ ] Perform UAT
4. [ ] Get stakeholder sign-off
5. [ ] Schedule production deployment
```

## Running Staging Commands

### Commands

```bash
# Deploy to staging
npm run deploy:staging

# Run staging tests
npm run test:staging

# Check staging health
npm run health:staging

# View staging logs
npm run logs:staging

# Clean staging data
npm run db:clean:staging

# Seed staging data
npm run db:seed:staging

# Rollback staging
npm run rollback:staging
```

### CI/CD Integration

```yaml
# .github/workflows/staging.yml
name: Staging Deployment

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      action:
        description: 'Action to perform'
        required: true
        type: choice
        options:
          - deploy
          - rollback
          - seed
          - clean

jobs:
  staging:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Deploy to staging
        if: github.event.inputs.action == 'deploy' || github.event_name == 'push'
        run: npm run deploy:staging
        
      - name: Seed staging data
        if: github.event.inputs.action == 'seed'
        run: npm run db:seed:staging
        
      - name: Clean staging data
        if: github.event.inputs.action == 'clean'
        run: npm run db:clean:staging
        
      - name: Rollback staging
        if: github.event.inputs.action == 'rollback'
        run: npm run rollback:staging
        
      - name: Run staging tests
        run: npm run test:staging
```

## Best Practices

### 1. Environment Parity
- Keep staging as close to production as possible
- Use same configurations and dependencies
- Test with production-like data

### 2. Data Management
- Regularly refresh staging data
- Anonymize sensitive data
- Use realistic data volumes

### 3. Testing
- Run comprehensive test suite
- Perform regular security scans
- Monitor performance metrics

### 4. Monitoring
- Set up proper alerting
- Monitor key metrics
- Review logs regularly

### 5. Communication
- Notify stakeholders of deployments
- Document issues and resolutions
- Share test results