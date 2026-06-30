# Row-Level Security (RLS) Policies

## Overview

Row-Level Security enforces multi-tenant data isolation at the database level. Every query is automatically filtered by the current user's organization context, preventing cross-tenant data leaks regardless of application code.

## Enabling RLS

```sql
-- Enable RLS on all tenant-scoped tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE connected_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE media ENABLE ROW LEVEL SECURITY;
ALTER TABLE publish_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhooks ENABLE ROW LEVEL SECURITY;
```

## Setting Tenant Context

Every database connection must set the current organization and user context:

```sql
CREATE OR REPLACE FUNCTION set_current_tenant(
    p_organization_id UUID,
    p_user_id UUID
) RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_organization_id', p_organization_id::TEXT, TRUE);
    PERFORM set_config('app.current_user_id', p_user_id::TEXT, TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Application Usage

```sql
-- At the start of every request:
SELECT set_current_tenant('org-uuid-here', 'user-uuid-here');

-- All subsequent queries in the same transaction are automatically filtered
SELECT * FROM posts;  -- Only returns posts in the current organization
```

## Helper Functions

```sql
-- Get current organization ID from session
CREATE OR REPLACE FUNCTION current_organization_id()
RETURNS UUID AS $$
    SELECT NULLIF(current_setting('app.current_organization_id', TRUE), '')::UUID;
$$ LANGUAGE sql STABLE;

-- Get current user ID from session
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID AS $$
    SELECT NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;
$$ LANGUAGE sql STABLE;

-- Check if user is member of current organization
CREATE OR REPLACE FUNCTION is_org_member(p_org_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM organization_members
        WHERE organization_id = COALESCE(p_org_id, current_organization_id())
        AND user_id = current_user_id()
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get user's role in current organization
CREATE OR REPLACE FUNCTION current_org_role()
RETURNS VARCHAR(50) AS $$
    SELECT role FROM organization_members
    WHERE organization_id = current_organization_id()
    AND user_id = current_user_id();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is member of a workspace
CREATE OR REPLACE FUNCTION is_workspace_member(p_workspace_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM workspace_members
        WHERE workspace_id = p_workspace_id
        AND user_id = current_user_id()
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

## Organization-Level Policies

### organizations

```sql
-- Users can only see organizations they belong to
CREATE POLICY org_isolation ON organizations
    FOR ALL
    USING (id IN (
        SELECT organization_id FROM organization_members
        WHERE user_id = current_user_id()
    ));
```

### organization_members

```sql
-- Users can only see members of their organizations
CREATE POLICY org_members_isolation ON organization_members
    FOR ALL
    USING (organization_id IN (
        SELECT organization_id FROM organization_members
        WHERE user_id = current_user_id()
    ));

-- Users can only invite to organizations they admin
CREATE POLICY org_members_insert ON organization_members
    FOR INSERT
    WITH CHECK (
        current_org_role() IN ('owner', 'admin')
    );
```

### organization_invitations

```sql
-- Only org admins can manage invitations
CREATE POLICY org_invitations_isolation ON organization_invitations
    FOR ALL
    USING (organization_id IN (
        SELECT organization_id FROM organization_members
        WHERE user_id = current_user_id()
        AND role IN ('owner', 'admin')
    ));
```

### organization_settings

```sql
-- Users can read settings for their organizations
CREATE POLICY org_settings_read ON organization_settings
    FOR SELECT
    USING (is_org_member(organization_id));

-- Only admins can modify settings
CREATE POLICY org_settings_write ON organization_settings
    FOR ALL
    USING (
        organization_id IN (
            SELECT organization_id FROM organization_members
            WHERE user_id = current_user_id()
            AND role IN ('owner', 'admin')
        )
    );
```

## Workspace-Level Policies

### workspaces

```sql
-- Users can only see workspaces they are members of
CREATE POLICY workspace_isolation ON workspaces
    FOR ALL
    USING (id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

### workspace_members

```sql
-- Workspace membership visibility
CREATE POLICY workspace_members_isolation ON workspace_members
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

### connected_accounts

```sql
-- Users can only see connected accounts in their workspaces
CREATE POLICY connected_accounts_isolation ON connected_accounts
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

## Content Policies

### posts

```sql
-- Users can only see posts in their workspaces
CREATE POLICY posts_isolation ON posts
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));

-- Editors and above can create posts
CREATE POLICY posts_insert ON posts
    FOR INSERT
    WITH CHECK (
        workspace_id IN (
            SELECT workspace_id FROM workspace_members
            WHERE user_id = current_user_id()
            AND role IN ('admin', 'editor', 'member')
        )
    );
```

### post_versions

```sql
-- Post versions inherit post isolation
CREATE POLICY post_versions_isolation ON post_versions
    FOR ALL
    USING (post_id IN (
        SELECT id FROM posts
        WHERE workspace_id IN (
            SELECT workspace_id FROM workspace_members
            WHERE user_id = current_user_id()
        )
    ));
```

### post_analytics

```sql
-- Analytics inherit post isolation
CREATE POLICY post_analytics_isolation ON post_analytics
    FOR ALL
    USING (post_id IN (
        SELECT id FROM posts
        WHERE workspace_id IN (
            SELECT workspace_id FROM workspace_members
            WHERE user_id = current_user_id()
        )
    ));
```

### content_templates

```sql
-- Templates visible to org members
CREATE POLICY content_templates_isolation ON content_templates
    FOR ALL
    USING (is_org_member(organization_id));
```

### content_library

```sql
-- Library visible to org members
CREATE POLICY content_library_isolation ON content_library
    FOR ALL
    USING (is_org_member(organization_id));
```

## Media Policies

```sql
-- Media isolated to workspace
CREATE POLICY media_isolation ON media
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

## Publishing Policies

```sql
-- Publish queue isolated to workspace
CREATE POLICY publish_queue_isolation ON publish_queue
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));

-- Publish history isolated to workspace
CREATE POLICY publish_history_isolation ON publish_history
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

## AI Policies

```sql
-- AI jobs isolated to organization
CREATE POLICY ai_jobs_isolation ON ai_jobs
    FOR ALL
    USING (is_org_member(organization_id));

-- AI prompts visible to org members
CREATE POLICY ai_prompts_isolation ON ai_prompts
    FOR ALL
    USING (
        is_org_member(organization_id)
        OR is_system = TRUE
        OR is_public = TRUE
    );

-- AI credits isolated to organization
CREATE POLICY ai_credits_isolation ON ai_credits
    FOR ALL
    USING (is_org_member(organization_id));
```

## Analytics Policies

```sql
-- Analytics snapshots isolated to workspace
CREATE POLICY analytics_snapshots_isolation ON analytics_snapshots
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));

-- Goals isolated to workspace
CREATE POLICY analytics_goals_isolation ON analytics_goals
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));

-- Reports isolated to workspace
CREATE POLICY analytics_reports_isolation ON analytics_reports
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

## Notification Policies

```sql
-- Users only see their own notifications
CREATE POLICY notifications_isolation ON notifications
    FOR ALL
    USING (user_id = current_user_id());

-- Preferences isolated to user + org
CREATE POLICY notification_prefs_isolation ON notification_preferences
    FOR ALL
    USING (user_id = current_user_id());
```

## Billing Policies

```sql
-- Subscriptions visible to org admins
CREATE POLICY subscriptions_isolation ON subscriptions
    FOR ALL
    USING (
        organization_id IN (
            SELECT organization_id FROM organization_members
            WHERE user_id = current_user_id()
            AND role IN ('owner', 'admin')
        )
    );

-- Invoices visible to org admins
CREATE POLICY invoices_isolation ON invoices
    FOR ALL
    USING (
        organization_id IN (
            SELECT organization_id FROM organization_members
            WHERE user_id = current_user_id()
            AND role IN ('owner', 'admin')
        )
    );

-- Payments visible to org admins
CREATE POLICY payments_isolation ON payments
    FOR ALL
    USING (
        organization_id IN (
            SELECT organization_id FROM organization_members
            WHERE user_id = current_user_id()
            AND role IN ('owner', 'admin')
        )
    );
```

## Integration Policies

```sql
-- Integrations isolated to workspace
CREATE POLICY integrations_isolation ON integrations
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));

-- Webhooks isolated to workspace
CREATE POLICY webhooks_isolation ON webhooks
    FOR ALL
    USING (workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = current_user_id()
    ));
```

## Admin Policies

### audit_logs

```sql
-- Audit logs visible to org admins
CREATE POLICY audit_logs_isolation ON audit_logs
    FOR SELECT
    USING (
        organization_id IN (
            SELECT organization_id FROM organization_members
            WHERE user_id = current_user_id()
            AND role IN ('owner', 'admin')
        )
    );

-- System admins bypass RLS
CREATE POLICY audit_logs_admin ON audit_logs
    FOR ALL
    USING (
        current_setting('app.is_system_admin', TRUE) = 'true'
    );
```

### feature_flags

```sql
-- Feature flags visible to all, only admins can modify
CREATE POLICY feature_flags_read ON feature_flags
    FOR SELECT
    USING (TRUE);

CREATE POLICY feature_flags_write ON feature_flags
    FOR ALL
    USING (
        current_setting('app.is_system_admin', TRUE) = 'true'
    );
```

## Superadmin Bypass

System administrators bypass all RLS policies:

```sql
CREATE OR REPLACE FUNCTION bypass_rls()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN current_setting('app.is_system_admin', TRUE) = 'true';
END;
$$ LANGUAGE plpgsql STABLE;

-- Add bypass to each policy's USING clause:
-- ... AND (bypass_rls() OR <tenant_check>)

-- Example:
CREATE POLICY org_isolation_bypass ON organizations
    FOR ALL
    USING (
        bypass_rls()
        OR id IN (
            SELECT organization_id FROM organization_members
            WHERE user_id = current_user_id()
        )
    );
```

## Performance Considerations

### Index Requirements for RLS

Every column used in RLS policies MUST be indexed:

```sql
-- Already covered by existing indexes:
-- organization_members.organization_id + user_id (composite)
-- workspace_members.workspace_id + user_id (composite)
-- posts.workspace_id
-- media.workspace_id
-- etc.
```

### Policy Performance Tips

1. **Use SECURITY DEFINER** for helper functions to avoid nested RLS checks
2. **Cache tenant context** - Don't call `set_current_tenant()` on every query
3. **Avoid subqueries in policies** when possible - use session variables
4. **Test with EXPLAIN ANALYZE** to ensure policies don't cause full table scans
5. **Use composite indexes** for multi-column policy checks

### Monitoring RLS Performance

```sql
-- Check for sequential scans on RLS-protected tables
SELECT
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
WHERE relname IN ('posts', 'analytics_snapshots', 'audit_logs')
ORDER BY seq_scan DESC;
```

## Testing RLS

```sql
-- Test as specific user
SELECT set_current_tenant('test-org-id', 'test-user-id');

-- Verify isolation
SELECT count(*) FROM posts;
-- Should only return posts in test-org-id

-- Verify admin access
SELECT set_current_tenant('test-org-id', 'admin-user-id');
SELECT count(*) FROM audit_logs;
-- Should return audit logs for test-org-id

-- Verify cross-tenant isolation
SELECT set_current_tenant('org-a', 'user-from-org-a');
SELECT count(*) FROM posts WHERE workspace_id IN (
    SELECT id FROM workspaces WHERE organization_id = 'org-b'
);
-- Should return 0
```
