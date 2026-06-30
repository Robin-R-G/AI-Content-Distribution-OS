# Test Data Management Guide

## Overview

Test data management involves creating, maintaining, and cleaning up test data to ensure consistent and reliable testing.

## Factories and Fixtures

### Factory Pattern

```typescript
// tests/factories/user.factory.ts
import { faker } from '@faker-js/faker';

export class UserFactory {
  static build(overrides = {}) {
    return {
      id: faker.string.uuid(),
      email: faker.internet.email(),
      name: faker.person.fullName(),
      password: 'Password123!',
      avatar: faker.image.avatar(),
      bio: faker.lorem.sentence(),
      location: faker.location.city(),
      createdAt: new Date(),
      ...overrides,
    };
  }

  static buildList(count: number, overrides = {}) {
    return Array.from({ length: count }, () => this.build(overrides));
  }

  static async create(overrides = {}) {
    const userData = this.build(overrides);
    // Create in database
    return userData;
  }

  static async createList(count: number, overrides = {}) {
    const users = this.buildList(count, overrides);
    // Create in database
    return users;
  }
}
```

### Post Factory

```typescript
// tests/factories/post.factory.ts
import { faker } from '@faker-js/faker';

export class PostFactory {
  static build(overrides = {}) {
    return {
      id: faker.string.uuid(),
      title: faker.lorem.sentence(),
      content: faker.lorem.paragraphs(2),
      authorId: faker.string.uuid(),
      tags: faker.helpers.arrayElements(['tech', 'news', 'sports', 'entertainment'], { min: 1, max: 3 }),
      status: faker.helpers.arrayElement(['draft', 'published', 'archived']),
      likesCount: faker.number.int({ min: 0, max: 1000 }),
      commentsCount: faker.number.int({ min: 0, max: 100 }),
      createdAt: faker.date.past(),
      updatedAt: new Date(),
      ...overrides,
    };
  }

  static buildList(count: number, overrides = {}) {
    return Array.from({ length: count }, () => this.build(overrides));
  }

  static buildPublished(overrides = {}) {
    return this.build({ status: 'published', ...overrides });
  }

  static buildDraft(overrides = {}) {
    return this.build({ status: 'draft', ...overrides });
  }
}
```

### Comment Factory

```typescript
// tests/factories/comment.factory.ts
import { faker } from '@faker-js/faker';

export class CommentFactory {
  static build(overrides = {}) {
    return {
      id: faker.string.uuid(),
      content: faker.lorem.sentence(),
      authorId: faker.string.uuid(),
      postId: faker.string.uuid(),
      parentId: null,
      likesCount: faker.number.int({ min: 0, max: 50 }),
      createdAt: faker.date.past(),
      ...overrides,
    };
  }

  static buildList(count: number, overrides = {}) {
    return Array.from({ length: count }, () => this.build(overrides));
  }

  static buildReply(parentId: string, overrides = {}) {
    return this.build({ parentId, ...overrides });
  }
}
```

### Fixture Files

```typescript
// tests/fixtures/users.fixture.ts
export const testUsers = [
  {
    id: 'user-1',
    email: 'admin@example.com',
    name: 'Admin User',
    role: 'admin',
    password: 'AdminPass123!',
  },
  {
    id: 'user-2',
    email: 'user1@example.com',
    name: 'Regular User 1',
    role: 'user',
    password: 'UserPass123!',
  },
  {
    id: 'user-3',
    email: 'user2@example.com',
    name: 'Regular User 2',
    role: 'user',
    password: 'UserPass123!',
  },
];

// tests/fixtures/posts.fixture.ts
export const testPosts = [
  {
    id: 'post-1',
    title: 'Test Post 1',
    content: 'This is test post 1 content.',
    authorId: 'user-1',
    status: 'published',
    createdAt: new Date('2024-01-01'),
  },
  {
    id: 'post-2',
    title: 'Test Post 2',
    content: 'This is test post 2 content.',
    authorId: 'user-2',
    status: 'published',
    createdAt: new Date('2024-01-02'),
  },
  {
    id: 'post-3',
    title: 'Draft Post',
    content: 'This is a draft post.',
    authorId: 'user-1',
    status: 'draft',
    createdAt: new Date('2024-01-03'),
  },
];
```

## Seed Data

### Database Seeding

```typescript
// tests/seed/seed.ts
import { DataSource } from 'typeorm';
import { User } from '../../src/entities/User';
import { Post } from '../../src/entities/Post';
import { Comment } from '../../src/entities/Comment';

export async function seedTestData(dataSource: DataSource): Promise<void> {
  const userRepository = dataSource.getRepository(User);
  const postRepository = dataSource.getRepository(Post);
  const commentRepository = dataSource.getRepository(Comment);

  // Create test users
  const users = await userRepository.save([
    {
      email: 'admin@example.com',
      name: 'Admin User',
      password: 'hashed_password',
      role: 'admin',
    },
    {
      email: 'user1@example.com',
      name: 'User 1',
      password: 'hashed_password',
      role: 'user',
    },
    {
      email: 'user2@example.com',
      name: 'User 2',
      password: 'hashed_password',
      role: 'user',
    },
  ]);

  // Create test posts
  const posts = await postRepository.save([
    {
      title: 'Welcome Post',
      content: 'Welcome to our platform!',
      author: users[0],
      status: 'published',
    },
    {
      title: 'Test Post 1',
      content: 'This is a test post.',
      author: users[1],
      status: 'published',
    },
    {
      title: 'Draft Post',
      content: 'This is a draft post.',
      author: users[0],
      status: 'draft',
    },
  ]);

  // Create test comments
  await commentRepository.save([
    {
      content: 'Great post!',
      author: users[1],
      post: posts[0],
    },
    {
      content: 'Thanks for sharing!',
      author: users[2],
      post: posts[1],
    },
  ]);
}
```

### Seed Data Files

```json
// tests/seed/data/users.json
[
  {
    "id": "user-1",
    "email": "admin@example.com",
    "name": "Admin User",
    "role": "admin",
    "password": "AdminPass123!"
  },
  {
    "id": "user-2",
    "email": "user1@example.com",
    "name": "Regular User 1",
    "role": "user",
    "password": "UserPass123!"
  },
  {
    "id": "user-3",
    "email": "user2@example.com",
    "name": "Regular User 2",
    "role": "user",
    "password": "UserPass123!"
  }
]

// tests/seed/data/posts.json
[
  {
    "id": "post-1",
    "title": "Welcome Post",
    "content": "Welcome to our platform!",
    "authorId": "user-1",
    "status": "published",
    "createdAt": "2024-01-01T00:00:00Z"
  },
  {
    "id": "post-2",
    "title": "Test Post 1",
    "content": "This is a test post.",
    "authorId": "user-2",
    "status": "published",
    "createdAt": "2024-01-02T00:00:00Z"
  },
  {
    "id": "post-3",
    "title": "Draft Post",
    "content": "This is a draft post.",
    "authorId": "user-1",
    "status": "draft",
    "createdAt": "2024-01-03T00:00:00Z"
  }
]
```

## Test Data Cleanup

### Cleanup Strategies

```typescript
// tests/cleanup/cleanup.ts
import { DataSource } from 'typeorm';

export class TestDataCleanup {
  private dataSource: DataSource;

  constructor(dataSource: DataSource) {
    this.dataSource = dataSource;
  }

  async cleanAll(): Promise<void> {
    const entities = this.dataSource.entityMetadatas;
    
    for (const entity of entities) {
      const repository = this.dataSource.getRepository(entity.name);
      await repository.clear();
    }
  }

  async cleanEntity(entityName: string): Promise<void> {
    const repository = this.dataSource.getRepository(entityName);
    await repository.clear();
  }

  async cleanTestData(): Promise<void> {
    const entities = ['Comment', 'Post', 'User'];
    
    for (const entity of entities) {
      const repository = this.dataSource.getRepository(entity);
      await repository.delete({ isTestData: true });
    }
  }
}
```

### Cleanup Hooks

```typescript
// tests/setup/cleanup-hooks.ts
import { TestDataCleanup } from '../cleanup/cleanup';

let cleanup: TestDataCleanup;

beforeAll(async () => {
  // Initialize cleanup
  cleanup = new TestDataCleanup(dataSource);
});

afterEach(async () => {
  // Clean after each test
  await cleanup.cleanTestData();
});

afterAll(async () => {
  // Clean all test data
  await cleanup.cleanAll();
});
```

### Database Transaction Rollback

```typescript
// tests/cleanup/transaction-cleanup.ts
import { DataSource, Transaction } from 'typeorm';

export class TransactionCleanup {
  private dataSource: DataSource;

  constructor(dataSource: DataSource) {
    this.dataSource = dataSource;
  }

  async runInTransaction<T>(
    fn: (transaction: Transaction) => Promise<T>
  ): Promise<T> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const result = await fn(queryRunner.manager);
      await queryRunner.commitTransaction();
      return result;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }
}
```

## Snapshot Testing

### Jest Snapshots

```typescript
// tests/snapshot/api-response.snapshot.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('API Response Snapshots', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123',
      });

    authToken = loginResponse.body.token;
  });

  it('should match posts response snapshot', async () => {
    const response = await request(app)
      .get('/api/posts')
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.body).toMatchSnapshot();
  });

  it('should match user profile response snapshot', async () => {
    const response = await request(app)
      .get('/api/users/me')
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.body).toMatchSnapshot();
  });

  it('should match post detail response snapshot', async () => {
    const response = await request(app)
      .get('/api/posts/post-1')
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.body).toMatchSnapshot();
  });
});
```

### Flutter Golden Tests

```dart
// test/snapshot/post_card_snapshot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:your_app/widgets/post_card.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('PostCard Snapshots', () {
    testWidgets('default state snapshot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: Post(
                id: '1',
                title: 'Test Post',
                content: 'Test content',
                author: 'John Doe',
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PostCard),
        matchesGoldenFile('golden/post_card_default.png'),
      );
    });

    testWidgets('with image snapshot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: Post(
                id: '1',
                title: 'Test Post',
                content: 'Test content',
                author: 'John Doe',
                imageUrl: 'https://example.com/image.jpg',
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PostCard),
        matchesGoldenFile('golden/post_card_with_image.png'),
      );
    });

    testWidgets('dark mode snapshot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PostCard(
              post: Post(
                id: '1',
                title: 'Test Post',
                content: 'Test content',
                author: 'John Doe',
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PostCard),
        matchesGoldenFile('golden/post_card_dark_mode.png'),
      );
    });
  });
}
```

## Test Data Configuration

### Environment-Specific Data

```typescript
// tests/config/test-data.config.ts
export const testDataConfig = {
  development: {
    users: 10,
    posts: 50,
    comments: 200,
  },
  test: {
    users: 5,
    posts: 20,
    comments: 50,
  },
  uat: {
    users: 20,
    posts: 100,
    comments: 500,
  },
  production: {
    users: 1000,
    posts: 10000,
    comments: 50000,
  },
};
```

### Test Data Generators

```typescript
// tests/generators/data-generator.ts
import { faker } from '@faker-js/faker';

export class TestDataGenerator {
  static generateUser(overrides = {}) {
    return {
      id: faker.string.uuid(),
      email: faker.internet.email(),
      name: faker.person.fullName(),
      password: 'Password123!',
      avatar: faker.image.avatar(),
      bio: faker.lorem.sentence(),
      location: faker.location.city(),
      createdAt: faker.date.past(),
      ...overrides,
    };
  }

  static generatePost(overrides = {}) {
    return {
      id: faker.string.uuid(),
      title: faker.lorem.sentence(),
      content: faker.lorem.paragraphs(2),
      authorId: faker.string.uuid(),
      tags: faker.helpers.arrayElements(['tech', 'news', 'sports']),
      status: faker.helpers.arrayElement(['draft', 'published']),
      likesCount: faker.number.int({ min: 0, max: 1000 }),
      commentsCount: faker.number.int({ min: 0, max: 100 }),
      createdAt: faker.date.past(),
      ...overrides,
    };
  }

  static generateComment(overrides = {}) {
    return {
      id: faker.string.uuid(),
      content: faker.lorem.sentence(),
      authorId: faker.string.uuid(),
      postId: faker.string.uuid(),
      likesCount: faker.number.int({ min: 0, max: 50 }),
      createdAt: faker.date.past(),
      ...overrides,
    };
  }
}
```

## Running Test Data Commands

### Commands

```bash
# Seed test data
npm run test:seed

# Clean test data
npm run test:clean

# Generate test data
npm run test:generate

# Reset test data
npm run test:reset

# Backup test data
npm run test:backup
```

### CI/CD Integration

```yaml
# .github/workflows/test-data.yml
name: Test Data Management

on:
  pull_request:
    branches: [main]

jobs:
  test-data:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Seed test data
        run: npm run test:seed
        
      - name: Run tests
        run: npm test
        
      - name: Clean test data
        if: always()
        run: npm run test:clean
```

## Best Practices

### 1. Data Isolation
- Use unique data for each test
- Clean up after tests
- Use transactions for rollback

### 2. Data Realism
- Use realistic data patterns
- Include edge cases
- Test with various data sizes

### 3. Data Security
- Don't use real user data
- Sanitize sensitive information
- Use fake data generators

### 4. Data Management
- Version control test data
- Document data structures
- Maintain data consistency

### 5. Performance
- Minimize test data creation
- Use data pooling
- Optimize cleanup operations