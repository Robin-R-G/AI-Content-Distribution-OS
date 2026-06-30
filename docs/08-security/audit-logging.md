# Audit Logging

## What to Log

### Authentication Events

```yaml
authentication_events:
  success:
    - user_login
    - user_logout
    - password_change
    - mfa_enable
    - mfa_disable
    - oauth_callback

  failure:
    - login_failure
    - password_reset_request
    - account_locked
    - mfa_failure

  events:
    user_login:
      fields:
        - user_id
        - email
        - ip_address
        - user_agent
        - timestamp
        - session_id
        - authentication_method
        - mfa_used

    login_failure:
      fields:
        - email
        - ip_address
        - user_agent
        - timestamp
        - failure_reason
        - attempt_count
```

### Authorization Events

```yaml
authorization_events:
  - permission_granted
  - permission_denied
  - role_assigned
  - role_removed
  - api_key_created
  - api_key_revoked
  - oauth_scope_granted
  - oauth_scope_denied

  permission_denied:
    fields:
      - user_id
      - requested_resource
      - required_permission
      - user_permissions
      - ip_address
      - timestamp
```

### Data Events

```yaml
data_events:
  create:
    - content_created
    - profile_updated
    - settings_changed
    - api_key_created
    - social_account_connected

  read:
    - content_viewed
    - analytics_accessed
    - profile_viewed
    - data_exported

  update:
    - content_updated
    - profile_updated
    - settings_changed
    - password_changed
    - email_changed

  delete:
    - content_deleted
    - account_deleted
    - data_deleted
    - api_key_deleted

  events:
    content_created:
      fields:
        - user_id
        - content_id
        - content_type
        - timestamp
        - ip_address

    data_exported:
      fields:
        - user_id
        - export_type
        - data_categories
        - timestamp
        - file_size
```

### Administrative Events

```yaml
admin_events:
  - user_suspended
  - user_reinstated
  - billing_changed
  - settings_modified
  - security_setting_changed
  - api_limit_changed
  - plan_upgraded
  - plan_downgraded

  user_suspended:
    fields:
      - admin_user_id
      - target_user_id
      - reason
      - duration
      - timestamp
      - ip_address
```

### System Events

```yaml
system_events:
  - service_started
  - service_stopped
  - error_occurred
  - performance_degraded
  - security_alert
  - backup_completed
  - backup_failed
  - key_rotated
```

## Log Format

### Structured Log Format (JSON)

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "event_type": "authentication.success",
  "event_name": "user_login",
  "user_id": "usr_abc123",
  "session_id": "sess_xyz789",
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "resource": "/api/auth/login",
  "method": "POST",
  "status": "success",
  "details": {
    "authentication_method": "password",
    "mfa_used": true,
    "device_type": "web"
  },
  "correlation_id": "req_def456",
  "service": "auth-service",
  "version": "1.0.0"
}
```

### Log Schema

```yaml
log_schema:
  required_fields:
    - timestamp: "ISO 8601 format"
    - level: "INFO|WARN|ERROR|FATAL"
    - event_type: "category.action"
    - event_name: "specific_event"
    - correlation_id: "unique_request_id"

  optional_fields:
    - user_id: "authenticated user"
    - session_id: "session identifier"
    - ip_address: "client IP"
    - user_agent: "client user agent"
    - resource: "target resource"
    - method: "HTTP method"
    - status: "success|failure"
    - details: "additional context"
    - service: "originating service"
    - version: "service version"
```

## Tamper-Proof Storage

### Immutable Logging Architecture

```yaml
immutable_logging:
  storage:
    primary: aws_cloudwatch
    secondary: aws_s3
    archive: aws_glacier

  immutability:
    enabled: true
    method: append_only
    verification: checksum

  retention:
    hot: 30 days
    warm: 90 days
    cold: 1 year
    archive: 7 years
```

### Implementation

```python
import hashlib
import json
from datetime import datetime

class ImmutableAuditLogger:
    def __init__(self, storage_client):
        self.storage = storage_client
        self.previous_hash = self.get_last_hash()

    def log_event(self, event):
        """Log event with tamper-proof hash chain."""
        # Create log entry
        entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event': event,
            'previous_hash': self.previous_hash
        }

        # Calculate hash
        entry_hash = self.calculate_hash(entry)
        entry['hash'] = entry_hash

        # Store entry
        self.storage.append(entry)

        # Update previous hash
        self.previous_hash = entry_hash

        return entry

    def calculate_hash(self, entry):
        """Calculate SHA-256 hash of entry."""
        entry_copy = entry.copy()
        entry_copy.pop('hash', None)
        entry_string = json.dumps(entry_copy, sort_keys=True)
        return hashlib.sha256(entry_string.encode()).hexdigest()

    def verify_integrity(self, start_time, end_time):
        """Verify log integrity for time range."""
        entries = self.storage.get_range(start_time, end_time)

        previous_hash = None
        for entry in entries:
            # Verify chain
            if entry['previous_hash'] != previous_hash:
                return False, "Chain broken"

            # Verify hash
            expected_hash = self.calculate_hash(entry)
            if entry['hash'] != expected_hash:
                return False, "Hash mismatch"

            previous_hash = entry['hash']

        return True, "Integrity verified"
```

### Blockchain-Based Verification (Optional)

```python
class BlockchainAuditLogger:
    def __init__(self):
        self.chain = []

    def add_block(self, data):
        """Add data to blockchain."""
        block = {
            'index': len(self.chain),
            'timestamp': datetime.utcnow().isoformat(),
            'data': data,
            'previous_hash': self.get_last_hash(),
            'nonce': 0
        }

        # Proof of work
        while not self.is_valid_proof(block):
            block['nonce'] += 1

        self.chain.append(block)
        return block

    def is_valid_proof(self, block):
        """Check if block hash meets difficulty target."""
        hash_value = self.calculate_hash(block)
        return hash_value.startswith('0' * 4)
```

## Log Retention

### Retention Policy

```yaml
log_retention:
  security_logs:
    retention: 3 years
    storage: immutable
    access: restricted

  audit_logs:
    retention: 3 years
    storage: immutable
    access: admin_only

  access_logs:
    retention: 1 year
    storage: append_only
    access: security_team

  application_logs:
    retention: 90 days
    storage: standard
    access: dev_team

  error_logs:
    retention: 90 days
    storage: standard
    access: dev_team

  debug_logs:
    retention: 30 days
    storage: standard
    access: dev_team
```

### Automated Rotation

```python
class LogRetentionManager:
    def rotate_logs(self):
        """Rotate logs based on retention policy."""
        for log_type, policy in RETENTION_POLICIES.items():
            cutoff = datetime.utcnow() - timedelta(days=policy['retention_days'])

            # Archive old logs
            old_logs = self.get_logs(log_type, before=cutoff)
            self.archive_logs(old_logs, policy['archive_storage'])

            # Delete from primary storage
            self.delete_logs(log_type, before=cutoff)

            # Verify deletion
            self.verify_deletion(log_type, before=cutoff)
```

## Alerting on Suspicious Activity

### Alert Rules

```yaml
alert_rules:
  authentication:
    - rule: "multiple_failed_logins"
      condition: "5 failures in 5 minutes"
      severity: "high"
      action: "block_ip_and_notify"

    - rule: "impossible_travel"
      condition: "login from different countries within 1 hour"
      severity: "critical"
      action: "lock_account_and_notify"

    - rule: "brute_force_attempt"
      condition: "10 failures in 15 minutes"
      severity: "critical"
      action: "block_ip_and_lock_account"

  authorization:
    - rule: "privilege_escalation_attempt"
      condition: "access denied to admin resource"
      severity: "high"
      action: "notify_admin"

    - rule: "unusual_api_usage"
      condition: "1000 requests in 1 hour"
      severity: "medium"
      action: "rate_limit_and_notify"

  data:
    - rule: "mass_data_export"
      condition: "export > 1000 records"
      severity: "high"
      action: "alert_and_log"

    - rule: "unusual_data_access"
      condition: "access outside normal pattern"
      severity: "medium"
      action: "log_and_notify"
```

### Alert Implementation

```python
class AlertManager:
    def __init__(self, notification_service):
        self.notifications = notification_service
        self.rules = self.load_alert_rules()

    def check_event(self, event):
        """Check event against alert rules."""
        for rule in self.rules:
            if self.matches_rule(event, rule):
                self.trigger_alert(event, rule)

    def trigger_alert(self, event, rule):
        """Trigger alert based on rule."""
        alert = {
            'rule': rule['name'],
            'severity': rule['severity'],
            'event': event,
            'timestamp': datetime.utcnow(),
            'action_taken': rule['action']
        }

        # Log alert
        self.log_alert(alert)

        # Take action
        self.execute_action(rule['action'], event)

        # Notify
        self.notifications.send(alert)
```

### Alert Destinations

```yaml
alert_destinations:
  critical:
    - pagerduty
    - slack_oncall
    - email_admin
    - sms_admin

  high:
    - slack_security
    - email_security

  medium:
    - slack_monitoring
    - email_dev

  low:
    - email_dev
```

## Security Checklist

- [ ] Authentication events logged
- [ ] Authorization events logged
- [ ] Data events logged
- [ ] Administrative events logged
- [ ] System events logged
- [ ] Structured log format (JSON)
- [ ] Tamper-proof storage
- [ ] Log integrity verification
- [ ] Retention policy implemented
- [ ] Alerting configured
- [ ] Alert rules documented
- [ ] Regular log reviews
