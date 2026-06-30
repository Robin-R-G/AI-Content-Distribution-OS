# High-Level Architecture

## System Overview

The AI Content Distribution OS is a multi-tenant SaaS platform enabling users to create, manage, schedule, and publish AI-generated content across social media platforms. The architecture follows a layered microservices approach with event-driven communication.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CLIENT LAYER                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ Flutter  │  │ Flutter  │  │ Flutter  │  │  Admin   │  │  Embed   │    │
│  │   Web    │  │  Mobile  │  │ Desktop  │  │  Panel   │  │  SDK     │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
│       └──────────────┴──────────────┴──────────────┴──────────────┘         │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │ HTTPS / WSS
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                         API GATEWAY LAYER                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │              Cloudflare Workers / Supabase Edge Functions           │   │
│  │  ┌─────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐ ┌─────────┐ │   │
│  │  │ Routing │ │   Rate   │ │  Auth     │ │ Transform│ │ Version │ │   │
│  │  │ Engine  │ │ Limiter  │ │ Middleware│ │   Layer  │ │ Router  │ │   │
│  │  └─────────┘ └──────────┘ └───────────┘ └──────────┘ └─────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                          SERVICE LAYER                                      │
│  ┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │  Auth  │ │  Org /   │ │Workspace │ │ Content  │ │Publishing│           │
│  │Service │ │Workspace │ │ Service  │ │ Service  │ │ Service  │           │
│  └────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
│  ┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │   AI   │ │Analytics │ │Notificat.│ │ Billing  │ │ Plugin   │           │
│  │Service │ │ Service  │ │ Service  │ │ Service  │ │ Service  │           │
│  └────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
│  ┌──────────┐                                                               │
│  │  Admin   │                                                               │
│  │ Service  │                                                               │
│  └──────────┘                                                               │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                           AI LAYER                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    Prompt Orchestration Engine                       │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │  │
│  │  │ Prompt   │ │ Template │ │ Variable │ │ Output   │ │ Fallback │ │  │
│  │  │ Registry │ │ Engine   │ │ Resolver │ │ Validator│ │ Manager  │ │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│  │  OpenAI  │ │  Gemini  │ │  Claude  │ │  Local   │ │ Custom   │         │
│  │ Provider │ │ Provider │ │ Provider │ │   LLM    │ │ Provider │         │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘         │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                          QUEUE LAYER                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                        BullMQ + Redis                                │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │  │
│  │  │Publishing│ │Analytics │ │ Notific. │ │    AI    │ │  Media   │ │  │
│  │  │  Queue   │ │  Queue   │ │  Queue   │ │  Queue   │ │  Queue   │ │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                         STORAGE LAYER                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  PostgreSQL  │  │ Cloudflare   │  │    Redis     │  │  Supabase    │   │
│  │  (Supabase)  │  │     R2       │  │    Cache     │  │  Realtime    │   │
│  │  ┌────────┐  │  │  ┌────────┐  │  │  ┌────────┐  │  │  ┌────────┐  │   │
│  │  │ Users  │  │  │  │ Media  │  │  │  │Session │  │  │  │Changes │  │   │
│  │  │ Content│  │  │  │ Backups│  │  │  │ Cache  │  │  │  │ Stream │  │   │
│  │  │ Orgs   │  │  │  │ Export │  │  │  │ Rate   │  │  │  │  PubSub│  │   │
│  │  │ Logs   │  │  │  │        │  │  │  │ Limits │  │  │  │        │  │   │
│  │  └────────┘  │  │  └────────┘  │  │  └────────┘  │  │  └────────┘  │   │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘   │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                         PLUGIN LAYER                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                     Plugin Registry & Manager                       │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │  │
│  │  │ Social   │ │   AI     │ │ Storage  │ │Analytics │ │  Custom  │ │  │
│  │  │Connectors│ │Providers │ │Providers │ │Providers │ │  Plugins │ │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│  Twitter │ LinkedIn │ Instagram │ YouTube │ TikTok │ Facebook │ Pinterest  │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────────────────┐
│                       MONITORING LAYER                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│  │PostHog   │ │ Plausible│ │ Sentry   │ │ Grafana  │ │ PagerDuty│         │
│  │Analytics │ │ Web      │ │ Error    │ │ Metrics  │ │ Alerts   │         │
│  │          │ │Analytics │ │ Tracking │ │Dashboard │ │          │         │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Client Layer

| Client | Technology | Purpose |
|--------|-----------|---------|
| Web App | Flutter Web | Primary SPA for desktop browsers |
| Mobile App | Flutter (iOS/Android) | Native mobile experience |
| Desktop App | Flutter Desktop | Windows/macOS/Linux native |
| Admin Panel | Flutter Web | Internal administration |
| Embed SDK | JavaScript SDK | Third-party embeddable widgets |

### 2. API Gateway Layer

- **Routing**: Path-based and method-based request routing
- **Rate Limiting**: Token bucket algorithm per user/org/endpoint
- **Authentication**: JWT validation, OAuth callback handling
- **Transformation**: Request/response normalization
- **Versioning**: Header-based and path-based API versioning

### 3. Service Layer

Microservices communicate via:
- **Synchronous**: Supabase Edge Functions (HTTP)
- **Asynchronous**: BullMQ job queues (Redis)
- **Real-time**: Supabase Realtime (WebSockets)

### 4. AI Layer

- **Prompt Orchestration**: Template management, variable injection
- **Multi-Provider**: OpenAI, Gemini, Claude, local LLMs
- **Fallback Chain**: Automatic provider failover
- **Cost Tracking**: Per-request token usage and cost logging

### 5. Queue Layer

- **BullMQ**: Redis-backed job queue with priorities
- **Job Types**: Publishing, analytics aggregation, notifications, AI processing
- **Retry**: Exponential backoff with configurable max attempts
- **Dead Letter**: Failed job capture for manual review

### 6. Storage Layer

| Store | Purpose | Technology |
|-------|---------|------------|
| Primary DB | Relational data | PostgreSQL (Supabase) |
| Object Storage | Media files | Cloudflare R2 |
| Cache | Sessions, rate limits | Redis |
| Real-time | Live subscriptions | Supabase Realtime |

### 7. Plugin Layer

Extensible connector system for:
- Social media platforms (publishing, analytics)
- AI providers (content generation)
- Storage backends (media management)
- Analytics platforms (data export)

### 8. Monitoring Layer

- **PostHog**: Product analytics, feature flags
- **Plausible**: Privacy-first web analytics
- **Sentry**: Error tracking and performance monitoring
- **Grafana**: Infrastructure metrics dashboards
- **PagerDuty**: On-call alerting and escalation

## Data Flow Summary

```
User Request → API Gateway → Auth Check → Rate Limit Check
    → Service Router → Microservice Processing
    → Queue (async) or Direct Response
    → Storage Read/Write
    → Response to Client
    → Real-time Broadcast (if applicable)
```

## Cross-Cutting Concerns

| Concern | Implementation |
|---------|---------------|
| Authentication | Supabase Auth + JWT |
| Authorization | RBAC + Row Level Security |
| Logging | Structured JSON → Log Drain |
| Tracing | OpenTelemetry spans |
| Metrics | Prometheus → Grafana |
| Configuration | Environment variables + Vault |
| Secrets | Supabase Vault / Cloudflare Secrets |
