# Tech Stack Selection

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
├─────────────────────────────────────────────────────────┤
│  Flutter (Web, iOS, Android, Desktop)                   │
│  └── Dart                                                │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    API LAYER                              │
├─────────────────────────────────────────────────────────┤
│  Supabase Edge Functions (Deno)                          │
│  └── REST API + GraphQL                                  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                         │
├─────────────────────────────────────────────────────────┤
│  Core Services (Edge Functions)                          │
│  ├── Content Service                                     │
│  ├── Scheduling Service                                  │
│  ├── Analytics Service                                   │
│  ├── AI Orchestration Service                            │
│  ├── Plugin Service                                      │
│  └── Collaboration Service                               │
│                                                         │
│  Background Jobs (BullMQ + Redis)                       │
│  ├── Post Publisher                                      │
│  ├── Analytics Aggregator                                │
│  ├── AI Credit Processor                                 │
│  └── Notification Sender                                 │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    DATA LAYER                             │
├─────────────────────────────────────────────────────────┤
│  Supabase (PostgreSQL)                                   │
│  ├── Primary Database                                    │
│  ├── Realtime Subscriptions                              │
│  └── Row Level Security                                  │
│                                                         │
│  Redis                                                   │
│  ├── Job Queue (BullMQ)                                  │
│  ├── Cache Layer                                         │
│  └── Rate Limiting                                       │
│                                                         │
│  Cloudflare R2                                           │
│  ├── Media Storage                                       │
│  ├── Plugin Assets                                       │
│  └── Backup Storage                                      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    EXTERNAL LAYER                        │
├─────────────────────────────────────────────────────────┤
│  AI Providers                                            │
│  ├── OpenAI (GPT-4, DALL-E)                             │
│  ├── Google (Gemini)                                     │
│  └── Anthropic (Claude)                                  │
│                                                         │
│  Platform APIs                                           │
│  ├── Instagram Graph API                                 │
│  ├── TikTok API                                          │
│  ├── YouTube Data API                                    │
│  ├── LinkedIn API                                        │
│  └── X/Twitter API                                       │
│                                                         │
│  Payment Providers                                       │
│  ├── Stripe (Global)                                     │
│  └── Razorpay (India)                                    │
└─────────────────────────────────────────────────────────┘
```

---

## Stack Justification

### 1. Flutter (Client)

**Why Flutter:**
- Single codebase for web, iOS, Android, desktop
- Hot reload for rapid development
- Native performance on all platforms
- Growing ecosystem and community

**Alternatives Considered:**
| Alternative | Pros | Cons | Decision |
|-------------|------|------|----------|
| React Native | Larger ecosystem | No desktop, JS complexity | Rejected |
| Native (Swift/Kotlin) | Best performance | 3x development cost | Rejected |
| Next.js (Web only) | Great DX | No mobile/desktop | Rejected |
| Electron | Desktop focus | Poor mobile, heavy | Rejected |

**Flutter Modules:**
- `core` — Shared UI components
- `auth` — Authentication flows
- `dashboard` — Main dashboard
- `content` — Content creation/editing
- `scheduler` — Scheduling interface
- `analytics` — Analytics dashboard
- `plugins` — Plugin management
- `settings` — User settings

---

### 2. Supabase (Backend-as-a-Service)

**Why Supabase:**
- Open-source Firebase alternative
- PostgreSQL database (not NoSQL)
- Real-time subscriptions built-in
- Row Level Security for auth
- Edge Functions for serverless compute
- Auth with social providers
- Storage for media files

**Alternatives Considered:**
| Alternative | Pros | Cons | Decision |
|-------------|------|------|----------|
| Firebase | Google ecosystem | Vendor lock-in, NoSQL | Rejected |
| AWS Amplify | AWS ecosystem | Complexity, cost | Rejected |
| Hasura | GraphQL native | Less features | Rejected |
| Custom backend | Full control | 10x development cost | Rejected |

**Supabase Features Used:**
- **Database:** PostgreSQL with migrations
- **Auth:** Email, Google, GitHub, Apple
- **Edge Functions:** API endpoints, AI orchestration
- **Realtime:** Live collaboration, notifications
- **Storage:** User uploads, plugin assets
- **RLS:** Multi-tenant security

---

### 3. PostgreSQL (Database)

**Why PostgreSQL:**
- ACID compliance for data integrity
- JSON support for flexible schemas
- Full-text search built-in
- Row Level Security for multi-tenancy
- Mature and battle-tested

**Schema Design:**
```sql
-- Core tables
users
organizations
social_accounts
posts
schedules
analytics
ai_credits
plugins
templates
teams
permissions
```

**Key Features Used:**
- UUIDs for primary keys
- JSONB for flexible metadata
- Full-text search for content
- Partitioning for analytics
- Materialized views for reports

---

### 4. Redis + BullMQ (Job Queue)

**Why Redis + BullMQ:**
- Reliable job processing
- Delayed jobs for scheduling
- Priority queues
- Retry logic
- Rate limiting
- Caching

**Job Types:**
| Job | Priority | Delay | Retries |
|-----|----------|-------|---------|
| Post Publisher | High | Scheduled time | 3 |
| Analytics Aggregator | Medium | Every hour | 2 |
| AI Credit Processor | Medium | On-demand | 2 |
| Notification Sender | Low | Immediate | 3 |
| Plugin Executor | Medium | On-demand | 2 |

**Redis Usage:**
- **Queue:** BullMQ for job processing
- **Cache:** Session data, API responses
- **Rate Limiting:** API rate limits per user
- **Pub/Sub:** Real-time notifications
- **Locks:** Distributed locks for critical operations

---

### 5. Cloudflare R2 (Storage)

**Why Cloudflare R2:**
- S3-compatible API
- No egress fees (vs AWS S3)
- Global CDN included
- 10GB free storage
- Web Workers for processing

**Storage Categories:**
| Category | Content | Retention |
|----------|---------|-----------|
| User Media | Images, videos | User-managed |
| Plugin Assets | Plugin files | Permanent |
| Analytics Data | Processed analytics | 1 year |
| Backups | Database backups | 30 days |
| Templates | Template files | Permanent |

**Alternatives Considered:**
| Alternative | Pros | Cons | Decision |
|-------------|------|------|----------|
| AWS S3 | Industry standard | Egress fees | Rejected |
| Google Cloud Storage | GCP ecosystem | Complexity | Rejected |
| Cloudinary | Media optimization | Vendor lock-in | Rejected |
| Local storage | No cost | No CDN, no scaling | Rejected |

---

### 6. AI Providers (Multi-Model)

**Why Multi-Model:**
- Best model for each task
- Redundancy if one provider fails
- Cost optimization across providers
- Avoid vendor lock-in

**Model Selection:**
| Task | Primary | Fallback | Reasoning |
|------|---------|----------|-----------|
| Content Writing | GPT-4 | Claude | Best creative writing |
| Content Analysis | Gemini | GPT-4 | Best at structured data |
| Image Generation | DALL-E 3 | Stable Diffusion | Best quality |
| Summarization | Claude | GPT-4 | Best at concise summaries |
| Code Generation | GPT-4 | Claude | Best at code |
| Multilingual | Gemini | GPT-4 | Best language support |

**AI Orchestration Layer:**
- Model selection based on task type
- Fallback logic if primary fails
- Cost tracking per model
- Performance monitoring
- A/B testing framework

---

### 7. Payment Providers

**Why Stripe + Razorpay:**
- **Stripe:** Global coverage, excellent API
- **Razorpay:** India-specific (UPI, NetBanking)

**Payment Features:**
- Subscription management
- One-time payments (templates, credits)
- Usage-based billing (API)
- Invoicing
- Tax calculation
- Fraud prevention

---

## Development Stack

### Languages
| Language | Usage |
|----------|-------|
| Dart | Flutter client |
| TypeScript | Edge Functions, BullMQ |
| SQL | Database queries |
| YAML | Configuration |

### Tools
| Tool | Purpose |
|------|---------|
| Git | Version control |
| GitHub | Code hosting, CI/CD |
| Figma | Design |
| Postman | API testing |
| Sentry | Error monitoring |
| Mixpanel | Analytics |
| Vercel | Edge Functions hosting |

### CI/CD
| Stage | Tool | Trigger |
|-------|------|---------|
| Lint | dart analyze, eslint | On commit |
| Test | flutter test, vitest | On PR |
| Build | GitHub Actions | On merge to main |
| Deploy | Supabase CLI | On merge to main |

---

## Infrastructure Costs (Estimated)

### Monthly Costs at Scale

| Service | 1K Users | 10K Users | 100K Users |
|---------|----------|-----------|------------|
| Supabase | $25 | $75 | $300 |
| Redis | $15 | $30 | $100 |
| Cloudflare R2 | $5 | $15 | $50 |
| AI APIs | $500 | $3,000 | $20,000 |
| Hosting | $10 | $25 | $75 |
| Monitoring | $20 | $50 | $150 |
| **Total** | **$575** | **$3,195** | **$20,675** |

### Cost Optimization Strategies

1. **AI Caching:** Cache AI responses for repeated prompts
2. **Batch Processing:** Batch analytics updates
3. **CDN Caching:** Cache static assets aggressively
4. **Connection Pooling:** Use Supabase connection pooling
5. **Lazy Loading:** Load data on-demand, not upfront
