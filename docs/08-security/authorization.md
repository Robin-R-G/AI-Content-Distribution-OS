# Authorization Security

## RBAC Implementation

### Role Hierarchy

```
super_admin
  └── admin
       └── manager
            └── content_creator
                 └── viewer
```

### Default Roles

```yaml
roles:
  viewer:
    description: Read-only access
    permissions:
      - content:read
      - analytics:read
      - profile:read

  content_creator:
    description: Create and manage own content
    inherits: viewer
    permissions:
      - content:create
      - content:update
      - content:delete (own only)
      - social:post (own accounts)
      - media:upload

  manager:
    description: Manage team content and analytics
    inherits: content_creator
    permissions:
      - content:delete (team)
      - analytics:export
      - social:manage (team accounts)
      - team:invite
      - team:remove

  admin:
    description: Full platform management
    inherits: manager
    permissions:
      - admin:users
      - admin:billing
      - admin:settings
      - admin:audit_log
      - content:delete (all)

  super_admin:
    description: System-wide administration
    inherits: admin
    permissions:
      - system:config
      - system:secrets
      - system:rotate_keys
      - admin:roles
```

### Custom Permissions Format

```
{resource}:{action}[:{scope}]

Examples:
  content:create
  content:read
  content:update
  content:delete
  content:delete:own        # Own resources only
  content:delete:team       # Team resources only
  analytics:read
  analytics:export
  social:post
  social:manage
  admin:users
  admin:billing
```

## Permission Validation

### Middleware Stack

```
Request → Rate Limiter → Auth Middleware → RBAC Middleware → Handler
                              ↓                    ↓
                        Verify JWT          Check Permissions
                              ↓                    ↓
                        Attach User        Deny if unauthorized
```

### Permission Check Algorithm

```python
def check_permission(user, required_permission):
    # 1. Check if user has the permission directly
    if required_permission in user.permissions:
        return True

    # 2. Check role hierarchy
    for role in user.roles:
        if role_has_permission(role, required_permission):
            return True

    # 3. Check resource-level permissions
    resource = extract_resource(required_permission)
    if check_resource_permission(user, resource):
        return True

    return False
```

### Resource-Level Access Control

```yaml
resource_rules:
  content:
    own:
      - content:create
      - content:read:own
      - content:update:own
      - content:delete:own
    team:
      - content:read:team
      - content:update:team
      - content:delete:team
    all:
      - content:read:all
      - content:update:all
      - content:delete:all

  social_accounts:
    own:
      - social:read:own
      - social:post:own
    team:
      - social:read:team
      - social:post:team
    all:
      - social:read:all
      - social:post:all
```

### Resource Ownership Validation

```python
def is_resource_owner(user, resource):
    """Check if user owns or has access to the resource."""
    if resource.user_id == user.id:
        return True

    if resource.team_id in user.team_ids:
        if user_has_permission(user, f"{resource.type}:read:team"):
            return True

    if user_has_permission(user, f"{resource.type}:read:all"):
        return True

    return False
```

## API Key Scoping

### Key Types

```yaml
api_key_types:
  read_only:
    description: Read-only access to specific endpoints
    permissions:
      - content:read
      - analytics:read
    rate_limit: 100/hour

  read_write:
    description: Read and write access
    permissions:
      - content:read
      - content:create
      - content:update
    rate_limit: 1000/hour

  full_access:
    description: Full access to all endpoints
    permissions:
      - "*"
    rate_limit: 10000/hour

  webhook:
    description: Webhook-specific access
    permissions:
      - webhook:receive
    rate_limit: 5000/hour
```

### API Key Validation

```
1. Extract API key from header (X-API-Key) or query parameter
2. Look up key in database
3. Verify key is not revoked
4. Check key expiration
5. Validate key scopes against requested endpoint
6. Check rate limits
7. Log access
```

### Key Rotation

```
Rotation Policy:
  - API keys: Rotate every 90 days
  - Webhook secrets: Rotate every 180 days
  - Service keys: Rotate every 365 days

Rotation Process:
  1. Generate new key
  2. Make new key active
  3. Grace period: 24 hours (both keys valid)
  4. Revoke old key
  5. Notify user of rotation
```

## OAuth Scope Enforcement

### Scope Mapping

```yaml
scope_mapping:
  openid:
    - user:profile
  profile:
    - user:profile
    - user:email
  email:
    - user:email
  content:read:
    - content:read
  content:write:
    - content:create
    - content:update
  social:post:
    - social:post
  analytics:read:
    - analytics:read
  admin:
    - admin:*
```

### Scope Validation

```python
def validate_oauth_scope(requesting_scopes, required_scopes):
    """Validate that requested scopes cover required permissions."""
    granted = set()

    for scope in requesting_scopes:
        if scope in scope_mapping:
            granted.update(scope_mapping[scope])

    return required_scopes.issubset(granted)
```

### Scope Negotiation

```
Client requests scopes → Server validates against allowed scopes
                       → Server grants subset of allowed scopes
                       → Token issued with granted scopes
                       → Client must handle reduced permissions
```

## Attribute-Based Access Control (ABAC)

### Attributes

```yaml
user_attributes:
  - department: marketing, engineering, finance
  - level: junior, senior, lead, manager, director
  - clearance: public, internal, confidential, secret
  - location: us, eu, apac

resource_attributes:
  - sensitivity: public, internal, confidential, secret
  - owner_team: string
  - classification: content, analytics, user_data

environment_attributes:
  - time_of_day: business_hours, off_hours
  - ip_range: internal, external, vpn
  - device_trusted: true, false
```

### ABAC Policy Examples

```yaml
policies:
  - name: "confidential_content_access"
    effect: deny
    subjects:
      - clearance: [public, internal]
    resources:
      - sensitivity: confidential
    action: read

  - name: "off_hours_restricted"
    effect: deny
    subjects:
      - department: [marketing, finance]
    resources:
      - sensitivity: [confidential, secret]
    environment:
      - time_of_day: off_hours
    action: "*"
```

## Denial and Error Handling

### Authorization Error Response

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to perform this action",
    "required_permission": "content:delete:all",
    "your_permissions": ["content:create", "content:read"]
  }
}
```

### Security Logging

```
Log authorization failures with:
  - User ID
  - Requested resource
  - Required permission
  - User's actual permissions
  - Request details (method, path, IP)
  - Timestamp
  - Correlation ID
```

## Security Checklist

- [ ] RBAC roles defined and documented
- [ ] Permission inheritance implemented correctly
- [ ] Resource-level access control enforced
- [ ] API keys scoped and rotatable
- [ ] OAuth scopes validated
- [ ] ABAC policies for sensitive data
- [ ] Authorization failures logged
- [ ] No permission escalation possible
- [ ] Role changes require admin approval
- [ ] Audit trail for all access decisions
