# UI Testing Guide

## Overview

UI testing ensures that user interfaces work correctly across different platforms, including widget tests, integration tests, visual regression tests, and accessibility tests.

## Widget Tests (Flutter)

### Basic Widget Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/widgets/post_card.dart';

void main() {
  group('PostCard Widget', () {
    testWidgets('should display post title and content', (tester) async {
      // Arrange
      final post = Post(
        id: '1',
        title: 'Test Post',
        content: 'Test content',
        author: 'John Doe',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: post),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Post'), findsOneWidget);
      expect(find.text('Test content'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should handle tap event', (tester) async {
      // Arrange
      bool tapped = false;
      final post = Post(
        id: '1',
        title: 'Test Post',
        content: 'Test content',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: post,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PostCard));

      // Assert
      expect(tapped, isTrue);
    });
  });
}
```

### State Management Testing

```dart
void main() {
  group('Counter Widget', () {
    testWidgets('should increment counter', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterWidget(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Assert
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should decrement counter', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterWidget(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Assert
      expect(find.text('-1'), findsOneWidget);
    });
  });
}
```

### Form Testing

```dart
void main() {
  group('Login Form', () {
    testWidgets('should validate empty fields', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should submit form with valid data', (tester) async {
      // Arrange
      bool submitted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onSubmit: () => submitted = true,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(submitted, isTrue);
    });
  });
}
```

## Integration Tests (Flutter)

### Page Navigation Testing

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Integration', () {
    testWidgets('should navigate through app flow', (tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());

      // Act - Login
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Assert - Should be on home page
      expect(find.text('Welcome'), findsOneWidget);

      // Act - Navigate to profile
      await tester.tap(find.byKey(Key('profile_tab')));
      await tester.pumpAndSettle();

      // Assert - Should be on profile page
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
```

### Full User Flow Testing

```dart
group('Post Creation Flow', () {
  testWidgets('should create a new post', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to create post
    await tester.tap(find.byKey(Key('create_post_button')));
    await tester.pumpAndSettle();

    // Fill in post details
    await tester.enterText(
      find.byKey(Key('title_field')),
      'My Test Post',
    );
    await tester.enterText(
      find.byKey(Key('content_field')),
      'This is test content for my post.',
    );

    // Add tags
    await tester.enterText(
      find.byKey(Key('tags_field')),
      'test, flutter',
    );

    // Submit
    await tester.tap(find.byKey(Key('submit_button')));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Post created successfully'), findsOneWidget);
    expect(find.text('My Test Post'), findsOneWidget);
  });
});
```

## Golden Tests for Visual Regression

### Setting Up Golden Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('Golden Tests', () {
    testWidgets('PostCard golden test', (tester) async {
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
        matchesGoldenFile('golden/post_card.png'),
      );
    });

    testWidgets('PostCard dark mode golden test', (tester) async {
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
        matchesGoldenFile('golden/post_card_dark.png'),
      );
    });
  });
}
```

### Golden Test Configuration

```yaml
# pubspec.yaml
dev_dependencies:
  golden_toolkit: ^0.15.0

# Configure golden tests
flutter_test:
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

## Page Object Model

### Page Object Implementation

```dart
// test/pages/login_page.dart
class LoginPage {
  final WidgetTester tester;

  LoginPage(this.tester);

  // Locators
  final emailField = find.byKey(Key('email_field'));
  final passwordField = find.byKey(Key('password_field'));
  final loginButton = find.byKey(Key('login_button'));
  final errorMessage = find.byKey(Key('error_message'));

  // Actions
  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
  }

  Future<void> tapLogin() async {
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  Future<void> login(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapLogin();
  }

  // Assertions
  bool hasError() => errorMessage.evaluate().isNotEmpty;

  String getErrorText() {
    final element = errorMessage.evaluate().first;
    return (element.widget as Text).data ?? '';
  }
}
```

### Using Page Objects

```dart
void main() {
  group('Login Flow', () {
    testWidgets('should login successfully', (tester) async {
      await tester.pumpWidget(MyApp());
      final loginPage = LoginPage(tester);

      await loginPage.login('test@example.com', 'password123');

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('should show error for invalid credentials', (tester) async {
      await tester.pumpWidget(MyApp());
      final loginPage = LoginPage(tester);

      await loginPage.login('wrong@example.com', 'wrongpassword');

      expect(loginPage.hasError(), isTrue);
      expect(loginPage.getErrorText(), 'Invalid credentials');
    });
  });
}
```

## Test Data Factories

### Factory Implementation

```dart
// test/factories/post_factory.dart
class PostFactory {
  static Post build({
    String? id,
    String? title,
    String? content,
    String? author,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? 'post-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Post ${DateTime.now().millisecondsSinceEpoch}',
      content: content ?? 'Test content for the post.',
      author: author ?? 'Test Author',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static List<Post> buildList(int count) {
    return List.generate(count, (index) => build(
      id: 'post-$index',
      title: 'Test Post $index',
    ));
  }
}
```

### Using Factories in Tests

```dart
void main() {
  group('Post List', () {
    testWidgets('should display multiple posts', (tester) async {
      final posts = PostFactory.buildList(5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(posts: posts),
          ),
        ),
      );

      expect(find.byType(PostCard), findsNWidgets(5));
    });

    testWidgets('should handle empty list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(posts: []),
          ),
        ),
      );

      expect(find.text('No posts available'), findsOneWidget);
    });
  });
}
```

## Flutter Test Configuration

### test_driver/app.dart

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test', () {
    testWidgets('Full app test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test app functionality
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

### analysis_options.yaml

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "**/generated_plugin_registrant.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
```

## Running Flutter Tests

### Commands

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/

# Run golden tests
flutter test --update-goldens
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### CI/CD Integration

```yaml
# .github/workflows/flutter-tests.yml
name: Flutter Tests

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests
        run: flutter test
        
      - name: Run integration tests
        run: flutter test integration_test/
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## Best Practices

### 1. Test Organization
- Use descriptive test names
- Group related tests
- Follow AAA pattern

### 2. Widget Testing
- Test widget in isolation
- Use keys for targeting widgets
- Test different screen sizes

### 3. Integration Testing
- Test complete user flows
- Use page objects
- Handle async operations

### 4. Golden Tests
- Update goldens when UI changes
- Test different themes
- Test different screen sizes

### 5. Test Data
- Use factories for test data
- Keep test data minimal
- Clean up after tests

### 6. Performance
- Run tests in parallel
- Keep tests fast
- Use test doubles when possible