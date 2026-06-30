# Media API

## POST /media/upload

Upload a media file.

**Auth Required:** Yes

**Request Body:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | file | Yes | Media file (image, video, audio, document) |
| `workspaceId` | string | Yes | Target workspace ID |
| `folder` | string | No | Target folder path (default: `/`) |
| `alt` | string | No | Alt text for images (max 500 chars) |
| `tags` | string[] | No | Media tags (max 20) |

**File Limits:**

| Type | Max Size | Accepted Formats |
|------|----------|-------------------|
| Image | 10MB | JPEG, PNG, GIF, WebP, SVG |
| Video | 100MB | MP4, MOV, AVI, WebM |
| Audio | 50MB | MP3, WAV, OGG, AAC |
| Document | 25MB | PDF, DOC, DOCX, TXT |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "med_abc123",
    "filename": "product-screenshot.png",
    "originalFilename": "Screenshot 2025-06-30 at 10.00.00 AM.png",
    "mimeType": "image/png",
    "size": 2456789,
    "url": "https://cdn.example.com/media/ws_abc123/med_abc123.png",
    "thumbnailUrl": "https://cdn.example.com/media/ws_abc123/med_abc123_thumb.png",
    "dimensions": {
      "width": 1920,
      "height": 1080
    },
    "duration": null,
    "folder": "/",
    "tags": ["product", "screenshot"],
    "alt": "Product dashboard screenshot",
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
| 400 | `VALIDATION_ERROR` | Invalid file or parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 413 | `PAYLOAD_TOO_LARGE` | File exceeds size limit |
| 422 | `UNPROCESSABLE` | Unsupported file type |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/media/upload \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -F "file=@/path/to/image.png" \
  -F "workspaceId=ws_abc123" \
  -F "alt=Product dashboard screenshot" \
  -F "tags=product,screenshot"
```

---

## GET /media

List media files in a workspace.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `sort` | string | No | Sort: `createdAt`, `filename`, `size` (default: `-createdAt`) |
| `filter[type]` | string | No | Filter: `image`, `video`, `audio`, `document` |
| `filter[folder]` | string | No | Filter by folder path |
| `filter[tags]` | string | No | Comma-separated tags |
| `search` | string | No | Search in filename or alt text |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "med_abc123",
      "filename": "product-screenshot.png",
      "mimeType": "image/png",
      "size": 2456789,
      "url": "https://cdn.example.com/media/ws_abc123/med_abc123.png",
      "thumbnailUrl": "https://cdn.example.com/media/ws_abc123/med_abc123_thumb.png",
      "dimensions": {
        "width": 1920,
        "height": 1080
      },
      "folder": "/",
      "tags": ["product", "screenshot"],
      "usageCount": 5,
      "createdAt": "2025-06-30T12:00:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6Im1lZF9hYmMxMjMifQ==",
    "hasMore": true,
    "total": 234
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
curl "https://api.contentdistribution.ai/v1/media?workspaceId=ws_abc123&filter[type]=image&sort=-createdAt" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /media/{mediaId}

Get details of a specific media file.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mediaId` | string | Media ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "med_abc123",
    "filename": "product-screenshot.png",
    "originalFilename": "Screenshot 2025-06-30 at 10.00.00 AM.png",
    "mimeType": "image/png",
    "size": 2456789,
    "url": "https://cdn.example.com/media/ws_abc123/med_abc123.png",
    "thumbnailUrl": "https://cdn.example.com/media/ws_abc123/med_abc123_thumb.png",
    "dimensions": {
      "width": 1920,
      "height": 1080
    },
    "folder": "/",
    "tags": ["product", "screenshot"],
    "alt": "Product dashboard screenshot",
    "metadata": {
      "exif": {
        "camera": "Apple iPhone 15 Pro",
        "takenAt": "2025-06-28T14:30:00Z"
      }
    },
    "usageCount": 5,
    "usedInPosts": ["post_abc123", "post_def456"],
    "createdBy": {
      "id": "usr_abc123",
      "name": "John Doe"
    },
    "createdAt": "2025-06-30T12:00:00Z",
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 404 | `NOT_FOUND` | Media not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/media/med_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /media/{mediaId}

Update media metadata.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mediaId` | string | Media ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `filename` | string | No | New filename |
| `alt` | string | No | Alt text |
| `tags` | string[] | No | Tags |
| `folder` | string | No | Move to folder |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "med_abc123",
    "filename": "renamed-file.png",
    "alt": "Updated alt text",
    "tags": ["product", "screenshot", "updated"],
    "folder": "/marketing",
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
| 404 | `NOT_FOUND` | Media not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/media/med_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "filename": "renamed-file.png",
    "alt": "Updated alt text",
    "folder": "/marketing"
  }'
```

---

## DELETE /media/{mediaId}

Delete a media file.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mediaId` | string | Media ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Media not found |
| 409 | `CONFLICT` | Media is in use by published posts |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/media/med_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /media/bulk-delete

Delete multiple media files.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mediaIds` | string[] | Yes | Array of media IDs (max 100) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "deleted": 15,
    "failed": 0,
    "failedIds": []
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
curl -X POST https://api.contentdistribution.ai/v1/media/bulk-delete \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "mediaIds": ["med_abc123", "med_def456", "med_xyz789"]
  }'
```

---

## GET /media/folders

List all folders in a workspace.

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
      "path": "/",
      "name": "Root",
      "mediaCount": 45,
      "totalSize": 125678901,
      "createdAt": "2025-01-15T08:00:00Z"
    },
    {
      "path": "/marketing",
      "name": "marketing",
      "mediaCount": 23,
      "totalSize": 56789012,
      "createdAt": "2025-02-10T10:00:00Z"
    },
    {
      "path": "/marketing/campaigns",
      "name": "campaigns",
      "mediaCount": 12,
      "totalSize": 34567890,
      "createdAt": "2025-03-05T14:00:00Z"
    },
    {
      "path": "/products",
      "name": "products",
      "mediaCount": 34,
      "totalSize": 89012345,
      "createdAt": "2025-02-20T09:00:00Z"
    }
  ],
  "pagination": {
    "cursor": null,
    "hasMore": false,
    "total": 4
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
curl "https://api.contentdistribution.ai/v1/media/folders?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /media/folders

Create a new folder.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `path` | string | Yes | Full folder path (e.g., `/marketing/campaigns`) |

**Validation Rules:**
- Path must start with `/`
- Path segments: 2-50 characters each
- Only alphanumeric, hyphens, and underscores allowed

**Success Response:** `201 Created`

```json
{
  "data": {
    "path": "/marketing/campaigns",
    "name": "campaigns",
    "mediaCount": 0,
    "totalSize": 0,
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid path format |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 409 | `CONFLICT` | Folder already exists |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/media/folders \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "path": "/marketing/campaigns"
  }'
```

---

## DELETE /media/folders/{folderPath}

Delete a folder and all contents.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `folderPath` | string | Encoded folder path (e.g., `marketing/campaigns`) |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "deletedMediaCount": 12,
    "message": "Folder and contents deleted successfully"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Folder not found |
| 409 | `CONFLICT` | Cannot delete root folder |

**Example Request:**

```bash
curl -X DELETE "https://api.contentdistribution.ai/v1/media/folders/marketing/campaigns?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /media/{mediaId}/tags

Add tags to a media file.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mediaId` | string | Media ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tags` | string[] | Yes | Tags to add (max 20) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "med_abc123",
    "tags": ["product", "screenshot", "marketing", "new-tag"],
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid tags |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Media not found |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/media/med_abc123/tags \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "tags": ["marketing", "new-tag"]
  }'
```

---

## DELETE /media/{mediaId}/tags/{tag}

Remove a tag from a media file.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mediaId` | string | Media ID |
| `tag` | string | Tag to remove (URL-encoded) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "med_abc123",
    "tags": ["product", "screenshot"],
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Media or tag not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/media/med_abc123/tags/marketing \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /media/{mediaId}/usage

Get usage statistics for a media file.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mediaId` | string | Media ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "med_abc123",
    "usageCount": 5,
    "usedInPosts": [
      {
        "postId": "post_abc123",
        "postStatus": "published",
        "platforms": ["twitter", "linkedin"],
        "usedAt": "2025-06-29T10:00:00Z"
      },
      {
        "postId": "post_def456",
        "postStatus": "scheduled",
        "platforms": ["facebook"],
        "usedAt": "2025-06-30T08:00:00Z"
      }
    ],
    "usedInTemplates": [
      {
        "templateId": "tpl_abc123",
        "templateName": "Product Launch",
        "usedAt": "2025-06-25T12:00:00Z"
      }
    ]
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Media not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/media/med_abc123/usage \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
