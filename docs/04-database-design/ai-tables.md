# AI Tables

## ai_jobs

Tracks every AI generation request from submission to completion.

```sql
CREATE TABLE ai_jobs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    user_id         UUID NOT NULL REFERENCES users(id),
    post_id         UUID REFERENCES posts(id) ON DELETE SET NULL,
    job_type        VARCHAR(50) NOT NULL
                    CHECK (job_type IN (
                        'generate_post', 'rewrite', 'suggest_hashtags',
                        'generate_image', 'analyze_content', 'competitor_analysis',
                        'sentiment_analysis', 'summarize', 'translate',
                        'generate_thread', 'brainstorm_topics', 'optimize_post'
                    )),
    status          VARCHAR(30) NOT NULL DEFAULT 'queued'
                    CHECK (status IN ('queued', 'processing', 'completed', 'failed', 'cancelled')),
    model           VARCHAR(100),
    prompt_tokens   INTEGER DEFAULT 0,
    completion_tokens INTEGER DEFAULT 0,
    total_tokens    INTEGER DEFAULT 0,
    credits_cost    INTEGER DEFAULT 0,
    input           JSONB NOT NULL,
    output          JSONB,
    error_message   TEXT,
    duration_ms     INTEGER,
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_jobs_organization_id ON ai_jobs (organization_id);
CREATE INDEX idx_ai_jobs_workspace_id ON ai_jobs (workspace_id);
CREATE INDEX idx_ai_jobs_user_id ON ai_jobs (user_id);
CREATE INDEX idx_ai_jobs_post_id ON ai_jobs (post_id);
CREATE INDEX idx_ai_jobs_status ON ai_jobs (status);
CREATE INDEX idx_ai_jobs_job_type ON ai_jobs (job_type);
CREATE INDEX idx_ai_jobs_created_at ON ai_jobs (created_at DESC);
CREATE INDEX idx_ai_jobs_model ON ai_jobs (model);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Job identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| user_id | UUID | No | FK to users |
| post_id | UUID | Yes | FK to posts if post-related |
| job_type | VARCHAR(50) | No | Type of AI operation |
| status | VARCHAR(30) | No | Job lifecycle status |
| model | VARCHAR(100) | Yes | AI model used (e.g., gpt-4o) |
| prompt_tokens | INTEGER | No | Input tokens consumed |
| completion_tokens | INTEGER | No | Output tokens generated |
| total_tokens | INTEGER | No | Total token count |
| credits_cost | INTEGER | No | Credits charged |
| input | JSONB | No | Request payload |
| output | JSONB | Yes | Response payload |
| error_message | TEXT | Yes | Error if failed |
| duration_ms | INTEGER | Yes | Processing duration |
| started_at | TIMESTAMPTZ | Yes | When processing began |
| completed_at | TIMESTAMPTZ | Yes | When job finished |
| created_at | TIMESTAMPTZ | No | Submission time |

---

## ai_prompts

Prompt templates used for AI generation.

```sql
CREATE TABLE ai_prompts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    created_by      UUID NOT NULL REFERENCES users(id),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    system_prompt   TEXT NOT NULL,
    user_prompt_template TEXT NOT NULL,
    variables       JSONB DEFAULT '[]',
    model           VARCHAR(100) NOT NULL DEFAULT 'gpt-4o',
    temperature     DECIMAL(3,2) DEFAULT 0.7,
    max_tokens      INTEGER DEFAULT 2000,
    category        VARCHAR(100),
    tags            TEXT[] DEFAULT '{}',
    is_system       BOOLEAN NOT NULL DEFAULT FALSE,
    is_public       BOOLEAN NOT NULL DEFAULT FALSE,
    use_count       INTEGER NOT NULL DEFAULT 0,
    avg_rating      DECIMAL(3,2),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_prompts_organization_id ON ai_prompts (organization_id);
CREATE INDEX idx_ai_prompts_created_by ON ai_prompts (created_by);
CREATE INDEX idx_ai_prompts_category ON ai_prompts (category);
CREATE INDEX idx_ai_prompts_tags ON ai_prompts USING GIN (tags);
CREATE INDEX idx_ai_prompts_is_system ON ai_prompts (is_system) WHERE is_system = TRUE;
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Prompt identifier |
| organization_id | UUID | Yes | FK to organizations; null = system prompt |
| created_by | UUID | No | FK to users |
| name | VARCHAR(255) | No | Prompt name |
| description | TEXT | Yes | What this prompt does |
| system_prompt | TEXT | No | System message for LLM |
| user_prompt_template | TEXT | No | User message template with {{vars}} |
| variables | JSONB | No | Variable definitions |
| model | VARCHAR(100) | No | Default model |
| temperature | DECIMAL(3,2) | No | Temperature setting |
| max_tokens | INTEGER | No | Max response tokens |
| category | VARCHAR(100) | Yes | Categorization |
| tags | TEXT[] | No | Discovery tags |
| is_system | BOOLEAN | No | Built-in system prompt |
| is_public | BOOLEAN | No | Visible across org |
| use_count | INTEGER | No | Times used |
| avg_rating | DECIMAL(3,2) | Yes | Average user rating |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## ai_credits

Credit balance per organization.

```sql
CREATE TABLE ai_credits (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    balance             INTEGER NOT NULL DEFAULT 0,
    total_purchased     INTEGER NOT NULL DEFAULT 0,
    total_used          INTEGER NOT NULL DEFAULT 0,
    monthly_allowance   INTEGER NOT NULL DEFAULT 0,
    monthly_used        INTEGER NOT NULL DEFAULT 0,
    month_start         DATE NOT NULL DEFAULT DATE_TRUNC('month', NOW()),
    low_balance_alert   INTEGER DEFAULT 100,
    auto_purchase       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_ai_credits_org UNIQUE (organization_id),
    CONSTRAINT chk_ai_credits_balance CHECK (balance >= 0)
);

CREATE INDEX idx_ai_credits_organization_id ON ai_credits (organization_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Credit record identifier |
| organization_id | UUID | No | FK to organizations |
| balance | INTEGER | No | Available credits |
| total_purchased | INTEGER | No | Lifetime credits purchased |
| total_used | INTEGER | No | Lifetime credits consumed |
| monthly_allowance | INTEGER | No | Plan-included monthly credits |
| monthly_used | INTEGER | No | Credits used this month |
| month_start | DATE | No | Start of current billing month |
| low_balance_alert | INTEGER | Yes | Threshold for low balance warning |
| auto_purchase | BOOLEAN | No | Auto-purchase when depleted |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## ai_credit_transactions

Immutable ledger of all credit movements.

```sql
CREATE TABLE ai_credit_transactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    ai_job_id       UUID REFERENCES ai_jobs(id) ON DELETE SET NULL,
    type            VARCHAR(30) NOT NULL
                    CHECK (type IN ('purchase', 'usage', 'refund', 'bonus', 'subscription', 'adjustment')),
    amount          INTEGER NOT NULL,
    balance_after   INTEGER NOT NULL,
    description     TEXT,
    reference_type  VARCHAR(50),
    reference_id    UUID,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_credit_transactions_organization_id ON ai_credit_transactions (organization_id);
CREATE INDEX idx_ai_credit_transactions_ai_job_id ON ai_credit_transactions (ai_job_id);
CREATE INDEX idx_ai_credit_transactions_type ON ai_credit_transactions (type);
CREATE INDEX idx_ai_credit_transactions_created_at ON ai_credit_transactions (created_at DESC);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Transaction identifier |
| organization_id | UUID | No | FK to organizations |
| ai_job_id | UUID | Yes | FK to ai_jobs (for usage) |
| type | VARCHAR(30) | No | Transaction type |
| amount | INTEGER | No | Credits added (positive) or consumed (negative) |
| balance_after | INTEGER | No | Balance after this transaction |
| description | TEXT | Yes | Human-readable description |
| reference_type | VARCHAR(50) | Yes | Related entity type |
| reference_id | UUID | Yes | Related entity ID |
| created_at | TIMESTAMPTZ | No | Transaction time |

---

## ai_models

Registry of available AI models and their configurations.

```sql
CREATE TABLE ai_models (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider        VARCHAR(50) NOT NULL,
    model_id        VARCHAR(100) NOT NULL,
    display_name    VARCHAR(255) NOT NULL,
    description     TEXT,
    capabilities    TEXT[] DEFAULT '{}',
    max_tokens      INTEGER NOT NULL DEFAULT 4096,
    input_cost_per_1k  DECIMAL(10,6),
    output_cost_per_1k DECIMAL(10,6),
    credits_per_1k  INTEGER NOT NULL DEFAULT 1,
    supports_vision BOOLEAN NOT NULL DEFAULT FALSE,
    supports_function_calling BOOLEAN NOT NULL DEFAULT FALSE,
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    enabled         BOOLEAN NOT NULL DEFAULT TRUE,
    rate_limit_rpm  INTEGER,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_ai_model_provider_id UNIQUE (provider, model_id)
);

CREATE INDEX idx_ai_models_provider ON ai_models (provider);
CREATE INDEX idx_ai_models_enabled ON ai_models (enabled) WHERE enabled = TRUE;
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Model identifier |
| provider | VARCHAR(50) | No | AI provider (openai, anthropic, etc.) |
| model_id | VARCHAR(100) | No | Provider's model ID |
| display_name | VARCHAR(255) | No | User-facing name |
| description | TEXT | Yes | Model description |
| capabilities | TEXT[] | No | What the model can do |
| max_tokens | INTEGER | No | Maximum output tokens |
| input_cost_per_1k | DECIMAL(10,6) | Yes | Cost per 1K input tokens (USD) |
| output_cost_per_1k | DECIMAL(10,6) | Yes | Cost per 1K output tokens (USD) |
| credits_per_1k | INTEGER | No | Credits charged per 1K tokens |
| supports_vision | BOOLEAN | No | Can process images |
| supports_function_calling | BOOLEAN | No | Supports tool use |
| is_default | BOOLEAN | No | Default model for new jobs |
| enabled | BOOLEAN | No | Available for use |
| rate_limit_rpm | INTEGER | Yes | Requests per minute limit |
| created_at | TIMESTAMPTZ | No | Registration time |
| updated_at | TIMESTAMPTZ | No | Last config update |

---

## Triggers

```sql
CREATE TRIGGER trg_ai_prompts_updated_at
    BEFORE UPDATE ON ai_prompts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_ai_credits_updated_at
    BEFORE UPDATE ON ai_credits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_ai_models_updated_at
    BEFORE UPDATE ON ai_models
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Validate credit balance on transactions
CREATE OR REPLACE FUNCTION validate_credit_transaction()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type = 'usage' AND NEW.amount > 0 THEN
        RAISE EXCEPTION 'Usage transactions must have negative amount';
    END IF;
    IF NEW.type = 'purchase' AND NEW.amount < 0 THEN
        RAISE EXCEPTION 'Purchase transactions must have positive amount';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_credit_transaction
    BEFORE INSERT ON ai_credit_transactions
    FOR EACH ROW EXECUTE FUNCTION validate_credit_transaction();
```
