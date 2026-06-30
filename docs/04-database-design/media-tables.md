# Media Tables

## media

Uploaded media files (images, videos, documents) referenced by posts and content library.

```sql
CREATE TABLE media (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id        UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    uploaded_by         UUID NOT NULL REFERENCES users(id),
    folder_id           UUID REFERENCES media_folders(id) ON DELETE SET NULL,
    filename            VARCHAR(500) NOT NULL,
    original_filename   VARCHAR(500) NOT NULL,
    mime_type           VARCHAR(100) NOT NULL,
    file_size           BIGINT NOT NULL,
    width               INTEGER,
    height              INTEGER,
    duration_seconds    DECIMAL(10,2),
    storage_key         VARCHAR(1000) NOT NULL,
    cdn_url             TEXT,
    thumbnail_url       TEXT,
    alt_text            TEXT,
    metadata            JSONB DEFAULT '{}',
    status              VARCHAR(20) NOT NULL DEFAULT 'ready'
                        CHECK (status IN ('uploading', 'processing', 'ready', 'failed', 'deleted')),
    deleted_at          TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_media_organization_id ON media (organization_id);
CREATE INDEX idx_media_workspace_id ON media (workspace_id);
CREATE INDEX idx_media_uploaded_by ON media (uploaded_by);
CREATE INDEX idx_media_folder_id ON media (folder_id);
CREATE INDEX idx_media_mime_type ON media (mime_type);
CREATE INDEX idx_media_status ON media (status);
CREATE INDEX idx_media_created_at ON media (created_at DESC);
CREATE INDEX idx_media_storage_key ON media (storage_key);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Media identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| uploaded_by | UUID | No | FK to users |
| folder_id | UUID | Yes | FK to media_folders |
| filename | VARCHAR(500) | No | Stored filename (UUID-based) |
| original_filename | VARCHAR(500) | No | User's original filename |
| mime_type | VARCHAR(100) | No | MIME type |
| file_size | BIGINT | No | File size in bytes |
| width | INTEGER | Yes | Image/video width in pixels |
| height | INTEGER | Yes | Image/video height in pixels |
| duration_seconds | DECIMAL(10,2) | Yes | Video/audio duration |
| storage_key | VARCHAR(1000) | No | Object storage path |
| cdn_url | TEXT | Yes | Public CDN URL |
| thumbnail_url | TEXT | Yes | Auto-generated thumbnail URL |
| alt_text | TEXT | Yes | Accessibility alt text |
| metadata | JSONB | No | EXIF, format-specific data |
| status | VARCHAR(20) | No | Processing status |
| deleted_at | TIMESTAMPTZ | Yes | Soft delete timestamp |
| created_at | TIMESTAMPTZ | No | Upload time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## media_folders

Folder hierarchy for organizing media assets.

```sql
CREATE TABLE media_folders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    parent_id       UUID REFERENCES media_folders(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    slug            VARCHAR(255) NOT NULL,
    path            TEXT NOT NULL,
    depth           INTEGER NOT NULL DEFAULT 0,
    media_count     INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_media_folder_org_path UNIQUE (organization_id, path),
    CONSTRAINT uq_media_folder_parent_name UNIQUE (parent_id, name)
);

CREATE INDEX idx_media_folders_organization_id ON media_folders (organization_id);
CREATE INDEX idx_media_folders_workspace_id ON media_folders (workspace_id);
CREATE INDEX idx_media_folders_parent_id ON media_folders (parent_id);
CREATE INDEX idx_media_folders_path ON media_folders (path);
```

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Folder identifier |
| organization_id | UUID | No | FK to organizations |
| workspace_id | UUID | Yes | FK to workspaces |
| parent_id | UUID | Yes | Self-referencing FK for hierarchy |
| name | VARCHAR(255) | No | Folder name |
| slug | VARCHAR(255) | No | URL-safe name |
| path | TEXT | No | Full materialized path (e.g., /brand-images/social) |
| depth | INTEGER | No | Nesting depth (0 = root) |
| media_count | INTEGER | No | Cached count of media in folder |
| created_at | TIMESTAMPTZ | No | Creation time |
| updated_at | TIMESTAMPTZ | No | Last modification time |

---

## media_tags

Tags for organizing and searching media assets.

```sql
CREATE TABLE media_tags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    color           VARCHAR(7),
    usage_count     INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_media_tag_org_name UNIQUE (organization_id, name)
);

CREATE TABLE media_tag_assignments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_id        UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    media_tag_id    UUID NOT NULL REFERENCES media_tags(id) ON DELETE CASCADE,
    assigned_by     UUID REFERENCES users(id),

    CONSTRAINT uq_media_tag_assignment UNIQUE (media_id, media_tag_id)
);

CREATE INDEX idx_media_tags_organization_id ON media_tags (organization_id);
CREATE INDEX idx_media_tags_name ON media_tags (name);
CREATE INDEX idx_media_tag_assignments_media_id ON media_tag_assignments (media_id);
CREATE INDEX idx_media_tag_assignments_tag_id ON media_tag_assignments (media_tag_id);
```

### media_tags

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Tag identifier |
| organization_id | UUID | No | FK to organizations |
| name | VARCHAR(100) | No | Tag name |
| color | VARCHAR(7) | Yes | Tag color hex code |
| usage_count | INTEGER | No | Times assigned to media |
| created_at | TIMESTAMPTZ | No | Creation time |

### media_tag_assignments

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | No | Assignment identifier |
| media_id | UUID | No | FK to media |
| media_tag_id | UUID | No | FK to media_tags |
| assigned_by | UUID | Yes | FK to users |

---

## Triggers

```sql
CREATE TRIGGER trg_media_updated_at
    BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_media_folders_updated_at
    BEFORE UPDATE ON media_folders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update media folder count on media insert/delete
CREATE OR REPLACE FUNCTION update_media_folder_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.folder_id IS NOT NULL THEN
        UPDATE media_folders SET media_count = media_count + 1 WHERE id = NEW.folder_id;
    ELSIF TG_OP = 'DELETE' AND OLD.folder_id IS NOT NULL THEN
        UPDATE media_folders SET media_count = media_count - 1 WHERE id = OLD.folder_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.folder_id IS DISTINCT FROM NEW.folder_id THEN
        IF OLD.folder_id IS NOT NULL THEN
            UPDATE media_folders SET media_count = media_count - 1 WHERE id = OLD.folder_id;
        END IF;
        IF NEW.folder_id IS NOT NULL THEN
            UPDATE media_folders SET media_count = media_count + 1 WHERE id = NEW.folder_id;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_media_folder_count
    AFTER INSERT OR UPDATE OR DELETE ON media
    FOR EACH ROW EXECUTE FUNCTION update_media_folder_count();

-- Update tag usage count
CREATE OR REPLACE FUNCTION update_media_tag_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE media_tags SET usage_count = usage_count + 1 WHERE id = NEW.media_tag_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE media_tags SET usage_count = usage_count - 1 WHERE id = OLD.media_tag_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_media_tag_count
    AFTER INSERT OR DELETE ON media_tag_assignments
    FOR EACH ROW EXECUTE FUNCTION update_media_tag_count();
```
