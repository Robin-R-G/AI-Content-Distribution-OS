# API Endpoint Testing Guide

## Overview

API tests verify that endpoints work correctly, including request/response validation, authentication, authorization, rate limiting, and error handling.

## Request/Response Validation

### Schema Validation Testing

```typescript
// tests/api/validation.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('API Validation', () => {
  describe('POST /api/posts', () => {
    it('should accept valid post data', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          title: 'Valid Post Title',
          content: 'This is valid content',
          tags: ['test', 'example'],
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.title).toBe('Valid Post Title');
    });

    it('should reject missing required fields', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          content: 'Missing title',
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'title',
          message: 'Title is required',
        })
      );
    });

    it('should reject invalid field types', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          title: 123, // Should be string
          content: 'Valid content',
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'title',
          message: 'Title must be a string',
        })
      );
    });

    it('should enforce field length limits', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          title: 'a'.repeat(256), // Max 255 chars
          content: 'Valid content',
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'title',
          message: 'Title must be 255 characters or less',
        })
      );
    });
  });
});
```

### Response Format Testing

```typescript
describe('Response Format', () => {
  it('should return consistent response structure', async () => {
    const response = await request(app)
      .get('/api/posts')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('data');
    expect(response.body).toHaveProperty('meta');
    expect(response.body.meta).toHaveProperty('total');
    expect(response.body.meta).toHaveProperty('page');
    expect(response.body.meta).toHaveProperty('limit');
  });

  it('should include proper headers', async () => {
    const response = await request(app)
      .get('/api/posts')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.headers['content-type']).toMatch(/application\/json/);
    expect(response.headers['x-request-id']).toBeDefined();
  });
});
```

## Authentication Testing

### Token Validation

```typescript
describe('Authentication', () => {
  describe('JWT Token', () => {
    it('should accept valid JWT token', async () => {
      const response = await request(app)
        .get('/api/posts')
        .set('Authorization', `Bearer ${validToken}`);

      expect(response.status).toBe(200);
    });

    it('should reject expired token', async () => {
      const expiredToken = generateExpiredToken();
      const response = await request(app)
        .get('/api/posts')
        .set('Authorization', `Bearer ${expiredToken}`);

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Token expired');
    });

    it('should reject invalid token', async () => {
      const response = await request(app)
        .get('/api/posts')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid token');
    });

    it('should reject missing token', async () => {
      const response = await request(app)
        .get('/api/posts');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Authentication required');
    });

    it('should reject malformed Authorization header', async () => {
      const response = await request(app)
        .get('/api/posts')
        .set('Authorization', 'InvalidFormat token');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid authorization format');
    });
  });
});
```

### API Key Validation

```typescript
describe('API Key Authentication', () => {
  it('should accept valid API key', async () => {
    const response = await request(app)
      .get('/api/public/data')
      .set('X-API-Key', validApiKey);

    expect(response.status).toBe(200);
  });

  it('should reject invalid API key', async () => {
    const response = await request(app)
      .get('/api/public/data')
      .set('X-API-Key', 'invalid-key');

    expect(response.status).toBe(401);
    expect(response.body.error).toBe('Invalid API key');
  });

  it('should reject missing API key', async () => {
    const response = await request(app)
      .get('/api/public/data');

    expect(response.status).toBe(401);
    expect(response.body.error).toBe('API key required');
  });
});
```

## Authorization Testing

### Role-Based Access Control

```typescript
describe('Authorization', () => {
  describe('Role-Based Access', () => {
    it('should allow admin to access admin endpoints', async () => {
      const response = await request(app)
        .get('/api/admin/users')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
    });

    it('should deny regular user from admin endpoints', async () => {
      const response = await request(app)
        .get('/api/admin/users')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(403);
      expect(response.body.error).toBe('Insufficient permissions');
    });

    it('should allow user to access own resources', async () => {
      const response = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
    });

    it('should deny user from accessing other users resources', async () => {
      const response = await request(app)
        .get('/api/users/other-user-id')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(403);
      expect(response.body.error).toBe('Access denied');
    });
  });
});
```

### Resource-Based Authorization

```typescript
describe('Resource Authorization', () => {
  it('should allow owner to edit own post', async () => {
    const response = await request(app)
      .put(`/api/posts/${ownedPostId}`)
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ title: 'Updated Title' });

    expect(response.status).toBe(200);
  });

  it('should deny non-owner from editing post', async () => {
    const response = await request(app)
      .put(`/api/posts/${otherPostId}`)
      .set('Authorization', `Bearer ${userToken}`)
      .send({ title: 'Updated Title' });

    expect(response.status).toBe(403);
    expect(response.body.error).toBe('You can only edit your own posts');
  });
});
```

## Rate Limiting Testing

### Basic Rate Limiting

```typescript
describe('Rate Limiting', () => {
  it('should allow requests within rate limit', async () => {
    const requests = Array(10).fill(null).map(() =>
      request(app)
        .get('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
    );

    const responses = await Promise.all(requests);
    const allSuccessful = responses.every(r => r.status === 200);
    
    expect(allSuccessful).toBe(true);
  });

  it('should block requests exceeding rate limit', async () => {
    // Make requests up to limit
    for (let i = 0; i < 100; i++) {
      await request(app)
        .get('/api/posts')
        .set('Authorization', `Bearer ${validToken}`);
    }

    // This should be rate limited
    const response = await request(app)
      .get('/api/posts')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(429);
    expect(response.body.error).toBe('Rate limit exceeded');
    expect(response.headers['retry-after']).toBeDefined();
  });

  it('should include rate limit headers', async () => {
    const response = await request(app)
      .get('/api/posts')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.headers['x-ratelimit-limit']).toBeDefined();
    expect(response.headers['x-ratelimit-remaining']).toBeDefined();
    expect(response.headers['x-ratelimit-reset']).toBeDefined();
  });
});
```

### Endpoint-Specific Rate Limiting

```typescript
describe('Endpoint-Specific Rate Limiting', () => {
  it('should apply stricter limits to auth endpoints', async () => {
    // Login endpoint might have lower rate limit
    for (let i = 0; i < 5; i++) {
      await request(app)
        .post('/api/auth/login')
        .send({ email: 'test@example.com', password: 'wrong' });
    }

    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'wrong' });

    expect(response.status).toBe(429);
  });
});
```

## Error Handling Testing

### HTTP Error Responses

```typescript
describe('Error Handling', () => {
  it('should return 404 for non-existent endpoints', async () => {
    const response = await request(app)
      .get('/api/non-existent');

    expect(response.status).toBe(404);
    expect(response.body.error).toBe('Endpoint not found');
  });

  it('should return 405 for wrong HTTP method', async () => {
    const response = await request(app)
      .patch('/api/posts')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(405);
    expect(response.body.error).toBe('Method not allowed');
  });

  it('should handle malformed JSON', async () => {
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${validToken}`)
      .set('Content-Type', 'application/json')
      .send('{"invalid": json}');

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('Invalid JSON');
  });

  it('should handle payload too large', async () => {
    const largePayload = 'x'.repeat(10 * 1024 * 1024); // 10MB
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ content: largePayload });

    expect(response.status).toBe(413);
    expect(response.body.error).toBe('Payload too large');
  });
});
```

### Business Logic Errors

```typescript
describe('Business Logic Errors', () => {
  it('should return conflict for duplicate resource', async () => {
    const userData = { email: 'existing@example.com', name: 'Test' };

    await request(app)
      .post('/api/users')
      .send(userData);

    const response = await request(app)
      .post('/api/users')
      .send(userData);

    expect(response.status).toBe(409);
    expect(response.body.error).toBe('User with this email already exists');
  });

  it('should return unprocessable entity for invalid state', async () => {
    const response = await request(app)
      .patch(`/api/posts/${postId}/publish`)
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(422);
    expect(response.body.error).toBe('Post must have content before publishing');
  });
});
```

## Contract Testing

### API Contract Verification

```typescript
describe('API Contract', () => {
  it('should match OpenAPI schema', async () => {
    const response = await request(app)
      .get('/api/posts')
      .set('Authorization', `Bearer ${validToken}`);

    // Validate against schema
    const isValid = validateAgainstSchema(response.body, postsSchema);
    expect(isValid).toBe(true);
  });

  it('should maintain backward compatibility', async () => {
    const response = await request(app)
      .get('/api/v1/posts')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(200);
    // Verify response structure matches v1 contract
    expect(response.body).toHaveProperty('data');
    expect(response.body).toHaveProperty('pagination');
  });
});
```

### Consumer-Driven Contract Testing

```typescript
describe('Consumer Contracts', () => {
  it('should satisfy mobile app contract', async () => {
    const response = await request(app)
      .get('/api/mobile/feed')
      .set('Authorization', `Bearer ${validToken}`)
      .set('X-Client-Version', '1.0.0');

    expect(response.status).toBe(200);
    // Mobile app expects these fields
    expect(response.body).toHaveProperty('posts');
    expect(response.body).toHaveProperty('hasMore');
    expect(response.body).toHaveProperty('nextCursor');
  });
});
```

## Test Utilities

### API Test Helpers

```typescript
// tests/api/helpers/api.helper.ts
import request from 'supertest';
import app from '../../../src/app';

export class ApiTestHelper {
  private authToken: string;

  constructor(token: string) {
    this.authToken = token;
  }

  async get(endpoint: string) {
    return request(app)
      .get(endpoint)
      .set('Authorization', `Bearer ${this.authToken}`);
  }

  async post(endpoint: string, data: any) {
    return request(app)
      .post(endpoint)
      .set('Authorization', `Bearer ${this.authToken}`)
      .send(data);
  }

  async put(endpoint: string, data: any) {
    return request(app)
      .put(endpoint)
      .set('Authorization', `Bearer ${this.authToken}`)
      .send(data);
  }

  async delete(endpoint: string) {
    return request(app)
      .delete(endpoint)
      .set('Authorization', `Bearer ${this.authToken}`);
  }
}

// Usage
const api = new ApiTestHelper(validToken);
const response = await api.get('/api/posts');
```

### Test Data Factories

```typescript
// tests/api/factories/post.factory.ts
export const PostFactory = {
  build: (overrides = {}) => ({
    title: `Test Post ${Date.now()}`,
    content: 'Test content',
    tags: ['test'],
    ...overrides,
  }),

  create: async (overrides = {}) => {
    const postData = PostFactory.build(overrides);
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${validToken}`)
      .send(postData);

    return response.body;
  },
};
```

## Running API Tests

### Commands

```bash
# Run all API tests
npm run test:api

# Run specific API test
npm run test:api -- posts.api.test.ts

# Run with coverage
npm run test:api:coverage

# Run in watch mode
npm run test:api:watch
```

### CI/CD Integration

```yaml
# .github/workflows/api-tests.yml
name: API Tests

on:
  pull_request:
    branches: [main]

jobs:
  api:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run API tests
        run: npm run test:api
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/api/coverage-final.json
```

## Best Practices

### 1. Test Organization
- Group tests by endpoint
- Use descriptive test names
- Test both success and error paths

### 2. Test Data Management
- Use factories for test data
- Clean up after tests
- Use unique data to avoid conflicts

### 3. Authentication
- Test with valid and invalid tokens
- Test token expiration
- Test different user roles

### 4. Error Handling
- Test all error status codes
- Verify error message format
- Test error logging

### 5. Performance
- Run tests in parallel
- Use test doubles for external services
- Keep tests fast and focused