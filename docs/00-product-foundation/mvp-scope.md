# MVP Scope — v1.0

## MVP Philosophy

**Build the smallest thing that delivers value and proves the hypothesis.**

The MVP must:
1. Solve the core pain point (content scheduling across platforms)
2. Demonstrate AI value (AI content generation)
3. Validate pricing (free + paid tiers)
4. Enable learning (analytics + feedback loops)

---

## MVP Features

### Core Features (Must Have)

#### 1. Authentication & Onboarding

| Feature | Description | Priority |
|---------|-------------|----------|
| Email/Password auth | Basic authentication | P0 |
| Social login | Google, GitHub | P0 |
| Onboarding flow | 5-step guided tour | P0 |
| Profile setup | Name, avatar, niche | P0 |

#### 2. Social Account Connection

| Feature | Description | Priority |
|---------|-------------|----------|
| Instagram connection | OAuth integration | P0 |
| TikTok connection | OAuth integration | P0 |
| YouTube connection | OAuth integration | P0 |
| LinkedIn connection | OAuth integration | P0 |
| X/Twitter connection | OAuth integration | P0 |
| Account dashboard | Connected accounts view | P0 |

#### 3. Content Creation

| Feature | Description | Priority |
|---------|-------------|----------|
| Post editor | Rich text editor | P0 |
| AI caption generator | GPT-4 powered | P0 |
| Image upload | Drag & drop, paste | P0 |
| Image generation | DALL-E integration | P1 |
| Hashtag suggestions | AI-powered | P0 |
| Content library | Save drafts | P0 |

#### 4. Scheduling & Publishing

| Feature | Description | Priority |
|---------|-------------|----------|
| Calendar view | Monthly/weekly/daily | P0 |
| Drag & drop scheduling | Move posts in calendar | P0 |
| Time slot suggestions | AI-optimized times | P1 |
| Bulk scheduling | Schedule multiple posts | P0 |
| Publish now | Immediate publishing | P0 |
| Platform-specific formatting | Auto-format per platform | P0 |

#### 5. Analytics

| Feature | Description | Priority |
|---------|-------------|----------|
| Post performance | Likes, comments, shares | P0 |
| Follower growth | Track follower changes | P0 |
| Engagement rate | Calculate engagement % | P0 |
| Best times to post | Historical analysis | P1 |
| Content performance | Which posts work best | P1 |

#### 6. Dashboard

| Feature | Description | Priority |
|---------|-------------|----------|
| Overview dashboard | Key metrics at a glance | P0 |
| Upcoming posts | Scheduled content | P0 |
| Recent performance | Latest analytics | P0 |
| Quick actions | Create, schedule, publish | P0 |

### Collaboration Features (P1 — Pro Plan)

| Feature | Description | Priority |
|---------|-------------|----------|
| Team invitations | Add team members | P1 |
| Role-based access | Owner, Editor, Viewer | P1 |
| Post comments | Comment on drafts | P1 |
| Approval workflow | Basic approve/reject | P1 |

### Plugin System (P1 — Foundation)

| Feature | Description | Priority |
|---------|-------------|----------|
| Plugin SDK | Basic plugin API | P1 |
| Plugin installation | Install from marketplace | P1 |
| Plugin management | Enable/disable plugins | P1 |

---

## MVP Exclusions

### Explicitly Excluded from v1.0

| Feature | Reason | Target Version |
|---------|--------|----------------|
| Advanced analytics | Not enough data | v1.2 |
| Social listening | Complex, not core | v2.0 |
| White-label reports | Agency feature | v1.5 |
| Client portal | Agency feature | v2.0 |
| Mobile app | Web-first | v1.5 |
| Desktop app | Web-first | v2.0 |
| Custom branding | Enterprise feature | v2.0 |
| API access | Developer feature | v1.5 |
| Multi-language | Start with English | v1.2 |
| Advanced AI features | Keep AI simple | v1.2 |

---

## Technical Implementation

### Database Schema (MVP)

```sql
-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Organizations (for team accounts)
CREATE TABLE organizations (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  plan TEXT DEFAULT 'free',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Organization Members
CREATE TABLE organization_members (
  id UUID PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id),
  user_id UUID REFERENCES users(id),
  role TEXT DEFAULT 'member',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Social Accounts
CREATE TABLE social_accounts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  platform TEXT NOT NULL,
  platform_user_id TEXT NOT NULL,
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Posts
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  media_urls JSONB DEFAULT '[]',
  platform_configs JSONB NOT NULL,
  status TEXT DEFAULT 'draft',
  scheduled_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Analytics
CREATE TABLE analytics (
  id UUID PRIMARY KEY,
  post_id UUID REFERENCES posts(id),
  platform TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  impressions INTEGER DEFAULT 0,
  engagement_rate DECIMAL(5,4),
  fetched_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints (MVP)

```
POST   /auth/signup
POST   /auth/login
POST   /auth/logout
GET    /auth/user

GET    /social-accounts
POST   /social-accounts/connect
DELETE /social-accounts/:id

GET    /posts
POST   /posts
PUT    /posts/:id
DELETE /posts/:id
POST   /posts/:id/publish

GET    /analytics/dashboard
GET    /analytics/posts/:id

POST   /ai/generate-caption
POST   /ai/suggest-hashtags
POST   /ai/suggest-times
```

### AI Integration (MVP)

| Feature | Model | Prompt Strategy |
|---------|-------|-----------------|
| Caption Generation | GPT-4 | Brand voice + platform context |
| Hashtag Suggestions | GPT-4 | Content analysis + trending |
| Time Optimization | GPT-4 | Historical engagement data |
| Image Generation | DALL-E 3 | Text prompt from user |

---

## MVP Metrics

### Success Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| Signups | 1,000 | Total accounts created |
| Activation | 50% | Complete onboarding + first post |
| Weekly Active Users | 200 | Use product 3+ days/week |
| Free → Paid Conversion | 5% | Upgrade within 30 days |
| NPS | 40+ | Post-onboarding survey |
| Time to First Post | <5 min | Onboarding to first post |

### Learning Goals

1. **Do creators want AI content generation?**
   - Track: AI feature usage rate
   - Target: 30%+ of users use AI weekly

2. **Is scheduling the core pain point?**
   - Track: Posts scheduled per user
   - Target: 10+ posts scheduled per user

3. **Will users pay for this?**
   - Track: Conversion rate, ARPU
   - Target: 5% conversion, $5 ARPU

4. **Which platforms matter most?**
   - Track: Platform connection rates
   - Identify: Primary platform for each user

---

## MVP Timeline

### Week 1-2: Foundation
- [ ] Project setup (Flutter, Supabase)
- [ ] Authentication flow
- [ ] Database schema
- [ ] Basic UI components

### Week 3-4: Social Integration
- [ ] Instagram OAuth
- [ ] TikTok OAuth
- [ ] YouTube OAuth
- [ ] LinkedIn OAuth
- [ ] X/Twitter OAuth

### Week 5-6: Content Creation
- [ ] Post editor
- [ ] AI caption generation
- [ ] Image upload
- [ ] Content library

### Week 7-8: Scheduling
- [ ] Calendar view
- [ ] Drag & drop
- [ ] Publish flow
- [ ] Platform formatting

### Week 9-10: Analytics
- [ ] Post performance
- [ ] Dashboard
- [ ] Basic charts

### Week 11-12: Polish & Launch
- [ ] Onboarding optimization
- [ ] Bug fixes
- [ ] Performance testing
- [ ] Beta launch preparation

---

## MVP Resource Requirements

### Team

| Role | Count | Responsibility |
|------|-------|----------------|
| Full-Stack Developer | 2 | Core features, API |
| Flutter Developer | 1 | Mobile/web client |
| Designer | 1 | UI/UX |
| **Total** | **4** | |

### Infrastructure

| Service | Cost/Month |
|---------|------------|
| Supabase (Pro) | $25 |
| Redis (Upstash) | $10 |
| Cloudflare R2 | $5 |
| AI APIs (est.) | $500 |
| Hosting | $20 |
| **Total** | **$560** |

### Budget

| Category | Amount |
|----------|--------|
| Development (3 months) | $30,000 |
| Infrastructure | $1,680 |
| Marketing (launch) | $5,000 |
| Contingency | $3,320 |
| **Total** | **$40,000** |
