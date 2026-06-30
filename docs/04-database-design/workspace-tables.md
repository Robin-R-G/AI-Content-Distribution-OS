# Workspace Tables

## workspaces

Organizational subdivisions for grouping connected accounts and team workflows.

```sql
CREATE TABLE workspaces (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    slug            VARCHAR(255) NOT NULL,
    description     TEXT,
    avatar_url      TEXT,
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    settings        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_workspace_org_slug UNIQUE (organization_id, slug)
);

CREATE INDEX idx_workspaces_organization_id ON workspaces (organization_id);
CREATE INDEX idx_workspaces_slug ON workspaces (slug);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Primary key |
| organization_id | UUID | No | FK to organizations |
| name | VARCHAR(255) | No | Workspace display name |
| slug | VARCHAR(255) | No | URL-safe identifier within org |
| description | TEXT | Yes | Workspace description |
| avatar_url | TEXT | Yes | Workspace icon |
| is_default | BOOLEAN | No | Whether this is the org's default workspace |
| settings | JSONB | No | Workspace-specific settings |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## workspace_members

Maps users to workspaces with workspace-level roles.

```sql
CREATE TABLE workspace_members (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            VARCHAR(50) NOT NULL DEFAULT 'member'
                    CHECK (role IN ('admin', 'editor', 'member', 'viewer')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_workspace_member UNIQUE (workspace_id, user_id)
);

CREATE INDEX idx_workspace_members_workspace_id ON workspace_members (workspace_id);
CREATE INDEX idx_workspace_members_user_id ON workspace_members (user_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Membership identifier |
| workspace_id | UUID | No | FK to workspaces |
| user_id | UUID | No | FK to users |
| role | VARCHAR(50) | No | Permission level in workspace |
| created_at | TIMESTAMPTZ | No | Membership creation time |

---

## workspace_settings

Per-workspace configuration overrides.

```sql
CREATE TABLE workspace_settings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    key             VARCHAR(255) NOT NULL,
    value           TEXT,
    value_type      VARCHAR(20) NOT NULL DEFAULT 'string'
                    CHECK (value_type IN ('string', 'number', 'boolean', 'json')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_workspace_setting_key UNIQUE (workspace_id, key)
);

CREATE INDEX idx_workspace_settings_workspace_id ON workspace_settings (workspace_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Setting identifier |
| workspace_id | UUID | No | FK to workspaces |
| key | VARCHAR(255) | No | Setting name |
| value | TEXT | Yes | Setting value |
| value_type | VARCHAR(20) | No | Data type for parsing |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## connected_accounts

Social media account connections managed per workspace.

```sql
CREATE TABLE connected_accounts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    platform            VARCHAR(50) NOT NULL
                        CHECK (platform IN (
                            'twitter', 'facebook', 'instagram', 'linkedin',
                            'tiktok', 'youtube', 'pinterest', 'threads',
                            'reddit', 'mastodon', 'bluesky'
                        )),
    platform_account_id VARCHAR(255) NOT NULL,
    account_name        VARCHAR(255) NOT NULL,
    account_handle      VARCHAR(255),
    account_avatar_url  TEXT,
    access_token        TEXT,
    refresh_token       TEXT,
    token_expires_at    TIMESTAMPTZ,
    scopes              TEXT[] DEFAULT '{}',
    status              VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'expired', 'revoked', 'error')),
    last_synced_at      TIMESTAMPTZ,
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_connected_account_platform UNIQUE (workspace_id, platform, platform_account_id)
);

CREATE INDEX idx_connected_accounts_workspace_id ON connected_accounts (workspace_id);
CREATE INDEX idx_connected_accounts_organization_id ON connected_accounts (organization_id);
CREATE INDEX idx_connected_accounts_platform ON connected_accounts (platform);
CREATE INDEX idx_connected_accounts_status ON connected_accounts (status);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Connection identifier |
| workspace_id | UUID | No | FK to workspaces |
| organization_id | UUID | No | FK to organizations |
| platform | VARCHAR(50) | No | Social media platform |
| platform_account_id | VARCHAR(255) | No | Account ID on the platform |
| account_name | VARCHAR(255) | No | Display name on platform |
| account_handle | VARCHAR(255) | Yes | @handle on platform |
| account_avatar_url | TEXT | Yes | Profile picture URL |
| access_token | TEXT | Yes | Encrypted OAuth access token |
| refresh_token | TEXT | Yes | Encrypted refresh token |
| token_expires_at | TIMESTAMPTZ | Yes | Token expiry |
| scopes | TEXT[] | No | Granted OAuth scopes |
| status | VARCHAR(20) | No | Connection health status |
| last_synced_at | TIMESTAMPTZ | Yes | Last data sync time |
| metadata | JSONB | No | Platform-specific extra data |
| created_at | TIMESTAMPTZ | No | Connection creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## account_groups

Logical grouping of connected accounts for batch operations.

```sql
CREATE TABLE account_groups (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    color           VARCHAR(7),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_account_group_workspace_name UNIQUE (workspace_id, name)
);

CREATE TABLE account_group_members (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_group_id    UUID NOT NULL REFERENCES account_groups(id) ON DELETE CASCADE,
    connected_account_id UUID NOT NULL REFERENCES connected_accounts(id) ON DELETE CASCADE,

    CONSTRAINT uq_account_group_member UNIQUE (account_group_id, connected_account_id)
);

CREATE INDEX idx_account_groups_workspace_id ON account_groups (workspace_id);
CREATE INDEX idx_account_group_members_group_id ON account_group_members (account_group_id);
CREATE INDEX idx_account_group_members_account_id ON account_group_members (connected_account_id);
```

### account_groups

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Group identifier |
| workspace_id | UUID | No | FK to workspaces |
| name | VARCHAR(255) | No | Group name |
| description | TEXT | Yes | Group description |
| color | VARCHAR(7) | Yes | Hex color code for UI |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

### account_group_members

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Membership identifier |
| account_group_id | UUID | No | FK to account_groups |
| connected_account_id | UUID | No | FK to connected_accounts |

---

## Triggers

```sql
CREATE TRIGGER trg_workspaces_updated_at
    BEFORE UPDATE ON workspaces
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_workspace_settings_updated_at
    BEFORE UPDATE ON workspace_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_connected_accounts_updated_at
    BEFORE UPDATE ON connected_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_account_groups_updated_at
    BEFORE UPDATE ON account_groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```
