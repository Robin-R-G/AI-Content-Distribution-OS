# Authentication API

## POST /auth/register

Register a new user account.

**Auth Required:** No

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | User email address |
| `password` | string | Yes | Password (min 8 chars, 1 uppercase, 1 number, 1 special) |
| `name` | string | Yes | Full name (2-100 chars) |
| `organizationName` | string | No | Name of organization to create |
| `acceptTerms` | boolean | Yes | Must be `true` |

**Validation Rules:**
- `email`: Valid email format, unique across system
- `password`: Min 8 chars, at least 1 uppercase, 1 lowercase, 1 number, 1 special char
- `name`: 2-100 characters
- `organizationName`: 2-100 characters if provided

**Success Response:** `201 Created`

```json
{
  "data": {
    "user": {
      "id": "usr_abc123",
      "email": "user@example.com",
      "name": "John Doe",
      "emailVerified": false,
      "createdAt": "2025-06-30T12:00:00Z"
    },
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "ref_abc123xyz",
    "expiresIn": 900
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 409 | `CONFLICT` | Email already registered |
| 422 | `UNPROCESSABLE` | Password does not meet requirements |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "name": "John Doe",
    "organizationName": "My Company",
    "acceptTerms": true
  }'
```

---

## POST /auth/login

Authenticate a user and receive tokens.

**Auth Required:** No

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | User email address |
| `password` | string | Yes | User password |
| `mfaCode` | string | No | MFA code if enabled |

**Success Response:** `200 OK`

```json
{
  "data": {
    "user": {
      "id": "usr_abc123",
      "email": "user@example.com",
      "name": "John Doe",
      "avatar": "https://cdn.example.com/avatars/usr_abc123.jpg",
      "mfaEnabled": true
    },
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "ref_abc123xyz",
    "expiresIn": 900,
    "requiresMfa": false
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Invalid credentials |
| 403 | `FORBIDDEN` | Account locked or disabled |
| 429 | `RATE_LIMITED` | Too many login attempts |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'
```

---

## POST /auth/logout

Invalidate the current session and refresh token.

**Auth Required:** Yes

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `refreshToken` | string | No | Specific refresh token to revoke. If omitted, all sessions are revoked |

**Success Response:** `204 No Content`

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "ref_abc123xyz"
  }'
```

---

## POST /auth/refresh

Exchange a refresh token for a new access token.

**Auth Required:** No

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `refreshToken` | string | Yes | Valid refresh token |

**Success Response:** `200 OK`

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "ref_newtoken456",
    "expiresIn": 900
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Missing refresh token |
| 401 | `UNAUTHORIZED` | Invalid or expired refresh token |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "ref_abc123xyz"
  }'
```

---

## POST /auth/forgot-password

Send a password reset email.

**Auth Required:** No

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Registered email address |

**Success Response:** `200 OK`

```json
{
  "data": {
    "message": "If the email exists, a reset link has been sent",
    "expiresIn": 3600
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid email format |
| 429 | `RATE_LIMITED` | Too many reset requests |

**Note:** Always returns 200 to prevent email enumeration.

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

---

## POST /auth/reset-password

Reset password using a valid reset token.

**Auth Required:** No

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | string | Yes | Password reset token from email |
| `password` | string | Yes | New password (min 8 chars, 1 uppercase, 1 number, 1 special) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "message": "Password has been reset successfully"
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid token or password format |
| 401 | `UNAUTHORIZED` | Token expired or invalid |
| 422 | `UNPROCESSABLE` | Password does not meet requirements |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "rst_abc123xyz",
    "password": "NewSecurePass123!"
  }'
```

---

## POST /auth/verify-email

Verify email address using verification token.

**Auth Required:** No

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | string | Yes | Email verification token |

**Success Response:** `200 OK`

```json
{
  "data": {
    "message": "Email verified successfully",
    "user": {
      "id": "usr_abc123",
      "email": "user@example.com",
      "emailVerified": true
    }
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Missing token |
| 401 | `UNAUTHORIZED` | Token expired or invalid |
| 409 | `CONFLICT` | Email already verified |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "token": "evt_abc123xyz"
  }'
```

---

## POST /auth/mfa/setup

Initialize MFA setup and receive a QR code URI.

**Auth Required:** Yes

**Request Body:** None

**Success Response:** `200 OK`

```json
{
  "data": {
    "secret": "JBSWY3DPEHPK3PXP",
    "qrCodeUrl": "otpauth://totp/ContentAI:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=ContentAI",
    "qrCodeImage": "data:image/png;base64,iVBORw0KGgo...",
    "recoveryCodes": [
      "abc1-def2-ghi3",
      "jkl4-mno5-pqr6",
      "stu7-vwx8-yza9"
    ]
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 409 | `CONFLICT` | MFA already enabled |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/mfa/setup \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

---

## POST /auth/mfa/verify

Verify MFA code to complete setup or login.

**Auth Required:** Yes (for setup) / No (for login with mfaToken)

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | 6-digit TOTP code |
| `mfaToken` | string | No | MFA token from login response (required during login flow) |

**Success Response:** `200 OK`

```json
{
  "data": {
    "verified": true,
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "ref_abc123xyz",
    "expiresIn": 900
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid code format |
| 401 | `UNAUTHORIZED` | Invalid MFA code |
| 404 | `NOT_FOUND` | MFA setup not initiated |

**Example Request:**

```bash
curl -X POST https://api.contentdistribution.ai/v1/auth/mfa/verify \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -d '{
    "code": "123456"
  }'
```

---

## GET /oauth/{provider}

Initiate OAuth authentication flow.

**Auth Required:** No

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `provider` | string | OAuth provider: `google`, `github`, `twitter`, `linkedin`, `facebook` |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `redirect_uri` | string | No | Custom redirect URI after authentication |
| `state` | string | No | CSRF protection state parameter |

**Success Response:** `302 Redirect`

Redirects to provider's authorization URL.

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid provider |
| 422 | `UNPROCESSABLE` | Provider not configured |

**Example Request:**

```bash
curl -L "https://api.contentdistribution.ai/v1/oauth/google?redirect_uri=https://app.example.com/callback"
```

---

## GET /oauth/{provider}/callback

Handle OAuth provider callback.

**Auth Required:** No

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `provider` | string | OAuth provider name |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `code` | string | Yes | Authorization code from provider |
| `state` | string | Yes | State parameter for CSRF validation |

**Success Response:** `200 OK`

```json
{
  "data": {
    "user": {
      "id": "usr_abc123",
      "email": "user@example.com",
      "name": "John Doe",
      "avatar": "https://cdn.example.com/avatars/usr_abc123.jpg"
    },
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "ref_abc123xyz",
    "expiresIn": 900,
    "isNewUser": true
  }
}
```

**Error Codes:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Missing code or state |
| 401 | `UNAUTHORIZED` | Invalid authorization code |
| 409 | `CONFLICT` | Email already associated with another account |

**Example Request:**

```bash
curl "https://api.contentdistribution.ai/v1/oauth/google/callback?code=auth_code_xyz&state=state_abc123"
```
