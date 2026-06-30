# Phase 9: Testing Prompts

## 9.1 Generate Unit Tests

**Phase:** 9-Testing
**Output:** `test/` directory
**Inputs:** Code, requirements

```
Generate comprehensive unit tests for Social Media AI.

## Test Structure
```
test/
├── core/
│   ├── auth/
│   │   ├── jwt_service_test.dart
│   │   └── auth_middleware_test.dart
│   ├── authorization/
│   │   └── rbac_service_test.dart
│   └── utils/
│       ├── formatters_test.dart
│       └── validators_test.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_test.dart
│   │   │   └── datasources/
│   │   │       └── auth_datasource_test.dart
│   │   └── domain/
│   │       └── usecases/
│   │           ├── login_usecase_test.dart
│   │           └── register_usecase_test.dart
│   ├── posts/
│   │   └── [similar structure]
│   └── ai_generation/
│       └── [similar structure]
└── shared/
    ├── widgets/
    │   └── [widget tests]
    └── services/
        └── [service tests]
```

## Unit Test Examples

### JWT Service Test
```dart
void main() {
  late JWTService jwtService;
  late MockRedis mockRedis;
  
  setUp(() {
    mockRedis = MockRedis();
    jwtService = JWTService(redis: mockRedis);
  });
  
  group('JWTService', () {
    group('generateTokenPair', () {
      test('should generate valid access and refresh tokens', () async {
        // Arrange
        final user = User(
          id: 'user-123',
          email: 'test@example.com',
          role: 'admin',
          workspaceId: 'workspace-123'
        );
        
        // Act
        final tokens = await jwtService.generateTokenPair(user);
        
        // Assert
        expect(tokens.accessToken, isNotEmpty);
        expect(tokens.refreshToken, isNotEmpty);
        expect(tokens.expiresIn, equals(900));
        expect(tokens.tokenType, equals('Bearer'));
      });
      
      test('should generate different tokens for each call', () async {
        // Arrange
        final user = createTestUser();
        
        // Act
        final tokens1 = await jwtService.generateTokenPair(user);
        final tokens2 = await jwtService.generateTokenPair(user);
        
        // Assert
        expect(tokens1.accessToken, isNot(equals(tokens2.accessToken)));
        expect(tokens1.refreshToken, isNot(equals(tokens2.refreshToken)));
      });
    });
    
    group('validateToken', () {
      test('should validate a valid access token', () async {
        // Arrange
        final user = createTestUser();
        final tokens = await jwtService.generateTokenPair(user);
        
        // Act
        final payload = await jwtService.validateToken(
          tokens.accessToken,
          'access'
        );
        
        // Assert
        expect(payload.sub, equals(user.id));
        expect(payload.email, equals(user.email));
        expect(payload.type, equals('access'));
      });
      
      test('should reject expired token', () async {
        // Arrange
        final expiredToken = createExpiredToken();
        
        // Act & Assert
        expect(
          () => jwtService.validateToken(expiredToken, 'access'),
          throwsA(isA<TokenExpiredError>())
        );
      });
      
      test('should reject revoked token', () async {
        // Arrange
        final user = createTestUser();
        final tokens = await jwtService.generateTokenPair(user);
        await jwtService.revokeToken(tokens.refreshToken);
        
        // Act & Assert
        expect(
          () => jwtService.validateToken(tokens.refreshToken, 'refresh'),
          throwsA(isA<InvalidTokenError>())
        );
      });
    });
  });
}
```

### Authorization Service Test
```dart
void main() {
  late AuthorizationService authService;
  late MockDatabase mockDb;
  
  setUp(() {
    mockDb = MockDatabase();
    authService = AuthorizationService(db: mockDb);
  });
  
  group('AuthorizationService', () {
    group('checkPermission', () {
      test('should return true when user has required permission', () async {
        // Arrange
        when(mockDb.workspace_members.findOne(
          userId: 'user-123',
          workspaceId: 'workspace-123'
        )).thenAnswer((_) async => WorkspaceMember(role: 'admin'));
        
        // Act
        final result = await authService.checkPermission(
          'user-123',
          'workspace-123',
          Permission.POST_CREATE
        );
        
        // Assert
        expect(result, isTrue);
      });
      
      test('should return false when user lacks permission', () async {
        // Arrange
        when(mockDb.workspace_members.findOne(
          userId: 'user-123',
          workspaceId: 'workspace-123'
        )).thenAnswer((_) async => WorkspaceMember(role: 'viewer'));
        
        // Act
        final result = await authService.checkPermission(
          'user-123',
          'workspace-123',
          Permission.POST_CREATE
        );
        
        // Assert
        expect(result, isFalse);
      });
      
      test('should return false when user is not a member', () async {
        // Arrange
        when(mockDb.workspace_members.findOne(
          userId: 'user-123',
          workspaceId: 'workspace-123'
        )).thenAnswer((_) async => null);
        
        // Act
        final result = await authService.checkPermission(
          'user-123',
          'workspace-123',
          Permission.POST_CREATE
        );
        
        // Assert
        expect(result, isFalse);
      });
    });
  });
}
```

### Repository Test
```dart
void main() {
  late PostRepository postRepository;
  late MockDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  
  setUp(() {
    mockDataSource = MockDataSource();
    mockNetworkInfo = MockNetworkInfo();
    postRepository = PostRepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo
    );
  });
  
  group('PostRepository', () {
    group('getPosts', () {
      test('should return posts when online', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getPosts(
          workspaceId: 'workspace-123',
          page: 1,
          limit: 20
        )).thenAnswer((_) async => testPosts);
        
        // Act
        final result = await postRepository.getPosts(
          workspaceId: 'workspace-123',
          page: 1,
          limit: 20
        );
        
        // Assert
        expect(result, equals(testPosts));
        verify(mockDataSource.getPosts(
          workspaceId: 'workspace-123',
          page: 1,
          limit: 20
        )).called(1);
      });
      
      test('should throw exception when offline', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        
        // Act & Assert
        expect(
          () => postRepository.getPosts(
            workspaceId: 'workspace-123',
            page: 1,
            limit: 20
          ),
          throwsA(isA<NetworkException>())
        );
      });
    });
  });
}
```

Generate comprehensive unit tests for all components.
```

**Expected Output:** 100+ unit tests with full coverage.

---

## 9.2 Generate Integration Tests

**Phase:** 9-Testing
**Output:** `test/integration/`
**Inputs:** API specs, database schema

```
Generate integration tests for Social Media AI.

## Integration Test Structure
```
test/integration/
├── auth/
│   ├── register_test.dart
│   ├── login_test.dart
│   └── refresh_test.dart
├── posts/
│   ├── create_post_test.dart
│   ├── update_post_test.dart
│   └── delete_post_test.dart
├── social_accounts/
│   ├── connect_account_test.dart
│   └── disconnect_account_test.dart
├── ai_generation/
│   ├── generate_caption_test.dart
│   └── generate_hashtags_test.dart
└── analytics/
    └── get_analytics_test.dart
```

## Integration Test Examples

### Auth Integration Test
```dart
void main() {
  late TestApp app;
  late TestDatabase db;
  
  setUpAll(() async {
    app = await TestApp.create();
    db = await TestDatabase.create();
  });
  
  tearDownAll(() async {
    await db.cleanup();
    await app.close();
  });
  
  group('Authentication Integration', () {
    test('should register, login, and access protected route', () async {
      // Register
      final registerResponse = await app.post('/auth/register', {
        'email': 'test@example.com',
        'password': 'Password123!',
        'full_name': 'Test User'
      });
      
      expect(registerResponse.statusCode, equals(201));
      expect(registerResponse.body['user']['email'], equals('test@example.com'));
      
      // Login
      final loginResponse = await app.post('/auth/login', {
        'email': 'test@example.com',
        'password': 'Password123!'
      });
      
      expect(loginResponse.statusCode, equals(200));
      final accessToken = loginResponse.body['tokens']['accessToken'];
      
      // Access protected route
      final profileResponse = await app.get(
        '/users/me',
        headers: {'Authorization': 'Bearer $accessToken'}
      );
      
      expect(profileResponse.statusCode, equals(200));
      expect(profileResponse.body['email'], equals('test@example.com'));
    });
    
    test('should fail login with wrong password', () async {
      // Register
      await app.post('/auth/register', {
        'email': 'test2@example.com',
        'password': 'Password123!',
        'full_name': 'Test User 2'
      });
      
      // Login with wrong password
      final response = await app.post('/auth/login', {
        'email': 'test2@example.com',
        'password': 'WrongPassword'
      });
      
      expect(response.statusCode, equals(401));
    });
  });
}
```

### Post Integration Test
```dart
void main() {
  late TestApp app;
  late String authToken;
  late String workspaceId;
  
  setUpAll(() async {
    app = await TestApp.create();
    
    // Create test user and workspace
    final user = await createTestUser(app);
    authToken = user.token;
    workspaceId = user.workspaceId;
  });
  
  group('Post Integration', () {
    test('should create, read, update, and delete post', () async {
      // Create
      final createResponse = await app.post(
        '/workspaces/$workspaceId/posts',
        {
          'content': {'text': 'Test post'},
          'status': 'draft'
        },
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(createResponse.statusCode, equals(201));
      final postId = createResponse.body['id'];
      
      // Read
      final getResponse = await app.get(
        '/workspaces/$workspaceId/posts/$postId',
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(getResponse.statusCode, equals(200));
      expect(getResponse.body['content']['text'], equals('Test post'));
      
      // Update
      final updateResponse = await app.patch(
        '/workspaces/$workspaceId/posts/$postId',
        {'content': {'text': 'Updated post'}},
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(updateResponse.statusCode, equals(200));
      expect(updateResponse.body['content']['text'], equals('Updated post'));
      
      // Delete
      final deleteResponse = await app.delete(
        '/workspaces/$workspaceId/posts/$postId',
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(deleteResponse.statusCode, equals(204));
    });
  });
}
```

### AI Generation Integration Test
```dart
void main() {
  late TestApp app;
  late String authToken;
  
  setUpAll(() async {
    app = await TestApp.create();
    final user = await createTestUser(app);
    authToken = user.token;
  });
  
  group('AI Generation Integration', () {
    test('should generate caption', () async {
      final response = await app.post(
        '/ai/generate/caption',
        {
          'topic': 'social media tips',
          'platform': 'instagram',
          'tone': 'professional'
        },
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(response.statusCode, equals(200));
      expect(response.body['caption'], isNotEmpty);
      expect(response.body['hashtags'], isList);
    });
    
    test('should generate hashtags', () async {
      final response = await app.post(
        '/ai/generate/hashtags',
        {
          'content': 'Amazing sunset at the beach',
          'platform': 'instagram',
          'count': 10
        },
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(response.statusCode, equals(200));
      expect(response.body['hashtags'], hasLength(10));
    });
  });
}
```

Generate comprehensive integration tests for all API endpoints.
```

**Expected Output:** 50+ integration tests covering all major flows.

---

## 9.3 Generate API Tests

**Phase:** 9-Testing
**Output:** API test suite
**Inputs:** OpenAPI spec

```
Generate API tests for Social Media AI.

## API Test Structure
```
test/api/
├── endpoints/
│   ├── auth/
│   │   ├── register_test.dart
│   │   ├── login_test.dart
│   │   └── refresh_test.dart
│   ├── posts/
│   │   ├── crud_test.dart
│   │   └── permissions_test.dart
│   └── analytics/
│       └── queries_test.dart
├── schemas/
│   ├── request_schemas_test.dart
│   └── response_schemas_test.dart
└── middleware/
    ├── rate_limit_test.dart
    └── auth_test.dart
```

## API Test Examples

### Request Validation Test
```dart
void main() {
  late TestApp app;
  
  setUpAll(() async {
    app = await TestApp.create();
  });
  
  group('API Validation', () {
    test('should return 422 for invalid email format', () async {
      final response = await app.post('/auth/register', {
        'email': 'not-an-email',
        'password': 'Password123!',
        'full_name': 'Test User'
      });
      
      expect(response.statusCode, equals(422));
      expect(response.body['error'], equals('Validation error'));
      expect(response.body['details'], contains('email'));
    });
    
    test('should return 422 for missing required fields', () async {
      final response = await app.post('/auth/register', {
        'email': 'test@example.com'
      });
      
      expect(response.statusCode, equals(422));
      expect(response.body['details'], contains('password'));
      expect(response.body['details'], contains('full_name'));
    });
    
    test('should return 422 for weak password', () async {
      final response = await app.post('/auth/register', {
        'email': 'test@example.com',
        'password': '123',
        'full_name': 'Test User'
      });
      
      expect(response.statusCode, equals(422));
      expect(response.body['details'], contains('password'));
    });
  });
}
```

### Rate Limit Test
```dart
void main() {
  late TestApp app;
  
  setUpAll(() async {
    app = await TestApp.create();
  });
  
  group('Rate Limiting', () {
    test('should enforce rate limits', () async {
      // Make requests up to limit
      for (var i = 0; i < 100; i++) {
        await app.get('/posts');
      }
      
      // Next request should be rate limited
      final response = await app.get('/posts');
      
      expect(response.statusCode, equals(429));
      expect(response.headers['X-RateLimit-Limit'], isNotNull);
      expect(response.headers['X-RateLimit-Remaining'], equals('0'));
      expect(response.headers['Retry-After'], isNotNull);
    });
  });
}
```

### Response Schema Test
```dart
void main() {
  late TestApp app;
  late String authToken;
  
  setUpAll(() async {
    app = await TestApp.create();
    final user = await createTestUser(app);
    authToken = user.token;
  });
  
  group('Response Schemas', () {
    test('GET /users/me should return valid user schema', () async {
      final response = await app.get(
        '/users/me',
        headers: {'Authorization': 'Bearer $authToken'}
      );
      
      expect(response.statusCode, equals(200));
      expect(response.body, contains('id'));
      expect(response.body, contains('email'));
      expect(response.body, contains('full_name'));
      expect(response.body, contains('created_at'));
      
      // Validate types
      expect(response.body['id'], isA<String>());
      expect(response.body['email'], isA<String>());
      expect(response.body['created_at'], isA<String>());
    });
  });
}
```

Generate comprehensive API tests with schema validation.
```

**Expected Output:** 30+ API tests with validation and schema checks.

---

## 9.4 Generate UI Tests

**Phase:** 9-Testing
**Output:** `test/widget/` and `test/integration/`
**Inputs:** Flutter widgets, user flows

```
Generate UI tests for Social Media AI Flutter app.

## Widget Test Examples

### Login Screen Test
```dart
void main() {
  group('LoginScreen', () {
    testWidgets('should display login form', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );
      
      // Verify form elements
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });
    
    testWidgets('should show validation errors for empty fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );
      
      // Tap login button without entering data
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Verify validation errors
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
    
    testWidgets('should show error for invalid email', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );
      
      // Enter invalid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email'
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Invalid email format'), findsOneWidget);
    });
    
    testWidgets('should call login on valid submission', (tester) async {
      final mockAuthBloc = MockAuthBloc();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginScreen(),
          ),
        ),
      );
      
      // Enter valid credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com'
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123!'
      );
      
      // Tap login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Verify login was called
      verify(mockAuthBloc.add(Login(
        email: 'test@example.com',
        password: 'Password123!'
      ))).called(1);
    });
  });
}
```

### Dashboard Screen Test
```dart
void main() {
  group('DashboardScreen', () {
    testWidgets('should display stats cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(),
        ),
      );
      
      // Verify stats cards
      expect(find.byType(StatCard), findsNWidgets(4));
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Engagement'), findsOneWidget);
      expect(find.text('Reach'), findsOneWidget);
    });
    
    testWidgets('should display recent posts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(),
        ),
      );
      
      // Verify recent posts section
      expect(find.text('Recent Posts'), findsOneWidget);
      expect(find.byType(PostPreviewCard), findsWidgets);
    });
    
    testWidgets('should show loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(),
        ),
      );
      
      // Should show skeleton loading
      expect(find.byType(SkeletonLoader), findsWidgets);
    });
  });
}
```

### Post Creation Test
```dart
void main() {
  group('PostCreationScreen', () {
    testWidgets('should display post editor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PostCreationScreen(),
        ),
      );
      
      // Verify editor elements
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(MediaPicker), findsOneWidget);
      expect(find.byType(PlatformSelector), findsOneWidget);
      expect(find.byType(SchedulePicker), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
    });
    
    testWidgets('should show character count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PostCreationScreen(),
        ),
      );
      
      // Enter text
      await tester.enterText(
        find.byType(TextFormField),
        'Hello World'
      );
      await tester.pump();
      
      // Verify character count
      expect(find.text('11/2200'), findsOneWidget);
    });
    
    testWidgets('should open AI assist panel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PostCreationScreen(),
        ),
      );
      
      // Tap AI assist button
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Verify AI panel opens
      expect(find.byType(AIAssistPanel), findsOneWidget);
    });
  });
}
```

## Integration Test Examples

### Onboarding Flow Test
```dart
void main() {
  group('Onboarding Flow', () {
    testWidgets('should complete onboarding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      
      // Page 1
      expect(find.text('Welcome to Social Media AI'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      
      // Page 2
      expect(find.text('AI-Powered Content'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      
      // Page 3
      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Should navigate to home
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
```

Generate comprehensive UI tests for all screens and widgets.
```

**Expected Output:** 50+ UI tests covering all screens and user flows.

---

## 9.5 Generate Load Test Scripts

**Phase:** 9-Testing
**Output:** Load test scripts
**Inputs:** Performance requirements

```
Generate load test scripts for Social Media AI.

## Load Test Configuration (k6)

### auth_load_test.js
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp up
    { duration: '5m', target: 50 },   // Stay at 50 users
    { duration: '1m', target: 100 },  // Ramp up to 100
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '1m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be < 500ms
    http_req_failed: ['rate<0.01'],   // < 1% of requests should fail
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://api.socialmediaai.com';

export default function () {
  // Login
  const loginRes = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    email: `user${__VU}@test.com`,
    password: 'TestPassword123!',
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(loginRes, {
    'login status is 200': (r) => r.status === 200,
    'login has token': (r) => JSON.parse(r.body).tokens.accessToken !== undefined,
  });
  
  const token = JSON.parse(loginRes.body).tokens.accessToken;
  
  // Get profile
  const profileRes = http.get(`${BASE_URL}/users/me`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  
  check(profileRes, {
    'profile status is 200': (r) => r.status === 200,
  });
  
  sleep(1);
}
```

### posts_load_test.js
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '1m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://api.socialmediaai.com';
let authToken;
let workspaceId;

export function setup() {
  // Create test user and get token
  const loginRes = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    email: 'loadtest@test.com',
    password: 'TestPassword123!',
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const token = JSON.parse(loginRes.body).tokens.accessToken;
  const workspace = JSON.parse(loginRes.body).user.workspaceId;
  
  return { token, workspaceId: workspace };
}

export default function (data) {
  const headers = {
    Authorization: `Bearer ${data.token}`,
    'Content-Type': 'application/json',
  };
  
  // Create post
  const createRes = http.post(
    `${BASE_URL}/workspaces/${data.workspaceId}/posts`,
    JSON.stringify({
      content: { text: `Load test post ${Date.now()}` },
      status: 'draft',
    }),
    { headers }
  );
  
  check(createRes, {
    'create post status is 201': (r) => r.status === 201,
  });
  
  const postId = JSON.parse(createRes.body).id;
  
  // Get posts
  const listRes = http.get(
    `${BASE_URL}/workspaces/${data.workspaceId}/posts?page=1&limit=20`,
    { headers }
  );
  
  check(listRes, {
    'list posts status is 200': (r) => r.status === 200,
  });
  
  // Get single post
  const getRes = http.get(
    `${BASE_URL}/workspaces/${data.workspaceId}/posts/${postId}`,
    { headers }
  );
  
  check(getRes, {
    'get post status is 200': (r) => r.status === 200,
  });
  
  sleep(1);
}
```

### ai_load_test.js
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },
    { duration: '5m', target: 50 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<5000'], // AI generation takes longer
    http_req_failed: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://api.socialmediaai.com';
let authToken;

export function setup() {
  const loginRes = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    email: 'loadtest@test.com',
    password: 'TestPassword123!',
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  return { token: JSON.parse(loginRes.body).tokens.accessToken };
}

export default function (data) {
  const headers = {
    Authorization: `Bearer ${data.token}`,
    'Content-Type': 'application/json',
  };
  
  // Generate caption
  const captionRes = http.post(
    `${BASE_URL}/ai/generate/caption`,
    JSON.stringify({
      topic: 'social media tips',
      platform: 'instagram',
      tone: 'professional',
    }),
    { headers }
  );
  
  check(captionRes, {
    'generate caption status is 200': (r) => r.status === 200,
    'caption is not empty': (r) => JSON.parse(r.body).caption !== '',
  });
  
  sleep(2);
}
```

### stress_test.js
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 100 },
    { duration: '2m', target: 500 },
    { duration: '5m', target: 500 },  // Stress test
    { duration: '2m', target: 1000 },
    { duration: '5m', target: 1000 }, // High stress
    { duration: '2m', target: 0 },    // Recovery
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.1'], // Allow higher failure rate during stress
  },
};

// Similar setup and test functions...
```

Generate comprehensive load test scripts for all endpoints.
```

**Expected Output:** Complete load test suite with k6 scripts for all scenarios.

---

## 9.6 Generate Security Tests

**Phase:** 9-Testing
**Output:** Security test suite
**Inputs:** Security requirements, OWASP Top 10

```
Generate security tests for Social Media AI.

## Security Test Structure
```
test/security/
├── authentication/
│   ├── brute_force_test.dart
│   ├── session_management_test.dart
│   └── token_security_test.dart
├── authorization/
│   ├── privilege_escalation_test.dart
│   └── idor_test.dart
├── injection/
│   ├── sql_injection_test.dart
│   └── xss_test.dart
├── api/
│   ├── rate_limiting_test.dart
│   └── input_validation_test.dart
└── data/
    ├── encryption_test.dart
    └── data_leakage_test.dart
```

## Security Test Examples

### Authentication Security Tests
```dart
void main() {
  late TestApp app;
  
  setUpAll(() async {
    app = await TestApp.create();
  });
  
  group('Authentication Security', () {
    test('should lock account after 5 failed attempts', () async {
      // Attempt 5 failed logins
      for (var i = 0; i < 5; i++) {
        await app.post('/auth/login', {
          'email': 'test@example.com',
          'password': 'WrongPassword$i',
        });
      }
      
      // 6th attempt should be locked
      final response = await app.post('/auth/login', {
        'email': 'test@example.com',
        'password': 'WrongPassword5',
      });
      
      expect(response.statusCode, equals(423));
      expect(response.body['error'], contains('locked'));
    });
    
    test('should prevent session fixation', () async {
      // Login and get token
      final loginResponse = await app.post('/auth/login', {
        'email': 'test@example.com',
        'password': 'Password123!',
      });
      
      final token = loginResponse.body['tokens']['accessToken'];
      
      // Refresh token
      final refreshResponse = await app.post('/auth/refresh', {
        'refreshToken': loginResponse.body['tokens']['refreshToken'],
      });
      
      // Old token should be invalid
      final profileResponse = await app.get(
        '/users/me',
        headers: {'Authorization': 'Bearer $token'},
      );
      
      expect(profileResponse.statusCode, equals(401));
    });
  });
}
```

### Authorization Security Tests
```dart
void main() {
  late TestApp app;
  late String viewerToken;
  late String adminToken;
  late String workspaceId;
  
  setUpAll(() async {
    app = await TestApp.create();
    
    // Create viewer user
    final viewer = await createUser('viewer@test.com', 'viewer');
    viewerToken = viewer.token;
    workspaceId = viewer.workspaceId;
    
    // Create admin user
    final admin = await createUser('admin@test.com', 'admin');
    adminToken = admin.token;
  });
  
  group('Authorization Security', () {
    test('should prevent privilege escalation', () async {
      // Viewer tries to invite member (admin only)
      final response = await app.post(
        '/workspaces/$workspaceId/members',
        {'email': 'new@test.com', 'role': 'admin'},
        headers: {'Authorization': 'Bearer $viewerToken'},
      );
      
      expect(response.statusCode, equals(403));
    });
    
    test('should prevent IDOR - accessing other workspace', () async {
      // Create another workspace
      final otherWorkspace = await createWorkspace(adminToken);
      
      // Viewer tries to access other workspace
      final response = await app.get(
        '/workspaces/${otherWorkspace.id}/posts',
        headers: {'Authorization': 'Bearer $viewerToken'},
      );
      
      expect(response.statusCode, equals(403));
    });
  });
}
```

### SQL Injection Tests
```dart
void main() {
  late TestApp app;
  
  setUpAll(() async {
    app = await TestApp.create();
  });
  
  group('SQL Injection', () {
    test('should prevent SQL injection in login', () async {
      final response = await app.post('/auth/login', {
        'email": "admin'--",
        'password': 'anything',
      });
      
      expect(response.statusCode, equals(401));
      // Should not reveal if user exists
      expect(response.body['error'], equals('Invalid credentials'));
    });
    
    test('should prevent SQL injection in search', () async {
      final response = await app.get(
        '/posts?search=%27%20OR%201%3D1%20--',
        headers: {'Authorization': 'Bearer $token'},
      );
      
      expect(response.statusCode, equals(200));
      // Should return empty results, not all posts
      expect(response.body['data'], isEmpty);
    });
  });
}
```

### XSS Tests
```dart
void main() {
  late TestApp app;
  late String authToken;
  
  setUpAll(() async {
    app = await TestApp.create();
    final user = await createTestUser(app);
    authToken = user.token;
  });
  
  group('XSS Prevention', () {
    test('should sanitize XSS in post content', () async {
      final response = await app.post(
        '/workspaces/$workspaceId/posts',
        {
          'content': {'text': '<script>alert("xss")</script>'},
        },
        headers: {'Authorization': 'Bearer $authToken'},
      );
      
      expect(response.statusCode, equals(201));
      
      // Get the post and verify XSS is sanitized
      final getResponse = await app.get(
        '/workspaces/$workspaceId/posts/${response.body["id"]}',
        headers: {'Authorization': 'Bearer $authToken'},
      );
      
      expect(
        getResponse.body['content']['text'],
        isNot(contains('<script>'))
      );
    });
  });
}
```

### Rate Limiting Security Tests
```dart
void main() {
  late TestApp app;
  
  setUpAll(() async {
    app = await TestApp.create();
  });
  
  group('Rate Limiting Security', () {
    test('should rate limit login attempts', () async {
      // Make 5 login attempts
      for (var i = 0; i < 5; i++) {
        await app.post('/auth/login', {
          'email': 'test@example.com',
          'password': 'WrongPassword',
        });
      }
      
      // 6th attempt should be rate limited
      final response = await app.post('/auth/login', {
        'email': 'test@example.com',
        'password': 'WrongPassword',
      });
      
      expect(response.statusCode, equals(429));
      expect(response.headers['Retry-After'], isNotNull);
    });
  });
}
```

### Data Leakage Tests
```dart
void main() {
  late TestApp app;
  
  setUpAll(() async {
    app = await TestApp.create();
  });
  
  group('Data Leakage Prevention', () {
    test('should not expose sensitive data in error messages', () async {
      final response = await app.post('/auth/login', {
        'email': 'nonexistent@test.com',
        'password': 'WrongPassword',
      });
      
      expect(response.statusCode, equals(401));
      // Should not reveal if user exists
      expect(response.body['error'], equals('Invalid credentials'));
      expect(response.body.toString(), isNot(contains('user not found')));
    });
    
    test('should not expose internal error details', () async {
      // Trigger an internal error
      final response = await app.get('/broken-endpoint');
      
      expect(response.statusCode, equals(500));
      // Should not expose stack trace
      expect(response.body.toString(), isNot(contains('stack trace')));
      expect(response.body.toString(), isNot(contains('line ')));
    });
  });
}
```

Generate comprehensive security tests covering OWASP Top 10.
```

**Expected Output:** 30+ security tests covering authentication, authorization, injection, and data protection.
