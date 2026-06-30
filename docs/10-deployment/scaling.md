# Scaling Strategy Guide

## Overview

This guide covers scaling strategies, including horizontal scaling, vertical scaling, database scaling, CDN scaling, and auto-scaling rules.

## Horizontal Scaling

### Horizontal Scaling Configuration

```typescript
// src/config/scaling.ts
export const scalingConfig = {
  horizontal: {
    enabled: true,
    minInstances: 2,
    maxInstances: 10,
    targetCPU: 70,
    targetMemory: 80,
    scaleUpCooldown: 300,
    scaleDownCooldown: 600,
  },
  
  loadBalancing: {
    algorithm: 'round-robin',
    healthCheckInterval: 30,
    healthCheckTimeout: 5,
    unhealthyThreshold: 3,
    healthyThreshold: 2,
  },
  
  sessionAffinity: {
    enabled: false,
    cookieName: 'session-affinity',
    cookieTTL: 3600,
  },
};
```

### Kubernetes Horizontal Pod Autoscaler

```yaml
# k8s/hpa.yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: social-media-ai-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: social-media-ai
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 600
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
```

### Load Balancer Configuration

```yaml
# k8s/service.yml
apiVersion: v1
kind: Service
metadata:
  name: social-media-ai-service
  namespace: production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'
spec:
  type: LoadBalancer
  selector:
    app: social-media-ai
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
  sessionAffinity: None
```

### Application-Level Load Balancing

```typescript
// src/services/load-balancer.ts
export class LoadBalancer {
  private instances: string[];
  private currentIndex: number = 0;

  constructor(instances: string[]) {
    this.instances = instances;
  }

  getNextInstance(): string {
    const instance = this.instances[this.currentIndex];
    this.currentIndex = (this.currentIndex + 1) % this.instances.length;
    return instance;
  }

  getHealthyInstances(): string[] {
    // Filter instances based on health checks
    return this.instances.filter(instance => this.isHealthy(instance));
  }

  private isHealthy(instance: string): boolean {
    // Implement health check logic
    return true;
  }
}
```

## Vertical Scaling

### Vertical Scaling Configuration

```typescript
// src/config/vertical-scaling.ts
export const verticalScalingConfig = {
  cpu: {
    request: '500m',
    limit: '2000m',
    requestsPerCore: 1000,
  },
  
  memory: {
    request: '512Mi',
    limit: '2048Mi',
    requestsPerGB: 1000,
  },
  
  storage: {
    request: '10Gi',
    limit: '100Gi',
    iops: 3000,
    throughput: 125,
  },
  
  scaling: {
    enabled: true,
    maxCPU: '4000m',
    maxMemory: '8192Mi',
    maxStorage: '500Gi',
  },
};
```

### Kubernetes Resource Limits

```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: social-media-ai
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: social-media-ai
  template:
    metadata:
      labels:
        app: social-media-ai
    spec:
      containers:
        - name: social-media-ai
          image: social-media-ai:latest
          resources:
            requests:
              cpu: "500m"
              memory: "512Mi"
            limits:
              cpu: "2000m"
              memory: "2048Mi"
          env:
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "3000"
          ports:
            - containerPort: 3000
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
```

### Resource Monitoring

```typescript
// src/monitoring/resources.ts
import { Gauge, Counter } from 'prom-client';

export const cpuUsage = new Gauge({
  name: 'cpu_usage_percent',
  help: 'CPU usage percentage',
  labelNames: ['instance'],
});

export const memoryUsage = new Gauge({
  name: 'memory_usage_percent',
  help: 'Memory usage percentage',
  labelNames: ['instance'],
});

export const diskUsage = new Gauge({
  name: 'disk_usage_percent',
  help: 'Disk usage percentage',
  labelNames: ['instance', 'mount'],
});

export const networkTraffic = new Counter({
  name: 'network_traffic_bytes_total',
  help: 'Network traffic in bytes',
  labelNames: ['instance', 'direction'],
});

export function collectMetrics(): void {
  // Collect CPU metrics
  const cpuPercent = process.cpuUsage();
  cpuUsage.set({ instance: process.env.HOSTNAME || 'unknown' }, cpuPercent.user / 1000000);

  // Collect memory metrics
  const memUsage = process.memoryUsage();
  const memPercent = (memUsage.heapUsed / memUsage.heapTotal) * 100;
  memoryUsage.set({ instance: process.env.HOSTNAME || 'unknown' }, memPercent);
}
```

## Database Scaling

### Database Scaling Configuration

```typescript
// src/config/database-scaling.ts
export const databaseScalingConfig = {
  connectionPooling: {
    min: 5,
    max: 20,
    idleTimeout: 30000,
    connectionTimeout: 2000,
  },
  
  readReplicas: {
    enabled: true,
    replicas: [
      { host: 'replica1.example.com', port: 5432 },
      { host: 'replica2.example.com', port: 5432 },
    ],
    loadBalancing: 'round-robin',
  },
  
  caching: {
    enabled: true,
    ttl: 3600,
    maxItems: 10000,
    strategy: 'lru',
  },
  
  sharding: {
    enabled: false,
    shardKey: 'userId',
    shards: 4,
  },
};
```

### Connection Pooling

```typescript
// src/config/database.ts
import { Pool } from 'pg';

export const databaseConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'social_media_ai',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

export const pool = new Pool(databaseConfig);

// Monitor connection pool
pool.on('connect', () => {
  console.log('New client connected to database');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

export async function getConnection() {
  const client = await pool.connect();
  try {
    return client;
  } finally {
    client.release();
  }
}
```

### Read Replicas

```typescript
// src/services/database-replicas.ts
import { Pool } from 'pg';

export class DatabaseReplicas {
  private writePool: Pool;
  private readPools: Pool[];

  constructor() {
    // Write pool (primary)
    this.writePool = new Pool({
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT || '5432'),
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      max: 10,
    });

    // Read pools (replicas)
    this.readPools = [
      new Pool({
        host: process.env.DB_REPLICA1_HOST,
        port: parseInt(process.env.DB_PORT || '5432'),
        database: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        max: 15,
      }),
      new Pool({
        host: process.env.DB_REPLICA2_HOST,
        port: parseInt(process.env.DB_PORT || '5432'),
        database: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        max: 15,
      }),
    ];
  }

  async writeQuery(text: string, params?: any[]): Promise<any> {
    const client = await this.writePool.connect();
    try {
      return await client.query(text, params);
    } finally {
      client.release();
    }
  }

  async readQuery(text: string, params?: any[]): Promise<any> {
    const pool = this.getReadPool();
    const client = await pool.connect();
    try {
      return await client.query(text, params);
    } finally {
      client.release();
    }
  }

  private getReadPool(): Pool {
    // Round-robin load balancing
    const index = Math.floor(Math.random() * this.readPools.length);
    return this.readPools[index];
  }
}
```

### Database Caching

```typescript
// src/services/database-cache.ts
import Redis from 'ioredis';

export class DatabaseCache {
  private redis: Redis;
  private defaultTTL: number;

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379'),
      password: process.env.REDIS_PASSWORD,
      maxRetriesPerRequest: 3,
    });
    
    this.defaultTTL = parseInt(process.env.CACHE_TTL || '3600');
  }

  async get<T>(key: string): Promise<T | null> {
    const cached = await this.redis.get(key);
    if (cached) {
      return JSON.parse(cached);
    }
    return null;
  }

  async set<T>(key: string, value: T, ttl?: number): Promise<void> {
    const serialized = JSON.stringify(value);
    const expiration = ttl || this.defaultTTL;
    await this.redis.setex(key, expiration, serialized);
  }

  async invalidate(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }

  async getOrSet<T>(key: string, fetchFn: () => Promise<T>, ttl?: number): Promise<T> {
    const cached = await this.get<T>(key);
    if (cached) {
      return cached;
    }

    const value = await fetchFn();
    await this.set(key, value, ttl);
    return value;
  }
}
```

## CDN Scaling

### CDN Configuration

```typescript
// src/config/cdn.ts
export const cdnConfig = {
  provider: 'cloudfront', // or 'cloudflare', 'akamai'
  
  distribution: {
    id: process.env.CDN_DISTRIBUTION_ID,
    domain: process.env.CDN_DOMAIN,
    origin: process.env.ORIGIN_DOMAIN,
  },
  
  caching: {
    defaultTTL: 86400, // 24 hours
    maxTTL: 31536000, // 1 year
    minTTL: 0,
    
    behaviors: [
      {
        pathPattern: '/static/*',
        ttl: 31536000, // 1 year
        compress: true,
      },
      {
        pathPattern: '/api/*',
        ttl: 0,
        compress: true,
      },
      {
        pathPattern: '/*',
        ttl: 86400, // 24 hours
        compress: true,
      },
    ],
  },
  
  security: {
    ssl: true,
    http2: true,
    waf: true,
    ddosProtection: true,
  },
  
  performance: {
    gzip: true,
    brotli: true,
    minification: true,
    imageOptimization: true,
  },
};
```

### CDN Implementation

```typescript
// src/services/cdn.ts
export class CDNService {
  private config: typeof cdnConfig;

  constructor() {
    this.config = cdnConfig;
  }

  getAssetUrl(path: string): string {
    return `${this.config.distribution.domain}${path}`;
  }

  getImageUrl(imagePath: string, options: ImageOptions = {}): string {
    const { width, height, quality = 80, format = 'auto' } = options;
    
    let url = `${this.config.distribution.domain}${imagePath}`;
    
    const params = new URLSearchParams();
    if (width) params.append('w', width.toString());
    if (height) params.append('h', height.toString());
    params.append('q', quality.toString());
    params.append('f', format);
    
    return `${url}?${params.toString()}`;
  }

  async purgeCache(paths: string[]): Promise<void> {
    // Implement CDN cache purge
    console.log(`Purging cache for paths: ${paths}`);
  }

  async purgeAll(): Promise<void> {
    // Implement full cache purge
    console.log('Purging all cache');
  }
}

interface ImageOptions {
  width?: number;
  height?: number;
  quality?: number;
  format?: 'auto' | 'webp' | 'jpeg' | 'png';
}
```

### CDN Headers

```typescript
// src/middleware/cdn-headers.ts
import { Request, Response, NextFunction } from 'express';

export function cdnHeaders(req: Request, res: Response, next: NextFunction) {
  // Set CDN-specific headers
  res.setHeader('X-CDN-Provider', 'cloudfront');
  res.setHeader('X-Cache-Status', 'MISS');
  
  // Set caching headers
  if (req.path.startsWith('/static/')) {
    res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
  } else if (req.path.startsWith('/api/')) {
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  } else {
    res.setHeader('Cache-Control', 'public, max-age=86400');
  }
  
  // Set compression headers
  res.setHeader('Content-Encoding', 'gzip');
  
  next();
}
```

## Auto-Scaling Rules

### Auto-Scaling Configuration

```yaml
# k8s/autoscaler.yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: social-media-ai-autoscaler
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: social-media-ai
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: 1000
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60
        - type: Pods
          value: 4
          periodSeconds: 60
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
        - type: Pods
          value: 2
          periodSeconds: 60
      selectPolicy: Min
```

### Auto-Scaling Rules

```typescript
// src/config/auto-scaling.ts
export const autoScalingRules = {
  scaleUp: [
    {
      metric: 'cpu_utilization',
      threshold: 70,
      duration: 60,
      action: 'add pods',
      amount: 2,
      cooldown: 300,
    },
    {
      metric: 'memory_utilization',
      threshold: 80,
      duration: 60,
      action: 'add pods',
      amount: 1,
      cooldown: 300,
    },
    {
      metric: 'request_rate',
      threshold: 1000,
      duration: 60,
      action: 'add pods',
      amount: 2,
      cooldown: 300,
    },
    {
      metric: 'error_rate',
      threshold: 5,
      duration: 60,
      action: 'add pods',
      amount: 1,
      cooldown: 300,
    },
  ],
  
  scaleDown: [
    {
      metric: 'cpu_utilization',
      threshold: 30,
      duration: 300,
      action: 'remove pods',
      amount: 1,
      cooldown: 600,
    },
    {
      metric: 'memory_utilization',
      threshold: 40,
      duration: 300,
      action: 'remove pods',
      amount: 1,
      cooldown: 600,
    },
    {
      metric: 'request_rate',
      threshold: 100,
      duration: 300,
      action: 'remove pods',
      amount: 1,
      cooldown: 600,
    },
  ],
  
  minInstances: 2,
  maxInstances: 20,
  
  scalingSchedule: {
    peakHours: {
      start: 9,
      end: 17,
      minInstances: 5,
    },
    offPeakHours: {
      start: 0,
      end: 6,
      minInstances: 2,
    },
  },
};
```

### Auto-Scaling Implementation

```typescript
// src/services/auto-scaler.ts
import { logger } from '../logger';

export class AutoScaler {
  private rules: typeof autoScalingRules;
  private currentInstances: number;
  private lastScaleTime: Date;

  constructor() {
    this.rules = autoScalingRules;
    this.currentInstances = this.rules.minInstances;
    this.lastScaleTime = new Date();
  }

  async evaluateScaling(metrics: ScalingMetrics): Promise<ScalingAction | null> {
    const now = new Date();
    const timeSinceLastScale = now.getTime() - this.lastScaleTime.getTime();

    // Check scale up rules
    for (const rule of this.rules.scaleUp) {
      if (this.shouldScaleUp(rule, metrics, timeSinceLastScale)) {
        return {
          action: 'scale_up',
          amount: rule.amount,
          reason: `${rule.metric} exceeded ${rule.threshold}%`,
        };
      }
    }

    // Check scale down rules
    for (const rule of this.rules.scaleDown) {
      if (this.shouldScaleDown(rule, metrics, timeSinceLastScale)) {
        return {
          action: 'scale_down',
          amount: rule.amount,
          reason: `${rule.metric} below ${rule.threshold}%`,
        };
      }
    }

    return null;
  }

  async executeScaling(action: ScalingAction): Promise<void> {
    logger.info('Executing scaling action', action);

    if (action.action === 'scale_up') {
      this.currentInstances = Math.min(
        this.currentInstances + action.amount,
        this.rules.maxInstances
      );
    } else if (action.action === 'scale_down') {
      this.currentInstances = Math.max(
        this.currentInstances - action.amount,
        this.rules.minInstances
      );
    }

    this.lastScaleTime = new Date();
    logger.info('Scaling completed', {
      newInstances: this.currentInstances,
      action: action.action,
    });
  }

  private shouldScaleUp(rule: ScalingRule, metrics: ScalingMetrics, timeSinceLastScale: number): boolean {
    const metricValue = this.getMetricValue(rule.metric, metrics);
    return (
      metricValue > rule.threshold &&
      timeSinceLastScale > rule.cooldown * 1000
    );
  }

  private shouldScaleDown(rule: ScalingRule, metrics: ScalingMetrics, timeSinceLastScale: number): boolean {
    const metricValue = this.getMetricValue(rule.metric, metrics);
    return (
      metricValue < rule.threshold &&
      timeSinceLastScale > rule.cooldown * 1000
    );
  }

  private getMetricValue(metric: string, metrics: ScalingMetrics): number {
    switch (metric) {
      case 'cpu_utilization':
        return metrics.cpuUtilization;
      case 'memory_utilization':
        return metrics.memoryUtilization;
      case 'request_rate':
        return metrics.requestRate;
      case 'error_rate':
        return metrics.errorRate;
      default:
        return 0;
    }
  }
}

interface ScalingMetrics {
  cpuUtilization: number;
  memoryUtilization: number;
  requestRate: number;
  errorRate: number;
}

interface ScalingAction {
  action: 'scale_up' | 'scale_down';
  amount: number;
  reason: string;
}

interface ScalingRule {
  metric: string;
  threshold: number;
  duration: number;
  action: string;
  amount: number;
  cooldown: number;
}
```

## Running Scaling Commands

### Commands

```bash
# Check current scaling status
npm run scaling:status

# Scale horizontally
npm run scaling:horizontal -- --instances 5

# Scale vertically
npm run scaling:vertical -- --cpu 2000m --memory 4096Mi

# Enable auto-scaling
npm run scaling:auto -- --enable

# Disable auto-scaling
npm run scaling:auto -- --disable

# View scaling metrics
npm run scaling:metrics
```

### CI/CD Integration

```yaml
# .github/workflows/scaling.yml
name: Scaling Management

on:
  workflow_dispatch:
    inputs:
      action:
        description: 'Scaling action'
        required: true
        type: choice
        options:
          - status
          - scale-up
          - scale-down
          - enable-auto
          - disable-auto

jobs:
  scaling:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Check scaling status
        if: github.event.inputs.action == 'status'
        run: npm run scaling:status
        
      - name: Scale up
        if: github.event.inputs.action == 'scale-up'
        run: npm run scaling:horizontal -- --instances 5
        
      - name: Scale down
        if: github.event.inputs.action == 'scale-down'
        run: npm run scaling:horizontal -- --instances 2
        
      - name: Enable auto-scaling
        if: github.event.inputs.action == 'enable-auto'
        run: npm run scaling:auto -- --enable
        
      - name: Disable auto-scaling
        if: github.event.inputs.action == 'disable-auto'
        run: npm run scaling:auto -- --disable
```

## Best Practices

### 1. Monitoring
- Monitor key metrics
- Set up alerts
- Track scaling events
- Review performance

### 2. Planning
- Plan for peak loads
- Consider cost implications
- Test scaling procedures
- Document processes

### 3. Automation
- Implement auto-scaling
- Use infrastructure as code
- Automate deployment
- Monitor automatically

### 4. Optimization
- Optimize resource usage
- Cache frequently accessed data
- Use load balancing
- Optimize database queries

### 5. Cost Management
- Monitor costs
- Right-size instances
- Use spot instances
- Optimize storage