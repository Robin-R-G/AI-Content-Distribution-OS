# Notification Tables

## notifications

User-facing notification messages.

```sql
CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    type            VARCHAR(50) NOT NULL
                    CHECK (type IN (
                        'post_published', 'post_failed', 'post_scheduled',
                        'comment_received', 'mention_received',
                        'team_invite', 'team_joined',
                        'billing_payment', 'billing_trial_ending',
                        'ai_job_completed', 'ai_credits_low',
                        'analytics_goal_reached', 'analytics_report_ready',
                        'integration_error', 'system_announcement',
                        'approval_needed', 'approval_completed'
                    )),
    title           VARCHAR(500) NOT NULL,
    body            TEXT,
    action_url      TEXT,
    entity_type     VARCHAR(100),
    entity_id       UUID,
    actor_id        UUID REFERENCES users(id),
    read_at         TIMESTAMPTZ,
    dismissed_at    TIMESTAMPTZ,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications (user_id);
CREATE INDEX idx_notifications_user_read ON notifications (user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_organization_id ON notifications (organization_id);
CREATE INDEX idx_notifications_type ON notifications (type);
CREATE INDEX idx_notifications_created_at ON notifications (created_at DESC);
CREATE INDEX idx_notifications_entity ON notifications (entity_type, entity_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Notification identifier |
| user_id | UUID | No | FK to users (recipient) |
| organization_id | UUID | Yes | FK to organizations context |
| type | VARCHAR(50) | No | Notification category |
| title | VARCHAR(500) | No | Short notification title |
| body | TEXT | Yes | Detailed notification text |
| action_url | TEXT | Yes | Deep link to relevant page |
| entity_type | VARCHAR(100) | Yes | Related entity type |
| entity_id | UUID | Yes | Related entity ID |
| actor_id | UUID | Yes | FK to users who triggered it |
| read_at | TIMESTAMPTZ | Yes | When user read it |
| dismissed_at | TIMESTAMPTZ | Yes | When user dismissed it |
| metadata | JSONB | No | Extra context data |
| created_at | TIMESTAMPTZ | No | Creation time |

---

## notification_preferences

Per-user notification delivery preferences.

```sql
CREATE TABLE notification_preferences (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    type            VARCHAR(50) NOT NULL,
    channel_email   BOOLEAN NOT NULL DEFAULT TRUE,
    channel_push    BOOLEAN NOT NULL DEFAULT TRUE,
    channel_in_app  BOOLEAN NOT NULL DEFAULT TRUE,
    channel_sms     BOOLEAN NOT NULL DEFAULT FALSE,
    digest_frequency VARCHAR(20) DEFAULT 'realtime'
                    CHECK (digest_frequency IN ('realtime', 'hourly', 'daily', 'weekly', 'never')),
    quiet_hours_start TIME,
    quiet_hours_end   TIME,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_notification_pref UNIQUE (user_id, organization_id, type)
);

CREATE INDEX idx_notification_preferences_user_id ON notification_preferences (user_id);
CREATE INDEX idx_notification_preferences_org_id ON notification_preferences (organization_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Preference identifier |
| user_id | UUID | No | FK to users |
| organization_id | UUID | Yes | FK to organizations; null = global |
| type | VARCHAR(50) | No | Notification type |
| channel_email | BOOLEAN | No | Send via email |
| channel_push | BOOLEAN | No | Send via push notification |
| channel_in_app | BOOLEAN | No | Show in-app |
| channel_sms | BOOLEAN | No | Send via SMS |
| digest_frequency | VARCHAR(20) | No | Digest cadence |
| quiet_hours_start | TIME | Yes | No notifications after this time |
| quiet_hours_end | TIME | Yes | Resume notifications at this time |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## notification_templates

Templates for system-generated notifications.

```sql
CREATE TABLE notification_templates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    type            VARCHAR(50) NOT NULL,
    channel         VARCHAR(20) NOT NULL CHECK (channel IN ('email', 'push', 'in_app', 'sms')),
    subject         VARCHAR(500),
    body_template   TEXT NOT NULL,
    html_template   TEXT,
    variables       JSONB DEFAULT '[]',
    locale          VARCHAR(10) DEFAULT 'en',
    enabled         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_notification_template UNIQUE (name, channel, locale)
);

CREATE INDEX idx_notification_templates_type ON notification_templates (type);
CREATE INDEX idx_notification_templates_channel ON notification_templates (channel);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Template identifier |
| name | VARCHAR(255) | No | Template name |
| type | VARCHAR(50) | No | Notification type |
| channel | VARCHAR(20) | No | Delivery channel |
| subject | VARCHAR(500) | Yes | Email/SMS subject |
| body_template | TEXT | No | Mustache/Handlebars template |
| html_template | TEXT | Yes | HTML email template |
| variables | JSONB | No | Template variable definitions |
| locale | VARCHAR(10) | No | Language code |
| enabled | BOOLEAN | No | Whether template is active |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## email_queue

Email messages waiting to be sent.

```sql
CREATE TABLE email_queue (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    to_address      VARCHAR(255) NOT NULL,
    from_address    VARCHAR(255) NOT NULL,
    subject         VARCHAR(500) NOT NULL,
    body_text       TEXT,
    body_html       TEXT,
    template_id     UUID REFERENCES notification_templates(id),
    template_vars   JSONB DEFAULT '{}',
    priority        INTEGER NOT NULL DEFAULT 0,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'sending', 'sent', 'failed', 'bounced')),
    retry_count     INTEGER NOT NULL DEFAULT 0,
    max_retries     INTEGER NOT NULL DEFAULT 3,
    error_message   TEXT,
    sent_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_email_queue_status ON email_queue (status) WHERE status IN ('pending', 'sending');
CREATE INDEX idx_email_queue_priority ON email_queue (priority DESC, created_at ASC) WHERE status = 'pending';
CREATE INDEX idx_email_queue_created_at ON email_queue (created_at);
CREATE INDEX idx_email_queue_to_address ON email_queue (to_address);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Queue entry identifier |
| to_address | VARCHAR(255) | No | Recipient email |
| from_address | VARCHAR(255) | No | Sender email |
| subject | VARCHAR(500) | No | Email subject |
| body_text | TEXT | Yes | Plain text body |
| body_html | TEXT | Yes | HTML body |
| template_id | UUID | Yes | FK to notification_templates |
| template_vars | JSONB | No | Template rendering variables |
| priority | INTEGER | No | Higher = sent first |
| status | VARCHAR(20) | No | Queue status |
| retry_count | INTEGER | No | Send attempts |
| max_retries | INTEGER | No | Maximum attempts |
| error_message | TEXT | Yes | Last error |
| sent_at | TIMESTAMPTZ | Yes | When email was sent |
| created_at | TIMESTAMPTZ | No | Queued time |

---

## push_queue

Push notifications waiting to be delivered.

```sql
CREATE TABLE push_queue (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_token    VARCHAR(500) NOT NULL,
    platform        VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    title           VARCHAR(500) NOT NULL,
    body            TEXT NOT NULL,
    badge_count     INTEGER,
    data            JSONB DEFAULT '{}',
    image_url       TEXT,
    action_url      TEXT,
    priority        INTEGER NOT NULL DEFAULT 0,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'sending', 'sent', 'failed', 'invalid_token')),
    retry_count     INTEGER NOT NULL DEFAULT 0,
    max_retries     INTEGER NOT NULL DEFAULT 3,
    error_message   TEXT,
    sent_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_push_queue_status ON push_queue (status) WHERE status IN ('pending', 'sending');
CREATE INDEX idx_push_queue_user_id ON push_queue (user_id);
CREATE INDEX idx_push_queue_priority ON push_queue (priority DESC, created_at ASC) WHERE status = 'pending';
CREATE INDEX idx_push_queue_device_token ON push_queue (device_token);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Queue entry identifier |
| user_id | UUID | No | FK to users |
| device_token | VARCHAR(500) | No | Push notification token |
| platform | VARCHAR(20) | No | Target platform |
| title | VARCHAR(500) | No | Notification title |
| body | TEXT | No | Notification body |
| badge_count | INTEGER | Yes | App badge number |
| data | JSONB | No | Deep link and payload data |
| image_url | TEXT | Yes | Rich notification image |
| action_url | TEXT | Yes | URL to open on tap |
| priority | INTEGER | No | Delivery priority |
| status | VARCHAR(20) | No | Queue status |
| retry_count | INTEGER | No | Send attempts |
| max_retries | INTEGER | No | Maximum attempts |
| error_message | TEXT | Yes | Last error |
| sent_at | TIMESTAMPTZ | Yes | When notification was sent |
| created_at | TIMESTAMPTZ | No | Queued time |

---

## Triggers

```sql
CREATE TRIGGER trg_notification_templates_updated_at
    BEFORE UPDATE ON notification_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_notification_preferences_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```
