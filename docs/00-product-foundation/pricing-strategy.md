# Pricing Strategy

## Pricing Philosophy

**Value-Based Pricing with Regional Adjustments**

Price based on the value delivered, not the cost to deliver. Adjust for purchasing power across regions while maintaining perceived value.

## Pricing Principles

1. **Transparent** — No hidden fees, no surprises
2. **Simple** — Easy to understand, easy to upgrade
3. **Fair** — Price reflects value delivered
4. **Flexible** — Multiple payment options
5. **Regional** — Adjusted for local economics

## Pricing Architecture

### Tier Design

```
Free ──────> Creator ──────> Pro ──────> Agency ──────> Enterprise
₹0           ₹399/mo        ₹999/mo     ₹2999/mo       Custom
                                                      
│            │              │           │              │
├─ 30 posts  ├─ Unlimited   ├─ Unlimited ├─ Unlimited   ├─ Unlimited
├─ 10 AI     ├─ 200 AI      ├─ 1000 AI   ├─ 5000 AI     ├─ Custom AI
├─ Basic     ├─ Advanced    ├─ Advanced  ├─ Advanced    ├─ Custom
├─ 1 team    ├─ 2 teams     ├─ 5 teams   ├─ 20 teams    ├─ Unlimited
└─ Community └─ Email       ├─ Priority  ├─ Dedicated   └─ CSM
                           └─ 5 clients ├─ 25 clients
                                       └─ White-label
```

### Upgrade Triggers

| Trigger | From → To | Mechanism |
|---------|-----------|-----------|
| Post limit hit | Free → Creator | Paywall with value demo |
| AI credits exhausted | Any → Upgrade | Credit pack upsell |
| Team member added | Creator → Pro | Collaboration paywall |
| Client added | Pro → Agency | Client management paywall |
| Need custom features | Agency → Enterprise | Sales-driven |

## Regional Pricing

### Price Multipliers

| Region | Multiplier | Rationale |
|--------|------------|-----------|
| India | 0.25x | Price-sensitive, high volume |
| Southeast Asia | 0.30x | Emerging market |
| Latin America | 0.35x | Price-sensitive |
| Eastern Europe | 0.50x | Moderate purchasing power |
| Western Europe | 0.85x | High purchasing power |
| North America | 1.00x | Base pricing |
| Australia/NZ | 0.90x | High purchasing power |

### Example: Creator Plan

| Region | Monthly | Annual (per month) |
|--------|---------|-------------------|
| India | ₹399 (~$5) | ₹333 (~$4) |
| Southeast Asia | $6 | $5 |
| Latin America | $7 | $6 |
| Eastern Europe | $9 | $7.50 |
| Western Europe | $12 | $10 |
| North America | $15 | $12.50 |
| Australia/NZ | $13 | $11 |

### Payment Methods

| Region | Methods |
|--------|---------|
| Global | Credit/Debit Card, PayPal |
| India | UPI, NetBanking, Razorpay |
| Europe | SEPA, Giropay, iDEAL |
| Brazil | PIX, Boleto |
| Global | Apple Pay, Google Pay |

## Freemium Conversion Funnel

### Free Tier Strategy

**Goal:** Demonstrate value within 5 minutes of signup.

**Conversion Levers:**

1. **AI First Value**
   - User generates first post with AI
   - Sees quality improvement
   - Wants more AI credits

2. **Scheduling Friction**
   - User schedules 5 posts (free limit)
   - Wants to schedule more
   - Hits post limit

3. **Analytics Hook**
   - User sees basic analytics
   - Wants deeper insights
   - Hits analytics paywall

4. **Team Collaboration**
   - User invites team member
   - Hits team limit
   - Upgrades for collaboration

### Conversion Optimization

| Stage | Metric | Target | Strategy |
|-------|--------|--------|----------|
| Signup → Activation | 70% | Complete onboarding | Guided tour, templates |
| Activation → Engagement | 50% | Use 3+ features | Feature discovery emails |
| Engagement → Conversion | 8% | Upgrade to paid | Value-based paywall |
| Conversion → Expansion | 20% | Upgrade tier | Usage-based upsell |

### Paywall Design

**Soft Paywall:**
- Show feature behind paywall
- Demonstrate value with preview
- Offer 7-day trial of premium feature
- Convert or move on

**Hard Paywall:**
- Post limit reached → Cannot publish more
- AI credits exhausted → Cannot generate more
- Team limit reached → Cannot add more

## Pricing Experiments

### A/B Tests

1. **Price Point Testing**
   - Test ₹299 vs ₹399 vs ₹499 for Creator
   - Measure conversion rate and LTV

2. **Annual Discount Testing**
   - Test 15% vs 17% vs 20% annual discount
   - Measure annual commitment rate

3. **Free Tier Limits**
   - Test 20 vs 30 vs 50 free posts
   - Measure conversion and retention

4. **AI Credit Allocation**
   - Test 5 vs 10 vs 20 free AI credits
   - Measure activation and upgrade

### Metrics to Track

| Metric | Target | Current |
|--------|--------|---------|
| Free → Paid Conversion | 5-8% | TBD |
| Monthly Churn (Solo) | <8% | TBD |
| Monthly Churn (Agency) | <2% | TBD |
| Average Revenue Per User | $12 | TBD |
| Customer Lifetime Value | $180+ | TBD |
| Payback Period | <6 months | TBD |

## Competitive Pricing Position

| Competitor | Starter | Pro | Team |
|------------|---------|-----|------|
| Hootsuite | $99/mo | $249/mo | $739/mo |
| Buffer | $6/mo | $12/mo | $120/mo |
| Later | $25/mo | $45/mo | $80/mo |
| Sprout Social | $249/mo | $399/mo | $899/mo |
| **Our Product** | **₹399/mo (~$5)** | **₹999/mo (~$12)** | **₹2999/mo (~$36)** |

**Position:** 3-10x cheaper than enterprise tools, comparable to budget tools but with AI-native features.

## Pricing Page Best Practices

### Design Principles

1. **Clear Value Proposition** — Each tier has a one-line value prop
2. **Feature Comparison** — Easy to compare across tiers
3. **Social Proof** — Testimonials and user counts
4. **Urgency** — Limited-time offers for annual plans
5. **Trust Signals** — Money-back guarantee, security badges

### Page Structure

1. Hero section with value prop
2. Pricing cards with features
3. Feature comparison table
4. FAQ section
5. Customer testimonials
6. Money-back guarantee
7. Contact sales (Enterprise)
