# Prompt Templates

## Code Generation Template

```
Generate [COMPONENT_TYPE] for [FEATURE_NAME].

## Context
- Project: Social Media AI
- Tech Stack: Flutter, Supabase, PostgreSQL
- Location: [FILE_PATH]

## Requirements
1. [REQUIREMENT_1]
2. [REQUIREMENT_2]
3. [REQUIREMENT_3]

## Constraints
- Follow existing code patterns
- Include error handling
- Add type safety
- Include documentation

## Expected Output
- Complete implementation file
- Unit tests
- Integration with existing code

## Example Usage
```dart
// Show how the component will be used
```
```

---

## Documentation Generation Template

```
Generate [DOCUMENTATION_TYPE] for [FEATURE_NAME].

## Target Audience
- [ ] Developers
- [ ] End Users
- [ ] DevOps
- [ ] Stakeholders

## Content Structure
1. Overview
2. Prerequisites
3. Step-by-step guide
4. Examples
5. Troubleshooting
6. Next steps

## Format Requirements
- Markdown format
- Include code examples
- Include diagrams (Mermaid)
- Include screenshots placeholders

## File Location
[OUTPUT_PATH]
```

---

## Test Generation Template

```
Generate [TEST_TYPE] tests for [COMPONENT_NAME].

## Test Framework
- Flutter: flutter_test
- Backend: pytest/jest

## Coverage Requirements
- Unit tests: [COVERAGE]%
- Integration tests: [COVERAGE]%

## Test Cases to Cover
1. Happy path
2. Edge cases
3. Error handling
4. Boundary conditions
5. Performance scenarios

## Mocking Strategy
- External services: Mock
- Database: In-memory/Test DB
- File system: Mock

## Expected Output
- Test file(s)
- Mock implementations
- Test data fixtures
```

---

## Refactoring Template

```
Refactor [COMPONENT_NAME] to improve [QUALITY].

## Current Issues
1. [ISSUE_1]
2. [ISSUE_2]
3. [ISSUE_3]

## Refactoring Goals
- Improve [METRIC]
- Reduce [METRIC]
- Enhance [METRIC]

## Constraints
- Maintain existing API
- Preserve functionality
- Keep backward compatibility
- Follow existing patterns

## Expected Changes
1. File modifications
2. New abstractions
3. Updated tests
4. Documentation updates

## Verification
- All tests pass
- No breaking changes
- Performance maintained/improved
```

---

## Bug Fix Template

```
Fix bug: [BUG_DESCRIPTION].

## Bug Details
- Component: [COMPONENT]
- Location: [FILE:LINE]
- Severity: [Critical/High/Medium/Low]

## Reproduction Steps
1. [STEP_1]
2. [STEP_2]
3. [STEP_3]

## Expected Behavior
[DESCRIPTION]

## Actual Behavior
[DESCRIPTION]

## Root Cause Analysis
- [ ] Null safety issue
- [ ] Race condition
- [ ] Logic error
- [ ] API misuse
- [ ] State management

## Fix Approach
[DESCRIPTION]

## Verification
- [ ] Bug is fixed
- [ ] No regressions
- [ ] Tests added/updated
- [ ] Documentation updated
```

---

## Code Review Template

```
Review [COMPONENT_NAME] for [REVIEW_TYPE].

## Review Criteria

### Code Quality
- [ ] Follows coding standards
- [ ] Proper naming conventions
- [ ] DRY principle applied
- [ ] SOLID principles followed
- [ ] Comments where needed

### Functionality
- [ ] Requirements met
- [ ] Edge cases handled
- [ ] Error handling complete
- [ ] Input validation present

### Performance
- [ ] No unnecessary computations
- [ ] Efficient data structures
- [ ] Memory management good
- [ ] No memory leaks

### Security
- [ ] Input sanitization
- [ ] Authentication checks
- [ ] Authorization checks
- [ ] No secrets exposed

### Testing
- [ ] Unit tests present
- [ ] Integration tests present
- [ ] Edge cases covered
- [ ] Mocks properly used

### Documentation
- [ ] Code comments
- [ ] API documentation
- [ ] README updated
- [ ] Changelog updated

## Findings
| Severity | Issue | Location | Suggestion |
|----------|-------|----------|------------|
| | | | |

## Verdict
- [ ] Approve
- [ ] Request changes
- [ ] Needs discussion
```

---

## Feature Implementation Template

```
Implement [FEATURE_NAME].

## Feature Description
[DETAILED_DESCRIPTION]

## User Stories
1. As a [USER], I want [FEATURE] so that [BENEFIT]
2. As a [USER], I want [FEATURE] so that [BENEFIT]

## Technical Requirements
- Frontend: [COMPONENTS]
- Backend: [ENDPOINTS]
- Database: [TABLES/COLUMNS]
- Integration: [SERVICES]

## Implementation Plan
1. [ ] Database schema changes
2. [ ] Backend API endpoints
3. [ ] Frontend components
4. [ ] Integration testing
5. [ ] Documentation
6. [ ] Deployment

## Files to Create/Modify
- [FILE_1]: [DESCRIPTION]
- [FILE_2]: [DESCRIPTION]
- [FILE_3]: [DESCRIPTION]

## Dependencies
- [DEPENDENCY_1]
- [DEPENDENCY_2]

## Acceptance Criteria
- [ ] [CRITERIA_1]
- [ ] [CRITERIA_2]
- [ ] [CRITERIA_3]

## Estimated Effort
- [X] hours/days
```

---

## Migration Template

```
Generate database migration for [CHANGE_DESCRIPTION].

## Migration Details
- Type: [CREATE/ALTER/DROP]
- Table(s): [TABLE_NAMES]
- Purpose: [DESCRIPTION]

## Changes
```sql
-- Up migration
[SQL_STATEMENTS]

-- Down migration (rollback)
[SQL_STATEMENTS]
```

## Data Migration
- [ ] No data migration needed
- [ ] Data migration required

## Verification
- [ ] Schema validated
- [ ] Indexes created
- [ ] RLS policies updated
- [ ] Functions updated
- [ ] Tests pass

## Rollback Plan
1. [ROLLBACK_STEP_1]
2. [ROLLBACK_STEP_2]
```

---

## API Endpoint Template

```
Generate [METHOD] [ENDPOINT] endpoint.

## Endpoint Details
- Method: [GET/POST/PATCH/DELETE]
- Path: [ENDPOINT_PATH]
- Auth: [Required/Optional]
- Rate Limit: [LIMIT]

## Request
### Headers
```
Authorization: Bearer <token>
Content-Type: application/json
```

### Body (if applicable)
```json
{
  "field": "type"
}
```

### Query Params (if applicable)
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| | | | |

## Response

### Success (200/201)
```json
{
  "success": true,
  "data": {}
}
```

### Error
| Code | Description |
|------|-------------|
| 400 | Bad request |
| 401 | Unauthorized |
| 404 | Not found |

## Implementation
- Service: [SERVICE_METHOD]
- Validation: [VALIDATION_RULES]
- Business Logic: [DESCRIPTION]

## Tests
- Unit: [TEST_DESCRIPTION]
- Integration: [TEST_DESCRIPTION]
```

---

## Widget Component Template

```
Generate [WIDGET_NAME] Flutter widget.

## Widget Purpose
[DESCRIPTION]

## Props/Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| | | | | |

## States
| State | Type | Description |
|-------|------|-------------|
| | | |

## Visual Design
- Layout: [Column/Row/Stack/etc]
- Responsive: [Yes/No]
- Theme: [Light/Dark/Both]

## Accessibility
- Semantics label: [LABEL]
- Minimum tap target: 48x48
- Screen reader: [Yes/No]

## Files to Create
- [WIDGET_FILE]
- [TEST_FILE]
- [STORY_FILE] (if using storybook)

## Example Usage
```dart
WidgetName(
  param1: value1,
  param2: value2,
)
```
```

---

## Service Layer Template

```
Generate [SERVICE_NAME] service.

## Service Purpose
[DESCRIPTION]

## Dependencies
- [DEPENDENCY_1]
- [DEPENDENCY_2]

## Methods
| Method | Parameters | Return | Description |
|--------|------------|--------|-------------|
| | | | |

## Error Handling
| Error | Type | Action |
|-------|------|--------|
| | | |

## Caching Strategy
- Cache type: [In-memory/Redis/None]
- TTL: [DURATION]
- Invalidation: [STRATEGY]

## Rate Limiting
- Limit: [NUMBER]
- Window: [DURATION]
- Scope: [User/IP/Global]

## Testing
- Unit tests: [COVERAGE]%
- Mock strategy: [DESCRIPTION]

## Implementation
```dart
// Service interface
abstract class [ServiceName] {
  // Method signatures
}

// Implementation
class [ServiceName]Impl implements [ServiceName] {
  // Implementation
}
```
```

---

## Database Schema Template

```
Generate [TABLE_NAME] database table.

## Table Purpose
[DESCRIPTION]

## Columns
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| | | | | |

## Constraints
- Primary Key: id
- Foreign Keys: [FK_DEFINITIONS]
- Unique: [UNIQUE_CONSTRAINTS]
- Check: [CHECK_CONSTRAINTS]

## Indexes
| Index | Columns | Type | Purpose |
|-------|---------|------|---------|
| | | | |

## RLS Policies
| Policy | Operation | Rule |
|--------|-----------|------|
| | | |

## Triggers
| Trigger | Event | Function |
|---------|-------|----------|
| | | |

## Migration SQL
```sql
CREATE TABLE [table_name] (
  -- columns
);

-- Indexes
CREATE INDEX idx_[table]_[column] ON [table]([column]);
```
```

---

## Environment Configuration Template

```
Configure [ENVIRONMENT] environment.

## Environment Details
- Name: [dev/staging/production]
- URL: [URL]
- Purpose: [DESCRIPTION]

## Variables
| Variable | Value | Secret | Description |
|----------|-------|--------|-------------|
| | | | |

## Services
| Service | Plan | Purpose |
|---------|------|---------|
| | | |

## Secrets Management
- Provider: [Supabase Vault/AWS Secrets/Environment]
- Rotation: [FREQUENCY]
- Access: [TEAM/MEMBERS]

## Monitoring
- Error Tracking: [Sentry/LogRocket]
- Analytics: [Mixpanel/Amplitude]
- Uptime: [Pingdom/UptimeRobot]

## Deployment
- CI/CD: [GitHub Actions/Other]
- Branch: [main/develop]
- Auto-deploy: [Yes/No]
```
