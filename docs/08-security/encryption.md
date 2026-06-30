# Encryption

## TLS 1.3 for Transit Encryption

### Configuration

```
Protocol: TLS 1.3 (minimum TLS 1.2)
Cipher Suites (in priority order):
  1. TLS_AES_256_GCM_SHA384
  2. TLS_CHACHA20_POLY1305_SHA256
  3. TLS_AES_128_GCM_SHA256

Key Exchange: X25519 (preferred), ECDHE
Certificate: ECDSA P-256 or RSA 2048+
HSTS: max-age=63072000; includeSubDomains; preload
```

### Certificate Management

```
Provider: Let's Encrypt (free) or DigiCert (EV)
Auto-renewal: Enabled (30 days before expiry)
Certificate Transparency: Required
OCSP Stapling: Enabled
CAA Record: Restrict to allowed CAs
```

### Internal Service Communication

```
Service Mesh: mTLS via service mesh (Istio/Linkerd)
Certificate Rotation: Automated every 24 hours
Service Identity: SPIFFE/SPIRE for workload identity
```

## AES-256 for At-Rest Encryption

### Database Encryption

```
Algorithm: AES-256-GCM
Mode: GCM (Galois/Counter Mode) for authenticated encryption
Key Size: 256 bits
IV Size: 96 bits (generated per record)
Tag Size: 128 bits
```

### File Storage Encryption

```
Algorithm: AES-256-GCM
Key Management: Envelope encryption with KMS
Chunk Size: 64 KB for large files
Integrity: HMAC-SHA256 for file integrity verification
```

### Encryption Implementation

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

def encrypt_data(plaintext, key):
    """Encrypt data with AES-256-GCM."""
    nonce = os.urandom(12)  # 96 bits
    aesgcm = AESGCM(key)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    return nonce + ciphertext

def decrypt_data(encrypted, key):
    """Decrypt AES-256-GCM encrypted data."""
    nonce = encrypted[:12]
    ciphertext = encrypted[12:]
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ciphertext, None)
```

## Field-Level Encryption

### Sensitive Field Classification

```yaml
field_classification:
  encrypt_at_rest:
    - user.email
    - user.phone
    - user.address
    - payment.card_number
    - payment.card_cvv
    - ssn
    - tax_id

  encrypt_in_transit:
    - user.password_hash
    - api_keys
    - oauth_tokens
    - webhook_secrets

  tokenization:
    - payment.card_number  # Replace with token
    - ssn                  # Replace with token
```

### Field Encryption Implementation

```python
class FieldEncryptor:
    def __init__(self, master_key):
        self.master_key = master_key

    def encrypt_field(self, field_name, value):
        """Encrypt a specific field with its own key."""
        field_key = derive_key(self.master_key, field_name)
        return encrypt_data(value.encode(), field_key)

    def decrypt_field(self, field_name, encrypted_value):
        """Decrypt a specific field."""
        field_key = derive_key(self.master_key, field_name)
        return decrypt_data(encrypted_value, field_key).decode()
```

### Deterministic Encryption (for Searching)

```
Algorithm: AES-SIV (RFC 5297)
Use Case: Encrypted fields that need equality searches
Security: Prevents pattern analysis while allowing lookups

Example:
  encrypted_email = deterministic_encrypt(user.email, key)
  # Can search: WHERE encrypted_email = encrypt('user@example.com')
  # Cannot decrypt without key
```

## Key Management

### Key Hierarchy

```
Master Key (CMK)
  ├── Data Encryption Key (DEK)
  │     ├── Database Key
  │     ├── File Storage Key
  │     └── Field Keys
  ├── Token Signing Key
  │     ├── Access Token Key
  │     └── Refresh Token Key
  └── Service Keys
        ├── Service A Key
        └── Service B Key
```

### Key Rotation Policy

```yaml
rotation_schedule:
  master_key: annually
  data_encryption_key: every 90 days
  field_keys: every 180 days
  token_signing_key: every 90 days
  api_keys: every 90 days
  service_keys: every 365 days

rotation_process:
  1. Generate new key version
  2. Start encrypting with new key
  3. Re-encrypt old data (background job)
  4. Verify all data re-encrypted
  5. Archive old key (90-day retention)
  6. Delete archived key
```

### Key Storage

```
Production:
  - AWS KMS / GCP KMS / Azure Key Vault
  - Hardware Security Module (HSM) for master key
  - Keys never leave HSM/KMS

Development:
  - Environment variables (not committed)
  - Local key vault (for testing)
  - Separate keys per environment
```

## Envelope Encryption

### Process

```
1. Generate Data Encryption Key (DEK)
2. Encrypt data with DEK
3. Encrypt DEK with Master Key (wrapped DEK)
4. Store wrapped DEK with encrypted data
5. To decrypt: unwrap DEK with Master Key, then decrypt data
```

### Implementation

```python
import boto3
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

class EnvelopeEncryption:
    def __init__(self, kms_client, master_key_id):
        self.kms = kms_client
        self.master_key_id = master_key_id

    def encrypt(self, plaintext):
        """Encrypt using envelope encryption."""
        # Generate DEK
        dek = AESGCM.generate_key(bit_length=256)

        # Encrypt data with DEK
        nonce = os.urandom(12)
        aesgcm = AESGCM(dek)
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)

        # Encrypt DEK with master key
        response = self.kms.encrypt(
            KeyId=self.master_key_id,
            Plaintext=dek
        )
        encrypted_dek = response['CiphertextBlob']

        return {
            'ciphertext': ciphertext,
            'encrypted_dek': encrypted_dek,
            'nonce': nonce
        }

    def decrypt(self, encrypted_data):
        """Decrypt using envelope encryption."""
        # Decrypt DEK
        response = self.kms.decrypt(
            CiphertextBlob=encrypted_data['encrypted_dek']
        )
        dek = response['Plaintext']

        # Decrypt data
        aesgcm = AESGCM(dek)
        plaintext = aesgcm.decrypt(
            encrypted_data['nonce'],
            encrypted_data['ciphertext'],
            None
        )

        return plaintext
```

## Hash Functions

### Approved Algorithms

```
Password Hashing: Argon2id (preferred) or bcrypt
  - Argon2id: Memory-hard, resistant to GPU attacks
  - bcrypt: Cost factor 12+

General Hashing: SHA-256, SHA-384, SHA-512
  - File integrity verification
  - Certificate fingerprinting
  - Audit log integrity

HMAC: HMAC-SHA256
  - Request signing
  - Webhook verification
  - Token generation
```

### Hashing for Integrity

```python
import hashlib

def compute_hash(data):
    """Compute SHA-256 hash for integrity verification."""
    return hashlib.sha256(data).hexdigest()

def verify_integrity(data, expected_hash):
    """Verify data integrity against expected hash."""
    return compute_hash(data) == expected_hash
```

## Security Checklist

- [ ] TLS 1.3 enforced on all external endpoints
- [ ] AES-256-GCM for at-rest encryption
- [ ] Field-level encryption for PII
- [ ] Envelope encryption for key hierarchy
- [ ] Key rotation automated
- [ ] Keys stored in KMS/HSM (not code)
- [ ] Hash functions approved (SHA-256+)
- [ ] Password hashing uses Argon2id
- [ ] Certificate transparency enabled
- [ ] HSTS headers configured
