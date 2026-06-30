# Posts API

## POST /posts

Create a new post.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Target workspace ID |
| `content` | string | Yes | Post content (max 10000 chars for text) |
| `platforms` | string[] | Yes | Target platforms: `twitter`, `linkedin`, `facebook`, `instagram`, `tiktok`, `youtube`, `pinterest` |
| `mediaIds` | string[] | No | Attached media IDs (max 10 for most platforms) |
| `scheduledAt` | string | No | ISO 8601 datetime for scheduling |
| `tags` | string[] | No | Content tags (max 20) |
| `category` | string | No | Content category |
| `variables` | object | No | Template variables for dynamic content |
| `metadata` | object | No | Custom metadata (max 500 chars JSON) |

**Validation Rules:**
- `content`: 1-10000 characters
- `platforms`: At least one valid platform
- `mediaIds`: Valid media IDs, max 10 per post
- `scheduledAt`: Must be future date if provided
- `tags`: Max 20 tags, each max 50 characters

**Platform-Specific Limits:**

| Platform | Max Content | Max Media | Max Hashtags |
|----------|------------|-----------|--------------|
| Twitter | 280 chars | 4 images | 10 |
| LinkedIn | 3000 chars | 20 images | 5 |
| Facebook | 63206 chars | 10 images | 30 |
| Instagram | 2200 chars | 10 images | 30 |
| TikTok | 2200 chars | 1 video | 0 |
| YouTube | 5000 chars | 1 video | 15 |
| Pinterest | 500 chars | 10 images | 0 |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "post_abc123",
    "workspaceId": "ws_abc123",
    "content": "Check out our latest product update!",
    "platforms": ["twitter", "linkedin"],
    "status": "draft",
    "media": [],
    "tags": ["product", "update"],
    "category": "announcement",
    "createdBy": "usr_abc123",
    "createdAt": "2025-06-30T12:00:00Z",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 404 | `NOT_FOUND` | Workspace not found |
| 409 | `CONFLICT` | Duplicate post detected |
| 422 | `UNPROCESSABLE` | Content exceeds platform limits |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "content": "Check out our latest product update!",
    "platforms": ["twitter", "linkedin"],
    "tags": ["product", "update"],
    "category": "announcement"
  }'
```

---

## GET /posts

List posts with filtering and pagination.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `sort` | string | No | Sort field (default: `-createdAt`) |
| `filter[status]` | string | No | Filter: `draft`, `scheduled`, `publishing`, `published`, `failed` |
| `filter[platform]` | string | No | Filter by platform |
| `filter[category]` | string | No | Filter by category |
| `filter[tags]` | string | No | Comma-separated tags |
| `filter[createdAt]` | string | No | Date range: `gte:2025-01-01`, `lte:2025-12-31` |
| `search` | string | No | Search in content |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "post_abc123",
      "content": "Check out our latest product update!",
      "platforms": ["twitter", "linkedin"],
      "status": "published",
      "media": [
        {
          "id": "med_abc123",
          "url": "https://cdn.example.com/media/med_abc123.jpg",
          "type": "image"
        }
      ],
      "tags": ["product", "update"],
      "scheduledAt": "2025-06-30T14:00:00Z",
      "publishedAt": "2025-06-30T14:00:05Z",
      "createdBy": {
        "id": "usr_abc123",
        "name": "John Doe"
      },
      "createdAt": "2025-06-29T12:00:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6InBvc3RfYWJjMTIzIn0=",
    "hasMore": true,
    "total": 156
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid query parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/posts?workspaceId=ws_abc123&filter[status]=published&sort=-publishedAt" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /posts/{postId}

Get a single post by ID.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `include` | string | No | Related: `versions`, `analytics`, `comments` |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "post_abc123",
    "workspaceId": "ws_abc123",
    "content": "Check out our latest product update!",
    "platforms": ["twitter", "linkedin"],
    "status": "published",
    "media": [
      {
        "id": "med_abc123",
        "url": "https://cdn.example.com/media/med_abc123.jpg",
        "type": "image",
        "alt": "Product screenshot"
      }
    ],
    "tags": ["product", "update"],
    "category": "announcement",
    "scheduledAt": "2025-06-30T14:00:00Z",
    "publishedAt": "2025-06-30T14:00:05Z",
    "publishResults": [
      {
        "platform": "twitter",
        "postId": "tw_123456789",
        "status": "published",
        "publishedAt": "2025-06-30T14:00:05Z",
        "url": "https://twitter.com/marketingco/status/123456789"
      },
      {
        "platform": "linkedin",
        "postId": "li_abc123def456",
        "status": "published",
        "publishedAt": "2025-06-30T14:00:10Z",
        "url": "https://linkedin.com/posts/marketingco_123456789"
      }
    ],
    "createdBy": {
      "id": "usr_abc123",
      "name": "John Doe",
      "avatar": "https://cdn.example.com/avatars/usr_abc123.jpg"
    },
    "createdAt": "2025-06-29T12:00:00Z",
    "updatedAt": "2025-06-30T14:00:10Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 404 | `NOT_FOUND` | Post not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/posts/post_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /posts/{postId}

Update a post (only draft or scheduled posts).

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | No | Post content |
| `platforms` | string[] | No | Target platforms |
| `mediaIds` | string[] | No | Attached media IDs |
| `scheduledAt` | string | No | New scheduling time |
| `tags` | string[] | No | Content tags |
| `category` | string | No | Content category |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "post_abc123",
    "content": "Updated post content!",
    "platforms": ["twitter", "linkedin", "facebook"],
    "status": "scheduled",
    "scheduledAt": "2025-07-01T10:00:00Z",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not post creator or insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post already published or publishing |
| 422 | `UNPROCESSABLE` | Cannot edit published post |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/posts/post_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Updated post content!",
    "scheduledAt": "2025-07-01T10:00:00Z"
  }'
```

---

## DELETE /posts/{postId}

Delete a post.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not post creator or insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post currently publishing |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/posts/post_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /posts/{postId}/publish

Publish a draft post immediately.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `platforms` | string[] | No | Override target platforms for this publish |
| `publishNow` | boolean | No | Force immediate publish (default: true) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "post_abc123",
    "status": "publishing",
    "publishResults": [
      {
        "platform": "twitter",
        "status": "publishing",
        "estimatedTime": "2025-06-30T12:00:30Z"
      }
    ],
    "publishedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post already published or publishing |
| 422 | `UNPROCESSABLE` | No connected accounts for target platforms |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts/post_abc123/publish \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "platforms": ["twitter", "linkedin"],
    "publishNow": true
  }'
```

---

## POST /posts/{postId}/versions

Create a version of a post for A/B testing.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Version content |
| `label` | string | No | Version label (e.g., "B", "Variant 2") |
| `mediaIds` | string[] | No | Version-specific media |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "postver_abc123",
    "postId": "post_abc123",
    "content": "Alternative version content",
    "label": "B",
    "media": [],
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Version label already exists |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts/post_abc123/versions \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Alternative version content",
    "label": "B"
  }'
```

---

## GET /posts/{postId}/versions

List all versions of a post.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "postver_abc123",
      "content": "Original content",
      "label": "A",
      "isOriginal": true,
      "createdAt": "2025-06-29T12:00:00Z"
    },
    {
      "id": "postver_def456",
      "content": "Alternative version content",
      "label": "B",
      "isOriginal": false,
      "createdAt": "2025-06-30T12:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 2
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Post not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/posts/post_abc123/versions \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /posts/{postId}/analytics

Get analytics for a specific post.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `platform` | string | No | Filter by platform |
| `dateRange` | string | No | Date range: `7d`, `30d`, `90d`, `all` |

**Success Response:** `200 OK`

```json
{
  "data": {
    "postId": "post_abc123",
    "impressions": 15420,
    "reach": 12300,
    "engagement": 892,
    "engagementRate": 5.78,
    "clicks": 234,
    "likes": 456,
    "comments": 89,
    "shares": 113,
    "saves": 0,
    "platforms": {
      "twitter": {
        "impressions": 8420,
        "reach": 6700,
        "engagement": 520,
        "engagementRate": 6.18,
        "likes": 280,
        "retweets": 156,
        "replies": 84,
        "url": "https://twitter.com/marketingco/status/123456789"
      },
      "linkedin": {
        "impressions": 7000,
        "reach": 5600,
        "engagement": 372,
        "engagementRate": 5.31,
        "likes": 176,
        "comments": 89,
        "reposts": 107,
        "url": "https://linkedin.com/posts/marketingco_123456789"
      }
    },
    "period": {
      "start": "2025-06-30T00:00:00Z",
      "end": "2025-06-30T12:00:00Z"
    }
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Post not found |
| 422 | `UNPROCESSABLE` | Analytics not available yet |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/posts/post_abc123/analytics?dateRange=30d" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /posts/schedule

Schedule multiple posts at once.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Target workspace ID |
| `posts` | array | Yes | Array of post objects (max 50) |

**Post Object:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Post content |
| `platforms` | string[] | Yes | Target platforms |
| `scheduledAt` | string | Yes | ISO 8601 datetime |
| `mediaIds` | string[] | No | Attached media IDs |
| `tags` | string[] | No | Content tags |

**Success Response:** `201 Created`

```json
{
  "data": {
    "scheduled": [
      {
        "id": "post_abc123",
        "content": "Post 1 content",
        "scheduledAt": "2025-07-01T10:00:00Z",
        "status": "scheduled"
      },
      {
        "id": "post_def456",
        "content": "Post 2 content",
        "scheduledAt": "2025-07-02T10:00:00Z",
        "status": "scheduled"
      }
    ],
    "failed": [],
    "summary": {
      "total": 2,
      "scheduled": 2,
      "failed": 0
    }
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 422 | `UNPROCESSABLE` | Some posts failed validation |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts/schedule \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "posts": [
      {
        "content": "Post 1 content",
        "platforms": ["twitter"],
        "scheduledAt": "2025-07-01T10:00:00Z"
      },
      {
        "content": "Post 2 content",
        "platforms": ["linkedin"],
        "scheduledAt": "2025-07-02T10:00:00Z"
      }
    ]
  }'
```

---

## POST /posts/bulk-schedule

Bulk schedule posts with CSV or JSON file upload.

**Auth Required:** Yes

**Request Body:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | file | Yes | CSV or JSON file with post data |
| `workspaceId` | string | Yes | Target workspace ID |
| `defaultTime` | string | No | Default time if not specified in file |
| `timezone` | string | No | Timezone for scheduling (default: UTC) |

**CSV Format:**

```csv
content,platforms,scheduledAt,tags
"Post 1 content","twitter,linkedin","2025-07-01 10:00","product,update"
"Post 2 content","facebook","2025-07-02 14:00","announcement"
```

**Success Response:** `200 OK`

```json
{
  "data": {
    "jobId": "job_abc123",
    "status": "processing",
    "totalPosts": 50,
    "estimatedCompletionAt": "2025-06-30T12:05:00Z",
    "message": "Bulk upload is being processed. Check status at /jobs/{jobId}"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid file format |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 413 | `PAYLOAD_TOO_LARGE` | File exceeds 10MB limit |
| 422 | `UNPROCESSABLE` | Invalid CSV/JSON structure |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts/bulk-schedule \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -F "file=@/path/to/posts.csv" \
  -F "workspaceId=ws_abc123" \
  -F "defaultTime=10:00" \
  -F "timezone=America/New_York"
```

---

## POST /posts/{postId}/cancel

Cancel a scheduled post.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "post_abc123",
    "status": "draft",
    "scheduledAt": null,
    "cancelledAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post already published or publishing |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts/post_abc123/cancel \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /posts/{postId}/duplicate

Duplicate an existing post.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID to duplicate |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `scheduledAt` | string | No | Schedule the duplicate for a specific time |
| `content` | string | No | Override content for the duplicate |
| `platforms` | string[] | No | Override platforms |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "post_xyz789",
    "content": "Check out our latest product update!",
    "platforms": ["twitter"],
    "status": "draft",
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Source post not found |
| 422 | `UNPROCESSABLE` | Cannot duplicate currently publishing post |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/posts/post_abc123/duplicate \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "scheduledAt": "2025-07-01T10:00:00Z",
    "platforms": ["twitter"]
  }'
```
