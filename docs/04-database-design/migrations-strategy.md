# Migration Strategy

## Principles

1. **Versioned** - Every schema change is a numbered migration
2. **Reversible** - Every migration has a `down` function
3. **Non-destructive** - Never drop columns/tables without a deprecation period
4. **Zero-downtime** - Migrations must not block reads or writes
5. **Testable** - Migrations run in CI against a test database
6. **Auditable** - Migration history is tracked in the database

## Directory Structure

```
migrations/
├── 00001_initial_schema/
│   ├── up.sql
│   └── down.sql
├── 00002_add_organization_sso/
│   ├── up.sql
│   └── down.sql
├── 00003_add_content_library/
│   ├── up.sql
│   └── down.sql
└── ...
```

## Migration Tracking Table

```sql
CREATE TABLE schema_migrations (
    version         INTEGER PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    applied_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    applied_by      VARCHAR(255),
    checksum        VARCHAR(64) NOT NULL,
    execution_ms    INTEGER,
    description     TEXT
);

CREATE INDEX idx_schema_migrations_applied_at ON schema_migrations (applied_at DESC);
```

## Migration Runner

```sql
CREATE OR REPLACE FUNCTION run_migration(
    p_version INTEGER,
    p_name VARCHAR(255),
    p_checksum VARCHAR(64),
    p_description TEXT DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
    v_start TIMESTAMPTZ;
    v_exists BOOLEAN;
BEGIN
    -- Check if already applied
    SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version = p_version) INTO v_exists;
    IF v_exists THEN
        RAISE EXCEPTION 'Migration % already applied', p_version;
    END IF;

    v_start := clock_timestamp();

    -- Track that we're running this migration
    INSERT INTO schema_migrations (version, name, applied_by, checksum, description)
    VALUES (p_version, p_name, current_user, p_checksum, p_description);

    -- Update execution time
    UPDATE schema_migrations
    SET execution_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start)::INTEGER
    WHERE version = p_version;

    RAISE NOTICE 'Migration % (%) applied in %ms', p_version, p_name,
        EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start)::INTEGER;
END;
$$ LANGUAGE plpgsql;
```

## Naming Convention

```
00001_initial_schema
00002_add_oauth_connections
00003_add_organization_sso
00004_create_content_library
00005_add_brand_kits
00006_modify_post_analytics_add_sentiment
00007_create_competitor_tracking
```

Pattern: `{version}_{action}_{description}`

Actions:
- `initial` - First migration
- `add_*` - New table/column
- `modify_*` - Alter existing structure
- `create_*` - New table (alternative to add)
- `drop_*` - Remove table/column
- `rename_*` - Rename table/column
- `seed_*` - Initial data
- `fix_*` - Bug fix migration

## Safe Migration Patterns

### Adding a Column

```sql
-- up.sql
-- Step 1: Add column with default (online for PostgreSQL 11+)
ALTER TABLE posts ADD COLUMN content_type VARCHAR(50) DEFAULT 'text';

-- Step 2: Backfill existing rows in batches (if needed)
-- Done in application code, not in migration

-- Step 3: Add NOT NULL constraint after backfill
-- ALTER TABLE posts ALTER COLUMN content_type SET NOT NULL;
-- Only do this after all rows have the value

-- down.sql
ALTER TABLE posts DROP COLUMN content_type;
```

### Adding an Index (Concurrent)

```sql
-- up.sql
-- CONCURRENTLY avoids locking the table
CREATE INDEX CONCURRENTLY idx_posts_content_type ON posts (content_type);

-- down.sql
DROP INDEX CONCURRENTLY idx_posts_content_type;
```

### Adding a Foreign Key

```sql
-- up.sql
-- Step 1: Add column first
ALTER TABLE posts ADD COLUMN brand_kit_id UUID;

-- Step 2: Backfill references (in application code)

-- Step 3: Add FK constraint
ALTER TABLE posts ADD CONSTRAINT fk_posts_brand_kit
    FOREIGN KEY (brand_kit_id) REFERENCES brand_kits(id) ON DELETE SET NULL;

-- down.sql
ALTER TABLE posts DROP CONSTRAINT fk_posts_brand_kit;
ALTER TABLE posts DROP COLUMN brand_kit_id;
```

### Renaming a Column

```sql
-- up.sql
-- Step 1: Add new column
ALTER TABLE posts ADD COLUMN content_text TEXT;

-- Step 2: Copy data (in application code)

-- Step 3: Create view for backward compatibility
CREATE VIEW posts_compat AS
SELECT id, content_text AS body, ... FROM posts;

-- down.sql
DROP VIEW IF EXISTS posts_compat;
ALTER TABLE posts DROP COLUMN content_text;
```

### Dropping a Table

```sql
-- up.sql
-- Step 1: Soft delete - stop writing to table
-- (Application code change)

-- Step 2: Migrate data (if needed)
-- (Application code change)

-- Step 3: After deprecation period (30 days), drop
DROP TABLE IF EXISTS old_table CASCADE;

-- down.sql
-- Recreate table structure
CREATE TABLE old_table (...);
```

### Data Migration

```sql
-- up.sql
-- Use a function for complex data migrations
CREATE OR REPLACE FUNCTION migrate_post_content_type() RETURNS VOID AS $$
BEGIN
    -- Batch update to avoid long locks
    LOOP
        UPDATE posts
        SET content_type = 'text'
        WHERE content_type IS NULL
        AND id IN (
            SELECT id FROM posts
            WHERE content_type IS NULL
            LIMIT 1000
        );

        EXIT WHEN NOT FOUND;
        COMMIT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT migrate_post_content_type();
DROP FUNCTION migrate_post_content_type();

-- down.sql
UPDATE posts SET content_type = NULL WHERE content_type = 'text';
```

## Rollback Strategy

### Automatic Rollback

```sql
CREATE OR REPLACE FUNCTION rollback_migration(p_version INTEGER) RETURNS VOID AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version = p_version) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Migration % not found', p_version;
    END IF;

    -- The down.sql for this migration should be executed here
    -- This is typically handled by the migration runner

    DELETE FROM schema_migrations WHERE version = p_version;
    RAISE NOTICE 'Migration % rolled back', p_version;
END;
$$ LANGUAGE plpgsql;
```

### Rollback Checklist

Before rolling back:

1. **Check dependencies** - Are other migrations built on this one?
2. **Check application compatibility** - Does old code still work?
3. **Check data safety** - Will rollback lose data?
4. **Run in staging first** - Test the full rollback
5. **Schedule downtime** if needed

## CI/CD Integration

### Migration Test Pipeline

```yaml
# .github/workflows/migrations.yml
name: Database Migrations
on: [push, pull_request]

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Run migrations up
        run: |
          for dir in migrations/*/; do
            psql -f "$dir/up.sql" postgresql://test:test@localhost:5432/test_db
          done

      - name: Verify schema
        run: psql -f scripts/verify_schema.sql postgresql://test:test@localhost:5432/test_db

      - name: Run migrations down
        run: |
          for dir in $(ls -d migrations/*/ | sort -r); do
            psql -f "$dir/down.sql" postgresql://test:test@localhost:5432/test_db
          done

      - name: Verify clean state
        run: psql -c "SELECT count(*) FROM schema_migrations;" postgresql://test:test@localhost:5432/test_db
```

### Deployment Script

```bash
#!/bin/bash
# scripts/run_migrations.sh

DB_URL="${DATABASE_URL:?DATABASE_URL is required}"
MIGRATIONS_DIR="migrations"

echo "Running pending migrations..."

# Get current version
CURRENT_VERSION=$(psql -t -A -c "SELECT COALESCE(MAX(version), 0) FROM schema_migrations;" "$DB_URL")

# Find and apply pending migrations
for dir in $(ls -d $MIGRATIONS_DIR/*/ | sort); do
    VERSION=$(basename "$dir" | cut -d'_' -f1)

    if [ "$VERSION" -gt "$CURRENT_VERSION" ]; then
        echo "Applying migration $VERSION..."

        # Calculate checksum
        CHECKSUM=$(sha256sum "$dir/up.sql" | cut -d' ' -f1)

        # Run migration
        PGPASSWORD=$PGPASSWORD psql -f "$dir/up.sql" "$DB_URL"
        if [ $? -eq 0 ]; then
            echo "Migration $VERSION applied successfully"
        else
            echo "Migration $VERSION FAILED"
            exit 1
        fi
    fi
done

echo "All migrations applied."
```

## Version Pinning

### Lock Step

All environments should run the same migration version:

```
Development:  v00045
Staging:      v00045
Production:   v00045
```

### Migration Approval Process

1. **PR Created** - Migration added to PR
2. **CI Tests** - Migrations run up and down in CI
3. **Code Review** - DBA or senior engineer reviews migration
4. **Staging Deploy** - Migrations run on staging first
5. **Production Deploy** - Migrations run during maintenance window (if needed)
6. **Verify** - Check logs, monitor for errors

## Special Cases

### Online Schema Changes

For large tables, use online schema change tools:

```sql
-- For PostgreSQL, use pg_repack or pt-online-schema-change
-- Example with pg_repack:
-- pg_repack --no-superuser --no-extensions -d mydb -t posts
```

### Feature Flags for Migrations

Gate new columns behind feature flags:

```sql
-- Migration adds column with default
ALTER TABLE posts ADD COLUMN ai_score DECIMAL(5,4);

-- Application code checks feature flag before using column
-- This allows deploying migration before deploying code
```

### Backward-Compatible Changes

1. **Add column** → Deploy code reading new column → Deploy code writing new column
2. **Drop column** → Stop writing to column → Stop reading column → Drop column
3. **Rename column** → Add new column → Dual-write → Migrate reads → Stop writes to old → Drop old

## Monitoring

### Migration Status Query

```sql
SELECT
    version,
    name,
    applied_at,
    applied_by,
    execution_ms,
    description
FROM schema_migrations
ORDER BY version DESC
LIMIT 10;
```

### Check for Failed Migrations

```sql
-- If a migration partially applied (error mid-execution)
SELECT * FROM schema_migrations
WHERE version = (
    SELECT MAX(version) FROM schema_migrations
)
AND execution_ms IS NULL;
```

### Migration Performance Log

```sql
SELECT
    version,
    name,
    execution_ms,
    CASE
        WHEN execution_ms > 60000 THEN 'SLOW'
        WHEN execution_ms > 10000 THEN 'MODERATE'
        ELSE 'FAST'
    END AS performance
FROM schema_migrations
ORDER BY execution_ms DESC
LIMIT 20;
```
