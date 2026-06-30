# AI Layer Architecture

## Overview

The AI Layer manages content generation through multiple providers with intelligent routing, fallback chains, and cost optimization.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Prompt Orchestration Engine                 │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │ Template │→ │ Variable │→ │  Chain   │→ │ Render  ││   │
│  │  │ Registry │  │ Resolver │  │  Builder │  │  Output ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  Provider Router                        │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │  Health  │→ │  Select  │→ │  Load    │→ │ Fallback││   │
│  │  │  Check   │  │ Provider │  │ Balance  │  │  Chain  ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Response Pipeline                           │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │ Validate │→ │  Parse   │→ │  Format  │→ │  Cache  ││   │
│  │  │  Schema  │  │  Output  │  │  Content │  │ Result  ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  Cost Management                         │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│   │
│  │  │  Token   │→ │  Price   │→ │  Budget  │→ │  Alert  ││   │
│  │  │  Count   │  │  Calc    │  │  Check   │  │  Admin  ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Prompt Management System

### Prompt Template Structure

```typescript
interface PromptTemplate {
  id: string;
  name: string;
  description: string;
  category: string;
  version: number;
  template: string;
  variables: PromptVariable[];
  outputSchema: JsonSchema;
  providerPreferences: ProviderPreference[];
  metadata: {
    createdBy: string;
    createdAt: string;
    updatedAt: string;
    usageCount: number;
    avgRating: number;
  };
}

interface PromptVariable {
  name: string;
  type: 'string' | 'number' | 'boolean' | 'array' | 'object';
  description: string;
  required: boolean;
  defaultValue?: any;
  validation?: {
    minLength?: number;
    maxLength?: number;
    pattern?: string;
    enum?: any[];
  };
}

interface ProviderPreference {
  provider: string;
  model: string;
  priority: number;
  maxTokens?: number;
  temperature?: number;
}
```

### Prompt Registry

```typescript
class PromptRegistry {
  private prompts: Map<string, PromptTemplate> = new Map();

  async registerPrompt(template: Omit<PromptTemplate, 'id'>): Promise<PromptTemplate> {
    const id = generateId();
    const prompt = { ...template, id };
    this.prompts.set(id, prompt);
    await this.persistPrompt(prompt);
    return prompt;
  }

  async getPrompt(id: string, version?: number): Promise<PromptTemplate> {
    const prompt = this.prompts.get(id);
    if (!prompt) throw new PromptNotFoundError(id);
    if (version && prompt.version !== version) {
      return this.getPromptVersion(id, version);
    }
    return prompt;
  }

  async renderPrompt(
    id: string,
    variables: Record<string, any>
  ): Promise<RenderedPrompt> {
    const template = await this.getPrompt(id);

    // Validate variables
    this.validateVariables(template, variables);

    // Render template
    const rendered = this.render(template.template, variables);

    return {
      templateId: id,
      version: template.version,
      rendered,
      outputSchema: template.outputSchema,
      providerPreferences: template.providerPreferences
    };
  }

  private render(template: string, variables: Record<string, any>): string {
    // Handlebars-like template rendering
    return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
      return variables[key] ?? match;
    });
  }
}
```

### Prompt Templates

```typescript
const promptTemplates: Omit<PromptTemplate, 'id'>[] = [
  {
    name: 'social_media_post',
    description: 'Generate a social media post',
    category: 'content',
    version: 1,
    template: `Create a {{platform}} post about {{topic}}.

Target audience: {{audience}}
Tone: {{tone}}
Length: {{length}}
Include hashtags: {{includeHashtags}}

{{#if examples}}
Examples of similar posts:
{{examples}}
{{/if}}

Requirements:
- Engaging and shareable
- Relevant to the topic
- Appropriate for {{platform}} format
- Include a call-to-action`,
    variables: [
      { name: 'platform', type: 'string', required: true, description: 'Social platform' },
      { name: 'topic', type: 'string', required: true, description: 'Post topic' },
      { name: 'audience', type: 'string', required: false, defaultValue: 'general' },
      { name: 'tone', type: 'string', required: false, defaultValue: 'professional' },
      { name: 'length', type: 'string', required: false, defaultValue: 'medium' },
      { name: 'includeHashtags', type: 'boolean', required: false, defaultValue: true },
      { name: 'examples', type: 'string', required: false }
    ],
    outputSchema: {
      type: 'object',
      properties: {
        content: { type: 'string' },
        hashtags: { type: 'array', items: { type: 'string' } },
        mediaSuggestions: { type: 'array', items: { type: 'string' } }
      }
    },
    providerPreferences: [
      { provider: 'openai', model: 'gpt-4', priority: 1 },
      { provider: 'anthropic', model: 'claude-3-opus', priority: 2 },
      { provider: 'google', model: 'gemini-pro', priority: 3 }
    ]
  },
  {
    name: 'content_thread',
    description: 'Generate a Twitter thread',
    category: 'content',
    version: 1,
    template: `Create a Twitter thread about {{topic}}.

Thread length: {{tweetCount}} tweets
Target audience: {{audience}}
Tone: {{tone}}

Structure:
- First tweet: Hook/introduction
- Middle tweets: Key points with examples
- Last tweet: Summary and CTA

Requirements:
- Each tweet under 280 characters
- Maintain coherent narrative
- Use numbered format (1/, 2/, etc.)
- Include relevant hashtags`,
    variables: [
      { name: 'topic', type: 'string', required: true },
      { name: 'tweetCount', type: 'number', required: false, defaultValue: 5 },
      { name: 'audience', type: 'string', required: false },
      { name: 'tone', type: 'string', required: false, defaultValue: 'informative' }
    ],
    outputSchema: {
      type: 'object',
      properties: {
        tweets: { type: 'array', items: { type: 'string' } },
        hashtags: { type: 'array', items: { type: 'string' } }
      }
    },
    providerPreferences: [
      { provider: 'anthropic', model: 'claude-3-opus', priority: 1 },
      { provider: 'openai', model: 'gpt-4', priority: 2 }
    ]
  }
];
```

## Provider Abstraction

### Provider Interface

```typescript
interface AIProvider {
  name: string;
  models: AIModel[];
  isAvailable(): Promise<boolean>;
  generate(request: GenerationRequest): Promise<GenerationResponse>;
  estimateTokens(text: string): number;
  calculateCost(usage: TokenUsage): number;
}

interface AIModel {
  id: string;
  name: string;
  maxTokens: number;
  inputCostPer1kTokens: number;
  outputCostPer1kTokens: number;
  capabilities: ModelCapability[];
}

type ModelCapability =
  | 'text-generation'
  | 'code-generation'
  | 'image-generation'
  | 'multimodal'
  | 'function-calling';

interface GenerationRequest {
  prompt: string;
  model?: string;
  maxTokens?: number;
  temperature?: number;
  topP?: number;
  stopSequences?: string[];
  metadata?: Record<string, any>;
}

interface GenerationResponse {
  content: string;
  model: string;
  usage: TokenUsage;
  finishReason: 'stop' | 'length' | 'content-filter';
  metadata?: Record<string, any>;
}

interface TokenUsage {
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
}
```

### Provider Implementations

```typescript
// OpenAI Provider
class OpenAIProvider implements AIProvider {
  name = 'openai';
  models = [
    {
      id: 'gpt-4',
      name: 'GPT-4',
      maxTokens: 8192,
      inputCostPer1kTokens: 0.03,
      outputCostPer1kTokens: 0.06,
      capabilities: ['text-generation', 'code-generation', 'function-calling']
    },
    {
      id: 'gpt-4-turbo',
      name: 'GPT-4 Turbo',
      maxTokens: 128000,
      inputCostPer1kTokens: 0.01,
      outputCostPer1kTokens: 0.03,
      capabilities: ['text-generation', 'code-generation', 'function-calling', 'multimodal']
    },
    {
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      maxTokens: 4096,
      inputCostPer1kTokens: 0.0005,
      outputCostPer1kTokens: 0.0015,
      capabilities: ['text-generation', 'code-generation']
    }
  ];

  private client: OpenAI;

  constructor(apiKey: string) {
    this.client = new OpenAI({ apiKey });
  }

  async isAvailable(): Promise<boolean> {
    try {
      await this.client.models.list();
      return true;
    } catch {
      return false;
    }
  }

  async generate(request: GenerationRequest): Promise<GenerationResponse> {
    const response = await this.client.chat.completions.create({
      model: request.model || 'gpt-4',
      messages: [{ role: 'user', content: request.prompt }],
      max_tokens: request.maxTokens,
      temperature: request.temperature,
      top_p: request.topP,
      stop: request.stopSequences
    });

    return {
      content: response.choices[0].message.content || '',
      model: response.model,
      usage: {
        promptTokens: response.usage.prompt_tokens,
        completionTokens: response.usage.completion_tokens,
        totalTokens: response.usage.total_tokens
      },
      finishReason: response.choices[0].finish_reason as any
    };
  }

  estimateTokens(text: string): number {
    return Math.ceil(text.length / 4);
  }

  calculateCost(usage: TokenUsage): number {
    const model = this.models.find(m => m.id === 'gpt-4');
    if (!model) return 0;
    return (
      (usage.promptTokens / 1000) * model.inputCostPer1kTokens +
      (usage.completionTokens / 1000) * model.outputCostPer1kTokens
    );
  }
}

// Anthropic Provider
class AnthropicProvider implements AIProvider {
  name = 'anthropic';
  models = [
    {
      id: 'claude-3-opus',
      name: 'Claude 3 Opus',
      maxTokens: 200000,
      inputCostPer1kTokens: 0.015,
      outputCostPer1kTokens: 0.075,
      capabilities: ['text-generation', 'code-generation', 'multimodal']
    },
    {
      id: 'claude-3-sonnet',
      name: 'Claude 3 Sonnet',
      maxTokens: 200000,
      inputCostPer1kTokens: 0.003,
      outputCostPer1kTokens: 0.015,
      capabilities: ['text-generation', 'code-generation', 'multimodal']
    }
  ];

  private client: Anthropic;

  constructor(apiKey: string) {
    this.client = new Anthropic({ apiKey });
  }

  async generate(request: GenerationRequest): Promise<GenerationResponse> {
    const response = await this.client.messages.create({
      model: request.model || 'claude-3-opus',
      max_tokens: request.maxTokens || 4096,
      messages: [{ role: 'user', content: request.prompt }],
      temperature: request.temperature
    });

    return {
      content: response.content[0].text,
      model: response.model,
      usage: {
        promptTokens: response.usage.input_tokens,
        completionTokens: response.usage.output_tokens,
        totalTokens: response.usage.input_tokens + response.usage.output_tokens
      },
      finishReason: response.stop_reason as any
    };
  }

  estimateTokens(text: string): number {
    return Math.ceil(text.length / 3.5);
  }

  calculateCost(usage: TokenUsage): number {
    const model = this.models.find(m => m.id === 'claude-3-opus');
    if (!model) return 0;
    return (
      (usage.promptTokens / 1000) * model.inputCostPer1kTokens +
      (usage.completionTokens / 1000) * model.outputCostPer1kTokens
    );
  }
}
```

## Fallback Chain

### Implementation

```typescript
class FallbackManager {
  private providers: AIProvider[];
  private healthStatus: Map<string, boolean> = new Map();

  constructor(providers: AIProvider[]) {
    this.providers = providers;
    this.startHealthChecks();
  }

  async generateWithFallback(
    request: GenerationRequest,
    preferences: ProviderPreference[]
  ): Promise<GenerationResponse> {
    // Sort by priority
    const sorted = [...preferences].sort((a, b) => a.priority - b.priority);

    for (const pref of sorted) {
      const provider = this.providers.find(p => p.name === pref.provider);
      if (!provider) continue;

      // Check health
      if (this.healthStatus.get(pref.provider) === false) {
        console.log(`Provider ${pref.provider} is unhealthy, skipping`);
        continue;
      }

      try {
        const response = await provider.generate({
          ...request,
          model: pref.model
        });
        return response;
      } catch (error) {
        console.error(`Provider ${pref.provider} failed:`, error);
        this.healthStatus.set(pref.provider, false);
        continue;
      }
    }

    throw new AllProvidersFailedError();
  }

  private startHealthChecks() {
    setInterval(async () => {
      for (const provider of this.providers) {
        try {
          const available = await provider.isAvailable();
          this.healthStatus.set(provider.name, available);
        } catch {
          this.healthStatus.set(provider.name, false);
        }
      }
    }, 60000); // Check every minute
  }
}
```

## Rate Limiting Per Provider

```typescript
interface ProviderRateLimit {
  provider: string;
  requestsPerMinute: number;
  tokensPerMinute: number;
  requestsPerDay: number;
}

class ProviderRateLimiter {
  private limits: Map<string, ProviderRateLimit>;
  private usage: Map<string, UsageWindow>;

  async checkLimit(provider: string, estimatedTokens: number): Promise<boolean> {
    const limit = this.limits.get(provider);
    if (!limit) return true;

    const current = this.usage.get(provider) || {
      requests: 0,
      tokens: 0,
      windowStart: Date.now()
    };

    // Check if window has expired
    if (Date.now() - current.windowStart > 60000) {
      this.usage.set(provider, {
        requests: 0,
        tokens: 0,
        windowStart: Date.now()
      });
      return true;
    }

    // Check limits
    if (current.requests >= limit.requestsPerMinute) return false;
    if (current.tokens + estimatedTokens > limit.tokensPerMinute) return false;

    // Update usage
    current.requests++;
    current.tokens += estimatedTokens;
    this.usage.set(provider, current);

    return true;
  }
}
```

## Caching Strategy

```typescript
class AICacheManager {
  private redis: Redis;

  async getCacheKey(request: GenerationRequest): Promise<string> {
    const hash = crypto
      .createHash('sha256')
      .update(JSON.stringify({
        prompt: request.prompt,
        model: request.model,
        temperature: request.temperature
      }))
      .digest('hex');
    return `ai:cache:${hash}`;
  }

  async getCached(request: GenerationRequest): Promise<GenerationResponse | null> {
    const key = await this.getCacheKey(request);
    const cached = await this.redis.get(key);
    return cached ? JSON.parse(cached) : null;
  }

  async setCached(
    request: GenerationRequest,
    response: GenerationResponse,
    ttl: number = 3600
  ): Promise<void> {
    const key = await this.getCacheKey(request);
    await this.redis.setex(key, ttl, JSON.stringify(response));
  }

  async invalidatePattern(pattern: string): Promise<void> {
    const keys = await this.redis.keys(`ai:cache:${pattern}`);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }
}
```

## Cost Tracking

```typescript
interface CostRecord {
  id: string;
  userId: string;
  organizationId: string;
  provider: string;
  model: string;
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
  cost: number;
  timestamp: string;
  metadata?: Record<string, any>;
}

class CostTracker {
  async trackUsage(record: Omit<CostRecord, 'id' | 'timestamp'>): Promise<void> {
    const fullRecord: CostRecord = {
      ...record,
      id: generateId(),
      timestamp: new Date().toISOString()
    };

    await this.saveRecord(fullRecord);
    await this.updateAggregates(record.organizationId, record.cost);
    await this.checkBudgetLimits(record.organizationId);
  }

  async getUsageSummary(
    organizationId: string,
    period: 'day' | 'week' | 'month'
  ): Promise<UsageSummary> {
    const records = await this.getRecords(organizationId, period);

    return {
      totalCost: records.reduce((sum, r) => sum + r.cost, 0),
      totalTokens: records.reduce((sum, r) => sum + r.totalTokens, 0),
      byProvider: this.groupByProvider(records),
      byModel: this.groupByModel(records),
      dailyTrend: this.getDailyTrend(records)
    };
  }

  private async checkBudgetLimits(organizationId: string): Promise<void> {
    const budget = await this.getBudget(organizationId);
    const currentUsage = await this.getCurrentPeriodUsage(organizationId);

    if (currentUsage >= budget.limit * 0.8) {
      await this.sendBudgetAlert(organizationId, 'warning', currentUsage, budget);
    }

    if (currentUsage >= budget.limit) {
      await this.sendBudgetAlert(organizationId, 'exceeded', currentUsage, budget);
      if (budget.hardLimit) {
        await this.disableAIForOrg(organizationId);
      }
    }
  }
}
```

## Output Validation

```typescript
class OutputValidator {
  async validate(
    response: GenerationResponse,
    schema: JsonSchema
  ): Promise<ValidationResult> {
    const errors: ValidationError[] = [];

    // Schema validation
    const schemaResult = this.validateSchema(response.content, schema);
    if (!schemaResult.valid) {
      errors.push(...schemaResult.errors);
    }

    // Content safety
    const safetyResult = await this.checkContentSafety(response.content);
    if (!safetyResult.safe) {
      errors.push({
        type: 'safety',
        message: 'Content violates safety guidelines',
        details: safetyResult.violations
      });
    }

    // Quality checks
    const qualityResult = this.checkQuality(response.content);
    if (!qualityResult.passed) {
      errors.push(...qualityResult.errors);
    }

    return {
      valid: errors.length === 0,
      errors,
      cleanedContent: this.sanitizeContent(response.content)
    };
  }

  private checkQuality(content: string): QualityResult {
    const errors: ValidationError[] = [];

    // Check length
    if (content.length < 10) {
      errors.push({ type: 'quality', message: 'Content too short' });
    }

    // Check for repetitive content
    if (this.isRepetitive(content)) {
      errors.push({ type: 'quality', message: 'Content is repetitive' });
    }

    // Check for placeholder text
    if (this.hasPlaceholders(content)) {
      errors.push({ type: 'quality', message: 'Content contains placeholders' });
    }

    return { passed: errors.length === 0, errors };
  }

  private sanitizeContent(content: string): string {
    return content
      .replace(/\s+/g, ' ')
      .trim();
  }
}
```
