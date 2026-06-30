# Database Design Overview

## Purpose

This document outlines the database architecture for the AI Content Distribution OS — a multi-tenant, PostgreSQL-based system supporting content creation, AI processing, social media publishing, analytics, and billing for organizations managing multiple social media accounts.

---

## Design Principles

### 1. Multi-Tenancy First
Every user-facing table is scoped to an `org_id` (organization) or `workspace_id`. Row-level security (RLS) policies enforce tenant isolation at the database level, preventing cross-tenant data leakage regardless of application logic.

### 2. Normalization with Strategic Denormalization
- **3NF** as the baseline for transactional tables.
- **Denormalized fields** (`jsonb`, materialized aggregates) used only where read performance demands it (e.g., `analytics_snapshots`, `post_analytics`).
- No duplicate data across tables; references via foreign keys.

### 3. Temporal Data for Auditability
- Soft deletes via `deleted_at` timestamps on mutable tables.
- `created_at` / `updated_at` on every table.
- Full audit trail via `audit_logs` with JSONB change snapshots.

### 4. Extensibility via JSONB
- `settings`, `metadata`, `config`, `platform_specific` columns use `jsonb`.
- Allows schema flexibility without migrations for non-critical attributes.
- Indexed with GIN where query patterns require it.

### 5. Idempotent Migrations
- All migrations are forward-only in production.
- Rollback procedures documented but executed as corrective migrations.
- Versioned migration files with up/down scripts.

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Tables | `snake_case`, plural | `posts`, `organization_members` |
| Columns | `snake_case` | `created_at`, `user_id` |
| Primary Keys | `id` (UUID v7) | `id` |
| Foreign Keys | `<singular_table>_id` | `user_id`, `workspace_id` |
| Indexes | `idx_<table>_<columns>` | `idx_posts_workspace_id` |
| Unique Constraints | `uniq_<table>_<columns>` | `uniq_users_email` |
| Foreign Key Constraints | `fk_<table>_<referenced>` | `fk_posts_workspace` |
| Check Constraints | `chk_<table>_<description>` | `chk_posts_status` |
| Triggers | `trg_<table>_<event>` | `trg_posts_updated_at` |
| Views | `v_<description>` | `v_active_subscriptions` |

### Primary Key Strategy
- **UUID v7** for all primary keys — time-sortable, globally unique, no sequential leaks.
- Generated via `gen_random_uuid()` or application-level UUID v7 library.
- No auto-incrementing integers exposed externally.

### Foreign Key Naming
```
CONSTRAINT fk_<table>_<referenced_table>
  FOREIGN KEY (<column>)
  REFERENCES <referenced_table>(id)
```

---

## Schema Organization

The database is organized into logical schemas (PostgreSQL schemas) for namespace isolation:

```
public          — Core application tables (users, orgs, workspaces)
content         — Posts, drafts, templates, media, library
publishing      — Queue, history, settings, auto-publish
analytics       — Snapshots, goals, reports, competitor data
ai              — Jobs, prompts, credits, models
billing         — Subscriptions, invoices, payments, usage
notifications   — Notifications, preferences, queues
integrations    — Plugins, webhooks, logs
admin           — Audit logs, feature flags, config
auth            — Sessions, API keys, MFA, OAuth
```

### Why Schemas?
- Permission isolation (grant schema-level access to service roles).
- Reduced catalog bloat per query planner scope.
- Clear domain boundaries for developers.

---

## Data Types

### Standard Types
| Use Case | PostgreSQL Type |
|----------|----------------|
| Primary/Foreign Keys | `uuid` |
| Timestamps | `timestamptz` |
| Short text | `text` (with CHECK constraints) |
| Long text / HTML | `text` |
| Booleans | `boolean` |
| Integers | `integer` / `bigint` |
| Decimals (currency) | `numeric(12,2)` |
| JSON (schema-flexible) | `jsonb` |
| Arrays | `text[]` |
| Enumerated values | `text` with CHECK or custom ENUM type |

### Custom ENUM Types
```sql
CREATE TYPE post_status AS ENUM (
  'draft', 'scheduled', 'queued', 'publishing',
  'published', 'failed', 'cancelled'
);

CREATE TYPE post_type AS ENUM (
  'text', 'image', 'video', 'carousel', 'story',
  'reel', 'thread', 'poll', 'link'
);

CREATE TYPE platform_type AS ENUM (
  'twitter', 'instagram', 'facebook', 'linkedin',
  'tiktok', 'youtube', 'pinterest', 'threads'
);

CREATE TYPE member_role AS ENUM (
  'owner', 'admin', 'editor', 'viewer'
);
```

---

## Multi-Tenancy Strategy

### Organization → Workspace Hierarchy
```
Organization (billing entity, SSO, member management)
  └── Workspace (content silo, connected accounts, team access)
        └── Posts, Media, Analytics, Publishing
```

### Isolation Layers
1. **Application Layer**: All queries scoped by `org_id` from session context.
2. **Database Layer**: RLS policies on every tenant-facing table.
3. **Connection Layer**: Service roles use `SET app.current_org_id = '<uuid>'` per request.

### Tenant Context Injection
```sql
-- Set at connection start or per-request
SET LOCAL app.current_org_id = 'org_uuid_here';

-- RLS policy reads this
CREATE POLICY org_isolation ON posts
  USING (workspace_id IN (
    SELECT id FROM workspaces WHERE org_id = current_setting('app.current_org_id')::uuid
  ));
```

---

## UUID v7 Generation

```sql
-- PostgreSQL extension (if available)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Or use application-generated UUID v7 (time-ordered)
-- Format: <48-bit timestamp_ms>-<7-bit version>-<random>
```

### Why UUID v7 over UUID v4?
- **Time-sortable**: Natural ordering by creation time without explicit `created_at` index for range scans.
- **No sequential leaks**: Unlike auto-increment, UUIDs don't reveal entity counts.
- **Distributed-safe**: No coordination needed across application instances.
- **B-tree friendly**: Time-prefix reduces page splits vs. random UUID v4.

---

## Temporal Patterns

### Soft Deletes
```sql
ALTER TABLE posts ADD COLUMN deleted_at timestamptz;

-- Query pattern
SELECT * FROM posts WHERE deleted_at IS NULL AND workspace_id = $1;

-- Unique constraints must account for soft deletes
CREATE UNIQUE INDEX uniq_posts_id_active ON posts (id) WHERE deleted_at IS NULL;
```

### Created / Updated Triggers
```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Applied to every mutable table
CREATE TRIGGER trg_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## JSONB Usage Guidelines

### When to Use JSONB
- User-defined settings (`settings`, `config`).
- Platform-specific data that varies by integration (`platform_specific`).
- Variable metadata (`metadata`, `variables`).
- Audit change snapshots (`changes` in `audit_logs`).

### When NOT to Use JSONB
- Data that needs to be queried, joined, or aggregated relationally.
- Values with strict type requirements.
- Columns that participate in foreign keys or indexes (except GIN).

### GIN Indexing for JSONB
```sql
-- For exact-key lookups
CREATE INDEX idx_posts_platform_specific ON posts USING GIN (platform_specific);

-- For path-specific queries
CREATE INDEX idx_org_settings_theme ON organization_settings USING GIN (value jsonb_path_ops);
```

---

## Soft Delete & Retention

### Soft Delete Policy
- Tables with `deleted_at`: `posts`, `content_library`, `media`, `connected_accounts`.
- Hard delete after configurable retention period (default: 90 days).
- Scheduled job: `DELETE FROM <table> WHERE deleted_at < now() - INTERVAL '90 days'`.

### Data Retention by Domain
| Domain | Retention Period | Notes |
|--------|-----------------|-------|
| Posts (deleted) | 90 days | Hard delete after soft delete |
| Media (deleted) | 30 days | Also delete from object storage |
| Analytics | 2 years | Archive older to cold storage |
| Audit logs | 7 years | Compliance requirement |
| Login history | 1 year | Security auditing |
| AI jobs | 90 days | Input/output purged |
| Email queue | 30 days | Sent emails purged |

---

## Backup & Recovery

### Backup Strategy
- **Continuous WAL archiving** for point-in-time recovery.
- **Daily full backups** to separate region.
- **Hourly incremental backups** during business hours.
- **Monthly snapshots** retained for 1 year.

### Recovery Objectives
| Metric | Target |
|--------|--------|
| RPO (Recovery Point Objective) | < 5 minutes |
| RTO (Recovery Time Objective) | < 15 minutes |

### Test Recovery
- Monthly restore drills to staging environment.
- Verify data integrity with checksums.

---

## Performance Considerations

### Connection Pooling
- Use PgBouncer or application-level pooling.
- Max connections per service: 20-50.
- Transaction-level pooling for serverless functions.

### Query Optimization
- All foreign key columns indexed.
- Covering indexes for common query patterns.
- Partial indexes for filtered queries (e.g., `WHERE deleted_at IS NULL`).
- BRIN indexes for large time-series tables (`analytics_snapshots`).

### Partitioning Strategy
Large tables partitioned by time or tenant:
- `analytics_snapshots` → partitioned by `date` (monthly)
- `audit_logs` → partitioned by `created_at` (monthly)
- `ai_jobs` → partitioned by `created_at` (monthly)

---

## File Index

| File | Content |
|------|---------|
| [auth-tables.md](./auth-tables.md) | Authentication, sessions, OAuth, MFA, API keys |
| [organization-tables.md](./organization-tables.md) | Organizations, members, billing, SSO |
| [workspace-tables.md](./workspace-tables.md) | Workspaces, connected accounts, settings |
| [content-tables.md](./content-tables.md) | Posts, drafts, templates, media library, brand kits |
| [media-tables.md](./media-tables.md) | Media uploads, folders, tags |
| [publishing-tables.md](./publishing-tables.md) | Publish queue, history, settings, auto-publish rules |
| [ai-tables.md](./ai-tables.md) | AI jobs, prompts, credits, models |
| [analytics-tables.md](./analytics-tables.md) | Snapshots, goals, reports, competitor tracking |
| [notification-tables.md](./notification-tables.md) | Notifications, preferences, email/push queues |
| [billing-tables.md](./billing-tables.md) | Subscriptions, invoices, payments, usage |
| [integration-tables.md](./integration-tables.md) | Integrations, webhooks, logs |
| [admin-tables.md](./admin-tables.md) | Audit logs, feature flags, system config, support tickets |
| [migrations-strategy.md](./migrations-strategy.md) | Migration versioning, rollback, seed data |
| [indexes.md](./indexes.md) | Comprehensive index strategy |
| [row-level-security.md](./row-level-security.md) | RLS policies for multi-tenant isolation |
