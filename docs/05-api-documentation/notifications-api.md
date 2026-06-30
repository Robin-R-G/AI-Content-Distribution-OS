# Notifications API

## GET /notifications

List notifications for the authenticated user.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `type` | string | No | Filter: `post_published`, `post_failed`, `comment`, `mention`, `team`, `billing`, `system` |
| `read` | boolean | No | Filter by read status |
| `workspaceId` | string | No | Filter by workspace |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "ntf_abc123",
      "type": "post_published",
      "title": "Post Published Successfully",
      "message": "Your post has been published to Twitter",
      "data": {
        "postId": "post_abc123",
        "platform": "twitter",
        "url": "https://twitter.com/marketingco/status/123456789"
      },
      "read": false,
      "createdAt": "2025-06-30T12:00:00Z"
    },
    {
      "id": "ntf_def456",
      "type": "team",
      "title": "New Team Member",
      "message": "Jane Smith joined the Marketing workspace",
      "data": {
        "userId": "usr_def456",
        "workspaceId": "ws_abc123"
      },
      "read": true,
      "createdAt": "2025-06-30T10:00:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6Im50Zl9hYmMxMjMifQ==",
    "hasMore": true,
    "total": 156
  },
  "unreadCount": 23
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid query parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/notifications?type=post_published&read=false" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /notifications/{notificationId}

Get a specific notification.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `notificationId` | string | Notification ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "ntf_abc123",
    "type": "post_published",
    "title": "Post Published Successfully",
    "message": "Your post has been published to Twitter",
    "data": {
      "postId": "post_abc123",
      "platform": "twitter",
      "url": "https://twitter.com/marketingco/status/123456789",
      "content": "Check out our latest feature!"
    },
    "read": false,
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Notification not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/notifications/ntf_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /notifications/{notificationId}/read

Mark a notification as read.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `notificationId` | string | Notification ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "ntf_abc123",
    "read": true,
    "readAt": "2025-06-30T12:05:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Notification not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/notifications/ntf_abc123/read \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /notifications/read-all

Mark all notifications as read.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `before` | string | No | Mark all before this timestamp as read |
| `type` | string | No | Only mark specific type as read |

**Success Response:** `200 OK`

```json
{
  "data": {
    "markedCount": 23,
    "message": "All notifications marked as read"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/notifications/read-all \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "before": "2025-06-30T12:00:00Z"
  }'
```

---

## DELETE /notifications/{notificationId}

Delete a notification.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `notificationId` | string | Notification ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Notification not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/notifications/ntf_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /notifications/preferences

Get notification preferences.

**Auth Required:** Yes

**Success Response:** `200 OK`

```json
{
  "data": {
    "email": {
      "postPublished": true,
      "postFailed": true,
      "teamUpdates": true,
      "billingAlerts": true,
      "weeklyDigest": true,
      "productUpdates": false
    },
    "push": {
      "postPublished": true,
      "postFailed": true,
      "teamUpdates": false,
      "comments": true,
      "mentions": true
    },
    "inApp": {
      "all": true
    },
    "digestFrequency": "daily",
    "quietHoursStart": "22:00",
    "quietHoursEnd": "08:00",
    "timezone": "America/New_York"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/notifications/preferences \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /notifications/preferences

Update notification preferences.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | object | No | Email notification settings |
| `push` | object | No | Push notification settings |
| `inApp` | object | No | In-app notification settings |
| `digestFrequency` | string | No | `daily`, `weekly`, `none` |
| `quietHoursStart` | string | No | Quiet hours start (HH:MM) |
| `quietHoursEnd` | string | No | Quiet hours end (HH:MM) |
| `timezone` | string | No | Timezone for quiet hours |

**Success Response:** `200 OK`

```json
{
  "data": {
    "email": {
      "postPublished": true,
      "postFailed": true,
      "teamUpdates": false,
      "billingAlerts": true,
      "weeklyDigest": false,
      "productUpdates": true
    },
    "push": {
      "postPublished": true,
      "postFailed": true,
      "teamUpdates": true,
      "comments": true,
      "mentions": true
    },
    "digestFrequency": "weekly",
    "quietHoursStart": "23:00",
    "quietHoursEnd": "07:00",
    "timezone": "America/New_York",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/notifications/preferences \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "email": {
      "postPublished": true,
      "weeklyDigest": false
    },
    "quietHoursStart": "23:00",
    "quietHoursEnd": "07:00"
  }'
```

---

## GET /notifications/unread-count

Get count of unread notifications.

**Auth Required:** Yes

**Success Response:** `200 OK`

```json
{
  "data": {
    "total": 23,
    "byType": [
      {"type": "post_published", "count": 12},
      {"type": "comment", "count": 5},
      {"type": "team", "count": 3},
      {"type": "billing", "count": 2},
      {"type": "system", "count": 1}
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
curl https://api.contentdistribution.ai/v1/notifications/unread-count \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
