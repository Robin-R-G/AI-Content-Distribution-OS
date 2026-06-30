# Data Retention

## Retention Schedules

### Data Classification Retention

```yaml
retention_policies:
  user_data:
    profile_information:
      retention: "Account lifetime + 30 days"
      deletion: "Automated after grace period"
      legal_basis: "Contract performance"

    authentication_data:
      password_hashes:
        retention: "Account lifetime"
        deletion: "Immediate on account deletion"
      login_history:
        retention: "1 year"
        deletion: "Automated"
      mfa_tokens:
        retention: "Until revoked"
        deletion: "Immediate on revocation"

    content_data:
      posts_and_media:
        retention: "Account lifetime + 90 days"
        deletion: "Soft delete 30 days, hard delete after"
      drafts:
        retention: "1 year"
        deletion: "Automated"
      archived_content:
        retention: "5 years"
        deletion: "Automated"

    analytics_data:
      usage_analytics:
        retention: "2 years"
        deletion: "Automated"
      performance_metrics:
        retention: "3 years"
        deletion: "Automated"
      aggregated_reports:
        retention: "5 years"
        deletion: "Automated"

  billing_data:
    invoices:
      retention: "7 years"
      deletion: "Automated"
      legal_basis: "Tax compliance"
    payment_methods:
      retention: "Until removed by user"
      deletion: "Immediate on removal"
    transaction_history:
      retention: "7 years"
      deletion: "Automated"

  communications:
    support_tickets:
      retention: "3 years"
      deletion: "Automated"
    emails:
      retention: "3 years"
      deletion: "Automated"
    marketing_emails:
      retention: "Until unsubscribe"
      deletion: "Immediate on unsubscribe"

  logs:
    access_logs:
      retention: "1 year"
      deletion: "Automated"
    error_logs:
      retention: "90 days"
      deletion: "Automated"
    audit_logs:
      retention: "3 years"
      deletion: "Automated"
    security_logs:
      retention: "2 years"
      deletion: "Automated"

  backups:
    full_backups:
      retention: "90 days"
      deletion: "Automated rotation"
    incremental_backups:
      retention: "30 days"
      deletion: "Automated rotation"
    archive_backups:
      retention: "1 year"
      deletion: "Automated"
```

## Automated Deletion

### Deletion Pipeline

```python
class DataRetentionService:
    def __init__(self, db, storage, cache):
        self.db = db
        self.storage = storage
        self.cache = cache

    def run_retention_job(self):
        """Run daily retention job."""
        # 1. Identify expired data
        expired = self.identify_expired_data()

        # 2. Process deletions
        for record in expired:
            self.process_deletion(record)

        # 3. Clean up backups
        self.cleanup_backups()

        # 4. Generate report
        self.generate_deletion_report()

    def process_deletion(self, record):
        """Process single record deletion."""
        # Soft delete first
        record.deleted_at = datetime.utcnow()
        self.db.session.commit()

        # Schedule hard delete after grace period
        self.schedule_hard_delete(record)

    def hard_delete(self, record):
        """Permanently delete record."""
        # Delete from primary storage
        self.db.session.delete(record)

        # Delete from backups
        self.delete_from_backups(record.id)

        # Delete from cache
        self.cache.delete(f"record:{record.id}")

        # Delete from search index
        self.delete_from_index(record.id)

        self.db.session.commit()
```

### Deletion Scheduling

```yaml
deletion_schedule:
  immediate_deletion:
    - account_deletion_requests
    - data_subject_requests
    - consent_withdrawal

  grace_period_deletion:
    - user_content: 30 days
    - user_profile: 30 days
    - user_settings: 30 days

  scheduled_deletion:
    - expired_sessions: daily
    - old_analytics: weekly
    - archived_logs: monthly
    - expired_backups: monthly
```

## Backup Retention

### Backup Strategy

```yaml
backup_strategy:
  types:
    full_backup:
      frequency: daily
      retention: 90 days
      compression: true
      encryption: AES-256

    incremental_backup:
      frequency: hourly
      retention: 30 days
      compression: true
      encryption: AES-256

    archive_backup:
      frequency: monthly
      retention: 1 year
      compression: true
      encryption: AES-256

  storage:
    primary: aws_s3
    secondary: aws_s3_cross_region
    archive: aws_glacier

  encryption:
    algorithm: AES-256-GCM
    key_management: aws_kms
    separate_keys: true
```

### Backup Rotation

```python
class BackupRetentionManager:
    def rotate_backups(self):
        """Rotate backups based on retention policy."""
        # Delete daily backups older than 90 days
        self.delete_old_backups('daily', days=90)

        # Delete hourly backups older than 30 days
        self.delete_old_backups('hourly', days=30)

        # Delete monthly backups older than 1 year
        self.delete_old_backups('monthly', months=12)

    def delete_old_backups(self, backup_type, **kwargs):
        """Delete backups older than specified time."""
        cutoff = datetime.utcnow() - timedelta(**kwargs)
        old_backups = self.list_backups(
            type=backup_type,
            older_than=cutoff
        )
        for backup in old_backups:
            self.delete_backup(backup)
```

## Audit Log Retention

### Audit Log Retention Policy

```yaml
audit_log_retention:
  security_events:
    retention: 3 years
    storage: immutable
    encryption: AES-256

  access_logs:
    retention: 1 year
    storage: append_only
    encryption: AES-256

  data_modification_logs:
    retention: 3 years
    storage: immutable
    encryption: AES-256

  admin_action_logs:
    retention: 5 years
    storage: immutable
    encryption: AES-256

  api_access_logs:
    retention: 1 year
    storage: append_only
    encryption: AES-256
```

### Log Rotation

```python
class AuditLogRetention:
    def rotate_logs(self):
        """Rotate audit logs based on retention policy."""
        for log_type, policy in RETENTION_POLICIES.items():
            cutoff = datetime.utcnow() - timedelta(days=policy['retention_days'])

            # Archive old logs
            old_logs = self.get_logs(log_type, before=cutoff)
            self.archive_logs(old_logs)

            # Delete from primary storage
            self.delete_logs(log_type, before=cutoff)

            # Verify deletion
            self.verify_deletion(log_type, before=cutoff)
```

## Anonymization Strategies

### Anonymization Techniques

```yaml
anonymization_techniques:
  pseudonymization:
    description: "Replace identifiers with pseudonyms"
    reversible: true
    use_cases:
      - analytics
      - research
      - internal reporting

  data_masking:
    description: "Mask sensitive fields"
    reversible: false
    use_cases:
      - non-production environments
      - third-party sharing
      - testing

  generalization:
    description: "Replace specific values with ranges"
    reversible: false
    use_cases:
      - age ranges instead of birth dates
      - zip codes instead of full addresses

  suppression:
    description: "Remove sensitive fields entirely"
    reversible: false
    use_cases:
      - data subject requests
      - high-risk processing

  aggregation:
    description: "Combine data to prevent identification"
    reversible: false
    use_cases:
      - statistical analysis
      - public reports
```

### Implementation

```python
class DataAnonymizer:
    def anonymize_user_data(self, user_data):
        """Anonymize user data for analytics."""
        anonymized = {
            'user_hash': self.hash_identifier(user_data['id']),
            'age_range': self.generalize_age(user_data['age']),
            'location_region': self.generalize_location(user_data['location']),
            'signup_month': user_data['created_at'].strftime('%Y-%m'),
        }
        return anonymized

    def hash_identifier(self, identifier):
        """Hash identifier for pseudonymization."""
        salt = os.environ['ANONYMIZATION_SALT']
        return hashlib.sha256(
            f"{salt}:{identifier}".encode()
        ).hexdigest()

    def generalize_age(self, age):
        """Generalize age to range."""
        if age < 18:
            return 'under_18'
        elif age < 25:
            return '18-24'
        elif age < 35:
            return '25-34'
        elif age < 45:
            return '35-44'
        elif age < 55:
            return '45-54'
        else:
            return '55_plus'
```

## Data Lifecycle

### Lifecycle Stages

```yaml
data_lifecycle:
  stages:
    collection:
      - purpose_documentation
      - consent_obtention
      - data_minimization

    storage:
      - encryption
      - access_controls
      - backup_creation

    processing:
      - purpose_limitation
      - access_logging
      - integrity_verification

    sharing:
      - legal_basis
      - dpa_agreements
      - security_measures

    retention:
      - policy_compliance
      - automated_deletion
      - archive_management

    disposal:
      - secure_deletion
      - verification
      - documentation
```

### Lifecycle Management

```python
class DataLifecycleManager:
    def manage_lifecycle(self, data):
        """Manage data through its lifecycle."""
        # Track lifecycle events
        self.log_lifecycle_event(data, 'created')

        # Apply retention policy
        self.apply_retention_policy(data)

        # Monitor for deletion triggers
        self.monitor_deletion_triggers(data)

        # Process deletion when required
        self.process_deletion(data)
```

## Compliance

### Regulatory Requirements

```yaml
regulatory_requirements:
  gdpr:
    retention_limitation: "No longer than necessary"
    right_to_erasure: "Honor deletion requests"
    data_minimization: "Collect only what's needed"

  ccpa:
    retention_limitation: "Reasonable period"
    deletion_request: "Honor deletion requests"

  hipaa:
    retention_period: "6 years minimum"
    secure_disposal: "Required"

  sox:
    retention_period: "7 years"
    audit_trail: "Required"
```

### Compliance Monitoring

```python
class ComplianceMonitor:
    def check_compliance(self):
        """Check data retention compliance."""
        violations = []

        # Check for expired data
        expired = self.find_expired_data()
        if expired:
            violations.append({
                'type': 'expired_data',
                'count': len(expired),
                'severity': 'high'
            })

        # Check deletion request compliance
        overdue = self.find_overdue_deletions()
        if overdue:
            violations.append({
                'type': 'overdue_deletion',
                'count': len(overdue),
                'severity': 'critical'
            })

        return violations
```

## Security Checklist

- [ ] Retention policies documented
- [ ] Automated deletion implemented
- [ ] Backup rotation configured
- [ ] Audit log retention defined
- [ ] Anonymization strategies implemented
- [ ] Deletion verification process
- [ ] Compliance monitoring active
- [ ] Data lifecycle documented
- [ ] Regulatory requirements met
- [ ] Regular compliance audits
