# Local Development Setup Guide

## Overview

This guide covers setting up the development environment for local development, including prerequisites, repository setup, environment configuration, and debugging.

## Prerequisites

### Required Software

```markdown
## Required Software

### Node.js
- Version: 18.x or higher
- Download: https://nodejs.org/
- Verify: `node --version`

### npm or yarn
- npm: Comes with Node.js
- Yarn: `npm install -g yarn`
- Verify: `npm --version` or `yarn --version`

### Flutter SDK
- Version: 3.16.0 or higher
- Download: https://flutter.dev/docs/get-started/install
- Verify: `flutter --version`

### Dart SDK
- Comes with Flutter
- Verify: `dart --version`

### Git
- Version: 2.30.0 or higher
- Download: https://git-scm.com/
- Verify: `git --version`

### Docker
- Version: 20.10.0 or higher
- Download: https://www.docker.com/products/docker-desktop
- Verify: `docker --version`

### Docker Compose
- Version: 2.0.0 or higher
- Comes with Docker Desktop
- Verify: `docker-compose --version`

### Supabase CLI
- Install: `npm install -g supabase`
- Verify: `supabase --version`

### IDE/Editor
- VS Code (recommended)
- Android Studio (for Flutter)
- IntelliJ IDEA
```

### VS Code Extensions

```json
// .vscode/extensions.json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "flutter/flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "streetsidesoftware.code-spell-checker",
    "eamodio.gitlens"
  ]
}
```

## Repository Setup

### Clone Repository

```bash
# Clone the repository
git clone https://github.com/your-org/social-media-ai.git

# Navigate to project directory
cd social-media-ai

# Install dependencies
npm install

# Install Flutter dependencies
cd mobile
flutter pub get
cd ..
```

### Initial Setup

```bash
# Run setup script
npm run setup

# Or manually:
# 1. Copy environment file
cp .env.example .env

# 2. Generate environment variables
npm run env:generate

# 3. Start local Supabase
supabase start

# 4. Run database migrations
supabase db reset

# 5. Seed test data
npm run db:seed

# 6. Start development server
npm run dev
```

## Environment Variables

### Environment File Structure

```bash
# .env.example

# Application
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# Database (Supabase)
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-role-key
DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres

# Authentication
JWT_SECRET=your-local-jwt-secret
JWT_EXPIRATION=7d

# AI Services
OPENAI_API_KEY=your-openai-api-key
AI_MODEL=gpt-4

# Email
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASS=

# Redis
REDIS_URL=redis://localhost:6379

# Storage
STORAGE_BUCKET=media
STORAGE_ENDPOINT=http://localhost:54321/storage/v1

# Logging
LOG_LEVEL=debug
LOG_FORMAT=pretty

# Feature Flags
ENABLE_AI_FEATURES=true
ENABLE_ANALYTICS=false
```

### Environment Variable Validation

```typescript
// src/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']),
  PORT: z.coerce.number().default(3000),
  APP_URL: z.string().url(),
  SUPABASE_URL: z.string().url(),
  SUPABASE_ANON_KEY: z.string(),
  SUPABASE_SERVICE_ROLE_KEY: z.string(),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRATION: z.string().default('7d'),
  OPENAI_API_KEY: z.string().optional(),
  AI_MODEL: z.string().default('gpt-4'),
  REDIS_URL: z.string().url(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const env = envSchema.parse(process.env);
```

## Database Setup (Supabase Local)

### Starting Supabase

```bash
# Start Supabase services
supabase start

# Check status
supabase status

# View logs
supabase logs

# Stop services
supabase stop
```

### Database Migrations

```bash
# Create new migration
supabase migration new create_users_table

# Run migrations
supabase db reset

# Or run specific migration
supabase db push
```

### Database Seeding

```bash
# Seed test data
npm run db:seed

# Or manually
supabase db seed

# Reset and seed
supabase db reset --seed
```

### Database Management

```bash
# Open Supabase Studio
open http://localhost:54323

# Connect to database
psql postgresql://postgres:postgres@localhost:54322/postgres

# Backup database
pg_dump -h localhost -p 54322 -U postgres postgres > backup.sql

# Restore database
psql -h localhost -p 54322 -U postgres postgres < backup.sql
```

## Running Locally

### Development Server

```bash
# Start development server
npm run dev

# Or with specific port
PORT=3001 npm run dev

# Start with debugging
npm run dev:debug

# Start with live reload
npm run dev:live
```

### Flutter Development

```bash
# Navigate to mobile directory
cd mobile

# Run on emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with debugging
flutter run --debug

# Run with profiling
flutter run --profile
```

### Running All Services

```bash
# Start all services
docker-compose up -d

# Or start specific services
docker-compose up -d postgres redis

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Hot Reload

### Backend Hot Reload

```bash
# Using nodemon
npm run dev:nodemon

# Using ts-node-dev
npm run dev:ts-node-dev

# With file watching
npm run dev:watch
```

### Frontend Hot Reload

```bash
# Flutter hot reload
flutter run --hot

# Or use IDE hot reload
# VS Code: Save file triggers hot reload
# Android Studio: Save file triggers hot reload
```

### Configuration Hot Reload

```bash
# Watch for config changes
npm run dev:config-watch

# Reload environment variables
npm run env:reload
```

## Debugging

### Backend Debugging

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch API Server",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/src/index.ts",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "envFile": "${workspaceFolder}/.env",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    },
    {
      "name": "Debug Tests",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/.bin/vitest",
      "args": ["--runInBand"],
      "envFile": "${workspaceFolder}/.env.test",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    },
    {
      "name": "Attach to Process",
      "type": "node",
      "request": "attach",
      "port": 9229,
      "restart": true,
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    }
  ]
}
```

### Flutter Debugging

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--flavor", "development"],
      "flutterMode": "debug"
    },
    {
      "name": "Flutter Profile",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--flavor", "development"],
      "flutterMode": "profile"
    }
  ]
}
```

### Database Debugging

```bash
# Enable query logging
LOG_QUERIES=true npm run dev

# Use pgAdmin
open http://localhost:5050

# Use Supabase Studio
open http://localhost:54323
```

### API Debugging

```bash
# Using curl
curl -H "Authorization: Bearer <token>" http://localhost:3000/api/posts

# Using httpie
http GET localhost:3000/api/posts Authorization:"Bearer <token>"

# Using Postman
# Import collection from /docs/api/postman.json
```

## Troubleshooting

### Common Issues

```markdown
## Common Issues and Solutions

### Port Already in Use
```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
PORT=3001 npm run dev
```

### Database Connection Issues
```bash
# Check Supabase status
supabase status

# Restart Supabase
supabase stop
supabase start

# Check database connection
psql postgresql://postgres:postgres@localhost:54322/postgres
```

### Node Modules Issues
```bash
# Clear node_modules
rm -rf node_modules

# Clear npm cache
npm cache clean --force

# Reinstall dependencies
npm install
```

### Flutter Issues
```bash
# Clean Flutter
flutter clean

# Get dependencies
flutter pub get

# Run doctor
flutter doctor
```

### Environment Variable Issues
```bash
# Validate environment
npm run env:validate

# Regenerate environment
npm run env:generate

# Check for missing variables
npm run env:check
```

## IDE Configuration

### VS Code Settings

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.tsdk": "node_modules/typescript/lib",
  "dart.flutterSdkPath": "mobile",
  "dart.testPaths": ["mobile/test"],
  "files.exclude": {
    "**/node_modules": true,
    "**/.git": true,
    "**/dist": true,
    "**/.next": true
  }
}
```

### EditorConfig

```ini
# .editorconfig
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false

[*.{json,yml,yaml}]
indent_size = 2

[*.ts]
indent_size = 2

[*.dart]
indent_size = 2
```

## Development Workflow

### Daily Workflow

```bash
# 1. Pull latest changes
git pull origin main

# 2. Install dependencies
npm install

# 3. Start services
supabase start
npm run dev

# 4. Run tests
npm test

# 5. Start development
# Make changes...

# 6. Run linter
npm run lint

# 7. Run type check
npm run typecheck

# 8. Commit changes
git add .
git commit -m "feat: add new feature"

# 9. Push changes
git push origin feature-branch
```

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes
# ...

# 3. Write tests
npm run test:unit

# 4. Run full test suite
npm test

# 5. Create pull request
git push origin feature/new-feature
# Create PR on GitHub
```

## Getting Help

### Resources
- Documentation: /docs
- API Reference: /docs/api
- Troubleshooting: /docs/troubleshooting
- FAQ: /docs/faq

### Support
- Slack: #dev-support
- Email: dev-support@example.com
- Office Hours: Fridays 2-3 PM