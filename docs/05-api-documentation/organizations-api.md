# Organizations API

## POST /organizations

Create a new organization.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Organization name (2-100 chars) |
| `slug` | string | No | URL-friendly identifier (auto-generated from name if omitted) |
| `description` | string | No | Organization description (max 500 chars) |
| `website` | string | No | Company website URL |
| `logo` | string | No | Logo image URL |

**Validation Rules:**
- `name`: 2-100 characters
- `slug`: 3-50 characters, lowercase alphanumeric and hyphens only, unique
- `description`: Max 500 characters
- `website`: Valid URL format

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "org_abc123",
    "name": "My Company",
    "slug": "my-company",
    "description": "A great company",
    "website": "https://example.com",
    "logo": "https://cdn.example.com/orgs/org_abc123/logo.png",
    "ownerId": "usr_abc123",
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
| 409 | `CONFLICT` | Slug already taken |
| 429 | `RATE_LIMITED` | Organization limit reached for plan |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/organizations \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Company",
    "description": "A great company",
    "website": "https://example.com"
  }'
```

---

## GET /organizations

List organizations the user belongs to.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `sort` | string | No | Sort field: `name`, `createdAt` (default: `-createdAt`) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "org_abc123",
      "name": "My Company",
      "slug": "my-company",
      "logo": "https://cdn.example.com/orgs/org_abc123/logo.png",
      "role": "owner",
      "memberCount": 12,
      "createdAt": "2025-01-15T08:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 1
  }
}
```

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/organizations \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /organizations/{organizationId}

Get organization details.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `include` | string | No | Related resources: `members`, `workspaces`, `billing` |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "org_abc123",
    "name": "My Company",
    "slug": "my-company",
    "description": "A great company",
    "website": "https://example.com",
    "logo": "https://cdn.example.com/orgs/org_abc123/logo.png",
    "ownerId": "usr_abc123",
    "memberCount": 12,
    "workspaceCount": 3,
    "createdAt": "2025-01-15T08:00:00Z",
    "updatedAt": "2025-06-15T10:00:00Z"
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
curl https://api.contentdistribution.ai/v1/organizations/org_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /organizations/{organizationId}

Update organization details.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Organization name |
| `description` | string | No | Organization description |
| `website` | string | No | Company website URL |
| `logo` | string | No | Logo image URL |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "org_abc123",
    "name": "Updated Company Name",
    "description": "Updated description",
    "website": "https://updated.com",
    "logo": "https://cdn.example.com/orgs/org_abc123/logo_v2.png",
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

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/organizations/org_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Company Name",
    "description": "Updated description"
  }'
```

---

## DELETE /organizations/{organizationId}

Delete an organization and all associated data.

**Auth Required:** Yes

**Required Role:** `owner`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `confirmSlug` | string | Yes | Organization slug for confirmation |
| `transferOwnershipTo` | string | No | User ID to transfer ownership before deletion |

**Success Response:** `200 OK`

```json
{
  "data": {
    "message": "Organization scheduled for deletion",
    "deletionScheduledAt": "2025-07-07T12:00:00Z",
    "gracePeriodDays": 7
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid confirmation slug |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not organization owner |
| 404 | `NOT_FOUND` | Organization not found |
| 422 | `UNPROCESSABLE` | Cannot delete org with active subscriptions |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/organizations/org_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "confirmSlug": "my-company"
  }'
```

---

## GET /organizations/{organizationId}/members

List organization members.

**Auth Required:** Yes

**Required Role:** `owner`, `admin`, or `member`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `role` | string | No | Filter by role: `owner`, `admin`, `member` |
| `search` | string | No | Search by name or email |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "mem_abc123",
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
    "total": 12
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
curl https://api.contentdistribution.ai/v1/organizations/org_abc123/members \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /organizations/{organizationId}/members/{memberId}

Update a member's role.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |
| `memberId` | string | Member ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `role` | string | Yes | New role: `admin` or `member` |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "mem_abc123",
    "user": {
      "id": "usr_def456",
      "name": "Jane Smith",
      "email": "jane@example.com"
    },
    "role": "admin",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid role |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Cannot change owner role or insufficient permissions |
| 404 | `NOT_FOUND` | Member not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/organizations/org_abc123/members/mem_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "role": "admin"
  }'
```

---

## DELETE /organizations/{organizationId}/members/{memberId}

Remove a member from the organization.

**Auth Required:** Yes

**Required Role:** `owner` or `admin` (cannot remove owners)

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |
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
curl -X DELETE https://api.contentdistribution.ai/v1/organizations/org_abc123/members/mem_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /organizations/{organizationId}/invitations

Invite a new member to the organization.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Invitee email address |
| `role` | string | Yes | Role to assign: `admin` or `member` |
| `message` | string | No | Personal invitation message (max 500 chars) |
| `workspaceIds` | string[] | No | Workspaces to grant access to |

**Validation Rules:**
- `email`: Valid email format
- `role`: Must be `admin` or `member`
- `message`: Max 500 characters

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "inv_abc123",
    "email": "invitee@example.com",
    "role": "member",
    "status": "pending",
    "expiresAt": "2025-07-07T12:00:00Z",
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
| 409 | `CONFLICT` | User already a member or invitation pending |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/organizations/org_abc123/invitations \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invitee@example.com",
    "role": "member",
    "message": "Join our team!",
    "workspaceIds": ["ws_abc123"]
  }'
```

---

## GET /organizations/{organizationId}/invitations

List pending invitations.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `status` | string | No | Filter: `pending`, `accepted`, `expired` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "inv_abc123",
      "email": "invitee@example.com",
      "role": "member",
      "status": "pending",
      "invitedBy": {
        "id": "usr_abc123",
        "name": "John Doe"
      },
      "expiresAt": "2025-07-07T12:00:00Z",
      "createdAt": "2025-06-30T12:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 1
  }
}
```

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/organizations/org_abc123/invitations \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## DELETE /organizations/{organizationId}/invitations/{invitationId}

Cancel a pending invitation.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |
| `invitationId` | string | Invitation ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Invitation not found |
| 409 | `CONFLICT` | Invitation already accepted |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/organizations/org_abc123/invitations/inv_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /organizations/{organizationId}/invitations/{invitationId}/resend

Resend a pending invitation email.

**Auth Required:** Yes

**Required Role:** `owner` or `admin`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `organizationId` | string | Organization ID |
| `invitationId` | string | Invitation ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "inv_abc123",
    "email": "invitee@example.com",
    "expiresAt": "2025-07-14T12:00:00Z",
    "resentAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Invitation not found |
| 409 | `CONFLICT` | Invitation already accepted or expired |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/organizations/org_abc123/invitations/inv_abc123/resend \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /organizations/invitations/{token}/accept

Accept an organization invitation.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Invitation token from email |

**Success Response:** `200 OK`

```json
{
  "data": {
    "organization": {
      "id": "org_abc123",
      "name": "My Company",
      "slug": "my-company"
    },
    "role": "member",
    "message": "Successfully joined organization"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Invitation not found |
| 409 | `CONFLICT` | Already a member or invitation expired |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/organizations/invitations/inv_token_xyz/accept \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
