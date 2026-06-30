# Analytics API

## GET /analytics/overview

Get overall analytics summary.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period: `7d`, `30d`, `90d`, `1y` (default: `30d`) |
| `startDate` | string | No | Custom start date (ISO 8601) |
| `endDate` | string | No | Custom end date (ISO 8601) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "summary": {
      "totalPosts": 156,
      "totalImpressions": 2450000,
      "totalReach": 1890000,
      "totalEngagement": 89450,
      "engagementRate": 3.65,
      "totalFollowers": 45230,
      "followerGrowth": 2340,
      "followerGrowthRate": 5.45
    },
    "comparison": {
      "impressionsChange": "+12.5%",
      "reachChange": "+8.3%",
      "engagementChange": "+15.2%",
      "followerChange": "+5.4%"
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
curl "https://api.contentdistribution.ai/v1/analytics/overview?workspaceId=ws_abc123&period=30d" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/platform/{platform}

Get analytics for a specific platform.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `platform` | string | Platform: `twitter`, `linkedin`, `facebook`, `instagram`, `tiktok`, `youtube`, `pinterest` |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `accountId` | string | No | Specific connected account ID |
| `period` | string | No | Period: `7d`, `30d`, `90d`, `1y` (default: `30d`) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "platform": "twitter",
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "metrics": {
      "impressions": 890000,
      "reach": 675000,
      "engagement": 34500,
      "engagementRate": 3.88,
      "followers": 12500,
      "followerGrowth": 890,
      "posts": 67,
      "likes": 21000,
      "retweets": 8500,
      "replies": 5000,
      "linkClicks": 3200,
      "hashtagClicks": 1200,
      "profileVisits": 4500,
      "mentions": 234
    },
    "topPosts": [
      {
        "id": "post_abc123",
        "content": "Our latest product update...",
        "impressions": 45000,
        "engagement": 2300,
        "engagementRate": 5.11,
        "publishedAt": "2025-06-15T10:00:00Z"
      }
    ]
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid query parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 404 | `NOT_FOUND` | Platform not connected |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/analytics/platform/twitter?workspaceId=ws_abc123&period=30d" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/account/{accountId}

Get analytics for a specific connected account.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `accountId` | string | Connected account ID |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `period` | string | No | Period: `7d`, `30d`, `90d`, `1y` (default: `30d`) |
| `granularity` | string | No | Granularity: `daily`, `weekly`, `monthly` (default: `daily`) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "account": {
      "id": "ca_abc123",
      "platform": "instagram",
      "handle": "@marketingco"
    },
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "metrics": {
      "impressions": 560000,
      "reach": 420000,
      "engagement": 28000,
      "engagementRate": 5.0,
      "followers": 18700,
      "followerGrowth": 1200,
      "posts": 45,
      "likes": 18000,
      "comments": 4500,
      "saves": 3200,
      "shares": 2300,
      "profileViews": 8900,
      "websiteClicks": 2100
    },
    "timeSeries": [
      {"date": "2025-06-01", "impressions": 18000, "engagement": 900},
      {"date": "2025-06-02", "impressions": 22000, "engagement": 1100}
    ]
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid query parameters |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Not a workspace member |
| 404 | `NOT_FOUND` | Account not found |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/analytics/account/ca_abc123?period=30d&granularity=daily" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/posts

Get post-level analytics.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period (default: `30d`) |
| `platform` | string | No | Filter by platform |
| `sort` | string | No | Sort: `impressions`, `engagement`, `engagementRate` (default: `-engagement`) |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "post_abc123",
      "content": "Check out our latest update!",
      "platforms": ["twitter", "linkedin"],
      "publishedAt": "2025-06-15T10:00:00Z",
      "metrics": {
        "impressions": 45000,
        "reach": 32000,
        "engagement": 2300,
        "engagementRate": 5.11,
        "likes": 1500,
        "comments": 320,
        "shares": 480
      }
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6InBvc3RfYWJjMTIzIn0=",
    "hasMore": true,
    "total": 156
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
curl "https://api.contentdistribution.ai/v1/analytics/posts?workspaceId=ws_abc123&period=30d&sort=-engagement" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/audience

Get audience demographics and insights.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `platform` | string | No | Filter by platform |

**Success Response:** `200 OK`

```json
{
  "data": {
    "totalFollowers": 45230,
    "demographics": {
      "age": [
        {"range": "18-24", "percentage": 15},
        {"range": "25-34", "percentage": 42},
        {"range": "35-44", "percentage": 28},
        {"range": "45-54", "percentage": 10},
        {"range": "55+", "percentage": 5}
      ],
      "gender": [
        {"type": "male", "percentage": 58},
        {"type": "female", "percentage": 38},
        {"type": "other", "percentage": 4}
      ],
      "locations": [
        {"country": "United States", "percentage": 45},
        {"country": "United Kingdom", "percentage": 12},
        {"country": "Canada", "percentage": 8},
        {"country": "Australia", "percentage": 6},
        {"country": "Germany", "percentage": 4}
      ],
      "languages": [
        {"language": "English", "percentage": 72},
        {"language": "Spanish", "percentage": 12},
        {"language": "French", "percentage": 6}
      ]
    },
    "activeHours": {
      "timezone": "America/New_York",
      "peakHours": ["09:00", "12:00", "18:00", "20:00"],
      "peakDays": ["Tuesday", "Wednesday", "Thursday"]
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
curl "https://api.contentdistribution.ai/v1/analytics/audience?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/engagement

Get detailed engagement analytics.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period (default: `30d`) |
| `platform` | string | No | Filter by platform |
| `granularity` | string | No | Granularity: `daily`, `weekly` (default: `daily`) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "summary": {
      "totalEngagement": 89450,
      "averageEngagementRate": 3.65,
      "bestEngagementRate": 8.2,
      "worstEngagementRate": 1.1
    },
    "byType": [
      {"type": "likes", "count": 52000, "percentage": 58.1},
      {"type": "comments", "count": 15600, "percentage": 17.4},
      {"type": "shares", "count": 12400, "percentage": 13.9},
      {"type": "saves", "count": 9450, "percentage": 10.6}
    ],
    "timeSeries": [
      {"date": "2025-06-01", "engagement": 2800, "rate": 3.2},
      {"date": "2025-06-02", "engagement": 3100, "rate": 3.5}
    ]
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
curl "https://api.contentdistribution.ai/v1/analytics/engagement?workspaceId=ws_abc123&period=30d" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/growth

Get follower growth analytics.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period (default: `30d`) |
| `platform` | string | No | Filter by platform |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "summary": {
      "startingFollowers": 42890,
      "currentFollowers": 45230,
      "totalGrowth": 2340,
      "growthRate": 5.45,
      "averageDailyGrowth": 78
    },
    "timeSeries": [
      {"date": "2025-06-01", "followers": 42890, "growth": 45},
      {"date": "2025-06-02", "followers": 42950, "growth": 60}
    ],
    "byPlatform": [
      {"platform": "twitter", "followers": 12500, "growth": 890, "growthRate": 7.67},
      {"platform": "linkedin", "followers": 8700, "growth": 650, "growthRate": 8.09},
      {"platform": "instagram", "followers": 18700, "growth": 720, "growthRate": 4.01}
    ],
    "milestones": [
      {"date": "2025-06-28", "count": 45000, "platform": "total"}
    ]
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
curl "https://api.contentdistribution.ai/v1/analytics/growth?workspaceId=ws_abc123&period=30d" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/content-performance

Get content performance analysis.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period (default: `30d`) |
| `groupBy` | string | No | Group by: `platform`, `category`, `contentType` (default: `platform`) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "performance": [
      {
        "group": "twitter",
        "posts": 67,
        "averageImpressions": 13284,
        "averageEngagement": 515,
        "averageEngagementRate": 3.88,
        "bestPerforming": {
          "postId": "post_abc123",
          "content": "Our latest feature update...",
          "impressions": 45000,
          "engagementRate": 5.11
        }
      },
      {
        "group": "linkedin",
        "posts": 45,
        "averageImpressions": 18000,
        "averageEngagement": 890,
        "averageEngagementRate": 4.94,
        "bestPerforming": {
          "postId": "post_def456",
          "content": "Industry insights report...",
          "impressions": 67000,
          "engagementRate": 7.2
        }
      }
    ],
    "insights": [
      "Video content performs 2.3x better than images",
      "Posts with questions get 45% more comments",
      "Tuesday and Wednesday have highest engagement"
    ]
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
curl "https://api.contentdistribution.ai/v1/analytics/content-performance?workspaceId=ws_abc123&period=30d" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/optimal-times

Get optimal posting times.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `platform` | string | No | Filter by platform |
| `timezone` | string | No | Timezone (default: account timezone) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "timezone": "America/New_York",
    "optimalTimes": {
      "twitter": [
        {"day": "Monday", "times": ["09:00", "12:00", "17:00"]},
        {"day": "Tuesday", "times": ["08:00", "11:00", "19:00"]},
        {"day": "Wednesday", "times": ["09:00", "12:00", "18:00"]},
        {"day": "Thursday", "times": ["10:00", "13:00", "20:00"]},
        {"day": "Friday", "times": ["09:00", "14:00"]},
        {"day": "Saturday", "times": ["10:00", "15:00"]},
        {"day": "Sunday", "times": ["11:00", "19:00"]}
      ],
      "linkedin": [
        {"day": "Tuesday", "times": ["08:00", "10:00", "12:00"]},
        {"day": "Wednesday", "times": ["09:00", "11:00", "17:00"]},
        {"day": "Thursday", "times": ["08:00", "10:00", "16:00"]}
      ]
    },
    "avoidTimes": [
      {"day": "Weekends", "times": ["00:00-06:00"], "reason": "Low activity"}
    ]
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
curl "https://api.contentdistribution.ai/v1/analytics/optimal-times?workspaceId=ws_abc123&timezone=America/New_York" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/hashtag-performance

Get hashtag performance analytics.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `period` | string | No | Period (default: `30d`) |
| `platform` | string | No | Filter by platform |
| `limit` | integer | No | Top N hashtags (default: 20) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "hashtags": [
      {
        "tag": "#SocialMediaMarketing",
        "posts": 45,
        "totalImpressions": 345000,
        "averageEngagementRate": 4.2,
        "reach": 234000,
        "trending": true
      },
      {
        "tag": "#ContentStrategy",
        "posts": 32,
        "totalImpressions": 210000,
        "averageEngagementRate": 3.8,
        "reach": 156000,
        "trending": false
      }
    ],
    "unusedHighPotential": [
      {
        "tag": "#AITools",
        "estimatedReach": 125000,
        "competition": "low",
        "relevance": 92
      }
    ]
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
curl "https://api.contentdistribution.ai/v1/analytics/hashtag-performance?workspaceId=ws_abc123&period=30d&limit=10" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/reports

List generated reports.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25) |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "rpt_abc123",
      "name": "June 2025 Monthly Report",
      "type": "monthly",
      "period": {
        "start": "2025-06-01",
        "end": "2025-06-30"
      },
      "status": "completed",
      "generatedAt": "2025-07-01T08:00:00Z",
      "downloadUrl": "https://cdn.example.com/reports/rpt_abc123.pdf"
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
curl "https://api.contentdistribution.ai/v1/analytics/reports?workspaceId=ws_abc123" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /analytics/reports

Generate a new analytics report.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `name` | string | Yes | Report name (2-100 chars) |
| `type` | string | Yes | Type: `custom`, `monthly`, `weekly`, `quarterly` |
| `period` | object | Yes | Start and end dates |
| `sections` | string[] | No | Sections: `overview`, `engagement`, `growth`, `content`, `audience` |
| `format` | string | No | Format: `pdf`, `csv`, `json` (default: `pdf`) |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "rpt_def456",
    "name": "Q2 2025 Performance Report",
    "type": "quarterly",
    "status": "generating",
    "estimatedCompletionAt": "2025-06-30T12:05:00Z",
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
curl -X POST https://api.contentdistribution.ai/v1/analytics/reports \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "ws_abc123",
    "name": "Q2 2025 Performance Report",
    "type": "quarterly",
    "period": {
      "start": "2025-04-01",
      "end": "2025-06-30"
    },
    "sections": ["overview", "engagement", "growth", "content"],
    "format": "pdf"
  }'
```

---

## GET /analytics/reports/{reportId}

Get report details and download URL.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `reportId` | string | Report ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "rpt_abc123",
    "name": "June 2025 Monthly Report",
    "type": "monthly",
    "status": "completed",
    "period": {
      "start": "2025-06-01",
      "end": "2025-06-30"
    },
    "sections": ["overview", "engagement", "growth", "content"],
    "format": "pdf",
    "fileSize": 2456789,
    "downloadUrl": "https://cdn.example.com/reports/rpt_abc123.pdf",
    "expiresAt": "2025-07-07T12:00:00Z",
    "generatedAt": "2025-07-01T08:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Report not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/analytics/reports/rpt_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## DELETE /analytics/reports/{reportId}

Delete a generated report.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `reportId` | string | Report ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Report not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/analytics/reports/rpt_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /analytics/export

Export analytics data.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workspaceId` | string | Yes | Workspace ID |
| `type` | string | Yes | Export type: `posts`, `engagement`, `growth`, `audience` |
| `period` | string | No | Period (default: `30d`) |
| `platform` | string | No | Filter by platform |
| `format` | string | No | Format: `csv`, `json` (default: `csv`) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "downloadUrl": "https://cdn.example.com/exports/export_abc123.csv",
    "expiresAt": "2025-07-01T12:00:00Z",
    "fileSize": 45678,
    "recordCount": 156
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
curl "https://api.contentdistribution.ai/v1/analytics/export?workspaceId=ws_abc123&type=posts&period=30d&format=csv" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```
