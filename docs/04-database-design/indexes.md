# Comprehensive Index Strategy

## Principles

1. **Primary keys** - All tables use UUID primary keys with default `gen_random_uuid()`
2. **Foreign keys** - Every FK column gets an index for JOIN performance
3. **Common filters** - Index columns used in WHERE clauses
4. **Sort order** - Index columns used in ORDER BY (especially DESC for recent-first)
5. **Partial indexes** - Use WHERE clauses for commonly filtered subsets
6. **GIN indexes** - For JSONB columns, arrays, and full-text search
7. **Composite indexes** - For queries filtering on multiple columns

## Index Inventory by Table

### Authentication Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| users | idx_users_email | email | B-tree | Login lookup |
| users | idx_users_status | status | B-tree (partial) | WHERE status != 'deleted' |
| users | idx_users_created_at | created_at | B-tree | Sorting |
| sessions | idx_sessions_user_id | user_id | B-tree | User session lookup |
| sessions | idx_sessions_expires_at | expires_at | B-tree | Cleanup queries |
| sessions | idx_sessions_token_hash | token_hash | B-tree | Token validation |
| oauth_connections | idx_oauth_connections_user_id | user_id | B-tree | User connections |
| oauth_connections | idx_oauth_connections_provider | provider | B-tree | Provider filtering |
| mfa_tokens | idx_mfa_tokens_user_id | user_id | B-tree | User MFA lookup |
| password_resets | idx_password_resets_user_id | user_id | B-tree | User reset lookup |
| password_resets | idx_password_resets_token | token_hash | B-tree | Token validation |
| password_resets | idx_password_resets_expires | expires_at | B-tree | Cleanup |
| email_verifications | idx_email_verifications_user_id | user_id | B-tree | User verification |
| email_verifications | idx_email_verifications_token | token_hash | B-tree | Token validation |
| api_keys | idx_api_keys_user_id | user_id | B-tree | User keys |
| api_keys | idx_api_keys_key_hash | key_hash | B-tree | Key validation |
| api_keys | idx_api_keys_key_prefix | key_prefix | B-tree | Key identification |
| login_history | idx_login_history_user_id | user_id | B-tree | User history |
| login_history | idx_login_history_email | email_used | B-tree | Email lookup |
| login_history | idx_login_history_created_at | created_at | B-tree | Time-based queries |
| login_history | idx_login_history_status | status | B-tree | Failed login reports |

### Organization Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| organizations | idx_organizations_slug | slug | B-tree | URL lookup |
| organizations | idx_organizations_status | status | B-tree (partial) | WHERE status != 'deleted' |
| organizations | idx_organizations_plan | plan | B-tree | Plan filtering |
| organization_members | idx_org_members_organization_id | organization_id | B-tree | Org member listing |
| organization_members | idx_org_members_user_id | user_id | B-tree | User org lookup |
| organization_members | idx_org_members_role | role | B-tree | Role filtering |
| organization_invitations | idx_org_invitations_organization_id | organization_id | B-tree | Pending invites |
| organization_invitations | idx_org_invitations_email | email | B-tree | Email lookup |
| organization_invitations | idx_org_invitations_token | token_hash | B-tree | Token validation |
| organization_settings | idx_org_settings_organization_id | organization_id | B-tree | Org settings |
| organization_settings | idx_org_settings_key | key | B-tree | Key lookup |
| organization_sso | idx_org_sso_organization_id | organization_id | B-tree | Org SSO |
| organization_billing | idx_org_billing_organization_id | organization_id | B-tree | Org billing |
| organization_billing | idx_org_billing_stripe_customer | stripe_customer_id | B-tree | Stripe lookup |
| organization_usage | idx_org_usage_organization_id | organization_id | B-tree | Org usage |
| organization_usage | idx_org_usage_period_start | period_start | B-tree | Period queries |

### Workspace Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| workspaces | idx_workspaces_organization_id | organization_id | B-tree | Org workspace listing |
| workspaces | idx_workspaces_slug | slug | B-tree | URL lookup |
| workspace_members | idx_workspace_members_workspace_id | workspace_id | B-tree | Workspace member listing |
| workspace_members | idx_workspace_members_user_id | user_id | B-tree | User workspace lookup |
| workspace_settings | idx_workspace_settings_workspace_id | workspace_id | B-tree | Workspace settings |
| connected_accounts | idx_connected_accounts_workspace_id | workspace_id | B-tree | Workspace accounts |
| connected_accounts | idx_connected_accounts_organization_id | organization_id | B-tree | Org-wide accounts |
| connected_accounts | idx_connected_accounts_platform | platform | B-tree | Platform filtering |
| connected_accounts | idx_connected_accounts_status | status | B-tree | Status filtering |
| account_groups | idx_account_groups_workspace_id | workspace_id | B-tree | Workspace groups |
| account_group_members | idx_account_group_members_group_id | account_group_id | B-tree | Group membership |
| account_group_members | idx_account_group_members_account_id | connected_account_id | B-tree | Account groups |

### Content Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| posts | idx_posts_workspace_id | workspace_id | B-tree | Workspace posts |
| posts | idx_posts_organization_id | organization_id | B-tree | Org-wide posts |
| posts | idx_posts_created_by | created_by | B-tree | User posts |
| posts | idx_posts_status | status | B-tree | Status filtering |
| posts | idx_posts_scheduled_at | scheduled_at | B-tree (partial) | WHERE scheduled_at IS NOT NULL |
| posts | idx_posts_published_at | published_at | B-tree (partial) | WHERE published_at IS NOT NULL |
| posts | idx_posts_content_type | content_type | B-tree | Type filtering |
| posts | idx_posts_created_at | created_at DESC | B-tree | Recent posts |
| posts | idx_posts_hashtags | hashtags | GIN | Array search |
| posts | idx_posts_metadata | metadata | GIN | JSONB search |
| post_versions | idx_post_versions_post_id | post_id | B-tree | Post version history |
| post_versions | idx_post_versions_created_at | created_at DESC | B-tree | Recent versions |
| post_analytics | idx_post_analytics_post_id | post_id | B-tree | Post analytics |
| post_analytics | idx_post_analytics_account_id | connected_account_id | B-tree | Account analytics |
| post_analytics | idx_post_analytics_last_synced | last_synced_at | B-tree | Sync queries |
| content_templates | idx_content_templates_organization_id | organization_id | B-tree | Org templates |
| content_templates | idx_content_templates_workspace_id | workspace_id | B-tree | Workspace templates |
| content_templates | idx_content_templates_tags | tags | GIN | Tag search |
| content_drafts | idx_content_drafts_post_id | post_id | B-tree | Post drafts |
| content_drafts | idx_content_drafts_workspace_id | workspace_id | B-tree | Workspace drafts |
| content_library | idx_content_library_organization_id | organization_id | B-tree | Org library |
| content_library | idx_content_library_workspace_id | workspace_id | B-tree | Workspace library |
| content_library | idx_content_library_asset_type | asset_type | B-tree | Type filtering |
| content_library | idx_content_library_tags | tags | GIN | Tag search |
| hashtags | idx_hashtags_organization_id | organization_id | B-tree | Org hashtags |
| hashtags | idx_hashtags_tag | tag | B-tree | Tag lookup |
| hashtags | idx_hashtags_category | category | B-tree | Category filtering |
| hashtags | idx_hashtags_trending | trending_score DESC | B-tree | Trending hashtags |
| brand_kits | idx_brand_kits_organization_id | organization_id | B-tree | Org brand kits |

### Media Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| media | idx_media_organization_id | organization_id | B-tree | Org media |
| media | idx_media_workspace_id | workspace_id | B-tree | Workspace media |
| media | idx_media_uploaded_by | uploaded_by | B-tree | User uploads |
| media | idx_media_folder_id | folder_id | B-tree | Folder contents |
| media | idx_media_mime_type | mime_type | B-tree | Type filtering |
| media | idx_media_status | status | B-tree | Status filtering |
| media | idx_media_created_at | created_at DESC | B-tree | Recent uploads |
| media | idx_media_storage_key | storage_key | B-tree | Storage lookup |
| media_folders | idx_media_folders_organization_id | organization_id | B-tree | Org folders |
| media_folders | idx_media_folders_workspace_id | workspace_id | B-tree | Workspace folders |
| media_folders | idx_media_folders_parent_id | parent_id | B-tree | Folder hierarchy |
| media_folders | idx_media_folders_path | path | B-tree | Path lookups |
| media_tags | idx_media_tags_organization_id | organization_id | B-tree | Org tags |
| media_tags | idx_media_tags_name | name | B-tree | Tag lookup |
| media_tag_assignments | idx_media_tag_assignments_media_id | media_id | B-tree | Media tags |
| media_tag_assignments | idx_media_tag_assignments_tag_id | media_tag_id | B-tree | Tagged media |

### Publishing Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| publish_queue | idx_publish_queue_scheduled_at | scheduled_at | B-tree (partial) | WHERE status = 'pending' |
| publish_queue | idx_publish_queue_post_id | post_id | B-tree | Post queue status |
| publish_queue | idx_publish_queue_workspace_id | workspace_id | B-tree | Workspace queue |
| publish_queue | idx_publish_queue_organization_id | organization_id | B-tree | Org queue |
| publish_queue | idx_publish_queue_connected_account_id | connected_account_id | B-tree | Account queue |
| publish_queue | idx_publish_queue_status | status | B-tree | Status filtering |
| publish_queue | idx_publish_queue_platform | platform | B-tree | Platform filtering |
| publish_queue | idx_publish_queue_next_retry | next_retry_at | B-tree (partial) | WHERE status = 'retrying' |
| publish_history | idx_publish_history_post_id | post_id | B-tree | Post history |
| publish_history | idx_publish_history_workspace_id | workspace_id | B-tree | Workspace history |
| publish_history | idx_publish_history_organization_id | organization_id | B-tree | Org history |
| publish_history | idx_publish_history_connected_account_id | connected_account_id | B-tree | Account history |
| publish_history | idx_publish_history_platform | platform | B-tree | Platform filtering |
| publish_history | idx_publish_history_status | status | B-tree | Status filtering |
| publish_history | idx_publish_history_published_at | published_at DESC | B-tree | Recent history |
| publish_settings | idx_publish_settings_workspace_id | workspace_id | B-tree | Workspace settings |
| auto_publish_rules | idx_auto_publish_rules_workspace_id | workspace_id | B-tree | Workspace rules |
| auto_publish_rules | idx_auto_publish_rules_organization_id | organization_id | B-tree | Org rules |
| auto_publish_rules | idx_auto_publish_rules_enabled | enabled | B-tree (partial) | WHERE enabled = TRUE |

### AI Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| ai_jobs | idx_ai_jobs_organization_id | organization_id | B-tree | Org jobs |
| ai_jobs | idx_ai_jobs_workspace_id | workspace_id | B-tree | Workspace jobs |
| ai_jobs | idx_ai_jobs_user_id | user_id | B-tree | User jobs |
| ai_jobs | idx_ai_jobs_post_id | post_id | B-tree | Post-related jobs |
| ai_jobs | idx_ai_jobs_status | status | B-tree | Status filtering |
| ai_jobs | idx_ai_jobs_job_type | job_type | B-tree | Type filtering |
| ai_jobs | idx_ai_jobs_created_at | created_at DESC | B-tree | Recent jobs |
| ai_jobs | idx_ai_jobs_model | model | B-tree | Model filtering |
| ai_prompts | idx_ai_prompts_organization_id | organization_id | B-tree | Org prompts |
| ai_prompts | idx_ai_prompts_created_by | created_by | B-tree | User prompts |
| ai_prompts | idx_ai_prompts_category | category | B-tree | Category filtering |
| ai_prompts | idx_ai_prompts_tags | tags | GIN | Tag search |
| ai_prompts | idx_ai_prompts_is_system | is_system | B-tree (partial) | WHERE is_system = TRUE |
| ai_credits | idx_ai_credits_organization_id | organization_id | B-tree | Org credits |
| ai_credit_transactions | idx_ai_credit_transactions_organization_id | organization_id | B-tree | Org transactions |
| ai_credit_transactions | idx_ai_credit_transactions_ai_job_id | ai_job_id | B-tree | Job transactions |
| ai_credit_transactions | idx_ai_credit_transactions_type | type | B-tree | Type filtering |
| ai_credit_transactions | idx_ai_credit_transactions_created_at | created_at DESC | B-tree | Recent transactions |
| ai_models | idx_ai_models_provider | provider | B-tree | Provider filtering |
| ai_models | idx_ai_models_enabled | enabled | B-tree (partial) | WHERE enabled = TRUE |

### Analytics Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| analytics_snapshots | idx_analytics_snapshots_organization_id | organization_id | B-tree | Org snapshots |
| analytics_snapshots | idx_analytics_snapshots_workspace_id | workspace_id | B-tree | Workspace snapshots |
| analytics_snapshots | idx_analytics_snapshots_connected_account_id | connected_account_id | B-tree | Account snapshots |
| analytics_snapshots | idx_analytics_snapshots_post_id | post_id | B-tree | Post snapshots |
| analytics_snapshots | idx_analytics_snapshots_type | snapshot_type | B-tree | Type filtering |
| analytics_snapshots | idx_analytics_snapshots_platform | platform | B-tree | Platform filtering |
| analytics_snapshots | idx_analytics_snapshots_date | snapshot_date DESC | B-tree | Recent snapshots |
| analytics_snapshots | idx_analytics_snapshots_date_type | snapshot_date DESC, snapshot_type | Composite | Date + type queries |
| analytics_snapshots | idx_analytics_snapshots_metrics | metrics | GIN | JSONB search |
| analytics_goals | idx_analytics_goals_organization_id | organization_id | B-tree | Org goals |
| analytics_goals | idx_analytics_goals_workspace_id | workspace_id | B-tree | Workspace goals |
| analytics_goals | idx_analytics_goals_status | status | B-tree | Status filtering |
| analytics_goals | idx_analytics_goals_goal_type | goal_type | B-tree | Type filtering |
| analytics_goals | idx_analytics_goals_dates | start_date, end_date | Composite | Date range queries |
| analytics_reports | idx_analytics_reports_organization_id | organization_id | B-tree | Org reports |
| analytics_reports | idx_analytics_reports_workspace_id | workspace_id | B-tree | Workspace reports |
| analytics_reports | idx_analytics_reports_type | report_type | B-tree | Type filtering |
| analytics_reports | idx_analytics_reports_date_range | date_range_start, date_range_end | Composite | Date range queries |
| analytics_reports | idx_analytics_reports_status | status | B-tree | Status filtering |
| competitor_tracking | idx_competitor_tracking_organization_id | organization_id | B-tree | Org competitors |
| competitor_tracking | idx_competitor_tracking_workspace_id | workspace_id | B-tree | Workspace competitors |
| competitor_tracking | idx_competitor_tracking_platform | platform | B-tree | Platform filtering |
| competitor_tracking | idx_competitor_tracking_enabled | tracking_enabled | B-tree (partial) | WHERE enabled = TRUE |

### Notification Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| notifications | idx_notifications_user_id | user_id | B-tree | User notifications |
| notifications | idx_notifications_user_read | user_id, read_at | Composite (partial) | WHERE read_at IS NULL |
| notifications | idx_notifications_organization_id | organization_id | B-tree | Org notifications |
| notifications | idx_notifications_type | type | B-tree | Type filtering |
| notifications | idx_notifications_created_at | created_at DESC | B-tree | Recent notifications |
| notifications | idx_notifications_entity | entity_type, entity_id | Composite | Entity lookups |
| notification_preferences | idx_notification_preferences_user_id | user_id | B-tree | User preferences |
| notification_preferences | idx_notification_preferences_org_id | organization_id | B-tree | Org preferences |
| notification_templates | idx_notification_templates_type | type | B-tree | Type lookup |
| notification_templates | idx_notification_templates_channel | channel | B-tree | Channel filtering |
| email_queue | idx_email_queue_status | status | B-tree (partial) | WHERE status IN ('pending', 'sending') |
| email_queue | idx_email_queue_priority | priority DESC, created_at ASC | Composite (partial) | WHERE status = 'pending' |
| email_queue | idx_email_queue_created_at | created_at | B-tree | Queue ordering |
| email_queue | idx_email_queue_to_address | to_address | B-tree | Email lookup |
| push_queue | idx_push_queue_status | status | B-tree (partial) | WHERE status IN ('pending', 'sending') |
| push_queue | idx_push_queue_user_id | user_id | B-tree | User push |
| push_queue | idx_push_queue_priority | priority DESC, created_at ASC | Composite (partial) | WHERE status = 'pending' |
| push_queue | idx_push_queue_device_token | device_token | B-tree | Token lookup |

### Billing Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| subscriptions | idx_subscriptions_organization_id | organization_id | B-tree | Org subscriptions |
| subscriptions | idx_subscriptions_status | status | B-tree | Status filtering |
| subscriptions | idx_subscriptions_plan | plan | B-tree | Plan filtering |
| subscriptions | idx_subscriptions_current_period_end | current_period_end | B-tree | Renewal queries |
| subscriptions | idx_subscriptions_stripe | stripe_subscription_id | B-tree | Stripe lookup |
| invoices | idx_invoices_organization_id | organization_id | B-tree | Org invoices |
| invoices | idx_invoices_subscription_id | subscription_id | B-tree | Subscription invoices |
| invoices | idx_invoices_status | status | B-tree | Status filtering |
| invoices | idx_invoices_due_date | due_date | B-tree (partial) | WHERE status = 'open' |
| invoices | idx_invoices_created_at | created_at DESC | B-tree | Recent invoices |
| invoices | idx_invoices_stripe | stripe_invoice_id | B-tree | Stripe lookup |
| payments | idx_payments_organization_id | organization_id | B-tree | Org payments |
| payments | idx_payments_invoice_id | invoice_id | B-tree | Invoice payments |
| payments | idx_payments_status | status | B-tree | Status filtering |
| payments | idx_payments_created_at | created_at DESC | B-tree | Recent payments |
| payments | idx_payments_stripe | stripe_payment_id | B-tree | Stripe lookup |
| credit_purchases | idx_credit_purchases_organization_id | organization_id | B-tree | Org purchases |
| credit_purchases | idx_credit_purchases_status | status | B-tree | Status filtering |
| credit_purchases | idx_credit_purchases_expires_at | expires_at | B-tree (partial) | WHERE status = 'active' |
| usage_records | idx_usage_records_organization_id | organization_id | B-tree | Org usage |
| usage_records | idx_usage_records_subscription_id | subscription_id | B-tree | Subscription usage |
| usage_records | idx_usage_records_type | record_type | B-tree | Type filtering |
| usage_records | idx_usage_records_period | period_start, period_end | Composite | Period queries |
| usage_records | idx_usage_records_recorded_at | recorded_at DESC | B-tree | Recent records |

### Integration Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| integrations | idx_integrations_organization_id | organization_id | B-tree | Org integrations |
| integrations | idx_integrations_workspace_id | workspace_id | B-tree | Workspace integrations |
| integrations | idx_integrations_type | integration_type | B-tree | Type filtering |
| integrations | idx_integrations_status | status | B-tree | Status filtering |
| integration_logs | idx_integration_logs_integration_id | integration_id | B-tree | Integration logs |
| integration_logs | idx_integration_logs_organization_id | organization_id | B-tree | Org logs |
| integration_logs | idx_integration_logs_status | status | B-tree | Status filtering |
| integration_logs | idx_integration_logs_created_at | created_at DESC | B-tree | Recent logs |
| integration_logs | idx_integration_logs_operation | operation | B-tree | Operation filtering |
| webhooks | idx_webhooks_organization_id | organization_id | B-tree | Org webhooks |
| webhooks | idx_webhooks_workspace_id | workspace_id | B-tree | Workspace webhooks |
| webhooks | idx_webhooks_enabled | enabled | B-tree (partial) | WHERE enabled = TRUE |
| webhooks | idx_webhooks_events | events | GIN | Event search |
| webhook_deliveries | idx_webhook_deliveries_webhook_id | webhook_id | B-tree | Webhook deliveries |
| webhook_deliveries | idx_webhook_deliveries_organization_id | organization_id | B-tree | Org deliveries |
| webhook_deliveries | idx_webhook_deliveries_status | status | B-tree | Status filtering |
| webhook_deliveries | idx_webhook_deliveries_event_type | event_type | B-tree | Event filtering |
| webhook_deliveries | idx_webhook_deliveries_created_at | created_at DESC | B-tree | Recent deliveries |
| webhook_deliveries | idx_webhook_deliveries_next_retry | next_retry_at | B-tree (partial) | WHERE status = 'retrying' |

### Admin Tables

| Table | Index | Columns | Type | Notes |
|-------|-------|---------|------|-------|
| audit_logs | idx_audit_logs_organization_id | organization_id | B-tree | Org audit logs |
| audit_logs | idx_audit_logs_user_id | user_id | B-tree | User audit logs |
| audit_logs | idx_audit_logs_action | action | B-tree | Action filtering |
| audit_logs | idx_audit_logs_resource | resource_type, resource_id | Composite | Resource lookups |
| audit_logs | idx_audit_logs_created_at | created_at DESC | B-tree | Recent logs |
| audit_logs | idx_audit_logs_status | status | B-tree | Status filtering |
| audit_logs | idx_audit_logs_actor_email | actor_email | B-tree | Actor lookup |
| feature_flags | idx_feature_flags_key | key | B-tree | Flag lookup |
| feature_flags | idx_feature_flags_enabled | enabled | B-tree | Enabled filtering |
| feature_flag_overrides | idx_flag_overrides_flag_id | feature_flag_id | B-tree | Flag overrides |
| feature_flag_overrides | idx_flag_overrides_org_id | organization_id | B-tree | Org overrides |
| system_config | idx_system_config_key | key | B-tree | Config lookup |
| system_config | idx_system_config_category | category | B-tree | Category filtering |
| support_tickets | idx_support_tickets_organization_id | organization_id | B-tree | Org tickets |
| support_tickets | idx_support_tickets_user_id | user_id | B-tree | User tickets |
| support_tickets | idx_support_tickets_status | status | B-tree | Status filtering |
| support_tickets | idx_support_tickets_priority | priority | B-tree | Priority filtering |
| support_tickets | idx_support_tickets_assigned_to | assigned_to | B-tree | Assignment lookup |
| support_tickets | idx_support_tickets_created_at | created_at DESC | B-tree | Recent tickets |

## Maintenance

### Index Bloat Monitoring

```sql
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan AS times_used,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Unused Index Detection

```sql
SELECT
    indexrelname AS index_name,
    relname AS table_name,
    idx_scan AS times_used,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Recommended Schedule

- **Weekly**: Run unused index detection, consider dropping unused indexes
- **Monthly**: ANALYZE all tables, review index sizes
- **Quarterly**: Review query patterns, add missing indexes, remove redundant ones
