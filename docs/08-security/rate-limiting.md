# Rate Limiting Security

## Rate Limit Architecture

### Implementation Strategy

```
Client → CDN (Cloudflare) → Load Balancer → API Gateway → Application
                ↓                ↓                ↓
           Bot Detection   Rate Limiting    Auth + Rate Limit
```

### Rate Limiting Layers

| Layer | Scope | Purpose |
|-------|-------|---------|
| CDN | Global | DDoS protection, bot filtering |
| Load Balancer | Per-IP | Connection limiting |
| API Gateway | Per-user/endpoint | Business logic limits |
| Application | Per-request | Resource protection |

## Per-Endpoint Limits

### API Endpoint Configuration

```yaml
rate_limits:
  authentication:
    /api/auth/login:
      limit: 5
      window: 15 minutes
      action: block

    /api/auth/register:
      limit: 3
      window: 1 hour
      action: block

    /api/auth/forgot-password:
      limit: 3
      window: 1 hour
      action: block

  content:
    /api/content/create:
      limit: 100
      window: 1 hour
      action: throttle

    /api/content/read:
      limit: 1000
      window: 1 hour
      action: throttle

    /api/content/delete:
      limit: 50
      window: 1 hour
      action: block

  social:
    /api/social/post:
      limit: 20
      window: 1 hour
      action: block

    /api/social/accounts:
      limit: 10
      window: 1 hour
      action: throttle

  analytics:
    /api/analytics/query:
      limit: 100
      window: 1 hour
      action: throttle

    /api/analytics/export:
      limit: 10
      window: 24 hours
      action: block
```

### Rate Limit Response

```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests",
    "retry_after": 300,
    "limit": 100,
    "remaining": 0,
    "reset": "2024-01-15T11:00:00Z"
  }
}
```

### Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1700003600
X-RateLimit-Window: 3600
Retry-After: 300
```

## Per-User Limits

### User Tier Limits

```yaml
user_tiers:
  free:
    api_calls: 1000/hour
    content_create: 10/hour
    social_posts: 5/day
    storage: 100MB

  pro:
    api_calls: 10000/hour
    content_create: 100/hour
    social_posts: 50/day
    storage: 10GB

  business:
    api_calls: 100000/hour
    content_create: 1000/hour
    social_posts: 500/day
    storage: 100GB

  enterprise:
    api_calls: unlimited
    content_create: unlimited
    social_posts: unlimited
    storage: unlimited
```

### User-Level Rate Limiting

```python
class UserRateLimiter:
    def __init__(self, redis_client):
        self.redis = redis_client

    def check_limit(self, user_id, endpoint, limit, window):
        """Check if user has exceeded rate limit."""
        key = f"rate_limit:{user_id}:{endpoint}"
        current = self.redis.incr(key)

        if current == 1:
            self.redis.expire(key, window)

        return {
            'allowed': current <= limit,
            'limit': limit,
            'remaining': max(0, limit - current),
            'reset': self.redis.ttl(key)
        }
```

## Per-IP Limits

### IP-Based Limits

```yaml
ip_limits:
  anonymous:
    requests_per_minute: 60
    requests_per_hour: 1000
    concurrent_connections: 10

  authenticated:
    requests_per_minute: 120
    requests_per_hour: 5000
    concurrent_connections: 20

  api_key:
    requests_per_minute: 600
    requests_per_hour: 50000
    concurrent_connections: 50
```

### IP Reputation Scoring

```yaml
ip_reputation:
  factors:
    - geo_location:
        high_risk_countries: [list]
        penalty: 0.2

    - vpn_detection:
        is_vpn: true
        penalty: 0.3

    - proxy_detection:
        is_proxy: true
        penalty: 0.4

    - tor_detection:
        is_tor: true
        penalty: 0.5

    - datacenter_detection:
        is_datacenter: true
        penalty: 0.3

  thresholds:
    block: 0.8
    challenge: 0.5
    allow: 0.0
```

## DDoS Protection

### Cloudflare Configuration

```yaml
cloudflare_ddos:
  l7_protection:
    enabled: true
    sensitivity: medium
    action: managed_challenge

  rate_limiting:
    - expression: "http.request.uri.path eq '/api/*'"
      action: "challenge"
      rate: 1000
      period: 60

  waf_rules:
    - rule: "ddos_protection"
      action: "block"
      score_threshold: 100

  bot_management:
    enabled: true
    fight_mode: true
    js_challenge: true
```

### DDoS Mitigation Strategies

```
Volumetric Attacks:
  - Cloudflare Spectrum
  - BGP Flowspec
  - Blackhole routing (last resort)

Application Layer Attacks:
  - Rate limiting
  - CAPTCHA challenges
  - Behavioral analysis
  - Fingerprinting

Protocol Attacks:
  - SYN cookies
  - Connection rate limiting
  - TCP proxy
```

## Bot Detection

### Bot Scoring System

```python
class BotDetector:
    def analyze_request(self, request):
        """Analyze request for bot characteristics."""
        score = 0

        # Check User-Agent
        if self.is_suspicious_ua(request.user_agent):
            score += 30

        # Check request patterns
        if self.detects_automation(request):
            score += 25

        # Check JavaScript execution
        if not request.js_executed:
            score += 20

        # Check mouse/keyboard patterns
        if self.detects_no_human_input(request):
            score += 15

        # Check header consistency
        if self.inconsistent_headers(request):
            score += 10

        return {
            'score': score,
            'is_bot': score >= 50,
            'confidence': min(score / 100, 1.0)
        }
```

### Bot Detection Rules

```yaml
detection_rules:
  user_agent:
    - pattern: "bot|crawler|spider|scraper"
      score: 30
    - pattern: "python-requests|curl|wget"
      score: 40
    - missing: true
      score: 50

  headers:
    - missing: ["Accept-Language"]
      score: 20
    - missing: ["Accept-Encoding"]
      score: 20
    - inconsistent: true
      score: 15

  behavior:
    - rapid_requests: true
      score: 25
    - no_mouse_movement: true
      score: 20
    - no_scroll: true
      score: 15
    - direct_url_access: true
      score: 10
```

## CAPTCHA Integration

### CAPTCHA Providers

```yaml
captcha_providers:
  primary: turnstile  # Cloudflare Turnstile (invisible)
  fallback: recaptcha  # Google reCAPTCHA v3

  configuration:
    turnstile:
      site_key: ${TURNSTILE_SITE_KEY}
      secret_key: ${TURNSTILE_SECRET_KEY}
      action: login
      threshold: 0.5

    recaptcha:
      site_key: ${RECAPTCHA_SITE_KEY}
      secret_key: ${RECAPTCHA_SECRET_KEY}
      threshold: 0.3
```

### CAPTCHA Trigger Conditions

```yaml
captcha_triggers:
  - failed_attempts: 3
    action: turnstile
  - suspicious_ip: true
    action: turnstile
  - new_device: true
    action: turnstile
  - high_risk_action: true
    action: recaptcha
  - api_abuse_detected: true
    action: recaptcha
```

### CAPTCHA Verification Flow

```
1. Client encounters CAPTCHA challenge
2. Client solves CAPTCHA (invisible or interactive)
3. Client submits CAPTCHA token with request
4. Server verifies token with provider
5. Server checks score against threshold
6. If passed: process request
7. If failed: return 403 with retry option
```

## Rate Limiting Implementation

### Redis-Based Rate Limiting

```python
import redis
import time

class RedisRateLimiter:
    def __init__(self, redis_client):
        self.redis = redis_client

    def is_rate_limited(self, key, limit, window):
        """Sliding window rate limiting."""
        now = time.time()
        window_start = now - window

        # Remove old entries
        self.redis.zremrangebyscore(key, 0, window_start)

        # Count requests in window
        count = self.redis.zcard(key)

        if count >= limit:
            return True, limit - count, self.redis.zrange(key, 0, 0, withscores=True)[0][1]

        # Add current request
        self.redis.zadd(key, {str(now): now})
        self.redis.expire(key, window)

        return False, limit - count - 1, now + window
```

### Distributed Rate Limiting

```python
class DistributedRateLimiter:
    def __init__(self, redis_cluster):
        self.redis = redis_cluster

    def check_distributed_limit(self, user_id, limit, window):
        """Rate limiting across multiple servers."""
        key = f"rate:{user_id}"
        lua_script = """
        local current = redis.call('INCR', KEYS[1])
        if current == 1 then
            redis.call('EXPIRE', KEYS[1], ARGV[1])
        end
        return current
        """

        current = self.redis.eval(lua_script, 1, key, window)
        return current <= limit
```

## Security Checklist

- [ ] Per-endpoint rate limits configured
- [ ] Per-user limits based on tier
- [ ] Per-IP limits enforced
- [ ] DDoS protection enabled (Cloudflare)
- [ ] Bot detection active
- [ ] CAPTCHA for suspicious requests
- [ ] Rate limit headers returned
- [ ] Graceful degradation under load
- [ ] Monitoring and alerting configured
- [ ] Emergency rate limiting procedures
