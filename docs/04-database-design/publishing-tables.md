# Publishing Tables

## publish_queue

Scheduled posts waiting to be published.

```sql
CREATE TABLE publish_queue (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id             UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    workspace_id        UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    connected_account_id UUID NOT NULL REFERENCES connected_accounts(id) ON DELETE CASCADE,
    platform            VARCHAR(50) NOT NULL,
    scheduled_at        TIMESTAMPTZ NOT NULL,
    timezone            VARCHAR(50) NOT NULL DEFAULT 'UTC',
    status              VARCHAR(30) NOT NULL DEFAULT 'pending'
                        CHECK (status IN (
                            'pending', 'processing', 'published', 'failed', 'cancelled', 'retrying'
                        )),
    retry_count         INTEGER NOT NULL DEFAULT 0,
    max_retries         INTEGER NOT NULL DEFAULT 3,
    last_attempt_at     TIMESTAMPTZ,
    next_retry_at       TIMESTAMPTZ,
    error_message       TEXT,
    platform_post_id    VARCHAR(255),
    publish_options     JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_publish_queue_scheduled_at ON publish_queue (scheduled_at) WHERE status = 'pending';
CREATE INDEX idx_publish_queue_post_id ON publish_queue (post_id);
CREATE INDEX idx_publish_queue_workspace_id ON publish_queue (workspace_id);
CREATE INDEX idx_publish_queue_organization_id ON publish_queue (organization_id);
CREATE INDEX idx_publish_queue_connected_account_id ON publish_queue (connected_account_id);
CREATE INDEX idx_publish_queue_status ON publish_queue (status);
CREATE INDEX idx_publish_queue_platform ON publish_queue (platform);
CREATE INDEX idx_publish_queue_next_retry ON publish_queue (next_retry_at) WHERE status = 'retrying';
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Queue item identifier |
| post_id | UUID | No | FK to posts |
| workspace_id | UUID | No | FK to workspaces |
| organization_id | UUID | No | FK to organizations |
| connected_account_id | UUID | No | FK to connected_accounts |
| platform | VARCHAR(50) | No | Target platform |
| scheduled_at | TIMESTAMPTZ | No | When to publish |
| timezone | VARCHAR(50) | No | Timezone for scheduling |
| status | VARCHAR(30) | No | Queue item status |
| retry_count | INTEGER | No | Number of publish attempts |
| max_retries | INTEGER | No | Maximum retry attempts |
| last_attempt_at | TIMESTAMPTZ | Yes | Last publish attempt time |
| next_retry_at | TIMESTAMPTZ | Yes | Scheduled retry time |
| error_message | TEXT | Yes | Last error message |
| platform_post_id | VARCHAR(255) | Yes | Post ID returned by platform |
| publish_options | JSONB | No | Platform-specific publish options |
| created_at | TIMESTAMPTZ | No | Queue insertion time |
| updated_at | TIMESTAMPTZ | No | Last status change time |

---

## publish_history

Immutable log of every publish attempt and result.

```sql
CREATE TABLE publish_history (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id             UUID NOT NULL REFERENCES posts(id) ON DELETE SET NULL,
    workspace_id        UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    connected_account_id UUID NOT NULL REFERENCES connected_accounts(id) ON DELETE CASCADE,
    platform            VARCHAR(50) NOT NULL,
    platform_post_id    VARCHAR(255),
    action              VARCHAR(30) NOT NULL CHECK (action IN ('publish', 'update', 'delete', 'retry')),
    status              VARCHAR(30) NOT NULL CHECK (status IN ('success', 'failed', 'partial')),
    request_payload     JSONB,
    response_payload    JSONB,
    error_code          VARCHAR(100),
    error_message       TEXT,
    duration_ms         INTEGER,
    published_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_publish_history_post_id ON publish_history (post_id);
CREATE INDEX idx_publish_history_workspace_id ON publish_history (workspace_id);
CREATE INDEX idx_publish_history_organization_id ON publish_history (organization_id);
CREATE INDEX idx_publish_history_connected_account_id ON publish_history (connected_account_id);
CREATE INDEX idx_publish_history_platform ON publish_history (platform);
CREATE INDEX idx_publish_history_status ON publish_history (status);
CREATE INDEX idx_publish_history_published_at ON publish_history (published_at DESC);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | History entry identifier |
| post_id | UUID | Yes | FK to posts (nullable on delete) |
| workspace_id | UUID | No | FK to workspaces |
| organization_id | UUID | No | FK to organizations |
| connected_account_id | UUID | No | FK to connected_accounts |
| platform | VARCHAR(50) | No | Target platform |
| platform_post_id | VARCHAR(255) | Yes | Post ID on platform |
| action | VARCHAR(30) | No | What was attempted |
| status | VARCHAR(30) | No | Outcome |
| request_payload | JSONB | Yes | What was sent to API |
| response_payload | JSONB | Yes | What came back |
| error_code | VARCHAR(100) | Yes | Platform error code |
| error_message | TEXT | Yes | Human-readable error |
| duration_ms | INTEGER | Yes | API call duration |
| published_at | TIMESTAMPTZ | No | When attempt occurred |

---

## publish_settings

Per-workspace/platform publishing preferences.

```sql
CREATE TABLE publish_settings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    platform        VARCHAR(50) NOT NULL,
    default_time    TIME,
    timezone        VARCHAR(50) NOT NULL DEFAULT 'UTC',
    auto_add_hashtags TEXT[] DEFAULT '{}',
    auto_add_mentions TEXT[] DEFAULT '{}',
    thread_mode     VARCHAR(20) DEFAULT 'single'
                    CHECK (thread_mode IN ('single', 'thread', 'carousel')),
    media_optimize  BOOLEAN NOT NULL DEFAULT TRUE,
    link_shortener  VARCHAR(50),
    utm_source      VARCHAR(100),
    utm_medium      VARCHAR(100),
    utm_campaign    VARCHAR(100),
    settings        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_publish_settings_workspace_platform UNIQUE (workspace_id, platform)
);

CREATE INDEX idx_publish_settings_workspace_id ON publish_settings (workspace_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Settings identifier |
| workspace_id | UUID | No | FK to workspaces |
| platform | VARCHAR(50) | No | Platform these settings apply to |
| default_time | TIME | Yes | Default publish time of day |
| timezone | VARCHAR(50) | No | Scheduling timezone |
| auto_add_hashtags | TEXT[] | No | Hashtags auto-appended to posts |
| auto_add_mentions | TEXT[] | No | Mentions auto-appended |
| thread_mode | VARCHAR(20) | No | How to handle long content |
| media_optimize | BOOLEAN | No | Auto-compress/resize media |
| link_shortener | VARCHAR(50) | Yes | URL shortener service |
| utm_source | VARCHAR(100) | Yes | UTM source parameter |
| utm_medium | VARCHAR(100) | Yes | UTM medium parameter |
| utm_campaign | VARCHAR(100) | Yes | UTM campaign parameter |
| settings | JSONB | No | Additional platform settings |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## auto_publish_rules

Rules that automatically schedule posts based on conditions.

```sql
CREATE TABLE auto_publish_rules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    created_by      UUID NOT NULL REFERENCES users(id),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    enabled         BOOLEAN NOT NULL DEFAULT TRUE,
    trigger_type    VARCHAR(50) NOT NULL
                    CHECK (trigger_type IN (
                        'ai_generated', 'from_template', 'brand_kit_match',
                        'content_type', 'hashtag_match', 'manual'
                    )),
    trigger_config  JSONB DEFAULT '{}',
    target_platforms TEXT[] NOT NULL,
    schedule_type   VARCHAR(30) NOT NULL DEFAULT 'optimal'
                    CHECK (schedule_type IN ('optimal', 'specific_time', 'interval', 'asap')),
    schedule_config JSONB DEFAULT '{}',
    priority        INTEGER NOT NULL DEFAULT 0,
    last_run_at     TIMESTAMPTZ,
    total_runs      INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_auto_publish_rules_workspace_id ON auto_publish_rules (workspace_id);
CREATE INDEX idx_auto_publish_rules_organization_id ON auto_publish_rules (organization_id);
CREATE INDEX idx_auto_publish_rules_enabled ON auto_publish_rules (enabled) WHERE enabled = TRUE;
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Rule identifier |
| workspace_id | UUID | No | FK to workspaces |
| organization_id | UUID | No | FK to organizations |
| created_by | UUID | No | FK to users |
| name | VARCHAR(255) | No | Rule name |
| description | TEXT | Yes | Rule description |
| enabled | BOOLEAN | No | Whether rule is active |
| trigger_type | VARCHAR(50) | No | What triggers the rule |
| trigger_config | JSONB | No | Trigger condition details |
| target_platforms | TEXT[] | No | Platforms to publish to |
| schedule_type | VARCHAR(30) | No | How to determine publish time |
| schedule_config | JSONB | No | Scheduling details |
| priority | INTEGER | No | Rule priority (higher = first) |
| last_run_at | TIMESTAMPTZ | Yes | Last execution time |
| total_runs | INTEGER | No | Execution count |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## Triggers

```sql
CREATE TRIGGER trg_publish_queue_updated_at
    BEFORE UPDATE ON publish_queue
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_publish_settings_updated_at
    BEFORE UPDATE ON publish_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_auto_publish_rules_updated_at
    BEFORE UPDATE ON auto_publish_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Archive to publish_history on publish attempt
CREATE OR REPLACE FUNCTION archive_publish_attempt()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'processing' AND NEW.status IN ('published', 'failed') THEN
        INSERT INTO publish_history (
            post_id, workspace_id, organization_id, connected_account_id,
            platform, platform_post_id, action, status,
            error_message, published_at
        ) VALUES (
            NEW.post_id, NEW.workspace_id, NEW.organization_id, NEW.connected_account_id,
            NEW.platform, NEW.platform_post_id,
            CASE WHEN NEW.status = 'published' THEN 'publish' ELSE 'retry' END,
            CASE WHEN NEW.status = 'published' THEN 'success' ELSE 'failed' END,
            NEW.error_message, NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_publish_archive
    AFTER UPDATE ON publish_queue
    FOR EACH ROW EXECUTE FUNCTION archive_publish_attempt();
```
