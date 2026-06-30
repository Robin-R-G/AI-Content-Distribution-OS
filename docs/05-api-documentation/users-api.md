# Users API

## GET /users/me

Get the authenticated user's profile.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `include` | string | No | Comma-separated related resources: `organizations`, `workspaces`, `subscription` |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "John Doe",
    "avatar": "https://cdn.example.com/avatars/usr_abc123.jpg",
    "bio": "Content creator and marketer",
    "timezone": "America/New_York",
    "locale": "en",
    "emailVerified": true,
    "mfaEnabled": false,
    "createdAt": "2025-01-15T08:00:00Z",
    "updatedAt": "2025-06-30T12:00:00Z",
    "organizations": [
      {
        "id": "org_abc123",
        "name": "My Company",
        "role": "owner"
      }
    ],
    "workspaces": [
      {
        "id": "ws_abc123",
        "name": "Marketing",
        "role": "admin"
      }
    ],
    "subscription": {
      "plan": "pro",
      "status": "active"
    }
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /users/me

Update the authenticated user's profile.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Full name (2-100 chars) |
| `bio` | string | No | User bio (max 500 chars) |
| `timezone` | string | No | IANA timezone identifier |
| `locale` | string | No | Language preference (e.g., `en`, `es`, `fr`) |

**Validation Rules:**
- `name`: 2-100 characters
- `bio`: Max 500 characters
- `timezone`: Valid IANA timezone (e.g., `America/New_York`)
- `locale`: Valid ISO 639-1 code

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "Jane Doe",
    "bio": "Updated bio text",
    "timezone": "Europe/London",
    "locale": "en",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 422 | `UNPROCESSABLE` | Invalid timezone or locale |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "bio": "Updated bio text",
    "timezone": "Europe/London"
  }'
```

---

## DELETE /users/me

Delete the authenticated user's account.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `password` | string | Yes | Current password for confirmation |
| `reason` | string | No | Reason for leaving (max 500 chars) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "message": "Account scheduled for deletion",
    "deletionScheduledAt": "2025-07-07T12:00:00Z",
    "gracePeriodDays": 7
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Missing password |
| 401 | `UNAUTHORIZED` | Invalid password |
| 403 | `FORBIDDEN` | Account has active subscriptions requiring transfer |

**Note:** Account deletion is scheduled with a 7-day grace period. Login within this period cancels deletion.

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "password": "SecurePass123!",
    "reason": "No longer needed"
  }'
```

---

## POST /users/me/avatar

Upload or update the user's avatar image.

**Auth Required:** Yes

**Request Body:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `avatar` | file | Yes | Image file (JPEG, PNG, WebP). Max 5MB |

**Validation Rules:**
- Accepted formats: `image/jpeg`, `image/png`, `image/webp`
- Maximum file size: 5MB
- Recommended dimensions: 400x400px (square)

**Success Response:** `200 OK`

```json
{
  "data": {
    "avatar": "https://cdn.example.com/avatars/usr_abc123_1719752400.jpg",
    "avatarThumbnail": "https://cdn.example.com/avatars/usr_abc123_1719752400_thumb.jpg",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid file type or size |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 413 | `PAYLOAD_TOO_LARGE` | File exceeds 5MB limit |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/users/me/avatar \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -F "avatar=@/path/to/avatar.jpg"
```

---

## GET /users/me/sessions

List all active sessions for the authenticated user.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "ses_abc123",
      "device": "Chrome 125.0 on macOS",
      "ip": "192.168.1.100",
      "location": "New York, US",
      "lastActiveAt": "2025-06-30T12:00:00Z",
      "createdAt": "2025-06-28T08:00:00Z",
      "isCurrent": true
    },
    {
      "id": "ses_def456",
      "device": "Safari 18.0 on iOS",
      "ip": "10.0.0.50",
      "location": "Boston, US",
      "lastActiveAt": "2025-06-29T16:30:00Z",
      "createdAt": "2025-06-25T14:00:00Z",
      "isCurrent": false
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

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/users/me/sessions \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## DELETE /users/me/sessions/{sessionId}

Terminate a specific session.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `sessionId` | string | Session ID to terminate |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Cannot terminate current session (use logout) |
| 404 | `NOT_FOUND` | Session not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/users/me/sessions/ses_def456 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## DELETE /users/me/sessions

Terminate all sessions except the current one.

**Auth Required:** Yes

**Request Body:** None

**Success Response:** `200 OK`

```json
{
  "data": {
    "terminatedCount": 3,
    "message": "All other sessions have been terminated"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/users/me/sessions \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
