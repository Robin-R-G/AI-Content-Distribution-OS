# OWASP Top 10 Compliance

## A01: Broken Access Control

### Risks
- Unauthorized access to other users' data
- Privilege escalation
- IDOR (Insecure Direct Object References)

### Mitigations

```yaml
access_control:
  rbac:
    enabled: true
    enforced_at: api_gateway

  resource_ownership:
    validated: true
    query_filter: "WHERE user_id = ?"

  idor_prevention:
    uuids: true  # Use UUIDs instead of sequential IDs
    ownership_check: true
    audit_log: true

  api_endpoint_protection:
    - path: /api/users/{id}
      method: GET
      require_auth: true
      require_ownership: true

    - path: /api/admin/users
      method: GET
      require_auth: true
      require_role: admin
```

### Testing

```bash
# Test IDOR
curl -H "Authorization: Bearer $TOKEN_A" /api/users/user_b_id

# Test privilege escalation
curl -H "Authorization: Bearer $USER_TOKEN" /api/admin/users
```

## A02: Cryptographic Failures

### Risks
- Weak encryption algorithms
- Hardcoded keys
- Insufficient key rotation

### Mitigations

```yaml
encryption:
  at_rest:
    algorithm: AES-256-GCM
    key_management: aws_kms

  transit:
    protocol: TLS 1.3
    min_version: TLS 1.2
    hsts: true

  hashing:
    passwords: argon2id
    general: SHA-256

  key_rotation:
    automatic: true
    interval: 90 days
```

### Checklist

- [ ] TLS 1.3 enforced
- [ ] AES-256 for at-rest encryption
- [ ] No hardcoded secrets
- [ ] Key rotation automated
- [ ] Strong cipher suites only

## A03: Injection

### SQL Injection Prevention

```python
# Parameterized queries
cursor.execute(
    "SELECT * FROM users WHERE email = %s",
    (email,)
)

# ORM usage (SQLAlchemy)
user = session.query(User).filter(User.email == email).first()

# Never
cursor.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

### XSS Prevention

```python
# Output encoding
from markupsafe import escape

rendered = escape(user_input)

# Content Security Policy
CSP = "default-src 'self'; script-src 'self'"

# Context-aware encoding
# HTML context: HTML entity encoding
# JavaScript context: JavaScript string encoding
# URL context: URL encoding
# CSS context: CSS encoding
```

### CSRF Protection

```yaml
csrf:
  enabled: true
  token_name: _csrf
  cookie:
    name: CSRF_TOKEN
    secure: true
    httpOnly: true
    sameSite: strict

  protected_methods:
    - POST
    - PUT
    - PATCH
    - DELETE
```

### Command Injection Prevention

```python
# Never use shell=True with user input
subprocess.run(
    ["ffmpeg", "-i", input_file],
    shell=False  # Always False
)

# Sanitize filenames
import re
safe_filename = re.sub(r'[^\w\-.]', '', user_filename)
```

## A04: Insecure Design

### Secure Design Principles

```yaml
design_principles:
  - defense_in_depth: true
  - least_privilege: true
  - secure_by_default: true
  - separation_of_duties: true
  - fail_secure: true
```

### Threat Modeling

```
1. Identify assets (user data, API keys, content)
2. Identify entry points (API, webhooks, integrations)
3. Identify trust boundaries (user ↔ system, system ↔ third-party)
4. Identify threats (STRIDE model)
5. Define mitigations
6. Verify mitigations
```

### Security Requirements

```yaml
security_requirements:
  authentication:
    - multi_factor: true
    - password_policy: strong
    - session_management: secure

  authorization:
    - rbac: true
    - resource_ownership: true
    - audit_trail: true

  data_protection:
    - encryption_at_rest: true
    - encryption_in_transit: true
    - field_level_encryption: true
```

## A05: Security Misconfiguration

### Secure Defaults

```yaml
defaults:
  debug: false
  verbose_errors: false
  stack_traces: false
  admin_enabled: false
  cors_origins: []
  tls_version: 1.3
```

### Configuration Checklist

```yaml
server:
  - remove_default_pages: true
  - disable_directory_listing: true
  - hide_server_version: true
  - security_headers: true

database:
  - default_password_changed: true
  - unnecessary_databases_removed: true
  - least_privilege_user: true

cloud:
  - public_buckets: false
  - encryption_enabled: true
  - logging_enabled: true
  - mfa_enabled: true
```

### Regular Audits

```bash
# Check for misconfigurations
nmap -sV --script ssl-enum-ciphers example.com
nikto -h example.com
testssl.sh example.com
```

## A06: Vulnerable Components

### Dependency Management

```yaml
dependency_scanning:
  tools:
    - dependabot
    - snyk
    - safety

  schedule:
    - daily: critical vulnerabilities
    - weekly: all dependencies
    - monthly: version updates

  policy:
    - no_critical: true
    - no_high: true
    - patch_within: 7 days
```

### SBOM (Software Bill of Materials)

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "components": [
    {
      "name": "express",
      "version": "4.18.2",
      "purl": "npm:express@4.18.2",
      "licenses": ["MIT"]
    }
  ]
}
```

## A07: Authentication Failures

### Secure Authentication

```yaml
authentication:
  password_policy:
    min_length: 12
    complexity: true
    breached_check: true
    history: 12

  account_lockout:
    max_attempts: 5
    lockout_duration: 15 minutes
    progressive_delays: true

  mfa:
    available: true
    required_for:
      - admin
      - sensitive_operations

  session:
    timeout: 30 minutes
    absolute_timeout: 24 hours
    regenerate_on_login: true
```

### Prevention

- [ ] No default credentials
- [ ] No weak passwords allowed
- [ ] Account lockout after failures
- [ ] Secure password recovery
- [ ] MFA available

## A08: Data Integrity Failures

### CI/CD Integrity

```yaml
ci_cd:
  signed_commits: true
  signed_artifacts: true
  verified_builds: true

  dependencies:
    lock_files: true
    checksums_verified: true

  deployment:
    signed_releases: true
    integrity_checks: true
```

### Data Validation

```python
# Schema validation
from pydantic import BaseModel, validator

class ContentInput(BaseModel):
    title: str
    body: str

    @validator('title')
    def validate_title(cls, v):
        if len(v) > 200:
            raise ValueError('Title too long')
        return v.strip()
```

## A09: Logging Failures

### Audit Logging

```yaml
audit_logging:
  events:
    - authentication.success
    - authentication.failure
    - authorization.granted
    - authorization.denied
    - data.create
    - data.read
    - data.update
    - data.delete
    - admin.action
    - system.error

  log_fields:
    - timestamp
    - user_id
    - action
    - resource
    - ip_address
    - user_agent
    - result
    - correlation_id
```

### Log Security

```yaml
log_security:
  tamper_proof: true
  encryption: true
  retention: 1 year
  access_control: true

  sensitive_fields:
    - password
    - token
    - api_key
    - ssn
    - credit_card
```

## A10: SSRF

### SSRF Prevention

```python
import ipaddress
from urllib.parse import urlparse

def validate_url(url):
    """Validate URL to prevent SSRF."""
    parsed = urlparse(url)

    # Only allow HTTP/HTTPS
    if parsed.scheme not in ('http', 'https'):
        raise ValueError("Invalid scheme")

    # Block internal IPs
    ip = socket.gethostbyname(parsed.hostname)
    if ipaddress.ip_address(ip).is_private:
        raise ValueError("Internal IP not allowed")

    # Block metadata endpoints
    blocked = [
        '169.254.169.254',
        'metadata.google.internal',
        '100.100.100.200'
    ]
    if parsed.hostname in blocked:
        raise ValueError("Blocked endpoint")

    return url
```

### Allowlist Approach

```yaml
ssrf_protection:
  allowed_domains:
    - api.socialmedia.com
    - cdn.socialmedia.com

  blocked_ip_ranges:
    - 10.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16
    - 169.254.0.0/16

  blocked_endpoints:
    - 169.254.169.254
    - metadata.google.internal
    - 100.100.100.200
```

## Compliance Summary

| Category | Status | Priority |
|----------|--------|----------|
| A01: Broken Access Control | Implemented | Critical |
| A02: Cryptographic Failures | Implemented | Critical |
| A03: Injection | Implemented | Critical |
| A04: Insecure Design | In Progress | High |
| A05: Security Misconfiguration | Implemented | High |
| A06: Vulnerable Components | Implemented | High |
| A07: Authentication Failures | Implemented | Critical |
| A08: Data Integrity Failures | Implemented | Medium |
| A09: Logging Failures | Implemented | Medium |
| A10: SSRF | Implemented | High |
