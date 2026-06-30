# Prompt Engineering Guide

## Overview

Best practices for crafting effective prompts, including structure, techniques, output formatting, temperature settings, A/B testing, and version control.

---

## Prompt Structure

### Anatomy of a Good Prompt

```
┌─────────────────────────────────────────┐
│ 1. SYSTEM PROMPT                        │
│    - Role definition                    │
│    - Rules and constraints              │
│    - Output format specification        │
├─────────────────────────────────────────┤
│ 2. CONTEXT                              │
│    - Background information             │
│    - Relevant examples                  │
│    - Current state/data                 │
├─────────────────────────────────────────┤
│ 3. TASK                                 │
│    - Clear objective                    │
│    - Specific requirements              │
│    - Constraints                        │
├─────────────────────────────────────────┤
│ 4. OUTPUT FORMAT                        │
│    - Structure specification            │
│    - Example output                     │
│    - Validation rules                   │
└─────────────────────────────────────────┘
```

### Prompt Template Structure

```yaml
prompt_template:
  id: "unique-identifier"
  version: "1.0.0"
  
  system: |
    You are [role]. You [expertise].
    
    Rules:
    - [Rule 1]
    - [Rule 2]
    - [Rule 3]
  
  context: |
    Background: [relevant context]
    Examples: [few-shot examples]
  
  user_template: |
    Task: [specific task]
    
    Input Variables:
    - {variable1}: [description]
    - {variable2}: [description]
    
    Output Format: [format specification]
  
  output_format: |
    Return as JSON:
    {
      "field1": "value",
      "field2": ["value"]
    }
```

---

## Prompt Techniques

### 1. Zero-Shot Prompting

No examples provided. Best for simple, clear tasks.

```
System: You are a social media expert.

User: Write an Instagram caption about email marketing tips.

Output: [Generated caption]
```

### 2. Few-Shot Prompting

Include examples to guide output format and style.

```
System: You are a social media expert.

User: Write Instagram captions in this style:

Example 1:
Topic: Productivity tips
Caption: "5 ways to 10x your productivity: ..."

Example 2:
Topic: Marketing strategy
Caption: "The marketing strategy nobody talks about: ..."

Now write for: Email marketing tips
```

### 3. Chain-of-Thought (CoT)

Have the model think step-by-step before answering.

```
System: You are a content strategist.

User: Analyze this content and suggest improvements.

Think step-by-step:
1. First, identify the target audience
2. Then, evaluate the hook effectiveness
3. Next, assess the value delivery
4. Finally, suggest specific improvements

Content: [content to analyze]
```

### 4. Role-Playing

Assign a specific role to get specialized outputs.

```
System: You are a viral content analyst who has studied 10,000 viral posts. You understand exactly what makes content shareable.

User: Analyze this content for viral potential:

[content]
```

### 5. Constraint-Based

Set clear constraints to control output.

```
System: You are a copywriter.

User: Write a tweet about AI marketing.

Constraints:
- Maximum 280 characters
- Include one statistic
- End with a question
- No hashtags
- Professional tone
```

### 6. Template Filling

Provide a template and have the model fill it.

```
System: You are a content creator.

User: Fill in this template for an Instagram caption:

Hook: [attention-grabbing first line]
Value: [key takeaway]
Details: [2-3 supporting points]
CTA: [call to action]
Hashtags: [relevant hashtags]

Topic: Email marketing tips
```

### 7. Iterative Refinement

Start with a draft and refine through follow-ups.

```
User: Write a LinkedIn post about leadership.
[Model generates draft]

User: Make it more personal and add a specific example.
[Model refines]

User: Shorten it by 30% and make the hook stronger.
[Model refines again]
```

---

## Output Formatting

### JSON Output

```
Output Format: Return as valid JSON with the following structure:

{
  "caption": "string - The generated caption",
  "hashtags": ["string - Array of hashtags"],
  "engagement_score": "number - Predicted engagement 1-10",
  "tone": "string - Detected tone",
  "word_count": "number - Total words"
}
```

### Structured Text

```
Output Format:

TITLE: [title]
HOOK: [first line]
BODY: [main content]
CTA: [call to action]
HASHTAGS: [comma-separated hashtags]
CHAR_COUNT: [character count]
```

### Table Format

```
Output Format:

| Option | Caption | Character Count | Predicted Engagement |
|--------|---------|-----------------|---------------------|
| 1      | [text]  | [number]        | [score]             |
| 2      | [text]  | [number]        | [score]             |
| 3      | [text]  | [number]        | [score]             |
```

### YAML Output

```
Output Format: Return as YAML

caption: "The generated caption"
hashtags:
  - "hashtag1"
  - "hashtag2"
metadata:
  word_count: 50
  sentiment: positive
  tone: professional
```

---

## Temperature Settings

### Temperature Guide

| Task Type | Temperature | Reasoning |
|-----------|-------------|-----------|
| Factual content | 0.1 - 0.3 | Low creativity, high accuracy |
| Educational content | 0.3 - 0.5 | Balanced, informative |
| Marketing copy | 0.5 - 0.7 | Creative but on-brand |
| Creative writing | 0.7 - 0.9 | High creativity |
| Brainstorming | 0.8 - 1.0 | Maximum variety |

### Other Parameters

```typescript
interface GenerationParams {
  temperature: number;      // 0-2, controls randomness
  top_p: number;           // 0-1, nucleus sampling
  frequency_penalty: number; // 0-2, reduces repetition
  presence_penalty: number;  // 0-2, encourages new topics
  max_tokens: number;       // Maximum output length
  stop: string[];          // Stop sequences
}

const PARAMETER_PRESETS = {
  precise: {
    temperature: 0.1,
    top_p: 0.9,
    frequency_penalty: 0,
    presence_penalty: 0,
  },
  
  balanced: {
    temperature: 0.7,
    top_p: 0.9,
    frequency_penalty: 0.3,
    presence_penalty: 0.3,
  },
  
  creative: {
    temperature: 0.9,
    top_p: 0.95,
    frequency_penalty: 0.5,
    presence_penalty: 0.5,
  },
};
```

---

## A/B Testing Prompts

### Testing Framework

```typescript
interface PromptTest {
  id: string;
  name: string;
  variants: PromptVariant[];
  metrics: TestMetrics;
  status: 'running' | 'completed' | 'paused';
  startDate: Date;
  endDate?: Date;
}

interface PromptVariant {
  id: string;
  prompt: string;
  params: GenerationParams;
  results: GenerationResult[];
}

interface TestMetrics {
  qualityScore: number;
  engagementRate: number;
  conversionRate: number;
  costPerRequest: number;
  latencyMs: number;
}
```

### What to A/B Test

| Element | Test Variables | Success Metric |
|---------|---------------|----------------|
| Hook | Question vs Statement vs Number | Engagement rate |
| Length | Short vs Medium vs Long | Completion rate |
| Tone | Professional vs Casual | Brand alignment |
| CTA | Comment vs Share vs Save | Action taken |
| Format | List vs Story vs Data | Read time |
| Hashtags | Few vs Many vs None | Reach |

### A/B Test Template

```yaml
ab_test:
  id: "caption-hook-test-001"
  name: "Caption Hook Style Test"
  
  hypothesis: "Question hooks will outperform statement hooks"
  
  variants:
    variant_a:
      name: "Question Hook"
      prompt: "Start with a question that creates curiosity"
      sample_size: 100
    
    variant_b:
      name: "Statement Hook"
      prompt: "Start with a bold, confident statement"
      sample_size: 100
  
  metrics:
    primary: "engagement_rate"
    secondary: ["saves", "shares", "comments"]
  
  duration: "7 days"
  
  success_criteria:
    statistical_significance: 0.95
    minimum_improvement: 10%
```

---

## Prompt Version Control

### Version Control System

```yaml
prompt_versioning:
  naming_convention: "semantic"
  format: "major.minor.patch"
  
  version_types:
    major: "Breaking changes to prompt structure"
    minor: "New features or significant improvements"
    patch: "Bug fixes, small adjustments"
  
  storage:
    location: "prompts/"
    format: "yaml"
    backup: "git"
```

### Version Tracking Template

```yaml
prompt_history:
  prompt_id: "instagram-caption-professional"
  
  versions:
    - version: "1.0.0"
      date: "2024-01-01"
      author: "system"
      changes: "Initial prompt creation"
      performance:
        quality_score: 7.5
        success_rate: 95%
    
    - version: "1.1.0"
      date: "2024-01-15"
      author: "admin"
      changes: "Added tone variations"
      performance:
        quality_score: 8.2
        success_rate: 97%
    
    - version: "2.0.0"
      date: "2024-02-01"
      author: "admin"
      changes: "Restructured for better output consistency"
      performance:
        quality_score: 8.8
        success_rate: 99%
```

### Version Control Rules

```
1. Every prompt change gets a new version
2. Test before deploying new versions
3. Keep backup of previous versions
4. Document all changes
5. Roll back if quality drops
6. Tag major versions for reference
```

---

## Prompt Optimization Checklist

### Before Creating a Prompt

```
□ Define clear objective
□ Identify target output format
□ Consider edge cases
□ Plan for validation
□ Estimate token usage
□ Set quality thresholds
```

### During Prompt Creation

```
□ Be specific and unambiguous
□ Use clear role definition
□ Include relevant examples
□ Set explicit constraints
□ Define output format
□ Handle edge cases
```

### After Prompt Creation

```
□ Test with various inputs
□ Validate output format
□ Check for consistency
□ Measure quality scores
□ Document performance
□ Set up monitoring
```

---

## Common Prompt Patterns

### Pattern: Content Generator

```
System: You are a {niche} content expert.

User: Generate {content_type} about {topic}.

Requirements:
- Target audience: {audience}
- Tone: {tone}
- Length: {length}
- Platform: {platform}

Output format: {format}
```

### Pattern: Content Optimizer

```
System: You are a content optimization expert.

User: Optimize this content for {platform}:

Original: {content}

Optimize for:
- Platform character limits
- Algorithm preferences
- Audience engagement
- SEO (if applicable)

Provide optimized version with changes explained.
```

### Pattern: Content Analyzer

```
System: You are a content performance analyst.

User: Analyze this content:

Content: {content}
Platform: {platform}
Metrics: {metrics}

Provide:
1. Strengths
2. Weaknesses
3. Improvement suggestions
4. Score (1-10)
```

### Pattern: Content Repurposer

```
System: You are a content repurposing specialist.

User: Repurpose this content for {target_platform}:

Original: {content}
Original Platform: {original_platform}

Rules:
- Maintain core message
- Adapt to platform conventions
- Optimize for target audience
- Keep brand voice consistent

Provide repurposed version.
```

---

## Prompt Anti-Patterns

### Avoid These Mistakes

```
❌ Too vague: "Write something about marketing"
✅ Specific: "Write a 140-character tweet about email marketing open rates"

❌ Too many instructions: [50 different requirements]
✅ Focused: [3-5 clear requirements]

❌ No examples: [expecting perfect output]
✅ Few-shot: [1-3 examples of desired output]

❌ Ambiguous output format: "Make it good"
✅ Clear format: "Return as JSON with keys: title, body, hashtags"

❌ No constraints: "Write a caption"
✅ Constrained: "Write a caption under 150 characters with a CTA"
```
