# Infrastructure Security

## Network Security

### Network Architecture

```yaml
network_architecture:
  layers:
    edge:
      - cloudflare_waf
      - ddos_protection
      - bot_management

    dmz:
      - load_balancer
      - api_gateway
      - cdn_origin

    application:
      - web_servers
      - api_servers
      - worker_nodes

    data:
      - database_cluster
      - cache_cluster
      - storage

  segmentation:
    - public_subnet
    - private_subnet
    - database_subnet
    - management_subnet
```

### Network Policies

```yaml
network_policies:
  ingress:
    - port: 443
      source: 0.0.0.0/0
      description: "HTTPS from anywhere"

    - port: 80
      source: 0.0.0.0/0
      description: "HTTP redirect to HTTPS"

    - port: 22
      source: 10.0.0.0/8
      description: "SSH from management network"

  egress:
    - port: 443
      destination: 0.0.0.0/0
      description: "HTTPS outbound"

    - port: 5432
      destination: 10.0.2.0/24
      description: "PostgreSQL to database subnet"

    - port: 6379
      destination: 10.0.3.0/24
      description: "Redis to cache subnet"
```

### VPC Configuration

```yaml
vpc_configuration:
  cidr_block: "10.0.0.0/16"

  subnets:
    public:
      - name: "public-1"
        cidr: "10.0.1.0/24"
        availability_zone: "us-east-1a"

    private:
      - name: "private-1"
        cidr: "10.0.2.0/24"
        availability_zone: "us-east-1a"

    database:
      - name: "database-1"
        cidr: "10.0.3.0/24"
        availability_zone: "us-east-1a"

  nat_gateway: true
  flow_logs: true
```

## Firewall Rules

### WAF Rules (Cloudflare)

```yaml
waf_rules:
  - name: "Block Known Bad IPs"
    action: "block"
    expression: "ip.geoip.country in {\"XX\" \"YY\"}"

  - name: "Rate Limit API"
    action: "challenge"
    expression: "http.request.uri.path matches \"/api/*\""
    rate: 100
    period: 60

  - name: "Block SQL Injection"
    action: "block"
    expression: "http.request.uri.query contains \"SELECT\" or http.request.uri.query contains \"UNION\""

  - name: "Block XSS"
    action: "block"
    expression: "http.request.uri.query contains \"<script\""
```

### Host Firewall (iptables)

```bash
# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow SSH from management network
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT

# Allow HTTPS
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow HTTP (redirect to HTTPS)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: "
```

## SSH Hardening

### SSH Configuration

```bash
# /etc/ssh/sshd_config

# Protocol and authentication
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Key exchange and ciphers
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Access control
AllowUsers deploy admin
AllowGroups ssh-users
MaxAuthTries 3
LoginGraceTime 60

# Session settings
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowTcpForwarding no

# Logging
SyslogFacility AUTH
LogLevel VERBOSE
```

### SSH Key Management

```yaml
ssh_key_management:
  key_type: ed25519
  key_size: 255
  passphrase: required

  rotation:
    frequency: 90 days
    process: automated

  access:
    - user: deploy
      key: /home/deploy/.ssh/authorized_keys
    - user: admin
      key: /home/admin/.ssh/authorized_keys
```

## Container Security

### Docker Security

```dockerfile
# Use minimal base image
FROM alpine:3.18

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy application files
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Run application
CMD ["python", "app.py"]
```

### Docker Compose Security

```yaml
services:
  app:
    image: app:latest
    read_only: true
    tmpfs:
      - /tmp
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    environment:
      - NODE_ENV=production
    secrets:
      - db_password
      - jwt_secret

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
```

### Kubernetes Security

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: social-media-ai
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001

      containers:
        - name: app
          image: app:latest
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL

          resources:
            limits:
              cpu: "1"
              memory: 1Gi
            requests:
              cpu: 500m
              memory: 512Mi

          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
```

## Cloud Security Posture

### AWS Security Configuration

```yaml
aws_security:
  iam:
    - mfa_enabled: true
    - password_policy:
        min_length: 14
        require_symbols: true
        require_numbers: true
        require_uppercase: true
        require_lowercase: true
        max_age: 90

  s3:
    - encryption: AES-256
    - versioning: true
    - logging: true
    - public_access: false

  ec2:
    - ebs_encryption: true
    - metadata_service: v2_only
    - termination_protection: true

  rds:
    - encryption: true
    - backup_retention: 30 days
    - multi_az: true
    - auto_upgrade: true

  cloudtrail:
    - enabled: true
    - log_file_validation: true
    - encryption: true
    - multi_region: true
```

### GCP Security Configuration

```yaml
gcp_security:
  iam:
    - mfa_enabled: true
    - service_account_keys: minimal
    - workload_identity: true

  compute:
    - shielded_vm: true
    - secure_boot: true
    - vtpm: true

  storage:
    - uniform_bucket_level_access: true
    - object_versioning: true

  cloudsql:
    - ssl_required: true
    - backup_enabled: true
    - point_in_time_recovery: true
```

### Azure Security Configuration

```yaml
azure_security:
  aad:
    - mfa_enabled: true
    - conditional_access: true
    - pim_enabled: true

  storage:
    - encryption: AES-256
    - secure_transfer: true
    - public_access: disabled

  sql:
    - auditing_enabled: true
    - transparent_data_encryption: true
    - threat_detection: true
```

## Monitoring and Detection

### Security Monitoring

```yaml
security_monitoring:
  siem:
    provider: aws_security_hub
    alerts:
      - unauthorized_access
      - privilege_escalation
      - data_exfiltration
      - malware_detection

  ids:
    provider: aws_guardduty
    findings:
      - trojan
      - backdoor
      - crypto_currency
      - dns_exfiltration

  vulnerability_scanning:
    provider: aws_inspector
    schedule: weekly
    targets:
      - ec2_instances
      - ecr_images
      - lambda_functions
```

### Alert Configuration

```yaml
security_alerts:
  critical:
    notification: immediate
    channels:
      - pagerduty
      - slack_oncall
      - email

  high:
    notification: 30_minutes
    channels:
      - slack_security
      - email

  medium:
    notification: 2_hours
    channels:
      - slack_monitoring

  low:
    notification: daily
    channels:
      - email_report
```

## Security Checklist

- [ ] Network segmentation implemented
- [ ] WAF rules configured
- [ ] SSH hardened
- [ ] Container security best practices
- [ ] Cloud security posture managed
- [ ] Monitoring and detection enabled
- [ ] Incident response procedures documented
- [ ] Regular security audits scheduled
- [ ] Access controls reviewed
- [ ] Encryption at rest and in transit
