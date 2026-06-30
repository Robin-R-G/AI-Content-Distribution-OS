# Authentication Security

## JWT Implementation

### Token Structure

**Access Token** (short-lived, 15 minutes):
```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "roles": ["content_creator"],
  "permissions": ["content:create", "content:read"],
  "iat": 1700000000,
  "exp": 1700000900,
  "iss": "social-media-ai",
  "jti": "unique_token_id"
}
```

**Refresh Token** (long-lived, 7 days):
```json
{
  "sub": "user_id",
  "token_family": "family_id",
  "iat": 1700000000,
  "exp": 1700604800,
  "iss": "social-media-ai",
  "jti": "unique_refresh_id"
}
```

### Token Signing

```
Algorithm: RS256 (RSA with SHA-256)
Key Size: 2048-bit minimum
Rotation: Every 90 days
Storage: HSM for signing keys, separate from application
```

### Token Validation Steps

1. Verify signature against public key
2. Check `iss` claim matches expected issuer
3. Check `exp` claim has not passed
4. Check `iat` claim is not in the future
5. Verify token has not been revoked (jti lookup)
6. Check token family for refresh token rotation

## Token Storage

### Access Tokens
- Store in memory only (JavaScript variable)
- Never in localStorage, sessionStorage, or cookies with `HttpOnly: false`
- Pass via `Authorization: Bearer <token>` header

### Refresh Tokens
- Store in `HttpOnly`, `Secure`, `SameSite=Strict` cookie
- Never accessible via JavaScript
- Domain-scoped to prevent subdomain leakage

### Token Refresh Flow

```
1. Client detects 401 response
2. Client sends refresh request with refresh token cookie
3. Server validates refresh token
4. Server rotates refresh token (invalidate old, issue new)
5. Server returns new access token
6. Client retries original request
```

## Password Security

### Hashing Configuration

```
Algorithm: Argon2id (preferred) or bcrypt
Argon2id Parameters:
  - Memory: 64 MB
  - Iterations: 3
  - Parallelism: 4 threads
  - Salt length: 16 bytes
  - Hash length: 32 bytes

bcrypt Fallback:
  - Cost factor: 12
  - Salt rounds: 12
```

### Password Requirements

- Minimum 12 characters
- Maximum 128 characters
- At least one uppercase, lowercase, number, special character
- Check against Have I Been Pwned API for breached passwords
- No password reuse (last 12 passwords)

### Account Lockout Policy

```
Failed Login Attempts:
  - 5 failures: 15-minute lockout
  - 10 failures: 1-hour lockout
  - 15 failures: 24-hour lockout + manual review
  - 20+ failures: Account flagged, notification sent

Progressive Delays:
  - Attempt 1-3: No delay
  - Attempt 4-5: 1 second delay
  - Attempt 6-8: 5 seconds delay
  - Attempt 9+: 30 seconds delay
```

## OAuth 2.0 Security

### Authorization Code Flow with PKCE

```
1. Client generates code_verifier (43-128 chars, cryptographically random)
2. Client computes code_challenge = SHA256(code_verifier)
3. Client redirects to /authorize with:
   - response_type=code
   - client_id=...
   - redirect_uri=...
   - code_challenge=...
   - code_challenge_method=S256
   - state=<random_state>
4. User authenticates
5. Server redirects with code and state
6. Client verifies state matches
7. Client exchanges code for tokens with code_verifier
8. Server validates code_challenge matches SHA256(code_verifier)
```

### PKCE Security Properties

- Prevents authorization code interception
- Code challenge cannot be derived from code verifier (SHA256 is one-way)
- State parameter prevents CSRF attacks
- All requests must use HTTPS

### OAuth Scope Enforcement

```yaml
scopes:
  content:
    - content:read       # Read content
    - content:write      # Create/update content
    - content:delete     # Delete content
  analytics:
    - analytics:read     # View analytics
    - analytics:export   # Export data
  social:
    - social:post        # Post to social accounts
    - social:manage      # Manage connected accounts
  admin:
    - admin:users        # Manage users
    - admin:billing      # Manage billing
    - admin:settings     # Manage settings
```

### OAuth Provider Security

```
Allowed Providers:
  - Google (OAuth 2.0)
  - GitHub (OAuth 2.0)
  - Apple (OAuth 2.0)

Provider Requirements:
  - Enforce HTTPS redirect URIs
  - Validate provider-issued tokens server-side
  - Verify email claims
  - Map to existing accounts or create new
  - Link accounts by email with verification
```

## Session Management

### Session Configuration

```
Session Duration:
  - Idle timeout: 30 minutes
  - Absolute timeout: 24 hours
  - Remember me: 30 days (with re-authentication for sensitive actions)

Session Store:
  - Backend: Redis with TTL
  - Key format: session:{session_id}
  - Value: encrypted session data
```

### Session Security

1. Generate cryptographically random session IDs (256-bit minimum)
2. Regenerate session ID after login
3. Invalidate all sessions on password change
4. Invalidate session on logout (both access and refresh tokens)
5. Detect session fixation attacks
6. Limit concurrent sessions (5 per user)

### Multi-Device Session Management

```
GET /api/sessions
Response:
{
  "sessions": [
    {
      "id": "sess_abc123",
      "device": "Chrome on Windows",
      "ip": "192.168.1.100",
      "last_active": "2024-01-15T10:30:00Z",
      "current": true
    }
  ]
}

DELETE /api/sessions/{id}  # Revoke specific session
DELETE /api/sessions       # Revoke all sessions
```

## MFA (Multi-Factor Authentication)

### Supported Methods

1. **TOTP** (Time-based One-Time Password)
   - Google Authenticator, Authy
   - 30-second intervals
   - 6-digit codes

2. **WebAuthn/FIDO2**
   - Hardware security keys
   - Biometric authentication
   - Platform authenticators

3. **SMS** (fallback only)
   - Rate limited to 3 messages/hour
   - Geographic restrictions
   - Phone number verification required

### MFA Enforcement

```
Admin accounts: MFA required
Premium accounts: MFA recommended
Free accounts: MFA optional

Step-up authentication required for:
  - Password changes
  - Payment method changes
  - Account deletion
  - API key generation
```

## Security Headers for Authentication

```
Set-Cookie:
  refresh_token=...;
  HttpOnly;
  Secure;
  SameSite=Strict;
  Path=/api/auth/refresh;
  Max-Age=604800

Authorization: Bearer <access_token>
  (Transmitted over HTTPS only)
```

## Security Checklist

- [ ] JWT signed with RS256
- [ ] Access tokens expire in 15 minutes
- [ ] Refresh tokens rotate on use
- [ ] Passwords hashed with Argon2id
- [ ] Account lockout after 5 failures
- [ ] PKCE enforced for OAuth
- [ ] State parameter validated
- [ ] Session ID regenerated on login
- [ ] Sessions invalidated on password change
- [ ] MFA available for all users
- [ ] Step-up auth for sensitive operations
