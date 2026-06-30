# Webhooks API

## GET /webhooks

List webhooks for a workspace.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `status` | string | No | Filter: `active`, `inactive`, `failing` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "wh_abc123",
      "name": "Slack Notifications",
      "url": "https://hooks.slack.com/services/T00/B00/xxx",
      "events": ["post.published", "post.failed"],
      "status": "active",
      "secret": "whsec_abc123...",
      "lastTriggeredAt": "2025-06-30T12:00:00Z",
      "failureCount": 0,
      "createdAt": "2025-06-01T10:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 3
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
curl "https://api.contentdistribution.ai/v1/webhooks?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /webhooks

Create a new webhook.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `name` | string | Yes | Webhook name (2-100 chars) |
| `url` | string | Yes | Callback URL (must be HTTPS) |
| `events` | string[] | Yes | Events to subscribe to |
| `secret` | string | No | Signing secret (auto-generated if omitted) |
| `active` | boolean | No | Enable immediately (default: true) |

**Available Events:**

| Event | Description |
|-------|-------------|
| `post.created` | Post created |
| `post.updated` | Post updated |
| `post.published` | Post published successfully |
| `post.failed` | Post publishing failed |
| `post.scheduled` | Post scheduled |
| `post.cancelled` | Post cancelled |
| `media.uploaded` | Media uploaded |
| `media.deleted` | Media deleted |
| `member.joined` | Team member joined |
| `member.removed` | Team member removed |
| `analytics.milestone` | Analytics milestone reached |
| `subscription.changed` | Subscription updated |
| `invoice.paid` | Invoice paid |
| `invoice.failed` | Invoice payment failed |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "wh_def456",
    "name": "My Webhook",
    "url": "https://example.com/webhook",
    "events": ["post.published", "post.failed"],
    "status": "active",
    "secret": "whsec_xyz789abc123def456",
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
| 422 | `UNPROCESSABLE` | Invalid URL or events |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/webhooks \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "name": "My Webhook",
    "url": "https://example.com/webhook",
    "events": ["post.published", "post.failed"]
  }'
```

---

## GET /webhooks/{webhookId}

Get webhook details.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "wh_abc123",
    "name": "Slack Notifications",
    "url": "https://hooks.slack.com/services/T00/B00/xxx",
    "events": ["post.published", "post.failed"],
    "status": "active",
    "secret": "whsec_abc123...",
    "lastTriggeredAt": "2025-06-30T12:00:00Z",
    "lastResponse": {
      "statusCode": 200,
      "duration": 245
    },
    "failureCount": 0,
    "createdAt": "2025-06-01T10:00:00Z",
    "updatedAt": "2025-06-15T14:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Webhook not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/webhooks/wh_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /webhooks/{webhookId}

Update a webhook.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Webhook name |
| `url` | string | No | Callback URL |
| `events` | string[] | No | Events to subscribe to |
| `active` | boolean | No | Enable/disable webhook |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "wh_abc123",
    "name": "Updated Webhook",
    "url": "https://updated.example.com/webhook",
    "events": ["post.published", "post.failed", "media.uploaded"],
    "status": "active",
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
| 404 | `NOT_FOUND` | Webhook not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/webhooks/wh_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "events": ["post.published", "post.failed", "media.uploaded"]
  }'
```

---

## DELETE /webhooks/{webhookId}

Delete a webhook.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Webhook not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/webhooks/wh_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /webhooks/{webhookId}/test

Send a test webhook event.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Event type to test |

**Success Response:** `200 OK`

```json
{
  "data": {
    "deliveryId": "del_abc123",
    "event": "post.published",
    "statusCode": 200,
    "duration": 245,
    "response": "OK",
    "sentAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid event type |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Webhook not found |
| 502 | `BAD_GATEWAY` | Target URL unreachable |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/webhooks/wh_abc123/test \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "event": "post.published"
  }'
```

---

## POST /webhooks/{webhookId}/rotate-secret

Rotate the webhook signing secret.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "wh_abc123",
    "secret": "whsec_newsecretxyz789",
    "previousSecret": "whsec_oldsecret...",
    "rotatedAt": "2025-06-30T12:00:00Z",
    "message": "Update your webhook handler with the new secret within 24 hours"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Webhook not found |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/webhooks/wh_abc123/rotate-secret \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /webhooks/{webhookId}/deliveries

List webhook delivery attempts.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `status` | string | No | Filter: `success`, `failed`, `pending` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "del_abc123",
      "event": "post.published",
      "statusCode": 200,
      "duration": 245,
      "request": {
        "headers": {"Content-Type": "application/json"},
        "body": "{\"event\":\"post.published\",\"data\":{...}}"
      },
      "response": {
        "headers": {"Content-Type": "application/json"},
        "body": "OK"
      },
      "status": "success",
      "createdAt": "2025-06-30T12:00:00Z"
    },
    {
      "id": "del_def456",
      "event": "post.failed",
      "statusCode": 500,
      "duration": 1023,
      "request": {
        "headers": {"Content-Type": "application/json"},
        "body": "{\"event\":\"post.failed\",\"data\":{...}}"
      },
      "response": {
        "headers": {},
        "body": "Internal Server Error"
      },
      "status": "failed",
      "error": "Received 500 response",
      "createdAt": "2025-06-30T11:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": true,
    "total": 156
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Webhook not found |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/webhooks/wh_abc123/deliveries?status=failed" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /webhooks/{webhookId}/deliveries/{deliveryId}

Get a specific delivery attempt.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |
| `deliveryId` | string | Delivery ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "del_abc123",
    "event": "post.published",
    "statusCode": 200,
    "duration": 245,
    "request": {
      "url": "https://example.com/webhook",
      "method": "POST",
      "headers": {
        "Content-Type": "application/json",
        "X-Webhook-Signature": "sha256=abc123...",
        "X-Webhook-Event": "post.published",
        "X-Webhook-Timestamp": "1719752400"
      },
      "body": {
        "event": "post.published",
        "timestamp": "2025-06-30T12:00:00Z",
        "data": {
          "postId": "post_abc123",
          "platform": "twitter",
          "url": "https://twitter.com/marketingco/status/123456789"
        }
      }
    },
    "response": {
      "statusCode": 200,
      "headers": {"Content-Type": "application/json"},
      "body": "OK"
    },
    "status": "success",
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Delivery not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/webhooks/wh_abc123/deliveries/del_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /webhooks/{webhookId}/deliveries/{deliveryId}/retry

Retry a failed delivery.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhookId` | string | Webhook ID |
| `deliveryId` | string | Delivery ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "del_new789",
    "status": "pending",
    "message": "Delivery retry queued",
    "createdAt": "2025-06-30T12:05:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Delivery not found |
| 409 | `CONFLICT` | Delivery already successful |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/webhooks/wh_abc123/deliveries/del_def456/retry \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
