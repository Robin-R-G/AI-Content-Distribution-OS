# Phase 11: Polish Prompts

## 11.1 Generate Documentation

**Phase:** 11-Polish
**Output:** `docs/` directory
**Inputs:** Code, architecture

```
Generate comprehensive documentation for Social Media AI.

## Documentation Structure
```
docs/
├── getting-started/
│   ├── installation.md
│   ├── quick-start.md
│   └── configuration.md
├── guides/
│   ├── authentication.md
│   ├── social-accounts.md
│   ├── content-creation.md
│   ├── scheduling.md
│   ├── analytics.md
│   ├── team-collaboration.md
│   └── ai-features.md
├── api/
│   ├── overview.md
│   ├── authentication.md
│   ├── endpoints.md
│   └── examples.md
├── architecture/
│   ├── overview.md
│   ├── database.md
│   ├── security.md
│   └── deployment.md
├── contributing/
│   ├── development-setup.md
│   ├── coding-standards.md
│   └── pull-requests.md
└── faq/
    ├── general.md
    ├── billing.md
    └── troubleshooting.md
```

## Documentation Templates

### Guide Template
```markdown
# [Feature Name] Guide

## Overview
Brief description of the feature.

## Prerequisites
- Requirement 1
- Requirement 2

## Getting Started
### Step 1: [Action]
Instructions...

### Step 2: [Action]
Instructions...

## Configuration
| Setting | Description | Default |
|---------|-------------|---------|
| setting1 | Description | value |

## Examples
Code or usage examples.

## Troubleshooting
| Issue | Solution |
|-------|----------|
| Problem 1 | Solution 1 |

## Next Steps
- Link to related guide
- Link to API reference
```

Generate complete documentation for all features.
```

**Expected Output:** 20+ documentation pages covering all features.

---

## 11.2 Generate README

**Phase:** 11-Polish
**Output:** `README.md`
**Inputs:** Project overview

```
Generate comprehensive README for Social Media AI.

## README Content

### Header
```markdown
# Social Media AI

> AI-powered social media management platform

[![CI](https://github.com/socialmediaai/app/actions/workflows/ci.yml/badge.svg)](https://github.com/socialmediaai/app/actions)
[![Coverage](https://codecov.io/gh/socialmediaai/app/branch/main/graph/badge.svg)](https://codecov.io/gh/socialmediaai/app)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

### Features
- AI Content Generation
- Multi-Platform Publishing
- Analytics Dashboard
- Team Collaboration
- Content Scheduling
- Brand Management

### Quick Start
```bash
# Clone repository
git clone https://github.com/socialmediaai/app.git

# Install dependencies
flutter pub get

# Run development server
flutter run -d chrome
```

### Documentation
- [Getting Started](docs/getting-started/)
- [User Guide](docs/guides/)
- [API Reference](docs/api/)
- [Contributing](docs/contributing/)

### Tech Stack
- Flutter (Mobile, Web, Desktop)
- Supabase (Backend)
- PostgreSQL (Database)
- OpenAI/Anthropic (AI)

### Environment Variables
| Variable | Description | Required |
|----------|-------------|----------|
| SUPABASE_URL | Supabase project URL | Yes |
| SUPABASE_ANON_KEY | Supabase anonymous key | Yes |
| OPENAI_API_KEY | OpenAI API key | Yes |

### Contributing
See [Contributing Guide](docs/contributing/)

### License
MIT License - see [LICENSE](LICENSE)
```

Generate complete README with all sections.
```

**Expected Output:** Complete README with badges, quick start, and documentation links.

---

## 11.3 Generate API Docs

**Phase:** 11-Polish
**Output:** `docs/api/`
**Inputs:** OpenAPI spec

```
Generate API documentation for Social Media AI.

## API Documentation Structure

### Overview
```markdown
# API Overview

## Base URL
https://api.socialmediaai.com/v1

## Authentication
All API requests require a Bearer token:
Authorization: Bearer <your-token>

## Rate Limits
| Tier | Requests/min |
|------|--------------|
| Free | 100 |
| Starter | 500 |
| Pro | 1000 |
| Business | 5000 |

## Response Format
```json
{
  "success": true,
  "data": {},
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
```

## Error Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input"
  }
}
```
```

### Endpoint Documentation
For each endpoint:
```markdown
## POST /auth/register

### Description
Register a new user account.

### Request Body
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User email |
| password | string | Yes | Password (min 8 chars) |
| full_name | string | Yes | User's full name |

### Response (201)
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe"
  }
}
```

### Errors
| Code | Description |
|------|-------------|
| 422 | Validation error |
| 409 | Email already exists |
```

Generate complete API documentation for all endpoints.
```

**Expected Output:** Complete API documentation with examples and error codes.

---

## 11.4 Generate User Guides

**Phase:** 11-Polish
**Output:** `docs/guides/`
**Inputs:** Features, user flows

```
Generate user guides for Social Media AI.

## User Guides to Generate

### Getting Started Guide
1. Creating Your Account
2. Connecting Social Accounts
3. Your First Post
4. Understanding the Dashboard

### Content Creation Guide
1. Writing Posts
2. Using AI Assistance
3. Adding Media
4. Scheduling Content

### Analytics Guide
1. Understanding Metrics
2. Reading Reports
3. Exporting Data
4. Tracking Growth

### Team Collaboration Guide
1. Inviting Team Members
2. Managing Roles
3. Approval Workflows
4. Content Calendar Sharing

### AI Features Guide
1. Generating Captions
2. Hashtag Suggestions
3. Content Ideas
4. Trending Topics

## Guide Format
```markdown
# [Guide Title]

## What You'll Learn
- Learning objective 1
- Learning objective 2
- Learning objective 3

## Prerequisites
- Account created
- Social account connected

## Step-by-Step Instructions

### Step 1: [Action]
![Screenshot](images/screenshot.png)

Instructions with screenshots...

### Step 2: [Action]
Instructions...

## Tips
> Pro tip: [Helpful tip]

## Need Help?
- [FAQ](../faq/)
- [Contact Support](mailto:support@socialmediaai.com)
```

Generate comprehensive user guides with screenshots placeholders.
```

**Expected Output:** 10+ user guides covering all major features.

---

## 11.5 Generate Onboarding Flow

**Phase:** 11-Polish
**Output:** Onboarding implementation
**Inputs:** User personas, features

```
Generate onboarding flow for Social Media AI.

## Onboarding Steps

### Step 1: Welcome
```dart
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 100),
            SizedBox(height: 24),
            Text('Welcome to Social Media AI', style: AppTypography.h1),
            SizedBox(height: 16),
            Text('AI-powered social media management'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(context, OnboardingRoute()),
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 2: Connect Accounts
```dart
class ConnectAccountsScreen extends StatefulWidget {
  @override
  _ConnectAccountsScreenState createState() => _ConnectAccountsScreenState();
}

class _ConnectAccountsScreenState extends State<ConnectAccountsScreen> {
  final platforms = [
    Platform(name: 'Instagram', icon: Icons.camera_alt, color: Colors.pink),
    Platform(name: 'Twitter', icon: Icons.chat, color: Colors.blue),
    Platform(name: 'LinkedIn', icon: Icons.work, color: Colors.blue[800]),
    Platform(name: 'TikTok', icon: Icons.music_note, color: Colors.black),
    Platform(name: 'YouTube', icon: Icons.play_circle, color: Colors.red),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect Social Accounts')),
      body: ListView.builder(
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          return ListTile(
            leading: Icon(platform.icon, color: platform.color),
            title: Text(platform.name),
            trailing: ElevatedButton(
              onPressed: () => connectPlatform(platform),
              child: Text('Connect'),
            ),
          );
        },
      ),
    );
  }
}
```

### Step 3: Create First Post
```dart
class FirstPostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Your First Post')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome, size: 48),
                    SizedBox(height: 16),
                    Text('Let AI help you create content'),
                    SizedBox(height: 8),
                    Text('Describe what you want to post', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g., Share tips about social media marketing...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => generateContent(),
              icon: Icon(Icons.auto_awesome),
              label: Text('Generate with AI'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 4: Success
```dart
class OnboardingCompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 24),
            Text("You're all set!", style: AppTypography.h1),
            SizedBox(height: 16),
            Text('Start creating amazing content'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                DashboardRoute(),
                (route) => false,
              ),
              child: Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Generate complete onboarding flow with all screens.
```

**Expected Output:** Complete onboarding flow with 4 screens and progress tracking.

---

## 11.6 Generate Error Messages

**Phase:** 11-Polish
**Output:** Error handling system
**Inputs:** Error scenarios

```
Generate user-friendly error messages for Social Media AI.

## Error Message System

### Error Types
```dart
enum ErrorType {
  network,
  authentication,
  authorization,
  validation,
  notFound,
  server,
  rateLimit,
  unknown
}
```

### Error Messages
```dart
const errorMessages = {
  ErrorType.network: {
    'title': 'Connection Error',
    'message': 'Unable to connect to the server. Please check your internet connection.',
    'action': 'Retry',
  },
  ErrorType.authentication: {
    'title': 'Authentication Required',
    'message': 'Your session has expired. Please log in again.',
    'action': 'Log In',
  },
  ErrorType.authorization: {
    'title': 'Access Denied',
    'message': "You don't have permission to access this resource.",
    'action': 'Go Back',
  },
  ErrorType.validation: {
    'title': 'Invalid Input',
    'message': 'Please check your input and try again.',
    'action': 'OK',
  },
  ErrorType.notFound: {
    'title': 'Not Found',
    'message': 'The resource you're looking for doesn't exist.',
    'action': 'Go Home',
  },
  ErrorType.server: {
    'title': 'Server Error',
    'message': 'Something went wrong on our end. Please try again later.',
    'action': 'Retry',
  },
  ErrorType.rateLimit: {
    'title': 'Too Many Requests',
    'message': "You've made too many requests. Please wait a moment.",
    'action': 'OK',
  },
  ErrorType.unknown: {
    'title': 'Unexpected Error',
    'message': 'An unexpected error occurred. Please try again.',
    'action': 'Retry',
  }
};
```

### Error Widget
```dart
class ErrorWidget extends StatelessWidget {
  final ErrorType type;
  final String? customMessage;
  final VoidCallback? onRetry;
  
  const ErrorWidget({
    required this.type,
    this.customMessage,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    final error = errorMessages[type]!;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(error['title']!, style: AppTypography.h3),
            SizedBox(height: 8),
            Text(
              customMessage ?? error['message']!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: Text(error['action']!),
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.authorization:
        return Icons.block;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.rateLimit:
        return Icons.speed;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }
}
```

### SnackBar Errors
```dart
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ),
  );
}
```

Generate complete error handling system with user-friendly messages.
```

**Expected Output:** Complete error handling system with typed errors and user-friendly messages.
