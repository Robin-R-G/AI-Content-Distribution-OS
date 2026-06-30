# Schedule API

## GET /schedule/calendar

Get scheduled posts for a calendar view.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `startDate` | string | Yes | Start date (ISO 8601) |
| `endDate` | string | Yes | End date (ISO 8601) |
| `platform` | string | No | Filter by platform |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-30",
      "end": "2025-07-06"
    },
    "scheduledPosts": [
      {
        "id": "post_abc123",
        "content": "Check out our new feature!",
        "platforms": ["twitter", "linkedin"],
        "scheduledAt": "2025-07-01T10:00:00Z",
        "status": "scheduled",
        "media": [
          {"id": "med_abc123", "type": "image", "thumbnail": "https://..."}
        ]
      }
    ],
    "calendarDays": [
      {
        "date": "2025-07-01",
        "postCount": 3,
        "platforms": ["twitter", "linkedin", "facebook"]
      },
      {
        "date": "2025-07-02",
        "postCount": 2,
        "platforms": ["instagram", "twitter"]
      }
    ],
    "summary": {
      "totalScheduled": 15,
      "byPlatform": [
        {"platform": "twitter", "count": 8},
        {"platform": "linkedin", "count": 5},
        {"platform": "facebook", "count": 2}
      ]
    }
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
curl "https://api.contentdistribution.ai/v1/schedule/calendar?workspaceId=ws_abc123&startDate=2025-06-30&endDate=2025-07-06" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /schedule/queue

Get the posting queue for a workspace.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `platform` | string | No | Filter by platform |
| `status` | string | No | Filter: `scheduled`, `publishing`, `published`, `failed` |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "post_abc123",
      "content": "Excited to share our latest update!",
      "platforms": ["twitter"],
      "scheduledAt": "2025-07-01T10:00:00Z",
      "status": "scheduled",
      "position": 1,
      "createdAt": "2025-06-30T12:00:00Z"
    },
    {
      "id": "post_def456",
      "content": "Behind the scenes of our team!",
      "platforms": ["instagram", "linkedin"],
      "scheduledAt": "2025-07-01T14:00:00Z",
      "status": "scheduled",
      "position": 2,
      "createdAt": "2025-06-30T11:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 15
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
curl "https://api.contentdistribution.ai/v1/schedule/queue?workspaceId=ws_abc123&status=scheduled" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /schedule/queue/reorder

Reorder posts in the queue.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `items` | array | Yes | Array of {postId, position} objects |

**Success Response:** `200 OK`

```json
{
  "data": {
    "reordered": 5,
    "message": "Queue order updated successfully"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Some posts not found |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/schedule/queue/reorder \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "items": [
      {"postId": "post_def456", "position": 1},
      {"postId": "post_abc123", "position": 2}
    ]
  }'
```

---

## GET /schedule/suggestions

Get AI-powered scheduling suggestions.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `platform` | string | No | Platform to get suggestions for |
| `count` | integer | No | Number of suggestions (default: 5) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "suggestions": [
      {
        "id": "sug_abc123",
        "scheduledAt": "2025-07-01T09:00:00Z",
        "platform": "twitter",
        "reason": "High engagement historically at this time",
        "confidence": 0.92,
        "estimatedReach": 15000,
        "estimatedEngagement": 450
      },
      {
        "id": "sug_def456",
        "scheduledAt": "2025-07-01T12:00:00Z",
        "platform": "linkedin",
        "reason": "Peak activity for your B2B audience",
        "confidence": 0.88,
        "estimatedReach": 8000,
        "estimatedEngagement": 320
      }
    ],
    "bestTimes": {
      "twitter": ["09:00", "12:00", "17:00"],
      "linkedin": ["08:00", "10:00", "12:00"]
    }
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
curl "https://api.contentdistribution.ai/v1/schedule/suggestions?workspaceId=ws_abc123&platform=twitter&count=5" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /schedule/{postId}/move

Move a scheduled post to a new time.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `postId` | string | Post ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `scheduledAt` | string | Yes | New scheduled time (ISO 8601) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "post_abc123",
    "scheduledAt": "2025-07-02T10:00:00Z",
    "status": "scheduled",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post already published |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/schedule/post_abc123/move \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "scheduledAt": "2025-07-02T10:00:00Z"
  }'
```

---

## POST /schedule/{postId}/pause

Pause a scheduled post.

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
    "status": "paused",
    "pausedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post not in scheduled state |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/schedule/post_abc123/pause \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /schedule/{postId}/resume

Resume a paused post.

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
    "status": "scheduled",
    "scheduledAt": "2025-07-01T10:00:00Z",
    "resumedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Post not found |
| 409 | `CONFLICT` | Post not paused |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/schedule/post_abc123/resume \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /schedule/settings

Get scheduling settings for a workspace.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "workspaceId": "ws_abc123",
    "timezone": "America/New_York",
    "autoSchedule": false,
    "postingHours": {
      "start": "08:00",
      "end": "22:00"
    },
    "postingDays": ["monday", "tuesday", "wednesday", "thursday", "friday"],
    "maxPostsPerDay": 5,
    "maxPostsPerPlatform": 3,
    "bufferMinutes": 30,
    "avoidConflicts": true
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
curl "https://api.contentdistribution.ai/v1/schedule/settings?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /schedule/settings

Update scheduling settings.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `timezone` | string | No | IANA timezone |
| `autoSchedule` | boolean | No | Enable auto-scheduling |
| `postingHours` | object | No | Start and end times |
| `postingDays` | string[] | No | Allowed posting days |
| `maxPostsPerDay` | integer | No | Max posts per day (1-20) |
| `maxPostsPerPlatform` | integer | No | Max posts per platform per day |
| `bufferMinutes` | integer | No | Minimum gap between posts (15-180) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "workspaceId": "ws_abc123",
    "timezone": "America/New_York",
    "autoSchedule": true,
    "postingHours": {
      "start": "09:00",
      "end": "21:00"
    },
    "postingDays": ["monday", "tuesday", "wednesday", "thursday", "friday"],
    "maxPostsPerDay": 4,
    "maxPostsPerPlatform": 2,
    "bufferMinutes": 60,
    "updatedAt": "2025-06-30T12:00:00Z"
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
curl -X PATCH https://api.contentdistribution.ai/v1/schedule/settings \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "autoSchedule": true,
    "maxPostsPerDay": 4
  }'
```
