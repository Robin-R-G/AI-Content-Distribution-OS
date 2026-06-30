# Regression Testing Guide

## Overview

Regression testing ensures that new changes don't break existing functionality, maintaining application stability through comprehensive test suites.

## Regression Test Suite

### Test Suite Structure

```typescript
// tests/regression/suite.config.ts
export const regressionSuite = {
  name: 'Regression Test Suite',
  description: 'Comprehensive regression tests for application stability',
  
  suites: {
    smoke: {
      name: 'Smoke Tests',
      description: 'Basic functionality verification',
      timeout: 30000,
      tests: [
        'health-check',
        'authentication',
        'core-navigation',
      ],
    },
    
    critical: {
      name: 'Critical Path Tests',
      description: 'Essential business workflows',
      timeout: 60000,
      tests: [
        'user-registration',
        'post-creation',
        'comment-system',
        'like-functionality',
        'user-profile',
      ],
    },
    
    full: {
      name: 'Full Regression Suite',
      description: 'Complete application testing',
      timeout: 300000,
      tests: [
        'all-api-endpoints',
        'all-ui-components',
        'all-user-flows',
        'all-integrations',
      ],
    },
  },
};
```

### Regression Test Implementation

```typescript
// tests/regression/smoke/smoke.test.ts
import request from 'supertest';
import app from '../../../src/app';

describe('Smoke Tests', () => {
  describe('Health Check', () => {
    it('should return health status', async () => {
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

    it('should check cache connection', async () => {
      const response = await request(app)
        .get('/api/health/cache');

      expect(response.status).toBe(200);
      expect(response.body.cache).toBe('connected');
    });
  });

  describe('Authentication', () => {
    it('should login with valid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123',
        });

      expect(response.status).toBe(200);
      expect(response.body.token).toBeDefined();
    });

    it('should reject invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
    });
  });

  describe('Core Navigation', () => {
    it('should access home page', async () => {
      const response = await request(app)
        .get('/');

      expect(response.status).toBe(200);
    });

    it('should access posts page', async () => {
      const response = await request(app)
        .get('/posts');

      expect(response.status).toBe(200);
    });
  });
});
```

## Smoke Tests

### Smoke Test Suite

```typescript
// tests/regression/smoke/smoke-suite.test.ts
import request from 'supertest';
import app from '../../../src/app';

describe('Smoke Test Suite', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'smoketest@example.com',
        password: 'password123',
      });

    authToken = loginResponse.body.token;
  });

  describe('API Endpoints', () => {
    it('should access all main endpoints', async () => {
      const endpoints = [
        '/api/health',
        '/api/posts',
        '/api/users/me',
        '/api/comments',
      ];

      for (const endpoint of endpoints) {
        const response = await request(app)
          .get(endpoint)
          .set('Authorization', `Bearer ${authToken}`);

        expect(response.status).toBeLessThan(500);
      }
    });
  });

  describe('Database Operations', () => {
    it('should perform basic CRUD operations', async () => {
      // Create
      const createResponse = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Smoke Test Post',
          content: 'Test content',
        });

      expect(createResponse.status).toBe(201);
      const postId = createResponse.body.id;

      // Read
      const readResponse = await request(app)
        .get(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(readResponse.status).toBe(200);

      // Update
      const updateResponse = await request(app)
        .put(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Smoke Test Post',
        });

      expect(updateResponse.status).toBe(200);

      // Delete
      const deleteResponse = await request(app)
        .delete(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(deleteResponse.status).toBe(204);
    });
  });

  describe('External Services', () => {
    it('should connect to external APIs', async () => {
      const response = await request(app)
        .get('/api/external/status')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.externalServices).toBeDefined();
    });
  });
});
```

## Critical Path Tests

### Critical Business Workflows

```typescript
// tests/regression/critical/user-registration.test.ts
import request from 'supertest';
import app from '../../../src/app';

describe('Critical Path: User Registration', () => {
  it('should complete full registration flow', async () => {
    // Step 1: Check email availability
    const emailCheckResponse = await request(app)
      .post('/api/auth/check-email')
      .send({ email: 'newuser@example.com' });

    expect(emailCheckResponse.status).toBe(200);
    expect(emailCheckResponse.body.available).toBe(true);

    // Step 2: Register user
    const registerResponse = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'newuser@example.com',
        password: 'SecurePass123!',
        name: 'New User',
      });

    expect(registerResponse.status).toBe(201);
    expect(registerResponse.body.token).toBeDefined();

    // Step 3: Verify email
    const verifyResponse = await request(app)
      .post('/api/auth/verify-email')
      .send({
        token: registerResponse.body.verificationToken,
      });

    expect(verifyResponse.status).toBe(200);

    // Step 4: Complete profile
    const profileResponse = await request(app)
      .put('/api/users/me/profile')
      .set('Authorization', `Bearer ${registerResponse.body.token}`)
      .send({
        bio: 'Hello, I am a new user!',
        location: 'New York',
      });

    expect(profileResponse.status).toBe(200);
  });
});

describe('Critical Path: Post Creation', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'testuser@example.com',
        password: 'password123',
      });

    authToken = loginResponse.body.token;
  });

  it('should create and publish post', async () => {
    // Step 1: Create draft
    const draftResponse = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Critical Path Post',
        content: 'This is a critical path test post.',
        status: 'draft',
      });

    expect(draftResponse.status).toBe(201);
    expect(draftResponse.body.status).toBe('draft');
    const postId = draftResponse.body.id;

    // Step 2: Add tags
    const tagResponse = await request(app)
      .post(`/api/posts/${postId}/tags`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        tags: ['test', 'critical-path'],
      });

    expect(tagResponse.status).toBe(200);

    // Step 3: Publish post
    const publishResponse = await request(app)
      .put(`/api/posts/${postId}/publish`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(publishResponse.status).toBe(200);
    expect(publishResponse.body.status).toBe('published');

    // Step 4: Verify post appears in feed
    const feedResponse = await request(app)
      .get('/api/feed')
      .set('Authorization', `Bearer ${authToken}`);

    expect(feedResponse.status).toBe(200);
    expect(feedResponse.body.posts).toContainEqual(
      expect.objectContaining({ id: postId })
    );
  });
});

describe('Critical Path: Comment System', () => {
  let authToken: string;
  let postId: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'testuser@example.com',
        password: 'password123',
      });

    authToken = loginResponse.body.token;

    const postResponse = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Comment Test Post',
        content: 'This post will have comments.',
      });

    postId = postResponse.body.id;
  });

  it('should add and reply to comments', async () => {
    // Step 1: Add comment
    const commentResponse = await request(app)
      .post(`/api/posts/${postId}/comments`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'This is a test comment.',
      });

    expect(commentResponse.status).toBe(201);
    const commentId = commentResponse.body.id;

    // Step 2: Reply to comment
    const replyResponse = await request(app)
      .post(`/api/posts/${postId}/comments/${commentId}/reply`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'This is a reply to the comment.',
      });

    expect(replyResponse.status).toBe(201);

    // Step 3: Get comments
    const getCommentsResponse = await request(app)
      .get(`/api/posts/${postId}/comments`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(getCommentsResponse.status).toBe(200);
    expect(getCommentsResponse.body.comments).toHaveLength(1);
  });
});
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/regression-tests.yml
name: Regression Tests

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  smoke:
    name: Smoke Tests
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run smoke tests
        run: npm run test:smoke

  critical:
    name: Critical Path Tests
    runs-on: ubuntu-latest
    needs: smoke
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run critical path tests
        run: npm run test:critical

  full:
    name: Full Regression Suite
    runs-on: ubuntu-latest
    needs: critical
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run full regression suite
        run: npm run test:regression
        
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: regression-test-results
          path: test-results/
```

### Test Selection Strategy

```typescript
// tests/regression/test-selector.ts
export const testSelector = {
  // Run smoke tests on every PR
  smoke: {
    trigger: 'pull_request',
    tests: ['health-check', 'authentication', 'core-navigation'],
    timeout: 30000,
  },

  // Run critical path tests on main branch
  critical: {
    trigger: 'push',
    branch: 'main',
    tests: ['user-registration', 'post-creation', 'comment-system'],
    timeout: 60000,
  },

  // Run full regression on schedule
  full: {
    trigger: 'schedule',
    cron: '0 2 * * 1', // Weekly on Monday at 2 AM
    tests: 'all',
    timeout: 300000,
  },

  // Run specific tests based on changed files
  targeted: {
    trigger: 'pull_request',
    rules: [
      {
        files: ['src/api/**'],
        tests: ['api-endpoints'],
      },
      {
        files: ['src/components/**'],
        tests: ['ui-components'],
      },
      {
        files: ['src/services/**'],
        tests: ['business-logic'],
      },
    ],
  },
};
```

### Test Configuration

```typescript
// vitest.config.regression.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./tests/regression/setup.ts'],
    testTimeout: 30000,
    hookTimeout: 30000,
    include: ['tests/regression/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/**/*.spec.ts'],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
    },
    reporters: [
      'default',
      'json',
      'html',
    ],
    outputFile: {
      json: './test-results/regression-results.json',
      html: './test-results/regression-report.html',
    },
  },
});
```

## Running Regression Tests

### Commands

```bash
# Run smoke tests
npm run test:smoke

# Run critical path tests
npm run test:critical

# Run full regression suite
npm run test:regression

# Run targeted regression tests
npm run test:regression:targeted

# Run regression tests with coverage
npm run test:regression:coverage
```

### Local Development

```bash
# Run regression tests before commit
npm run test:regression:quick

# Run specific regression test
npm run test:regression -- --grep "User Registration"

# Run regression tests in watch mode
npm run test:regression:watch
```

## Best Practices

### 1. Test Maintenance
- Regular review and update of regression tests
- Remove obsolete tests
- Update test data and fixtures

### 2. Test Selection
- Use smart test selection based on changes
- Prioritize critical path tests
- Run full regression on schedule

### 3. Test Environment
- Use production-like environment
- Isolate test data
- Monitor test execution

### 4. Reporting
- Generate comprehensive reports
- Track test results over time
- Share results with stakeholders

### 5. Continuous Improvement
- Analyze test failures
- Optimize test execution
- Update test strategies