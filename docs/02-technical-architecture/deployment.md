# Deployment Architecture

## Overview

CI/CD pipeline with environment strategy, database migrations, feature flags, and zero-downtime deployments.

## CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                     CI/CD PIPELINE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Push/PR │────►│  GitHub  │────►│  Build   │               │
│  │  Trigger │     │  Actions │     │  Stage   │               │
│  └──────────┘     └──────────┘     └────┬─────┘               │
│                                          │                      │
│                                    ┌─────▼─────┐               │
│                                    │   Test    │               │
│                                    │   Stage   │               │
│                                    └─────┬─────┘               │
│                                          │                      │
│                              ┌───────────┼───────────┐         │
│                              │           │           │         │
│                        ┌─────▼─────┐ ┌──▼───┐ ┌────▼────┐    │
│                        │   Lint    │ │ Unit │ │  E2E   │    │
│                        │   Check   │ │Tests │ │ Tests  │    │
│                        └───────────┘ └──────┘ └────────┘    │
│                                          │                      │
│                                    ┌─────▼─────┐               │
│                                    │  Deploy   │               │
│                                    │  Preview  │               │
│                                    └─────┬─────┘               │
│                                          │                      │
│                              ┌───────────┼───────────┐         │
│                              │           │           │         │
│                        ┌─────▼─────┐     │     ┌────▼────┐    │
│                        │  Review   │     │     │  Merge  │    │
│                        │  Approve  │     │     │  to     │    │
│                        └───────────┘     │     │  main   │    │
│                                          │     └────┬────┘    │
│                                          │          │         │
│                                    ┌─────▼──────────▼─────┐   │
│                                    │    Deploy to         │   │
│                                    │    Staging           │   │
│                                    └──────────┬───────────┘   │
│                                               │                │
│                                    ┌──────────▼───────────┐   │
│                                    │   Smoke Tests        │   │
│                                    └──────────┬───────────┘   │
│                                               │                │
│                                    ┌──────────▼───────────┐   │
│                                    │   Deploy to          │   │
│                                    │   Production         │   │
│                                    └──────────┬───────────┘   │
│                                               │                │
│                                    ┌──────────▼───────────┐   │
│                                    │   Post-Deploy        │   │
│                                    │   Verification       │   │
│                                    └──────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run test:unit -- --coverage
      - run: npm run test:integration

  e2e:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npx playwright install
      - run: npm run test:e2e

  build:
    runs-on: ubuntu-latest
    needs: [lint, test, e2e]
    steps:
      - uses: actions/checkout@v4
      - name: Build Edge Functions
        run: |
          cd supabase
          supabase functions deploy --dry-run

      - name: Build Flutter Web
        run: |
          cd frontend
          flutter build web --release

      - name: Build Docker Images
        run: |
          docker build -t $REGISTRY/$IMAGE_NAME-api:latest .
          docker build -t $REGISTRY/$IMAGE_NAME-worker:latest -f Dockerfile.worker .

      - name: Push to Registry
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login $REGISTRY -u ${{ github.actor }} --password-stdin
          docker push $REGISTRY/$IMAGE_NAME-api:latest
          docker push $REGISTRY/$IMAGE_NAME-worker:latest

  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Staging
        run: |
          # Deploy Edge Functions
          cd supabase
          supabase functions deploy --project-ref ${{ secrets.STAGING_SUPABASE_REF }}

          # Deploy Frontend
          cd ../frontend
          flutter build web --release
          wrangler pages deploy build/web --project-name contentos-staging

          # Run migrations
          supabase db push --project-ref ${{ secrets.STAGING_SUPABASE_REF }}

      - name: Run Smoke Tests
        run: |
          npm run test:smoke -- --base-url=https://staging.contentos.ai

  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Production
        run: |
          # Deploy Edge Functions
          cd supabase
          supabase functions deploy --project-ref ${{ secrets.PROD_SUPABASE_REF }}

          # Deploy Frontend
          cd ../frontend
          flutter build web --release
          wrangler pages deploy build/web --project-name contentos

          # Run migrations
          supabase db push --project-ref ${{ secrets.PROD_SUPABASE_REF }}

      - name: Post-Deploy Verification
        run: |
          npm run test:smoke -- --base-url=https://contentos.ai
```

## Environment Strategy

### Environment Configuration

```
┌─────────────────────────────────────────────────────────────────┐
│                    ENVIRONMENT STRATEGY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Development                           │   │
│  │  URL: localhost:3000                                    │   │
│  │  Database: Local Supabase                               │   │
│  │  Cache: Local Redis                                     │   │
│  │  AI: Sandbox keys                                       │   │
│  │  Payments: Stripe test mode                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Staging                               │   │
│  │  URL: staging.contentos.ai                              │   │
│  │  Database: Supabase staging project                     │   │
│  │  Cache: Upstash staging                                 │   │
│  │  AI: Test API keys                                      │   │
│  │  Payments: Stripe test mode                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Production                            │   │
│  │  URL: contentos.ai                                      │   │
│  │  Database: Supabase production project                  │   │
│  │  Cache: Upstash production                              │   │
│  │  AI: Production API keys                                │   │
│  │  Payments: Stripe live mode                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Environment Variables

```typescript
// config/environments.ts
interface Environment {
  name: string;
  supabase: {
    url: string;
    anonKey: string;
    serviceRoleKey: string;
  };
  redis: {
    url: string;
  };
  ai: {
    openaiKey: string;
    anthropicKey: string;
    googleKey: string;
  };
  payments: {
    stripeKey: string;
    stripeWebhookSecret: string;
  };
  cdn: {
    r2AccountId: string;
    r2AccessKey: string;
    r2SecretKey: string;
    r2Bucket: string;
  };
  monitoring: {
    sentryDsn: string;
    posthogKey: string;
  };
}

const environments: Record<string, Environment> = {
  development: {
    name: 'development',
    supabase: {
      url: 'http://localhost:54321',
      anonKey: 'local-anon-key',
      serviceRoleKey: 'local-service-key'
    },
    redis: { url: 'redis://localhost:6379' },
    // ... other dev config
  },
  staging: {
    name: 'staging',
    supabase: {
      url: process.env.STAGING_SUPABASE_URL!,
      anonKey: process.env.STAGING_SUPABASE_ANON_KEY!,
      serviceRoleKey: process.env.STAGING_SUPABASE_SERVICE_KEY!
    },
    // ... other staging config
  },
  production: {
    name: 'production',
    supabase: {
      url: process.env.PROD_SUPABASE_URL!,
      anonKey: process.env.PROD_SUPABASE_ANON_KEY!,
      serviceRoleKey: process.env.PROD_SUPABASE_SERVICE_KEY!
    },
    // ... other production config
  }
};
```

## Database Migrations

### Migration Strategy

```typescript
// lib/database/migrations.ts
interface Migration {
  id: string;
  name: string;
  up: string;
  down: string;
  checksum: string;
  applied_at?: string;
}

class MigrationRunner {
  private supabase: SupabaseClient;

  constructor(supabase: SupabaseClient) {
    this.supabase = supabase;
  }

  async runPendingMigrations(): Promise<MigrationResult> {
    const applied = await this.getAppliedMigrations();
    const pending = await this.getPendingMigrations(applied);

    const results: MigrationResult[] = [];

    for (const migration of pending) {
      try {
        await this.applyMigration(migration);
        results.push({ migration: migration.id, status: 'success' });
      } catch (error) {
        results.push({ migration: migration.id, status: 'failed', error: error.message });
        break; // Stop on failure
      }
    }

    return {
      applied: results.filter(r => r.status === 'success').length,
      failed: results.filter(r => r.status === 'failed').length,
      results
    };
  }

  private async applyMigration(migration: Migration): Promise<void> {
    // Start transaction
    const { error } = await this.supabase.rpc('run_migration', {
      migration_sql: migration.up,
      migration_id: migration.id,
      checksum: migration.checksum
    });

    if (error) throw error;
  }

  async rollbackMigration(migrationId: string): Promise<void> {
    const migration = await this.getMigration(migrationId);
    if (!migration) throw new Error('Migration not found');

    const { error } = await this.supabase.rpc('rollback_migration', {
      migration_sql: migration.down,
      migration_id: migrationId
    });

    if (error) throw error;
  }
}
```

### Migration Safety Checklist

```yaml
migration_checklist:
  pre_deployment:
    - backup_database: true
    - test_on_staging: true
    - review_sql: true
    - check_locks: true
    - estimate_duration: true

  during_deployment:
    - monitor_locks: true
    - watch_connections: true
    - track_progress: true

  post_deployment:
    - verify_data: true
    - run_tests: true
    - monitor_errors: true
    - check_performance: true
```

## Feature Flags

### Feature Flag System

```typescript
// lib/feature-flags/flags.ts
interface FeatureFlag {
  name: string;
  description: string;
  enabled: boolean;
  rolloutPercentage?: number;
  allowedUsers?: string[];
  allowedOrganizations?: string[];
  allowedPlans?: string[];
  startDate?: string;
  endDate?: string;
}

class FeatureFlagManager {
  private flags: Map<string, FeatureFlag> = new Map();

  async loadFlags(): Promise<void> {
    const flags = await db.feature_flags.findAll();
    flags.forEach(flag => this.flags.set(flag.name, flag));
  }

  isEnabled(
    flagName: string,
    context: {
      userId?: string;
      organizationId?: string;
      plan?: string;
    }
  ): boolean {
    const flag = this.flags.get(flagName);
    if (!flag) return false;

    // Check if globally disabled
    if (!flag.enabled) return false;

    // Check date range
    if (flag.startDate && new Date() < new Date(flag.startDate)) return false;
    if (flag.endDate && new Date() > new Date(flag.endDate)) return false;

    // Check allowed users
    if (flag.allowedUsers && context.userId) {
      if (!flag.allowedUsers.includes(context.userId)) return false;
    }

    // Check allowed organizations
    if (flag.allowedOrganizations && context.organizationId) {
      if (!flag.allowedOrganizations.includes(context.organizationId)) return false;
    }

    // Check allowed plans
    if (flag.allowedPlans && context.plan) {
      if (!flag.allowedPlans.includes(context.plan)) return false;
    }

    // Check rollout percentage
    if (flag.rolloutPercentage !== undefined && context.userId) {
      const hash = this.hashString(context.userId + flagName);
      const percentage = hash % 100;
      if (percentage >= flag.rolloutPercentage) return false;
    }

    return true;
  }

  private hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash);
  }
}

export const featureFlags = new FeatureFlagManager();
```

### Feature Flag Definitions

```typescript
const defaultFlags: Omit<FeatureFlag, 'id'>[] = [
  {
    name: 'ai_content_generation',
    description: 'Enable AI content generation feature',
    enabled: true,
    allowedPlans: ['pro', 'business']
  },
  {
    name: 'advanced_analytics',
    description: 'Enable advanced analytics dashboard',
    enabled: true,
    allowedPlans: ['business']
  },
  {
    name: 'team_collaboration',
    description: 'Enable team collaboration features',
    enabled: false,
    rolloutPercentage: 25
  },
  {
    name: 'new_publishing_flow',
    description: 'New publishing workflow UI',
    enabled: true,
    rolloutPercentage: 50
  }
];
```

## Blue-Green Deployments

### Deployment Strategy

```typescript
// lib/deployment/blue-green.ts
interface DeploymentTarget {
  name: string;          // 'blue' or 'green'
  url: string;
  version: string;
  status: 'active' | 'standby' | 'deploying';
}

class BlueGreenDeployment {
  private targets: DeploymentTarget[] = [
    { name: 'blue', url: 'blue.contentos.ai', version: '1.0.0', status: 'active' },
    { name: 'green', url: 'green.contentos.ai', version: '1.0.0', status: 'standby' }
  ];

  async deploy(version: string): Promise<void> {
    const standby = this.targets.find(t => t.status === 'standby');
    if (!standby) throw new Error('No standby target available');

    // 1. Deploy to standby
    standby.status = 'deploying';
    await this.deployToTarget(standby, version);

    // 2. Run smoke tests
    const testsPassed = await this.runSmokeTests(standby.url);
    if (!testsPassed) {
      standby.status = 'standby';
      throw new Error('Smoke tests failed');
    }

    // 3. Switch traffic
    await this.switchTraffic(standby);

    // 4. Update status
    const active = this.targets.find(t => t.status === 'active');
    if (active) active.status = 'standby';
    standby.status = 'active';
    standby.version = version;
  }

  private async switchTraffic(target: DeploymentTarget): Promise<void> {
    // Update Cloudflare DNS to point to new target
    await cloudflare.dns.update({
      zone_id: process.env.CF_ZONE_ID,
      record_id: process.env.CF_RECORD_ID,
      content: target.url
    });
  }

  async rollback(): Promise<void> {
    const active = this.targets.find(t => t.status === 'active');
    const standby = this.targets.find(t => t.status === 'standby');

    if (!active || !standby) throw new Error('Cannot rollback');

    await this.switchTraffic(standby);

    active.status = 'standby';
    standby.status = 'active';
  }
}
```
