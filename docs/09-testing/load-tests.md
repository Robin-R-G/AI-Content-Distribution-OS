# Load Testing Guide

## Overview

Load testing evaluates system performance under expected and peak load conditions, ensuring the application can handle user traffic and maintain performance standards.

## k6 Scripts

### Basic Load Test

```javascript
// tests/load/basic-load.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const requestDuration = new Trend('request_duration');

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    errors: ['rate<0.1'],             // Error rate under 10%
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/posts');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'has data': (r) => JSON.parse(r.body).data !== undefined,
  });

  errorRate.add(response.status !== 200);
  requestDuration.add(response.timings.duration);

  sleep(1);
}
```

### Realistic User Flow

```javascript
// tests/load/user-flow.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';

const userFlows = new Counter('user_flows');

export const options = {
  scenarios: {
    browsing: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 50 },
        { duration: '10m', target: 50 },
        { duration: '5m', target: 0 },
      ],
    },
    posting: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 20 },
        { duration: '10m', target: 20 },
        { duration: '5m', target: 0 },
      ],
    },
  },
};

export default function () {
  const userType = __ITER % 2 === 0 ? 'browsing' : 'posting';
  
  if (userType === 'browsing') {
    browsingFlow();
  } else {
    postingFlow();
  }
}

function browsingFlow() {
  // Login
  const loginResponse = http.post('http://localhost:3000/api/auth/login', 
    JSON.stringify({
      email: 'testuser@example.com',
      password: 'password123',
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(loginResponse, {
    'login successful': (r) => r.status === 200,
  });

  const token = loginResponse.json('token');

  // Browse posts
  for (let i = 0; i < 5; i++) {
    const postsResponse = http.get('http://localhost:3000/api/posts', {
      headers: { Authorization: `Bearer ${token}` },
    });

    check(postsResponse, {
      'posts loaded': (r) => r.status === 200,
    });

    sleep(2);
  }
}

function postingFlow() {
  // Login
  const loginResponse = http.post('http://localhost:3000/api/auth/login',
    JSON.stringify({
      email: 'testposter@example.com',
      password: 'password123',
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  const token = loginResponse.json('token');

  // Create post
  const createPostResponse = http.post('http://localhost:3000/api/posts',
    JSON.stringify({
      title: `Load Test Post ${Date.now()}`,
      content: 'This is a load test post content.',
    }),
    {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
    }
  );

  check(createPostResponse, {
    'post created': (r) => r.status === 201,
  });

  userFlows.add(1);
  sleep(1);
}
```

### API Endpoint Testing

```javascript
// tests/load/api-endpoints.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const endpointMetrics = {};

const endpoints = [
  { method: 'GET', path: '/api/posts', name: 'Get Posts' },
  { method: 'GET', path: '/api/posts/1', name: 'Get Post' },
  { method: 'POST', path: '/api/posts', name: 'Create Post' },
  { method: 'PUT', path: '/api/posts/1', name: 'Update Post' },
  { method: 'DELETE', path: '/api/posts/1', name: 'Delete Post' },
  { method: 'GET', path: '/api/users/me', name: 'Get User' },
];

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '3m', target: 50 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    errors: ['rate<0.05'],
  },
};

export default function () {
  const token = login();
  
  endpoints.forEach(endpoint => {
    const startTime = Date.now();
    let response;

    const params = {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
    };

    switch (endpoint.method) {
      case 'GET':
        response = http.get(`http://localhost:3000${endpoint.path}`, params);
        break;
      case 'POST':
        response = http.post(`http://localhost:3000${endpoint.path}`, 
          JSON.stringify({ title: 'Test', content: 'Test' }), params);
        break;
      case 'PUT':
        response = http.put(`http://localhost:3000${endpoint.path}`,
          JSON.stringify({ title: 'Updated' }), params);
        break;
      case 'DELETE':
        response = http.del(`http://localhost:3000${endpoint.path}`, null, params);
        break;
    }

    const duration = Date.now() - startTime;
    
    check(response, {
      [`${endpoint.name} status is OK`]: (r) => r.status >= 200 && r.status < 300,
      [`${endpoint.name} response time OK`]: (r) => r.timings.duration < 1000,
    });

    if (!endpointMetrics[endpoint.name]) {
      endpointMetrics[endpoint.name] = new Trend(endpoint.name);
    }
    endpointMetrics[endpoint.name].add(duration);

    sleep(0.5);
  });
}

function login() {
  const response = http.post('http://localhost:3000/api/auth/login',
    JSON.stringify({
      email: 'loadtest@example.com',
      password: 'password123',
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  return response.json('token');
}
```

## Performance Benchmarks

### Benchmark Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Response Time (p50) | < 200ms | > 500ms |
| Response Time (p95) | < 500ms | > 1000ms |
| Response Time (p99) | < 1000ms | > 2000ms |
| Throughput | > 1000 req/s | < 500 req/s |
| Error Rate | < 0.1% | > 1% |
| CPU Usage | < 70% | > 90% |
| Memory Usage | < 80% | > 95% |

### Benchmark Test

```javascript
// tests/load/benchmark.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

const throughput = new Counter('throughput');
const latency = new Trend('latency');

export const options = {
  scenarios: {
    benchmark: {
      executor: 'constant-vus',
      vus: 100,
      duration: '5m',
    },
  },
  thresholds: {
    throughput: ['count>50000'],
    latency: ['p(95)<500'],
    http_req_duration: ['avg<200', 'p(95)<500', 'p(99)<1000'],
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/posts');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time acceptable': (r) => r.timings.duration < 1000,
  });

  throughput.add(1);
  latency.add(response.timings.duration);

  sleep(0.1);
}
```

## Scalability Testing

### Horizontal Scaling Test

```javascript
// tests/load/scalability.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  scenarios: {
    scaling_test: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 50 },   // Baseline
        { duration: '2m', target: 100 },  // Scale up
        { duration: '2m', target: 200 },  // Scale up more
        { duration: '2m', target: 500 },  // Peak load
        { duration: '2m', target: 200 },  // Scale down
        { duration: '2m', target: 100 },  // Scale down more
        { duration: '2m', target: 0 },    // Baseline
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.05'],
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/posts');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time acceptable': (r) => r.timings.duration < 2000,
  });

  errorRate.add(response.status !== 200);
  responseTime.add(response.timings.duration);

  sleep(1);
}
```

## Soak Testing

### Long Duration Test

```javascript
// tests/load/soak-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  scenarios: {
    soak_test: {
      executor: 'constant-vus',
      vus: 100,
      duration: '4h', // 4 hour soak test
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500'],
    errors: ['rate<0.01'],
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/posts');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time acceptable': (r) => r.timings.duration < 1000,
  });

  errorRate.add(response.status !== 200);
  responseTime.add(response.timings.duration);

  sleep(1);
}
```

## Threshold Definitions

### Performance Thresholds

```javascript
// tests/load/thresholds.js
export const thresholds = {
  // Response time thresholds
  http_req_duration: [
    'p(50)<200',   // 50% of requests under 200ms
    'p(95)<500',   // 95% of requests under 500ms
    'p(99)<1000',  // 99% of requests under 1000ms
    'avg<300',     // Average under 300ms
  ],

  // Error rate thresholds
  http_req_failed: ['rate<0.01'], // Less than 1% errors

  // Throughput thresholds
  http_reqs: ['count>10000'], // At least 10,000 requests

  // Custom metric thresholds
  api_response_time: ['p(95)<500'],
  database_query_time: ['p(95)<100'],
  cache_hit_rate: ['rate>0.8'], // 80% cache hit rate
};
```

## Running Load Tests

### k6 Commands

```bash
# Run basic load test
k6 run tests/load/basic-load.js

# Run with custom options
k6 run --vus 100 --duration 5m tests/load/basic-load.js

# Run with environment variables
k6 run -e BASE_URL=http://localhost:3000 tests/load/basic-load.js

# Run with output to InfluxDB
k6 run --out influxdb=http://localhost:8086/k6 tests/load/basic-load.js

# Run with JSON output
k6 run --out json=results.json tests/load/basic-load.js
```

### CI/CD Integration

```yaml
# .github/workflows/load-tests.yml
name: Load Tests

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM
  
  workflow_dispatch:
    inputs:
      vus:
        description: 'Number of virtual users'
        required: false
        default: '100'
      duration:
        description: 'Test duration'
        required: false
        default: '5m'

jobs:
  load:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install k6
        run: |
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D68
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6
          
      - name: Run load test
        run: |
          k6 run \
            --vus ${{ github.event.inputs.vus || '100' }} \
            --duration ${{ github.event.inputs.duration || '5m' }} \
            tests/load/basic-load.js
            
      - name: Upload results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: load-test-results
          path: results.json
```

## Best Practices

### 1. Test Environment
- Use production-like environment
- Isolate test data
- Monitor resource usage

### 2. Test Data
- Use realistic data volumes
- Clean up after tests
- Use unique data to avoid conflicts

### 3. Monitoring
- Monitor application metrics
- Monitor infrastructure metrics
- Set up alerts for anomalies

### 4. Analysis
- Analyze bottlenecks
- Review error patterns
- Compare with baseline metrics

### 5. Reporting
- Generate comprehensive reports
- Track performance over time
- Share results with stakeholders