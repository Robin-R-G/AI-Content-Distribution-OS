# CI/CD Pipeline Guide

## Overview

This guide covers the Continuous Integration/Continuous Deployment pipeline, including GitHub Actions workflows, build processes, testing stages, and deployment procedures.

## GitHub Actions Workflows

### Main Workflow

```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  NODE_VERSION: '18'
  FLUTTER_VERSION: '3.16.0'

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run ESLint
        run: npm run lint
        
      - name: Run Prettier
        run: npm run format:check
        
      - name: Run TypeScript check
        run: npm run typecheck

  test:
    name: Test Suite
    runs-on: ubuntu-latest
    needs: lint
    
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
          
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run unit tests
        run: npm run test:unit
        
      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379
          
      - name: Run API tests
        run: npm run test:api
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: lint
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run npm audit
        run: npm audit --audit-level=moderate
        
      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          command: test
          args: --severity-threshold=high

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [test, security]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build application
        run: npm run build
        
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist/

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: staging
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Download build
        uses: actions/download-artifact@v3
        with:
          name: build
          path: dist/
          
      - name: Deploy to staging
        run: |
          echo "Deploying to staging..."
          # Add deployment script here
          
      - name: Run smoke tests
        run: npm run test:smoke
        env:
          BASE_URL: ${{ secrets.STAGING_URL }}

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Download build
        uses: actions/download-artifact@v3
        with:
          name: build
          path: dist/
          
      - name: Deploy to production
        run: |
          echo "Deploying to production..."
          # Add deployment script here
          
      - name: Run production tests
        run: npm run test:production
        env:
          BASE_URL: ${{ secrets.PRODUCTION_URL }}
          
      - name: Notify deployment
        run: |
          echo "Deployment completed successfully"
          # Add notification script here
```

### Flutter Workflow

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    name: Flutter Tests
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          
      - name: Install dependencies
        run: |
          cd mobile
          flutter pub get
          
      - name: Run tests
        run: |
          cd mobile
          flutter test
          
      - name: Run integration tests
        run: |
          cd mobile
          flutter test integration_test/

  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          
      - name: Build APK
        run: |
          cd mobile
          flutter build apk --release
          
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: mobile/build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: test
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          
      - name: Build iOS
        run: |
          cd mobile
          flutter build ios --release --no-codesign
          
      - name: Upload iOS build
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: mobile/build/ios/iphoneos/Runner.app
```

## Build, Test, Lint Stages

### Build Configuration

```json
// package.json
{
  "scripts": {
    "build": "tsc && vite build",
    "build:prod": "NODE_ENV=production npm run build",
    "build:staging": "NODE_ENV=staging npm run build",
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,css,scss}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,css,scss}\"",
    "typecheck": "tsc --noEmit",
    "test": "vitest",
    "test:unit": "vitest run --reporter=verbose",
    "test:integration": "vitest run --config vitest.config.integration.ts",
    "test:api": "vitest run --config vitest.config.api.ts",
    "test:e2e": "playwright test",
    "test:coverage": "vitest run --coverage",
    "test:watch": "vitest watch"
  }
}
```

### Test Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./tests/setup.ts'],
    include: ['src/**/*.test.ts'],
    exclude: ['node_modules', 'dist'],
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

### Lint Configuration

```javascript
// .eslintrc.js
module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:prettier/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  plugins: ['react', 'react-hooks', '@typescript-eslint'],
  rules: {
    'react/react-in-jsx-scope': 'off',
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/no-explicit-any': 'warn',
    'react/prop-types': 'off',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
};
```

## Deployment Stages

### Stage Configuration

```yaml
# .github/workflows/deployment-stages.yml
name: Deployment Stages

on:
  workflow_dispatch:
    inputs:
      stage:
        description: 'Deployment stage'
        required: true
        type: choice
        options:
          - development
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.stage }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to ${{ github.event.inputs.stage }}
        run: |
          echo "Deploying to ${{ github.event.inputs.stage }}"
          case "${{ github.event.inputs.stage }}" in
            development)
              npm run deploy:dev
              ;;
            staging)
              npm run deploy:staging
              ;;
            production)
              npm run deploy:prod
              ;;
          esac
          
      - name: Verify deployment
        run: |
          echo "Verifying deployment..."
          npm run verify:${{ github.event.inputs.stage }}
          
      - name: Run smoke tests
        run: |
          echo "Running smoke tests..."
          npm run test:smoke:${{ github.event.inputs.stage }}
```

## Environment Promotion

### Promotion Workflow

```yaml
# .github/workflows/promote.yml
name: Environment Promotion

on:
  workflow_dispatch:
    inputs:
      from:
        description: 'Source environment'
        required: true
        type: choice
        options:
          - staging
          - production
      to:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - production
          - production-canary

jobs:
  promote:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.to }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Promote from ${{ github.event.inputs.from }} to ${{ github.event.inputs.to }}
        run: |
          echo "Promoting from ${{ github.event.inputs.from }} to ${{ github.event.inputs.to }}"
          
      - name: Verify promotion
        run: |
          echo "Verifying promotion..."
          npm run verify:${{ github.event.inputs.to }}
          
      - name: Update environment variables
        run: |
          echo "Updating environment variables..."
          # Update environment-specific configurations
          
      - name: Notify completion
        run: |
          echo "Promotion completed successfully"
          # Send notification
```

## Rollback Procedures

### Automatic Rollback

```yaml
# .github/workflows/rollback.yml
name: Automatic Rollback

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback'
        required: true
        type: choice
        options:
          - staging
          - production
      reason:
        description: 'Reason for rollback'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Rollback deployment
        run: |
          echo "Rolling back ${{ github.event.inputs.environment }}"
          npm run rollback:${{ github.event.inputs.environment }}
          
      - name: Verify rollback
        run: |
          echo "Verifying rollback..."
          npm run verify:${{ github.event.inputs.environment }}
          
      - name: Notify rollback
        run: |
          echo "Rollback completed"
          echo "Reason: ${{ github.event.inputs.reason }}"
          # Send notification
```

### Manual Rollback

```bash
# Rollback to previous version
npm run rollback:previous

# Rollback to specific version
npm run rollback:to <version>

# Rollback database
npm run db:rollback

# Rollback feature flags
npm run features:rollback
```

## CI/CD Configuration

### Environment Secrets

```yaml
# GitHub Secrets
STAGING_URL: https://staging.socialmediaai.com
STAGING_DB_URL: postgresql://...
STAGING_API_KEY: ...

PRODUCTION_URL: https://socialmediaai.com
PRODUCTION_DB_URL: postgresql://...
PRODUCTION_API_KEY: ...

SNYK_TOKEN: ...
CODECOV_TOKEN: ...
DEPLOYMENT_KEY: ...
```

### Environment Variables

```yaml
# .github/workflows/env.yml
env:
  NODE_VERSION: '18'
  FLUTTER_VERSION: '3.16.0'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
```

### Caching Strategy

```yaml
# .github/workflows/caching.yml
- name: Cache Node.js modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

- name: Cache Flutter modules
  uses: actions/cache@v3
  with:
    path: |
      ~/flutter/pub-cache
      ~/flutter/.pub-cache
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-flutter-
```

## Running CI/CD Locally

### Local CI/CD Testing

```bash
# Run all CI checks locally
npm run ci

# Run lint
npm run lint

# Run tests
npm run test

# Run build
npm run build

# Run security scan
npm run security:scan

# Run full pipeline
npm run pipeline:local
```

### Act (GitHub Actions Local)

```bash
# Install act
brew install act  # macOS
choco install act  # Windows

# Run workflow locally
act push

# Run specific job
act -j lint

# Run with secrets
act --secret-file .secrets
```

## Best Practices

### 1. Pipeline Optimization
- Use caching effectively
- Run jobs in parallel
- Minimize build artifacts
- Use matrix builds

### 2. Security
- Never commit secrets
- Use environment protection
- Scan for vulnerabilities
- Use least privilege access

### 3. Monitoring
- Monitor pipeline performance
- Track build times
- Monitor failure rates
- Set up alerts

### 4. Documentation
- Document pipeline changes
- Update deployment guides
- Maintain runbooks
- Share knowledge

### 5. Continuous Improvement
- Regular pipeline reviews
- Optimize slow steps
- Update dependencies
- Adopt new tools