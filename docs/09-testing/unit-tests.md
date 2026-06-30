# Unit Testing Guide

## Framework Selection

### TypeScript (Backend/API)
- **Vitest**: Fast, modern test runner
- **@vitest/coverage-v8**: Code coverage
- **msw**: API mocking
- **nock**: HTTP mocking

### Flutter (Mobile)
- **flutter_test**: Built-in testing framework
- **mockito**: Mocking library
- **bloc_test**: BLoC testing
- **golden_toolkit**: Visual regression testing

## File Naming Conventions

### TypeScript
```
src/
  services/
    user.service.ts
    user.service.test.ts  # Co-located tests
  utils/
    formatters.ts
    formatters.test.ts
tests/
  unit/
    services/
      user.service.unit.test.ts  # Separate test directory
    utils/
      formatters.unit.test.ts
```

### Flutter
```
lib/
  services/
    user_service.dart
test/
  unit/
    services/
      user_service_test.dart
  widget/
    screens/
      home_screen_test.dart
```

## Test Structure (AAA Pattern)

### Arrange-Act-Assert
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { name: 'John', email: 'john@example.com' };
      const mockRepository = createMock<UserRepository>();
      const service = new UserService(mockRepository);

      // Act
      const result = await service.createUser(userData);

      // Assert
      expect(result).toBeDefined();
      expect(result.name).toBe('John');
      expect(mockRepository.save).toHaveBeenCalledWith(userData);
    });
  });
});
```

### Flutter Example
```dart
void main() {
  group('UserService', () {
    test('should create user with valid data', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final service = UserService(repository: mockRepository);
      final userData = UserModel(name: 'John', email: 'john@example.com');

      // Act
      final result = await service.createUser(userData);

      // Assert
      expect(result, isNotNull);
      expect(result.name, equals('John'));
      verify(mockRepository.save(userData)).called(1);
    });
  });
}
```

## Mocking Strategy

### TypeScript Mocking

#### Service Mocking
```typescript
import { vi, describe, it, expect, beforeEach } from 'vitest';

// Create mock factory
const createMockUserRepository = () => ({
  findById: vi.fn(),
  findByEmail: vi.fn(),
  save: vi.fn(),
  delete: vi.fn(),
});

describe('UserService', () => {
  let service: UserService;
  let mockRepository: ReturnType<typeof createMockUserRepository>;

  beforeEach(() => {
    mockRepository = createMockUserRepository();
    service = new UserService(mockRepository);
  });

  it('should return user by id', async () => {
    const mockUser = { id: '1', name: 'John' };
    mockRepository.findById.mockResolvedValue(mockUser);

    const result = await service.getUserById('1');

    expect(result).toEqual(mockUser);
    expect(mockRepository.findById).toHaveBeenCalledWith('1');
  });
});
```

#### API Mocking with MSW
```typescript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('/api/users/:id', () => {
    return HttpResponse.json({ id: '1', name: 'John' });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it('should fetch user from API', async () => {
  const result = await fetchUser('1');
  expect(result.name).toBe('John');
});
```

### Flutter Mocking

#### Mock Class Generation
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserRepository, ApiService])
import 'user_service_test.mocks.dart';

void main() {
  late UserService service;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    service = UserService(repository: mockRepository);
  });
}
```

#### BLoC Mocking
```dart
import 'package:bloc_test/bloc_test.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when LoginSubmitted',
  build: () => MockAuthBloc(),
  act: (bloc) => bloc.add(LoginSubmitted(
    email: 'test@example.com',
    password: 'password',
  )),
  expect: () => [
    AuthLoading(),
    AuthSuccess(user: testUser),
  ],
);
```

## Test Examples

### Service Layer Testing

#### UserService Unit Test
```typescript
describe('UserService', () => {
  describe('updateProfile', () => {
    it('should update user profile successfully', async () => {
      const userId = 'user-123';
      const updateData = { name: 'Updated Name' };
      const existingUser = { id: userId, name: 'Old Name', email: 'test@example.com' };
      const updatedUser = { ...existingUser, ...updateData };

      mockRepository.findById.mockResolvedValue(existingUser);
      mockRepository.save.mockResolvedValue(updatedUser);

      const result = await service.updateProfile(userId, updateData);

      expect(result.name).toBe('Updated Name');
      expect(mockRepository.save).toHaveBeenCalledWith(updatedUser);
    });

    it('should throw error if user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(service.updateProfile('non-existent', {}))
        .rejects.toThrow('User not found');
    });
  });
});
```

### Utility Function Testing

#### Formatter Tests
```typescript
describe('Formatters', () => {
  describe('formatDate', () => {
    it('should format date to readable string', () => {
      const date = new Date('2024-01-15T10:30:00Z');
      const result = formatDate(date);
      expect(result).toBe('January 15, 2024');
    });

    it('should handle null date', () => {
      const result = formatDate(null);
      expect(result).toBe('N/A');
    });
  });

  describe('truncateText', () => {
    it('should truncate long text', () => {
      const text = 'This is a very long text that needs truncation';
      const result = truncateText(text, 20);
      expect(result).toBe('This is a very long ...');
    });

    it('should not truncate short text', () => {
      const text = 'Short text';
      const result = truncateText(text, 20);
      expect(result).toBe('Short text');
    });
  });
});
```

### Validator Testing

#### Email Validator
```typescript
describe('EmailValidator', () => {
  it('should validate correct email format', () => {
    expect(validateEmail('test@example.com')).toBe(true);
    expect(validateEmail('user.name@domain.co.uk')).toBe(true);
  });

  it('should reject invalid email formats', () => {
    expect(validateEmail('invalid')).toBe(false);
    expect(validateEmail('test@')).toBe(false);
    expect(validateEmail('@example.com')).toBe(false);
    expect(validateEmail('test@example')).toBe(false);
  });

  it('should handle edge cases', () => {
    expect(validateEmail('')).toBe(false);
    expect(validateEmail(null)).toBe(false);
    expect(validateEmail(undefined)).toBe(false);
  });
});
```

#### Password Validator
```typescript
describe('PasswordValidator', () => {
  it('should validate strong password', () => {
    const result = validatePassword('StrongP@ss123');
    expect(result.isValid).toBe(true);
    expect(result.strength).toBe('strong');
  });

  it('should reject weak password', () => {
    const result = validatePassword('weak');
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Password must be at least 8 characters');
  });

  it('should require special characters', () => {
    const result = validatePassword('NoSpecialChar123');
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Password must contain special characters');
  });
});
```

## Coverage Thresholds

### vitest Configuration
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/**/*.test.ts',
        'src/**/*.spec.ts',
        'src/types/',
        'src/**/*.d.ts',
      ],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
    },
  },
});
```

### Flutter Coverage
```yaml
# analysis_options.yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

# Run with coverage
# flutter test --coverage
# genhtml coverage/lcov.info -o coverage/html
```

## Running Tests

### TypeScript
```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test file
npm run test -- user.service.test.ts

# Run in watch mode
npm run test:watch

# Run UI tests
npm run test:ui
```

### Flutter
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/services/user_service_test.dart

# Run widget tests
flutter test test/widget/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Best Practices

### 1. Test Isolation
- Each test should be independent
- Use beforeEach/afterEach for setup/cleanup
- Avoid shared state between tests

### 2. Meaningful Assertions
- Test behavior, not implementation
- Use descriptive test names
- Assert one concept per test

### 3. Mock Boundaries
- Mock external dependencies only
- Don't mock the system under test
- Use real objects when possible

### 4. Test Data
- Use factories for test data
- Keep test data minimal
- Use descriptive variable names

### 5. Maintenance
- Review and update tests regularly
- Remove obsolete tests
- Refactor flaky tests