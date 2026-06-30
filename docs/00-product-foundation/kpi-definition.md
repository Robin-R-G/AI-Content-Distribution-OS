# KPI Definition

## KPI Framework

### KPI Hierarchy

```
BUSINESS KPIs
    │
    ├── Revenue KPIs
    ├── Growth KPIs
    └── Efficiency KPIs
        │
PRODUCT KPIs
    │
    ├── Acquisition KPIs
    ├── Activation KPIs
    ├── Engagement KPIs
    └── Retention KPIs
        │
TEAM KPIs
    │
    ├── Engineering KPIs
    ├── Marketing KPIs
    └── Support KPIs
```

---

## Business KPIs

### BKPI-01: Monthly Recurring Revenue (MRR)

**Definition:** Total predictable revenue collected each month.

**Formula:**
```
MRR = Σ (Active Subscriptions × Monthly Price)
```

**Components:**
- Subscription MRR
- AI Credit Pack Revenue
- Template Sales Revenue
- Plugin Commission Revenue

**Targets:**
| Month | Target |
|-------|--------|
| Month 3 | $3,000 |
| Month 6 | $15,000 |
| Month 12 | $50,000 |
| Month 24 | $200,000 |

**Measurement Frequency:** Daily

**Owner:** CEO

---

### BKPI-02: Annual Recurring Revenue (ARR)

**Definition:** MRR × 12, representing annualized revenue.

**Formula:**
```
ARR = MRR × 12
```

**Targets:**
| Month | Target |
|-------|--------|
| Month 6 | $180,000 |
| Month 12 | $600,000 |
| Month 24 | $2,400,000 |

**Measurement Frequency:** Monthly

**Owner:** CEO

---

### BKPI-03: Customer Lifetime Value (LTV)

**Definition:** Total revenue expected from a customer over their lifetime.

**Formula:**
```
LTV = ARPU × Average Customer Lifetime
LTV = ARPU × (1 / Churn Rate)
```

**Targets:**
| Segment | Target LTV |
|---------|------------|
| Solo Creator | $180 |
| Growing Creator | $960 |
| Agency | $18,000 |
| Brand Team | $48,000 |
| Blended | $500 |

**Measurement Frequency:** Monthly

**Owner:** CEO

---

### BKPI-04: Customer Acquisition Cost (CAC)

**Definition:** Total cost to acquire a new paying customer.

**Formula:**
```
CAC = Total Marketing & Sales Spend / New Paying Customers
```

**Targets:**
| Segment | Target CAC |
|---------|------------|
| Solo Creator | $25 |
| Growing Creator | $85 |
| Agency | $450 |
| Brand Team | $1,200 |
| Blended | $50 |

**Measurement Frequency:** Monthly

**Owner:** CMO

---

### BKPI-05: LTV:CAC Ratio

**Definition:** Ratio of customer lifetime value to acquisition cost.

**Formula:**
```
LTV:CAC = LTV / CAC
```

**Target:** >3:1

**Benchmarks:**
| Ratio | Assessment | Action |
|-------|------------|--------|
| <1:1 | Unsustainable | Pause acquisition |
| 1:1-2:1 | Marginal | Optimize CAC |
| 2:1-3:1 | Acceptable | Monitor closely |
| 3:1-5:1 | Good | Scale acquisition |
| >5:1 | Excellent | Invest aggressively |

**Measurement Frequency:** Monthly

**Owner:** CEO

---

### BKPI-06: Gross Margin

**Definition:** Revenue minus cost of goods sold (COGS).

**Formula:**
```
Gross Margin = (Revenue - COGS) / Revenue × 100
```

**COGS Components:**
- AI API costs
- Infrastructure costs
- Payment processing fees

**Target:** >70%

**Measurement Frequency:** Monthly

**Owner:** CFO

---

## Product KPIs

### PKPI-01: Daily Active Users (DAU)

**Definition:** Unique users who perform any meaningful action per day.

**Actions Counted:**
- Login
- Create post
- Schedule post
- View analytics
- Use AI features

**Targets:**
| Month | Target |
|-------|--------|
| Month 3 | 200 |
| Month 6 | 500 |
| Month 12 | 5,000 |
| Month 24 | 25,000 |

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### PKPI-02: Monthly Active Users (MAU)

**Definition:** Unique users who perform any meaningful action per month.

**Formula:**
```
MAU = Unique users with ≥1 action in 30 days
```

**Targets:**
| Month | Target |
|-------|--------|
| Month 3 | 1,000 |
| Month 6 | 2,000 |
| Month 12 | 15,000 |
| Month 24 | 65,000 |

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### PKPI-03: DAU/MAU Ratio (Stickiness)

**Definition:** Daily active users divided by monthly active users.

**Formula:**
```
Stickiness = DAU / MAU × 100
```

**Target:** >25%

**Interpretation:**
| Ratio | User Behavior |
|-------|---------------|
| <10% | Monthly users (low engagement) |
| 10-20% | Weekly users (moderate engagement) |
| 20-30% | Frequent users (good engagement) |
| >30% | Daily users (high engagement) |

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### PKPI-04: Activation Rate

**Definition:** % of signups who complete key activation events.

**Activation Events:**
1. Complete profile setup
2. Connect first social account
3. Create first post
4. Schedule first post
5. View analytics

**Formula:**
```
Activation Rate = Users completing ≥4 events / Total signups × 100
```

**Target:** 40%

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### PKPI-05: Time to First Value (TTV)

**Definition:** Minutes from signup to first "aha moment."

**Aha Moment:** First scheduled post going live.

**Formula:**
```
TTV = Time of first scheduled post - Signup time
```

**Target:** <5 minutes

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### PKPI-06: Feature Adoption Rate

**Definition:** % of MAU using each feature monthly.

**Formula:**
```
Feature Adoption = Users using feature / MAU × 100
```

**Targets:**
| Feature | Target |
|---------|--------|
| Post creation | 80% |
| Scheduling | 70% |
| AI caption generation | 40% |
| Analytics | 50% |
| Calendar view | 60% |
| Hashtag suggestions | 30% |
| Image generation | 20% |
| Team collaboration | 15% |

**Measurement Frequency:** Weekly

**Owner:** Product Manager

---

### PKPI-07: Session Duration

**Definition:** Average time spent in product per session.

**Formula:**
```
Session Duration = Total time in app / Total sessions
```

**Target:** 8 minutes

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### PKPI-08: Session Frequency

**Definition:** Average sessions per user per week.

**Formula:**
```
Session Frequency = Total sessions / Unique users / Weeks
```

**Target:** 5 sessions/week

**Measurement Frequency:** Weekly

**Owner:** Product Manager

---

## Acquisition KPIs

### AKPI-01: Total Signups

**Definition:** New user accounts created.

**Formula:**
```
Total Signups = Σ New accounts per day
```

**Targets:**
| Month | Target |
|-------|--------|
| Month 3 | 1,000 |
| Month 6 | 10,000 |
| Month 12 | 50,000 |
| Month 24 | 200,000 |

**Measurement Frequency:** Daily

**Owner:** Marketing

---

### AKPI-02: Signup Conversion Rate

**Definition:** % of website visitors who sign up.

**Formula:**
```
Signup Conversion = Signups / Website visitors × 100
```

**Target:** 3%

**Measurement Frequency:** Daily

**Owner:** Marketing

---

### AKPI-03: Organic vs Paid Signups

**Definition:** Breakdown of signups by acquisition channel.

**Formula:**
```
Organic % = Organic signups / Total signups × 100
Paid % = Paid signups / Total signups × 100
```

**Target:** 60% organic, 40% paid

**Measurement Frequency:** Weekly

**Owner:** Marketing

---

### AKPI-04: Cost Per Lead (CPL)

**Definition:** Marketing spend / Total leads (signups).

**Formula:**
```
CPL = Marketing spend / Signups
```

**Target:** <$5

**Measurement Frequency:** Monthly

**Owner:** Marketing

---

## Activation KPIs

### ACTKPI-01: Onboarding Completion Rate

**Definition:** % of users who complete the onboarding flow.

**Formula:**
```
Onboarding Completion = Users completing all steps / Total signups × 100
```

**Target:** 70%

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### ACTKPI-02: Social Account Connection Rate

**Definition:** % of users who connect at least one social account.

**Formula:**
```
Connection Rate = Users with ≥1 account / Total signups × 100
```

**Target:** 60%

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### ACTKPI-03: First Post Creation Rate

**Definition:** % of users who create their first post.

**Formula:**
```
First Post Rate = Users with ≥1 post / Total signups × 100
```

**Target:** 50%

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

### ACTKPI-04: First Schedule Rate

**Definition:** % of users who schedule their first post.

**Formula:**
```
First Schedule Rate = Users with ≥1 scheduled post / Total signups × 100
```

**Target:** 40%

**Measurement Frequency:** Daily

**Owner:** Product Manager

---

## Engagement KPIs

### EGKPI-01: Posts Scheduled Per User

**Definition:** Average posts scheduled per active user per week.

**Formula:**
```
Posts Per User = Total posts scheduled / Active users / Weeks
```

**Target:** 10 posts/week

**Measurement Frequency:** Weekly

**Owner:** Product Manager

---

### EGKPI-02: AI Feature Usage Rate

**Definition:** % of active users using AI features weekly.

**Formula:**
```
AI Usage = Users using AI / Active users × 100
```

**Target:** 40%

**Measurement Frequency:** Weekly

**Owner:** Product Manager

---

### EGKPI-03: Content Calendar Utilization

**Definition:** % of users with ≥5 posts scheduled in calendar.

**Formula:**
```
Calendar Utilization = Users with ≥5 scheduled / Active users × 100
```

**Target:** 30%

**Measurement Frequency:** Weekly

**Owner:** Product Manager

---

### EGKPI-04: Feature Depth Score

**Definition:** Average number of features used per user per month.

**Formula:**
```
Feature Depth = Σ Features used / Active users
```

**Target:** 4 features/user/month

**Measurement Frequency:** Monthly

**Owner:** Product Manager

---

## Retention KPIs

### RTKPI-01: Day 1 Retention

**Definition:** % of users who return 1 day after signup.

**Formula:**
```
D1 Retention = Users active on Day 1 / Users who signed up on Day 0 × 100
```

**Target:** 40%

**Measurement Frequency:** Daily (cohort-based)

**Owner:** Product Manager

---

### RTKPI-02: Day 7 Retention

**Definition:** % of users who return 7 days after signup.

**Formula:**
```
D7 Retention = Users active on Day 7 / Users who signed up on Day 0 × 100
```

**Target:** 25%

**Measurement Frequency:** Weekly (cohort-based)

**Owner:** Product Manager

---

### RTKPI-03: Day 30 Retention

**Definition:** % of users who return 30 days after signup.

**Formula:**
```
D30 Retention = Users active on Day 30 / Users who signed up on Day 0 × 100
```

**Target:** 15%

**Measurement Frequency:** Monthly (cohort-based)

**Owner:** Product Manager

---

### RTKPI-04: Monthly Churn Rate

**Definition:** % of paying customers who cancel per month.

**Formula:**
```
Churn Rate = Customers lost / Customers at start of period × 100
```

**Targets:**
| Segment | Target |
|---------|--------|
| Free users | 15% |
| Solo Creator | 8% |
| Growing Creator | 5% |
| Agency | 2% |
| Enterprise | 1% |

**Measurement Frequency:** Monthly

**Owner:** Product Manager

---

### RTKPI-05: Net Revenue Retention (NRR)

**Definition:** Revenue retained from existing customers including expansion.

**Formula:**
```
NRR = (Starting MRR + Expansion - Contraction - Churn) / Starting MRR × 100
```

**Target:** >110%

**Interpretation:**
| NRR | Assessment |
|-----|------------|
| <90% | Shrinking revenue |
| 90-100% | Flat revenue |
| 100-110% | Growing revenue |
| >110% | Strong expansion |

**Measurement Frequency:** Monthly

**Owner:** CEO

---

## Conversion KPIs

### CVKPI-01: Free-to-Paid Conversion Rate

**Definition:** % of free users who upgrade to paid plans.

**Formula:**
```
Conversion Rate = Paying users / Total users × 100
```

**Target:** 5-8%

**Measurement Frequency:** Monthly

**Owner:** Product Manager

---

### CVKPI-02: Plan Upgrade Rate

**Definition:** % of users who upgrade to higher tier per month.

**Formula:**
```
Upgrade Rate = Users upgrading / Paying users × 100
```

**Target:** 5% monthly

**Measurement Frequency:** Monthly

**Owner:** Product Manager

---

### CVKPI-03: AI Credit Purchase Rate

**Definition:** % of users who purchase AI credit packs.

**Formula:**
```
Credit Purchase Rate = Users purchasing credits / Active users × 100
```

**Target:** 10%

**Measurement Frequency:** Monthly

**Owner:** Product Manager

---

### CVKPI-04: Template Purchase Rate

**Definition:** % of users who purchase premium templates.

**Formula:**
```
Template Purchase Rate = Users purchasing templates / Active users × 100
```

**Target:** 5%

**Measurement Frequency:** Monthly

**Owner:** Product Manager

---

## Satisfaction KPIs

### SKPI-01: Net Promoter Score (NPS)

**Definition:** Likelihood of users recommending the product.

**Formula:**
```
NPS = % Promoters (9-10) - % Detractors (0-6)
```

**Target:** 60+

**Measurement Frequency:** Monthly (survey)

**Owner:** Product Manager

---

### SKPI-02: Customer Satisfaction Score (CSAT)

**Definition:** Satisfaction with specific interactions.

**Formula:**
```
CSAT = Satisfied responses / Total responses × 100
```

**Target:** >85%

**Measurement Frequency:** Per interaction

**Owner:** Support Lead

---

### SKPI-03: Support Ticket Volume

**Definition:** Number of support tickets per 1000 users.

**Formula:**
```
Ticket Volume = Support tickets / Users (in thousands)
```

**Target:** <10 tickets/1000 users/week

**Measurement Frequency:** Weekly

**Owner:** Support Lead

---

### SKPI-04: First Response Time

**Definition:** Time to first support response.

**Formula:**
```
FRT = Time of first response - Time of ticket creation
```

**Targets:**
| Plan | Target |
|------|--------|
| Free | 24 hours |
| Creator | 24 hours |
| Pro | 4 hours |
| Agency | 1 hour |
| Enterprise | 15 minutes |

**Measurement Frequency:** Daily

**Owner:** Support Lead

---

### SKPI-05: First Contact Resolution Rate

**Definition:** % of tickets resolved in first response.

**Formula:**
```
FCR = Resolved in first response / Total tickets × 100
```

**Target:** 70%

**Measurement Frequency:** Weekly

**Owner:** Support Lead

---

## KPI Dashboard

### Real-Time KPIs (Updated hourly)
- DAU
- Signups today
- Posts scheduled today
- Revenue today

### Daily KPIs (Updated daily)
- Activation rate
- Onboarding completion
- Session duration
- Support tickets

### Weekly KPIs (Updated weekly)
- MRR growth
- Churn rate
- Feature adoption
- NPS score

### Monthly KPIs (Updated monthly)
- LTV:CAC ratio
- Gross margin
- NRR
- Cohort analysis

---

## KPI Review Cadence

| Frequency | KPIs | Audience | Action |
|-----------|------|----------|--------|
| Daily | DAU, signups, revenue | Product team | Monitor |
| Weekly | Activation, retention | Leadership | Optimize |
| Monthly | Revenue, LTV, NPS | Board | Strategize |
| Quarterly | All KPIs, trends | All stakeholders | Plan |

---

## KPI Ownership

| KPI Category | Owner | Review Frequency |
|--------------|-------|------------------|
| Business KPIs | CEO | Weekly |
| Product KPIs | Product Manager | Daily |
| Acquisition KPIs | Marketing | Weekly |
| Activation KPIs | Product Manager | Daily |
| Engagement KPIs | Product Manager | Weekly |
| Retention KPIs | Product Manager | Weekly |
| Conversion KPIs | Product Manager | Monthly |
| Satisfaction KPIs | Support Lead | Weekly |
