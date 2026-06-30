# Security Testing Guide

## Overview

Security testing identifies vulnerabilities in the application through static analysis, dynamic analysis, dependency scanning, and penetration testing.

## SAST (Static Application Security Testing)

### ESLint Security Plugin

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:security/recommended',
  ],
  plugins: ['security'],
  rules: {
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-possible-timing-attacks': 'warn',
  },
};
```

### TypeScript Security Rules

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### Static Analysis Tools

```yaml
# .github/workflows/sast.yml
name: SAST

on:
  pull_request:
    branches: [main]

jobs:
  sast:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ESLint Security
        run: |
          npm install eslint-plugin-security
          eslint --plugin security src/
          
      - name: Run TypeScript Security Check
        run: |
          npm run typecheck
          
      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/typescript
          
      - name: Run CodeQL
        uses: github/codeql-action/analyze@v2
        with:
          languages: typescript
```

## DAST (Dynamic Application Security Testing)

### OWASP ZAP Configuration

```yaml
# zap-config.yml
---
env:
  contexts:
    - name: "Social Media AI"
      urls:
        - "http://localhost:3000"
      includePaths:
        - "http://localhost:3000/api/.*"
      excludePaths:
        - "http://localhost:3000/api/health"
      technology:
        - JavaScript
        - Node.js
        - PostgreSQL

  parameters:
    failOnError: true
    progressToStdout: true

  policies:
    - name: "Social Media AI Policy"
      rules:
        - id: 10010
          name: "Cookie No HttpOnly Flag"
          strength: "medium"
          threshold: "low"
        - id: 10011
          name: "Cookie Without SameSite Attribute"
          strength: "medium"
          threshold: "low"
        - id: 10015
          name: "Re-examine Cache Control Headers"
          strength: "low"
          threshold: "low"
        - id: 10017
          name: "Cross-Domain JavaScript Source Inclusion"
          strength: "medium"
          threshold: "medium"
        - id: 10018
          name: "JavaScript Object Injection"
          strength: "medium"
          threshold: "medium"
        - id: 10019
          name: "Content-Type Header Missing"
          strength: "medium"
          threshold: "low"
        - id: 10020
          name: "X-Frame-Options Missing"
          strength: "medium"
          threshold: "low"
        - id: 10021
          name: "X-Content-Type-Options Missing"
          strength: "low"
          threshold: "low"
        - id: 10023
          name: "Information Disclosure"
          strength: "low"
          threshold: "low"
        - id: 10024
          name: "Information Disclosure - Debug Errors"
          strength: "low"
          threshold: "low"
        - id: 10025
          name: "Information Disclosure - Sensitive Information in URL"
          strength: "low"
          threshold: "low"
        - id: 10027
          name: "Information Disclosure - Sensitive Information in HTTP Referrer Header"
          strength: "low"
          threshold: "low"
        - id: 10028
          name: "Information Disclosure - Password Auto-Fill"
          strength: "low"
          threshold: "low"
        - id: 10029
          name: "Information Disclosure - Debug Errors"
          strength: "low"
          threshold: "low"
        - id: 10030
          name: "Information Disclosure - Sensitive Information in HTTP Referrer Header"
          strength: "low"
          threshold: "low"
        - id: 10031
          name: "Information Disclosure - Password Auto-Fill"
          strength: "low"
          threshold: "low"
        - id: 10032
          name: "Information Disclosure - Debug Errors"
          strength: "low"
          threshold: "low"
        - id: 10033
          name: "Information Disclosure - Sensitive Information in HTTP Referrer Header"
          strength: "low"
          threshold: "low"
        - id: 10034
          name: "Information Disclosure - Password Auto-Fill"
          strength: "low"
          threshold: "low"
        - id: 10035
          name: "Information Disclosure - Debug Errors"
          strength: "low"
          threshold: "low"
        - id: 10036
          name: "Information Disclosure - Sensitive Information in HTTP Referrer Header"
          strength: "low"
          threshold: "low"
        - id: 10037
          name: "Information Disclosure - Password Auto-Fill"
          strength: "low"
          threshold: "low"
        - id: 10038
          name: "Information Disclosure - Debug Errors"
          strength: "low"
          threshold: "low"
        - id: 10039
          name: "Information Disclosure - Sensitive Information in HTTP Referrer Header"
          strength: "low"
          threshold: "low"
        - id: 10040
          name: "Information Disclosure - Password Auto-Fill"
          strength: "low"
          threshold: "low"

  spider:
    maxDepth: 10
    maxChildren: 10
    scanType: "sequential"

  ascan:
    maxRuleDurationInMins: 5
    maxScanDurationInMins: 60
    maxChildren: 10
    recursiveDepth: 5

  passiveScan:
    enabled: true

  activeScan:
    enabled: true
    strength: "medium"
    threshold: "medium"
```

### ZAP Automation

```yaml
# .github/workflows/zap.yml
name: OWASP ZAP Scan

on:
  pull_request:
    branches: [main]

jobs:
  zap:
    runs-on: ubuntu-latest
    
    services:
      app:
        image: your-app-image
        ports:
          - 3000:3000
        env:
          NODE_ENV: test

    steps:
      - uses: actions/checkout@v3
      
      - name: Run ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.9.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: 'zap-config.yml'
          cmd_options: '-a'
          
      - name: Run ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.7.0
        if: github.event_name == 'schedule'
        with:
          target: 'http://localhost:3000'
          rules_file_name: 'zap-config.yml'
```

## Dependency Scanning

### npm Audit

```yaml
# .github/workflows/dependency-scan.yml
name: Dependency Scanning

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'  # Daily

jobs:
  audit:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run npm audit
        run: npm audit --audit-level=moderate
        
      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          command: test
          args: --severity-threshold=high
```

### Snyk Configuration

```json
// .snyk
{
  "version": "1.25.0",
  "delete": "0.25.0",
  "ignore": {
    "SNYK-JS-LODASH-567746": {
      "": {
        "paths": ["node_modules/lodash"],
        "version": ">=0",
        "severity": "moderate",
        "reason": "Only affects specific use cases"
      }
    }
  },
  "patch": {
    "SNYK-JS-LODASH-567746": {
      "node_modules/lodash": {
        "node_modules/lodash": {
          "lodash": ">=4.17.21"
        }
      }
    }
  }
}
```

### Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
      time: "09:00"
      timezone: "America/New_York"
    open-pull-requests-limit: 10
    reviewers:
      - "your-team"
    labels:
      - "dependencies"
      - "security"
    allow:
      - dependency-type: "production"
    ignore:
      - dependency-name: "lodash"
        versions: ["<4.17.21"]
```

## Penetration Testing Checklist

### Authentication Testing

```markdown
## Authentication Testing

### 1. Password Policy
- [ ] Minimum length requirements enforced
- [ ] Complexity requirements enforced
- [ ] Password history prevention
- [ ] Account lockout after failed attempts

### 2. Session Management
- [ ] Session tokens are random and unpredictable
- [ ] Session tokens expire after reasonable time
- [ ] Session tokens are invalidated on logout
- [ ] Session fixation prevention

### 3. Multi-Factor Authentication
- [ ] MFA implementation is secure
- [ ] Backup codes are secure
- [ ] MFA bypass attempts are blocked

### 4. OAuth/SSO
- [ ] State parameter validation
- [ ] Redirect URI validation
- [ ] Token storage security
```

### Authorization Testing

```markdown
## Authorization Testing

### 1. Role-Based Access Control
- [ ] Roles are properly defined
- [ ] Permissions are properly assigned
- [ ] Role escalation is prevented

### 2. Object-Level Authorization
- [ ] Users can only access their own resources
- [ ] IDOR vulnerabilities are prevented
- [ ] Horizontal privilege escalation is prevented

### 3. Vertical Authorization
- [ ] Admin functions are protected
- [ ] Privilege escalation is prevented
- [ ] API endpoints are properly secured
```

### Input Validation Testing

```markdown
## Input Validation Testing

### 1. SQL Injection
- [ ] Parameterized queries are used
- [ ] Input sanitization is implemented
- [ ] Error messages don't reveal SQL structure

### 2. XSS (Cross-Site Scripting)
- [ ] Input encoding is implemented
- [ ] Output encoding is implemented
- [ ] Content Security Policy is configured

### 3. CSRF (Cross-Site Request Forgery)
- [ ] CSRF tokens are implemented
- [ ] SameSite cookies are used
- [ ] Origin validation is implemented

### 4. File Upload
- [ ] File type validation
- [ ] File size limits
- [ ] Malware scanning
- [ ] Secure file storage
```

### API Security Testing

```markdown
## API Security Testing

### 1. Authentication
- [ ] API keys are secure
- [ ] JWT tokens are secure
- [ ] Token expiration is enforced

### 2. Rate Limiting
- [ ] Rate limiting is implemented
- [ ] Rate limits are appropriate
- [ ] Rate limit bypass is prevented

### 3. Input Validation
- [ ] Request body validation
- [ ] Query parameter validation
- [ ] Header validation

### 4. Error Handling
- [ ] Error messages are sanitized
- [ ] Stack traces are not exposed
- [ ] Logging is implemented
```

## Security Test Scripts

### Authentication Security Tests

```typescript
// tests/security/authentication.security.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('Authentication Security', () => {
  describe('Brute Force Protection', () => {
    it('should lock account after 5 failed attempts', async () => {
      const email = 'test@example.com';
      
      for (let i = 0; i < 5; i++) {
        await request(app)
          .post('/api/auth/login')
          .send({ email, password: 'wrongpassword' });
      }

      const response = await request(app)
        .post('/api/auth/login')
        .send({ email, password: 'wrongpassword' });

      expect(response.status).toBe(423);
      expect(response.body.error).toBe('Account locked');
    });
  });

  describe('Password Security', () => {
    it('should not reveal if email exists', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({ email: 'nonexistent@example.com', password: 'password' });

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid credentials');
    });
  });

  describe('Session Security', () => {
    it('should invalidate session on logout', async () => {
      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({ email: 'test@example.com', password: 'password' });

      const token = loginResponse.body.token;

      await request(app)
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${token}`);

      const response = await request(app)
        .get('/api/posts')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(401);
    });
  });
});
```

### Input Validation Security Tests

```typescript
// tests/security/input-validation.security.test.ts
import request from 'supertest';
import app from '../../src/app';

describe('Input Validation Security', () => {
  describe('SQL Injection', () => {
    it('should prevent SQL injection in login', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: "admin'--",
          password: 'password',
        });

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid credentials');
    });

    it('should prevent SQL injection in search', async () => {
      const response = await request(app)
        .get('/api/posts/search?q=1%27%20OR%201%3D1--')
        .set('Authorization', `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe('XSS Prevention', () => {
    it('should sanitize HTML in post content', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          title: 'Test Post',
          content: '<script>alert("xss")</script>',
        });

      expect(response.status).toBe(201);
      expect(response.body.content).not.toContain('<script>');
    });

    it('should escape special characters', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          title: 'Test Post',
          content: '<img src=x onerror=alert(1)>',
        });

      expect(response.status).toBe(201);
      expect(response.body.content).not.toContain('onerror');
    });
  });

  describe('CSRF Protection', () => {
    it('should reject requests without CSRF token', async () => {
      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          title: 'Test Post',
          content: 'Test content',
        });

      expect(response.status).toBe(403);
      expect(response.body.error).toBe('CSRF token missing');
    });
  });
});
```

## Running Security Tests

### Commands

```bash
# Run SAST
npm run test:sast

# Run dependency audit
npm audit

# Run OWASP ZAP
npm run test:zap

# Run security tests
npm run test:security

# Run full security scan
npm run security:scan
```

### CI/CD Integration

```yaml
# .github/workflows/security-tests.yml
name: Security Tests

on:
  pull_request:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Security Tests
        run: npm run test:security
        
      - name: Run Dependency Audit
        run: npm audit --audit-level=moderate
        
      - name: Run SAST
        run: npm run test:sast
        
      - name: Upload Security Report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: security-report
          path: security-report.json
```

## Best Practices

### 1. Regular Testing
- Run security tests on every PR
- Perform regular penetration testing
- Keep dependencies updated

### 2. Security Headers
- Implement Content Security Policy
- Use HTTPS everywhere
- Set secure cookie attributes

### 3. Input Validation
- Validate all user input
- Sanitize output data
- Use parameterized queries

### 4. Authentication
- Implement strong password policies
- Use multi-factor authentication
- Secure session management

### 5. Monitoring
- Monitor for suspicious activity
- Log security events
- Set up alerts for anomalies