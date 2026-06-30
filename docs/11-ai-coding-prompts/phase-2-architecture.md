# Phase 2: Architecture Prompts

## 2.1 Generate High-Level Architecture

**Phase:** 2-Architecture
**Output:** `docs/03-architecture/high-level.md`
**Inputs:** PRD, NFRs

```
Generate high-level architecture for Social Media AI.

## Architecture Overview
Write a 1-page executive summary of the architecture approach, key decisions, and trade-offs.

## System Context Diagram (C4 Level 1)
Describe the system context:
- Social Media AI Platform (our system)
- Users (mobile, web)
- Social Platforms (Instagram, Twitter, LinkedIn, TikTok, YouTube)
- AI Providers (OpenAI, Anthropic)
- Payment (Stripe)
- Email (SendGrid)
- Storage (Supabase Storage)

## Container Diagram (C4 Level 2)
```
┌─────────────────────────────────────────────────────────────┐
│                    Client Applications                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ Flutter  │  │   Web    │  │  Admin   │                  │
│  │  Mobile  │  │   App    │  │  Portal  │                  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                  │
│       │              │              │                        │
└───────┼──────────────┼──────────────┼────────────────────────┘
        │              │              │
        ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (Supabase Edge Functions)     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │   Rate   │  │   Route  │  │   Log    │   │
│  │ Service  │  │  Limiter │  │  Handler │  │  Manager │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼──────────────┼──────────────┼──────────────┼─────────┘
        │              │              │              │
        ▼              ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Services                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   User   │  │   Post   │  │    AI    │  │Analytics │   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │              │              │              │         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Social  │  │ Schedule │  │   Team   │  │  Media   │   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼──────────────┼──────────────┼──────────────┼─────────┘
        │              │              │              │
        ▼              ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │PostgreSQL│  │   Redis  │  │ Supabase │  │   S3     │   │
│  │ Database │  │  Cache   │  │ Realtime │  │ Storage  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend
- Flutter 3.x (Mobile, Web, Desktop)
- Dart 3.x
- Riverpod (State Management)
- GoRouter (Navigation)
- Dio (HTTP Client)

### Backend
- Supabase (Backend-as-a-Service)
- Edge Functions (Deno/TypeScript)
- PostgreSQL 15
- Redis (Caching)
- Supabase Storage (Media)

### AI/ML
- OpenAI API (GPT-4, DALL-E)
- Anthropic API (Claude)
- Custom prompt templates
- Prompt caching

### Infrastructure
- Supabase Cloud
- Cloudflare (CDN, DNS)
- GitHub Actions (CI/CD)
- Sentry (Error Tracking)

## Key Architectural Decisions

### ADR-001: Backend Framework
**Decision:** Supabase with Edge Functions
**Rationale:** Faster development, built-in auth, real-time, RLS
**Alternatives:** Custom Node.js, Django, Rails

### ADR-002: State Management
**Decision:** Riverpod
**Rationale:** Compile-time safety, testability, provider pattern
**Alternatives:** Bloc, Provider, GetX

### ADR-003: Database
**Decision:** PostgreSQL via Supabase
**Rationale:** SQL power, RLS, full-text search, JSON support
**Alternatives:** MongoDB, Firebase Firestore

[Continue for 5-7 ADRs]

## Service Responsibilities

### User Service
- Registration, login, profile management
- Subscription management
- Preference storage

### Post Service
- CRUD operations for posts
- Content validation
- Version history

### AI Service
- Prompt management
- Content generation
- Response caching
- Rate limiting

### Analytics Service
- Event collection
- Metric aggregation
- Report generation
- Data export

### Social Service
- Platform connection management
- Token refresh
- Content publishing
- Webhook handling

### Scheduler Service
- Cron job management
- Queue processing
- Retry logic
- Time zone handling

## Data Flow Diagrams

### Content Creation Flow
```
User → Flutter App → API Gateway → Post Service → AI Service → AI Provider
                                                    ↓
                                              Post Service → Database
                                                    ↓
                                              Scheduler → Social Platform
```

### Analytics Collection Flow
```
Social Platform → Webhook → API Gateway → Analytics Service → Database
                                                      ↓
                                              Aggregation Jobs → Cache
                                                      ↓
                                              Dashboard ← API ← Cache
```

Include complete C4 diagrams (PlantUML/Mermaid), data flow diagrams, and deployment considerations.
```

**Expected Output:** 10-15 page architecture document with diagrams, decisions, and service descriptions.

---

## 2.2 Generate TRD

**Phase:** 2-Architecture
**Output:** `docs/03-architecture/TRD.md`
**Inputs:** Architecture, PRD

```
Generate Technical Requirements Document (TRD) for Social Media AI.

## TRD Overview
- Version: 1.0
- Status: Draft
- Authors: [AI Generated]

## 1. System Requirements

### 1.1 Hardware Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 vCPU | 4 vCPU |
| Memory | 4GB | 8GB |
| Storage | 50GB SSD | 100GB SSD |
| Network | 1Gbps | 10Gbps |

### 1.2 Software Requirements
| Component | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.19+ | Mobile/Web |
| Dart | 3.3+ | Language |
| PostgreSQL | 15+ | Database |
| Redis | 7+ | Cache |
| Node.js | 20+ | Edge Functions |
| Deno | 1.40+ | Runtime |

### 1.3 Infrastructure Requirements
| Service | Provider | Spec |
|---------|----------|------|
| Database | Supabase | Pro plan |
| Storage | Supabase | 100GB |
| CDN | Cloudflare | Free tier |
| CI/CD | GitHub Actions | 2000 min/month |
| Monitoring | Sentry | Team plan |

## 2. API Design Standards

### 2.1 RESTful Conventions
- Base URL: `https://api.socialmediaai.com/v1`
- Authentication: Bearer token (JWT)
- Content-Type: application/json
- Rate limiting: 100 req/min (free), 1000 req/min (paid)

### 2.2 Response Format
```json
{
  "success": true,
  "data": {},
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
```

### 2.3 Error Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": []
  }
}
```

### 2.4 Endpoint Naming
- Resources: nouns (posts, users, analytics)
- Actions: verbs (generate, schedule, publish)
- Plural for collections
- Nested for relationships

## 3. Database Design Standards

### 3.1 Naming Conventions
- Tables: snake_case, plural (users, posts)
- Columns: snake_case (created_at)
- Indexes: idx_tablename_column
- Foreign keys: fk_tablename_referenced

### 3.2 Common Columns
```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
created_at TIMESTAMPTZ DEFAULT NOW()
updated_at TIMESTAMPTZ DEFAULT NOW()
deleted_at TIMESTAMPTZ -- soft delete
```

### 3.3 Indexing Strategy
- Primary keys: UUID
- Foreign keys: Always indexed
- Search columns: GIN indexes
- Timestamp columns: For range queries
- Composite indexes for common queries

## 4. Security Standards

### 4.1 Authentication
- JWT with 15-minute expiry
- Refresh tokens with 7-day expiry
- Secure cookie storage
- CSRF protection

### 4.2 Authorization
- RBAC with 4 roles
- Row-level security
- API scope validation
- Resource ownership checks

### 4.3 Data Protection
- Encryption at rest (AES-256)
- Encryption in transit (TLS 1.3)
- PII masking in logs
- Secure key rotation

## 5. Performance Standards

### 5.1 Response Time Targets
| Operation | Target | Measurement |
|-----------|--------|-------------|
| API call | < 200ms | p50 |
| API call | < 500ms | p95 |
| Page load | < 2s | FCP |
| AI generation | < 5s | caption |
| Real-time | < 100ms | latency |

### 5.2 Throughput Targets
| Metric | Target |
|--------|--------|
| Concurrent users | 10,000 |
| Requests/second | 10,000 |
| Database queries/s | 5,000 |
| File uploads/s | 1,000 |

### 5.3 Scalability Approach
- Horizontal auto-scaling
- Database read replicas
- Redis caching layer
- CDN for static assets
- Queue for async jobs

## 6. Testing Standards

### 6.1 Test Pyramid
```
         E2E Tests (10%)
        /           \
Integration (30%)     \
      /               \
Unit Tests (60%)
```

### 6.2 Coverage Targets
| Type | Target |
|------|--------|
| Unit | 80% |
| Integration | 70% |
| E2E | 60% |
| Overall | 75% |

### 6.3 Test Automation
- Unit tests: On every commit
- Integration tests: On PR
- E2E tests: Nightly
- Performance tests: Weekly

## 7. Monitoring Standards

### 7.1 Metrics to Track
- Request latency (p50, p95, p99)
- Error rate
- CPU/Memory usage
- Database connections
- Queue depth
- Cache hit rate

### 7.2 Alerting Rules
| Metric | Threshold | Severity |
|--------|-----------|----------|
| Error rate | > 1% | Critical |
| Latency p95 | > 1s | Warning |
| CPU | > 80% | Warning |
| Memory | > 85% | Critical |
| DB connections | > 80% | Critical |

## 8. Deployment Standards

### 8.1 Environment Strategy
- Development: Local + Preview
- Staging: Production-like
- Production: Multi-AZ

### 8.2 Deployment Process
1. Feature branch
2. PR with tests passing
3. Merge to main
4. Auto-deploy to staging
5. Manual promotion to production
6. Canary rollout (10% → 50% → 100%)

### 8.3 Rollback Strategy
- Database migrations: Reversible
- Feature flags: Instant disable
- Blue-green deployment
- Maximum rollback time: 5 minutes

Include complete standards, conventions, and implementation guidelines.
```

**Expected Output:** 12-15 page TRD with standards, conventions, and technical specifications.

---

## 2.3 Generate Database Schema

**Phase:** 2-Architecture
**Output:** `docs/03-architecture/database-schema.md`
**Inputs:** TRD, functional requirements

```
Generate comprehensive PostgreSQL database schema for Social Media AI.

## Schema Overview
- Database: PostgreSQL 15
- Extensions: uuid-ossp, pgcrypto, pg_trgm, uuid GENERATE_V4

## Core Tables

### users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  timezone VARCHAR(50) DEFAULT 'UTC',
  language VARCHAR(10) DEFAULT 'en',
  onboarding_completed BOOLEAN DEFAULT FALSE,
  subscription_tier VARCHAR(20) DEFAULT 'free',
  stripe_customer_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);
```

### workspaces
```sql
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  owner_id UUID REFERENCES users(id),
  plan VARCHAR(20) DEFAULT 'free',
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### workspace_members
```sql
CREATE TABLE workspace_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL DEFAULT 'viewer',
  invited_by UUID REFERENCES users(id),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, user_id)
);
```

### social_accounts
```sql
CREATE TABLE social_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  platform VARCHAR(50) NOT NULL,
  platform_user_id VARCHAR(255) NOT NULL,
  username VARCHAR(255) NOT NULL,
  display_name VARCHAR(255),
  avatar_url TEXT,
  access_token TEXT,
  refresh_token TEXT,
  token_expires_at TIMESTAMPTZ,
  scopes TEXT[],
  settings JSONB DEFAULT '{}',
  connected_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced_at TIMESTAMPTZ,
  UNIQUE(workspace_id, platform, platform_user_id)
);
```

### posts
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'draft',
  content JSONB NOT NULL,
  media_ids UUID[],
  scheduled_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  ai_generated BOOLEAN DEFAULT FALSE,
  ai_prompt TEXT,
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);
```

### post_publications
```sql
CREATE TABLE post_publications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  social_account_id UUID REFERENCES social_accounts(id),
  platform_post_id VARCHAR(255),
  status VARCHAR(20) DEFAULT 'pending',
  published_at TIMESTAMPTZ,
  platform_data JSONB DEFAULT '{}',
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### media
```sql
CREATE TABLE media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  uploaded_by UUID REFERENCES users(id),
  file_name VARCHAR(255) NOT NULL,
  file_type VARCHAR(50) NOT NULL,
  file_size INTEGER,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### ai_generations
```sql
CREATE TABLE ai_generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  type VARCHAR(50) NOT NULL,
  prompt TEXT NOT NULL,
  response TEXT,
  model VARCHAR(100),
  tokens_used INTEGER,
  duration_ms INTEGER,
  rating INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### analytics_events
```sql
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id),
  post_id UUID REFERENCES posts(id),
  social_account_id UUID REFERENCES social_accounts(id),
  event_type VARCHAR(50) NOT NULL,
  platform VARCHAR(50) NOT NULL,
  value NUMERIC,
  metadata JSONB DEFAULT '{}',
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);
```

### hashtags
```sql
CREATE TABLE hashtags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  group_name VARCHAR(100),
  usage_count INTEGER DEFAULT 0,
  performance_score NUMERIC,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, name)
);
```

### schedules
```sql
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id),
  social_account_id UUID REFERENCES social_accounts(id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### notifications
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  data JSONB DEFAULT '{}',
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### audit_logs
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID REFERENCES workspaces(id),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(50),
  resource_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Indexes
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_stripe ON users(stripe_customer_id);
CREATE INDEX idx_workspaces_owner ON workspaces(owner_id);
CREATE INDEX idx_workspace_members_user ON workspace_members(user_id);
CREATE INDEX idx_social_accounts_workspace ON social_accounts(workspace_id);
CREATE INDEX idx_posts_workspace ON posts(workspace_id, status);
CREATE INDEX idx_posts_scheduled ON posts(scheduled_at) WHERE status = 'scheduled';
CREATE INDEX idx_analytics_events_post ON analytics_events(post_id, recorded_at);
CREATE INDEX idx_analytics_events_workspace ON analytics_events(workspace_id, recorded_at);
CREATE INDEX idx_schedules_pending ON schedules(scheduled_at) WHERE status = 'pending';
CREATE INDEX idx_notifications_user ON notifications(user_id, read_at);
```

## Row-Level Security
```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON posts
  USING (workspace_id = auth.workspace_id());

-- Similar policies for all workspace-scoped tables
```

Include complete SQL, ER diagrams (Mermaid), and migration strategy.
```

**Expected Output:** 10-12 page schema document with complete SQL, indexes, RLS policies, and ER diagrams.

---

## 2.4 Generate API Specification

**Phase:** 2-Architecture
**Output:** `docs/03-architecture/api-spec.yaml`
**Inputs:** PRD, functional requirements

```
Generate OpenAPI 3.0 specification for Social Media AI API.

## API Specification

Generate complete OpenAPI YAML covering:

### Info
- Title: Social Media AI API
- Version: 1.0.0
- Description: RESTful API for social media management platform

### Authentication
- Bearer token (JWT)
- OAuth 2.0 for social logins

### Endpoints to Include:

#### Auth
- POST /auth/register
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh
- POST /auth/forgot-password
- POST /auth/reset-password
- POST /auth/verify-email

#### Users
- GET /users/me
- PATCH /users/me
- DELETE /users/me

#### Workspaces
- GET /workspaces
- POST /workspaces
- GET /workspaces/:id
- PATCH /workspaces/:id
- DELETE /workspaces/:id

#### Workspace Members
- GET /workspaces/:id/members
- POST /workspaces/:id/members
- PATCH /workspaces/:id/members/:userId
- DELETE /workspaces/:id/members/:userId

#### Social Accounts
- GET /workspaces/:id/social-accounts
- POST /workspaces/:id/social-accounts/connect
- DELETE /workspaces/:id/social-accounts/:id
- POST /workspaces/:id/social-accounts/:id/refresh

#### Posts
- GET /workspaces/:id/posts
- POST /workspaces/:id/posts
- GET /workspaces/:id/posts/:postId
- PATCH /workspaces/:id/posts/:postId
- DELETE /workspaces/:id/posts/:postId
- POST /workspaces/:id/posts/:postId/publish
- POST /workspaces/:id/posts/:postId/schedule

#### AI Generation
- POST /ai/generate/caption
- POST /ai/generate/hashtags
- POST /ai/generate/title
- POST /ai/generate/content
- GET /ai/history

#### Analytics
- GET /workspaces/:id/analytics/overview
- GET /workspaces/:id/analytics/posts
- GET /workspaces/:id/analytics/audience
- GET /workspaces/:id/analytics/growth
- POST /workspaces/:id/analytics/export

#### Media
- POST /workspaces/:id/media/upload
- GET /workspaces/:id/media
- DELETE /workspaces/:id/media/:id

#### Notifications
- GET /notifications
- PATCH /notifications/:id/read
- POST /notifications/read-all

### Schemas
Define all request/response schemas with proper types, required fields, and examples.

### Error Responses
Standardize error responses with codes and messages.

Generate complete YAML with all endpoints, schemas, and examples.
```

**Expected Output:** Complete OpenAPI 3.0 YAML specification with 50+ endpoints and schemas.

---

## 2.5 Generate Security Architecture

**Phase:** 2-Architecture
**Output:** `docs/03-architecture/security.md`
**Inputs:** NFRs, compliance requirements

```
Generate security architecture document for Social Media AI.

## Security Overview

### Security Principles
1. Defense in depth
2. Least privilege
3. Zero trust
4. Secure by default

## Authentication Architecture

### JWT Implementation
- Algorithm: RS256
- Access token: 15 minutes
- Refresh token: 7 days
- Token rotation on refresh
- Revocation list

### OAuth 2.0 Flows
- Authorization Code with PKCE for mobile
- Client Credentials for service-to-service
- Social login via platform SDKs

### Multi-Factor Authentication
- TOTP (Google Authenticator)
- SMS backup codes
- Recovery codes (10 per account)

## Authorization Architecture

### RBAC Model
```
Owner > Admin > Editor > Viewer
```

### Permission Evaluation
```
1. Check user role
2. Check workspace membership
3. Check resource ownership
4. Check specific permission
5. Allow/Deny
```

### Row-Level Security
- Database-level enforcement
- Workspace isolation
- Resource ownership

## Data Security

### Encryption Strategy
| State | Method | Key Management |
|-------|--------|----------------|
| At rest | AES-256 | Supabase managed |
| In transit | TLS 1.3 | Cloudflare |
| Backups | AES-256 | Separate keys |
| PII | Field-level | App-level |

### Data Classification
| Level | Examples | Protection |
|-------|----------|------------|
| Public | Post content | Standard |
| Internal | Analytics | Access control |
| Confidential | User PII | Encryption |
| Restricted | Payment | PCI DSS |

## API Security

### Rate Limiting
| Tier | Limit | Window |
|------|-------|--------|
| Free | 100 req | 1 min |
| Starter | 500 req | 1 min |
| Pro | 1000 req | 1 min |
| Business | 5000 req | 1 min |

### Input Validation
- Request schema validation
- SQL injection prevention
- XSS prevention
- File upload validation

### Security Headers
```
Strict-Transport-Security: max-age=31536000
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

## Infrastructure Security

### Network Security
- VPC isolation
- Firewall rules
- DDoS protection (Cloudflare)
- WAF rules

### Secrets Management
- Environment variables
- Supabase Vault
- Key rotation schedule
- Audit logging

## Compliance

### GDPR Requirements
- Data subject rights
- Consent management
- Data portability
- Right to deletion
- Privacy policy
- DPA with processors

### SOC 2 Controls
- Access controls
- Change management
- Monitoring
- Incident response
- Risk assessment

## Incident Response

### Response Plan
1. Detection
2. Triage
3. Containment
4. Eradication
5. Recovery
6. Lessons learned

### Communication
- Internal escalation
- User notification
- Regulatory reporting

## Security Testing

### Testing Schedule
| Type | Frequency | Tool |
|------|------------|------|
| SAST | Every commit | Semgrep |
| DAST | Weekly | OWASP ZAP |
| Dependency | Daily | Snyk |
| Penetration | Quarterly | External |

Include complete security controls, compliance checklists, and implementation guidelines.
```

**Expected Output:** 12-15 page security architecture with controls, compliance, and incident response.

---

## 2.6 Generate Deployment Architecture

**Phase:** 2-Architecture
**Output:** `docs/03-architecture/deployment.md`
**Inputs:** Architecture, infrastructure requirements

```
Generate deployment architecture for Social Media AI.

## Deployment Overview

### Environments
| Environment | Purpose | Infrastructure |
|-------------|---------|----------------|
| Development | Local dev | Docker Compose |
| Preview | PR previews | Supabase Branching |
| Staging | Pre-production | Supabase Pro |
| Production | Live | Supabase Pro + CDN |

## Production Architecture

### Infrastructure Diagram
```
┌─────────────────────────────────────────────────────┐
│                    Cloudflare                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │   DNS    │  │   CDN    │  │   WAF    │         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
└───────┼──────────────┼──────────────┼───────────────┘
        │              │              │
        ▼              ▼              ▼
┌─────────────────────────────────────────────────────┐
│                    Supabase                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │   API    │  │ Database │  │  Auth    │         │
│  │ Gateway  │  │(Postgres)│  │ Service  │         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
│       │              │              │               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  Edge   │  │ Realtime │  │ Storage  │         │
│  │Functions│  │  Server  │  │  (S3)    │         │
│  └─────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────┘
```

### CDN Configuration
- Static assets: Cached 30 days
- API responses: Cached 5 minutes
- HTML: No cache
- Assets: Immutable with versioned filenames

### Database Configuration
- Read replicas: 2 (for analytics)
- Connection pooling: PgBouncer
- Backup schedule: Every 6 hours
- Retention: 30 days

## CI/CD Pipeline

### Pipeline Stages
```
Code Push → Lint → Test → Build → Deploy → Verify
```

### GitHub Actions Workflow
```yaml
name: CI/CD
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      
  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      
  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to Supabase
        run: supabase functions deploy
```

## Environment Variables

### Required Variables
```env
# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_JWT_SECRET=

# AI Providers
OPENAI_API_KEY=
ANTHROPIC_API_KEY=

# Social Platforms
INSTAGRAM_CLIENT_ID=
INSTAGRAM_CLIENT_SECRET=
TWITTER_API_KEY=
TWITTER_API_SECRET=
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
TIKTOK_CLIENT_KEY=
TIKTOK_CLIENT_SECRET=

# Email
SENDGRID_API_KEY=

# Payments
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
```

### Secrets Management
- Use Supabase Vault for sensitive values
- Environment-specific configuration
- No secrets in code or git

## Monitoring & Observability

### Application Monitoring
- Sentry for error tracking
- Supabase Dashboard for metrics
- Custom dashboards for business metrics

### Log Aggregation
- Structured JSON logging
- Centralized in Supabase Logs
- Retention: 30 days
- Alerting on error patterns

### Health Checks
```
GET /health
{
  "status": "healthy",
  "version": "1.0.0",
  "database": "connected",
  "redis": "connected",
  "uptime": 12345
}
```

## Backup & Recovery

### Backup Strategy
| Component | Frequency | Retention | Method |
|-----------|-----------|-----------|--------|
| Database | Every 6 hours | 30 days | Supabase |
| Storage | Daily | 30 days | Supabase |
| Config | On change | Forever | Git |

### Recovery Procedures
1. Database point-in-time recovery
2. Storage version restore
3. Full environment rebuild
4. Disaster recovery drill quarterly

## Scaling Strategy

### Auto-scaling Rules
| Metric | Scale Up | Scale Down |
|--------|----------|------------|
| CPU | > 70% | < 30% |
| Memory | > 80% | < 40% |
| Connections | > 80% | < 40% |

### Performance Optimization
- Connection pooling
- Query caching
- CDN caching
- Lazy loading
- Image optimization

Include complete infrastructure diagrams, pipeline configs, and operational procedures.
```

**Expected Output:** 10-12 page deployment architecture with infrastructure, CI/CD, and operational procedures.
