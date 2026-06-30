# API Security

## Input Validation

### Validation Strategy

```yaml
validation_strategy:
  layer_1: "Schema validation (Pydantic/Joi)"
  layer_2: "Business logic validation"
  layer_3: "Database constraint validation"

  principle: "Never trust user input"
  default_action: "Reject on validation failure"
```

### Pydantic Validation (Python)

```python
from pydantic import BaseModel, validator, constr
from typing import Optional
import re

class ContentCreate(BaseModel):
    title: constr(min_length=1, max_length=200)
    body: constr(min_length=1, max_length=10000)
    tags: Optional[list[str]] = []
    scheduled_at: Optional[datetime] = None

    @validator('title')
    def validate_title(cls, v):
        # Strip HTML tags
        v = re.sub(r'<[^>]+>', '', v)
        # Check for script injection
        if re.search(r'<script|javascript:|on\w+\s*=', v, re.I):
            raise ValueError('Invalid title content')
        return v.strip()

    @validator('body')
    def validate_body(cls, v):
        # Sanitize HTML
        v = re.sub(r'<script.*?</script>', '', v, flags=re.DOTALL|re.I)
        return v

    @validator('tags')
    def validate_tags(cls, v):
        if len(v) > 10:
            raise ValueError('Maximum 10 tags allowed')
        return [tag.lower().strip() for tag in v]
```

### Express.js Validation (Node.js)

```javascript
const Joi = require('joi');

const contentSchema = Joi.object({
  title: Joi.string()
    .min(1)
    .max(200)
    .pattern(/^[a-zA-Z0-9\s\-.,!?]+$/)
    .required()
    .messages({
      'string.pattern.base': 'Title contains invalid characters'
    }),
  body: Joi.string()
    .min(1)
    .max(10000)
    .required(),
  tags: Joi.array()
    .items(Joi.string().max(30))
    .max(10)
    .optional(),
  scheduled_at: Joi.date()
    .min('now')
    .optional()
});

// Middleware
function validate(schema) {
  return (req, res, next) => {
    const { error } = schema.validate(req.body, { abortEarly: false });
    if (error) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          details: error.details.map(d => d.message)
        }
      });
    }
    next();
  };
}
```

## Output Encoding

### Encoding Strategy

```yaml
encoding_strategy:
  html_context: "HTML entity encoding"
  javascript_context: "JavaScript string encoding"
  url_context: "URL encoding"
  css_context: "CSS encoding"
  json_context: "JSON encoding"
```

### Implementation

```python
from markupsafe import escape
import html
import json

class OutputEncoder:
    def encode_html(self, value):
        """HTML entity encoding."""
        return html.escape(value, quote=True)

    def encode_javascript(self, value):
        """JavaScript string encoding."""
        return json.dumps(value)

    def encode_url(self, value):
        """URL encoding."""
        from urllib.parse import quote
        return quote(value, safe='')

    def encode_json(self, value):
        """JSON encoding."""
        return json.dumps(value, ensure_ascii=True)
```

### Content Security

```python
def sanitize_for_display(content, context='html'):
    """Sanitize content for display."""
    encoder = OutputEncoder()

    if context == 'html':
        return encoder.encode_html(content)
    elif context == 'javascript':
        return encoder.encode_javascript(content)
    elif context == 'url':
        return encoder.encode_url(content)
    elif context == 'json':
        return encoder.encode_json(content)
    else:
        return content
```

## SQL Injection Prevention

### Parameterized Queries

```python
# CORRECT - Parameterized query
cursor.execute(
    "SELECT * FROM users WHERE email = %s AND status = %s",
    (email, status)
)

# CORRECT - ORM usage
user = session.query(User).filter(
    User.email == email,
    User.status == status
).first()

# INCORRECT - String formatting (NEVER DO THIS)
cursor.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

### Stored Procedures

```sql
-- Safe stored procedure
CREATE OR REPLACE FUNCTION get_user_by_email(p_email VARCHAR)
RETURNS TABLE(id UUID, email VARCHAR, name VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.email, u.name
    FROM users u
    WHERE u.email = p_email;
END;
$$ LANGUAGE plpgsql;
```

### Query Builder Safety

```python
# SQLAlchemy - safe by default
from sqlalchemy import and_

query = session.query(User).filter(
    and_(
        User.email == email,
        User.status == status
    )
)

# Raw query with parameters
cursor.execute(
    "SELECT * FROM users WHERE email = :email AND status = :status",
    {"email": email, "status": status}
)
```

## XSS Prevention

### Types of XSS

```yaml
xss_types:
  reflected:
    description: "Input reflected in response"
    prevention: "Output encoding"

  stored:
    description: "Input stored and rendered later"
    prevention: "Input validation + Output encoding"

  dom_based:
    description: "DOM manipulation in client"
    prevention: "Safe DOM APIs + CSP"
```

### Prevention Implementation

```python
import bleach

class XSSPrevention:
    def __init__(self):
        self.allowed_tags = ['p', 'b', 'i', 'u', 'em', 'strong', 'a', 'br']
        self.allowed_attrs = {'a': ['href', 'title']}
        self.allowed_protocols = ['http', 'https']

    def sanitize_html(self, content):
        """Sanitize HTML content."""
        return bleach.clean(
            content,
            tags=self.allowed_tags,
            attributes=self.allowed_attrs,
            protocols=self.allowed_protocols
        )

    def sanitize_for_template(self, content):
        """Sanitize content for template rendering."""
        from markupsafe import Markup, escape
        sanitized = self.sanitize_html(content)
        return Markup(sanitized)
```

### CSP Nonce

```python
import secrets

def render_with_nonce(template, context):
    """Render template with CSP nonce."""
    nonce = secrets.token_hex(16)
    context['nonce'] = nonce

    headers = {
        'Content-Security-Policy': f"script-src 'nonce-{nonce}'"
    }

    return render_template(template, context), headers
```

## CSRF Protection

### Token-Based Protection

```python
import secrets
from functools import wraps

class CSRFProtection:
    def __init__(self, app):
        self.app = app
        self.secret_key = app.config['SECRET_KEY']

    def generate_token(self):
        """Generate CSRF token."""
        return secrets.token_hex(32)

    def validate_token(self, token, stored_token):
        """Validate CSRF token."""
        return secrets.compare_digest(token, stored_token)

    def protect(self, f):
        """Decorator to protect routes."""
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if request.method in ('POST', 'PUT', 'DELETE', 'PATCH'):
                token = request.form.get('_csrf') or \
                        request.headers.get('X-CSRF-Token')
                stored_token = session.get('csrf_token')

                if not token or not stored_token or \
                   not self.validate_token(token, stored_token):
                    abort(403)

            return f(*args, **kwargs)
        return decorated_function
```

### SameSite Cookies

```python
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
```

## Request Signing

### HMAC Signature

```python
import hmac
import hashlib
import time

class RequestSigner:
    def __init__(self, secret_key):
        self.secret_key = secret_key.encode()

    def sign_request(self, method, path, body, timestamp):
        """Sign request with HMAC."""
        message = f"{method}\n{path}\n{timestamp}\n{body}"
        signature = hmac.new(
            self.secret_key,
            message.encode(),
            hashlib.sha256
        ).hexdigest()
        return signature

    def verify_request(self, method, path, body, timestamp, signature):
        """Verify request signature."""
        # Check timestamp (5-minute window)
        if abs(time.time() - int(timestamp)) > 300:
            return False

        expected = self.sign_request(method, path, body, timestamp)
        return hmac.compare_digest(signature, expected)
```

### API Key Signing

```python
class APIKeySigner:
    def __init__(self):
        self.key_cache = {}

    def sign_request(self, api_key, request_data):
        """Sign request with API key."""
        # Derive signing key from API key
        signing_key = self.derive_signing_key(api_key)

        # Create signature
        message = json.dumps(request_data, sort_keys=True)
        signature = hmac.new(
            signing_key.encode(),
            message.encode(),
            hashlib.sha256
        ).hexdigest()

        return {
            'X-API-Key': api_key,
            'X-Signature': signature,
            'X-Timestamp': str(int(time.time()))
        }

    def derive_signing_key(self, api_key):
        """Derive signing key from API key."""
        return hashlib.sha256(
            f"{api_key}:signing".encode()
        ).hexdigest()
```

## Rate Limiting

### Per-Endpoint Rate Limits

```yaml
rate_limits:
  authentication:
    /api/auth/login:
      limit: 5
      window: 900  # 15 minutes

    /api/auth/register:
      limit: 3
      window: 3600  # 1 hour

  api:
    default:
      limit: 1000
      window: 3600  # 1 hour

    /api/content:
      limit: 100
      window: 3600

    /api/analytics:
      limit: 50
      window: 3600
```

### Rate Limit Headers

```python
def add_rate_limit_headers(response, limit, remaining, reset):
    """Add rate limit headers to response."""
    response.headers['X-RateLimit-Limit'] = str(limit)
    response.headers['X-RateLimit-Remaining'] = str(remaining)
    response.headers['X-RateLimit-Reset'] = str(reset)
    return response
```

## API Security Checklist

- [ ] Input validation on all endpoints
- [ ] Output encoding implemented
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Request signing for webhooks
- [ ] Rate limiting configured
- [ ] API versioning
- [ ] Deprecation notices
- [ ] Error handling (no sensitive data in errors)
- [ ] Logging of all API access
- [ ] TLS 1.3 enforced
- [ ] CORS properly configured
