# Analytics Tables

## analytics_snapshots

Time-series snapshots of account and post metrics.

```sql
CREATE TABLE analytics_snapshots (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id        UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    connected_account_id UUID REFERENCES connected_accounts(id) ON DELETE SET NULL,
    post_id             UUID REFERENCES posts(id) ON DELETE SET NULL,
    snapshot_type       VARCHAR(30) NOT NULL
                        CHECK (snapshot_type IN (
                            'account_daily', 'account_hourly', 'post_realtime',
                            'post_daily', 'engagement', 'audience'
                        )),
    platform            VARCHAR(50) NOT NULL,
    metrics             JSONB NOT NULL DEFAULT '{}',
    dimensions          JSONB DEFAULT '{}',
    snapshot_date       DATE NOT NULL,
    snapshot_hour       INTEGER,
    period_start        TIMESTAMPTZ,
    period_end          TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_analytics_snapshots_organization_id ON analytics_snapshots (organization_id);
CREATE INDEX idx_analytics_snapshots_workspace_id ON analytics_snapshots (workspace_id);
CREATE INDEX idx_analytics_snapshots_connected_account_id ON analytics_snapshots (connected_account_id);
CREATE INDEX idx_analytics_snapshots_post_id ON analytics_snapshots (post_id);
CREATE INDEX idx_analytics_snapshots_type ON analytics_snapshots (snapshot_type);
CREATE INDEX idx_analytics_snapshots_platform ON analytics_snapshots (platform);
CREATE INDEX idx_analytics_snapshots_date ON analytics_snapshots (snapshot_date DESC);
CREATE INDEX idx_analytics_snapshots_date_type ON analytics_snapshots (snapshot_date DESC, snapshot_type);
CREATE INDEX idx_analytics_snapshots_metrics ON analytics_snapshots USING GIN (metrics);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Snapshot identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| connected_account_id | UUID | Yes | FK to connected_accounts |
| post_id | UUID | Yes | FK to posts |
| snapshot_type | VARCHAR(30) | No | Type of snapshot |
| platform | VARCHAR(50) | No | Source platform |
| metrics | JSONB | No | Metric values (followers, engagement, etc.) |
| dimensions | JSONB | No | Breakdown dimensions (country, age, etc.) |
| snapshot_date | DATE | No | Date of snapshot |
| snapshot_hour | INTEGER | Yes | Hour (for hourly snapshots) |
| period_start | TIMESTAMPTZ | Yes | Metric period start |
| period_end | TIMESTAMPTZ | Yes | Metric period end |
| created_at | TIMESTAMPTZ | No | Record creation time |

---

## analytics_goals

Trackable KPI goals with target values.

```sql
CREATE TABLE analytics_goals (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by      UUID NOT NULL REFERENCES users(id),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    goal_type       VARCHAR(50) NOT NULL
                    CHECK (goal_type IN (
                        'follower_growth', 'engagement_rate', 'reach',
                        'impressions', 'clicks', 'conversions',
                        'post_frequency', 'response_time', 'sentiment',
                        'custom'
                    )),
    metric_key      VARCHAR(100) NOT NULL,
    target_value    DECIMAL(15,2) NOT NULL,
    current_value   DECIMAL(15,2) DEFAULT 0,
    comparison      VARCHAR(20) DEFAULT 'gte'
                    CHECK (comparison IN ('gte', 'lte', 'eq', 'range')),
    min_value       DECIMAL(15,2),
    max_value       DECIMAL(15,2),
    connected_account_id UUID REFERENCES connected_accounts(id) ON DELETE SET NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          VARCHAR(20) NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'completed', 'failed', 'paused')),
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_analytics_goals_organization_id ON analytics_goals (organization_id);
CREATE INDEX idx_analytics_goals_workspace_id ON analytics_goals (workspace_id);
CREATE INDEX idx_analytics_goals_status ON analytics_goals (status);
CREATE INDEX idx_analytics_goals_goal_type ON analytics_goals (goal_type);
CREATE INDEX idx_analytics_goals_dates ON analytics_goals (start_date, end_date);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Goal identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| created_by | UUID | No | FK to users |
| name | VARCHAR(255) | No | Goal name |
| description | TEXT | Yes | Goal description |
| goal_type | VARCHAR(50) | No | Type of metric being tracked |
| metric_key | VARCHAR(100) | No | Key to look up in analytics data |
| target_value | DECIMAL(15,2) | No | Target metric value |
| current_value | DECIMAL(15,2) | No | Current progress |
| comparison | VARCHAR(20) | No | Comparison operator |
| min_value | DECIMAL(15,2) | Yes | Min for range comparison |
| max_value | DECIMAL(15,2) | Yes | Max for range comparison |
| connected_account_id | UUID | Yes | Specific account to track |
| start_date | DATE | No | Goal period start |
| end_date | DATE | Yes | Goal period end |
| status | VARCHAR(20) | No | Goal status |
| completed_at | TIMESTAMPTZ | Yes | When goal was achieved |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last update time |

---

## analytics_reports

Generated analytics reports with snapshots.

```sql
CREATE TABLE analytics_reports (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by      UUID NOT NULL REFERENCES users(id),
    name            VARCHAR(255) NOT NULL,
    report_type     VARCHAR(50) NOT NULL
                    CHECK (report_type IN (
                        'daily_summary', 'weekly_recap', 'monthly_overview',
                        'campaign_report', 'competitor_report', 'custom'
                    )),
    date_range_start DATE NOT NULL,
    date_range_end   DATE NOT NULL,
    filters         JSONB DEFAULT '{}',
    data            JSONB DEFAULT '{}',
    summary         TEXT,
    insights        JSONB DEFAULT '[]',
    file_url        TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'generating'
                    CHECK (status IN ('generating', 'completed', 'failed')),
    generated_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_analytics_reports_organization_id ON analytics_reports (organization_id);
CREATE INDEX idx_analytics_reports_workspace_id ON analytics_reports (workspace_id);
CREATE INDEX idx_analytics_reports_type ON analytics_reports (report_type);
CREATE INDEX idx_analytics_reports_date_range ON analytics_reports (date_range_start, date_range_end);
CREATE INDEX idx_analytics_reports_status ON analytics_reports (status);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Report identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| created_by | UUID | No | FK to users |
| name | VARCHAR(255) | No | Report title |
| report_type | VARCHAR(50) | No | Type of report |
| date_range_start | DATE | No | Report period start |
| date_range_end | DATE | No | Report period end |
| filters | JSONB | No | Applied filters |
| data | JSONB | No | Full report data |
| summary | TEXT | Yes | AI-generated summary |
| insights | JSONB | No | Array of key insights |
| file_url | TEXT | Yes | Exported PDF/CSV URL |
| status | VARCHAR(20) | No | Generation status |
| generated_at | TIMESTAMPTZ | Yes | When report was completed |
| expires_at | TIMESTAMPTZ | Yes | When export expires |
| created_at | TIMESTAMPTZ | No | Request time |

---

## competitor_tracking

Monitor competitor social media presence.

```sql
CREATE TABLE competitor_tracking (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id        UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by          UUID NOT NULL REFERENCES users(id),
    competitor_name     VARCHAR(255) NOT NULL,
    competitor_url      TEXT,
    platform            VARCHAR(50) NOT NULL,
    platform_account_id VARCHAR(255),
    account_handle      VARCHAR(255),
    tracking_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    last_analyzed_at    TIMESTAMPTZ,
    follower_count      INTEGER,
    avg_engagement_rate DECIMAL(5,4),
    post_frequency      DECIMAL(5,2),
    top_hashtags        TEXT[] DEFAULT '{}',
    notes               TEXT,
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_competitor_org_platform UNIQUE (organization_id, platform, platform_account_id)
);

CREATE INDEX idx_competitor_tracking_organization_id ON competitor_tracking (organization_id);
CREATE INDEX idx_competitor_tracking_workspace_id ON competitor_tracking (workspace_id);
CREATE INDEX idx_competitor_tracking_platform ON competitor_tracking (platform);
CREATE INDEX idx_competitor_tracking_enabled ON competitor_tracking (tracking_enabled) WHERE tracking_enabled = TRUE;
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Tracking identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| created_by | UUID | No | FK to users |
| competitor_name | VARCHAR(255) | No | Competitor display name |
| competitor_url | TEXT | Yes | Website URL |
| platform | VARCHAR(50) | No | Platform being tracked |
| platform_account_id | VARCHAR(255) | Yes | Account ID on platform |
| account_handle | VARCHAR(255) | Yes | @handle |
| tracking_enabled | BOOLEAN | No | Whether actively tracking |
| last_analyzed_at | TIMESTAMPTZ | Yes | Last analysis run |
| follower_count | INTEGER | Yes | Latest follower count |
| avg_engagement_rate | DECIMAL(5,4) | Yes | Average engagement rate |
| post_frequency | DECIMAL(5,2) | Yes | Posts per week |
| top_hashtags | TEXT[] | No | Most used hashtags |
| notes | TEXT | Yes | Manual notes |
| metadata | JSONB | No | Additional tracking data |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## Triggers

```sql
CREATE TRIGGER trg_analytics_goals_updated_at
    BEFORE UPDATE ON analytics_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_competitor_tracking_updated_at
    BEFORE UPDATE ON competitor_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-complete goals when target is met
CREATE OR REPLACE FUNCTION check_goal_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'active' AND NEW.current_value >= NEW.target_value THEN
        NEW.status = 'completed';
        NEW.completed_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_goal_completion
    BEFORE UPDATE ON analytics_goals
    FOR EACH ROW EXECUTE FUNCTION check_goal_completion();
```
