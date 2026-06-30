# Phase 10: Deployment Prompts

## 10.1 Generate CI/CD Pipeline

**Phase:** 10-Deployment
**Output:** `.github/workflows/`
**Inputs:** Deployment requirements

```
Generate CI/CD pipeline for Social Media AI.

## GitHub Actions Workflows

### ci.yml - Main CI Pipeline
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
env:
  FLUTTER_VERSION: '3.19.0'
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: dart format --set-exit-if-changed .
  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
  build-web:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      - uses: actions/upload-artifact@v4
  build-android:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - run: flutter build appbundle --release
  build-ios:
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
  deploy-staging:
    runs-on: ubuntu-latest
    needs: [build-web, build-android, build-ios]
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - run: supabase functions deploy
  deploy-production:
    runs-on: ubuntu-latest
    needs: [build-web, build-android, build-ios]
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4
      - run: supabase functions deploy
      - uses: cloudflare/wrangler-action@v3
```

### supabase-ci.yml - Database CI
```yaml
name: Supabase CI
on:
  push:
    paths:
      - 'supabase/migrations/**'
jobs:
  migrate-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
      - run: supabase db push --linked
  migrate-production:
    runs-on: ubuntu-latest
    needs: migrate-staging
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
      - run: supabase db push --linked
```

### security.yml - Security Scanning
```yaml
name: Security Scan
on:
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 0 * * *'
jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
  sast-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/analyze@v2
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: trufflesecurity/trufflehog@main
```

Generate complete CI/CD pipeline with all workflows.
```

**Expected Output:** Complete GitHub Actions workflows for CI, CD, and security scanning.

---

## 10.2 Generate Docker Configuration

**Phase:** 10-Deployment
**Output:** Docker files
**Inputs:** Application requirements

```
Generate Docker configuration for Social Media AI.

## Dockerfile (Flutter Web)
```dockerfile
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost/ || exit 1
```

## nginx.conf
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - supabase
      - redis
  supabase:
    image: supabase/supabase:latest
    ports:
      - "54321:54321"
    volumes:
      - supabase-data:/var/lib/postgresql/data
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
volumes:
  supabase-data:
```

Generate complete Docker configuration.
```

**Expected Output:** Complete Docker setup with Dockerfile, docker-compose, and nginx.

---

## 10.3 Generate Monitoring Setup

**Phase:** 10-Deployment
**Output:** Monitoring configuration
**Inputs:** Observability requirements

```
Generate monitoring setup for Social Media AI.

## Sentry Configuration
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static Future<void> init() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'your-dsn';
        options.tracesSampleRate = 1.0;
        options.attachScreenshot = true;
      },
      appRunner: () => runApp(SocialMediaAIApp()),
    );
  }
  
  static Future<void> captureException(
    dynamic exception,
    StackTrace? stackTrace,
  ) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
}
```

## Structured Logging
```dart
enum LogLevel { debug, info, warning, error, fatal }

class LoggerService {
  static void log(String message, {LogLevel level = LogLevel.info, String? tag}) {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'tag': tag ?? 'app',
      'message': message,
    };
    developer.log(message, name: tag ?? 'app');
  }
}
```

## Health Check Service
```dart
class HealthCheckService {
  Future<HealthStatus> check() async {
    final checks = await Future.wait([
      _checkDatabase(),
      _checkRedis(),
    ]);
    return HealthStatus(
      status: checks.every((c) => c.healthy) ? 'healthy' : 'degraded',
      checks: checks,
    );
  }
}
```

Generate complete monitoring setup with Sentry, logging, and health checks.
```

**Expected Output:** Complete monitoring setup with error tracking, logging, and health checks.

---

## 10.4 Generate Logging Configuration

**Phase:** 10-Deployment
**Output:** Logging configuration
**Inputs:** Logging requirements

```
Generate logging configuration for Social Media AI.

## Log Levels
- DEBUG: Detailed debug information
- INFO: General operational information
- WARNING: Unexpected but recoverable
- ERROR: Error conditions
- FATAL: Critical failures

## Structured Logging Format
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "info",
  "service": "social-media-ai",
  "trace_id": "abc123",
  "span_id": "def456",
  "message": "Post published successfully",
  "context": {
    "user_id": "user-123",
    "workspace_id": "ws-456",
    "post_id": "post-789",
    "platforms": ["instagram", "twitter"]
  }
}
```

## Logger Implementation
```dart
class StructuredLogger {
  final String serviceName;
  final String environment;
  
  void info(String message, {Map<String, dynamic>? context}) {
    _log('info', message, context);
  }
  
  void error(String message, {Error? error, Map<String, dynamic>? context}) {
    _log('error', message, context, error: error);
  }
  
  void _log(String level, String message, Map<String, dynamic>? context, {Error? error}) {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'service': serviceName,
      'environment': environment,
      'message': message,
      'context': context,
      if (error != null) 'error': error.toString(),
    };
    print(jsonEncode(entry));
  }
}
```

## Log Shipping
- Development: Console output
- Staging: Supabase Logs
- Production: Supabase Logs + Sentry

Generate complete logging configuration.
```

**Expected Output:** Complete logging configuration with structured logging and log shipping.

---

## 10.5 Generate Backup Scripts

**Phase:** 10-Deployment
**Output:** Backup scripts
**Inputs:** Backup requirements

```
Generate backup scripts for Social Media AI.

## Database Backup Script
```bash
#!/bin/bash
# backup-database.sh

BACKUP_DIR="/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Create backup
pg_dump \
  --host=$SUPABASE_DB_HOST \
  --port=$SUPABASE_DB_PORT \
  --username=$SUPABASE_DB_USER \
  --dbname=$SUPABASE_DB_NAME \
  --format=custom \
  --compress=9 \
  --file="$BACKUP_DIR/backup_$DATE.dump"

# Upload to storage
aws s3 cp "$BACKUP_DIR/backup_$DATE.dump" \
  "s3://backups/socialmediaai/database/"

# Clean old backups
find $BACKUP_DIR -name "backup_*.dump" -mtime +$RETENTION_DAYS -delete
```

## Storage Backup Script
```bash
#!/bin/bash
# backup-storage.sh

DATE=$(date +%Y%m%d)
SOURCE_BUCKET="socialmediaai-media"
BACKUP_BUCKET="socialmediaai-backups"

# Sync storage
aws s3 sync "s3://$SOURCE_BUCKET" \
  "s3://$BACKUP_BUCKET/storage/$DATE" \
  --storage-class STANDARD_IA
```

## Cron Schedule
```
# Database backup every 6 hours
0 */6 * * * /scripts/backup-database.sh

# Storage backup daily at 2 AM
0 2 * * * /scripts/backup-storage.sh

# Cleanup old backups weekly
0 3 * * 0 /scripts/cleanup-backups.sh
```

## Restore Script
```bash
#!/bin/bash
# restore-database.sh

BACKUP_FILE=$1
pg_restore \
  --host=$SUPABASE_DB_HOST \
  --port=$SUPABASE_DB_PORT \
  --username=$SUPABASE_DB_USER \
  --dbname=$SUPABASE_DB_NAME \
  --clean \
  --if-exists \
  "$BACKUP_FILE"
```

Generate complete backup and restore scripts.
```

**Expected Output:** Complete backup scripts for database and storage with scheduling.

---

## 10.6 Generate Deployment Scripts

**Phase:** 10-Deployment
**Output:** Deployment scripts
**Inputs:** Deployment requirements

```
Generate deployment scripts for Social Media AI.

## Deploy Script
```bash
#!/bin/bash
# deploy.sh

ENVIRONMENT=$1
VERSION=$2

echo "Deploying version $VERSION to $ENVIRONMENT..."

case $ENVIRONMENT in
  staging)
    echo "Deploying to staging..."
    supabase functions deploy --project-ref $STAGING_REF
    supabase db push --linked --project-ref $STAGING_REF
    ;;
  production)
    echo "Deploying to production..."
    supabase functions deploy --project-ref $PRODUCTION_REF
    supabase db push --linked --project-ref $PRODUCTION_REF
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

echo "Deployment complete!"
```

## Rollback Script
```bash
#!/bin/bash
# rollback.sh

ENVIRONMENT=$1
VERSION=$2

echo "Rolling back $ENVIRONMENT to version $VERSION..."

case $ENVIRONMENT in
  staging)
    supabase functions deploy --project-ref $STAGING_REF
    supabase db reset --linked --project-ref $STAGING_REF
    ;;
  production)
    supabase functions deploy --project-ref $PRODUCTION_REF
    supabase db reset --linked --project-ref $PRODUCTION_REF
    ;;
esac

echo "Rollback complete!"
```

## Migration Script
```bash
#!/bin/bash
# migrate.sh

ENVIRONMENT=$1
DIRECTION=$2

if [ "$DIRECTION" = "up" ]; then
  supabase db push --linked
elif [ "$DIRECTION" = "down" ]; then
  supabase db reset --linked
fi
```

Generate complete deployment scripts with rollback capability.
```

**Expected Output:** Complete deployment scripts for staging and production.
