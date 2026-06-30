# Secrets Management

## Environment Variables

### Required Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db
DATABASE_SSL=require

# Authentication
JWT_SECRET_KEY=arn:aws:kms:...
JWT_PUBLIC_KEY=arn:aws:kms:...
REFRESH_TOKEN_SECRET=arn:aws:kms:...

# API Keys (stored in vault, not plaintext)
SOCIAL_MEDIA_API_KEY=arn:aws:secretsmanager:...
OPENAI_API_KEY=arn:aws:secretsmanager:...

# Encryption
ENCRYPTION_MASTER_KEY=arn:aws:kms:...
FIELD_ENCRYPTION_KEY=arn:aws:kms:...

# Services
REDIS_URL=rediss://host:6379
AWS_REGION=us-east-1
```

### Environment Variable Security Rules

1. **Never commit** `.env` files to version control
2. **Never log** environment variables in application logs
3. **Rotate** secrets on a regular schedule
4. **Use vault references** instead of plaintext values
5. **Separate** secrets per environment (dev, staging, prod)

## Vault Integration

### Supported Providers

```yaml
vault_providers:
  cloud:
    - aws_secrets_manager
    - aws_parameter_store
    - gcp_secret_manager
    - azure_key_vault

  self_hosted:
    - hashicorp_vault
    -Infisical
    - doppler

  local_development:
    - dotenv
    - direnv
    - docker_secrets
```

### Vault Access Pattern

```python
import hvac  # HashiCorp Vault client

class SecretsManager:
    def __init__(self, vault_url, vault_token):
        self.client = hvac.Client(url=vault_url, token=vault_token)

    def get_secret(self, path, key=None):
        """Retrieve secret from vault."""
        response = self.client.secrets.kv.v2.read_secret_version(
            path=path
        )
        data = response['data']['data']
        return data.get(key) if key else data

    def rotate_secret(self, path, key, new_value):
        """Rotate a secret value."""
        current = self.get_secret(path)
        current[key] = new_value
        self.client.secrets.kv.v2.create_or_update_secret(
            path=path,
            secret=current
        )
```

### Vault Configuration

```hcl
# Vault Policy for Application
path "secret/data/social-media-ai/*" {
  capabilities = ["read", "list"]
}

path "secret/data/social-media-ai/rotate/*" {
  capabilities = ["read", "write"]
}

path "transit/encrypt/*" {
  capabilities = ["update"]
}

path "transit/decrypt/*" {
  capabilities = ["update"]
}
```

## API Key Rotation

### Rotation Schedule

```yaml
rotation_policy:
  api_keys:
    automatic: true
    interval: 90 days
    grace_period: 24 hours

  oauth_tokens:
    automatic: true
    interval: 30 days
    grace_period: 1 hour

  database_passwords:
    automatic: true
    interval: 30 days
    grace_period: 5 minutes

  encryption_keys:
    automatic: true
    interval: 180 days
    grace_period: 7 days
```

### Rotation Process

```
1. Generate new secret
2. Update vault with new secret
3. Update application configuration
4. Grace period: both old and new secrets valid
5. Monitor for errors
6. Revoke old secret
7. Log rotation event
```

### Zero-Downtime Rotation

```python
class SecretRotator:
    def rotate_with_grace_period(self, secret_name, new_value):
        """Rotate secret with grace period for zero-downtime."""
        old_value = self.get_secret(secret_name)

        # Store both during grace period
        self.store_secret(f"{secret_name}_new", new_value)
        self.store_secret(f"{secret_name}_old", old_value)

        # Application reads _new, falls back to _old
        # After grace period, delete _old
```

## Secret Scanning Prevention

### Pre-commit Hooks

```bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
        args: ['--config', '.gitleaks.toml']

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

### Gitleaks Configuration

```toml
# .gitleaks.toml
[allowlist]
  description = "Global allowlist"
  paths = [
    '''vendor/.*''',
    '''node_modules/.*''',
    '''.env.example''',
  ]

[[rules]]
  id = "api-key"
  description = "API Key"
  regex = '''(?i)api[_-]?key['"\"\s]*[:=]['"\"\s]*['"\"a-zA-Z0-9]{32,}'''
  tags = ["api-key"]

[[rules]]
  id = "aws-access-key"
  description = "AWS Access Key"
  regex = '''(?i)(aws[_-]?access[_-]?key[_-]?id|AKIA)[=:]['"\"\s]*[A-Z0-9]{16}'''
  tags = ["aws"]

[[rules]]
  id = "private-key"
  description = "Private Key"
  regex = '''-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----'''
  tags = ["private-key"]
```

### CI/CD Secret Scanning

```yaml
# .github/workflows/secret-scan.yml
name: Secret Scanning
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}
```

## .env File Security

### .env.example Template

```bash
# Database
DATABASE_URL=
DATABASE_SSL=require

# Authentication
JWT_SECRET_KEY=
REFRESH_TOKEN_SECRET=

# API Keys
SOCIAL_MEDIA_API_KEY=
OPENAI_API_KEY=

# Encryption
ENCRYPTION_MASTER_KEY=
```

### .gitignore Configuration

```gitignore
# Environment files
.env
.env.local
.env.production
.env.staging
.env.development

# Secrets
*.pem
*.key
*.cert
*.p12
*.pfx
service-account*.json

# Configuration files with secrets
config/secrets.yml
config/credentials.yml
```

### .env File Permissions

```bash
# Set restrictive permissions
chmod 600 .env
chmod 600 .env.local
chmod 600 .env.production

# Ensure correct ownership
chown app_user:app_group .env*
```

## Secrets in Configuration

### Secure Configuration Pattern

```python
import os
from functools import lru_cache

class Settings:
    """Application settings with secure defaults."""

    @property
    def database_url(self):
        return self._get_secret('DATABASE_URL')

    @property
    def jwt_secret_key(self):
        return self._get_secret('JWT_SECRET_KEY')

    def _get_secret(self, key):
        """Get secret from vault or environment."""
        if self.vault_enabled:
            return self.vault.get_secret(key)
        value = os.environ.get(key)
        if not value:
            raise ValueError(f"Missing secret: {key}")
        return value
```

### Secrets in Docker

```yaml
# docker-compose.yml
services:
  app:
    secrets:
      - db_password
      - jwt_secret
    environment:
      DATABASE_URL_FILE: /run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
```

## Secrets in CI/CD

### GitHub Actions Secrets

```yaml
# Never echo secrets
- name: Deploy
  run: ./deploy.sh
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### CI/CD Security Rules

1. **Never print** secrets in logs
2. **Mask** secrets in output
3. **Use short-lived** credentials
4. **Limit** secret access to specific jobs
5. **Audit** secret access
6. **Rotate** CI/CD credentials regularly

## Emergency Procedures

### Secret Compromise Response

```
1. Identify compromised secret
2. Revoke compromised secret immediately
3. Generate new secret
4. Update all systems using the secret
5. Audit for unauthorized access
6. Review audit logs
7. Notify affected parties
8. Document incident
```

### Bulk Secret Rotation

```bash
# Emergency rotation script
#!/bin/bash
echo "Starting emergency rotation..."

# 1. Generate new secrets
NEW_JWT_SECRET=$(openssl rand -base64 64)
NEW_REFRESH_SECRET=$(openssl rand -base64 64)

# 2. Update vault
vault kv put secret/social-media-ai/jwt secret="$NEW_JWT_SECRET"
vault kv put secret/social-media-ai/refresh secret="$NEW_REFRESH_SECRET"

# 3. Update application (requires restart)
kubectl rollout restart deployment/social-media-ai

# 4. Verify
curl -f https://api.example.com/health || echo "Health check failed"
```

## Security Checklist

- [ ] No secrets in version control
- [ ] .env files in .gitignore
- [ ] Vault integration for production
- [ ] Secret scanning in CI/CD
- [ ] API key rotation automated
- [ ] Emergency rotation procedure documented
- [ ] Secrets not logged in application
- [ ] Docker secrets configured
- [ ] CI/CD secrets masked
- [ ] Access to secrets audited
