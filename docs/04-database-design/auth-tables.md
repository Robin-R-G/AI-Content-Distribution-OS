# Authentication Tables

## users

Core user account table. Single source of truth for identity.

```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) NOT NULL,
    email_verified  BOOLEAN NOT NULL DEFAULT FALSE,
    password_hash   VARCHAR(255),
    full_name       VARCHAR(255) NOT NULL,
    avatar_url      TEXT,
    locale          VARCHAR(10) DEFAULT 'en',
    timezone        VARCHAR(50) DEFAULT 'UTC',
    status          VARCHAR(20) NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'suspended', 'deleted')),
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_status ON users (status) WHERE status != 'deleted';
CREATE INDEX idx_users_created_at ON users (created_at);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Primary key |
| email | VARCHAR(255) | No | Login email, unique |
| email_verified | BOOLEAN | No | Whether email is confirmed |
| password_hash | VARCHAR(255) | Yes | Bcrypt hash; null for OAuth-only users |
| full_name | VARCHAR(255) | No | Display name |
| avatar_url | TEXT | Yes | Profile image URL |
| locale | VARCHAR(10) | No | Preferred language code |
| timezone | VARCHAR(50) | No | IANA timezone |
| status | VARCHAR(20) | No | Account status |
| last_login_at | TIMESTAMPTZ | Yes | Timestamp of last login |
| created_at | TIMESTAMPTZ | No | Record creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## sessions

Active user sessions for JWT refresh and session management.

```sql
CREATE TABLE sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(255) NOT NULL,
    ip_address      INET,
    user_agent      TEXT,
    expires_at      TIMESTAMPTZ NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_sessions_token_hash UNIQUE (token_hash)
);

CREATE INDEX idx_sessions_user_id ON sessions (user_id);
CREATE INDEX idx_sessions_expires_at ON sessions (expires_at);
CREATE INDEX idx_sessions_token_hash ON sessions (token_hash);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Session identifier |
| user_id | UUID | No | FK to users |
| token_hash | VARCHAR(255) | No | SHA-256 hash of session token |
| ip_address | INET | Yes | Client IP |
| user_agent | TEXT | Yes | Browser/client string |
| expires_at | TIMESTAMPTZ | No | Session expiration |
| created_at | TIMESTAMPTZ | No | Session creation time |

---

## oauth_connections

Third-party OAuth provider linkages.

```sql
CREATE TABLE oauth_connections (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider        VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    access_token    TEXT,
    refresh_token   TEXT,
    token_expires_at TIMESTAMPTZ,
    provider_data   JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_oauth_provider_user UNIQUE (provider, provider_user_id),
    CONSTRAINT uq_oauth_user_provider UNIQUE (user_id, provider)
);

CREATE INDEX idx_oauth_connections_user_id ON oauth_connections (user_id);
CREATE INDEX idx_oauth_connections_provider ON oauth_connections (provider);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Connection identifier |
| user_id | UUID | No | FK to users |
| provider | VARCHAR(50) | No | OAuth provider name (google, github, twitter, etc.) |
| provider_user_id | VARCHAR(255) | No | User ID at the provider |
| access_token | TEXT | Yes | Encrypted OAuth access token |
| refresh_token | TEXT | Yes | Encrypted refresh token |
| token_expires_at | TIMESTAMPTZ | Yes | Token expiration time |
| provider_data | JSONB | No | Extra profile/data from provider |
| created_at | TIMESTAMPTZ | No | Linkage creation time |
| updated_at | TIMESTAMPTZ | No | Last token refresh time |

---

## mfa_tokens

Multi-factor authentication TOTP and backup codes.

```sql
CREATE TABLE mfa_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    secret          VARCHAR(255) NOT NULL,
    type            VARCHAR(20) NOT NULL CHECK (type IN ('totp', 'backup_codes')),
    backup_codes    TEXT,
    enabled         BOOLEAN NOT NULL DEFAULT FALSE,
    last_used_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_mfa_user_type UNIQUE (user_id, type)
);

CREATE INDEX idx_mfa_tokens_user_id ON mfa_tokens (user_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | MFA token identifier |
| user_id | UUID | No | FK to users |
| secret | VARCHAR(255) | No | Encrypted TOTP secret or backup codes |
| type | VARCHAR(20) | No | Token type |
| backup_codes | TEXT | Yes | Hashed backup codes (newline-separated) |
| enabled | BOOLEAN | No | Whether MFA is active |
| last_used_at | TIMESTAMPTZ | Yes | Last successful MFA verification |
| created_at | TIMESTAMPTZ | No | Setup time |

---

## password_resets

Password reset tokens with expiry.

```sql
CREATE TABLE password_resets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(255) NOT NULL,
    expires_at      TIMESTAMPTZ NOT NULL,
    used_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_password_resets_token UNIQUE (token_hash)
);

CREATE INDEX idx_password_resets_user_id ON password_resets (user_id);
CREATE INDEX idx_password_resets_token ON password_resets (token_hash);
CREATE INDEX idx_password_resets_expires ON password_resets (expires_at);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Reset request identifier |
| user_id | UUID | No | FK to users |
| token_hash | VARCHAR(255) | No | SHA-256 hash of reset token |
| expires_at | TIMESTAMPTZ | No | Token expiry (1 hour) |
| used_at | TIMESTAMPTZ | Yes | When token was consumed |
| created_at | TIMESTAMPTZ | No | Request time |

---

## email_verifications

Email verification tokens for new accounts and email changes.

```sql
CREATE TABLE email_verifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email           VARCHAR(255) NOT NULL,
    token_hash      VARCHAR(255) NOT NULL,
    expires_at      TIMESTAMPTZ NOT NULL,
    verified_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_email_verifications_token UNIQUE (token_hash)
);

CREATE INDEX idx_email_verifications_user_id ON email_verifications (user_id);
CREATE INDEX idx_email_verifications_token ON email_verifications (token_hash);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Verification identifier |
| user_id | UUID | No | FK to users |
| email | VARCHAR(255) | No | Email being verified |
| token_hash | VARCHAR(255) | No | SHA-256 hash of verification token |
| expires_at | TIMESTAMPTZ | No | Token expiry (24 hours) |
| verified_at | TIMESTAMPTZ | Yes | When email was confirmed |
| created_at | TIMESTAMPTZ | No | Request time |

---

## api_keys

Programmatic API access keys.

```sql
CREATE TABLE api_keys (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    key_hash        VARCHAR(255) NOT NULL,
    key_prefix      VARCHAR(10) NOT NULL,
    scopes          TEXT[] NOT NULL DEFAULT '{}',
    rate_limit      INTEGER DEFAULT 1000,
    last_used_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    revoked_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_api_keys_key_hash UNIQUE (key_hash)
);

CREATE INDEX idx_api_keys_user_id ON api_keys (user_id);
CREATE INDEX idx_api_keys_key_hash ON api_keys (key_hash);
CREATE INDEX idx_api_keys_key_prefix ON api_keys (key_prefix);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | API key identifier |
| user_id | UUID | No | FK to users |
| name | VARCHAR(255) | No | Human-readable key name |
| key_hash | VARCHAR(255) | No | SHA-256 hash of the API key |
| key_prefix | VARCHAR(10) | No | First few chars for identification (e.g., `sk_live_`) |
| scopes | TEXT[] | No | Permission scopes (e.g., posts:read, posts:write) |
| rate_limit | INTEGER | No | Requests per hour limit |
| last_used_at | TIMESTAMPTZ | Yes | Last API call with this key |
| expires_at | TIMESTAMPTZ | Yes | Optional expiration |
| revoked_at | TIMESTAMPTZ | Yes | When key was revoked |
| created_at | TIMESTAMPTZ | No | Creation time |

---

## login_history

Audit log of all login attempts.

```sql
CREATE TABLE login_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id) ON DELETE SET NULL,
    email_used      VARCHAR(255) NOT NULL,
    ip_address      INET,
    user_agent      TEXT,
    status          VARCHAR(20) NOT NULL CHECK (status IN ('success', 'failed_password', 'failed_mfa', 'locked_out')),
    failure_reason  VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_login_history_user_id ON login_history (user_id);
CREATE INDEX idx_login_history_email ON login_history (email_used);
CREATE INDEX idx_login_history_created_at ON login_history (created_at);
CREATE INDEX idx_login_history_status ON login_history (status);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Log entry identifier |
| user_id | UUID | Yes | FK to users (null if user not found) |
| email_used | VARCHAR(255) | No | Email attempted |
| ip_address | INET | Yes | Client IP |
| user_agent | TEXT | Yes | Browser/client string |
| status | VARCHAR(20) | No | Outcome of the attempt |
| failure_reason | VARCHAR(255) | Yes | Detail if failed |
| created_at | TIMESTAMPTZ | No | Attempt timestamp |

---

## Triggers

```sql
-- Auto-update updated_at on users
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_oauth_connections_updated_at
    BEFORE UPDATE ON oauth_connections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-delete expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM sessions WHERE expires_at < NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```
