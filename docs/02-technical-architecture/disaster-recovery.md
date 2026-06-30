# Disaster Recovery Plan

## Overview

Comprehensive DR plan with defined RPO/RTO targets, backup schedules, and recovery procedures.

## RPO and RTO Targets

| System Component | RPO (Recovery Point) | RTO (Recovery Time) | Strategy |
|-----------------|---------------------|--------------------|--------------------|
| PostgreSQL Database | 5 minutes | 15 minutes | WAL archiving + replication |
| Redis Cache | 1 hour | 30 minutes | Snapshot + rebuild |
| R2 Object Storage | 24 hours | 1 hour | Cross-region replication |
| Edge Functions | 24 hours | 15 minutes | Git + automated deploy |
| User Sessions | 1 hour | 30 minutes | Redis persistence |
| Scheduled Jobs | 5 minutes | 10 minutes | Queue persistence |

## Backup Strategy

### Database Backups

```typescript
// lib/backup/database-backup.ts
interface BackupConfig {
  schedule: string;        // Cron expression
  retention: number;       // Days to keep
  storage: 'r2' | 's3';
  compression: boolean;
  encryption: boolean;
}

const backupConfigs: Record<string, BackupConfig> = {
  full: {
    schedule: '0 2 * * *',  // Daily at 2 AM
    retention: 30,
    storage: 'r2',
    compression: true,
    encryption: true
  },
  incremental: {
    schedule: '0 * * * *',  // Hourly
    retention: 7,
    storage: 'r2',
    compression: true,
    encryption: true
  },
  wal: {
    schedule: '*/5 * * * *',  // Every 5 minutes
    retention: 3,
    storage: 'r2',
    compression: false,
    encryption: true
  }
};

class DatabaseBackupManager {
  async createFullBackup(): Promise<BackupResult> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `backup-full-${timestamp}.sql.gz`;

    // Use Supabase backup API
    const backup = await supabase.rpc('create_backup', {
      backup_type: 'full'
    });

    // Compress and encrypt
    const compressed = await compress(backup.data);
    const encrypted = await encrypt(compressed, process.env.BACKUP_ENCRYPTION_KEY!);

    // Upload to R2
    await r2.upload(`backups/database/${filename}`, encrypted);

    // Clean old backups
    await this.cleanOldBackups('full', backupConfigs.full.retention);

    return {
      filename,
      size: encrypted.length,
      timestamp: new Date().toISOString()
    };
  }

  async restoreFromBackup(backupId: string): Promise<void> {
    // 1. Download backup
    const backup = await r2.download(`backups/database/${backupId}`);

    // 2. Decrypt
    const decrypted = await decrypt(backup, process.env.BACKUP_ENCRYPTION_KEY!);

    // 3. Decompress
    const decompressed = await decompress(decrypted);

    // 4. Restore to database
    await supabase.rpc('restore_backup', {
      backup_data: decompressed.toString()
    });

    // 5. Verify restoration
    await this.verifyRestoration();
  }

  private async cleanOldBackups(type: string, retentionDays: number): Promise<void> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

    const backups = await r2.list(`backups/database/`);
    for (const backup of backups) {
      if (backup.lastModified < cutoffDate) {
        await r2.delete(backup.key);
      }
    }
  }
}
```

### Media Backups

```typescript
// lib/backup/media-backup.ts
class MediaBackupManager {
  async syncToBackupRegion(): Promise<void> {
    // R2 cross-region replication is configured at bucket level
    // This handles additional backup to secondary bucket

    const sourceBucket = process.env.R2_BUCKET_NAME;
    const backupBucket = process.env.R2_BACKUP_BUCKET;

    // List recent files
    const files = await r2.list(sourceBucket, {
      modifiedAfter: new Date(Date.now() - 24 * 60 * 60 * 1000)
    });

    for (const file of files) {
      // Check if already backed up
      const exists = await r2.exists(backupBucket, file.key);
      if (!exists) {
        const content = await r2.get(sourceBucket, file.key);
        await r2.put(backupBucket, file.key, content);
      }
    }
  }
}
```

## Backup Schedule

```
┌─────────────────────────────────────────────────────────────────┐
│                    BACKUP SCHEDULE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  PostgreSQL Backups                                      │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │ Full Backup:      Daily at 2:00 AM UTC          │    │   │
│  │  │ Incremental:      Hourly                        │    │   │
│  │  │ WAL Archival:     Every 5 minutes               │    │   │
│  │  │ Retention:        30 days (full), 7 days (incr) │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Redis Backups                                           │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │ Snapshot:          Daily at 3:00 AM UTC          │    │   │
│  │  │ RDB Persistence:   Every 15 minutes             │    │   │
│  │  │ Retention:         7 days                        │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  R2 Object Storage                                       │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │ Cross-Region Replication: Real-time             │    │   │
│  │  │ Backup Bucket Sync:      Daily at 4:00 AM UTC   │    │   │
│  │  │ Retention:               90 days                 │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Configuration & Code                                     │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │ Git Repository:    On every commit               │    │   │
│  │  │ Supabase Migrations: On every migration          │    │   │
│  │  │ Environment Config: Daily snapshot               │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Recovery Procedures

### Database Recovery

```typescript
// lib/recovery/database-recovery.ts
class DatabaseRecovery {
  async recoverToPointInTime(targetTime: Date): Promise<void> {
    // 1. Find latest full backup before target time
    const fullBackup = await this.findLatestFullBackup(targetTime);
    if (!fullBackup) throw new Error('No full backup found');

    // 2. Restore full backup
    await this.restoreBackup(fullBackup);

    // 3. Apply WAL segments up to target time
    const walSegments = await this.findWALSegments(
      fullBackup.timestamp,
      targetTime
    );

    for (const segment of walSegments) {
      await this.applyWALSegment(segment);
    }

    // 4. Verify recovery
    await this.verifyRecovery(targetTime);
  }

  async recoverFromBackup(backupId: string): Promise<void> {
    // 1. Download and restore backup
    await backupManager.restoreFromBackup(backupId);

    // 2. Restart connections
    await this.restartConnections();

    // 3. Verify data integrity
    await this.verifyIntegrity();
  }

  private async verifyRecovery(targetTime: Date): Promise<void> {
    // Check transaction ID
    const lastTxId = await db.query('SELECT txid_current()');
    console.log(`Recovered to transaction: ${lastTxId}`);

    // Check row counts
    const counts = await db.query(`
      SELECT 
        (SELECT COUNT(*) FROM users) as users,
        (SELECT COUNT(*) FROM contents) as contents,
        (SELECT COUNT(*) FROM organizations) as orgs
    `);
    console.log('Row counts:', counts);
  }
}
```

### Redis Recovery

```typescript
// lib/recovery/redis-recovery.ts
class RedisRecovery {
  async recoverFromSnapshot(): Promise<void> {
    // 1. Stop accepting new connections
    await this.pauseConnections();

    // 2. Download latest snapshot
    const snapshot = await r2.download('backups/redis/latest.rdb');

    // 3. Restore to Redis
    await redis.restore('dump', 0, snapshot.toString());

    // 4. Resume connections
    await this.resumeConnections();

    // 5. Warm cache
    await this.warmCache();
  }

  private async warmCache(): Promise<void> {
    // Reload frequently accessed data
    const hotKeys = await this.getHotKeys();
    for (const key of hotKeys) {
      await this.loadKeyToCache(key);
    }
  }
}
```

### Full System Recovery

```typescript
// lib/recovery/system-recovery.ts
class SystemRecovery {
  async fullRecovery(): Promise<RecoveryResult> {
    const steps: RecoveryStep[] = [];
    const startTime = Date.now();

    try {
      // Step 1: Database Recovery
      steps.push({ name: 'database', status: 'in_progress' });
      await this.recoverDatabase();
      steps[steps.length - 1].status = 'completed';

      // Step 2: Redis Recovery
      steps.push({ name: 'redis', status: 'in_progress' });
      await this.recoverRedis();
      steps[steps.length - 1].status = 'completed';

      // Step 3: Deploy Services
      steps.push({ name: 'deploy', status: 'in_progress' });
      await this.deployServices();
      steps[steps.length - 1].status = 'completed';

      // Step 4: Verify System
      steps.push({ name: 'verify', status: 'in_progress' });
      await this.verifySystem();
      steps[steps.length - 1].status = 'completed';

      // Step 5: Resume Traffic
      steps.push({ name: 'traffic', status: 'in_progress' });
      await this.resumeTraffic();
      steps[steps.length - 1].status = 'completed';

      return {
        success: true,
        duration: Date.now() - startTime,
        steps
      };
    } catch (error) {
      return {
        success: false,
        duration: Date.now() - startTime,
        steps,
        error: error.message
      };
    }
  }

  private async recoverDatabase(): Promise<void> {
    const recovery = new DatabaseRecovery();
    await recovery.recoverFromLatestBackup();
  }

  private async recoverRedis(): Promise<void> {
    const recovery = new RedisRecovery();
    await recovery.recoverFromSnapshot();
  }

  private async deployServices(): Promise<void> {
    // Deploy latest version
    await deploy('production');
  }

  private async verifySystem(): Promise<void> {
    // Health checks
    const health = await healthCheck();
    if (health.status !== 'healthy') {
      throw new Error('System health check failed');
    }
  }

  private async resumeTraffic(): Promise<void> {
    // Enable traffic routing
    await cloudflare.enableRouting('contentos.ai');
  }
}
```

## Failover Strategy

### Automatic Failover

```typescript
// lib/failover/auto-failover.ts
interface FailoverConfig {
  healthCheckInterval: number;    // ms
  failureThreshold: number;       // consecutive failures
  failoverTimeout: number;        // ms
  rollbackOnFailure: boolean;
}

class AutoFailover {
  private config: FailoverConfig;
  private failureCounts: Map<string, number> = new Map();

  constructor(config: FailoverConfig) {
    this.config = config;
    this.startHealthChecks();
  }

  private startHealthChecks(): void {
    setInterval(async () => {
      await this.checkHealth();
    }, this.config.healthCheckInterval);
  }

  private async checkHealth(): Promise<void> {
    const services = ['database', 'redis', 'ai-provider', 'queue'];

    for (const service of services) {
      const isHealthy = await this.checkServiceHealth(service);

      if (!isHealthy) {
        const failures = (this.failureCounts.get(service) || 0) + 1;
        this.failureCounts.set(service, failures);

        if (failures >= this.config.failureThreshold) {
          await this.triggerFailover(service);
        }
      } else {
        this.failureCounts.set(service, 0);
      }
    }
  }

  private async triggerFailover(service: string): Promise<void> {
    console.log(`Triggering failover for ${service}`);

    switch (service) {
      case 'database':
        await this.failoverDatabase();
        break;
      case 'redis':
        await this.failoverRedis();
        break;
      case 'ai-provider':
        await this.failoverAIProvider();
        break;
      case 'queue':
        await this.failoverQueue();
        break;
    }
  }

  private async failoverDatabase(): Promise<void> {
    // Switch to read replica
    await db.switchToReplica();

    // Update connection pool
    await db.updateConnectionPool({
      host: process.env.DB_REPLICA_HOST,
      port: 5432
    });

    // Notify admin
    await sendAlert({
      level: 'critical',
      title: 'Database failover triggered',
      message: 'Switched to read replica'
    });
  }

  private async failoverAIProvider(): Promise<void> {
    // Switch to backup provider
    const currentProvider = aiProvider.getCurrentProvider();
    const backupProvider = aiProvider.getBackupProvider(currentProvider);

    if (backupProvider) {
      await aiProvider.switchProvider(backupProvider);
    }
  }
}
```

### Failover Matrix

| Service | Primary | Failover | Recovery |
|---------|---------|----------|----------|
| PostgreSQL | Primary DB | Read Replica | Restore from backup |
| Redis | Primary | Replica | Rebuild from snapshot |
| AI (OpenAI) | OpenAI API | Anthropic API | Auto-switch |
| AI (Gemini) | Gemini API | OpenAI API | Auto-switch |
| Queue | Primary Redis | Secondary Redis | Rebuild queue |
| Storage | R2 Primary | R2 Backup Region | Manual sync |

## Incident Response

### Incident Severity Levels

| Level | Description | Response Time | Escalation |
|-------|-------------|---------------|------------|
| P1 | Complete system outage | 15 minutes | Immediate |
| P2 | Major feature unavailable | 30 minutes | 1 hour |
| P3 | Minor feature issue | 2 hours | 4 hours |
| P4 | Cosmetic issue | 24 hours | Next sprint |

### Incident Response Procedure

```typescript
// lib/incident/response.ts
interface Incident {
  id: string;
  severity: 'P1' | 'P2' | 'P3' | 'P4';
  title: string;
  description: string;
  status: 'open' | 'investigating' | 'identified' | 'monitoring' | 'resolved';
  assignee?: string;
  createdAt: string;
  updatedAt: string;
  timeline: IncidentEvent[];
}

class IncidentManager {
  async createIncident(data: Omit<Incident, 'id' | 'createdAt' | 'updatedAt' | 'timeline'>): Promise<Incident> {
    const incident: Incident = {
      ...data,
      id: generateId(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      timeline: []
    };

    // Store incident
    await db.incidents.create(incident);

    // Notify team
    await this.notifyTeam(incident);

    // Page on-call for P1/P2
    if (incident.severity === 'P1' || incident.severity === 'P2') {
      await this.pageOnCall(incident);
    }

    return incident;
  }

  async updateIncident(id: string, update: Partial<Incident>): Promise<void> {
    await db.incidents.update(id, {
      ...update,
      updatedAt: new Date().toISOString()
    });
  }

  async resolveIncident(id: string, resolution: string): Promise<void> {
    await this.updateIncident(id, {
      status: 'resolved',
      timeline: [
        {
          action: 'resolved',
          description: resolution,
          timestamp: new Date().toISOString()
        }
      ]
    });

    // Send resolution notification
    await this.notifyResolution(id);
  }

  private async notifyTeam(incident: Incident): Promise<void> {
    await sendSlack({
      channel: '#incidents',
      text: `🚨 New ${incident.severity} incident: ${incident.title}`,
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*${incident.severity} Incident*\n${incident.title}\n\n${incident.description}`
          }
        }
      ]
    });
  }

  private async pageOnCall(incident: Incident): Promise<void> {
    await pagerduty.createIncident({
      title: `[${incident.severity}] ${incident.title}`,
      description: incident.description,
      severity: incident.severity === 'P1' ? 'critical' : 'error'
    });
  }
}
```
