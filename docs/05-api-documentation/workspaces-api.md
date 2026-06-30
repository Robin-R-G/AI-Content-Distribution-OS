# Workspaces API

## POST /organizations/{organizationId}/workspaces

Create a new workspace within an organization.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Workspace name (2-100 chars) |
| `description` | string | No | Workspace description (max 500 chars) |
| `settings` | object | No | Workspace-specific settings |

**Validation Rules:**
- `name`: 2-100 characters
- `description`: Max 500 characters

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "ws_abc123",
    "name": "Marketing",
    "slug": "marketing",
    "description": "Marketing team workspace",
    "organizationId": "org_abc123",
    "createdBy": "usr_abc123",
    "memberCount": 5,
    "connectedAccounts": 0,
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
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Organization not found |
| 409 | `CONFLICT` | Workspace name already exists |
| 429 | `RATE_LIMITED` | Workspace limit reached for plan |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/organizations/org_abc123/workspaces \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Marketing",
    "description": "Marketing team workspace"
  }'
```

---

## GET /organizations/{organizationId}/workspaces

List workspaces in an organization.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `sort` | string | No | Sort: `name`, `createdAt` (default: `-createdAt`) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "ws_abc123",
      "name": "Marketing",
      "slug": "marketing",
      "description": "Marketing team workspace",
      "memberCount": 5,
      "connectedAccounts": 3,
      "createdAt": "2025-01-15T08:00:00Z"
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
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a member of this organization |
| 404 | `NOT_FOUND` | Organization not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/organizations/org_abc123/workspaces \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /workspaces/{workspaceId}

Get workspace details.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `include` | string | No | Related: `members`, `connectedAccounts`, `recentPosts` |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "ws_abc123",
    "name": "Marketing",
    "slug": "marketing",
    "description": "Marketing team workspace",
    "organizationId": "org_abc123",
    "createdBy": "usr_abc123",
    "settings": {
      "defaultPlatform": "twitter",
      "autoSchedule": false,
      "aiEnabled": true
    },
    "memberCount": 5,
    "connectedAccounts": [
      {
        "id": "ca_abc123",
        "platform": "twitter",
        "handle": "@marketingco",
        "status": "connected"
      }
    ],
    "createdAt": "2025-01-15T08:00:00Z",
    "updatedAt": "2025-06-15T10:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a member of this workspace |
| 404 | `NOT_FOUND` | Workspace not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/workspaces/ws_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /workspaces/{workspaceId}

Update workspace details.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Workspace name |
| `description` | string | No | Workspace description |
| `settings` | object | No | Workspace settings |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "ws_abc123",
    "name": "Updated Name",
    "description": "Updated description",
    "settings": {
      "defaultPlatform": "linkedin",
      "autoSchedule": true,
      "aiEnabled": true
    },
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
| 404 | `NOT_FOUND` | Workspace not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/workspaces/ws_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "description": "Updated description"
  }'
```

---

## DELETE /workspaces/{workspaceId}

Delete a workspace and all associated data.

**Auth Required:** Yes

**Required Role:** `owner` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `confirmName` | string | Yes | Workspace name for confirmation |

**Success Response:** `200 OK`

```json
{
  "data": {
    "message": "Workspace deleted successfully"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid confirmation name |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not workspace owner |
| 404 | `NOT_FOUND` | Workspace not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/workspaces/ws_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "confirmName": "Marketing"
  }'
```

---

## GET /workspaces/{workspaceId}/members

List workspace members.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `role` | string | No | Filter by role: `owner`, `admin`, `member` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "wmem_abc123",
      "user": {
        "id": "usr_abc123",
        "name": "John Doe",
        "email": "john@example.com",
        "avatar": "https://cdn.example.com/avatars/usr_abc123.jpg"
      },
      "role": "owner",
      "joinedAt": "2025-01-15T08:00:00Z",
      "lastActiveAt": "2025-06-30T12:00:00Z"
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
| 403 | `FORBIDDEN` | Not a member of this workspace |
| 404 | `NOT_FOUND` | Workspace not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/workspaces/ws_abc123/members \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /workspaces/{workspaceId}/members

Add a member to the workspace.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | string | Yes | User ID to add |
| `role` | string | Yes | Role: `admin` or `member` |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "wmem_def456",
    "user": {
      "id": "usr_def456",
      "name": "Jane Smith",
      "email": "jane@example.com"
    },
    "role": "member",
    "joinedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Workspace or user not found |
| 409 | `CONFLICT` | User already a workspace member |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/workspaces/ws_abc123/members \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "usr_def456",
    "role": "member"
  }'
```

---

## DELETE /workspaces/{workspaceId}/members/{memberId}

Remove a member from the workspace.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |
| `memberId` | string | Member ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Cannot remove owner or insufficient permissions |
| 404 | `NOT_FOUND` | Member not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/workspaces/ws_abc123/members/wmem_def456 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /workspaces/{workspaceId}/connected-accounts

List connected social media accounts.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `platform` | string | No | Filter by platform: `twitter`, `linkedin`, `facebook`, `instagram` |
| `status` | string | No | Filter by status: `connected`, `expired`, `error` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "ca_abc123",
      "platform": "twitter",
      "handle": "@marketingco",
      "name": "Marketing Company",
      "avatar": "https://pbs.twimg.com/profile_images/...",
      "status": "connected",
      "permissions": ["read", "write"],
      "expiresAt": "2025-12-31T00:00:00Z",
      "connectedAt": "2025-01-20T10:00:00Z",
      "lastSyncAt": "2025-06-30T12:00:00Z"
    },
    {
      "id": "ca_def456",
      "platform": "linkedin",
      "handle": "marketing-company",
      "name": "Marketing Company",
      "avatar": "https://media.licdn.com/...",
      "status": "connected",
      "permissions": ["read", "write"],
      "expiresAt": "2025-11-15T00:00:00Z",
      "connectedAt": "2025-02-10T14:00:00Z",
      "lastSyncAt": "2025-06-30T11:00:00Z"
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
| 403 | `FORBIDDEN` | Not a member of this workspace |
| 404 | `NOT_FOUND` | Workspace not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/workspaces/ws_abc123/connected-accounts \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /workspaces/{workspaceId}/connected-accounts

Connect a new social media account.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `platform` | string | Yes | Platform: `twitter`, `linkedin`, `facebook`, `instagram` |
| `authorizationCode` | string | Yes | OAuth authorization code |
| `redirectUri` | string | Yes | OAuth redirect URI used |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "ca_xyz789",
    "platform": "instagram",
    "handle": "@marketingco",
    "name": "Marketing Company",
    "avatar": "https://...",
    "status": "connected",
    "permissions": ["read", "write"],
    "expiresAt": "2026-06-30T00:00:00Z",
    "connectedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Workspace not found |
| 409 | `CONFLICT` | Account already connected |
| 422 | `UNPROCESSABLE` | Invalid authorization code |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/workspaces/ws_abc123/connected-accounts \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "instagram",
    "authorizationCode": "auth_code_xyz",
    "redirectUri": "https://app.example.com/callback"
  }'
```

---

## DELETE /workspaces/{workspaceId}/connected-accounts/{accountId}

Disconnect a social media account.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |
| `accountId` | string | Connected account ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Connected account not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/workspaces/ws_abc123/connected-accounts/ca_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /workspaces/{workspaceId}/connected-accounts/{accountId}/refresh

Refresh OAuth tokens for a connected account.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` in workspace

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `workspaceId` | string | Workspace ID |
| `accountId` | string | Connected account ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "ca_abc123",
    "status": "connected",
    "expiresAt": "2025-12-31T00:00:00Z",
    "refreshedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Connected account not found |
| 422 | `UNPROCESSABLE` | Refresh token invalid or account revoked |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/workspaces/ws_abc123/connected-accounts/ca_abc123/refresh \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
