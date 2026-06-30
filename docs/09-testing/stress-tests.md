# Stress Testing Guide

## Overview

Stress testing evaluates system behavior under extreme load conditions, identifying breaking points, recovery capabilities, and resource exhaustion limits.

## Breaking Point Analysis

### Finding System Limits

```javascript
// tests/stress/breaking-point.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');
const successfulRequests = new Counter('successful_requests');
const failedRequests = new Counter('failed_requests');

export const options = {
  scenarios: {
    stress_test: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 100 },   // Baseline
        { duration: '2m', target: 200 },   // Increase
        { duration: '2m', target: 400 },   // High load
        { duration: '2m', target: 600 },   // Very high
        { duration: '2m', target: 800 },   // Extreme
        { duration: '2m', target: 1000 },  // Breaking point
        { duration: '5m', target: 1000 },  // Sustain breaking point
        { duration: '2m', target: 0 },     // Recovery
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    errors: ['rate<0.1'],
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/posts');
  
  const isSuccess = response.status >= 200 && response.status < 300;
  
  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
    'response time acceptable': (r) => r.timings.duration < 5000,
  });

  errorRate.add(!isSuccess);
  responseTime.add(response.timings.duration);
  
  if (isSuccess) {
    successfulRequests.add(1);
  } else {
    failedRequests.add(1);
  }

  sleep(0.5);
}
```

### Breaking Point Metrics

```javascript
// tests/stress/breaking-point-metrics.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Trend, Rate } from 'k6/metrics';

const breakingPointMetrics = {
  maxConcurrentUsers: new Counter('max_concurrent_users'),
  responseTimeAtBreaking: new Trend('response_time_at_breaking'),
  errorRateAtBreaking: new Rate('error_rate_at_breaking'),
  throughputAtBreaking: new Counter('throughput_at_breaking'),
};

let maxSuccessfulVUs = 0;
let breakingPointReached = false;

export const options = {
  scenarios: {
    breaking_point: {
      executor: 'ramping-vus',
      stages: [
        { duration: '1m', target: 50 },
        { duration: '1m', target: 100 },
        { duration: '1m', target: 200 },
        { duration: '1m', target: 300 },
        { duration: '1m', target: 400 },
        { duration: '1m', target: 500 },
        { duration: '1m', target: 600 },
        { duration: '1m', target: 700 },
        { duration: '1m', target: 800 },
        { duration: '1m', target: 900 },
        { duration: '1m', target: 1000 },
      ],
    },
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/posts');
  
  const isSuccess = response.status >= 200 && response.status < 300;
  const currentVUs = __VU;
  
  if (isSuccess && currentVUs > maxSuccessfulVUs) {
    maxSuccessfulVUs = currentVUs;
    breakingPointMetrics.maxConcurrentUsers.add(currentVUs);
  }

  if (!breakingPointReached && response.timings.duration > 5000) {
    breakingPointReached = true;
    breakingPointMetrics.responseTimeAtBreaking.add(response.timings.duration);
    breakingPointMetrics.errorRateAtBreaking.add(1);
    console.log(`Breaking point reached at ${currentVUs} VUs`);
  }

  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
  });

  sleep(0.5);
}
```

## Recovery Testing

### System Recovery After Stress

```javascript
// tests/stress/recovery.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');
const recoveryTime = new Counter('recovery_time');

export const options = {
  scenarios: {
    stress_and_recovery: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 100 },   // Baseline
        { duration: '2m', target: 500 },   // Stress
        { duration: '2m', target: 1000 },  // Extreme stress
        { duration: '5m', target: 1000 },  // Sustain stress
        { duration: '1m', target: 0 },     // Stop all load
        { duration: '5m', target: 0 },     // Recovery period
        { duration: '2m', target: 100 },   // Post-recovery baseline
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.05'],
  },
};

let stressStartTime = 0;
let recoveryStartTime = 0;
let isRecovering = false;

export default function () {
  const currentVUs = __VU;
  
  // Detect stress phase
  if (currentVUs >= 500 && stressStartTime === 0) {
    stressStartTime = Date.now();
    console.log('Stress phase started');
  }
  
  // Detect recovery phase
  if (currentVUs === 0 && !isRecovering && stressStartTime > 0) {
    isRecovering = true;
    recoveryStartTime = Date.now();
    console.log('Recovery phase started');
  }

  const response = http.get('http://localhost:3000/api/posts');
  
  const isSuccess = response.status >= 200 && response.status < 300;
  
  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
    'response time acceptable': (r) => r.timings.duration < 2000,
  });

  errorRate.add(!isSuccess);
  responseTime.add(response.timings.duration);

  // Track recovery
  if (isRecovering && isSuccess) {
    const recoveryDuration = Date.now() - recoveryStartTime;
    recoveryTime.add(recoveryDuration);
    
    if (recoveryDuration > 60000) { // 1 minute
      console.log(`System recovered in ${recoveryDuration / 1000} seconds`);
      isRecovering = false;
    }
  }

  sleep(0.5);
}
```

### Recovery Metrics

```javascript
// tests/stress/recovery-metrics.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';

const recoveryMetrics = {
  timeToRecover: new Trend('time_to_recover'),
  errorRateDuringRecovery: new Trend('error_rate_during_recovery'),
  responseTimeDuringRecovery: new Trend('response_time_during_recovery'),
};

let stressStartTime = 0;
let recoveryStartTime = 0;
let isRecovering = false;
let errorsDuringRecovery = 0;
let requestsDuringRecovery = 0;

export const options = {
  scenarios: {
    recovery_test: {
      executor: 'ramping-vus',
      stages: [
        { duration: '1m', target: 100 },
        { duration: '2m', target: 1000 },
        { duration: '3m', target: 1000 },
        { duration: '1m', target: 0 },
        { duration: '5m', target: 0 },
      ],
    },
  },
};

export default function () {
  const currentVUs = __VU;
  
  if (currentVUs >= 500 && stressStartTime === 0) {
    stressStartTime = Date.now();
  }
  
  if (currentVUs === 0 && !isRecovering && stressStartTime > 0) {
    isRecovering = true;
    recoveryStartTime = Date.now();
  }

  const response = http.get('http://localhost:3000/api/posts');
  
  const isSuccess = response.status >= 200 && response.status < 300;
  
  if (isRecovering) {
    requestsDuringRecovery++;
    
    if (!isSuccess) {
      errorsDuringRecovery++;
    }
    
    const recoveryDuration = Date.now() - recoveryStartTime;
    recoveryMetrics.timeToRecover.add(recoveryDuration);
    recoveryMetrics.responseTimeDuringRecovery.add(response.timings.duration);
    
    if (requestsDuringRecovery > 0) {
      const errorRate = errorsDuringRecovery / requestsDuringRecovery;
      recoveryMetrics.errorRateDuringRecovery.add(errorRate);
    }
  }

  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
  });

  sleep(0.5);
}
```

## Resource Exhaustion Testing

### Memory Exhaustion

```javascript
// tests/stress/memory-exhaustion.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const memoryUsage = new Trend('memory_usage');

export const options = {
  scenarios: {
    memory_stress: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 100 },
        { duration: '2m', target: 200 },
        { duration: '2m', target: 300 },
        { duration: '2m', target: 400 },
        { duration: '2m', target: 500 },
        { duration: '5m', target: 500 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    errors: ['rate<0.1'],
  },
};

export default function () {
  // Make requests that consume memory
  const response = http.get('http://localhost:3000/api/posts?limit=1000');
  
  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
    'response time acceptable': (r) => r.timings.duration < 5000,
  });

  errorRate.add(response.status !== 200);
  
  // Monitor response time as proxy for memory pressure
  memoryUsage.add(response.timings.duration);

  sleep(0.5);
}
```

### CPU Exhaustion

```javascript
// tests/stress/cpu-exhaustion.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const cpuPressure = new Trend('cpu_pressure');

export const options = {
  scenarios: {
    cpu_stress: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 200 },
        { duration: '2m', target: 400 },
        { duration: '2m', target: 600 },
        { duration: '2m', target: 800 },
        { duration: '2m', target: 1000 },
        { duration: '5m', target: 1000 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<3000'],
    errors: ['rate<0.1'],
  },
};

export default function () {
  // Make CPU-intensive requests
  const response = http.post('http://localhost:3000/api/ai/generate',
    JSON.stringify({
      prompt: 'Generate a detailed analysis of market trends',
      maxTokens: 2000,
    }),
    {
      headers: { 'Content-Type': 'application/json' },
    }
  );
  
  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
  });

  errorRate.add(response.status !== 200);
  cpuPressure.add(response.timings.duration);

  sleep(0.5);
}
```

## Database Stress Testing

### Database Connection Stress

```javascript
// tests/stress/database-connections.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

const errorRate = new Rate('errors');
const dbResponseTime = new Trend('db_response_time');
const connectionErrors = new Counter('connection_errors');

export const options = {
  scenarios: {
    db_stress: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 100 },
        { duration: '2m', target: 200 },
        { duration: '2m', target: 300 },
        { duration: '2m', target: 400 },
        { duration: '2m', target: 500 },
        { duration: '5m', target: 500 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    errors: ['rate<0.05'],
  },
};

export default function () {
  // Make database-intensive requests
  const response = http.get('http://localhost:3000/api/posts/search?q=test&limit=100');
  
  const isSuccess = response.status >= 200 && response.status < 300;
  
  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
    'response time acceptable': (r) => r.timings.duration < 3000,
  });

  if (!isSuccess && response.status === 503) {
    connectionErrors.add(1);
  }

  errorRate.add(!isSuccess);
  dbResponseTime.add(response.timings.duration);

  sleep(0.5);
}
```

### Database Query Stress

```javascript
// tests/stress/database-queries.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const queryTime = new Trend('query_time');

export const options = {
  scenarios: {
    query_stress: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 50 },
        { duration: '2m', target: 100 },
        { duration: '2m', target: 150 },
        { duration: '2m', target: 200 },
        { duration: '5m', target: 200 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.05'],
  },
};

export default function () {
  // Complex database queries
  const endpoints = [
    '/api/posts?sort=created_at&order=desc&limit=50',
    '/api/posts?filter=trending&limit=20',
    '/api/users?search=john&limit=10',
    '/api/analytics?period=7d',
  ];

  const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  
  const response = http.get(`http://localhost:3000${endpoint}`);
  
  check(response, {
    'status is OK': (r) => r.status >= 200 && r.status < 300,
    'response time acceptable': (r) => r.timings.duration < 2000,
  });

  errorRate.add(response.status !== 200);
  queryTime.add(response.timings.duration);

  sleep(0.5);
}
```

## Running Stress Tests

### k6 Commands

```bash
# Run breaking point test
k6 run tests/stress/breaking-point.js

# Run recovery test
k6 run tests/stress/recovery.js

# Run with custom options
k6 run --vus 1000 --duration 10m tests/stress/breaking-point.js

# Run with environment variables
k6 run -e BASE_URL=http://localhost:3000 tests/stress/breaking-point.js

# Run with output to InfluxDB
k6 run --out influxdb=http://localhost:8086/k6 tests/stress/breaking-point.js
```

### CI/CD Integration

```yaml
# .github/workflows/stress-tests.yml
name: Stress Tests

on:
  schedule:
    - cron: '0 3 * * 1'  # Weekly on Monday at 3 AM
  
  workflow_dispatch:
    inputs:
      test_type:
        description: 'Test type'
        required: true
        default: 'breaking-point'
        type: choice
        options:
          - breaking-point
          - recovery
          - memory-exhaustion
          - cpu-exhaustion

jobs:
  stress:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install k6
        run: |
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D68
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6
          
      - name: Run stress test
        run: |
          k6 run tests/stress/${{ github.event.inputs.test_type || 'breaking-point' }}.js
            
      - name: Upload results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: stress-test-results
          path: results.json
```

## Best Practices

### 1. Test Environment
- Use production-like environment
- Monitor system resources
- Isolate test data

### 2. Test Design
- Start with baseline measurements
- Gradually increase load
- Monitor for breaking points

### 3. Monitoring
- Monitor application metrics
- Monitor infrastructure metrics
- Set up alerts for anomalies

### 4. Analysis
- Analyze breaking points
- Review error patterns
- Identify bottlenecks

### 5. Reporting
- Generate comprehensive reports
- Track performance over time
- Share results with stakeholders