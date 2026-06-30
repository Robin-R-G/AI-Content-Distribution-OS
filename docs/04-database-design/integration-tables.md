# Integration Tables

## integrations

Third-party service connections (beyond social media accounts).

```sql
CREATE TABLE integrations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id        UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by          UUID NOT NULL REFERENCES users(id),
    integration_type    VARCHAR(50) NOT NULL
                        CHECK (integration_type IN (
                            'slack', 'discord', 'zapier', 'hubspot',
                            'salesforce', 'google_analytics', 'bitly',
                            'canva', 'figma', 'notion', 'trello',
                            'asana', 'github', 'gitlab', 'jira',
                            'google_drive', 'dropbox', 'onedrive',
                            'mailchimp', 'sendgrid', 'twilio', 'custom'
                        )),
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    status              VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'inactive', 'error', 'pending')),
    config              JSONB DEFAULT '{}',
    credentials         TEXT,
    credentials_iv      VARCHAR(100),
    webhook_url         TEXT,
    scopes              TEXT[] DEFAULT '{}',
    last_synced_at      TIMESTAMPTZ,
    sync_frequency      INTEGER DEFAULT 3600,
    error_count         INTEGER NOT NULL DEFAULT 0,
    last_error          TEXT,
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_integrations_organization_id ON integrations (organization_id);
CREATE INDEX idx_integrations_workspace_id ON integrations (workspace_id);
CREATE INDEX idx_integrations_type ON integrations (integration_type);
CREATE INDEX idx_integrations_status ON integrations (status);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Integration identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| created_by | UUID | No | FK to users who set it up |
| integration_type | VARCHAR(50) | No | Type of integration |
| name | VARCHAR(255) | No | User-assigned name |
| description | TEXT | Yes | What this integration does |
| status | VARCHAR(20) | No | Connection status |
| config | JSONB | No | Integration-specific configuration |
| credentials | TEXT | Yes | Encrypted API keys/tokens |
| credentials_iv | VARCHAR(100) | Yes | Encryption initialization vector |
| webhook_url | TEXT | Yes | Incoming webhook URL |
| scopes | TEXT[] | No | Granted permission scopes |
| last_synced_at | TIMESTAMPTZ | Yes | Last data sync |
| sync_frequency | INTEGER | No | Sync interval in seconds |
| error_count | INTEGER | No | Consecutive error count |
| last_error | TEXT | Yes | Last error message |
| metadata | JSONB | No | Additional integration data |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## integration_logs

Audit trail of all integration operations.

```sql
CREATE TABLE integration_logs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    integration_id      UUID NOT NULL REFERENCES integrations(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    operation           VARCHAR(50) NOT NULL,
    direction           VARCHAR(10) NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    status              VARCHAR(20) NOT NULL CHECK (status IN ('success', 'failed', 'timeout')),
    request_method      VARCHAR(10),
    request_url         TEXT,
    request_headers     JSONB,
    request_body        JSONB,
    response_status     INTEGER,
    response_body       JSONB,
    error_code          VARCHAR(100),
    error_message       TEXT,
    duration_ms         INTEGER,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_integration_logs_integration_id ON integration_logs (integration_id);
CREATE INDEX idx_integration_logs_organization_id ON integration_logs (organization_id);
CREATE INDEX idx_integration_logs_status ON integration_logs (status);
CREATE INDEX idx_integration_logs_created_at ON integration_logs (created_at DESC);
CREATE INDEX idx_integration_logs_operation ON integration_logs (operation);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Log identifier |
| integration_id | UUID | No | FK to integrations |
| organization_id | UUID | No | FK to organizations |
| operation | VARCHAR(50) | No | What operation was performed |
| direction | VARCHAR(10) | No | Inbound or outbound call |
| status | VARCHAR(20) | No | Outcome |
| request_method | VARCHAR(10) | Yes | HTTP method |
| request_url | TEXT | Yes | Request URL |
| request_headers | JSONB | Yes | Request headers (sanitized) |
| request_body | JSONB | Yes | Request payload |
| response_status | INTEGER | Yes | HTTP response code |
| response_body | JSONB | Yes | Response payload |
| error_code | VARCHAR(100) | Yes | Error code |
| error_message | TEXT | Yes | Error description |
| duration_ms | INTEGER | Yes | Request duration |
| created_at | TIMESTAMPTZ | No | Log time |

---

## webhooks

Outbound webhook configurations.

```sql
CREATE TABLE webhooks (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id        UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by          UUID NOT NULL REFERENCES users(id),
    url                 TEXT NOT NULL,
    secret              TEXT,
    events              TEXT[] NOT NULL,
    description         VARCHAR(255),
    enabled             BOOLEAN NOT NULL DEFAULT TRUE,
    content_type        VARCHAR(50) DEFAULT 'application/json',
    headers             JSONB DEFAULT '{}',
    retry_policy        JSONB DEFAULT '{"max_retries": 3, "backoff": "exponential"}',
    failure_count       INTEGER NOT NULL DEFAULT 0,
    last_triggered_at   TIMESTAMPTZ,
    last_status         INTEGER,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_webhooks_organization_id ON webhooks (organization_id);
CREATE INDEX idx_webhooks_workspace_id ON webhooks (workspace_id);
CREATE INDEX idx_webhooks_enabled ON webhooks (enabled) WHERE enabled = TRUE;
CREATE INDEX idx_webhooks_events ON webhooks USING GIN (events);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Webhook identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| created_by | UUID | No | FK to users |
| url | TEXT | No | Target URL for POST |
| secret | TEXT | Yes | HMAC signing secret |
| events | TEXT[] | No | Event types to subscribe to |
| description | VARCHAR(255) | Yes | What this webhook does |
| enabled | BOOLEAN | No | Whether webhook is active |
| content_type | VARCHAR(50) | No | Content-Type header |
| headers | JSONB | No | Custom headers to include |
| retry_policy | JSONB | No | Retry configuration |
| failure_count | INTEGER | No | Consecutive delivery failures |
| last_triggered_at | TIMESTAMPTZ | Yes | Last event time |
| last_status | INTEGER | Yes | Last response status code |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## webhook_deliveries

Log of every webhook delivery attempt.

```sql
CREATE TABLE webhook_deliveries (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    webhook_id          UUID NOT NULL REFERENCES webhooks(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSONB NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'success', 'failed', 'retrying')),
    attempt             INTEGER NOT NULL DEFAULT 1,
    max_attempts        INTEGER NOT NULL DEFAULT 3,
    response_status     INTEGER,
    response_body       TEXT,
    error_message       TEXT,
    duration_ms         INTEGER,
    next_retry_at       TIMESTAMPTZ,
    delivered_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_webhook_deliveries_webhook_id ON webhook_deliveries (webhook_id);
CREATE INDEX idx_webhook_deliveries_organization_id ON webhook_deliveries (organization_id);
CREATE INDEX idx_webhook_deliveries_status ON webhook_deliveries (status);
CREATE INDEX idx_webhook_deliveries_event_type ON webhook_deliveries (event_type);
CREATE INDEX idx_webhook_deliveries_created_at ON webhook_deliveries (created_at DESC);
CREATE INDEX idx_webhook_deliveries_next_retry ON webhook_deliveries (next_retry_at) WHERE status = 'retrying';
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Delivery identifier |
| webhook_id | UUID | No | FK to webhooks |
| organization_id | UUID | No | FK to organizations |
| event_type | VARCHAR(100) | No | Event that triggered delivery |
| payload | JSONB | No | Event payload sent |
| status | VARCHAR(20) | No | Delivery status |
| attempt | INTEGER | No | Current attempt number |
| max_attempts | INTEGER | No | Maximum delivery attempts |
| response_status | INTEGER | Yes | HTTP response code |
| response_body | TEXT | Yes | Response body |
| error_message | TEXT | Yes | Delivery error |
| duration_ms | INTEGER | Yes | Request duration |
| next_retry_at | TIMESTAMPTZ | Yes | Scheduled retry time |
| delivered_at | TIMESTAMPTZ | Yes | Successful delivery time |
| created_at | TIMESTAMPTZ | No | Creation time |

---

## Triggers

```sql
CREATE TRIGGER trg_integrations_updated_at
    BEFORE UPDATE ON integrations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_webhooks_updated_at
    BEFORE UPDATE ON webhooks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-increment webhook failure count
CREATE OR REPLACE FUNCTION update_webhook_failure_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'failed' THEN
        UPDATE webhooks SET failure_count = failure_count + 1 WHERE id = NEW.webhook_id;
    ELSIF NEW.status = 'success' THEN
        UPDATE webhooks SET failure_count = 0, last_status = NEW.response_status, last_triggered_at = NOW() WHERE id = NEW.webhook_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_webhook_delivery_status
    AFTER INSERT OR UPDATE ON webhook_deliveries
    FOR EACH ROW EXECUTE FUNCTION update_webhook_failure_count();
```
