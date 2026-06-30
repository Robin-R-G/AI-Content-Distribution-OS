# Integration Architecture Overview

The AI Content Distribution OS uses a unified plugin-based integration architecture to connect with social platforms, storage providers, design tools, and cloud services.

## Plugin Framework

All integrations implement a common `IntegrationPlugin` interface:

```typescript
interface IntegrationPlugin {
  id: string;
  name: string;
  version: string;
  category: 'social' | 'storage' | 'design' | 'cloud';

  initialize(config: PluginConfig): Promise<void>;
  authenticate(credentials: Credentials): Promise<AuthResult>;
 健康check(): Promise<HealthStatus>;
  execute<T>(action: string, params: unknown): Promise<T>;
  getRateLimit(): RateLimitInfo;
  validateConfig(config: unknown): ValidationResult;
}
```

## Authentication Flows

### OAuth 2.0 Flow (Primary)
1. Authorization request → User consent
2. Authorization code → Token exchange
3. Access token + Refresh token stored encrypted
4. Automatic token refresh before expiry

### API Key Flow
1. Static API key stored in secrets manager
2. Passed via headers on each request
3. Rotation via cron job

### JWT/Service Account Flow
1. Generate signed JWT with private key
2. Exchange JWT for short-lived access token
3. Token cached until expiry

## Rate Limiting

Each integration tracks rate limits independently:

```typescript
interface RateLimitInfo {
  platform: string;
  requests: { window: number; max: number; current: number };
  tokens?: { max: number; remaining: number; resetAt: number };
}
```

- **Adaptive throttling**: Automatically slows requests when approaching limits
- **Queue-based**: Requests queued when rate-limited, processed as quota resets
- **Per-user tracking**: Separate limits per authenticated account

## Error Handling

### Standard Error Codes
| Code | Meaning | Action |
|------|---------|--------|
| `AUTH_EXPIRED` | Token expired | Refresh token |
| `AUTH_REVOKED` | Access revoked | Re-authenticate |
| `RATE_LIMITED` | Quota exceeded | Queue + retry |
| `CONTENT_REJECTED` | Platform rejected content | Retry with modifications |
| `TEMPORARY` | Transient error | Exponential backoff |
| `PERMANENT` | Non-retryable error | Log and alert |

### Retry Strategy
```
Attempt 1: Immediate
Attempt 2: 1 second
Attempt 3: 5 seconds
Attempt 4: 30 seconds
Attempt 5: 5 minutes (max retries)
```

## Webhook Handling

### Incoming Webhooks
- Registered per-platform with unique endpoints
- HMAC-SHA256 signature verification
- Idempotency via `event_id` deduplication
- Queue-based async processing

### Outgoing Webhooks
- Event subscriptions configured per integration
- Payload signed with project HMAC secret
- Retry with exponential backoff (3 attempts)
- Dead letter queue for failed deliveries

## Plugin Lifecycle

```
Register → Configure → Authenticate → Health Check → Execute → Deactivate
```

Each stage emits events for monitoring and logging.

## File Structure

```
07-integrations/
├── overview.md              ← This file
├── plugin-framework.md      ← Plugin development guide
├── social/                  ← Social platform integrations
├── storage/                 ← Cloud storage integrations
├── design/                  ← Design tool integrations
├── cloud/                   ← Cloud service integrations
├── webhooks.md              ← Webhook system
├── rate-limits.md           ← Rate limit reference
└── oauth-flows.md           ← OAuth flow diagrams
```
