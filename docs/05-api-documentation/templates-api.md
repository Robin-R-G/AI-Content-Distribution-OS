# Templates API

## GET /templates

List templates in a workspace.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `type` | string | No | Filter: `post`, `story`, `reel`, `carousel`, `banner`, `custom` |
| `platform` | string | No | Filter by platform |
| `search` | string | No | Search in name and description |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "tpl_abc123",
      "name": "Product Launch Announcement",
      "type": "post",
      "platforms": ["twitter", "linkedin"],
      "description": "Standard template for product launches",
      "content": "Introducing {{product_name}}! {{description}}",
      "variables": [
        {"name": "product_name", "type": "text", "required": true},
        {"name": "description", "type": "text", "required": true}
      ],
      "media": [
        {"type": "image", "required": true, "position": "top"}
      ],
      "tags": ["product", "launch", "announcement"],
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
| 400 | `VALIDATION_ERROR` | Invalid query parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/templates?workspaceId=ws_abc123&type=post" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /templates

Create a new template.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `name` | string | Yes | Template name (2-100 chars) |
| `type` | string | Yes | Type: `post`, `story`, `reel`, `carousel`, `banner`, `custom` |
| `platforms` | string[] | Yes | Target platforms |
| `description` | string | No | Template description (max 500 chars) |
| `content` | string | Yes | Template content with {{variables}} (max 5000 chars) |
| `variables` | array[] | No | Variable definitions |
| `media` | array[] | No | Media placeholders |
| `tags` | string[] | No | Template tags (max 20) |

**Variable Object:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Variable name (alphanumeric, underscores) |
| `type` | string | Yes | Type: `text`, `number`, `date`, `select`, `boolean` |
| `required` | boolean | No | Required (default: true) |
| `defaultValue` | any | No | Default value |
| `options` | string[] | No | Options for select type |

**Media Object:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Type: `image`, `video`, `any` |
| `required` | boolean | No | Required (default: true) |
| `position` | string | No | Position: `top`, `bottom`, `inline` |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "tpl_def456",
    "name": "Weekly Tip Template",
    "type": "post",
    "platforms": ["twitter", "linkedin"],
    "description": "Template for weekly tips",
    "content": "Weekly Tip: {{tip_title}}\n\n{{tip_content}}\n\nWhat do you think? Let us know below!",
    "variables": [
      {"name": "tip_title", "type": "text", "required": true},
      {"name": "tip_content", "type": "text", "required": true}
    ],
    "media": [
      {"type": "image", "required": false, "position": "top"}
    ],
    "tags": ["tips", "weekly", "engagement"],
    "usageCount": 0,
    "createdBy": {
      "id": "usr_abc123",
      "name": "John Doe"
    },
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
curl -X POST https://api.contentdistribution.ai/v1/templates \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "name": "Weekly Tip Template",
    "type": "post",
    "platforms": ["twitter", "linkedin"],
    "content": "Weekly Tip: {{tip_title}}\n\n{{tip_content}}",
    "variables": [
      {"name": "tip_title", "type": "text", "required": true},
      {"name": "tip_content", "type": "text", "required": true}
    ],
    "tags": ["tips", "weekly"]
  }'
```

---

## GET /templates/{templateId}

Get template details.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | Template ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "tpl_abc123",
    "name": "Product Launch Announcement",
    "type": "post",
    "platforms": ["twitter", "linkedin"],
    "description": "Standard template for product launches",
    "content": "Introducing {{product_name}}! {{description}}",
    "variables": [
      {"name": "product_name", "type": "text", "required": true},
      {"name": "description", "type": "text", "required": true}
    ],
    "media": [
      {"type": "image", "required": true, "position": "top"}
    ],
    "tags": ["product", "launch", "announcement"],
    "usageCount": 45,
    "createdBy": {
      "id": "usr_abc123",
      "name": "John Doe"
    },
    "createdAt": "2025-06-01T10:00:00Z",
    "updatedAt": "2025-06-15T14:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Template not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/templates/tpl_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /templates/{templateId}

Update a template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | Template ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Template name |
| `description` | string | No | Template description |
| `content` | string | No | Template content |
| `platforms` | string[] | No | Target platforms |
| `variables` | array[] | No | Variable definitions |
| `media` | array[] | No | Media placeholders |
| `tags` | string[] | No | Template tags |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "tpl_abc123",
    "name": "Updated Template Name",
    "content": "Updated content with {{new_variable}}",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not template creator |
| 404 | `NOT_FOUND` | Template not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/templates/tpl_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Template Name",
    "content": "Updated content with {{new_variable}}"
  }'
```

---

## DELETE /templates/{templateId}

Delete a template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | Template ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not template creator |
| 404 | `NOT_FOUND` | Template not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/templates/tpl_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /templates/{templateId}/use

Create a post from a template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | Template ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `variables` | object | Yes | Variable values |
| `mediaIds` | string[] | No | Media file IDs |
| `scheduledAt` | string | No | Schedule for later |
| `platforms` | string[] | No | Override target platforms |

**Success Response:** `201 Created`

```json
{
  "data": {
    "postId": "post_xyz789",
    "content": "Introducing our new AI tool! This revolutionary product helps you create content 10x faster.",
    "platforms": ["twitter", "linkedin"],
    "status": "draft",
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Missing required variables |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 404 | `NOT_FOUND` | Template not found |
| 422 | `UNPROCESSABLE` | Invalid variable values |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/templates/tpl_abc123/use \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "variables": {
      "product_name": "AI Content Tool",
      "description": "Revolutionary product that helps you create content 10x faster."
    },
    "mediaIds": ["med_abc123"],
    "scheduledAt": "2025-07-01T10:00:00Z"
  }'
```

---

## POST /templates/{templateId}/duplicate

Duplicate a template.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | Template ID to duplicate |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | New template name |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "tpl_new789",
    "name": "Product Launch - Copy",
    "type": "post",
    "platforms": ["twitter", "linkedin"],
    "content": "Introducing {{product_name}}! {{description}}",
    "variables": [
      {"name": "product_name", "type": "text", "required": true},
      {"name": "description", "type": "text", "required": true}
    ],
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Source template not found |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/templates/tpl_abc123/duplicate \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Product Launch - Copy"
  }'
```

---

## GET /templates/categories

List template categories.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "cat_abc123",
      "name": "Product Launches",
      "templateCount": 5,
      "createdAt": "2025-06-01T10:00:00Z"
    },
    {
      "id": "cat_def456",
      "name": "Weekly Tips",
      "templateCount": 8,
      "createdAt": "2025-06-05T14:00:00Z"
    },
    {
      "id": "cat_xyz789",
      "name": "Event Promotions",
      "templateCount": 3,
      "createdAt": "2025-06-10T09:00:00Z"
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
| 403 | `FORBIDDEN` | Not a workspace member |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/templates/categories?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /templates/categories

Create a template category.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `name` | string | Yes | Category name (2-100 chars) |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "cat_new123",
    "name": "New Category",
    "templateCount": 0,
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
| 409 | `CONFLICT` | Category name already exists |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/templates/categories \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "name": "New Category"
  }'
```
