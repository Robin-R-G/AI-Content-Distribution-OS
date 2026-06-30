# API Overview

Base URL for all API requests.

## Base URL

```
https://api.contentdistribution.ai/v1
```

All endpoints are relative to this base URL. The API is served over HTTPS only. HTTP requests are redirected with a 301 status code.

## Versioning Strategy

The API uses URI-based versioning. The current version is `v1`. Breaking changes introduce a new version. Deprecated versions receive security patches for 12 months after deprecation notice.

```
https://api.contentdistribution.ai/v1/resource
```

## Authentication

All requests require a Bearer token in the `Authorization` header except for public endpoints like login, register, and password reset.

```
Authorization: Bearer <access_token>
```

Tokens are JWTs signed with RS256. Access tokens expire after 15 minutes. Refresh tokens expire after 7 days.

## Common Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes* | Bearer token for authentication |
| `Content-Type` | Yes | `application/json` for request bodies |
| `X-Request-ID` | No | Unique request identifier for tracing |
| `X-Workspace-Id` | No | Workspace context for multi-workspace accounts |
| `X-Organization-Id` | No | Organization context for multi-org accounts |
| `Accept-Language` | No | Response language preference (default: `en`) |
| `Idempotency-Key` | No | Unique key for idempotent POST requests |

*Excluded for authentication endpoints.

## Rate Limiting

Every response includes rate limit headers:

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Maximum requests per window |
| `X-RateLimit-Remaining` | Requests remaining in window |
| `X-RateLimit-Reset` | UTC epoch seconds when window resets |
| `Retry-After` | Seconds to wait (only on 429 responses) |

Default rate limits by plan:

| Plan | Requests/min | Burst |
|------|-------------|-------|
| Free | 60 | 10 |
| Pro | 300 | 50 |
| Business | 1000 | 200 |
| Enterprise | Custom | Custom |

Exceeding the limit returns a `429 Too Many Requests` response.

## Pagination

All list endpoints use cursor-based pagination. Results are ordered by creation date descending unless otherwise specified.

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cursor` | string | null | Cursor from previous response |
| `limit` | integer | 25 | Results per page (max 100) |

**Response Format:**

```json
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTAwfQ==",
    "hasMore": true,
    "total": 1547
  }
}
```

To fetch the next page, pass the `cursor` value from the response. When `hasMore` is `false`, there are no more results.

## Filtering

List endpoints support filtering via query parameters. Filters use the format `filter[field]=value`.

**Operators:**

| Syntax | Operator | Example |
|--------|----------|---------|
| `filter[field]=value` | Equals | `filter[status]=published` |
| `filter[field]=value1,value2` | In | `filter[platform]=twitter,linkedin` |
| `filter[field]=gte:value` | Greater than or equal | `filter[createdAt]=gte:2025-01-01` |
| `filter[field]=lte:value` | Less than or equal | `filter[createdAt]=lte:2025-12-31` |
| `filter[field]=contains:value` | Text search | `filter[title]=contains:marketing` |

## Sorting

List endpoints support sorting via the `sort` query parameter.

```
GET /api/v1/posts?sort=-createdAt
```

Prefix with `-` for descending order. Prefix with nothing for ascending order.

Multiple sort fields: `sort=-createdAt,title`

## Error Response Format

All errors follow a consistent structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request body is invalid",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Must be a valid email address"
      }
    ],
    "requestId": "req_abc123xyz",
    "timestamp": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | `VALIDATION_ERROR` | Request body or parameters failed validation |
| 400 | `BAD_REQUEST` | Malformed request |
| 401 | `UNAUTHORIZED` | Missing or invalid authentication |
| 403 | `FORBIDDEN` | Authenticated but insufficient permissions |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `CONFLICT` | Resource state conflict (e.g., duplicate) |
| 422 | `UNPROCESSABLE` | Semantically invalid request |
| 429 | `RATE_LIMITED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Server error |
| 502 | `BAD_GATEWAY` | Upstream service error |
| 503 | `SERVICE_UNAVAILABLE` | Maintenance or overload |

## Idempotency

POST, PATCH, and DELETE endpoints support idempotency via the `Idempotency-Key` header. The key must be a unique UUID v4. Idempotent responses are cached for 24 hours.

```http
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

If a request with the same key is repeated, the original response is returned without re-executing the operation.

## Request Body Format

All request bodies must be `application/json`. Non-JSON bodies return a `415 Unsupported Media Type` error.

**Maximum body size:** 10 MB for standard requests. Media uploads use multipart/form-data with a 100 MB limit.

## Response Envelope

Successful responses are wrapped in a data envelope:

```json
{
  "data": { ... },
  "meta": {
    "requestId": "req_abc123xyz",
    "timestamp": "2025-06-30T12:00:00Z"
  }
}
```

Single resources return an object. Collections return an array with pagination metadata.

## CORS

The API supports Cross-Origin Resource Sharing. Allowed origins are configured per organization. The `Access-Control-Allow-Credentials` header is set to `true` for authenticated requests.

## WebSocket API

Real-time updates are available via WebSocket:

```
wss://ws.contentdistribution.ai/v1?token=<access_token>
```

WebSocket connections receive events for post status changes, analytics updates, and notifications. See the WebSocket documentation for event schemas.
