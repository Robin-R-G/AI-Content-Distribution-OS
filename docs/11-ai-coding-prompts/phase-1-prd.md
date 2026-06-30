# Phase 1: Product Requirements Document Prompts

## 1.1 Generate Complete PRD

**Phase:** 1-PRD
**Output:** `docs/02-prd/PRD.md`
**Inputs:** Vision, personas, business model

```
Generate a comprehensive Product Requirements Document (PRD) for Social Media AI.

# Social Media AI - Product Requirements Document

## Document Control
- Version: 1.0
- Status: Draft

## 1. Executive Summary
Write 3 paragraphs covering: what the product is, who it serves, key value propositions, market opportunity, and success metrics.

## 2. Goals and Objectives
| Goal | Objective | Success Metric | Timeline |

## 3. Scope
- In Scope: List 10-15 key features
- Out of Scope: List 5-10 excluded features

## 4. User Personas
Reference personas document. Summarize primary (2-3) and secondary (2-3) personas with key use cases.

## 5. Functional Requirements

### 5.1 Authentication & User Management
AUTH-001: User registration with email (P0)
AUTH-002: Social login - Google, Apple, GitHub (P0)
AUTH-003: Password reset flow (P0)
AUTH-004: Email verification (P0)
AUTH-005: Two-factor authentication (P1)
AUTH-006: Profile management (P0)
AUTH-007: Account deletion (P1)

### 5.2 Social Account Integration
INT-001: Connect Instagram Business (P0)
INT-002: Connect Facebook Pages (P0)
INT-003: Connect Twitter/X (P0)
INT-004: Connect LinkedIn (P0)
INT-005: Connect TikTok (P1)
INT-006: Connect YouTube (P1)
INT-007: Connect Pinterest (P2)
INT-008: Multi-account management (P0)
INT-009: Account health monitoring (P1)

### 5.3 AI Content Generation
AI-001: AI caption generation (P0)
AI-002: AI hashtag suggestions (P0)
AI-003: AI title generation (P0)
AI-004: AI content repurposing (P1)
AI-005: AI image generation (P1)
AI-006: AI video script generation (P2)
AI-007: AI content calendar suggestions (P1)
AI-008: AI competitor analysis (P2)
AI-009: AI trend identification (P2)
AI-010: AI audience insights (P1)

### 5.4 Content Scheduling & Publishing
SCH-001: Drag-and-drop calendar (P0)
SCH-002: Bulk scheduling (P0)
SCH-003: Optimal time suggestions (P1)
SCH-004: Recurring posts (P1)
SCH-005: Queue management (P0)
SCH-006: Cross-platform posting (P0)
SCH-007: Content approval workflow (P1)
SCH-008: Time zone support (P0)

### 5.5 Analytics & Reporting
ANA-001: Real-time analytics dashboard (P0)
ANA-002: Post performance tracking (P0)
ANA-003: Audience demographics (P1)
ANA-004: Engagement metrics (P0)
ANA-005: Growth tracking (P1)
ANA-006: Competitor benchmarking (P2)
ANA-007: Custom reports (P1)
ANA-008: PDF export (P1)
ANA-009: Automated reports (P2)

### 5.6 Team Collaboration
TEAM-001: Team workspaces (P0)
TEAM-002: Role-based access (P0)
TEAM-003: Content calendar sharing (P1)
TEAM-004: Comments and annotations (P1)
TEAM-005: Approval workflows (P1)
TEAM-006: Activity logs (P2)

### 5.7 Content Library
LIB-001: Media upload and storage (P0)
LIB-002: Content templates (P1)
LIB-003: Brand kit - logos, colors, fonts (P1)
LIB-004: Hashtag groups (P1)
LIB-005: Saved captions (P1)
LIB-006: Asset tagging (P2)

## 6. Non-Functional Requirements

### 6.1 Performance
NFR-P001: Page load time < 2 seconds
NFR-P002: API response time < 500ms (p95)
NFR-P003: AI generation time < 5 seconds
NFR-P004: Real-time updates < 1 second
NFR-P005: Concurrent users 10,000+

### 6.2 Scalability
NFR-S001: Database capacity 1M+ users
NFR-S002: Storage capacity 10TB+
NFR-S003: API throughput 10K req/s
NFR-S004: Horizontal auto-scaling

### 6.3 Security
NFR-SEC01: Data encryption AES-256
NFR-SEC02: Transport security TLS 1.3
NFR-SEC03: Authentication JWT + Refresh tokens
NFR-SEC04: Authorization RBAC
NFR-SEC05: Compliance SOC2, GDPR

### 6.4 Availability
NFR-A001: Uptime 99.9%
NFR-A002: RTO < 1 hour
NFR-A003: RPO < 5 minutes
NFR-A004: Disaster recovery plan

## 7. User Interface Requirements
- Mobile-first responsive design
- Dark/light theme support
- Accessibility WCAG 2.1 AA
- Internationalization support

## 8. Technical Constraints
- Flutter for mobile/web
- Supabase for backend
- PostgreSQL for database
- AI via OpenAI/Anthropic APIs

## 9. Dependencies
- Social platform APIs
- AI provider APIs
- Payment processor (Stripe)
- Email service (SendGrid)

## 10. Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| User signups | 10K month 1 | Analytics |
| Activation rate | 40% | Funnel |
| Daily active users | 1K month 3 | Analytics |
| Revenue | $10K MRR month 6 | Stripe |

## 11. Release Plan
- MVP (Month 1-3): Core features
- V1.0 (Month 4-6): Full launch
- V1.1 (Month 7-9): Enhancements
- V2.0 (Month 10-12): Enterprise features

## 12. Open Questions
List 5-10 unresolved questions needing stakeholder input.
```

**Expected Output:** 15-20 page PRD with complete requirements, priorities, and release plan.

---

## 1.2 Generate User Stories (200+)

**Phase:** 1-PRD
**Output:** `docs/02-prd/user-stories.md`
**Inputs:** PRD, personas

```
Generate 200+ user stories for the Social Media AI platform organized by epic.

Format each story as:
**Story ID:** [EPIC-NNN]
**Title:** [Brief title]
**As a** [persona]
**I want to** [action]
**So that** [benefit]
**Acceptance Criteria:**
- Criterion 1
- Criterion 2
- Criterion 3
**Priority:** P0/P1/P2
**Story Points:** [1/2/3/5/8]

## Epic 1: Authentication (20 stories)
Cover: registration, login, social auth, password reset, email verification, 2FA, profile management, account settings, account deletion, session management.

## Epic 2: Social Account Management (25 stories)
Cover: connecting accounts, disconnecting, account health, token refresh, multi-account, account switching, permission management, platform-specific settings.

## Epic 3: AI Content Generation (30 stories)
Cover: caption generation, hashtag suggestions, title generation, content repurposing, image generation, video scripts, calendar suggestions, trend analysis, competitor insights, audience analysis, tone customization, language translation.

## Epic 4: Content Scheduling (25 stories)
Cover: calendar view, drag-drop scheduling, bulk upload, queue management, optimal timing, recurring posts, cross-platform posting, time zones, approval workflows, content preview.

## Epic 5: Analytics (25 stories)
Cover: dashboard overview, post metrics, audience insights, growth tracking, engagement analysis, competitor tracking, custom reports, PDF export, scheduled reports, real-time updates.

## Epic 6: Team Collaboration (20 stories)
Cover: workspace creation, member invitation, role assignment, content sharing, comments, approvals, activity logs, permissions, team analytics.

## Epic 7: Content Library (20 stories)
Cover: media upload, folder organization, template creation, brand kit, hashtag groups, saved captions, asset search, tag management.

## Epic 8: Notifications (15 stories)
Cover: email notifications, push notifications, in-app alerts, notification preferences, digest emails, failure alerts, mention alerts.

## Epic 9: Settings & Preferences (15 stories)
Cover: profile settings, notification settings, billing, subscription management, API keys, integrations, data export, account deletion.

## Epic 10: Mobile (15 stories)
Cover: mobile login, dashboard view, quick post, notifications, offline support, biometric auth, deep links.

Include story mapping table and velocity estimates.
```

**Expected Output:** 200+ user stories across 10 epics with acceptance criteria and estimates.

---

## 1.3 Generate Use Case Diagrams

**Phase:** 1-PRD
**Output:** `docs/02-prd/use-cases.md`
**Inputs:** PRD, user stories

```
Generate comprehensive use case documentation for Social Media AI.

## Actors
Define all system actors:
- Unregistered User
- Registered User (Free)
- Paid Subscriber
- Team Admin
- Team Member
- Content Reviewer
- System Admin
- AI Service
- Social Platform APIs

## Use Case Diagrams (PlantUML format)

### Authentication Use Cases
@startuml
left to right direction
actor "User" as U
actor "Auth Service" as AS
rectangle "Authentication" {
  usecase "Register" as UC1
  usecase "Login" as UC2
  usecase "Social Login" as UC3
  usecase "Reset Password" as UC4
  usecase "Verify Email" as UC5
  usecase "Enable 2FA" as UC6
}
U --> UC1
U --> UC2
U --> UC3
U --> UC4
AS --> UC5
U --> UC6
@enduml

### Content Generation Use Cases
[Generate similar PlantUML for content generation]

### Scheduling Use Cases
[Generate similar PlantUML for scheduling]

### Analytics Use Cases
[Generate similar PlantUML for analytics]

### Team Management Use Cases
[Generate similar PlantUML for teams]

## Use Case Specifications

For each major use case, provide:
1. Use Case Name
2. Actor(s)
3. Pre-conditions
4. Main Flow (step by step)
5. Alternative Flows
6. Exception Flows
7. Post-conditions
8. Business Rules

Cover these use cases in detail:
- UC001: User Registration
- UC002: Connect Social Account
- UC003: Generate AI Content
- UC004: Schedule Post
- UC005: View Analytics
- UC006: Create Team Workspace
- UC007: Approve Content
- UC008: Export Report
- UC009: Manage Subscription
- UC010: Generate Hashtag Suggestions

Include complete PlantUML code for all diagrams.
```

**Expected Output:** Use case diagrams in PlantUML and 10 detailed use case specifications.

---

## 1.4 Generate Functional Requirements

**Phase:** 1-PRD
**Output:** `docs/02-prd/functional-requirements.md`
**Inputs:** PRD, user stories

```
Generate detailed functional requirements specification for Social Media AI.

## Requirement Format
For each requirement:
- **ID:** Unique identifier
- **Title:** Brief name
- **Description:** What the system must do
- **Priority:** P0 (Must have), P1 (Should have), P2 (Nice to have)
- **Complexity:** Low/Medium/High
- **Dependencies:** Other requirements this depends on

## FR-001: User Registration
**Description:** System shall allow users to register with email/password or social auth.
**Priority:** P0
**Complexity:** Medium

Detailed sub-requirements:
- FR-001.1: Email validation
- FR-001.2: Password strength requirements
- FR-001.3: Terms acceptance
- FR-001.4: Welcome email
- FR-001.5: Profile initialization

[Continue for all requirements organized by module]

## Modules to Cover:
1. Authentication (15 requirements)
2. Social Integration (20 requirements)
3. AI Generation (25 requirements)
4. Scheduling (20 requirements)
5. Analytics (20 requirements)
6. Team Management (15 requirements)
7. Content Library (15 requirements)
8. Notifications (10 requirements)
9. Billing (10 requirements)
10. Admin (10 requirements)

Total: 160+ detailed functional requirements
```

**Expected Output:** 160+ functional requirements with IDs, descriptions, priorities, and dependencies.

---

## 1.5 Generate Non-Functional Requirements

**Phase:** 1-PRD
**Output:** `docs/02-prd/non-functional-requirements.md`
**Inputs:** PRD

```
Generate comprehensive non-functional requirements for Social Media AI.

## Performance Requirements

### NFR-PERF-001: Response Time
- API responses: < 200ms (p50), < 500ms (p95), < 1s (p99)
- Page loads: < 2s (FCP), < 3.5s (LCP)
- AI generation: < 5s (caption), < 10s (image)
- Real-time updates: < 100ms latency

### NFR-PERF-002: Throughput
- Concurrent users: 10,000+
- Requests per second: 10,000+
- Database queries: 5,000+/s
- File uploads: 1,000 concurrent

### NFR-PERF-003: Resource Usage
- Memory: < 512MB per instance
- CPU: < 80% average utilization
- Storage IOPS: 10,000+
- Network: 1Gbps bandwidth

## Scalability Requirements

### NFR-SCALE-001: Horizontal Scaling
- Auto-scale 2-20 instances
- Scale-up time: < 2 minutes
- Scale-down time: < 5 minutes
- No single point of failure

### NFR-SCALE-002: Data Scalability
- Users: 1M+ concurrent
- Posts: 100M+ records
- Media: 10TB+ storage
- Analytics: 1B+ events

## Security Requirements

### NFR-SEC-001: Authentication
- JWT token expiry: 15 minutes
- Refresh token expiry: 7 days
- Password hashing: bcrypt (12 rounds)
- Session management: Secure, HttpOnly cookies

### NFR-SEC-002: Authorization
- Role-based access control
- Row-level security in database
- API endpoint protection
- Resource-level permissions

### NFR-SEC-003: Data Protection
- Encryption at rest: AES-256
- Encryption in transit: TLS 1.3
- PII data masking
- Secure key management

### NFR-SEC-004: Compliance
- GDPR compliance
- CCPA compliance
- SOC 2 Type II
- OWASP Top 10 mitigation

## Availability Requirements

### NFR-AVAIL-001: Uptime
- SLA: 99.9% uptime
- Planned maintenance: < 4 hours/month
- Recovery Time Objective (RTO): < 1 hour
- Recovery Point Objective (RPO): < 5 minutes

### NFR-AVAIL-002: Redundancy
- Multi-AZ deployment
- Database replication
- Backup every 6 hours
- Disaster recovery tested quarterly

## Usability Requirements

### NFR-USE-001: Accessibility
- WCAG 2.1 AA compliance
- Screen reader support
- Keyboard navigation
- Color contrast ratios

### NFR-USE-002: Internationalization
- Support 10+ languages
- RTL language support
- Locale-specific formatting
- Time zone handling

## Compatibility Requirements

### NFR-COMPAT-001: Mobile
- iOS 14+
- Android 10+
- Responsive design
- Offline capability

### NFR-COMPAT-002: Web
- Chrome, Firefox, Safari, Edge (latest 2 versions)
- 1280px+ viewport optimized
- Progressive Web App support

## Monitoring Requirements

### NFR-MON-001: Observability
- Application performance monitoring
- Error tracking and alerting
- Log aggregation
- Distributed tracing

Format with clear sections, measurable criteria, and testing methods.
```

**Expected Output:** 10-15 page NFR document with measurable criteria and compliance requirements.

---

## 1.6 Generate Permission Model

**Phase:** 1-PRD
**Output:** `docs/02-prd/permission-model.md`
**Inputs:** PRD, team features

```
Generate comprehensive permission model for Social Media AI.

## Roles Definition

### Role Hierarchy
```
Owner > Admin > Editor > Viewer > Free User
```

### Role Descriptions

| Role | Description | Max Members |
|------|-------------|-------------|
| Owner | Full control, billing, delete workspace | 1 |
| Admin | Manage members, settings, all features | 5 |
| Editor | Create, edit, schedule, publish content | 20 |
| Viewer | Read-only access to all content | Unlimited |
| Free User | Limited personal workspace | 1 |

## Permission Matrix

### Workspace Permissions
| Permission | Owner | Admin | Editor | Viewer |
|------------|-------|-------|--------|--------|
| Delete workspace | Yes | No | No | No |
| Change billing | Yes | No | No | No |
| Manage members | Yes | Yes | No | No |
| Change settings | Yes | Yes | No | No |
| View analytics | Yes | Yes | Yes | Yes |
| Export data | Yes | Yes | Yes | No |

### Content Permissions
| Permission | Owner | Admin | Editor | Viewer |
|------------|-------|-------|--------|--------|
| Create post | Yes | Yes | Yes | No |
| Edit own posts | Yes | Yes | Yes | No |
| Edit any posts | Yes | Yes | No | No |
| Delete own posts | Yes | Yes | Yes | No |
| Delete any posts | Yes | Yes | No | No |
| Publish posts | Yes | Yes | Yes | No |
| Schedule posts | Yes | Yes | Yes | No |
| Approve posts | Yes | Yes | No | No |

### Social Account Permissions
| Permission | Owner | Admin | Editor | Viewer |
|------------|-------|-------|--------|--------|
| Connect account | Yes | Yes | No | No |
| Disconnect account | Yes | Yes | No | No |
| Post to account | Yes | Yes | Yes | No |
| View account stats | Yes | Yes | Yes | Yes |
| Manage account settings | Yes | Yes | No | No |

### AI Feature Permissions
| Permission | Owner | Admin | Editor | Viewer |
|------------|-------|-------|--------|--------|
| Generate content | Yes | Yes | Yes | No |
| Use custom prompts | Yes | Yes | No | No |
| View AI history | Yes | Yes | Yes | No |
| Manage AI settings | Yes | Yes | No | No |

### Team Permissions
| Permission | Owner | Admin | Editor | Viewer |
|------------|-------|-------|--------|--------|
| Invite members | Yes | Yes | No | No |
| Remove members | Yes | Yes | No | No |
| Change member roles | Yes | Yes | No | No |
| View team activity | Yes | Yes | Yes | Yes |

## Resource-Level Permissions

### Post Ownership Rules
- Creator can edit/delete own posts
- Admin can edit/delete any post
- Viewer cannot create/edit/delete

### Workspace Isolation
- Users only see their workspace data
- Cross-workspace access requires explicit sharing
- API keys are workspace-scoped

## API Permission Scopes

### OAuth Scopes
```
read:profile        - Read user profile
write:profile       - Update user profile
read:posts          - View posts
write:posts         - Create/edit posts
delete:posts        - Delete posts
read:analytics      - View analytics
read:social         - View connected accounts
write:social        - Connect/manage accounts
read:team           - View team members
write:team          - Manage team members
admin:workspace     - Full workspace admin
admin:billing       - Billing management
```

## Row-Level Security Policies

### Database RLS Rules
```sql
-- Users can only read their own workspace data
CREATE POLICY workspace_isolation ON posts
  USING (workspace_id = auth.workspace_id());

-- Editors can update posts in their workspace
CREATE POLICY editor_update ON posts
  FOR UPDATE USING (
    workspace_id = auth.workspace_id()
    AND auth.has_role('editor')
  );

-- Only admins can delete any post
CREATE POLICY admin_delete ON posts
  FOR DELETE USING (
    workspace_id = auth.workspace_id()
    AND auth.has_role('admin')
  );
```

## Permission Inheritance
- Owner inherits all permissions
- Admin inherits Editor permissions
- Editor has explicit permissions only
- Viewer has read-only access

## Custom Roles (Enterprise)
- Define custom roles
- Assign granular permissions
- Role templates
- Audit role changes

Include complete permission matrix, RLS policies, and implementation guidelines.
```

**Expected Output:** 8-10 page permission model with roles, matrix, RLS policies, and API scopes.
