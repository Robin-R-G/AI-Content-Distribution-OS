# Microservices Architecture

## Service Boundaries

### 1. Auth Service

**Responsibility**: User authentication, authorization, session management

| Component | Purpose |
|-----------|---------|
| Registration | Email/password signup, email verification |
| Login | Credential validation, JWT issuance |
| OAuth | Google, GitHub, custom provider integration |
| MFA | TOTP-based multi-factor authentication |
| Sessions | Session lifecycle, concurrent session limits |
| Password | Hashing (bcrypt), reset flow, policies |

**Data Owned**:
- `users` - Core user profile
- `sessions` - Active sessions
- `mfa_settings` - MFA configuration
- `oauth_connections` - Linked OAuth providers

**API Endpoints**:
```
POST   /auth/register
POST   /auth/login
POST   /auth/logout
POST   /auth/refresh
POST   /auth/forgot-password
POST   /auth/reset-password
POST   /auth/mfa/enable
POST   /auth/mfa/verify
GET    /auth/sessions
DELETE /auth/sessions/:id
```

**Events Published**:
- `user.registered`
- `user.login`
- `user.logout`
- `user.password_reset`

---

### 2. Organization Service

**Responsibility**: Multi-tenant organization management, billing association

| Component | Purpose |
|-----------|---------|
| CRUD | Organization creation, update, deletion |
| Members | Invitation, removal, role assignment |
| Settings | Org-level configuration |
| Billing | Plan association, usage tracking |

**Data Owned**:
- `organizations` - Organization records
- `organization_members` - Membership with roles
- `organization_invites` - Pending invitations
- `organization_settings` - Configuration

**API Endpoints**:
```
POST   /organizations
GET    /organizations/:id
PUT    /organizations/:id
DELETE /organizations/:id
POST   /organizations/:id/invite
GET    /organizations/:id/members
PUT    /organizations/:id/members/:userId/role
DELETE /organizations/:id/members/:userId
```

**Events Published**:
- `organization.created`
- `organization.member_added`
- `organization.member_removed`
- `organization.plan_changed`

---

### 3. Workspace Service

**Responsibility**: Content workspaces, team collaboration, channel management

| Component | Purpose |
|-----------|---------|
| CRUD | Workspace lifecycle |
| Channels | Social media account connections |
| Settings | Workspace-specific configuration |
| Access | Workspace-level permissions |

**Data Owned**:
- `workspaces` - Workspace records
- `workspace_channels` - Connected social accounts
- `workspace_settings` - Configuration
- `workspace_members` - Workspace-level access

**API Endpoints**:
```
POST   /workspaces
GET    /workspaces/:id
PUT    /workspaces/:id
DELETE /workspaces/:id
POST   /workspaces/:id/channels
GET    /workspaces/:id/channels
DELETE /workspaces/:id/channels/:channelId
```

**Events Published**:
- `workspace.created`
- `workspace.channel_added`
- `workspace.channel_removed`

---

### 4. Content Service

**Responsibility**: Content creation, storage, versioning, media management

| Component | Purpose |
|-----------|---------|
| CRUD | Content lifecycle management |
| Types | Posts, threads, stories, articles |
| Templates | Reusable content templates |
| Media | Upload, processing, storage |
| Versions | Content version history |
| AI Content | AI-generated content storage |

**Data Owned**:
- `contents` - Content records
- `content_versions` - Version history
- `content_templates` - Reusable templates
- `media` - Media file metadata
- `media_variants` - Processed media versions

**API Endpoints**:
```
POST   /contents
GET    /contents
GET    /contents/:id
PUT    /contents/:id
DELETE /contents/:id
POST   /contents/:id/versions
GET    /contents/:id/versions
POST   /media/upload
DELETE /media/:id
POST   /templates
GET    /templates
```

**Events Published**:
- `content.created`
- `content.updated`
- `content.deleted`
- `media.uploaded`

---

### 5. Publishing Service

**Responsibility**: Content scheduling, platform publishing, status tracking

| Component | Purpose |
|-----------|---------|
| Schedule | Post scheduling with timezone support |
| Publish | Platform API integration |
| Status | Publishing status tracking |
| OAuth | Platform token management |
| Webhooks | Platform callback handling |

**Data Owned**:
- `scheduled_posts` - Scheduled publications
- `publish_history` - Publishing audit log
- `platform_tokens` - Encrypted OAuth tokens
- `publish_status` - Real-time status

**API Endpoints**:
```
POST   /publish/schedule
GET    /publish/schedule
PUT    /publish/schedule/:id
DELETE /publish/schedule/:id
POST   /publish/now
GET    /publish/history
POST   /publish/webhook/:platform
```

**Events Published**:
- `publish.scheduled`
- `publish.started`
- `publish.completed`
- `publish.failed`
- `publish.retry`

---

### 6. AI Service

**Responsibility**: AI content generation, prompt management, provider routing

| Component | Purpose |
|-----------|---------|
| Generate | Content generation requests |
| Prompts | Template management and rendering |
| Providers | Multi-provider orchestration |
| Fallback | Automatic provider failover |
| Cache | Response caching |
| Budget | Cost tracking and limits |

**Data Owned**:
- `ai_prompts` - Prompt templates
- `ai_generations` - Generation history
- `ai_usage` - Token usage and costs
- `ai_budgets` - Budget limits

**API Endpoints**:
```
POST   /ai/generate
GET    /ai/prompts
POST   /ai/prompts
PUT    /ai/prompts/:id
GET    /ai/usage
GET    /ai/budgets
PUT    /ai/budgets/:id
```

**Events Published**:
- `ai.generation.requested`
- `ai.generation.completed`
- `ai.generation.failed`
- `ai.budget.exceeded`

---

### 7. Analytics Service

**Responsibility**: Metrics collection, aggregation, reporting

| Component | Purpose |
|-----------|---------|
| Collect | Platform API polling, webhook ingestion |
| Aggregate | Time-series rollups |
| Report | Export generation |
| Dashboard | Real-time metrics |

**Data Owned**:
- `analytics_raw` - Raw metrics data
- `analytics_hourly` - Hourly aggregations
- `analytics_daily` - Daily aggregations
- `analytics_weekly` - Weekly aggregations
- `reports` - Generated reports

**API Endpoints**:
```
GET    /analytics/dashboard
GET    /analytics/posts
GET    /analytics/platforms
GET    /analytics/export
POST   /analytics/reports
GET    /analytics/reports/:id
```

**Events Published**:
- `analytics.collected`
- `analytics.report_ready`

---

### 8. Notification Service

**Responsibility**: Multi-channel notification delivery

| Component | Purpose |
|-----------|---------|
| In-App | Real-time in-app notifications |
| Email | Transactional email delivery |
| Push | Mobile push notifications |
| Digest | Digest email compilation |
| Preferences | User notification settings |

**Data Owned**:
- `notifications` - Notification records
- `notification_preferences` - User settings
- `notification_templates` - Message templates
- `email_log` - Email delivery log

**API Endpoints**:
```
GET    /notifications
PUT    /notifications/:id/read
POST   /notifications/read-all
GET    /notifications/preferences
PUT    /notifications/preferences
POST   /notifications/test
```

**Events Published**:
- `notification.created`
- `notification.delivered`
- `notification.failed`

---

### 9. Billing Service

**Responsibility**: Subscription management, invoicing, payment processing

| Component | Purpose |
|-----------|---------|
| Plans | Subscription plan management |
| Subscriptions | User subscription lifecycle |
| Invoices | Invoice generation and delivery |
| Payments | Payment gateway integration |
| Usage | Usage-based billing metering |

**Data Owned**:
- `plans` - Available plans
- `subscriptions` - Active subscriptions
- `invoices` - Invoice records
- `payments` - Payment transactions
- `usage_records` - Usage metering

**API Endpoints**:
```
GET    /billing/plans
POST   /billing/subscriptions
GET    /billing/subscriptions/:id
PUT    /billing/subscriptions/:id
DELETE /billing/subscriptions/:id
GET    /billing/invoices
POST   /billing/invoices/:id/pay
GET    /billing/usage
```

**Events Published**:
- `billing.subscription.created`
- `billing.subscription.updated`
- `billing.subscription.cancelled`
- `billing.invoice.created`
- `billing.payment.success`
- `billing.payment.failed`

---

### 10. Plugin Service

**Responsibility**: Plugin lifecycle, connector management, sandboxed execution

| Component | Purpose |
|-----------|---------|
| Registry | Plugin installation and versioning |
| Runtime | Sandboxed plugin execution |
| Connectors | Social, AI, storage connector management |
| Config | Plugin configuration management |

**Data Owned**:
- `plugins` - Plugin definitions
- `plugin_configs` - Plugin configurations
- `plugin_executions` - Execution history
- `connector_accounts` - Connected accounts

**API Endpoints**:
```
GET    /plugins
POST   /plugins/install
DELETE /plugins/:id/uninstall
GET    /plugins/:id/config
PUT    /plugins/:id/config
POST   /plugins/:id/test
GET    /connectors
POST   /connectors/:type/auth
DELETE /connectors/:id
```

**Events Published**:
- `plugin.installed`
- `plugin.uninstalled`
- `plugin.execution.completed`
- `connector.connected`
- `connector.disconnected`

---

### 11. Admin Service

**Responsibility**: Platform administration, user management, system health

| Component | Purpose |
|-----------|---------|
| Users | Platform user administration |
| Orgs | Organization management |
| System | Health checks, metrics |
| Config | Platform configuration |
| Audit | Admin action logging |

**Data Owned**:
- `admin_users` - Admin user records
- `admin_actions` - Admin action audit log
- `system_config` - Platform configuration
- `system_health` - Health check results

**API Endpoints**:
```
GET    /admin/users
GET    /admin/users/:id
PUT    /admin/users/:id
GET    /admin/organizations
GET    /admin/organizations/:id
PUT    /admin/organizations/:id
GET    /admin/health
GET    /admin/metrics
GET    /admin/audit-log
```

**Events Published**:
- `admin.action_performed`
- `system.health_check`

---

## Inter-Service Communication

### Synchronous (HTTP)

```
Client → API Gateway → Service A → Service B → Response
```

Used for:
- Real-time operations requiring immediate response
- CRUD operations with direct dependencies

### Asynchronous (BullMQ)

```
Service A → Queue → Service B (Worker)
```

Used for:
- Publishing operations
- Analytics aggregation
- Email/notification delivery
- AI content generation
- Media processing

### Real-time (Supabase Realtime)

```
Service → PostgreSQL → Supabase Realtime → Client WebSocket
```

Used for:
- Live dashboard updates
- Notification delivery
- Collaborative editing
- Status updates

---

## Service Discovery

Services are registered in a service registry:

```typescript
interface ServiceRegistry {
  services: {
    auth: { url: string; health: string };
    organization: { url: string; health: string };
    workspace: { url: string; health: string };
    content: { url: string; health: string };
    publishing: { url: string; health: string };
    ai: { url: string; health: string };
    analytics: { url: string; health: string };
    notification: { url: string; health: string };
    billing: { url: string; health: string };
    plugin: { url: string; health: string };
    admin: { url: string; health: string };
  };
}
```

---

## Circuit Breaker Pattern

```typescript
interface CircuitBreaker {
  state: 'closed' | 'open' | 'half-open';
  failureCount: number;
  successCount: number;
  lastFailureTime: number;
  threshold: number;
  timeout: number;
}
```

| State | Behavior |
|-------|----------|
| Closed | Normal operation, requests pass through |
| Open | All requests fail immediately |
| Half-Open | Limited requests to test recovery |
