# Organization Tables

## organizations

Top-level tenant entity. Each org owns workspaces and billing.

```sql
CREATE TABLE organizations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    slug            VARCHAR(255) NOT NULL,
    logo_url        TEXT,
    website         TEXT,
    industry        VARCHAR(100),
    size            VARCHAR(50) CHECK (size IN ('solo', 'small', 'medium', 'large', 'enterprise')),
    plan            VARCHAR(50) NOT NULL DEFAULT 'free'
                    CHECK (plan IN ('free', 'starter', 'pro', 'enterprise')),
    trial_ends_at   TIMESTAMPTZ,
    status          VARCHAR(20) NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'suspended', 'deleted')),
    settings        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_organizations_slug UNIQUE (slug)
);

CREATE INDEX idx_organizations_slug ON organizations (slug);
CREATE INDEX idx_organizations_status ON organizations (status) WHERE status != 'deleted';
CREATE INDEX idx_organizations_plan ON organizations (plan);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Primary key |
| name | VARCHAR(255) | No | Organization display name |
| slug | VARCHAR(255) | No | URL-safe unique identifier |
| logo_url | TEXT | Yes | Brand logo image URL |
| website | TEXT | Yes | Company website |
| industry | VARCHAR(100) | Yes | Industry classification |
| size | VARCHAR(50) | Yes | Company size bracket |
| plan | VARCHAR(50) | No | Current subscription plan |
| trial_ends_at | TIMESTAMPTZ | Yes | Trial expiration |
| status | VARCHAR(20) | No | Org lifecycle status |
| settings | JSONB | No | Org-wide settings (JSON) |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## organization_members

Maps users to organizations with roles.

```sql
CREATE TABLE organization_members (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            VARCHAR(50) NOT NULL DEFAULT 'member'
                    CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
    invited_by      UUID REFERENCES users(id),
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_org_member UNIQUE (organization_id, user_id)
);

CREATE INDEX idx_org_members_organization_id ON organization_members (organization_id);
CREATE INDEX idx_org_members_user_id ON organization_members (user_id);
CREATE INDEX idx_org_members_role ON organization_members (role);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Membership identifier |
| organization_id | UUID | No | FK to organizations |
| user_id | UUID | No | FK to users |
| role | VARCHAR(50) | No | Permission level within org |
| invited_by | UUID | Yes | FK to users who sent invite |
| joined_at | TIMESTAMPTZ | No | When membership was established |

---

## organization_invitations

Pending invitations to join an organization.

```sql
CREATE TABLE organization_invitations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email           VARCHAR(255) NOT NULL,
    role            VARCHAR(50) NOT NULL DEFAULT 'member'
                    CHECK (role IN ('admin', 'member', 'viewer')),
    invited_by      UUID NOT NULL REFERENCES users(id),
    token_hash      VARCHAR(255) NOT NULL,
    expires_at      TIMESTAMPTZ NOT NULL,
    accepted_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_org_invitation_email UNIQUE (organization_id, email)
);

CREATE INDEX idx_org_invitations_organization_id ON organization_invitations (organization_id);
CREATE INDEX idx_org_invitations_email ON organization_invitations (email);
CREATE INDEX idx_org_invitations_token ON organization_invitations (token_hash);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Invitation identifier |
| organization_id | UUID | No | FK to organizations |
| email | VARCHAR(255) | No | Invitee email |
| role | VARCHAR(50) | No | Role to be assigned |
| invited_by | UUID | No | FK to inviting user |
| token_hash | VARCHAR(255) | No | SHA-256 of invitation token |
| expires_at | TIMESTAMPTZ | No | Invitation expiry (7 days) |
| accepted_at | TIMESTAMPTZ | Yes | When invitation was accepted |
| created_at | TIMESTAMPTZ | No | When invitation was sent |

---

## organization_settings

Key-value organization settings with type metadata.

```sql
CREATE TABLE organization_settings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    key             VARCHAR(255) NOT NULL,
    value           TEXT,
    value_type      VARCHAR(20) NOT NULL DEFAULT 'string'
                    CHECK (value_type IN ('string', 'number', 'boolean', 'json')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_org_setting_key UNIQUE (organization_id, key)
);

CREATE INDEX idx_org_settings_organization_id ON organization_settings (organization_id);
CREATE INDEX idx_org_settings_key ON organization_settings (key);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Setting identifier |
| organization_id | UUID | No | FK to organizations |
| key | VARCHAR(255) | No | Setting name (e.g., default_post_time) |
| value | TEXT | Yes | Setting value |
| value_type | VARCHAR(20) | No | Data type for parsing |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## organization_sso

SAML/OIDC SSO configuration per organization.

```sql
CREATE TABLE organization_sso (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    provider_type       VARCHAR(20) NOT NULL CHECK (provider_type IN ('saml', 'oidc')),
    provider_name       VARCHAR(255) NOT NULL,
    entity_id           TEXT NOT NULL,
    sso_url             TEXT NOT NULL,
    certificate         TEXT,
    client_id           VARCHAR(255),
    client_secret       TEXT,
    redirect_uri        TEXT,
    enabled             BOOLEAN NOT NULL DEFAULT FALSE,
    enforce_sso         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_org_sso UNIQUE (organization_id)
);

CREATE INDEX idx_org_sso_organization_id ON organization_sso (organization_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | SSO config identifier |
| organization_id | UUID | No | FK to organizations, one SSO per org |
| provider_type | VARCHAR(20) | No | Protocol type |
| provider_name | VARCHAR(255) | No | Display name (e.g., "Okta") |
| entity_id | TEXT | No | SAML Entity ID or OIDC issuer |
| sso_url | TEXT | No | SSO login URL |
| certificate | TEXT | Yes | PEM certificate for SAML |
| client_id | VARCHAR(255) | Yes | OIDC client ID |
| client_secret | TEXT | Yes | Encrypted OIDC client secret |
| redirect_uri | TEXT | Yes | Callback URL |
| enabled | BOOLEAN | No | Whether SSO is active |
| enforce_sso | BOOLEAN | No | Require SSO for all members |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## organization_billing

Billing details linked to payment provider.

```sql
CREATE TABLE organization_billing (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    stripe_customer_id  VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    billing_email       VARCHAR(255),
    billing_name        VARCHAR(255),
    billing_address     JSONB,
    tax_id              VARCHAR(100),
    payment_method      JSONB,
    next_invoice_date   DATE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_org_billing_org UNIQUE (organization_id),
    CONSTRAINT uq_org_billing_stripe_customer UNIQUE (stripe_customer_id)
);

CREATE INDEX idx_org_billing_organization_id ON organization_billing (organization_id);
CREATE INDEX idx_org_billing_stripe_customer ON organization_billing (stripe_customer_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Billing record identifier |
| organization_id | UUID | No | FK to organizations |
| stripe_customer_id | VARCHAR(255) | Yes | Stripe customer ID |
| stripe_subscription_id | VARCHAR(255) | Yes | Stripe subscription ID |
| billing_email | VARCHAR(255) | Yes | Email for invoices |
| billing_name | VARCHAR(255) | Yes | Name on invoice |
| billing_address | JSONB | Yes | Address object |
| tax_id | VARCHAR(100) | Yes | VAT/GST number |
| payment_method | JSONB | Yes | Stored payment method metadata |
| next_invoice_date | DATE | Yes | Next billing cycle date |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## organization_usage

Rolling usage counters for rate limits and quotas.

```sql
CREATE TABLE organization_usage (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    period_start        DATE NOT NULL,
    posts_created       INTEGER NOT NULL DEFAULT 0,
    posts_published     INTEGER NOT NULL DEFAULT 0,
    ai_credits_used     INTEGER NOT NULL DEFAULT 0,
    media_uploaded_bytes BIGINT NOT NULL DEFAULT 0,
    api_requests        INTEGER NOT NULL DEFAULT 0,
    team_members        INTEGER NOT NULL DEFAULT 1,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_org_usage_period UNIQUE (organization_id, period_start)
);

CREATE INDEX idx_org_usage_organization_id ON organization_usage (organization_id);
CREATE INDEX idx_org_usage_period_start ON organization_usage (period_start);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Usage record identifier |
| organization_id | UUID | No | FK to organizations |
| period_start | DATE | No | Billing period start date |
| posts_created | INTEGER | No | Posts created this period |
| posts_published | INTEGER | No | Posts published this period |
| ai_credits_used | INTEGER | No | AI credits consumed |
| media_uploaded_bytes | BIGINT | No | Total media upload bytes |
| api_requests | INTEGER | No | API calls made |
| team_members | INTEGER | No | Active member count |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## Triggers

```sql
CREATE TRIGGER trg_organizations_updated_at
    BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_organization_settings_updated_at
    BEFORE UPDATE ON organization_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_organization_sso_updated_at
    BEFORE UPDATE ON organization_sso
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_organization_billing_updated_at
    BEFORE UPDATE ON organization_billing
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_organization_usage_updated_at
    BEFORE UPDATE ON organization_usage
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```
