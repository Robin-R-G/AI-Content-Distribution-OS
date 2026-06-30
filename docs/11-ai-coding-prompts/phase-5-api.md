# Phase 5: API Prompts

## 5.1 Generate Auth Endpoints

**Phase:** 5-API
**Output:** `supabase/functions/auth-*`
**Inputs:** Auth requirements, Supabase patterns

```
Generate authentication API endpoints for Social Media AI.

## Endpoints to Generate

### POST /auth/register
```typescript
// supabase/functions/auth-register/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { email, password, full_name } = await req.json()
  
  // Validate input
  // Create user with Supabase Auth
  // Insert user profile
  // Send verification email
  // Return user object
})
```

### POST /auth/login
Generate login endpoint with:
- Email/password validation
- Session creation
- Token generation
- Activity logging
- Rate limiting

### POST /auth/logout
Generate logout endpoint with:
- Token invalidation
- Session cleanup
- Audit logging

### POST /auth/refresh
Generate refresh endpoint with:
- Token validation
- New token generation
- Refresh token rotation
- Old token revocation

### POST /auth/forgot-password
Generate forgot password endpoint with:
- Email validation
- Reset token generation
- Email sending
- Rate limiting

### POST /auth/reset-password
Generate reset password endpoint with:
- Token validation
- Password update
- Session invalidation
- Confirmation email

### POST /auth/verify-email
Generate email verification endpoint with:
- Token validation
- Email confirmation
- Welcome email
- Account activation

### POST /auth/social/:provider
Generate social auth endpoint with:
- OAuth flow handling
- Account linking
- Profile sync
- Token management

## Helper Functions
Generate:
- JWT token generation
- Token validation
- Password hashing (bcrypt)
- Rate limiting middleware
- Input validation

## Error Handling
Standardize error responses:
- 400: Bad request
- 401: Unauthorized
- 403: Forbidden
- 404: Not found
- 409: Conflict
- 422: Validation error
- 429: Rate limited
- 500: Server error

Generate complete TypeScript code for all auth endpoints.
```

**Expected Output:** 8+ auth endpoints with complete TypeScript implementation.

---

## 5.2 Generate CRUD Endpoints

**Phase:** 5-API
**Output:** `supabase/functions/`
**Inputs:** Schema, REST conventions

```
Generate CRUD API endpoints for Social Media AI.

## Workspace Endpoints

### GET /workspaces
```typescript
// List user's workspaces
// Query params: page, limit, sort
// Returns: Workspace[] with pagination
```

### POST /workspaces
```typescript
// Create workspace
// Body: { name, slug, plan }
// Validates slug uniqueness
// Adds owner as member
```

### GET /workspaces/:id
```typescript
// Get workspace details
// Checks membership
// Returns workspace with stats
```

### PATCH /workspaces/:id
```typescript
// Update workspace
// Body: { name?, settings? }
// Owner/admin only
```

### DELETE /workspaces/:id
```typescript
// Soft delete workspace
// Owner only
// Cascades to members
```

## Post Endpoints

### GET /workspaces/:id/posts
```typescript
// List posts with filters
// Query params: status, platform, date_range, page, limit
// Returns: Post[] with pagination
```

### POST /workspaces/:id/posts
```typescript
// Create post
// Body: { content, media_ids?, scheduled_at?, tags? }
// Validates content
// Returns created post
```

### GET /workspaces/:id/posts/:postId
```typescript
// Get post details
// Includes publications
// Returns full post object
```

### PATCH /workspaces/:id/posts/:postId
```typescript
// Update post
// Body: partial post object
// Creator or admin only
```

### DELETE /workspaces/:id/posts/:postId
```typescript
// Soft delete post
// Creator or admin only
```

### POST /workspaces/:id/posts/:postId/publish
```typescript
// Publish post immediately
// Sends to connected platforms
// Updates status
```

### POST /workspaces/:id/posts/:postId/schedule
```typescript
// Schedule post
// Body: { scheduled_at, social_account_ids[] }
// Creates schedule entries
```

## Social Account Endpoints

### GET /workspaces/:id/social-accounts
### POST /workspaces/:id/social-accounts/connect
### DELETE /workspaces/:id/social-accounts/:accountId
### POST /workspaces/:id/social-accounts/:accountId/refresh

## Media Endpoints

### POST /workspaces/:id/media/upload
### GET /workspaces/:id/media
### DELETE /workspaces/:id/media/:mediaId

## Common Patterns
- Pagination with cursor
- Filtering with query params
- Sorting with sort param
- Field selection with select param
- Error handling middleware
- Rate limiting
- Audit logging

Generate complete CRUD endpoints for all resources.
```

**Expected Output:** 30+ CRUD endpoints with consistent patterns and error handling.

---

## 5.3 Generate AI Endpoints

**Phase:** 5-API
**Output:** `supabase/functions/ai-*`
**Inputs:** AI requirements, prompt library

```
Generate AI content generation endpoints for Social Media AI.

## Endpoints to Generate

### POST /ai/generate/caption
```typescript
// Generate caption for post
// Body: {
//   topic: string,
//   platform: string,
//   tone?: string,
//   length?: 'short' | 'medium' | 'long',
//   include_emojis?: boolean,
//   include_cta?: boolean
// }
// Returns: { caption, hashtags, tokens_used }
```

### POST /ai/generate/hashtags
```typescript
// Generate hashtags for content
// Body: {
//   content: string,
//   platform: string,
//   count?: number,
//   trending?: boolean
// }
// Returns: { hashtags: string[], categories: {} }
```

### POST /ai/generate/title
```typescript
// Generate title for content
// Body: {
//   content: string,
//   platform: string,
//   style?: string
// }
// Returns: { titles: string[] }
```

### POST /ai/generate/content
```typescript
// Repurpose content across platforms
// Body: {
//   source_content: string,
//   target_platforms: string[],
//   style?: string
// }
// Returns: { content: { [platform]: string } }
```

### POST /ai/generate/ideas
```typescript
// Generate content ideas
// Body: {
//   niche: string,
//   platform: string,
//   count?: number,
//   trending?: boolean
// }
// Returns: { ideas: string[] }
```

### POST /ai/generate/image-prompt
```typescript
// Generate image generation prompt
// Body: {
//   description: string,
//   style?: string,
//   aspect_ratio?: string
// }
// Returns: { prompt, negative_prompt }
```

### GET /ai/history
```typescript
// Get AI generation history
// Query params: type, page, limit
// Returns: Generation[] with pagination
```

### POST /ai/rate/:generationId
```typescript
// Rate AI generation
// Body: { rating: 1-5, feedback?: string }
```

## AI Service Layer
Generate:
- Prompt template management
- Provider abstraction (OpenAI, Anthropic)
- Response caching
- Token counting
- Rate limiting per user
- Error handling with retries

## Prompt Templates
Include templates for:
- Caption generation (5 tones)
- Hashtag generation (5 platforms)
- Title generation (5 styles)
- Content repurposing (6 platforms)

Generate complete AI endpoints with service layer.
```

**Expected Output:** 8+ AI endpoints with prompt templates and service layer.

---

## 5.4 Generate Analytics Endpoints

**Phase:** 5-API
**Output:** `supabase/functions/analytics-*`
**Inputs:** Analytics requirements, metrics

```
Generate analytics API endpoints for Social Media AI.

## Endpoints to Generate

### GET /workspaces/:id/analytics/overview
```typescript
// Get analytics overview
// Query params: period (7d, 30d, 90d), platforms[]
// Returns: {
//   followers: { total, change },
//   engagement: { rate, change },
//   reach: { total, change },
//   impressions: { total, change },
//   top_posts: Post[],
//   platform_breakdown: {}
// }
```

### GET /workspaces/:id/analytics/posts
```typescript
// Get post analytics
// Query params: post_id?, period, sort, page, limit
// Returns: PostAnalytics[]
```

### GET /workspaces/:id/analytics/audience
```typescript
// Get audience insights
// Returns: {
//   demographics: { age, gender, location },
//   active_hours: HeatmapData,
//   interests: string[],
//   growth: TimeSeriesData
// }
```

### GET /workspaces/:id/analytics/platforms/:platform
```typescript
// Get platform-specific analytics
// Returns: {
//   metrics: {},
//   content_type_performance: {},
//   best_times: [],
//   hashtag_performance: []
// }
```

### GET /workspaces/:id/analytics/competitors
```typescript
// Get competitor analytics
// Query params: competitor_ids[]
// Returns: CompetitorAnalytics[]
```

### GET /workspaces/:id/analytics/growth
```typescript
// Get growth analytics
// Query params: period, metrics[]
// Returns: {
//   followers: TimeSeriesData,
//   engagement: TimeSeriesData,
//   milestones: Milestone[]
// }
```

### POST /workspaces/:id/analytics/export
```typescript
// Export analytics report
// Body: { format: 'pdf' | 'csv', sections: string[] }
// Returns: { download_url }
```

### GET /workspaces/:id/analytics/custom
```typescript
// Custom report builder
// Query params: metrics[], dimensions[], filters{}, group_by
// Returns: CustomReportData
```

## Aggregation Functions
Generate:
- Real-time aggregation
- Historical aggregation
- Platform-specific aggregation
- Trending calculation
- Comparison calculation

## Caching Strategy
- Overview: 5 minutes
- Platform: 15 minutes
- Audience: 1 hour
- Growth: 6 hours

Generate complete analytics endpoints with aggregation logic.
```

**Expected Output:** 8+ analytics endpoints with aggregation and caching.

---

## 5.5 Generate Webhook Endpoints

**Phase:** 5-API
**Output:** `supabase/functions/webhook-*`
**Inputs:** Platform webhook specs

```
Generate webhook endpoints for Social Media AI.

## Platform Webhooks

### POST /webhooks/instagram
```typescript
// Handle Instagram webhooks
// Events: comments, mentions, story_insights
// Verify signature
// Process events
// Update analytics
```

### POST /webhooks/facebook
```typescript
// Handle Facebook webhooks
// Events: page_posts, comments, messages
// Verify signature
// Process events
// Update analytics
```

### POST /webhooks/twitter
```typescript
// Handle Twitter webhooks
// Events: tweets, mentions, dm
// Verify signature
// Process events
// Update analytics
```

### POST /webhooks/linkedin
```typescript
// Handle LinkedIn webhooks
// Events: posts, comments, reactions
// Verify signature
// Process events
// Update analytics
```

### POST /webhooks/tiktok
```typescript
// Handle TikTok webhooks
// Events: video_published, comments
// Verify signature
// Process events
// Update analytics
```

### POST /webhooks/youtube
```typescript
// Handle YouTube webhooks
// Events: video_published, comments
// Verify signature
// Process events
// Update analytics
```

## Internal Webhooks

### POST /webhooks/stripe
```typescript
// Handle Stripe webhooks
// Events: payment_succeeded, subscription_updated
// Verify signature
// Update user subscription
```

### POST /webhooks/scheduler
```typescript
// Handle scheduled post triggers
// Process queue
// Publish posts
// Handle failures
```

## Webhook Processing
Generate:
- Signature verification
- Event parsing
- Idempotency handling
- Retry logic
- Dead letter queue
- Event logging

## Event Types
Document all event types and payloads for each platform.

Generate complete webhook endpoints with event handling.
```

**Expected Output:** 8+ webhook endpoints with event processing and verification.

---

## 5.6 Generate OpenAPI Spec

**Phase:** 5-API
**Output:** `docs/05-api/openapi.yaml`
**Inputs:** All API endpoints

```
Generate complete OpenAPI 3.0 specification for Social Media AI.

## Specification Structure

### Info
```yaml
openapi: 3.0.3
info:
  title: Social Media AI API
  description: RESTful API for AI-powered social media management
  version: 1.0.0
  contact:
    name: API Support
    email: api@socialmediaai.com
  license:
    name: MIT
```

### Servers
```yaml
servers:
  - url: https://api.socialmediaai.com/v1
    description: Production
  - url: https://staging-api.socialmediaai.com/v1
    description: Staging
  - url: http://localhost:54321/functions/v1
    description: Local Development
```

### Security Schemes
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
```

### Paths (50+ endpoints)
Document all endpoints with:
- Summary
- Description
- Parameters
- Request body
- Responses
- Security
- Tags

### Schemas (30+ models)
Document all data models with:
- Properties
- Required fields
- Examples
- References

### Tags
- Auth
- Users
- Workspaces
- Posts
- Social Accounts
- AI Generation
- Analytics
- Media
- Notifications
- Webhooks

Generate complete OpenAPI YAML with all endpoints and schemas.
```

**Expected Output:** Complete OpenAPI 3.0 YAML specification with 50+ endpoints and 30+ schemas.
