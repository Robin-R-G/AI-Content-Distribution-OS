# Integrations API

## GET /integrations

List available integrations.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `category` | string | No | Filter: `social`, `analytics`, `project-management`, `storage`, `ai`, `other` |
| `search` | string | No | Search in name or description |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "int_abc123",
      "name": "Slack",
      "description": "Get notifications and manage content from Slack",
      "category": "project-management",
      "icon": "https://cdn.example.com/integrations/slack.png",
      "website": "https://slack.com",
      "status": "available",
      "features": ["notifications", "approval-workflows", "team-collaboration"],
      "permissions": ["read", "write"],
      "installUrl": "https://api.contentdistribution.ai/v1/integrations/slack/install"
    },
    {
      "id": "int_def456",
      "name": "Google Analytics",
      "description": "Import analytics data from Google Analytics",
      "category": "analytics",
      "icon": "https://cdn.example.com/integrations/ga.png",
      "website": "https://analytics.google.com",
      "status": "available",
      "features": ["analytics-import", "audience-data", "conversion-tracking"],
      "permissions": ["read"]
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 24
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid query parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/integrations?category=analytics" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /integrations/{integrationId}

Get integration details.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `integrationId` | string | Integration ID or slug |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "int_abc123",
    "name": "Slack",
    "description": "Get notifications and manage content from Slack",
    "category": "project-management",
    "icon": "https://cdn.example.com/integrations/slack.png",
    "website": "https://slack.com",
    "documentation": "https://docs.contentdistribution.ai/integrations/slack",
    "status": "available",
    "features": ["notifications", "approval-workflows", "team-collaboration"],
    "permissions": [
      {"scope": "channels:read", "description": "Read channel list"},
      {"scope": "chat:write", "description": "Send messages"}
    ],
    "setupGuide": "1. Click Install\n2. Authorize in Slack\n3. Select channels"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Integration not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/integrations/int_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /integrations/{integrationId}/install

Install an integration.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `integrationId` | string | Integration ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `config` | object | No | Integration-specific configuration |
| `credentials` | object | No | OAuth tokens or API keys |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "inst_abc123",
    "integrationId": "int_abc123",
    "workspaceId": "ws_abc123",
    "status": "connected",
    "config": {
      "defaultChannel": "#marketing",
      "notifyOnPublish": true,
      "notifyOnFailure": true
    },
    "installedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Integration not found |
| 409 | `CONFLICT` | Integration already installed |
| 422 | `UNPROCESSABLE` | Invalid credentials |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/integrations/int_abc123/install \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "config": {
      "defaultChannel": "#marketing",
      "notifyOnPublish": true
    }
  }'
```

---

## GET /integrations/installed

List installed integrations.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `status` | string | No | Filter: `connected`, `disconnected`, `error` |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "inst_abc123",
      "integration": {
        "id": "int_abc123",
        "name": "Slack",
        "icon": "https://cdn.example.com/integrations/slack.png"
      },
      "status": "connected",
      "config": {
        "defaultChannel": "#marketing",
        "notifyOnPublish": true
      },
      "health": {
        "status": "healthy",
        "lastCheckedAt": "2025-06-30T12:00:00Z"
      },
      "installedAt": "2025-06-01T10:00:00Z",
      "lastSyncAt": "2025-06-30T11:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 5
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
curl "https://api.contentdistribution.ai/v1/integrations/installed?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## DELETE /integrations/{installationId}

Uninstall an integration.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `installationId` | string | Installation ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Installation not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/integrations/inst_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /integrations/{installationId}/config

Update integration configuration.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `installationId` | string | Installation ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `config` | object | Yes | Integration-specific configuration |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "inst_abc123",
    "status": "connected",
    "config": {
      "defaultChannel": "#content-team",
      "notifyOnPublish": true,
      "notifyOnFailure": true,
      "weeklyDigest": true
    },
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid config |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Installation not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/integrations/inst_abc123/config \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "config": {
      "defaultChannel": "#content-team",
      "weeklyDigest": true
    }
  }'
```

---

## GET /integrations/{installationId}/health

Check integration health status.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `installationId` | string | Installation ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "inst_abc123",
    "integration": {
      "id": "int_abc123",
      "name": "Slack"
    },
    "status": "healthy",
    "checks": [
      {
        "name": "api_connection",
        "status": "pass",
        "message": "API connection successful",
        "latency": 145
      },
      {
        "name": "authentication",
        "status": "pass",
        "message": "Credentials valid",
        "expiresAt": "2025-12-31T00:00:00Z"
      },
      {
        "name": "permissions",
        "status": "pass",
        "message": "All required permissions granted"
      }
    ],
    "lastCheckedAt": "2025-06-30T12:00:00Z",
    "uptime": 99.9
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Installation not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/integrations/inst_abc123/health \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /integrations/{installationId}/sync

Trigger a manual sync.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `installationId` | string | Installation ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "jobId": "job_abc123",
    "status": "started",
    "estimatedCompletionAt": "2025-06-30T12:05:00Z",
    "message": "Sync job started"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Installation not found |
| 409 | `CONFLICT` | Sync already in progress |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/integrations/inst_abc123/sync \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /integrations/{installationId}/logs

Get integration activity logs.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `installationId` | string | Installation ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `type` | string | No | Filter: `sync`, `notification`, `error`, `config_change` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "log_abc123",
      "type": "sync",
      "message": "Sync completed successfully",
      "details": {
        "itemsSynced": 45,
        "duration": 2340
      },
      "createdAt": "2025-06-30T12:00:00Z"
    },
    {
      "id": "log_def456",
      "type": "notification",
      "message": "Post published notification sent to #marketing",
      "details": {
        "channel": "#marketing",
        "postId": "post_abc123"
      },
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
| 404 | `NOT_FOUND` | Installation not found |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/integrations/inst_abc123/logs?type=sync" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
