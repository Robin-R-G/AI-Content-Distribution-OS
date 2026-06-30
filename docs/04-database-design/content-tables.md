# Content Tables

## posts

Core content entity. Every post belongs to a workspace and is linked to connected accounts.

```sql
CREATE TABLE posts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    created_by          UUID NOT NULL REFERENCES users(id),
    title               VARCHAR(500),
    body                TEXT NOT NULL,
    media_ids           UUID[] DEFAULT '{}',
    hashtags            TEXT[] DEFAULT '{}',
    mentions            TEXT[] DEFAULT '{}',
    status              VARCHAR(30) NOT NULL DEFAULT 'draft'
                        CHECK (status IN (
                            'draft', 'in_review', 'approved', 'scheduled',
                            'publishing', 'published', 'failed', 'archived'
                        )),
    scheduled_at        TIMESTAMPTZ,
    published_at        TIMESTAMPTZ,
    ai_generated        BOOLEAN NOT NULL DEFAULT FALSE,
    ai_prompt_id        UUID,
    content_type        VARCHAR(50) DEFAULT 'text'
                        CHECK (content_type IN ('text', 'image', 'video', 'carousel', 'story', 'reel', 'thread')),
    metadata            JSONB DEFAULT '{}',
    version             INTEGER NOT NULL DEFAULT 1,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_workspace_id ON posts (workspace_id);
CREATE INDEX idx_posts_organization_id ON posts (organization_id);
CREATE INDEX idx_posts_created_by ON posts (created_by);
CREATE INDEX idx_posts_status ON posts (status);
CREATE INDEX idx_posts_scheduled_at ON posts (scheduled_at) WHERE scheduled_at IS NOT NULL;
CREATE INDEX idx_posts_published_at ON posts (published_at) WHERE published_at IS NOT NULL;
CREATE INDEX idx_posts_content_type ON posts (content_type);
CREATE INDEX idx_posts_created_at ON posts (created_at DESC);
CREATE INDEX idx_posts_hashtags ON posts USING GIN (hashtags);
CREATE INDEX idx_posts_metadata ON posts USING GIN (metadata);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Post identifier |
| workspace_id | UUID | No | FK to workspaces |
| organization_id | UUID | No | FK to organizations |
| created_by | UUID | No | FK to users |
| title | VARCHAR(500) | Yes | Post title (LinkedIn articles, etc.) |
| body | TEXT | No | Post content (supports markdown) |
| media_ids | UUID[] | No | References to media table |
| hashtags | TEXT[] | No | Extracted/explicit hashtags |
| mentions | TEXT[] | No | @mentions |
| status | VARCHAR(30) | No | Post lifecycle status |
| scheduled_at | TIMESTAMPTZ | Yes | Scheduled publish time |
| published_at | TIMESTAMPTZ | Yes | Actual publish time |
| ai_generated | BOOLEAN | No | Whether AI helped generate content |
| ai_prompt_id | UUID | Yes | FK to ai_prompts |
| content_type | VARCHAR(50) | No | Format of the post |
| metadata | JSONB | No | Platform-specific overrides |
| version | INTEGER | No | Optimistic locking version |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## post_versions

Full version history of every post edit.

```sql
CREATE TABLE post_versions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    version         INTEGER NOT NULL,
    title           VARCHAR(500),
    body            TEXT NOT NULL,
    media_ids       UUID[] DEFAULT '{}',
    hashtags        TEXT[] DEFAULT '{}',
    changed_by      UUID NOT NULL REFERENCES users(id),
    change_summary  TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_post_version UNIQUE (post_id, version)
);

CREATE INDEX idx_post_versions_post_id ON post_versions (post_id);
CREATE INDEX idx_post_versions_created_at ON post_versions (created_at DESC);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Version identifier |
| post_id | UUID | No | FK to posts |
| version | INTEGER | No | Version number (1-indexed) |
| title | VARCHAR(500) | Yes | Title at this version |
| body | TEXT | No | Body at this version |
| media_ids | UUID[] | No | Media at this version |
| hashtags | TEXT[] | No | Hashtags at this version |
| changed_by | UUID | No | FK to users who made the edit |
| change_summary | TEXT | Yes | Description of changes |
| created_at | TIMESTAMPTZ | No | When this version was saved |

---

## post_analytics

Per-platform engagement metrics per post.

```sql
CREATE TABLE post_analytics (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id             UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    connected_account_id UUID NOT NULL REFERENCES connected_accounts(id) ON DELETE CASCADE,
    platform_post_id    VARCHAR(255),
    impressions         INTEGER NOT NULL DEFAULT 0,
    reach               INTEGER NOT NULL DEFAULT 0,
    engagement          INTEGER NOT NULL DEFAULT 0,
    likes               INTEGER NOT NULL DEFAULT 0,
    comments            INTEGER NOT NULL DEFAULT 0,
    shares              INTEGER NOT NULL DEFAULT 0,
    saves               INTEGER NOT NULL DEFAULT 0,
    clicks              INTEGER NOT NULL DEFAULT 0,
    video_views         INTEGER NOT NULL DEFAULT 0,
    profile_visits      INTEGER NOT NULL DEFAULT 0,
    follower_count      INTEGER,
    sentiment_score     DECIMAL(3,2),
    engagement_rate     DECIMAL(5,4),
    last_synced_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_post_analytics UNIQUE (post_id, connected_account_id)
);

CREATE INDEX idx_post_analytics_post_id ON post_analytics (post_id);
CREATE INDEX idx_post_analytics_account_id ON post_analytics (connected_account_id);
CREATE INDEX idx_post_analytics_last_synced ON post_analytics (last_synced_at);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Analytics record identifier |
| post_id | UUID | No | FK to posts |
| connected_account_id | UUID | No | FK to connected_accounts |
| platform_post_id | VARCHAR(255) | Yes | Post ID on the platform |
| impressions | INTEGER | No | Times shown |
| reach | INTEGER | No | Unique accounts reached |
| engagement | INTEGER | No | Total engagement actions |
| likes | INTEGER | No | Like count |
| comments | INTEGER | No | Comment count |
| shares | INTEGER | No | Share/repost count |
| saves | INTEGER | No | Save/bookmark count |
| clicks | INTEGER | No | Link clicks |
| video_views | INTEGER | No | Video view count |
| profile_visits | INTEGER | No | Profile clicks from post |
| follower_count | INTEGER | Yes | Follower count at sync time |
| sentiment_score | DECIMAL(3,2) | Yes | AI sentiment -1.00 to 1.00 |
| engagement_rate | DECIMAL(5,4) | Yes | Engagement / impressions |
| last_synced_at | TIMESTAMPTZ | No | Last analytics fetch |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## content_templates

Reusable post templates.

```sql
CREATE TABLE content_templates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by      UUID NOT NULL REFERENCES users(id),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    body            TEXT NOT NULL,
    variables       JSONB DEFAULT '[]',
    content_type    VARCHAR(50) DEFAULT 'text'
                    CHECK (content_type IN ('text', 'image', 'video', 'carousel', 'story', 'reel', 'thread')),
    tags            TEXT[] DEFAULT '{}',
    is_public       BOOLEAN NOT NULL DEFAULT FALSE,
    use_count       INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_content_templates_organization_id ON content_templates (organization_id);
CREATE INDEX idx_content_templates_workspace_id ON content_templates (workspace_id);
CREATE INDEX idx_content_templates_tags ON content_templates USING GIN (tags);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Template identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces; null = org-wide |
| created_by | UUID | No | FK to users |
| name | VARCHAR(255) | No | Template name |
| description | TEXT | Yes | Template description |
| body | TEXT | No | Template body with {{variable}} placeholders |
| variables | JSONB | No | Variable definitions (name, type, default) |
| content_type | VARCHAR(50) | No | Post format |
| tags | TEXT[] | No | Discovery tags |
| is_public | BOOLEAN | No | Visible to all org members |
| use_count | INTEGER | No | Times used to create a post |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## content_drafts

AI-generated draft variants for A/B testing and review.

```sql
CREATE TABLE content_drafts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    workspace_id    UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    ai_prompt_id    UUID REFERENCES ai_prompts(id),
    variant_label   VARCHAR(10) NOT NULL,
    body            TEXT NOT NULL,
    tone            VARCHAR(50),
    score           DECIMAL(3,2),
    feedback        VARCHAR(20) CHECK (feedback IN ('accepted', 'rejected', 'modified')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_content_draft_variant UNIQUE (post_id, variant_label)
);

CREATE INDEX idx_content_drafts_post_id ON content_drafts (post_id);
CREATE INDEX idx_content_drafts_workspace_id ON content_drafts (workspace_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Draft identifier |
| post_id | UUID | No | FK to posts |
| workspace_id | UUID | No | FK to workspaces |
| ai_prompt_id | UUID | Yes | FK to ai_prompts |
| variant_label | VARCHAR(10) | No | Variant identifier (A, B, C) |
| body | TEXT | No | Draft content |
| tone | VARCHAR(50) | Yes | Writing tone used |
| score | DECIMAL(3,2) | Yes | AI quality score 0.00-1.00 |
| feedback | VARCHAR(20) | Yes | User feedback on variant |
| created_at | TIMESTAMPTZ | No | Creation time |

---

## content_library

Evergreen content assets (images, videos, copy snippets) for reuse.

```sql
CREATE TABLE content_library (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_by      UUID NOT NULL REFERENCES users(id),
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    asset_type      VARCHAR(50) NOT NULL
                    CHECK (asset_type IN ('text', 'image', 'video', 'audio', 'document', 'template')),
    content         TEXT,
    file_url        TEXT,
    file_size       BIGINT,
    mime_type       VARCHAR(100),
    tags            TEXT[] DEFAULT '{}',
    usage_count     INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_content_library_organization_id ON content_library (organization_id);
CREATE INDEX idx_content_library_workspace_id ON content_library (workspace_id);
CREATE INDEX idx_content_library_asset_type ON content_library (asset_type);
CREATE INDEX idx_content_library_tags ON content_library USING GIN (tags);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Asset identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| created_by | UUID | No | FK to users |
| title | VARCHAR(255) | No | Asset title |
| description | TEXT | Yes | Asset description |
| asset_type | VARCHAR(50) | No | Type of asset |
| content | TEXT | Yes | Text content (for text assets) |
| file_url | TEXT | Yes | Storage URL |
| file_size | BIGINT | Yes | File size in bytes |
| mime_type | VARCHAR(100) | Yes | MIME type |
| tags | TEXT[] | No | Discovery tags |
| usage_count | INTEGER | No | Times used in posts |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## hashtags

Hashtag tracking and analytics.

```sql
CREATE TABLE hashtags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    tag             VARCHAR(100) NOT NULL,
    category        VARCHAR(100),
    is_banned       BOOLEAN NOT NULL DEFAULT FALSE,
    total_posts     INTEGER NOT NULL DEFAULT 0,
    avg_engagement  DECIMAL(10,2) DEFAULT 0,
    trending_score  DECIMAL(5,2) DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_hashtag_org_tag UNIQUE (organization_id, tag)
);

CREATE INDEX idx_hashtags_organization_id ON hashtags (organization_id);
CREATE INDEX idx_hashtags_tag ON hashtags (tag);
CREATE INDEX idx_hashtags_category ON hashtags (category);
CREATE INDEX idx_hashtags_trending ON hashtags (trending_score DESC);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Hashtag identifier |
| organization_id | UUID | No | FK to organizations |
| tag | VARCHAR(100) | No | Hashtag text (without #) |
| category | VARCHAR(100) | Yes | Categorization tag |
| is_banned | BOOLEAN | No | Whether blocked for use |
| total_posts | INTEGER | No | Times used in posts |
| avg_engagement | DECIMAL(10,2) | No | Average engagement on posts with this tag |
| trending_score | DECIMAL(5,2) | No | Current trend score |
| created_at | TIMESTAMPTZ | No | First seen time |
| updated_at | TIMESTAMPTZ | No | Last updated time |

---

## brand_kits

Brand identity assets for AI content generation.

```sql
CREATE TABLE brand_kits (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    logo_url        TEXT,
    primary_color   VARCHAR(7),
    secondary_color VARCHAR(7),
    fonts           JSONB DEFAULT '[]',
    tone_of_voice   TEXT,
    brand_keywords  TEXT[] DEFAULT '{}',
    avoid_keywords  TEXT[] DEFAULT '{}',
    sample_posts    JSONB DEFAULT '[]',
    guidelines      TEXT,
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_brand_kits_organization_id ON brand_kits (organization_id);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Brand kit identifier |
| organization_id | UUID | No | FK to organizations |
| name | VARCHAR(255) | No | Brand kit name |
| logo_url | TEXT | Yes | Brand logo URL |
| primary_color | VARCHAR(7) | Yes | Primary brand hex color |
| secondary_color | VARCHAR(7) | Yes | Secondary brand hex color |
| fonts | JSONB | No | Font definitions |
| tone_of_voice | TEXT | Yes | Brand voice description |
| brand_keywords | TEXT[] | No | Words to use |
| avoid_keywords | TEXT[] | No | Words to avoid |
| sample_posts | JSONB | No | Example posts for AI training |
| guidelines | TEXT | Yes | Full brand guidelines |
| is_default | BOOLEAN | No | Default brand kit for org |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## Triggers

```sql
CREATE TRIGGER trg_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_post_analytics_updated_at
    BEFORE UPDATE ON post_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_content_templates_updated_at
    BEFORE UPDATE ON content_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_content_library_updated_at
    BEFORE UPDATE ON content_library
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_hashtags_updated_at
    BEFORE UPDATE ON hashtags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_brand_kits_updated_at
    BEFORE UPDATE ON brand_kits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```
