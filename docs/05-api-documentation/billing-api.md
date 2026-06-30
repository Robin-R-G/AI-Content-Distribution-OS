# Billing API

## GET /billing/subscription

Get current subscription details.

**Auth Required:** Yes

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "sub_abc123",
    "plan": "pro",
    "status": "active",
    "currentPeriod": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "pricing": {
      "amount": 4900,
      "currency": "USD",
      "interval": "month"
    },
    "features": {
      "workspaces": 5,
      "teamMembers": 10,
      "connectedAccounts": 20,
      "aiCredits": 100000,
      "postsPerMonth": 500,
      "analyticsRetention": 90
    },
    "usage": {
      "workspaces": 3,
      "teamMembers": 7,
      "connectedAccounts": 12,
      "aiCreditsUsed": 45000,
      "postsThisMonth": 156
    },
    "paymentMethod": {
      "id": "pm_abc123",
      "type": "card",
      "last4": "4242",
      "brand": "Visa",
      "expiresAt": "2027-12-31"
    },
    "nextBillingDate": "2025-07-01T00:00:00Z",
    "cancelAt": null
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/billing/subscription \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /billing/subscription

Create or update subscription.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `plan` | string | Yes | Plan: `free`, `starter`, `pro`, `business`, `enterprise` |
| `paymentMethodId` | string | Yes | Payment method ID |
| `couponCode` | string | No | Discount coupon code |
| `billingCycle` | string | No | `monthly` or `annual` (default: `monthly`) |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "sub_def456",
    "plan": "pro",
    "status": "active",
    "currentPeriod": {
      "start": "2025-06-30T12:00:00Z",
      "end": "2025-07-30T12:00:00Z"
    },
    "pricing": {
      "amount": 4900,
      "currency": "USD",
      "interval": "month",
      "discount": {
        "code": "SUMMER20",
        "percentOff": 20,
        "amountAfterDiscount": 3920
      }
    },
    "message": "Subscription created successfully"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Payment failed |
| 404 | `NOT_FOUND` | Payment method not found |
| 409 | `CONFLICT` | Active subscription already exists |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/billing/subscription \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "pro",
    "paymentMethodId": "pm_abc123",
    "billingCycle": "annual"
  }'
```

---

## PATCH /billing/subscription

Update subscription (change plan).

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `plan` | string | No | New plan |
| `paymentMethodId` | string | No | New payment method |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "sub_abc123",
    "plan": "business",
    "status": "active",
    "proration": {
      "amount": 5100,
      "credit": 2450,
      "charge": 7550,
      "immediate": true
    },
    "effectiveDate": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Payment failed for proration |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/billing/subscription \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "business"
  }'
```

---

## DELETE /billing/subscription

Cancel subscription.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reason` | string | No | Cancellation reason |
| `feedback` | string | No | Additional feedback |
| `cancelAtPeriodEnd` | boolean | No | Cancel at period end (default: true) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "sub_abc123",
    "status": "cancelling",
    "cancelAt": "2025-06-30T23:59:59Z",
    "accessUntil": "2025-06-30T23:59:59Z",
    "message": "Subscription will be cancelled at the end of the billing period"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | No active subscription |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/billing/subscription \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Too expensive",
    "cancelAtPeriodEnd": true
  }'
```

---

## GET /billing/invoices

List billing invoices.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 25, max: 100) |
| `status` | string | No | Filter: `paid`, `pending`, `failed`, `void` |

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "inv_abc123",
      "number": "INV-2025-006",
      "status": "paid",
      "amount": 4900,
      "currency": "USD",
      "description": "Pro Plan - Monthly",
      "periodStart": "2025-06-01T00:00:00Z",
      "periodEnd": "2025-06-30T23:59:59Z",
      "paidAt": "2025-06-01T00:00:00Z",
      "downloadUrl": "https://cdn.example.com/invoices/inv_abc123.pdf"
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

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/billing/invoices?status=paid" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## GET /billing/invoices/{invoiceId}

Get invoice details.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `invoiceId` | string | Invoice ID |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "inv_abc123",
    "number": "INV-2025-006",
    "status": "paid",
    "amount": 4900,
    "currency": "USD",
    "description": "Pro Plan - Monthly",
    "items": [
      {
        "description": "Pro Plan (Jun 1 - Jun 30)",
        "amount": 4900,
        "quantity": 1
      }
    ],
    "subtotal": 4900,
    "tax": 0,
    "total": 4900,
    "periodStart": "2025-06-01T00:00:00Z",
    "periodEnd": "2025-06-30T23:59:59Z",
    "paidAt": "2025-06-01T00:00:00Z",
    "paymentMethod": {
      "type": "card",
      "last4": "4242",
      "brand": "Visa"
    },
    "downloadUrl": "https://cdn.example.com/invoices/inv_abc123.pdf"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Invoice not found |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/billing/invoices/inv_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /billing/invoices/{invoiceId}/pay

Retry payment for a failed invoice.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `invoiceId` | string | Invoice ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `paymentMethodId` | string | No | Override payment method |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "inv_abc123",
    "status": "paid",
    "paidAt": "2025-06-30T12:00:00Z",
    "message": "Payment successful"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Payment declined |
| 404 | `NOT_FOUND` | Invoice not found |
| 409 | `CONFLICT` | Invoice already paid |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/billing/invoices/inv_abc123/pay \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "paymentMethodId": "pm_def456"
  }'
```

---

## GET /billing/payment-methods

List saved payment methods.

**Auth Required:** Yes

**Success Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "pm_abc123",
      "type": "card",
      "brand": "Visa",
      "last4": "4242",
      "expiresAt": "2027-12-31",
      "isDefault": true,
      "createdAt": "2025-01-15T08:00:00Z"
    },
    {
      "id": "pm_def456",
      "type": "card",
      "brand": "Mastercard",
      "last4": "8888",
      "expiresAt": "2026-08-31",
      "isDefault": false,
      "createdAt": "2025-03-10T10:00:00Z"
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
curl https://api.contentdistribution.ai/v1/billing/payment-methods \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /billing/payment-methods

Add a new payment method.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | string | Yes | Payment token from Stripe Elements |
| `setAsDefault` | boolean | No | Set as default payment method |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "pm_xyz789",
    "type": "card",
    "brand": "Visa",
    "last4": "1234",
    "expiresAt": "2028-06-30",
    "isDefault": false,
    "createdAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid token |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 402 | `PAYMENT_REQUIRED` | Card declined |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/billing/payment-methods \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "token": "tok_visa_4242",
    "setAsDefault": false
  }'
```

---

## DELETE /billing/payment-methods/{paymentMethodId}

Delete a payment method.

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `paymentMethodId` | string | Payment method ID |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Cannot delete default payment method with active subscription |
| 404 | `NOT_FOUND` | Payment method not found |

**Example Request:**

```bash
curl -X DELETE https://api.contentdistribution.ai/v1/billing/payment-methods/pm_def456 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## PATCH /billing/payment-methods/{paymentMethodId}

Update payment method (set as default).

**Auth Required:** Yes

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `paymentMethodId` | string | Payment method ID |

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `isDefault` | boolean | Yes | Set as default |

**Success Response:** `200 OK`

```json
{
  "data": {
    "id": "pm_abc123",
    "isDefault": true,
    "updatedAt": "2025-06-30T12:00:00Z"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 404 | `NOT_FOUND` | Payment method not found |

**Example Request:**

```bash
curl -X PATCH https://api.contentdistribution.ai/v1/billing/payment-methods/pm_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "isDefault": true
  }'
```

---

## GET /billing/credits

Get AI credit balance and history.

**Auth Required:** Yes

**Success Response:** `200 OK`

```json
{
  "data": {
    "balance": 87550,
    "monthlyAllocation": 100000,
    "usedThisMonth": 12450,
    "resetsAt": "2025-07-01T00:00:00Z",
    "purchasedCredits": 25000,
    "lifetimeUsed": 245000
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl https://api.contentdistribution.ai/v1/billing/credits \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /billing/credits/purchase

Purchase additional AI credits.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `amount` | integer | Yes | Number of credits (1000-100000) |
| `paymentMethodId` | string | Yes | Payment method ID |

**Success Response:** `201 Created`

```json
{
  "data": {
    "id": "crd_abc123",
    "amount": 10000,
    "cost": 2999,
    "currency": "USD",
    "newBalance": 97550,
    "paymentMethod": {
      "last4": "4242",
      "brand": "Visa"
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
| 402 | `PAYMENT_REQUIRED` | Payment declined |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/billing/credits/purchase \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 10000,
    "paymentMethodId": "pm_abc123"
  }'
```

---

## GET /billing/usage

Get billing usage details.

**Auth Required:** Yes

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `period` | string | No | Period: `current`, `previous` (default: `current`) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "period": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-06-30T23:59:59Z"
    },
    "plan": "pro",
    "included": {
      "workspaces": 5,
      "teamMembers": 10,
      "connectedAccounts": 20,
      "aiCredits": 100000,
      "postsPerMonth": 500
    },
    "used": {
      "workspaces": 3,
      "teamMembers": 7,
      "connectedAccounts": 12,
      "aiCredits": 45000,
      "postsThisMonth": 156
    },
    "overages": {
      "aiCredits": 0,
      "posts": 0,
      "estimatedOverageCharges": 0
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
curl "https://api.contentdistribution.ai/v1/billing/usage?period=current" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /billing/coupons/validate

Validate a coupon code.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | Coupon code |

**Success Response:** `200 OK`

```json
{
  "data": {
    "valid": true,
    "code": "SUMMER20",
    "discount": {
      "type": "percent",
      "value": 20
    },
    "description": "20% off for 3 months",
    "expiresAt": "2025-09-30T23:59:59Z",
    "maxUses": 1000,
    "usedCount": 456
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Missing code |
| 404 | `NOT_FOUND` | Invalid coupon code |
| 410 | `GONE` | Coupon expired or max uses reached |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/billing/coupons/validate \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SUMMER20"
  }'
```
