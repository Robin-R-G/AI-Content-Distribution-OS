# Volume 11: AI Coding Prompts Overview

## Purpose

This volume provides optimized prompts for AI coding assistants to generate complete development artifacts for the Social Media AI platform. Each prompt is designed to produce structured, production-ready output including PRDs, TRDs, code, schemas, tests, and documentation.

## Supported AI Coding Tools

| Tool | Model | Best For | Tips |
|------|-------|----------|------|
| **OpenCode** | Various | CLI-based coding, file operations | Use `/init` to bootstrap, provide context via files |
| **Claude Code** | Claude 4 | Complex reasoning, architecture | Be explicit about constraints, use system prompts |
| **Gemini CLI** | Gemini 2.5 | Multi-file edits, search | Leverage grounding, reference existing files |
| **Codex** | GPT-4 | Code generation, refactoring | Provide example outputs, use structured prompts |

## How to Use These Prompts

### 1. Context Setup

Before using any prompt, ensure the AI has access to:
- Previous phase outputs (PRD → Architecture → Code)
- Project conventions file (`CONVENTIONS.md`)
- Tech stack reference (`tech-stack.md`)
- Existing codebase structure

### 2. Prompt Execution Flow

```
Phase N Output → Context Window → Phase N+1 Prompt → Generated Output → Review → Commit
```

### 3. Prompt Structure

Each prompt follows this format:

```markdown
## [Prompt Name]
**Phase:** X-Y  
**Output:** What gets generated  
**Inputs:** Required context  

[The actual prompt]

**Expected Output:** Structure description
```

## Best Practices

### Prompt Engineering

1. **Be Specific**: Include exact file paths, table names, API routes
2. **Provide Examples**: Show desired output format
3. **Set Constraints**: Define max lines, coding standards, patterns
4. **Chain Prompts**: Reference previous outputs explicitly
5. **Validate Output**: Always verify generated code compiles/runs

### Multi-Tool Strategy

| Task | Recommended Tool | Reason |
|------|-----------------|--------|
| Schema design | Claude Code | Strong at relational modeling |
| Flutter UI | Gemini CLI | Good at widget composition |
| API endpoints | OpenCode | CLI-native file operations |
| Tests | Codex | Thorough test generation |
| Documentation | Any | Markdown generation is universal |

### Quality Checklist

- [ ] Generated code compiles without errors
- [ ] Follows project conventions (naming, structure)
- [ ] Includes proper error handling
- [ ] Has corresponding tests
- [ ] Documentation is accurate
- [ ] No hardcoded secrets or values
- [ ] Follows security best practices

## Prompt Versioning

```
prompt-v{VERSION}-{PHASE}-{NAME}.md
Example: prompt-v1.0-phase3-auth-screens.md
```

## Customization

### Adding New Prompts

1. Copy template from `prompt-templates.md`
2. Fill in phase-specific details
3. Add expected output structure
4. Test with each AI tool
5. Document tool-specific notes

### Modifying Existing Prompts

1. Version the change (v1.0 → v1.1)
2. Update compatibility notes
3. Test across all supported tools
4. Update this overview

## File Structure

```
11-ai-coding-prompts/
├── overview.md                    # This file
├── phase-0-foundation.md          # Business analysis prompts
├── phase-1-prd.md                 # Product requirements
├── phase-2-architecture.md        # System architecture
├── phase-3-ui-ux.md               # Flutter UI generation
├── phase-4-database.md            # PostgreSQL schemas
├── phase-5-api.md                 # API endpoints
├── phase-6-ai.md                  # AI/ML prompts
├── phase-7-integrations.md        # Platform integrations
├── phase-8-security.md            # Security implementation
├── phase-9-testing.md             # Test generation
├── phase-10-deployment.md         # DevOps & deployment
├── phase-11-polish.md             # Documentation & polish
└── prompt-templates.md            # Reusable templates
```

## Tips for Maximum Output Quality

### For Code Generation
```
Include in prompt:
- Exact file path for output
- Import list (dependencies)
- Type definitions/interfaces
- Error handling pattern
- Example usage
```

### For Documentation
```
Include in prompt:
- Target audience (developer, user, ops)
- Format (markdown, wiki, PDF)
- Level of detail (overview, reference, tutorial)
- Cross-references to include
```

### For Tests
```
Include in prompt:
- Test framework (flutter_test, pytest, jest)
- Coverage targets
- Mocking strategy
- Edge cases to cover
- Assertion style
```
