# Tech Stack

## Overview

Detailed technology stack with versions, justifications, and alternatives considered.

## Frontend

### Flutter Framework

| Technology | Version | Purpose | Justification |
|------------|---------|---------|---------------|
| Flutter | 3.24.x | Cross-platform UI | Single codebase for Web, iOS, Android, Desktop |
| Dart | 3.5.x | Programming language | Type-safe,高性能, Hot reload |
| Riverpod | 2.6.x | State management | Testable, scalable, compile-time safe |
| GoRouter | 14.x | Navigation | Declarative routing, deep linking |
| Freezed | 2.5.x | Immutability | Code generation for models |
| json_serializable | 6.x | JSON parsing | Type-safe serialization |

### Flutter Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Navigation
  go_router: ^14.8.1
  
  # Network
  dio: ^5.7.0
  supabase_flutter: ^2.8.4
  
  # UI Components
  flutter_staggered_grid_view: ^0.7.0
  shimmer: ^3.0.0
  lottie: ^3.2.0
  
  # Storage
  shared_preferences: ^2.3.3
  flutter_secure_storage: ^9.2.4
  
  # Utilities
  intl: ^0.19.0
  url_launcher: ^6.3.1
  share_plus: ^10.1.4
  
  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.14
  freezed: ^2.5.8
  json_serializable: ^6.9.2
  riverpod_generator: ^2.6.3
  mockito: ^5.4.5
  integration_test:
    sdk: flutter
```

## Backend

### Supabase Stack

| Technology | Version | Purpose | Justification |
|------------|---------|---------|---------------|
| Supabase | 2.x | Backend-as-a-Service | Auth, DB, Realtime, Edge Functions |
| PostgreSQL | 15.x | Primary database | ACID, JSONB, RLS, Extensions |
| PostgREST | Latest | REST API | Auto-generated API from schema |
| GoTrue | Latest | Authentication | JWT, OAuth, MFA support |
| Realtime | Latest | WebSockets | Live subscriptions |
| Edge Functions | Deno | Serverless | Low latency, TypeScript |

### Supabase Configuration

```typescript
// supabase/config.toml
[project]
id = "your-project-ref"

[api]
enabled = true
port = 54321
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
max_rows = 1000

[db]
port = 54322
shadow_port = 54320
major_version = 15

[studio]
enabled = true
port = 54323
api_url = "http://localhost"

[auth]
enabled = true
site_url = "http://localhost:3000"
additional_redirect_urls = ["https://staging.contentos.ai"]
jwt_expiry = 3600
enable_refresh_token_rotation = true
refresh_token_reuse_interval = 10
enable_signup = true

[auth.email]
enable_signup = true
double_confirm_changes = true
enable_confirmations = false

[auth.external.google]
enabled = true
client_id = ""
secret = ""
redirect_uri = ""

[storage]
enabled = true
file_size_limit = "50MiB"

[realtime]
enabled = true
```

## Caching & Queues

### Redis + BullMQ

| Technology | Version | Purpose | Justification |
|------------|---------|---------|---------------|
| Redis | 7.x | Cache, Sessions, Queues | In-memory performance, pub/sub |
| BullMQ | 5.x | Job queues | Reliable, Redis-backed, prioritized |
| ioredis | 5.x | Redis client | Promise-based, cluster support |

### Redis Configuration

```typescript
// lib/config/redis.ts
import Redis from 'ioredis';
import { Queue, Worker } from 'bullmq';

const connection = new Redis({
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
  retryDelayOnFailover: 100,
  lazyConnect: true
});

// Queue configuration
const defaultQueueOptions = {
  connection,
  defaultJobOptions: {
    removeOnComplete: { age: 7 * 24 * 3600 },
    removeOnFail: { age: 30 * 24 * 3600 },
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 5000
    }
  }
};
```

## Storage

### Cloudflare R2

| Technology | Version | Purpose | Justification |
|------------|---------|---------|---------------|
| Cloudflare R2 | - | Object storage | S3-compatible, no egress fees |
| Cloudflare CDN | - | Content delivery | Global edge network |
| Cloudflare Workers | - | Edge compute | Low latency, serverless |

### R2 Configuration

```typescript
// lib/config/r2.ts
import { S3Client } from '@aws-sdk/client-s3';

const r2Client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID!,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY!
  }
});

// Bucket configuration
const bucketConfig = {
  name: process.env.R2_BUCKET_NAME || 'contentos-media',
  publicUrl: 'https://media.contentos.ai',
  maxFileSize: 50 * 1024 * 1024, // 50MB
  allowedMimeTypes: [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/webm',
    'application/pdf'
  ]
};
```

## AI Providers

| Provider | API Version | Models | Pricing (per 1M tokens) |
|----------|-------------|--------|-------------------------|
| OpenAI | v1 | GPT-4o, GPT-4, GPT-3.5 | $2.50-$60 |
| Anthropic | v2023-06-01 | Claude 3.5, Claude 3 | $3-$75 |
| Google AI | v1 | Gemini 1.5, Gemini Pro | $1.25-$10 |
| Local LLM | - | Llama 3, Mistral | Self-hosted |

### Provider Configuration

```typescript
// lib/config/ai-providers.ts
interface AIProviderConfig {
  name: string;
  apiKey: string;
  baseUrl: string;
  models: ModelConfig[];
  rateLimit: RateLimitConfig;
  timeout: number;
}

const aiProviders: Record<string, AIProviderConfig> = {
  openai: {
    name: 'openai',
    apiKey: process.env.OPENAI_API_KEY!,
    baseUrl: 'https://api.openai.com/v1',
    models: [
      { id: 'gpt-4o', maxTokens: 128000, costPer1k: { input: 0.005, output: 0.015 } },
      { id: 'gpt-4', maxTokens: 8192, costPer1k: { input: 0.03, output: 0.06 } },
      { id: 'gpt-3.5-turbo', maxTokens: 4096, costPer1k: { input: 0.0005, output: 0.0015 } }
    ],
    rateLimit: { rpm: 60, tpm: 90000 },
    timeout: 60000
  },
  anthropic: {
    name: 'anthropic',
    apiKey: process.env.ANTHROPIC_API_KEY!,
    baseUrl: 'https://api.anthropic.com',
    models: [
      { id: 'claude-3-5-sonnet', maxTokens: 200000, costPer1k: { input: 0.003, output: 0.015 } },
      { id: 'claude-3-opus', maxTokens: 200000, costPer1k: { input: 0.015, output: 0.075 } }
    ],
    rateLimit: { rpm: 40, tpm: 80000 },
    timeout: 60000
  },
  google: {
    name: 'google',
    apiKey: process.env.GOOGLE_AI_API_KEY!,
    baseUrl: 'https://generativelanguage.googleapis.com/v1',
    models: [
      { id: 'gemini-1.5-pro', maxTokens: 1000000, costPer1k: { input: 0.00125, output: 0.005 } },
      { id: 'gemini-1.5-flash', maxTokens: 1000000, costPer1k: { input: 0.000075, output: 0.0003 } }
    ],
    rateLimit: { rpm: 60, tpm: 120000 },
    timeout: 60000
  }
};
```

## Payment Processing

| Provider | Version | Purpose | Regions |
|----------|---------|---------|---------|
| Stripe | 2024-12 | Subscriptions, Invoices | Global |
| Razorpay | v1 | Subscriptions | India |
| Lemon Squeezy | - | Digital products | Global |

### Payment Configuration

```typescript
// lib/config/payments.ts
interface PaymentProviderConfig {
  name: string;
  apiKey: string;
  webhookSecret: string;
  supportedCurrencies: string[];
  features: string[];
}

const paymentProviders: Record<string, PaymentProviderConfig> = {
  stripe: {
    name: 'stripe',
    apiKey: process.env.STRIPE_SECRET_KEY!,
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET!,
    supportedCurrencies: ['usd', 'eur', 'gbp', 'inr', 'cad', 'aud'],
    features: ['subscriptions', 'invoices', 'usage-based', 'taxes']
  },
  razorpay: {
    name: 'razorpay',
    apiKey: process.env.RAZORPAY_KEY_ID!,
    webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET!,
    supportedCurrencies: ['inr', 'usd'],
    features: ['subscriptions', 'invoices']
  },
  lemonSqueezy: {
    name: 'lemonsqueezy',
    apiKey: process.env.LEMONSQUEEZY_API_KEY!,
    webhookSecret: process.env.LEMONSQUEEZY_WEBHOOK_SECRET!,
    supportedCurrencies: ['usd', 'eur', 'gbp'],
    features: ['subscriptions', 'digital-products']
  }
};
```

## Push Notifications

| Provider | Purpose | Platforms |
|----------|---------|-----------|
| Firebase Cloud Messaging | Mobile push | iOS, Android |
| OneSignal | Web push, Mobile | Web, iOS, Android |

### Notification Configuration

```typescript
// lib/config/notifications.ts
interface NotificationConfig {
  fcm: {
    projectId: string;
    privateKey: string;
    clientEmail: string;
  };
  oneSignal: {
    appId: string;
    apiKey: string;
    restApiKey: string;
  };
}

const notificationConfig: NotificationConfig = {
  fcm: {
    projectId: process.env.FCM_PROJECT_ID!,
    privateKey: process.env.FCM_PRIVATE_KEY!,
    clientEmail: process.env.FCM_CLIENT_EMAIL!
  },
  oneSignal: {
    appId: process.env.ONESIGNAL_APP_ID!,
    apiKey: process.env.ONESIGNAL_API_KEY!,
    restApiKey: process.env.ONESIGNAL_REST_API_KEY!
  }
};
```

## Analytics

| Provider | Purpose | Privacy |
|----------|---------|---------|
| PostHog | Product analytics, Feature flags | Self-hostable |
| Plausible | Web analytics | Privacy-first, GDPR compliant |

### Analytics Configuration

```typescript
// lib/config/analytics.ts
interface AnalyticsConfig {
  posthog: {
    apiKey: string;
    host: string;
  };
  plausible: {
    domain: string;
    apiSecret: string;
  };
}

const analyticsConfig: AnalyticsConfig = {
  posthog: {
    apiKey: process.env.POSTHOG_API_KEY!,
    host: process.env.POSTHOG_HOST || 'https://app.posthog.com'
  },
  plausible: {
    domain: 'contentos.ai',
    apiSecret: process.env.PLAUSIBLE_API_SECRET!
  }
};
```

## Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 20.x LTS | Runtime |
| TypeScript | 5.x | Type safety |
| ESLint | 9.x | Linting |
| Prettier | 3.x | Formatting |
| Vitest | 2.x | Unit testing |
| Playwright | 1.x | E2E testing |
| Supabase CLI | 2.x | Local development |
| Wrangler | 3.x | Cloudflare CLI |

### Development Dependencies

```json
{
  "devDependencies": {
    "@types/node": "^20.14.0",
    "typescript": "^5.5.0",
    "eslint": "^9.5.0",
    "prettier": "^3.3.0",
    "vitest": "^2.0.0",
    "@playwright/test": "^1.45.0",
    "supabase": "^2.0.0",
    "wrangler": "^3.60.0",
    "turbo": "^2.0.0"
  }
}
```

## Infrastructure

| Service | Provider | Purpose |
|---------|----------|---------|
| Hosting (Frontend) | Cloudflare Pages | Static hosting, CDN |
| Hosting (API) | Cloudflare Workers | Serverless compute |
| Database | Supabase (PostgreSQL) | Managed PostgreSQL |
| Object Storage | Cloudflare R2 | Media files |
| Cache/Queue | Upstash (Redis) | Managed Redis |
| DNS | Cloudflare | DNS management |
| SSL | Cloudflare | TLS certificates |
| Email | Resend | Transactional email |
| Monitoring | Sentry | Error tracking |

## Version Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    TECHNOLOGY VERSIONS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Frontend                                                       │
│  ├── Flutter SDK:           3.24.x                             │
│  ├── Dart:                  3.5.x                              │
│  ├── Riverpod:              2.6.x                              │
│  ├── GoRouter:              14.x                               │
│  └── Freezed:               2.5.x                              │
│                                                                 │
│  Backend                                                        │
│  ├── Supabase:              2.x                                │
│  ├── PostgreSQL:            15.x                               │
│  ├── Deno (Edge Functions): 1.x                                │
│  └── Node.js:               20.x LTS                           │
│                                                                 │
│  Infrastructure                                                 │
│  ├── Redis:                 7.x                                │
│  ├── BullMQ:                5.x                                │
│  ├── Cloudflare Workers:    Latest                             │
│  └── Cloudflare R2:         Latest                             │
│                                                                 │
│  AI Providers                                                   │
│  ├── OpenAI API:            v1                                 │
│  ├── Anthropic API:         v2023-06-01                        │
│  └── Google AI:             v1                                 │
│                                                                 │
│  Payments                                                       │
│  ├── Stripe:                2024-12                            │
│  ├── Razorpay:              v1                                 │
│  └── Lemon Squeezy:         Latest                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
