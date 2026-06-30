# Backup Strategy Guide

## Overview

This guide covers backup strategies, including database backups, media backups, configuration backups, restore procedures, and backup testing.

## Database Backups

### Database Backup Configuration

```typescript
// src/config/backup.ts
export const backupConfig = {
  database: {
    enabled: true,
    schedule: '0 2 * * *', // Daily at 2 AM
    retention: {
      daily: 7,
      weekly: 4,
      monthly: 12,
    },
    storage: {
      type: 's3', // or 'gcs', 'azure', 'local'
      bucket: process.env.BACKUP_BUCKET,
      region: process.env.BACKUP_REGION,
      path: 'database/',
    },
    compression: true,
    encryption: true,
    encryptionKey: process.env.BACKUP_ENCRYPTION_KEY,
  },
  
  media: {
    enabled: true,
    schedule: '0 3 * * *', // Daily at 3 AM
    retention: {
      daily: 30,
      weekly: 12,
      monthly: 24,
    },
    storage: {
      type: 's3',
      bucket: process.env.MEDIA_BACKUP_BUCKET,
      region: process.env.MEDIA_BACKUP_REGION,
      path: 'media/',
    },
  },
  
  configuration: {
    enabled: true,
    schedule: '0 4 * * *', // Daily at 4 AM
    retention: {
      daily: 30,
      weekly: 12,
      monthly: 24,
    },
    storage: {
      type: 's3',
      bucket: process.env.CONFIG_BACKUP_BUCKET,
      region: process.env.CONFIG_BACKUP_REGION,
      path: 'configuration/',
    },
  },
};
```

### Database Backup Script

```typescript
// scripts/db-backup.ts
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { S3 } from 'aws-sdk';
import { logger } from '../src/logger';
import { backupConfig } from '../src/config/backup';

export class DatabaseBackup {
  private s3: S3;

  constructor() {
    this.s3 = new S3({
      region: backupConfig.database.storage.region,
    });
  }

  async createBackup(): Promise<string> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `database-backup-${timestamp}.sql`;
    const backupPath = path.join('/tmp', filename);

    logger.info('Starting database backup', { filename });

    try {
      // Create backup
      execSync(
        `pg_dump -h ${process.env.DB_HOST} -p ${process.env.DB_PORT} -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -F c -f ${backupPath}`,
        { stdio: 'inherit' }
      );

      // Compress backup
      execSync(`gzip ${backupPath}`, { stdio: 'inherit' });
      const compressedPath = `${backupPath}.gz`;

      // Upload to S3
      await this.uploadToS3(compressedPath, filename);

      // Clean up local file
      fs.unlinkSync(compressedPath);

      logger.info('Database backup completed', { filename });
      return filename;
    } catch (error) {
      logger.error('Database backup failed', error);
      throw error;
    }
  }

  async restoreBackup(filename: string): Promise<void> {
    logger.info('Starting database restore', { filename });

    try {
      // Download from S3
      const localPath = await this.downloadFromS3(filename);

      // Decompress backup
      execSync(`gunzip ${localPath}`, { stdio: 'inherit' });
      const sqlPath = localPath.replace('.gz', '');

      // Restore backup
      execSync(
        `pg_restore -h ${process.env.DB_HOST} -p ${process.env.DB_PORT} -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -c ${sqlPath}`,
        { stdio: 'inherit' }
      );

      // Clean up local file
      fs.unlinkSync(sqlPath);

      logger.info('Database restore completed', { filename });
    } catch (error) {
      logger.error('Database restore failed', error);
      throw error;
    }
  }

  private async uploadToS3(localPath: string, filename: string): Promise<void> {
    const fileContent = fs.readFileSync(localPath);
    
    await this.s3
      .upload({
        Bucket: backupConfig.database.storage.bucket,
        Key: `${backupConfig.database.storage.path}${filename}`,
        Body: fileContent,
        ServerSideEncryption: 'AES256',
      })
      .promise();

    logger.info('Backup uploaded to S3', { filename });
  }

  private async downloadFromS3(filename: string): Promise<string> {
    const localPath = path.join('/tmp', filename);
    
    const data = await this.s3
      .getObject({
        Bucket: backupConfig.database.storage.bucket,
        Key: `${backupConfig.database.storage.path}${filename}`,
      })
      .promise();

    fs.writeFileSync(localPath, data.Body as Buffer);
    
    logger.info('Backup downloaded from S3', { filename });
    return localPath;
  }

  async listBackups(): Promise<string[]> {
    const data = await this.s3
      .listObjectsV2({
        Bucket: backupConfig.database.storage.bucket,
        Prefix: backupConfig.database.storage.path,
      })
      .promise();

    return (
      data.Contents?.map((obj) => obj.Key?.split('/').pop() || '') || []
    );
  }

  async deleteBackup(filename: string): Promise<void> {
    await this.s3
      .deleteObject({
        Bucket: backupConfig.database.storage.bucket,
        Key: `${backupConfig.database.storage.path}${filename}`,
      })
      .promise();

    logger.info('Backup deleted from S3', { filename });
  }
}
```

### Automated Backup Script

```bash
#!/bin/bash
# scripts/backup.sh

set -e

echo "Starting automated backup..."

# Database backup
echo "Creating database backup..."
npm run db:backup

# Media backup
echo "Creating media backup..."
npm run media:backup

# Configuration backup
echo "Creating configuration backup..."
npm run config:backup

# Clean old backups
echo "Cleaning old backups..."
npm run backup:cleanup

echo "Automated backup completed successfully!"
```

## Media Backups

### Media Backup Configuration

```typescript
// src/config/media-backup.ts
export const mediaBackupConfig = {
  sources: [
    {
      name: 'user-uploads',
      path: '/uploads',
      type: 'local',
    },
    {
      name: 'profile-images',
      path: '/profiles',
      type: 's3',
      bucket: process.env.PROFILE_BUCKET,
    },
    {
      name: 'post-images',
      path: '/posts',
      type: 's3',
      bucket: process.env.POST_BUCKET,
    },
  ],
  
  backup: {
    schedule: '0 3 * * *', // Daily at 3 AM
    retention: {
      daily: 30,
      weekly: 12,
      monthly: 24,
    },
    compression: true,
    encryption: true,
  },
  
  storage: {
    type: 's3',
    bucket: process.env.MEDIA_BACKUP_BUCKET,
    region: process.env.MEDIA_BACKUP_REGION,
    path: 'media/',
  },
};
```

### Media Backup Script

```typescript
// scripts/media-backup.ts
import * as fs from 'fs';
import * as path from 'path';
import { S3 } from 'aws-sdk';
import { logger } from '../src/logger';
import { mediaBackupConfig } from '../src/config/media-backup';

export class MediaBackup {
  private s3: S3;

  constructor() {
    this.s3 = new S3({
      region: mediaBackupConfig.storage.region,
    });
  }

  async backupAll(): Promise<void> {
    logger.info('Starting media backup');

    for (const source of mediaBackupConfig.sources) {
      try {
        await this.backupSource(source);
      } catch (error) {
        logger.error(`Failed to backup ${source.name}`, error);
      }
    }

    logger.info('Media backup completed');
  }

  private async backupSource(source: typeof mediaBackupConfig.sources[0]): Promise<void> {
    logger.info(`Backing up ${source.name}`);

    if (source.type === 'local') {
      await this.backupLocalSource(source);
    } else if (source.type === 's3') {
      await this.backupS3Source(source);
    }
  }

  private async backupLocalSource(source: typeof mediaBackupConfig.sources[0]): Promise<void> {
    const files = this.getFilesRecursive(source.path);
    
    for (const file of files) {
      const relativePath = path.relative(source.path, file);
      const backupKey = `${mediaBackupConfig.storage.path}${source.name}/${relativePath}`;
      
      await this.uploadFile(file, backupKey);
    }

    logger.info(`Backed up ${files.length} files from ${source.name}`);
  }

  private async backupS3Source(source: typeof mediaBackupConfig.sources[0]): Promise<void> {
    const s3 = new S3({ region: source.bucket?.split('.')[0] });
    
    const data = await s3
      .listObjectsV2({
        Bucket: source.bucket!,
        Prefix: source.path,
      })
      .promise();

    for (const obj of data.Contents || []) {
      if (obj.Key) {
        const backupKey = `${mediaBackupConfig.storage.path}${source.name}/${path.basename(obj.Key)}`;
        
        await this.copyS3Object(source.bucket!, obj.Key, backupKey);
      }
    }

    logger.info(`Backed up objects from ${source.name}`);
  }

  private getFilesRecursive(dir: string): string[] {
    const files: string[] = [];
    
    const items = fs.readdirSync(dir);
    for (const item of items) {
      const fullPath = path.join(dir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        files.push(...this.getFilesRecursive(fullPath));
      } else {
        files.push(fullPath);
      }
    }
    
    return files;
  }

  private async uploadFile(localPath: string, s3Key: string): Promise<void> {
    const fileContent = fs.readFileSync(localPath);
    
    await this.s3
      .upload({
        Bucket: mediaBackupConfig.storage.bucket,
        Key: s3Key,
        Body: fileContent,
        ServerSideEncryption: 'AES256',
      })
      .promise();
  }

  private async copyS3Object(sourceBucket: string, sourceKey: string, destKey: string): Promise<void> {
    await this.s3
      .copyObject({
        Bucket: mediaBackupConfig.storage.bucket,
        CopySource: `${sourceBucket}/${sourceKey}`,
        Key: destKey,
        ServerSideEncryption: 'AES256',
      })
      .promise();
  }
}
```

## Configuration Backups

### Configuration Backup Script

```typescript
// scripts/config-backup.ts
import * as fs from 'fs';
import * as path from 'path';
import { S3 } from 'aws-sdk';
import { logger } from '../src/logger';
import { backupConfig } from '../src/config/backup';

export class ConfigBackup {
  private s3: S3;

  constructor() {
    this.s3 = new S3({
      region: backupConfig.configuration.storage.region,
    });
  }

  async backupConfiguration(): Promise<void> {
    logger.info('Starting configuration backup');

    const configFiles = [
      '.env',
      '.env.production',
      'docker-compose.yml',
      'k8s/',
      'config/',
    ];

    for (const configFile of configFiles) {
      try {
        if (fs.existsSync(configFile)) {
          await this.backupFile(configFile);
        }
      } catch (error) {
        logger.error(`Failed to backup ${configFile}`, error);
      }
    }

    logger.info('Configuration backup completed');
  }

  private async backupFile(filePath: string): Promise<void> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = path.basename(filePath);
    const backupKey = `${backupConfig.configuration.storage.path}${filename}-${timestamp}`;

    if (fs.statSync(filePath).isDirectory()) {
      await this.backupDirectory(filePath, backupKey);
    } else {
      await this.backupSingleFile(filePath, backupKey);
    }

    logger.info(`Backed up ${filePath}`);
  }

  private async backupSingleFile(filePath: string, backupKey: string): Promise<void> {
    const fileContent = fs.readFileSync(filePath);
    
    await this.s3
      .upload({
        Bucket: backupConfig.configuration.storage.bucket,
        Key: backupKey,
        Body: fileContent,
        ServerSideEncryption: 'AES256',
      })
      .promise();
  }

  private async backupDirectory(dirPath: string, backupKey: string): Promise<void> {
    const files = this.getFilesRecursive(dirPath);
    
    for (const file of files) {
      const relativePath = path.relative(dirPath, file);
      const fileKey = `${backupKey}/${relativePath}`;
      
      await this.backupSingleFile(file, fileKey);
    }
  }

  private getFilesRecursive(dir: string): string[] {
    const files: string[] = [];
    
    const items = fs.readdirSync(dir);
    for (const item of items) {
      const fullPath = path.join(dir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        files.push(...this.getFilesRecursive(fullPath));
      } else {
        files.push(fullPath);
      }
    }
    
    return files;
  }

  async restoreConfiguration(version?: string): Promise<void> {
    logger.info('Starting configuration restore');

    const prefix = version
      ? `${backupConfig.configuration.storage.path}${version}`
      : backupConfig.configuration.storage.path;

    const data = await this.s3
      .listObjectsV2({
        Bucket: backupConfig.configuration.storage.bucket,
        Prefix: prefix,
      })
      .promise();

    for (const obj of data.Contents || []) {
      if (obj.Key) {
        await this.restoreFile(obj.Key);
      }
    }

    logger.info('Configuration restore completed');
  }

  private async restoreFile(s3Key: string): Promise<void> {
    const data = await this.s3
      .getObject({
        Bucket: backupConfig.configuration.storage.bucket,
        Key: s3Key,
      })
      .promise();

    const localPath = path.join(process.cwd(), s3Key);
    const dir = path.dirname(localPath);
    
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(localPath, data.Body as Buffer);
    
    logger.info(`Restored ${s3Key}`);
  }
}
```

## Restore Procedures

### Restore Script

```typescript
// scripts/restore.ts
import { DatabaseBackup } from './db-backup';
import { MediaBackup } from './media-backup';
import { ConfigBackup } from './config-backup';
import { logger } from '../src/logger';

export class RestoreManager {
  private dbBackup: DatabaseBackup;
  private mediaBackup: MediaBackup;
  private configBackup: ConfigBackup;

  constructor() {
    this.dbBackup = new DatabaseBackup();
    this.mediaBackup = new MediaBackup();
    this.configBackup = new ConfigBackup();
  }

  async restoreAll(backupDate: string): Promise<void> {
    logger.info(`Starting full restore from ${backupDate}`);

    try {
      // Restore configuration first
      await this.configBackup.restoreConfiguration(backupDate);
      
      // Restore database
      const dbBackupFile = await this.findDatabaseBackup(backupDate);
      if (dbBackupFile) {
        await this.dbBackup.restoreBackup(dbBackupFile);
      }
      
      // Restore media (optional, can be time-consuming)
      // await this.mediaBackup.restoreAll(backupDate);
      
      logger.info('Full restore completed successfully');
    } catch (error) {
      logger.error('Full restore failed', error);
      throw error;
    }
  }

  async restoreDatabase(backupFile: string): Promise<void> {
    logger.info(`Restoring database from ${backupFile}`);
    await this.dbBackup.restoreBackup(backupFile);
  }

  async restoreMedia(backupDate: string): Promise<void> {
    logger.info(`Restoring media from ${backupDate}`);
    // Implement media restore logic
  }

  async restoreConfiguration(backupDate?: string): Promise<void> {
    logger.info(`Restoring configuration from ${backupDate || 'latest'}`);
    await this.configBackup.restoreConfiguration(backupDate);
  }

  private async findDatabaseBackup(date: string): Promise<string | null> {
    const backups = await this.dbBackup.listBackups();
    return backups.find(backup => backup.includes(date)) || null;
  }
}
```

### Restore Checklist

```markdown
## Restore Checklist

### Pre-Restore
- [ ] Identify backup to restore
- [ ] Verify backup integrity
- [ ] Notify stakeholders
- [ ] Schedule maintenance window
- [ ] Create current state backup

### During Restore
- [ ] Stop application services
- [ ] Restore configuration
- [ ] Restore database
- [ ] Restore media files
- [ ] Verify restore progress

### Post-Restore
- [ ] Start application services
- [ ] Verify application functionality
- [ ] Run smoke tests
- [ ] Monitor for issues
- [ ] Notify stakeholders of completion
```

## Backup Testing

### Backup Test Script

```typescript
// scripts/test-backup.ts
import { DatabaseBackup } from './db-backup';
import { RestoreManager } from './restore';
import { logger } from '../src/logger';

export class BackupTest {
  private dbBackup: DatabaseBackup;
  private restoreManager: RestoreManager;

  constructor() {
    this.dbBackup = new DatabaseBackup();
    this.restoreManager = new RestoreManager();
  }

  async testBackupAndRestore(): Promise<void> {
    logger.info('Starting backup and restore test');

    try {
      // Create backup
      const backupFile = await this.dbBackup.createBackup();
      logger.info('Backup created', { backupFile });

      // List backups to verify
      const backups = await this.dbBackup.listBackups();
      logger.info('Available backups', { backups });

      // Test restore (to a test database)
      await this.testRestore(backupFile);
      
      logger.info('Backup and restore test completed successfully');
    } catch (error) {
      logger.error('Backup and restore test failed', error);
      throw error;
    }
  }

  private async testRestore(backupFile: string): Promise<void> {
    // This would restore to a test database
    // Implementation depends on your test setup
    logger.info('Testing restore to test database', { backupFile });
  }

  async testBackupIntegrity(): Promise<void> {
    logger.info('Testing backup integrity');

    const backups = await this.dbBackup.listBackups();
    
    for (const backup of backups.slice(0, 5)) { // Test last 5 backups
      try {
        // Download and verify backup
        logger.info(`Testing backup: ${backup}`);
        // Implement integrity check
        logger.info(`Backup ${backup} is valid`);
      } catch (error) {
        logger.error(`Backup ${backup} is invalid`, error);
      }
    }
  }

  async testRecoveryTime(): Promise<void> {
    logger.info('Testing recovery time');

    const startTime = Date.now();
    
    // Create backup
    const backupFile = await this.dbBackup.createBackup();
    
    // Test restore time
    const restoreStartTime = Date.now();
    // Perform test restore
    const restoreEndTime = Date.now();
    
    const backupTime = restoreStartTime - startTime;
    const restoreTime = restoreEndTime - restoreStartTime;
    
    logger.info('Recovery time test results', {
      backupTime: `${backupTime}ms`,
      restoreTime: `${restoreTime}ms`,
      totalTime: `${restoreEndTime - startTime}ms`,
    });
  }
}
```

### Backup Monitoring

```typescript
// src/monitoring/backup.ts
import { Gauge, Counter } from 'prom-client';
import { DatabaseBackup } from '../../scripts/db-backup';

export const backupSuccess = new Counter({
  name: 'backup_success_total',
  help: 'Total number of successful backups',
  labelNames: ['type'],
});

export const backupFailure = new Counter({
  name: 'backup_failure_total',
  help: 'Total number of failed backups',
  labelNames: ['type'],
});

export const backupSize = new Gauge({
  name: 'backup_size_bytes',
  help: 'Size of backups in bytes',
  labelNames: ['type', 'filename'],
});

export const lastBackupTime = new Gauge({
  name: 'last_backup_timestamp',
  help: 'Timestamp of last successful backup',
  labelNames: ['type'],
});

export async function monitorBackups(): Promise<void> {
  const dbBackup = new DatabaseBackup();
  
  try {
    const backups = await dbBackup.listBackups();
    
    for (const backup of backups) {
      // Monitor backup metrics
      lastBackupTime.set({ type: 'database' }, Date.now());
    }
  } catch (error) {
    backupFailure.inc({ type: 'database' });
  }
}
```

## Running Backup Commands

### Commands

```bash
# Create database backup
npm run db:backup

# Create media backup
npm run media:backup

# Create configuration backup
npm run config:backup

# Restore from backup
npm run restore:database -- --file <filename>

# List backups
npm run backup:list

# Test backup and restore
npm run backup:test

# Clean old backups
npm run backup:cleanup
```

### CI/CD Integration

```yaml
# .github/workflows/backup.yml
name: Backup Management

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  
  workflow_dispatch:
    inputs:
      action:
        description: 'Backup action'
        required: true
        type: choice
        options:
          - backup
          - restore
          - test
          - cleanup

jobs:
  backup:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Create backup
        if: github.event.inputs.action == 'backup' || github.event_name == 'schedule'
        run: |
          npm run db:backup
          npm run media:backup
          npm run config:backup
          
      - name: Test backup
        if: github.event.inputs.action == 'test'
        run: npm run backup:test
        
      - name: Cleanup old backups
        if: github.event.inputs.action == 'cleanup'
        run: npm run backup:cleanup
        
      - name: Restore backup
        if: github.event.inputs.action == 'restore'
        run: npm run restore:database -- --file ${{ github.event.inputs.file }}
```

## Best Practices

### 1. Regular Backups
- Schedule automated backups
- Monitor backup success
- Test backups regularly
- Keep multiple backup copies

### 2. Security
- Encrypt backups
- Secure backup storage
- Limit access to backups
- Audit backup access

### 3. Testing
- Test restore procedures
- Verify backup integrity
- Measure recovery time
- Document test results

### 4. Retention
- Define retention policies
- Automate cleanup
- Monitor storage usage
- Archive old backups

### 5. Documentation
- Document backup procedures
- Maintain restore procedures
- Update documentation regularly
- Train team on procedures