# User Acceptance Testing (UAT) Guide

## Overview

User Acceptance Testing validates that the application meets business requirements and user expectations before production deployment.

## UAT Plan Template

### UAT Plan Document

```markdown
# User Acceptance Testing Plan

## Project Information
- **Project Name:** Social Media AI
- **Version:** 1.0.0
- **UAT Start Date:** [Date]
- **UAT End Date:** [Date]
- **UAT Lead:** [Name]
- **Stakeholders:** [Names]

## Objectives
1. Verify application meets business requirements
2. Validate user workflows and processes
3. Identify any usability issues
4. Ensure application is ready for production

## Scope
### In Scope
- User registration and authentication
- Post creation and management
- Comment and like functionality
- User profile management
- Search functionality
- Mobile responsiveness

### Out of Scope
- Performance testing (covered in load testing)
- Security testing (covered in security testing)
- Integration testing (covered in integration testing)

## Test Environment
- **URL:** https://uat.socialmediaai.com
- **Database:** UAT database (separate from production)
- **Test Data:** Pre-loaded test accounts and data

## Test Schedule
| Phase | Start Date | End Date | Duration |
|-------|------------|----------|----------|
| Test Case Review | [Date] | [Date] | 2 days |
| Test Execution | [Date] | [Date] | 5 days |
| Bug Fix Verification | [Date] | [Date] | 2 days |
| Sign-off | [Date] | [Date] | 1 day |

## Resources
### Test Team
- [Name] - UAT Lead
- [Name] - Business Analyst
- [Name] - End User Representative
- [Name] - QA Engineer

### Tools
- Test Management: [Tool Name]
- Bug Tracking: [Tool Name]
- Communication: [Tool Name]

## Entry Criteria
- [ ] All test cases reviewed and approved
- [ ] Test environment set up and verified
- [ ] Test data loaded and verified
- [ ] Development team completed all features
- [ ] All critical bugs fixed

## Exit Criteria
- [ ] All test cases executed
- [ ] 100% of critical test cases passed
- [ ] 95% of high priority test cases passed
- [ ] All critical bugs fixed and verified
- [ ] Stakeholder sign-off obtained

## Risks and Mitigation
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Environment issues | Medium | High | Have backup environment ready |
| Resource availability | Low | Medium | Cross-train team members |
| Scope creep | Medium | Medium | Strict change control process |

## Approvals
- [ ] Project Manager
- [ ] Business Owner
- [ ] QA Lead
- [ ] Development Lead
```

## Test Scenarios

### User Registration Scenarios

```markdown
## User Registration Test Scenarios

### Scenario 1: New User Registration
**Priority:** Critical
**Precondition:** User is on registration page

**Steps:**
1. Navigate to registration page
2. Enter valid email address
3. Enter valid password
4. Enter display name
5. Click "Register" button
6. Verify email verification link sent
7. Click verification link
8. Verify account is activated

**Expected Result:** User account is created and activated

### Scenario 2: Duplicate Email Registration
**Priority:** High
**Precondition:** User with email exists in system

**Steps:**
1. Navigate to registration page
2. Enter existing email address
3. Enter password
4. Enter display name
5. Click "Register" button

**Expected Result:** Error message displayed "Email already exists"

### Scenario 3: Weak Password Registration
**Priority:** High
**Precondition:** User is on registration page

**Steps:**
1. Navigate to registration page
2. Enter valid email address
3. Enter weak password (e.g., "123")
4. Enter display name
5. Click "Register" button

**Expected Result:** Error message displayed about password requirements
```

### Post Creation Scenarios

```markdown
## Post Creation Test Scenarios

### Scenario 1: Create Text Post
**Priority:** Critical
**Precondition:** User is logged in

**Steps:**
1. Click "Create Post" button
2. Enter post title
3. Enter post content
4. Add tags (optional)
5. Click "Publish" button

**Expected Result:** Post is created and appears in feed

### Scenario 2: Create Post with Image
**Priority:** High
**Precondition:** User is logged in

**Steps:**
1. Click "Create Post" button
2. Enter post title
3. Enter post content
4. Click "Add Image" button
5. Select image file
6. Wait for image upload
7. Click "Publish" button

**Expected Result:** Post with image is created and appears in feed

### Scenario 3: Edit Existing Post
**Priority:** High
**Precondition:** User is logged in and owns the post

**Steps:**
1. Navigate to own post
2. Click "Edit" button
3. Modify post title
4. Modify post content
5. Click "Save Changes" button

**Expected Result:** Post is updated with new content

### Scenario 4: Delete Post
**Priority:** Medium
**Precondition:** User is logged in and owns the post

**Steps:**
1. Navigate to own post
2. Click "Delete" button
3. Confirm deletion in dialog

**Expected Result:** Post is removed from feed
```

### Comment System Scenarios

```markdown
## Comment System Test Scenarios

### Scenario 1: Add Comment
**Priority:** Critical
**Precondition:** User is logged in

**Steps:**
1. Navigate to a post
2. Scroll to comment section
3. Enter comment text
4. Click "Post Comment" button

**Expected Result:** Comment appears under the post

### Scenario 2: Reply to Comment
**Priority:** High
**Precondition:** User is logged in

**Steps:**
1. Navigate to a post with comments
2. Click "Reply" on existing comment
3. Enter reply text
4. Click "Post Reply" button

**Expected Result:** Reply appears under the original comment

### Scenario 3: Delete Comment
**Priority:** Medium
**Precondition:** User is logged in and owns the comment

**Steps:**
1. Navigate to own comment
2. Click "Delete" button
3. Confirm deletion

**Expected Result:** Comment is removed
```

## Acceptance Criteria

### Feature Acceptance Criteria

```typescript
// tests/acceptance/user-registration.acceptance.ts
import request from 'supertest';
import app from '../../src/app';

describe('User Registration Acceptance Criteria', () => {
  describe('AC-1: User can register with valid data', () => {
    it('should create user account', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'acceptance@example.com',
          password: 'SecurePass123!',
          name: 'Acceptance Test User',
        });

      expect(response.status).toBe(201);
      expect(response.body.user).toBeDefined();
      expect(response.body.user.email).toBe('acceptance@example.com');
      expect(response.body.user.name).toBe('Acceptance Test User');
      expect(response.body.token).toBeDefined();
    });

    it('should send verification email', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'verify@example.com',
          password: 'SecurePass123!',
          name: 'Verify Test User',
        });

      expect(response.status).toBe(201);
      expect(response.body.verificationSent).toBe(true);
    });
  });

  describe('AC-2: User cannot register with invalid data', () => {
    it('should reject invalid email', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'invalid-email',
          password: 'SecurePass123!',
          name: 'Invalid Email User',
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'email',
          message: 'Invalid email format',
        })
      );
    });

    it('should reject weak password', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'weak@example.com',
          password: '123',
          name: 'Weak Password User',
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'password',
          message: 'Password does not meet requirements',
        })
      );
    });

    it('should reject duplicate email', async () => {
      // First registration
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'duplicate@example.com',
          password: 'SecurePass123!',
          name: 'First User',
        });

      // Second registration with same email
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'duplicate@example.com',
          password: 'SecurePass123!',
          name: 'Second User',
        });

      expect(response.status).toBe(409);
      expect(response.body.error).toBe('Email already exists');
    });
  });

  describe('AC-3: User can verify email', () => {
    it('should verify email with valid token', async () => {
      const registerResponse = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'verify@example.com',
          password: 'SecurePass123!',
          name: 'Verify Test User',
        });

      const verificationToken = registerResponse.body.verificationToken;

      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: verificationToken });

      expect(response.status).toBe(200);
      expect(response.body.verified).toBe(true);
    });

    it('should reject invalid verification token', async () => {
      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: 'invalid-token' });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Invalid verification token');
    });
  });
});
```

### User Story Acceptance Criteria

```markdown
## User Story: As a user, I want to create posts

### Acceptance Criteria:
1. **Given** I am logged in
   **When** I click "Create Post"
   **Then** I should see a post creation form

2. **Given** I am on the post creation form
   **When** I enter a title and content
   **Then** the "Publish" button should be enabled

3. **Given** I have entered valid post data
   **When** I click "Publish"
   **Then** my post should appear in the feed

4. **Given** I have entered invalid post data
   **When** I click "Publish"
   **Then** I should see validation errors

5. **Given** I have created a post
   **When** I view my profile
   **Then** I should see my post in my post list
```

## Sign-off Process

### Sign-off Document

```markdown
# UAT Sign-off Document

## Project Information
- **Project:** Social Media AI
- **Version:** 1.0.0
- **UAT Period:** [Start Date] to [End Date]

## Test Execution Summary
| Test Category | Total | Passed | Failed | Pass Rate |
|---------------|-------|--------|--------|-----------|
| Critical | 25 | 25 | 0 | 100% |
| High | 50 | 49 | 1 | 98% |
| Medium | 30 | 29 | 1 | 96.7% |
| Low | 20 | 20 | 0 | 100% |
| **Total** | **125** | **123** | **2** | **98.4%** |

## Critical Issues Found
| Issue ID | Description | Status |
|----------|-------------|--------|
| UAT-001 | Post deletion not working on mobile | Fixed |
| UAT-002 | Comment sorting issue | Fixed |

## Sign-off Criteria Met
- [x] All critical test cases passed
- [x] 95%+ of high priority test cases passed
- [x] All critical bugs fixed and verified
- [x] Performance requirements met
- [x] Security requirements met
- [x] Accessibility requirements met

## Approvals

### Business Owner
- **Name:** [Name]
- **Signature:** _______________
- **Date:** [Date]
- **Comments:** [Comments]

### Project Manager
- **Name:** [Name]
- **Signature:** _______________
- **Date:** [Date]
- **Comments:** [Comments]

### QA Lead
- **Name:** [Name]
- **Signature:** _______________
- **Date:** [Date]
- **Comments:** [Comments]

### Development Lead
- **Name:** [Name]
- **Signature:** _______________
- **Date:** [Date]
- **Comments:** [Comments]

## Recommendations
1. Proceed with production deployment
2. Monitor application closely for first 24 hours
3. Have rollback plan ready
4. Schedule post-deployment review

## Attachments
- [ ] Full test execution report
- [ ] Bug report summary
- [ ] Performance test results
- [ ] Security scan results
```

## Running UAT Tests

### Commands

```bash
# Run UAT tests
npm run test:uat

# Run specific UAT scenario
npm run test:uat -- --grep "User Registration"

# Generate UAT report
npm run test:uat:report

# Run UAT with coverage
npm run test:uat:coverage
```

### CI/CD Integration

```yaml
# .github/workflows/uat.yml
name: User Acceptance Testing

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'UAT Environment'
        required: true
        default: 'uat'
        type: choice
        options:
          - uat
          - staging

jobs:
  uat:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run UAT tests
        run: npm run test:uat
        env:
          UAT_URL: ${{ secrets.UAT_URL }}
          
      - name: Generate UAT report
        run: npm run test:uat:report
        
      - name: Upload UAT report
        uses: actions/upload-artifact@v3
        with:
          name: uat-report
          path: uat-report/
```

## Best Practices

### 1. Test Planning
- Involve stakeholders early
- Define clear acceptance criteria
- Prioritize test scenarios

### 2. Test Execution
- Use real-world scenarios
- Test with production-like data
- Document all issues found

### 3. Communication
- Regular status updates
- Clear issue reporting
- Stakeholder involvement

### 4. Sign-off Process
- Clear sign-off criteria
- Document all decisions
- Get formal approvals

### 5. Post-UAT Activities
- Verify all issues fixed
- Update documentation
- Prepare for production deployment