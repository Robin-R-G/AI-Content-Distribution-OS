# Security Headers

## Content-Security-Policy (CSP)

### Default Policy

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{random}';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self';
  connect-src 'self' https://api.example.com;
  frame-ancestors 'none';
  form-action 'self';
  base-uri 'self';
  object-src 'none';
  upgrade-insecure-requests;
```

### Strict CSP (High Security)

```
Content-Security-Policy:
  default-src 'none';
  script-src 'self' 'nonce-{random}' 'strict-dynamic';
  style-src 'self' 'nonce-{random}';
  img-src 'self' data: https://cdn.example.com;
  font-src 'self';
  connect-src 'self' https://api.example.com;
  frame-ancestors 'none';
  form-action 'self';
  base-uri 'self';
  object-src 'none';
  worker-src 'self';
  manifest-src 'self';
  upgrade-insecure-requests;
```

### CSP Implementation

```python
import secrets

def generate_csp_headers():
    """Generate CSP headers with random nonce."""
    nonce = secrets.token_hex(16)

    csp = (
        f"default-src 'self'; "
        f"script-src 'self' 'nonce-{nonce}'; "
        f"style-src 'self' 'unsafe-inline'; "
        f"img-src 'self' data: https:; "
        f"font-src 'self'; "
        f"connect-src 'self'; "
        f"frame-ancestors 'none'; "
        f"form-action 'self'; "
        f"base-uri 'self'; "
        f"object-src 'none'; "
        f"upgrade-insecure-requests"
    )

    return {
        'Content-Security-Policy': csp,
        'X-Content-Security-Policy': csp,
        'X-WebKit-CSP': csp
    }
```

## Strict-Transport-Security (HSTS)

### Configuration

```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

### Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| max-age | 63072000 | 2 years in seconds |
| includeSubDomains | true | Apply to all subdomains |
| preload | true | Include in browser preload list |

### Implementation

```python
def get_hsts_header():
    """Get HSTS header configuration."""
    return {
        'Strict-Transport-Security': 'max-age=63072000; includeSubDomains; preload'
    }
```

## X-Content-Type-Options

### Configuration

```
X-Content-Type-Options: nosniff
```

### Purpose

- Prevents MIME-type sniffing
- Forces browsers to respect Content-Type header
- Prevents drive-by download attacks

### Implementation

```python
def get_content_type_options():
    """Get X-Content-Type-Options header."""
    return {
        'X-Content-Type-Options': 'nosniff'
    }
```

## X-Frame-Options

### Configuration

```
X-Frame-Options: DENY
```

### Options

| Value | Description |
|-------|-------------|
| DENY | Prevent framing entirely |
| SAMEORIGIN | Allow framing from same origin |
| ALLOW-FROM | Allow framing from specific origin |

### Implementation

```python
def get_frame_options():
    """Get X-Frame-Options header."""
    return {
        'X-Frame-Options': 'DENY'
    }
```

## Referrer-Policy

### Configuration

```
Referrer-Policy: strict-origin-when-cross-origin
```

### Options

| Value | Description |
|-------|-------------|
| no-referrer | Never send referrer |
| no-referrer-when-downgrade | No referrer for HTTPS→HTTP |
| origin | Send origin only |
| origin-when-cross-origin | Origin for cross-origin, full for same-origin |
| same-origin | Send referrer for same-origin only |
| strict-origin | Send origin for cross-origin |
| strict-origin-when-cross-origin | Best balance of security and functionality |

### Implementation

```python
def get_referrer_policy():
    """Get Referrer-Policy header."""
    return {
        'Referrer-Policy': 'strict-origin-when-cross-origin'
    }
```

## Permissions-Policy

### Configuration

```
Permissions-Policy:
  accelerometer=(),
  autoplay=(),
  camera=(),
  encrypted-media=(),
  fullscreen=(self),
  geolocation=(),
  gyroscope=(),
  magnetometer=(),
  microphone=(),
  midi=(),
  payment=(),
  picture-in-picture=(),
  speaker=(),
  usb=(),
  web-share=(self)
```

### Purpose

- Controls browser features
- Prevents unauthorized feature access
- Reduces attack surface

### Implementation

```python
def get_permissions_policy():
    """Get Permissions-Policy header."""
    policy = (
        "accelerometer=(), "
        "autoplay=(), "
        "camera=(), "
        "encrypted-media=(), "
        "fullscreen=(self), "
        "geolocation=(), "
        "gyroscope=(), "
        "magnetometer=(), "
        "microphone=(), "
        "midi=(), "
        "payment=(), "
        "picture-in-picture=(), "
        "speaker=(), "
        "usb=(), "
        "web-share=(self)"
    )
    return {
        'Permissions-Policy': policy
    }
```

## CORS Configuration

### Strict CORS Policy

```yaml
cors_config:
  allowed_origins:
    - https://app.example.com
    - https://www.example.com

  allowed_methods:
    - GET
    - POST
    - PUT
    - DELETE
    - OPTIONS

  allowed_headers:
    - Authorization
    - Content-Type
    - X-Requested-With
    - X-API-Key

  exposed_headers:
    - X-RateLimit-Limit
    - X-RateLimit-Remaining
    - X-RateLimit-Reset

  allow_credentials: true
  max_age: 3600
  expose_headers: true
```

### Implementation

```python
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)

CORS(app, resources={
    r"/api/*": {
        "origins": ["https://app.example.com"],
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Authorization", "Content-Type"],
        "expose_headers": ["X-RateLimit-Limit"],
        "allow_credentials": True,
        "max_age": 3600
    }
})
```

### CORS Security Rules

```yaml
cors_security:
  never:
    - allow_all_origins: true
    - allow_credentials_with_wildcard: true
    - allow_all_headers: true
    - allow_all_methods: true

  always:
    - validate_origin: true
    - restrict_methods: true
    - restrict_headers: true
    - set_max_age: true
```

## Complete Security Headers

### Implementation

```python
class SecurityHeadersMiddleware:
    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        def custom_start_response(status, headers, exc_info=None):
            security_headers = {
                'Content-Security-Policy': self.get_csp(),
                'Strict-Transport-Security': 'max-age=63072000; includeSubDomains; preload',
                'X-Content-Type-Options': 'nosniff',
                'X-Frame-Options': 'DENY',
                'X-XSS-Protection': '1; mode=block',
                'Referrer-Policy': 'strict-origin-when-cross-origin',
                'Permissions-Policy': self.get_permissions_policy(),
                'Cache-Control': 'no-store, no-cache, must-revalidate',
                'Pragma': 'no-cache',
                'X-Permitted-Cross-Domain-Policies': 'none',
                'Cross-Origin-Embedder-Policy': 'require-corp',
                'Cross-Origin-Opener-Policy': 'same-origin',
                'Cross-Origin-Resource-Policy': 'same-origin'
            }

            headers.extend(security_headers.items())
            return start_response(status, headers, exc_info)

        return self.app(environ, custom_start_response)
```

### Header Summary

| Header | Value | Purpose |
|--------|-------|---------|
| Content-Security-Policy | Strict CSP | Prevent XSS |
| Strict-Transport-Security | max-age=63072000 | Force HTTPS |
| X-Content-Type-Options | nosniff | Prevent MIME sniffing |
| X-Frame-Options | DENY | Prevent clickjacking |
| Referrer-Policy | strict-origin-when-cross-origin | Control referrer |
| Permissions-Policy | Minimal permissions | Control features |
| Cache-Control | no-store | Prevent caching sensitive data |
| X-XSS-Protection | 1; mode=block | Legacy XSS protection |

## Testing

### Security Header Validation

```bash
# Check headers
curl -I https://example.com

# Use securityheaders.com
# https://securityheaders.com/?q=example.com

# Automated testing
python -m pytest tests/test_security_headers.py
```

### Test Implementation

```python
def test_security_headers(client):
    """Test all security headers are present."""
    response = client.get('/')

    assert 'Content-Security-Policy' in response.headers
    assert 'Strict-Transport-Security' in response.headers
    assert 'X-Content-Type-Options' in response.headers
    assert 'X-Frame-Options' in response.headers
    assert 'Referrer-Policy' in response.headers
    assert 'Permissions-Policy' in response.headers
    assert 'Cache-Control' in response.headers

    # Verify specific values
    assert response.headers['X-Content-Type-Options'] == 'nosniff'
    assert response.headers['X-Frame-Options'] == 'DENY'
```

## Security Checklist

- [ ] Content-Security-Policy configured
- [ ] Strict-Transport-Security enabled
- [ ] X-Content-Type-Options set
- [ ] X-Frame-Options configured
- [ ] Referrer-Policy set
- [ ] Permissions-Policy configured
- [ ] CORS properly restricted
- [ ] Cache-Control for sensitive data
- [ ] Headers tested and validated
- [ ] Regular header audits
