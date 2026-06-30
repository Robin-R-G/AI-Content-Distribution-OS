# Production Deployment Guide

## Overview

This guide covers production deployment procedures, including pre-deployment checklists, deployment steps, post-deployment verification, feature flags, and blue-green deployment strategies.

## Pre-Deployment Checklist

### Code Readiness

```markdown
## Code Readiness Checklist

### Code Quality
- [ ] Code review completed by 2+ reviewers
- [ ] All automated tests passing
- [ ] Code coverage meets thresholds (80%+)
- [ ] No critical security vulnerabilities
- [ ] Performance benchmarks met

### Documentation
- [ ] API documentation updated
- [ ] Changelog updated
- [ ] README updated (if needed)
- [ ] Deployment guide updated

### Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] API tests passing
- [ ] UI tests passing
- [ ] Load tests completed
- [ ] Security tests completed
- [ ] Accessibility tests completed

### Dependencies
- [ ] All dependencies updated
- [ ] No known vulnerabilities
- [ ] Package lock file committed
- [ ] Docker images updated
```

### Infrastructure Readiness

```markdown
## Infrastructure Readiness Checklist

### Environment
- [ ] Production environment provisioned
- [ ] Auto-scaling configured
- [ ] Load balancer configured
- [ ] CDN configured
- [ ] SSL certificates valid

### Database
- [ ] Database backups configured
- [ ] Database replicas configured
- [ ] Connection pooling configured
- [ ] Indexes optimized
- [ ] Migrations tested

### Security
- [ ] Firewall rules configured
- [ ] WAF rules configured
- [ ] DDoS protection enabled
- [ ] Secrets management configured
- [ ] Access controls verified

### Monitoring
- [ ] Health checks configured
- [ ] Metrics dashboards created
- [ ] Alerting rules configured
- [ ] Log aggregation configured
- [ ] Error tracking configured
```

### Team Readiness

```markdown
## Team Readiness Checklist

### Communication
- [ ] Deployment window communicated
- [ ] Stakeholders notified
- [ ] Support team briefed
- [ ] Rollback plan documented

### On-Call
- [ ] On-call engineer assigned
- [ ] Escalation path defined
- [ ] Contact list updated
- [ ] War room (if needed) scheduled

### Training
- [ ] Team trained on new features
- [ ] Support team trained
- [ ] Documentation available
- [ ] FAQ prepared
```

## Deployment Steps

### Deployment Script

```bash
#!/bin/bash
# scripts/deploy-production.sh

set -e

echo "Starting production deployment..."

# 1. Pre-deployment checks
echo "Running pre-deployment checks..."
npm run pre-deploy

# 2. Build application
echo "Building application..."
npm run build:prod

# 3. Run tests
echo "Running tests..."
npm run test:smoke

# 4. Deploy to production
echo "Deploying to production..."
npm run deploy:prod

# 5. Run database migrations
echo "Running database migrations..."
npm run db:migrate:prod

# 6. Verify deployment
echo "Verifying deployment..."
npm run verify:prod

# 7. Run smoke tests
echo "Running smoke tests..."
npm run test:smoke:prod

# 8. Notify completion
echo "Deployment completed successfully!"
npm run notify:deploy
```

### Deployment Process

```markdown
## Production Deployment Process

### Phase 1: Preparation (T-30 minutes)
1. [ ] Final code review
2. [ ] Run full test suite
3. [ ] Verify staging deployment
4. [ ] Notify stakeholders
5. [ ] Assign on-call engineer

### Phase 2: Deployment (T-0)
1. [ ] Start deployment window
2. [ ] Deploy to production
3. [ ] Run database migrations
4. [ ] Verify deployment health
5. [ ] Run smoke tests

### Phase 3: Verification (T+15 minutes)
1. [ ] Monitor error rates
2. [ ] Monitor performance metrics
3. [ ] Verify user flows
4. [ ] Check integration points
5. [ ] Review logs

### Phase 4: Completion (T+30 minutes)
1. [ ] Confirm deployment successful
2. [ ] Update deployment log
3. [ ] Notify stakeholders of completion
4. [ ] Schedule post-deployment review
5. [ ] Update documentation
```

### Blue-Green Deployment

```typescript
// src/deployment/blue-green.ts
export class BlueGreenDeployment {
  private blueEnvironment: string;
  private greenEnvironment: string;
  private activeEnvironment: string;

  constructor() {
    this.blueEnvironment = process.env.BLUE_ENVIRONMENT || 'blue';
    this.greenEnvironment = process.env.GREEN_ENVIRONMENT || 'green';
    this.activeEnvironment = process.env.ACTIVE_ENVIRONMENT || 'blue';
  }

  async deploy(version: string): Promise<void> {
    const inactiveEnvironment = this.getInactiveEnvironment();
    
    console.log(`Deploying to ${inactiveEnvironment}...`);
    
    // Deploy to inactive environment
    await this.deployToEnvironment(inactiveEnvironment, version);
    
    // Run health checks
    await this.healthCheck(inactiveEnvironment);
    
    // Switch traffic
    await this.switchTraffic(inactiveEnvironment);
    
    // Update active environment
    this.activeEnvironment = inactiveEnvironment;
    
    console.log(`Deployment to ${inactiveEnvironment} completed`);
  }

  async rollback(): Promise<void> {
    const previousEnvironment = this.getInactiveEnvironment();
    
    console.log(`Rolling back to ${previousEnvironment}...`);
    
    // Switch traffic back
    await this.switchTraffic(previousEnvironment);
    
    // Update active environment
    this.activeEnvironment = previousEnvironment;
    
    console.log(`Rollback to ${previousEnvironment} completed`);
  }

  private getInactiveEnvironment(): string {
    return this.activeEnvironment === this.blueEnvironment
      ? this.greenEnvironment
      : this.blueEnvironment;
  }

  private async deployToEnvironment(env: string, version: string): Promise<void> {
    // Deploy to specific environment
    console.log(`Deploying ${version} to ${env}`);
  }

  private async healthCheck(env: string): Promise<void> {
    // Verify health of deployed environment
    console.log(`Running health checks on ${env}`);
  }

  private async switchTraffic(env: string): Promise<void> {
    // Switch traffic to new environment
    console.log(`Switching traffic to ${env}`);
  }
}
```

## Post-Deployment Verification

### Verification Script

```bash
#!/bin/bash
# scripts/verify-production.sh

set -e

echo "Running post-deployment verification..."

# 1. Health check
echo "Running health check..."
curl -f https://api.socialmediaai.com/health || exit 1

# 2. API endpoints
echo "Checking API endpoints..."
curl -f https://api.socialmediaai.com/api/posts || exit 1
curl -f https://api.socialmediaai.com/api/users/me || exit 1

# 3. Database connection
echo "Checking database connection..."
npm run verify:db || exit 1

# 4. Cache connection
echo "Checking cache connection..."
npm run verify:cache || exit 1

# 5. External services
echo "Checking external services..."
npm run verify:external || exit 1

echo "Post-deployment verification completed successfully!"
```

### Verification Checklist

```markdown
## Post-Deployment Verification Checklist

### Health Checks
- [ ] Application health endpoint responding
- [ ] Database connection healthy
- [ ] Cache connection healthy
- [ ] External services responding
- [ ] SSL certificates valid

### Functionality
- [ ] User login working
- [ ] Post creation working
- [ ] Comment system working
- [ ] Like functionality working
- [ ] Search functionality working

### Performance
- [ ] Response times within thresholds
- [ ] Error rates within thresholds
- [ ] Throughput within expectations
- [ ] Memory usage normal
- [ ] CPU usage normal

### Monitoring
- [ ] Metrics being collected
- [ ] Logs being aggregated
- [ ] Alerts configured
- [ ] Dashboards updated
- [ ] Error tracking working
```

## Feature Flags

### Feature Flag Configuration

```typescript
// src/config/features.ts
export const featureFlags = {
  // AI Features
  enableAIContentGeneration: {
    enabled: true,
    percentage: 100,
    environments: ['production', 'staging'],
  },
  
  enableAIRecommendations: {
    enabled: true,
    percentage: 50,
    environments: ['production'],
  },
  
  // UI Features
  enableNewPostEditor: {
    enabled: false,
    percentage: 0,
    environments: ['staging'],
  },
  
  enableDarkMode: {
    enabled: true,
    percentage: 100,
    environments: ['production', 'staging', 'development'],
  },
  
  // Performance Features
  enableCaching: {
    enabled: true,
    percentage: 100,
    environments: ['production', 'staging'],
  },
  
  enableCDN: {
    enabled: true,
    percentage: 100,
    environments: ['production'],
  },
};
```

### Feature Flag Service

```typescript
// src/services/feature-flag.service.ts
import { featureFlags } from '../config/features';

export class FeatureFlagService {
  private flags: Map<string, FeatureFlag> = new Map();

  constructor() {
    this.loadFlags();
  }

  private loadFlags(): void {
    for (const [key, value] of Object.entries(featureFlags)) {
      this.flags.set(key, value as FeatureFlag);
    }
  }

  isEnabled(feature: string, userId?: string): boolean {
    const flag = this.flags.get(feature);
    
    if (!flag) {
      return false;
    }

    // Check if feature is enabled
    if (!flag.enabled) {
      return false;
    }

    // Check environment
    if (!flag.environments.includes(process.env.NODE_ENV || 'development')) {
      return false;
    }

    // Check percentage rollout
    if (flag.percentage < 100 && userId) {
      const hash = this.hashUserId(userId);
      const percentage = hash % 100;
      return percentage < flag.percentage;
    }

    return true;
  }

  private hashUserId(userId: string): number {
    let hash = 0;
    for (let i = 0; i < userId.length; i++) {
      hash = ((hash << 5) - hash) + userId.charCodeAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash);
  }

  async updateFlag(feature: string, updates: Partial<FeatureFlag>): Promise<void> {
    const flag = this.flags.get(feature);
    
    if (flag) {
      this.flags.set(feature, { ...flag, ...updates });
    }
  }

  async getFlags(): Promise<Map<string, FeatureFlag>> {
    return this.flags;
  }
}
```

### Feature Flag Usage

```typescript
// Usage in components
import { FeatureFlagService } from '../services/feature-flag.service';

const featureFlagService = new FeatureFlagService();

// Check feature flag
if (featureFlagService.isEnabled('enableNewPostEditor', userId)) {
  // Show new editor
} else {
  // Show old editor
}

// In React component
const NewPostEditor = () => {
  const { user } = useAuth();
  const isNewEditorEnabled = featureFlagService.isEnabled('enableNewPostEditor', user.id);
  
  return isNewEditorEnabled ? <NewEditor /> : <OldEditor />;
};
```

## Rollback Procedures

### Automatic Rollback

```typescript
// src/deployment/rollback.ts
export class RollbackManager {
  async automaticRollback(reason: string): Promise<void> {
    console.log(`Initiating automatic rollback: ${reason}`);
    
    // 1. Stop traffic to current version
    await this.stopTraffic();
    
    // 2. Deploy previous version
    await this.deployPreviousVersion();
    
    // 3. Verify rollback
    await this.verifyRollback();
    
    // 4. Notify team
    await this.notifyTeam(reason);
    
    console.log('Automatic rollback completed');
  }

  async manualRollback(version: string): Promise<void> {
    console.log(`Initiating manual rollback to ${version}...`);
    
    // 1. Stop traffic
    await this.stopTraffic();
    
    // 2. Deploy specified version
    await this.deployVersion(version);
    
    // 3. Verify deployment
    await this.verifyDeployment();
    
    // 4. Resume traffic
    await this.resumeTraffic();
    
    console.log(`Manual rollback to ${version} completed`);
  }

  private async stopTraffic(): Promise<void> {
    console.log('Stopping traffic...');
  }

  private async deployPreviousVersion(): Promise<void> {
    console.log('Deploying previous version...');
  }

  private async deployVersion(version: string): Promise<void> {
    console.log(`Deploying version ${version}...`);
  }

  private async verifyRollback(): Promise<void> {
    console.log('Verifying rollback...');
  }

  private async verifyDeployment(): Promise<void> {
    console.log('Verifying deployment...');
  }

  private async resumeTraffic(): Promise<void> {
    console.log('Resuming traffic...');
  }

  private async notifyTeam(reason: string): Promise<void> {
    console.log(`Notifying team: ${reason}`);
  }
}
```

### Rollback Checklist

```markdown
## Rollback Checklist

### Pre-Rollback
- [ ] Identify issue requiring rollback
- [ ] Notify stakeholders
- [ ] Assign rollback lead
- [ ] Document rollback reason

### During Rollback
- [ ] Stop traffic to current version
- [ ] Deploy previous version
- [ ] Run database rollback (if needed)
- [ ] Verify deployment health
- [ ] Resume traffic

### Post-Rollback
- [ ] Verify application functionality
- [ ] Monitor for issues
- [ ] Document lessons learned
- [ ] Schedule post-mortem
- [ ] Update rollback procedures
```

## Deployment Monitoring

### Production Monitoring

```typescript
// src/monitoring/production.ts
export const productionMonitoring = {
  metrics: {
    enabled: true,
    endpoint: '/metrics',
    labels: {
      environment: 'production',
    },
  },
  
  logging: {
    level: 'info',
    format: 'json',
    transports: ['console', 'file', 'external'],
    retention: '30d',
  },
  
  tracing: {
    enabled: true,
    serviceName: 'social-media-ai-production',
    sampleRate: 0.1,
  },
  
  alerting: {
    enabled: true,
    rules: [
      {
        name: 'High Error Rate',
        condition: 'error_rate > 0.01',
        duration: '5m',
        severity: 'critical',
      },
      {
        name: 'High Response Time',
        condition: 'response_time_p95 > 500',
        duration: '5m',
        severity: 'warning',
      },
      {
        name: 'Low Availability',
        condition: 'availability < 99.9',
        duration: '5m',
        severity: 'critical',
      },
    ],
  },
};
```

### Health Check Endpoint

```typescript
// src/routes/health.ts
import { Router } from 'express';
import { healthCheck } from '../services/health.service';

const router = Router();

router.get('/health', async (req, res) => {
  try {
    const health = await healthCheck();
    
    if (health.status === 'healthy') {
      res.status(200).json(health);
    } else {
      res.status(503).json(health);
    }
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
    });
  }
});

router.get('/health/ready', async (req, res) => {
  try {
    const ready = await healthCheck.readiness();
    
    if (ready) {
      res.status(200).json({ status: 'ready' });
    } else {
      res.status(503).json({ status: 'not ready' });
    }
  } catch (error) {
    res.status(503).json({
      status: 'not ready',
      error: error.message,
    });
  }
});

router.get('/health/live', async (req, res) => {
  res.status(200).json({ status: 'alive' });
});

export default router;
```

## Running Production Commands

### Commands

```bash
# Deploy to production
npm run deploy:prod

# Verify production deployment
npm run verify:prod

# Run production smoke tests
npm run test:smoke:prod

# Rollback production
npm run rollback:prod

# Check production health
npm run health:prod

# View production logs
npm run logs:prod
```

### CI/CD Integration

```yaml
# .github/workflows/production.yml
name: Production Deployment

on:
  workflow_dispatch:
    inputs:
      action:
        description: 'Action to perform'
        required: true
        type: choice
        options:
          - deploy
          - rollback
          - verify

jobs:
  production:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Deploy to production
        if: github.event.inputs.action == 'deploy'
        run: npm run deploy:prod
        
      - name: Rollback production
        if: github.event.inputs.action == 'rollback'
        run: npm run rollback:prod
        
      - name: Verify production
        if: github.event.inputs.action == 'verify'
        run: npm run verify:prod
        
      - name: Run smoke tests
        run: npm run test:smoke:prod
```

## Best Practices

### 1. Deployment Safety
- Use blue-green deployments
- Implement feature flags
- Have rollback procedures ready
- Monitor during deployment

### 2. Verification
- Run comprehensive health checks
- Verify all critical paths
- Monitor error rates
- Check performance metrics

### 3. Communication
- Notify stakeholders before deployment
- Provide real-time updates
- Document all changes
- Share deployment status

### 4. Monitoring
- Monitor key metrics
- Set up alerts
- Review logs regularly
- Track deployment success

### 5. Continuous Improvement
- Conduct post-deployment reviews
- Document lessons learned
- Update procedures
- Share knowledge