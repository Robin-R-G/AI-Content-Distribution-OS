# Admin Tables

## audit_logs

Immutable audit trail of all significant actions across the system.

```sql
CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    user_id         UUID REFERENCES users(id) ON DELETE SET NULL,
    actor_email     VARCHAR(255),
    action          VARCHAR(100) NOT NULL,
    resource_type   VARCHAR(100) NOT NULL,
    resource_id     UUID,
    resource_name   VARCHAR(255),
    changes         JSONB,
    previous_values JSONB,
    ip_address      INET,
    user_agent      TEXT,
    session_id      UUID,
    status          VARCHAR(20) NOT NULL DEFAULT 'success'
                    CHECK (status IN ('success', 'failure', 'error')),
    error_message   TEXT,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_organization_id ON audit_logs (organization_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs (user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs (action);
CREATE INDEX idx_audit_logs_resource ON audit_logs (resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs (created_at DESC);
CREATE INDEX idx_audit_logs_status ON audit_logs (status);
CREATE INDEX idx_audit_logs_actor_email ON audit_logs (actor_email);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Log entry identifier |
| organization_id | UUID | Yes | FK to organizations (null for global actions) |
| user_id | UUID | Yes | FK to users (null for system actions) |
| actor_email | VARCHAR(255) | Yes | Email of the actor (denormalized) |
| action | VARCHAR(100) | No | Action performed (e.g., post.create, user.login) |
| resource_type | VARCHAR(100) | No | Entity type affected |
| resource_id | UUID | Yes | Entity ID affected |
| resource_name | VARCHAR(255) | Yes | Entity name for readability |
| changes | JSONB | Yes | Fields that changed |
| previous_values | JSONB | Yes | Values before change |
| ip_address | INET | Yes | Client IP |
| user_agent | TEXT | Yes | Client user agent |
| session_id | UUID | Yes | Session that performed action |
| status | VARCHAR(20) | No | Whether action succeeded |
| error_message | TEXT | Yes | Error details if failed |
| metadata | JSONB | No | Additional context |
| created_at | TIMESTAMPTZ | No | Action timestamp |

---

## feature_flags

Feature flags for gradual rollouts and A/B testing.

```sql
CREATE TABLE feature_flags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key             VARCHAR(100) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    enabled         BOOLEAN NOT NULL DEFAULT FALSE,
    flag_type       VARCHAR(30) NOT NULL DEFAULT 'boolean'
                    CHECK (flag_type IN ('boolean', 'percentage', 'variant', 'user_list')),
    percentage      INTEGER CHECK (percentage >= 0 AND percentage <= 100),
    variants        JSONB DEFAULT '[]',
    target_rules    JSONB DEFAULT '{}',
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_feature_flag_key UNIQUE (key)
);

CREATE INDEX idx_feature_flags_key ON feature_flags (key);
CREATE INDEX idx_feature_flags_enabled ON feature_flags (enabled);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Flag identifier |
| key | VARCHAR(100) | No | Unique flag key |
| name | VARCHAR(255) | No | Display name |
| description | TEXT | Yes | What this flag controls |
| enabled | BOOLEAN | No | Global on/off switch |
| flag_type | VARCHAR(30) | No | How flag is evaluated |
| percentage | INTEGER | Yes | Rollout percentage (0-100) |
| variants | JSONB | No | A/B test variant definitions |
| target_rules | JSONB | No | Targeting rules (org, user, plan) |
| created_by | UUID | Yes | FK to users |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

### feature_flag_overrides

Per-organization flag overrides.

```sql
CREATE TABLE feature_flag_overrides (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_flag_id     UUID NOT NULL REFERENCES feature_flags(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    enabled             BOOLEAN,
    percentage          INTEGER CHECK (percentage >= 0 AND percentage <= 100),
    variant             VARCHAR(100),
    reason              TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_flag_override UNIQUE (feature_flag_id, organization_id)
);

CREATE INDEX idx_flag_overrides_flag_id ON feature_flag_overrides (feature_flag_id);
CREATE INDEX idx_flag_overrides_org_id ON feature_flag_overrides (organization_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Override identifier |
| feature_flag_id | UUID | No | FK to feature_flags |
| organization_id | UUID | No | FK to organizations |
| enabled | BOOLEAN | Yes | Override enabled state |
| percentage | INTEGER | Yes | Override rollout percentage |
| variant | VARCHAR(100) | Yes | Override variant assignment |
| reason | TEXT | Yes | Why override exists |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## system_config

System-wide configuration stored in the database.

```sql
CREATE TABLE system_config (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key             VARCHAR(255) NOT NULL,
    value           TEXT NOT NULL,
    value_type      VARCHAR(20) NOT NULL DEFAULT 'string'
                    CHECK (value_type IN ('string', 'number', 'boolean', 'json')),
    category        VARCHAR(100) NOT NULL DEFAULT 'general',
    description     TEXT,
    is_secret       BOOLEAN NOT NULL DEFAULT FALSE,
    requires_restart BOOLEAN NOT NULL DEFAULT FALSE,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_system_config_key UNIQUE (key)
);

CREATE INDEX idx_system_config_key ON system_config (key);
CREATE INDEX idx_system_config_category ON system_config (category);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Config identifier |
| key | VARCHAR(255) | No | Unique configuration key |
| value | TEXT | No | Configuration value |
| value_type | VARCHAR(20) | No | Data type for parsing |
| category | VARCHAR(100) | No | Config category |
| description | TEXT | Yes | What this config controls |
| is_secret | BOOLEAN | No | Whether value should be masked |
| requires_restart | BOOLEAN | No | Whether change needs restart |
| created_by | UUID | Yes | FK to users |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## support_tickets

Customer support ticket tracking.

```sql
CREATE TABLE support_tickets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    user_id         UUID NOT NULL REFERENCES users(id),
    subject         VARCHAR(500) NOT NULL,
    description     TEXT NOT NULL,
    category        VARCHAR(100)
                    CHECK (category IN (
                        'bug', 'feature_request', 'billing', 'account',
                        'integration', 'performance', 'security', 'other'
                    )),
    priority        VARCHAR(20) NOT NULL DEFAULT 'medium'
                    CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status          VARCHAR(20) NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open', 'in_progress', 'waiting_customer', 'resolved', 'closed')),
    assigned_to     UUID REFERENCES users(id),
    resolution      TEXT,
    tags            TEXT[] DEFAULT '{}',
    attachments     JSONB DEFAULT '[]',
    first_response_at TIMESTAMPTZ,
    resolved_at     TIMESTAMPTZ,
    closed_at       TIMESTAMPTZ,
    satisfaction_rating INTEGER CHECK (satisfaction_rating >= 1 AND satisfaction_rating <= 5),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_support_tickets_organization_id ON support_tickets (organization_id);
CREATE INDEX idx_support_tickets_user_id ON support_tickets (user_id);
CREATE INDEX idx_support_tickets_status ON support_tickets (status);
CREATE INDEX idx_support_tickets_priority ON support_tickets (priority);
CREATE INDEX idx_support_tickets_assigned_to ON support_tickets (assigned_to);
CREATE INDEX idx_support_tickets_created_at ON support_tickets (created_at DESC);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Ticket identifier |
| organization_id | UUID | Yes | FK to organizations |
| user_id | UUID | No | FK to users (reporter) |
| subject | VARCHAR(500) | No | Ticket title |
| description | TEXT | No | Detailed description |
| category | VARCHAR(100) | Yes | Issue category |
| priority | VARCHAR(20) | No | Urgency level |
| status | VARCHAR(20) | No | Ticket status |
| assigned_to | UUID | Yes | FK to support staff |
| resolution | TEXT | Yes | Resolution notes |
| tags | TEXT[] | No | Classification tags |
| attachments | JSONB | No | File attachment references |
| first_response_at | TIMESTAMPTZ | Yes | Time to first response |
| resolved_at | TIMESTAMPTZ | Yes | Resolution time |
| closed_at | TIMESTAMPTZ | Yes | Closure time |
| satisfaction_rating | INTEGER | Yes | User satisfaction (1-5) |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## Triggers

```sql
CREATE TRIGGER trg_feature_flags_updated_at
    BEFORE UPDATE ON feature_flags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_feature_flag_overrides_updated_at
    BEFORE UPDATE ON feature_flag_overrides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_system_config_updated_at
    BEFORE UPDATE ON system_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_support_tickets_updated_at
    BEFORE UPDATE ON support_tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-set first response time
CREATE OR REPLACE FUNCTION set_first_response_time()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'open' AND NEW.status = 'in_progress' AND OLD.first_response_at IS NULL THEN
        NEW.first_response_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_first_response
    BEFORE UPDATE ON support_tickets
    FOR EACH ROW EXECUTE FUNCTION set_first_response_time();

-- Prevent audit log modifications
CREATE OR REPLACE FUNCTION prevent_audit_log_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Audit logs are immutable and cannot be modified';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_logs_immutable
    BEFORE UPDATE OR DELETE ON audit_logs
    FOR EACH ROW EXECUTE FUNCTION prevent_audit_log_modification();
```
