# GDPR Compliance

## Data Processing Overview

### Data Controller vs Processor

```yaml
data_roles:
  controller:
    definition: "Determines purposes and means of processing"
    responsibilities:
      - Defining data processing purposes
      - Obtaining consent
      - Responding to data subject requests
      - Ensuring data protection

  processor:
    definition: "Processes data on behalf of controller"
    responsibilities:
      - Processing data per instructions
      - Implementing security measures
      - Assisting with data subject requests
      - Reporting data breaches
```

### Data Processing Agreement (DPA)

```yaml
dpa_template:
  parties:
    controller: "Social Media AI Company"
    processor: "Third-party services"

  processing_details:
    purposes:
      - Content management
      - Analytics
      - User authentication
      - Customer support

    data_categories:
      - User identifiers (name, email)
      - Content data
      - Usage analytics
      - Technical data

    data_subjects:
      - Platform users
      - Website visitors
      - Customer contacts
```

## Right to Access

### Data Subject Access Request (DSAR)

```yaml
dsar_process:
  request_methods:
    - email: privacy@company.com
    - web_form: /privacy/access-request
    - api: /api/privacy/data-request

  response_timeline:
    acknowledge: 3 business days
    complete: 30 calendar days
    extension: 60 additional days (complex requests)

  information_to_provide:
    - categories_of_data
    - purposes_of_processing
    - data_recipients
    - retention_periods
    - source_of_data
    - copy_of_personal_data
```

### Automated Data Export

```python
class DataExportService:
    def export_user_data(self, user_id):
        """Export all user data for DSAR."""
        return {
            'profile': self.get_profile(user_id),
            'content': self.get_content(user_id),
            'analytics': self.get_analytics(user_id),
            'settings': self.get_settings(user_id),
            'billing': self.get_billing(user_id),
            'activity_log': self.get_activity_log(user_id),
            'connected_accounts': self.get_social_accounts(user_id),
            'consent_records': self.get_consents(user_id),
            'data_processing_log': self.get_processing_log(user_id)
        }
```

## Right to Erasure

### Deletion Process

```yaml
deletion_process:
  request_flow:
    1. User requests deletion
    2. Verify identity
    3. Check for legal obligations
    4. Process deletion request
    5. Notify third parties
    6. Confirm deletion

  exceptions:
    - legal_obligations:
        - tax_records: 7 years
        - financial_transactions: 7 years
        - legal_disputes: until resolved

    - legitimate_interests:
        - fraud_prevention: 5 years
        - security_logs: 1 year

  deletion_scope:
    - profile_data: immediate
    - content: 30 days (soft delete)
    - analytics: 30 days
    - backups: 90 days (cascading delete)
    - logs: 30 days
```

### Deletion Implementation

```python
class DeletionService:
    def process_deletion(self, user_id):
        """Process GDPR deletion request."""
        # 1. Check for legal holds
        if self.has_legal_hold(user_id):
            return {"status": "delayed", "reason": "legal_hold"}

        # 2. Soft delete (30-day grace period)
        self.soft_delete_user(user_id)

        # 3. Schedule hard deletion
        self.schedule_hard_delete(user_id, delay_days=30)

        # 4. Notify third parties
        self.notify_deletion_to_partners(user_id)

        # 5. Log deletion request
        self.log_deletion_request(user_id)

    def hard_delete_user(self, user_id):
        """Permanently delete all user data."""
        self.delete_profile(user_id)
        self.delete_content(user_id)
        self.delete_analytics(user_id)
        self.delete_activity_logs(user_id)
        self.delete_backups(user_id)
```

## Data Portability

### Export Formats

```yaml
export_formats:
  json:
    extension: .json
    encoding: UTF-8
    schema: defined_by_user

  csv:
    extension: .csv
    encoding: UTF-8
    delimiter: comma

  xml:
    extension: .xml
    encoding: UTF-8
    schema: custom

  machine_readable: true
  structured: true
```

### Portability API

```yaml
api_endpoints:
  request_export:
    method: POST
    path: /api/privacy/export
    body:
      format: json|csv|xml
      include: [profile, content, analytics]

  check_status:
    method: GET
    path: /api/privacy/export/{export_id}

  download:
    method: GET
    path: /api/privacy/export/{export_id}/download
    expires: 7 days
```

## Consent Management

### Consent Types

```yaml
consent_types:
  essential:
    required: true
    description: "Necessary for basic functionality"
    examples:
      - authentication
      - security
      - legal_compliance

  functional:
    required: false
    description: "Enhanced functionality"
    examples:
      - preferences
      - personalization
      - remembering_choices

  analytics:
    required: false
    description: "Usage analytics"
    examples:
      - google_analytics
      - heatmap_tracking
      - a_b_testing

  marketing:
    required: false
    description: "Marketing and advertising"
    examples:
      - email_marketing
      - targeted_ads
      - social_media_tracking
```

### Consent Implementation

```python
class ConsentManager:
    def record_consent(self, user_id, consent_type, granted):
        """Record user consent."""
        consent = Consent(
            user_id=user_id,
            type=consent_type,
            granted=granted,
            timestamp=datetime.utcnow(),
            ip_address=request.remote_addr,
            user_agent=request.user_agent
        )
        self.db.session.add(consent)
        self.db.session.commit()

    def get_consents(self, user_id):
        """Get user's current consents."""
        consents = Consent.query.filter_by(
            user_id=user_id
        ).order_by(Consent.timestamp.desc())

        return {c.type: c.granted for c in consents}

    def withdraw_consent(self, user_id, consent_type):
        """Withdraw user consent."""
        self.record_consent(user_id, consent_type, False)
        self.process_withdrawal(user_id, consent_type)
```

### Consent UI

```yaml
consent_ui:
  cookie_banner:
    style: "opt-in"
    position: "bottom"
    dismissible: false
    buttons:
      - text: "Accept All"
        action: "accept_all"
      - text: "Reject Non-Essential"
        action: "reject_all"
      - text: "Customize"
        action: "open_settings"

  settings_page:
    path: /settings/privacy
    granular_controls: true
    easy_withdrawal: true
```

## Privacy by Design

### Data Protection Principles

```yaml
principles:
  data_minimization:
    description: "Collect only what's needed"
    implementation:
      - required_fields_only
      - optional_data_with_consent
      - regular_data_review

  purpose_limitation:
    description: "Use data only for stated purposes"
    implementation:
      - purpose_documentation
      - access_controls
      - audit_logging

  storage_limitation:
    description: "Keep data only as long as needed"
    implementation:
      - retention_policies
      - automated_deletion
      - regular_purge

  accuracy:
    description: "Keep data accurate and up to date"
    implementation:
      - user_self_service
      - validation_rules
      - regular_verification

  integrity_confidentiality:
    description: "Protect data with appropriate security"
    implementation:
      - encryption
      - access_controls
      - security_monitoring
```

### Privacy Impact Assessment

```yaml
pia_requirements:
  when_required:
    - new_systems
    - new_processing_activities
    - significant_changes
    - high_risk_data

  assessment_areas:
    - data_flow_mapping
    - risk_identification
    - mitigation_measures
    - compliance_verification

  documentation:
    - processing_purposes
    - data_categories
    - retention_periods
    - security_measures
    - third_party_sharing
```

## DPIA Guidelines

### When to Conduct DPIA

```yaml
dpia_triggers:
  mandatory:
    - systematic_monitoring
    - large_scale_processing
    - special_category_data
    - automated_decision_making
    - new_technologies

  recommended:
    - new_data_processing
    - significant_changes
    - high_volume_data
    - sensitive_data
```

### DPIA Process

```yaml
dpia_steps:
  1. description:
      - processing_activities
      - data_flows
      - purposes

  2. necessity:
      - legal_basis
      - proportionality
      - alternatives

  3. risk_assessment:
      - data_subjects
      - processing_effects
      - risk_likelihood
      - risk_severity

  4. mitigation:
      - technical_measures
      - organizational_measures
      - contractual_measures

  5. consultation:
      - dpo_review
      - stakeholder_input
      - authority_consultation

  6. documentation:
      - report
      - action_plan
      - review_schedule
```

## EU Representative

```yaml
eu_representative:
  required: true
  article: "Article 27 GDPR"
  contact:
    name: "[EU Representative Name]"
    address: "[EU Address]"
    email: privacy-eu@company.com
    phone: +[EU Phone]

  responsibilities:
    - handle_data_subject_requests
    - liaise_with_supervisory_authorities
    - maintain_records_of_processing
```

## Security Checklist

- [ ] DPA with all processors
- [ ] DSAR process implemented
- [ ] Right to erasure process
- [ ] Data portability export
- [ ] Consent management system
- [ ] Privacy by design principles
- [ ] DPIA process documented
- [ ] EU representative appointed
- [ ] Data processing records
- [ ] Breach notification process
