# AI API

## POST /ai/generate/caption

Generate captions for social media posts.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `prompt` | string | Yes | Description of what to write about (10-500 chars) |
| `platform` | string | Yes | Target platform: `twitter`, `linkedin`, `facebook`, `instagram`, `tiktok` |
| `tone` | string | No | Tone: `professional`, `casual`, `humorous`, `inspirational`, `informative` |
| `length` | string | No | Length: `short`, `medium`, `long` |
| `includeHashtags` | boolean | No | Include relevant hashtags (default: false) |
| `includeEmojis` | boolean | No | Include emojis (default: false) |
| `context` | string | No | Additional context (max 1000 chars) |
| `brandVoice` | string | No | Brand voice guidelines |
| `count` | integer | No | Number of variations (1-5, default: 1) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "captions": [
      {
        "id": "gen_abc123",
        "content": "Excited to announce our latest feature update!",
        "platform": "linkedin",
        "characterCount": 178,
        "hashtags": ["#ProductUpdate", "#Innovation"],
        "wordCount": 28,
        "score": 85
      }
    ],
    "tokensUsed": 456,
    "creditsRemaining": 9544
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |
| 429 | `RATE_LIMITED` | AI rate limit exceeded |
| 503 | `SERVICE_UNAVAILABLE` | AI service temporarily unavailable |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/generate/caption \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "New product feature announcement",
    "platform": "linkedin",
    "tone": "professional",
    "length": "medium",
    "includeHashtags": true,
    "count": 3
  }'
```

---

## POST /ai/generate/title

Generate titles for blog posts, articles, or videos.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | string | Yes | Topic or subject (10-500 chars) |
| `type` | string | Yes | Type: `blog`, `video`, `article`, `newsletter`, `podcast` |
| `style` | string | No | Style: `listicle`, `how-to`, `question`, `statement`, `numbered` |
| `keywords` | string[] | No | Keywords to include |
| `count` | integer | No | Number of variations (1-10, default: 5) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "titles": [
      {
        "id": "gen_def456",
        "content": "10 Ways to Boost Your Social Media Engagement in 2025",
        "type": "blog",
        "style": "listicle",
        "wordCount": 10,
        "score": 92,
        "seoScore": 88
      }
    ],
    "tokensUsed": 320,
    "creditsRemaining": 9224
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |
| 429 | `RATE_LIMITED` | AI rate limit exceeded |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/generate/title \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Social media engagement strategies",
    "type": "blog",
    "style": "listicle",
    "keywords": ["engagement", "social media", "2025"],
    "count": 5
  }'
```

---

## POST /ai/generate/hashtags

Generate hashtags for social media posts.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Post content or topic (10-500 chars) |
| `platform` | string | Yes | Target platform |
| `count` | integer | No | Number of hashtags (5-30, default: 10) |
| `mix` | string | No | Mix: `trending`, `niche`, `branded`, `balanced` |
| `exclude` | string[] | No | Hashtags to exclude |

**Success Response:** `200 OK`

```json
{
  "data": {
    "hashtags": [
      {
        "tag": "#SocialMediaMarketing",
        "relevance": 95,
        "volume": "high",
        "difficulty": "medium",
        "category": "primary"
      },
      {
        "tag": "#ContentStrategy",
        "relevance": 88,
        "volume": "medium",
        "difficulty": "low",
        "category": "secondary"
      }
    ],
    "tokensUsed": 234,
    "creditsRemaining": 8990
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/generate/hashtags \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Tips for improving social media engagement",
    "platform": "instagram",
    "count": 15,
    "mix": "balanced"
  }'
```

---

## POST /ai/generate/thumbnail

Generate thumbnail ideas or descriptions for images/videos.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Content description or title (10-500 chars) |
| `type` | string | Yes | Type: `youtube`, `blog`, `instagram`, `thumbnail` |
| `style` | string | No | Style: `minimalist`, `bold`, `professional`, `creative`, `educational` |
| `count` | integer | No | Number of ideas (1-5, default: 3) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "ideas": [
      {
        "id": "gen_xyz789",
        "description": "Split-screen design with bold typography on the left",
        "elements": ["Bold sans-serif typography", "Split-screen layout", "Blue and orange color scheme"],
        "colorPalette": ["#1E40AF", "#F97316", "#FFFFFF"],
        "mood": "Professional and attention-grabbing",
        "score": 88
      }
    ],
    "tokensUsed": 345,
    "creditsRemaining": 8645
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/generate/thumbnail \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "10 tips for better social media engagement",
    "type": "youtube",
    "style": "bold",
    "count": 3
  }'
```

---

## POST /ai/generate/content-ideas

Generate content ideas based on topics or trends.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | string | Yes | Main topic or niche (10-500 chars) |
| `platforms` | string[] | Yes | Target platforms |
| `count` | integer | No | Number of ideas (1-20, default: 10) |
| `contentTypes` | string[] | No | Types: `post`, `reel`, `story`, `carousel`, `video`, `article` |
| `trendingTopics` | string[] | No | Current trending topics to incorporate |

**Success Response:** `200 OK`

```json
{
  "data": {
    "ideas": [
      {
        "id": "gen_idea1",
        "title": "Behind-the-scenes of our product development",
        "description": "Show the team working on the latest feature",
        "contentType": "reel",
        "platforms": ["instagram", "tiktok"],
        "engagementScore": 92,
        "difficulty": "easy",
        "estimatedTime": "30 minutes",
        "suggestedHashtags": ["#BTS", "#BehindTheScenes"]
      }
    ],
    "tokensUsed": 567,
    "creditsRemaining": 8078
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/generate/content-ideas \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "SaaS product marketing",
    "platforms": ["linkedin", "twitter"],
    "count": 10,
    "contentTypes": ["post", "carousel", "video"]
  }'
```

---

## POST /ai/generate/script

Generate video or podcast scripts.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | string | Yes | Script topic (10-500 chars) |
| `type` | string | Yes | Type: `youtube`, `tiktok`, `reel`, `podcast`, `webinar` |
| `duration` | integer | No | Target duration in seconds (30-3600) |
| `tone` | string | No | Tone: `professional`, `casual`, `energetic`, `educational` |
| `includeHooks` | boolean | No | Include attention hooks (default: true) |
| `includeCTA` | boolean | No | Include call-to-action (default: true) |
| `targetAudience` | string | No | Target audience description |

**Success Response:** `200 OK`

```json
{
  "data": {
    "script": {
      "id": "gen_script1",
      "title": "5 Social Media Tips for Small Businesses",
      "type": "youtube",
      "duration": 180,
      "wordCount": 350,
      "sections": [
        {
          "type": "hook",
          "timestamp": "0:00",
          "content": "Are you struggling to grow your small business on social media?",
          "duration": 10
        }
      ],
      "cta": "Hit that subscribe button and drop a comment below!",
      "tags": ["social media", "small business"]
    },
    "tokensUsed": 890,
    "creditsRemaining": 7188
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/generate/script \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Social media tips for small businesses",
    "type": "youtube",
    "duration": 180,
    "tone": "energetic"
  }'
```

---

## POST /ai/rewrite

Rewrite existing content for different platforms or tones.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Content to rewrite (10-10000 chars) |
| `instruction` | string | Yes | Rewrite instruction (10-500 chars) |
| `platform` | string | No | Target platform for format optimization |
| `tone` | string | No | New tone |
| `preserveLength` | boolean | No | Try to maintain similar length |

**Success Response:** `200 OK`

```json
{
  "data": {
    "rewritten": {
      "id": "gen_rewrite1",
      "content": "We're thrilled to unveil our latest innovation!",
      "originalWordCount": 45,
      "newWordCount": 38,
      "tone": "professional",
      "platform": "twitter",
      "improvements": ["More concise", "Stronger call-to-action"]
    },
    "tokensUsed": 345,
    "creditsRemaining": 6843
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/rewrite \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "We are excited to announce our new feature!",
    "instruction": "Make it more engaging and add emojis",
    "platform": "instagram",
    "tone": "casual"
  }'
```

---

## POST /ai/translate

Translate content to different languages.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Content to translate (10-10000 chars) |
| `targetLanguage` | string | Yes | Target language code (e.g., `es`, `fr`, `de`, `ja`) |
| `sourceLanguage` | string | No | Source language (auto-detected if omitted) |
| `preserveFormatting` | boolean | No | Preserve markdown/formatting (default: true) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "translated": {
      "id": "gen_translate1",
      "content": "Estamos emocionados de anunciar nuestra nueva funcion!",
      "originalLanguage": "en",
      "targetLanguage": "es",
      "confidence": 0.98,
      "preservedFormatting": true
    },
    "tokensUsed": 234,
    "creditsRemaining": 6609
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body or unsupported language |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/translate \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "We are excited to announce our new feature!",
    "targetLanguage": "es",
    "preserveFormatting": true
  }'
```

---

## POST /ai/predict/trend

Predict trending topics or content types.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `industry` | string | Yes | Industry or niche |
| `platform` | string | Yes | Target platform |
| `timeframe` | string | No | Prediction timeframe: `week`, `month`, `quarter` |
| `includeHistorical` | boolean | No | Include historical trend data (default: false) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "trends": [
      {
        "topic": "AI-powered content creation",
        "score": 95,
        "growth": "+340%",
        "timeframe": "month",
        "confidence": 0.92,
        "relatedTopics": ["generative AI", "content automation"],
        "suggestedContent": ["Tutorial", "Case study"]
      }
    ],
    "tokensUsed": 678,
    "creditsRemaining": 5931
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/predict/trend \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "industry": "SaaS",
    "platform": "linkedin",
    "timeframe": "month"
  }'
```

---

## POST /ai/predict/viral

Predict viral potential of content.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Content to analyze (10-5000 chars) |
| `platform` | string | Yes | Target platform |
| `mediaIds` | string[] | No | Attached media IDs |

**Success Response:** `200 OK`

```json
{
  "data": {
    "viralScore": 78,
    "confidence": 0.85,
    "factors": [
      {"factor": "Emotional trigger", "score": 90, "impact": "high"},
      {"factor": "Timing", "score": 75, "impact": "medium"},
      {"factor": "Visual appeal", "score": 82, "impact": "high"}
    ],
    "suggestions": [
      "Add a stronger hook in the first sentence",
      "Include a trending hashtag",
      "Post between 9-11 AM for maximum reach"
    ],
    "predictedReach": "15,000-25,000",
    "tokensUsed": 456,
    "creditsRemaining": 5475
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/predict/viral \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Excited to launch our new AI-powered content tool!",
    "platform": "twitter"
  }'
```

---

## POST /ai/repurpose

Repurpose content for different platforms.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Original content (10-10000 chars) |
| `targetPlatforms` | string[] | Yes | Platforms to repurpose for |
| `style` | string | No | Style: `adaptive`, `native`, `minimal` |
| `includeMedia` | boolean | No | Suggest media for each platform (default: true) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "repurposed": [
      {
        "platform": "twitter",
        "content": "Launching our new AI tool! Transform your content strategy in minutes. Try it free today.",
        "characterCount": 120,
        "mediaSuggestions": ["Product screenshot", "Demo video clip"],
        "hashtags": ["#AI", "#ContentMarketing"]
      },
      {
        "platform": "linkedin",
        "content": "We're thrilled to announce our new AI-powered content tool. After months of development, we're ready to help you transform your content strategy...",
        "characterCount": 890,
        "mediaSuggestions": ["Feature carousel", "Team photo"],
        "hashtags": ["#ProductLaunch", "#Innovation"]
      }
    ],
    "tokensUsed": 678,
    "creditsRemaining": 4797
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Insufficient credits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/repurpose \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "We are launching our new AI tool that helps create content 10x faster. It uses advanced models to generate captions, hashtags, and schedule posts automatically.",
    "targetPlatforms": ["twitter", "linkedin", "instagram"],
    "style": "native"
  }'
```

---

## GET /ai/prompts

List saved prompt templates.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `category` | string | No | Filter by category |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "prompt_abc123",
      "name": "Product Launch Caption",
      "category": "captions",
      "template": "Write a professional caption announcing {{product_name}}. Include 3-5 relevant hashtags.",
      "variables": ["product_name"],
      "platforms": ["linkedin", "twitter"],
      "usageCount": 45,
      "createdAt": "2025-06-01T10:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 12
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/ai/prompts?workspaceId=ws_abc123&category=captions" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /ai/prompts

Create a saved prompt template.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `name` | string | Yes | Prompt name (2-100 chars) |
| `category` | string | Yes | Category: `captions`, `titles`, `hashtags`, `scripts`, `custom` |
| `template` | string | Yes | Prompt template with {{variables}} (10-2000 chars) |
| `platforms` | string[] | No | Default platforms |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "prompt_def456",
    "name": "Weekly Newsletter Intro",
    "category": "custom",
    "template": "Write an engaging introduction for our weekly newsletter about {{topic}}. Keep it under 100 words.",
    "variables": ["topic"],
    "platforms": [],
    "usageCount": 0,
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/ai/prompts \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "name": "Weekly Newsletter Intro",
    "category": "custom",
    "template": "Write an engaging introduction for our weekly newsletter about {{topic}}. Keep it under 100 words."
  }'
```

---

## GET /ai/prompts/{promptId}

Get a specific prompt template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `promptId` | string | Prompt template ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "prompt_abc123",
    "name": "Product Launch Caption",
    "category": "captions",
    "template": "Write a professional caption announcing {{product_name}}. Include 3-5 relevant hashtags.",
    "variables": ["product_name"],
    "platforms": ["linkedin", "twitter"],
    "usageCount": 45,
    "createdAt": "2025-06-01T10:00:00Z",
    "updatedAt": "2025-06-15T14:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Prompt not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/ai/prompts/prompt_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /ai/prompts/{promptId}

Update a prompt template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `promptId` | string | Prompt template ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Prompt name |
| `template` | string | No | Prompt template |
| `platforms` | string[] | No | Default platforms |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "prompt_abc123",
    "name": "Updated Prompt Name",
    "template": "Updated template text with {{variable}}",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not prompt creator |
| 404 | `NOT_FOUND` | Prompt not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/ai/prompts/prompt_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Prompt Name",
    "template": "Updated template text with {{variable}}"
  }'
```

---

## DELETE /ai/prompts/{promptId}

Delete a prompt template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `promptId` | string | Prompt template ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not prompt creator |
| 404 | `NOT_FOUND` | Prompt not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/ai/prompts/prompt_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /ai/usage

Get AI usage statistics.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period: `day`, `week`, `month`, `year` (default: `month`) |
| `startDate` | string | No | Start date (ISO 8601) |
| `endDate` | string | No | End date (ISO 8601) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "totalCreditsUsed": 12450,
    "totalRequests": 342,
    "byFeature": [
      {"feature": "captions", "credits": 4500, "requests": 150},
      {"feature": "hashtags", "credits": 2100, "requests": 105},
      {"feature": "titles", "credits": 1800, "requests": 90},
      {"feature": "rewriting", "credits": 2400, "requests": 60},
      {"feature": "translation", "credits": 1650, "requests": 37}
    ],
    "dailyUsage": [
      {"date": "2025-06-01", "credits": 450, "requests": 12},
      {"date": "2025-06-02", "credits": 680, "requests": 18}
    ]
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/ai/usage?workspaceId=ws_abc123&period=month" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /ai/credits

Get current credit balance.

**Auth Required:** Yes

**Success Response:** `200 OK`

```json
{
  "data": {
    "balance": 87550,
    "plan": "pro",
    "monthlyAllocation": 100000,
    "usedThisMonth": 12450,
    "resetsAt": "2025-07-01T00:00:00Z",
    "purchaseHistory": [
      {
        "id": "cr_abc123",
        "amount": 10000,
        "cost": 29.99,
        "purchasedAt": "2025-06-15T10:00:00Z"
      }
    ]
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/ai/credits \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
