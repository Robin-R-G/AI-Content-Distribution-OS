# Billing Tables

## subscriptions

Active and historical subscription records per organization.

```sql
CREATE TABLE subscriptions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id         UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    plan                    VARCHAR(50) NOT NULL
                            CHECK (plan IN ('free', 'starter', 'pro', 'enterprise')),
    status                  VARCHAR(30) NOT NULL DEFAULT 'active'
                            CHECK (status IN (
                                'active', 'trialing', 'past_due', 'canceled',
                                'paused', 'expired', 'incomplete'
                            )),
    billing_cycle           VARCHAR(20) NOT NULL DEFAULT 'monthly'
                            CHECK (billing_cycle IN ('monthly', 'yearly')),
    trial_start             TIMESTAMPTZ,
    trial_end               TIMESTAMPTZ,
    current_period_start    TIMESTAMPTZ NOT NULL,
    current_period_end      TIMESTAMPTZ NOT NULL,
    cancel_at               TIMESTAMPTZ,
    canceled_at             TIMESTAMPTZ,
    ended_at                TIMESTAMPTZ,
    stripe_subscription_id  VARCHAR(255),
    stripe_price_id         VARCHAR(255),
    price_amount            INTEGER NOT NULL DEFAULT 0,
    currency                VARCHAR(3) NOT NULL DEFAULT 'USD',
    discount_percent        INTEGER DEFAULT 0,
    discount_expires_at     TIMESTAMPTZ,
    metadata                JSONB DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_subscription_dates CHECK (
        trial_end IS NULL OR trial_start IS NULL OR trial_end > trial_start
    ),
    CONSTRAINT chk_subscription_period CHECK (
        current_period_end > current_period_start
    )
);

CREATE INDEX idx_subscriptions_organization_id ON subscriptions (organization_id);
CREATE INDEX idx_subscriptions_status ON subscriptions (status);
CREATE INDEX idx_subscriptions_plan ON subscriptions (plan);
CREATE INDEX idx_subscriptions_current_period_end ON subscriptions (current_period_end);
CREATE INDEX idx_subscriptions_stripe ON subscriptions (stripe_subscription_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Subscription identifier |
| organization_id | UUID | No | FK to organizations |
| plan | VARCHAR(50) | No | Subscription plan tier |
| status | VARCHAR(30) | No | Subscription lifecycle status |
| billing_cycle | VARCHAR(20) | No | Monthly or yearly billing |
| trial_start | TIMESTAMPTZ | Yes | Trial start time |
| trial_end | TIMESTAMPTZ | Yes | Trial end time |
| current_period_start | TIMESTAMPTZ | No | Current billing period start |
| current_period_end | TIMESTAMPTZ | No | Current billing period end |
| cancel_at | TIMESTAMPTZ | Yes | Scheduled cancellation time |
| canceled_at | TIMESTAMPTZ | Yes | Actual cancellation time |
| ended_at | TIMESTAMPTZ | Yes | When subscription fully ended |
| stripe_subscription_id | VARCHAR(255) | Yes | Stripe subscription ID |
| stripe_price_id | VARCHAR(255) | Yes | Stripe price ID |
| price_amount | INTEGER | No | Amount in cents |
| currency | VARCHAR(3) | No | ISO 4217 currency code |
| discount_percent | INTEGER | Yes | Active discount percentage |
| discount_expires_at | TIMESTAMPTZ | Yes | When discount expires |
| metadata | JSONB | No | Additional subscription data |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## invoices

Billing invoices generated for each period.

```sql
CREATE TABLE invoices (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id         UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    subscription_id         UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    invoice_number          VARCHAR(50) NOT NULL,
    status                  VARCHAR(20) NOT NULL DEFAULT 'draft'
                            CHECK (status IN ('draft', 'open', 'paid', 'void', 'uncollectible')),
    currency                VARCHAR(3) NOT NULL DEFAULT 'USD',
    subtotal                INTEGER NOT NULL DEFAULT 0,
    tax_amount              INTEGER NOT NULL DEFAULT 0,
    discount_amount         INTEGER NOT NULL DEFAULT 0,
    total_amount            INTEGER NOT NULL DEFAULT 0,
    amount_paid             INTEGER NOT NULL DEFAULT 0,
    amount_due              INTEGER NOT NULL DEFAULT 0,
    billing_reason          VARCHAR(50)
                            CHECK (billing_reason IN (
                                'subscription_create', 'subscription_cycle',
                                'subscription_update', 'manual'
                            )),
    period_start            DATE,
    period_end              DATE,
    due_date                DATE,
    paid_at                 TIMESTAMPTZ,
    stripe_invoice_id       VARCHAR(255),
    stripe_payment_intent_id VARCHAR(255),
    line_items              JSONB DEFAULT '[]',
    pdf_url                 TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_invoice_number UNIQUE (invoice_number)
);

CREATE INDEX idx_invoices_organization_id ON invoices (organization_id);
CREATE INDEX idx_invoices_subscription_id ON invoices (subscription_id);
CREATE INDEX idx_invoices_status ON invoices (status);
CREATE INDEX idx_invoices_due_date ON invoices (due_date) WHERE status = 'open';
CREATE INDEX idx_invoices_created_at ON invoices (created_at DESC);
CREATE INDEX idx_invoices_stripe ON invoices (stripe_invoice_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Invoice identifier |
| organization_id | UUID | No | FK to organizations |
| subscription_id | UUID | Yes | FK to subscriptions |
| invoice_number | VARCHAR(50) | No | Human-readable invoice number |
| status | VARCHAR(20) | No | Invoice status |
| currency | VARCHAR(3) | No | ISO 4217 currency |
| subtotal | INTEGER | No | Amount before tax/discount (cents) |
| tax_amount | INTEGER | No | Tax amount (cents) |
| discount_amount | INTEGER | No | Discount amount (cents) |
| total_amount | INTEGER | No | Final amount (cents) |
| amount_paid | INTEGER | No | Amount already paid (cents) |
| amount_due | INTEGER | No | Remaining balance (cents) |
| billing_reason | VARCHAR(50) | Yes | Why invoice was created |
| period_start | DATE | Yes | Service period start |
| period_end | DATE | Yes | Service period end |
| due_date | DATE | Yes | Payment due date |
| paid_at | TIMESTAMPTZ | Yes | When fully paid |
| stripe_invoice_id | VARCHAR(255) | Yes | Stripe invoice ID |
| stripe_payment_intent_id | VARCHAR(255) | Yes | Stripe payment intent ID |
| line_items | JSONB | No | Detailed charge breakdown |
| pdf_url | TEXT | Yes | Downloadable invoice PDF |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## payments

Individual payment transactions.

```sql
CREATE TABLE payments (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id         UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    invoice_id              UUID REFERENCES invoices(id) ON DELETE SET NULL,
    amount                  INTEGER NOT NULL,
    currency                VARCHAR(3) NOT NULL DEFAULT 'USD',
    status                  VARCHAR(20) NOT NULL
                            CHECK (status IN ('pending', 'succeeded', 'failed', 'refunded', 'partially_refunded')),
    payment_method          VARCHAR(50)
                            CHECK (payment_method IN ('card', 'bank_transfer', 'invoice', 'credit', 'promo')),
    payment_provider        VARCHAR(50) DEFAULT 'stripe',
    stripe_payment_id       VARCHAR(255),
    stripe_charge_id        VARCHAR(255),
    card_brand              VARCHAR(20),
    card_last4              VARCHAR(4),
    failure_code            VARCHAR(100),
    failure_message         TEXT,
    refund_amount           INTEGER DEFAULT 0,
    refund_reason           TEXT,
    metadata                JSONB DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_organization_id ON payments (organization_id);
CREATE INDEX idx_payments_invoice_id ON payments (invoice_id);
CREATE INDEX idx_payments_status ON payments (status);
CREATE INDEX idx_payments_created_at ON payments (created_at DESC);
CREATE INDEX idx_payments_stripe ON payments (stripe_payment_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Payment identifier |
| organization_id | UUID | No | FK to organizations |
| invoice_id | UUID | Yes | FK to invoices |
| amount | INTEGER | No | Payment amount (cents) |
| currency | VARCHAR(3) | No | ISO 4217 currency |
| status | VARCHAR(20) | No | Payment status |
| payment_method | VARCHAR(50) | Yes | How payment was made |
| payment_provider | VARCHAR(50) | No | Payment processor |
| stripe_payment_id | VARCHAR(255) | Yes | Stripe payment ID |
| stripe_charge_id | VARCHAR(255) | Yes | Stripe charge ID |
| card_brand | VARCHAR(20) | Yes | Visa, Mastercard, etc. |
| card_last4 | VARCHAR(4) | Yes | Last 4 digits of card |
| failure_code | VARCHAR(100) | Yes | Error code |
| failure_message | TEXT | Yes | Human-readable error |
| refund_amount | INTEGER | No | Amount refunded (cents) |
| refund_reason | TEXT | Yes | Reason for refund |
| metadata | JSONB | No | Additional payment data |
| created_at | TIMESTAMPTZ | No | Transaction time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## credit_purchases

AI credit purchase records.

```sql
CREATE TABLE credit_purchases (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    payment_id          UUID REFERENCES payments(id) ON DELETE SET NULL,
    credits_purchased   INTEGER NOT NULL,
    credits_remaining   INTEGER NOT NULL,
    price_cents         INTEGER NOT NULL,
    currency            VARCHAR(3) NOT NULL DEFAULT 'USD',
    bundle_name         VARCHAR(100),
    stripe_price_id     VARCHAR(255),
    stripe_session_id   VARCHAR(255),
    status              VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'depleted', 'expired', 'refunded')),
    expires_at          TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_credit_purchases_organization_id ON credit_purchases (organization_id);
CREATE INDEX idx_credit_purchases_status ON credit_purchases (status);
CREATE INDEX idx_credit_purchases_expires_at ON credit_purchases (expires_at) WHERE status = 'active';
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Purchase identifier |
| organization_id | UUID | No | FK to organizations |
| payment_id | UUID | Yes | FK to payments |
| credits_purchased | INTEGER | No | Total credits bought |
| credits_remaining | INTEGER | No | Credits still available |
| price_cents | INTEGER | No | Price paid (cents) |
| currency | VARCHAR(3) | No | Currency |
| bundle_name | VARCHAR(100) | Yes | Bundle tier name |
| stripe_price_id | VARCHAR(255) | Yes | Stripe product/price ID |
| stripe_session_id | VARCHAR(255) | Yes | Stripe checkout session |
| status | VARCHAR(20) | No | Purchase status |
| expires_at | TIMESTAMPTZ | Yes | Credit expiration |
| created_at | TIMESTAMPTZ | No | Purchase time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## usage_records

Granular usage tracking for billing metering.

```sql
CREATE TABLE usage_records (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    subscription_id     UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    record_type         VARCHAR(50) NOT NULL
                        CHECK (record_type IN (
                            'post_published', 'ai_job', 'media_upload_mb',
                            'api_request', 'team_member', 'workspace',
                            'analytics_request', 'competitor_tracking'
                        )),
    quantity            DECIMAL(15,4) NOT NULL DEFAULT 1,
    unit                VARCHAR(50) NOT NULL,
    metadata            JSONB DEFAULT '{}',
    recorded_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    period_start        TIMESTAMPTZ NOT NULL,
    period_end          TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_usage_records_organization_id ON usage_records (organization_id);
CREATE INDEX idx_usage_records_subscription_id ON usage_records (subscription_id);
CREATE INDEX idx_usage_records_type ON usage_records (record_type);
CREATE INDEX idx_usage_records_period ON usage_records (period_start, period_end);
CREATE INDEX idx_usage_records_recorded_at ON usage_records (recorded_at DESC);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Record identifier |
| organization_id | UUID | No | FK to organizations |
| subscription_id | UUID | Yes | FK to subscriptions |
| record_type | VARCHAR(50) | No | What was consumed |
| quantity | DECIMAL(15,4) | No | Amount consumed |
| unit | VARCHAR(50) | No | Unit of measurement |
| metadata | JSONB | No | Context (workspace, platform, etc.) |
| recorded_at | TIMESTAMPTZ | No | When usage occurred |
| period_start | TIMESTAMPTZ | No | Billing period start |
| period_end | TIMESTAMPTZ | No | Billing period end |

---

## Triggers

```sql
CREATE TRIGGER trg_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_invoices_updated_at
    BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_credit_purchases_updated_at
    BEFORE UPDATE ON credit_purchases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-deplete credit purchases
CREATE OR REPLACE FUNCTION update_credit_purchase_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.credits_remaining <= 0 AND OLD.credits_remaining > 0 THEN
        NEW.status = 'depleted';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_credit_purchase_deplete
    BEFORE UPDATE ON credit_purchases
    FOR EACH ROW EXECUTE FUNCTION update_credit_purchase_status();
```
