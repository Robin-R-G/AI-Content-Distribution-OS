# Integration Testing Guide

## Overview

Integration tests verify that different components work together correctly, including database operations, API integrations, and external service interactions.

## Database Testing with Testcontainers

### Setup

```typescript
// tests/integration/database.setup.ts
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql';
import { DataSource } from 'typeorm';

let container: StartedPostgreSqlContainer;
let dataSource: DataSource;

beforeAll(async () => {
  container = await new PostgreSqlContainer()
    .withDatabase('test_db')
    .withUsername('test_user')
    .withPassword('test_password')
    .start();

  dataSource = new DataSource({
    type: 'postgres',
    host: container.getHost(),
    port: container.getPort(),
    database: container.getDatabase(),
    username: container.getUsername(),
    password: container.getPassword(),
    entities: ['src/entities/*.ts'],
    synchronize: true,
  });

  await dataSource.initialize();
});

afterAll(async () => {
  await dataSource?.destroy();
  await container?.stop();
});

beforeEach(async () => {
  // Clean database before each test
  const entities = dataSource.entityMetadatas;
  for (const entity of entities) {
    const repository = dataSource.getRepository(entity.name);
    await repository.clear();
  }
});
```

### Test Example

```typescript
describe('User Repository Integration', () => {
  it('should create and retrieve user', async () => {
    const userRepository = dataSource.getRepository(User);

    const user = userRepository.create({
      name: 'Test User',
      email: 'test@example.com',
    });

    const savedUser = await userRepository.save(user);
    const foundUser = await userRepository.findOne({
      where: { id: savedUser.id },
    });

    expect(foundUser).toBeDefined();
    expect(foundUser!.name).toBe('Test User');
    expect(foundUser!.email).toBe('test@example.com');
  });

  it('should enforce unique email constraint', async () => {
    const userRepository = dataSource.getRepository(User);

    const user1 = userRepository.create({
      name: 'User 1',
      email: 'duplicate@example.com',
    });

    const user2 = userRepository.create({
      name: 'User 2',
      email: 'duplicate@example.com',
    });

    await userRepository.save(user1);

    await expect(userRepository.save(user2))
      .rejects.toThrow();
  });
});
```

## API Integration Tests

### Supabase Integration

```typescript
// tests/integration/supabase.integration.test.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL || 'http://localhost:54321';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'test-anon-key';

let supabase: ReturnType<typeof createClient>;

beforeAll(() => {
  supabase = createClient(supabaseUrl, supabaseKey);
});

describe('Supabase Integration', () => {
  it('should insert and query data', async () => {
    const { data: insertData, error: insertError } = await supabase
      .from('posts')
      .insert({
        title: 'Test Post',
        content: 'Test content',
        user_id: 'test-user-id',
      })
      .select();

    expect(insertError).toBeNull();
    expect(insertData).toHaveLength(1);

    const { data: queryData, error: queryError } = await supabase
      .from('posts')
      .select('*')
      .eq('title', 'Test Post');

    expect(queryError).toBeNull();
    expect(queryData).toHaveLength(1);
    expect(queryData![0].title).toBe('Test Post');
  });

  it('should handle RLS policies', async () => {
    // Test with authenticated user
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: 'test@example.com',
      password: 'password',
    });

    expect(authError).toBeNull();

    // Test with unauthenticated user
    const { data: unauthData, error: unauthError } = await supabase
      .from('private_posts')
      .select('*');

    // Should fail due to RLS
    expect(unauthError).toBeDefined();
  });
});
```

### REST API Integration

```typescript
// tests/integration/api.integration.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('API Integration', () => {
  let authToken: string;

  beforeAll(async () => {
    // Get auth token
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password',
      });

    authToken = response.body.token;
  });

  describe('Posts API', () => {
    it('should create, read, update, delete post', async () => {
      // Create
      const createResponse = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Integration Test Post',
          content: 'This is a test post',
        });

      expect(createResponse.status).toBe(201);
      const postId = createResponse.body.id;

      // Read
      const readResponse = await request(app)
        .get(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(readResponse.status).toBe(200);
      expect(readResponse.body.title).toBe('Integration Test Post');

      // Update
      const updateResponse = await request(app)
        .put(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Post',
        });

      expect(updateResponse.status).toBe(200);
      expect(updateResponse.body.title).toBe('Updated Post');

      // Delete
      const deleteResponse = await request(app)
        .delete(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(deleteResponse.status).toBe(204);

      // Verify deletion
      const verifyResponse = await request(app)
        .get(`/api/posts/${postId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(verifyResponse.status).toBe(404);
    });
  });
});
```

## External Service Mocking

### AI Service Mocking

```typescript
// tests/integration/ai-service.integration.test.ts
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.post('https://api.openai.com/v1/chat/completions', () => {
    return HttpResponse.json({
      choices: [
        {
          message: {
            content: 'This is a mock AI response',
          },
        },
      ],
    });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('AI Service Integration', () => {
  it('should handle AI API response', async () => {
    const result = await aiService.generateContent('Test prompt');
    expect(result).toBe('This is a mock AI response');
  });

  it('should handle API errors', async () => {
    server.use(
      http.post('https://api.openai.com/v1/chat/completions', () => {
        return HttpResponse.json(
          { error: 'Rate limit exceeded' },
          { status: 429 }
        );
      })
    );

    await expect(aiService.generateContent('Test prompt'))
      .rejects.toThrow('Rate limit exceeded');
  });
});
```

### Payment Gateway Mocking

```typescript
// tests/integration/payment.integration.test.ts
import { Stripe } from 'stripe';

// Mock Stripe
jest.mock('stripe', () => {
  return {
    Stripe: jest.fn().mockImplementation(() => ({
      paymentIntents: {
        create: jest.fn().mockResolvedValue({
          id: 'pi_test_123',
          amount: 2000,
          currency: 'usd',
          status: 'succeeded',
        }),
      },
    })),
  };
});

describe('Payment Integration', () => {
  it('should process payment successfully', async () => {
    const result = await paymentService.processPayment({
      amount: 2000,
      currency: 'usd',
      userId: 'user-123',
    });

    expect(result.success).toBe(true);
    expect(result.paymentIntentId).toBe('pi_test_123');
  });
});
```

## Test Data Setup/Teardown

### Database Seeding

```typescript
// tests/integration/helpers/seed.ts
import { DataSource } from 'typeorm';
import { User } from '../../../src/entities/User';
import { Post } from '../../../src/entities/Post';

export async function seedTestData(dataSource: DataSource): Promise<void> {
  const userRepository = dataSource.getRepository(User);
  const postRepository = dataSource.getRepository(Post);

  // Create test users
  const users = await userRepository.save([
    {
      name: 'User 1',
      email: 'user1@example.com',
      password: 'hashed_password',
    },
    {
      name: 'User 2',
      email: 'user2@example.com',
      password: 'hashed_password',
    },
  ]);

  // Create test posts
  await postRepository.save([
    {
      title: 'Post 1',
      content: 'Content 1',
      user: users[0],
    },
    {
      title: 'Post 2',
      content: 'Content 2',
      user: users[1],
    },
  ]);
}

export async function cleanTestData(dataSource: DataSource): Promise<void> {
  const entities = dataSource.entityMetadatas;
  for (const entity of entities) {
    const repository = dataSource.getRepository(entity.name);
    await repository.clear();
  }
}
```

### Test Fixtures

```typescript
// tests/integration/fixtures/users.fixture.ts
export const testUsers = [
  {
    id: 'user-1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'admin',
    createdAt: new Date('2024-01-01'),
  },
  {
    id: 'user-2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    role: 'user',
    createdAt: new Date('2024-01-02'),
  },
];

export const testPosts = [
  {
    id: 'post-1',
    title: 'Test Post 1',
    content: 'Test content 1',
    userId: 'user-1',
    createdAt: new Date('2024-01-01'),
  },
  {
    id: 'post-2',
    title: 'Test Post 2',
    content: 'Test content 2',
    userId: 'user-2',
    createdAt: new Date('2024-01-02'),
  },
];
```

## Supabase Local Testing

### Setup Supabase Local

```bash
# Install Supabase CLI
npm install -g supabase

# Initialize Supabase in project
supabase init

# Start local Supabase
supabase start

# Run migrations
supabase db reset

# Seed test data
supabase db seed
```

### Testing with Local Supabase

```typescript
// tests/integration/supabase-local.integration.test.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://localhost:54321';
const supabaseKey = 'your-local-anon-key';

describe('Supabase Local Testing', () => {
  let supabase: ReturnType<typeof createClient>;

  beforeAll(() => {
    supabase = createClient(supabaseUrl, supabaseKey);
  });

  it('should work with local Supabase', async () => {
    const { data, error } = await supabase
      .from('posts')
      .select('*');

    expect(error).toBeNull();
    expect(data).toBeDefined();
  });

  it('should test RLS policies', async () => {
    // Sign in as test user
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: 'test@example.com',
      password: 'password',
    });

    expect(authError).toBeNull();

    // Test authenticated access
    const { data: postData, error: postError } = await supabase
      .from('posts')
      .select('*');

    expect(postError).toBeNull();
  });
});
```

## Test Configuration

### Jest/Vitest Configuration

```typescript
// vitest.config.integration.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./tests/integration/setup.ts'],
    testTimeout: 30000,
    hookTimeout: 30000,
    include: ['tests/integration/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/**/*.spec.ts'],
    },
  },
});
```

### Environment Variables

```bash
# .env.test
DATABASE_URL=postgresql://test:test@localhost:5432/test_db
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=test-anon-key
SUPABASE_SERVICE_ROLE_KEY=test-service-role-key
REDIS_URL=redis://localhost:6379
```

## Running Integration Tests

### Commands

```bash
# Run all integration tests
npm run test:integration

# Run specific integration test
npm run test:integration -- user.integration.test.ts

# Run with coverage
npm run test:integration:coverage

# Run with testcontainers
npm run test:integration:testcontainers

# Run Supabase integration tests
npm run test:integration:supabase
```

### CI/CD Integration

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests

on:
  pull_request:
    branches: [main]

jobs:
  integration:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/integration/coverage-final.json
```

## Best Practices

### 1. Test Isolation
- Clean database between tests
- Use transactions that rollback
- Reset external service mocks

### 2. Test Data Management
- Use factories for test data
- Keep test data minimal
- Clean up after tests

### 3. Error Handling
- Test both success and failure paths
- Verify error messages
- Test retry logic

### 4. Performance
- Use testcontainers for database tests
- Mock external services when possible
- Run tests in parallel when safe

### 5. Maintenance
- Keep tests simple and focused
- Update tests when code changes
- Remove obsolete tests