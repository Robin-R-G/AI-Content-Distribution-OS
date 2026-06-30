# Rollback Procedures Guide

## Overview

This guide covers rollback procedures, including database rollbacks, code rollbacks, feature flag rollbacks, and communication plans.

## Database Rollback

### Database Rollback Scripts

```typescript
// scripts/db-rollback.ts
import { DataSource } from 'typeorm';

export class DatabaseRollback {
  private dataSource: DataSource;

  constructor(dataSource: DataSource) {
    this.dataSource = dataSource;
  }

  async rollbackToVersion(version: string): Promise<void> {
    console.log(`Rolling back database to version ${version}...`);

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Get current version
      const currentVersion = await this.getCurrentVersion();
      console.log(`Current version: ${currentVersion}`);

      // Get migrations to rollback
      const migrations = await this.getMigrationsToRollback(currentVersion, version);
      console.log(`Migrations to rollback: ${migrations.length}`);

      // Execute rollbacks in reverse order
      for (const migration of migrations.reverse()) {
        console.log(`Rolling back migration: ${migration.name}`);
        await queryRunner.query(migration.down);
      }

      // Update version tracking
      await queryRunner.query(
        'UPDATE schema_version SET version = $1, updated_at = NOW()',
        [version]
      );

      await queryRunner.commitTransaction();
      console.log(`Database rolled back to version ${version}`);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      console.error('Database rollback failed:', error);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  async rollbackLastMigration(): Promise<void> {
    console.log('Rolling back last migration...');

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Get last migration
      const lastMigration = await this.getLastMigration();
      
      if (!lastMigration) {
        console.log('No migrations to rollback');
        return;
      }

      console.log(`Rolling back migration: ${lastMigration.name}`);
      await queryRunner.query(lastMigration.down);

      // Remove migration record
      await queryRunner.query(
        'DELETE FROM schema_migrations WHERE version = $1',
        [lastMigration.version]
      );

      await queryRunner.commitTransaction();
      console.log('Last migration rolled back successfully');
    } catch (error) {
      await queryRunner.rollbackTransaction();
      console.error('Migration rollback failed:', error);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  private async getCurrentVersion(): Promise<string> {
    const result = await this.dataSource.query(
      'SELECT version FROM schema_version ORDER BY updated_at DESC LIMIT 1'
    );
    return result[0]?.version || '0';
  }

  private async getMigrationsToRollback(fromVersion: string, toVersion: string) {
    const result = await this.dataSource.query(
      'SELECT * FROM schema_migrations WHERE version > $1 AND version <= $2 ORDER BY version DESC',
      [toVersion, fromVersion]
    );
    return result;
  }

  private async getLastMigration() {
    const result = await this.dataSource.query(
      'SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 1'
    );
    return result[0];
  }
}
```

### Database Backup and Restore

```bash
#!/bin/bash
# scripts/db-backup-restore.sh

# Backup database
backup_database() {
  echo "Backing up database..."
  pg_dump -h localhost -p 5432 -U postgres social_media_ai > backup_$(date +%Y%m%d_%H%M%S).sql
  echo "Database backup completed"
}

# Restore database
restore_database() {
  echo "Restoring database from backup..."
  psql -h localhost -p 5432 -U postgres social_media_ai < $1
  echo "Database restore completed"
}

# Create point-in-time backup
point_in_time_backup() {
  echo "Creating point-in-time backup..."
  pg_dump -h localhost -p 5432 -U postgres -Fc social_media_ai > backup_$(date +%Y%m%d_%H%M%S).dump
  echo "Point-in-time backup completed"
}

# Restore from dump
restore_from_dump() {
  echo "Restoring from dump file..."
  pg_restore -h localhost -p 5432 -U postgres -d social_media_ai $1
  echo "Dump restore completed"
}
```

## Code Rollback

### Code Rollback Script

```typescript
// scripts/code-rollback.ts
import { execSync } from 'child_process';
import { logger } from '../src/logger';

export class CodeRollback {
  async rollbackToCommit(commitHash: string): Promise<void> {
    logger.info(`Rolling back to commit ${commitHash}...`);

    try {
      // Stash any changes
      execSync('git stash', { stdio: 'inherit' });

      // Checkout specific commit
      execSync(`git checkout ${commitHash}`, { stdio: 'inherit' });

      // Install dependencies
      execSync('npm install', { stdio: 'inherit' });

      // Build application
      execSync('npm run build', { stdio: 'inherit' });

      logger.info(`Code rolled back to commit ${commitHash}`);
    } catch (error) {
      logger.error('Code rollback failed:', error);
      throw error;
    }
  }

  async rollbackToPreviousVersion(): Promise<void> {
    logger.info('Rolling back to previous version...');

    try {
      // Get previous commit
      const previousCommit = execSync('git rev-parse HEAD~1')
        .toString()
        .trim();

      await this.rollbackToCommit(previousCommit);
    } catch (error) {
      logger.error('Previous version rollback failed:', error);
      throw error;
    }
  }

  async rollbackToTag(tagName: string): Promise<void> {
    logger.info(`Rolling back to tag ${tagName}...`);

    try {
      // Fetch tags
      execSync('git fetch --tags', { stdio: 'inherit' });

      // Checkout tag
      execSync(`git checkout ${tagName}`, { stdio: 'inherit' });

      // Install dependencies
      execSync('npm install', { stdio: 'inherit' });

      // Build application
      execSync('npm run build', { stdio: 'inherit' });

      logger.info(`Code rolled back to tag ${tagName}`);
    } catch (error) {
      logger.error('Tag rollback failed:', error);
      throw error;
    }
  }

  async createRollbackCommit(reason: string): Promise<void> {
    logger.info('Creating rollback commit...');

    try {
      // Add all changes
      execSync('git add .', { stdio: 'inherit' });

      // Create commit
      execSync(`git commit -m "rollback: ${reason}"`, { stdio: 'inherit' });

      // Push changes
      execSync('git push', { stdio: 'inherit' });

      logger.info('Rollback commit created and pushed');
    } catch (error) {
      logger.error('Rollback commit creation failed:', error);
      throw error;
    }
  }
}
```

### Docker Rollback

```bash
#!/bin/bash
# scripts/docker-rollback.sh

# Rollback to previous image
rollback_docker() {
  echo "Rolling back Docker deployment..."
  
  # Get current container
  CURRENT_CONTAINER=$(docker ps --filter "name=social-media-ai" --format "{{.ID}}")
  
  # Get previous image
  PREVIOUS_IMAGE=$(docker images social-media-ai --format "{{.Repository}}:{{.Tag}}" | head -2 | tail -1)
  
  # Stop current container
  docker stop $CURRENT_CONTAINER
  
  # Remove current container
  docker rm $CURRENT_CONTAINER
  
  # Start previous image
  docker run -d \
    --name social-media-ai \
    -p 3000:3000 \
    -e NODE_ENV=production \
    $PREVIOUS_IMAGE
  
  echo "Docker rollback completed"
}

# Rollback to specific version
rollback_docker_version() {
  echo "Rolling back Docker to version $1..."
  
  # Stop current container
  docker stop social-media-ai
  
  # Remove current container
  docker rm social-media-ai
  
  # Start specific version
  docker run -d \
    --name social-media-ai \
    -p 3000:3000 \
    -e NODE_ENV=production \
    social-media-ai:$1
  
  echo "Docker rollback to version $1 completed"
}
```

## Feature Flag Rollback

### Feature Flag Rollback Script

```typescript
// scripts/feature-flag-rollback.ts
import { FeatureFlagService } from '../src/services/feature-flag.service';
import { logger } from '../src/logger';

export class FeatureFlagRollback {
  private featureFlagService: FeatureFlagService;

  constructor() {
    this.featureFlagService = new FeatureFlagService();
  }

  async rollbackFeature(featureName: string, reason: string): Promise<void> {
    logger.info(`Rolling back feature flag: ${featureName}`);

    try {
      // Disable feature
      await this.featureFlagService.updateFlag(featureName, {
        enabled: false,
        percentage: 0,
      });

      // Log rollback
      logger.info(`Feature ${featureName} rolled back`, {
        feature: featureName,
        reason,
        timestamp: new Date().toISOString(),
      });

      // Notify stakeholders
      await this.notifyStakeholders(featureName, reason);
    } catch (error) {
      logger.error(`Feature rollback failed for ${featureName}:`, error);
      throw error;
    }
  }

  async rollbackAllFeatures(reason: string): Promise<void> {
    logger.info('Rolling back all feature flags');

    try {
      const flags = await this.featureFlagService.getFlags();
      
      for (const [featureName, flag] of flags) {
        if (flag.enabled && flag.percentage > 0) {
          await this.rollbackFeature(featureName, reason);
        }
      }

      logger.info('All feature flags rolled back');
    } catch (error) {
      logger.error('Feature flags rollback failed:', error);
      throw error;
    }
  }

  async rollbackPercentage(featureName: string, targetPercentage: number, reason: string): Promise<void> {
    logger.info(`Rolling back feature ${featureName} to ${targetPercentage}%`);

    try {
      await this.featureFlagService.updateFlag(featureName, {
        percentage: targetPercentage,
      });

      logger.info(`Feature ${featureName} rolled back to ${targetPercentage}%`, {
        feature: featureName,
        targetPercentage,
        reason,
      });
    } catch (error) {
      logger.error(`Feature percentage rollback failed for ${featureName}:`, error);
      throw error;
    }
  }

  private async notifyStakeholders(featureName: string, reason: string): Promise<void> {
    // Send notification to stakeholders
    logger.info(`Notifying stakeholders about ${featureName} rollback`, {
      feature: featureName,
      reason,
    });
  }
}
```

### Feature Flag Configuration Rollback

```typescript
// scripts/feature-config-rollback.ts
import * as fs from 'fs';
import * as path from 'path';
import { logger } from '../src/logger';

export class FeatureConfigRollback {
  async rollbackConfig(configPath: string, backupPath: string): Promise<void> {
    logger.info(`Rolling back feature configuration from ${backupPath}`);

    try {
      // Check if backup exists
      if (!fs.existsSync(backupPath)) {
        throw new Error(`Backup file not found: ${backupPath}`);
      }

      // Read backup configuration
      const configContent = fs.readFileSync(backupPath, 'utf-8');

      // Write to current configuration
      fs.writeFileSync(configPath, configContent, 'utf-8');

      logger.info('Feature configuration rolled back successfully', {
        configPath,
        backupPath,
      });
    } catch (error) {
      logger.error('Feature configuration rollback failed:', error);
      throw error;
    }
  }

  async createBackup(configPath: string): Promise<string> {
    const backupPath = `${configPath}.backup.${Date.now()}`;
    
    try {
      const configContent = fs.readFileSync(configPath, 'utf-8');
      fs.writeFileSync(backupPath, configContent, 'utf-8');
      
      logger.info('Configuration backup created', {
        configPath,
        backupPath,
      });
      
      return backupPath;
    } catch (error) {
      logger.error('Configuration backup creation failed:', error);
      throw error;
    }
  }
}
```

## Communication Plan

### Rollback Communication Templates

```markdown
## Rollback Communication Templates

### Initial Rollback Notification
```
[ROLLBACK NOTICE] - {Service Name}

Status: Rollback in progress
Reason: {reason}
Start Time: {time}
Impact: {description}
On-Call: {name}

Updates will follow every {interval}.
```

### Rollback Update
```
[ROLLBACK UPDATE] - {Service Name}

Status: {status}
Reason: {reason}
Impact: {description}
Next Update: {time}

Current Actions:
- {action1}
- {action2}
```

### Rollback Completion
```
[ROLLBACK COMPLETED] - {Service Name}

Status: Rollback completed
Duration: {duration}
Reason: {reason}
Resolution: {resolution}

Post-mortem scheduled for {time}.
```

### Rollback Summary
```
[ROLLBACK SUMMARY] - {Service Name}

Date: {date}
Duration: {duration}
Reason: {reason}
Impact: {description}

Timeline:
- {time}: {event}
- {time}: {event}

Root Cause:
- {cause}

Resolution:
- {resolution}

Action Items:
- [ ] {action1}
- [ ] {action2}

Lessons Learned:
- {lesson1}
- {lesson2}
```

### Communication Channels

```yaml
# communication/channels.yml
channels:
  email:
    - team@socialmediaai.com
    - stakeholders@socialmediaai.com
    
  slack:
    - "#incidents"
    - "#engineering"
    - "#leadership"
    
  phone:
    - primary_oncall
    - engineering_manager
    
  status_page:
    url: "https://status.socialmediaai.com"
    update_interval: "5m"
```

### Communication Script

```typescript
// scripts/communication.ts
import { logger } from '../src/logger';

export class CommunicationManager {
  async notifyRollbackStart(reason: string, impact: string): Promise<void> {
    const message = `
[ROLLBACK NOTICE] - Social Media AI

Status: Rollback in progress
Reason: ${reason}
Start Time: ${new Date().toISOString()}
Impact: ${impact}
On-Call: ${process.env.ONCALL_NAME}

Updates will follow every 5 minutes.
    `;

    await this.sendNotification(message);
  }

  async notifyRollbackUpdate(status: string, reason: string): Promise<void> {
    const message = `
[ROLLBACK UPDATE] - Social Media AI

Status: ${status}
Reason: ${reason}
Impact: ${impact}
Next Update: ${new Date(Date.now() + 5 * 60 * 1000).toISOString()}

Current Actions:
- Monitoring system recovery
- Verifying service health
    `;

    await this.sendNotification(message);
  }

  async notifyRollbackComplete(duration: string, reason: string): Promise<void> {
    const message = `
[ROLLBACK COMPLETED] - Social Media AI

Status: Rollback completed
Duration: ${duration}
Reason: ${reason}
Resolution: Service restored to previous stable version

Post-mortem scheduled for tomorrow at 10 AM.
    `;

    await this.sendNotification(message);
  }

  private async sendNotification(message: string): Promise<void> {
    // Send to email
    await this.sendEmail(message);
    
    // Send to Slack
    await this.sendSlack(message);
    
    // Update status page
    await this.updateStatusPage(message);
    
    logger.info('Rollback notification sent', { message });
  }

  private async sendEmail(message: string): Promise<void> {
    // Implement email sending
    logger.info('Email notification sent');
  }

  private async sendSlack(message: string): Promise<void> {
    // Implement Slack notification
    logger.info('Slack notification sent');
  }

  private async updateStatusPage(message: string): Promise<void> {
    // Implement status page update
    logger.info('Status page updated');
  }
}
```

## Rollback Checklist

### Pre-Rollback Checklist

```markdown
## Pre-Rollback Checklist

### Assessment
- [ ] Issue identified and documented
- [ ] Impact assessed
- [ ] Rollback reason documented
- [ ] Rollback plan reviewed

### Preparation
- [ ] On-call engineer assigned
- [ ] Stakeholders notified
- [ ] Communication channels established
- [ ] Rollback scripts tested

### Backup
- [ ] Database backup created
- [ ] Configuration backup created
- [ ] Current state documented
- [ ] Rollback artifacts prepared
```

### During Rollback Checklist

```markdown
## During Rollback Checklist

### Execution
- [ ] Rollback initiated
- [ ] Database rollback completed
- [ ] Code rollback completed
- [ ] Feature flags rolled back
- [ ] Configuration updated

### Verification
- [ ] Service health verified
- [ ] Database connectivity verified
- [ ] External services verified
- [ ] User flows verified

### Communication
- [ ] Stakeholders updated
- [ ] Status page updated
- [ ] Team notified
- [ ] Users notified (if needed)
```

### Post-Rollback Checklist

```markdown
## Post-Rollback Checklist

### Verification
- [ ] Application functioning correctly
- [ ] All critical paths working
- [ ] Performance metrics normal
- [ ] Error rates within thresholds

### Documentation
- [ ] Rollback documented
- [ ] Root cause identified
- [ ] Lessons learned recorded
- [ ] Action items created

### Follow-up
- [ ] Post-mortem scheduled
- [ ] Stakeholders debriefed
- [ ] Process improvements identified
- [ ] Team notified of resolution
```

## Running Rollback Commands

### Commands

```bash
# Rollback database
npm run db:rollback

# Rollback code
npm run code:rollback

# Rollback feature flags
npm run features:rollback

# Rollback configuration
npm run config:rollback

# Full rollback
npm run rollback:full
```

### CI/CD Integration

```yaml
# .github/workflows/rollback.yml
name: Rollback

on:
  workflow_dispatch:
    inputs:
      rollback_type:
        description: 'Type of rollback'
        required: true
        type: choice
        options:
          - database
          - code
          - features
          - full
      reason:
        description: 'Reason for rollback'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Perform rollback
        run: |
          case "${{ github.event.inputs.rollback_type }}" in
            database)
              npm run db:rollback
              ;;
            code)
              npm run code:rollback
              ;;
            features)
              npm run features:rollback
              ;;
            full)
              npm run rollback:full
              ;;
          esac
          
      - name: Verify rollback
        run: |
          npm run verify:production
          
      - name: Notify completion
        run: |
          npm run notify:rollback "${{ github.event.inputs.reason }}"
```

## Best Practices

### 1. Preparation
- Test rollback procedures regularly
- Document rollback steps
- Maintain backup systems
- Train team on rollback procedures

### 2. Execution
- Follow documented procedures
- Communicate clearly
- Monitor during rollback
- Verify after rollback

### 3. Communication
- Notify stakeholders early
- Provide regular updates
- Document everything
- Conduct post-mortems

### 4. Prevention
- Implement feature flags
- Use blue-green deployments
- Monitor thoroughly
- Test extensively

### 5. Improvement
- Learn from incidents
- Update procedures
- Share knowledge
- Prevent recurrence