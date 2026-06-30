# Provider Configuration

## Overview

Multi-provider AI configuration with selection strategy, fallback chain, rate limits, and cost comparison.

---

## Provider Overview

```yaml
providers:
  openai:
    name: "OpenAI"
    status: "active"
    priority: 1
    
  anthropic:
    name: "Anthropic"
    status: "active"
    priority: 2
    
  google:
    name: "Google AI"
    status: "active"
    priority: 3
    
  local:
    name: "Local LLM"
    status: "available"
    priority: 4
```

---

## OpenAI Configuration

### Models

```yaml
openai:
  api_key: "${OPENAI_API_KEY}"
  base_url: "https://api.openai.com/v1"
  
  models:
    gpt-4o:
      id: "gpt-4o"
      max_tokens: 128000
      output_limit: 4096
      cost_per_1k_input: 0.005
      cost_per_1k_output: 0.015
      use_case: "Primary generation, complex tasks"
      latency: "medium"
      quality: "highest"
    
    gpt-4o-mini:
      id: "gpt-4o-mini"
      max_tokens: 128000
      output_limit: 4096
      cost_per_1k_input: 0.00015
      cost_per_1k_output: 0.0006
      use_case: "Drafts, simple tasks, high volume"
      latency: "fast"
      quality: "high"
    
    gpt-4-turbo:
      id: "gpt-4-turbo"
      max_tokens: 128000
      output_limit: 4096
      cost_per_1k_input: 0.01
      cost_per_1k_output: 0.03
      use_case: "Legacy support"
      latency: "medium"
      quality: "highest"
    
    dall-e-3:
      id: "dall-e-3"
      resolution: "1024x1024"
      cost_per_image: 0.04
      use_case: "Image generation"
```

### Rate Limits

```yaml
openai_rate_limits:
  rpm: 500          # Requests per minute
  tpm: 200000       # Tokens per minute
  rpd: 10000        # Requests per day
  max_concurrent: 10 # Max concurrent requests
```

### Configuration Example

```typescript
const openaiConfig = {
  apiKey: process.env.OPENAI_API_KEY,
  organization: process.env.OPENAI_ORG_ID,
  timeout: 30000,
  maxRetries: 3,
  
  defaultParams: {
    model: 'gpt-4o',
    temperature: 0.7,
    max_tokens: 2048,
    top_p: 1,
    frequency_penalty: 0,
    presence_penalty: 0,
  },
  
  modelSelection: {
    highQuality: 'gpt-4o',
    balanced: 'gpt-4o-mini',
    lowCost: 'gpt-4o-mini',
  },
};
```

---

## Anthropic Configuration

### Models

```yaml
anthropic:
  api_key: "${ANTHROPIC_API_KEY}"
  base_url: "https://api.anthropic.com"
  
  models:
    claude-3-5-sonnet:
      id: "claude-3-5-sonnet-20241022"
      max_tokens: 200000
      output_limit: 8192
      cost_per_1k_input: 0.003
      cost_per_1k_output: 0.015
      use_case: "Long-form, nuanced content"
      latency: "medium"
      quality: "highest"
    
    claude-3-haiku:
      id: "claude-3-haiku-20240307"
      max_tokens: 200000
      output_limit: 4096
      cost_per_1k_input: 0.00025
      cost_per_1k_output: 0.00125
      use_case: "Quick tasks, fallback, high volume"
      latency: "fast"
      quality: "high"
    
    claude-3-opus:
      id: "claude-3-opus-20240229"
      max_tokens: 200000
      output_limit: 4096
      cost_per_1k_input: 0.015
      cost_per_1k_output: 0.075
      use_case: "Most complex tasks, highest quality"
      latency: "slow"
      quality: "highest"
```

### Rate Limits

```yaml
anthropic_rate_limits:
  rpm: 1000         # Requests per minute
  tpm: 100000       # Tokens per minute
  rpd: 100000       # Requests per day
  max_concurrent: 20 # Max concurrent requests
```

### Configuration Example

```typescript
const anthropicConfig = {
  apiKey: process.env.ANTHROPIC_API_KEY,
  timeout: 60000,
  maxRetries: 3,
  
  defaultParams: {
    model: 'claude-3-5-sonnet-20241022',
    max_tokens: 2048,
    temperature: 0.7,
    top_p: 1,
  },
  
  modelSelection: {
    highQuality: 'claude-3-5-sonnet-20241022',
    balanced: 'claude-3-haiku-20240307',
    lowCost: 'claude-3-haiku-20240307',
  },
};
```

---

## Google AI Configuration

### Models

```yaml
google:
  api_key: "${GOOGLE_AI_API_KEY}"
  base_url: "https://generativelanguage.googleapis.com"
  
  models:
    gemini-pro:
      id: "gemini-pro"
      max_tokens: 32000
      output_limit: 8192
      cost_per_1k_input: 0.00025
      cost_per_1k_output: 0.0005
      use_case: "Multi-modal, general tasks"
      latency: "fast"
      quality: "high"
    
    gemini-flash:
      id: "gemini-1.5-flash"
      max_tokens: 1000000
      output_limit: 8192
      cost_per_1k_input: 0.000075
      cost_per_1k_output: 0.0003
      use_case: "High-volume, low-cost"
      latency: "very_fast"
      quality: "good"
    
    gemini-pro-vision:
      id: "gemini-pro-vision"
      max_tokens: 32000
      output_limit: 4096
      cost_per_1k_input: 0.00025
      cost_per_1k_output: 0.0005
      use_case: "Image understanding, multi-modal"
      latency: "medium"
      quality: "high"
```

### Rate Limits

```yaml
google_rate_limits:
  rpm: 60           # Requests per minute
  tpm: 100000       # Tokens per minute
  rpd: 1500         # Requests per day
  max_concurrent: 5 # Max concurrent requests
```

### Configuration Example

```typescript
const googleConfig = {
  apiKey: process.env.GOOGLE_AI_API_KEY,
  timeout: 30000,
  maxRetries: 3,
  
  defaultParams: {
    model: 'gemini-pro',
    temperature: 0.7,
    topP: 0.8,
    topK: 40,
    maxOutputTokens: 2048,
  },
  
  modelSelection: {
    highQuality: 'gemini-pro',
    balanced: 'gemini-1.5-flash',
    lowCost: 'gemini-1.5-flash',
  },
};
```

---

## Local LLM Configuration

### Supported Models

```yaml
local:
  models:
    llama-3-70b:
      id: "llama-3-70b"
      quantization: "Q4_K_M"
      vram_required: "40GB"
      use_case: "High-quality local generation"
      quality: "high"
      cost: 0
    
    llama-3-8b:
      id: "llama-3-8b"
      quantization: "Q8_0"
      vram_required: "10GB"
      use_case: "Fast local generation"
      quality: "medium"
      cost: 0
    
    mistral-7b:
      id: "mistral-7b"
      quantization: "Q4_K_M"
      vram_required: "8GB"
      use_case: "Lightweight tasks"
      quality: "medium"
      cost: 0
    
    phi-3:
      id: "phi-3-medium"
      quantization: "Q4_K_M"
      vram_required: "8GB"
      use_case: "Code and reasoning"
      quality: "medium"
      cost: 0
```

### Configuration Example

```typescript
const localConfig = {
  baseUrl: 'http://localhost:11434', // Ollama
  // or
  baseUrl: 'http://localhost:8080', // llama.cpp server
  
  models: {
    primary: 'llama-3-70b',
    fallback: 'llama-3-8b',
  },
  
  defaultParams: {
    temperature: 0.7,
    top_p: 0.9,
    max_tokens: 2048,
  },
  
  timeout: 120000, // Longer timeout for local
  maxRetries: 2,
};
```

---

## Provider Selection Strategy

### Decision Tree

```typescript
interface SelectionCriteria {
  taskType: 'generation' | 'rewrite' | 'translation' | 'analysis' | 'image';
  qualityRequired: 'high' | 'medium' | 'low';
  budget: number; // Max cost per request
  latency: 'fast' | 'medium' | 'any';
  contentLength: 'short' | 'medium' | 'long';
}

function selectProvider(criteria: SelectionCriteria): ProviderConfig {
  // 1. Check rate limits
  const availableProviders = getAvailableProviders();
  
  // 2. Filter by task type
  const suitableProviders = availableProviders.filter(p => 
    p.supportedTasks.includes(criteria.taskType)
  );
  
  // 3. Filter by quality requirement
  const qualityFiltered = suitableProviders.filter(p => {
    if (criteria.qualityRequired === 'high') return p.quality === 'highest';
    if (criteria.qualityRequired === 'medium') return ['high', 'highest'].includes(p.quality);
    return true;
  });
  
  // 4. Filter by budget
  const budgetFiltered = qualityFiltered.filter(p => 
    p.costPerRequest <= criteria.budget
  );
  
  // 5. Sort by cost (cheapest first) for same quality
  const sorted = budgetFiltered.sort((a, b) => a.costPerRequest - b.costPerRequest);
  
  // 6. Return best match
  return sorted[0] || getFallbackProvider();
}
```

### Selection Matrix

| Task Type | Best Provider | Fallback | Reason |
|-----------|---------------|----------|--------|
| High-quality generation | GPT-4o | Claude 3.5 Sonnet | Best overall quality |
| Long-form content | Claude 3.5 Sonnet | GPT-4o | Better context window |
| Quick tasks | GPT-4o-mini | Claude 3 Haiku | Fast, cheap |
| Translation | Claude 3.5 Sonnet | Gemini Pro | Nuance handling |
| Image generation | DALL-E 3 | Stable Diffusion | Quality, integration |
| High volume | Gemini Flash | GPT-4o-mini | Lowest cost |
| Offline/privacy | Local LLM | - | No data leaves system |

---

## Fallback Chain Configuration

```typescript
const FALLBACK_CHAIN: ProviderConfig[] = [
  // Priority 1: Primary provider
  {
    provider: 'openai',
    model: 'gpt-4o',
    priority: 1,
    retryAttempts: 2,
    timeout: 30000,
  },
  
  // Priority 2: First fallback
  {
    provider: 'anthropic',
    model: 'claude-3-5-sonnet-20241022',
    priority: 2,
    retryAttempts: 2,
    timeout: 60000,
  },
  
  // Priority 3: Budget fallback
  {
    provider: 'google',
    model: 'gemini-pro',
    priority: 3,
    retryAttempts: 2,
    timeout: 30000,
  },
  
  // Priority 4: Emergency fallback
  {
    provider: 'local',
    model: 'llama-3-70b',
    priority: 4,
    retryAttempts: 1,
    timeout: 120000,
  },
];

async function generateWithFallback(
  prompt: string,
  options: GenerateOptions
): Promise<GenerateResult> {
  for (const provider of FALLBACK_CHAIN) {
    try {
      const result = await generate(provider, prompt, options);
      
      if (validateOutput(result, options.constraints)) {
        return result;
      }
      
      logQualityWarning(provider, result);
    } catch (error) {
      logProviderError(provider, error);
      continue;
    }
  }
  
  throw new Error('All providers failed');
}
```

---

## Cost Comparison

### Cost Per Request Estimates

| Task Type | Tokens (In/Out) | GPT-4o | Claude 3.5 Sonnet | Gemini Pro | GPT-4o-mini |
|-----------|-----------------|--------|-------------------|------------|-------------|
| Caption (short) | 200/150 | $0.003 | $0.003 | $0.0001 | $0.0001 |
| Caption (long) | 500/500 | $0.010 | $0.010 | $0.0004 | $0.0004 |
| Thread (10 tweets) | 1000/1500 | $0.028 | $0.026 | $0.001 | $0.001 |
| Blog post | 2000/2000 | $0.040 | $0.036 | $0.002 | $0.002 |
| Carousel (10 slides) | 1500/1000 | $0.023 | $0.019 | $0.001 | $0.001 |
| YouTube script | 3000/3000 | $0.060 | $0.054 | $0.003 | $0.003 |
| Translation | 1000/1000 | $0.020 | $0.018 | $0.001 | $0.001 |
| Image generation | - | $0.040 | N/A | N/A | N/A |

### Monthly Cost Estimates

| Usage Level | GPT-4o | Claude 3.5 Sonnet | Gemini Pro | Hybrid Strategy |
|-------------|--------|-------------------|------------|-----------------|
| Light (100 requests) | $3.00 | $2.50 | $0.15 | $1.50 |
| Medium (500 requests) | $15.00 | $12.50 | $0.75 | $7.50 |
| Heavy (2000 requests) | $60.00 | $50.00 | $3.00 | $30.00 |
| Enterprise (10000 requests) | $300.00 | $250.00 | $15.00 | $150.00 |

### Cost Optimization Strategy

```typescript
const COST_OPTIMIZATION = {
  // Use cheap models for simple tasks
  simpleTasks: {
    provider: 'gpt-4o-mini',
    savings: '80%',
    tasks: ['draft generation', 'simple rewrites', 'formatting'],
  },
  
  // Use cache for repeated prompts
  cacheStrategy: {
    enabled: true,
    ttl: 86400, // 24 hours
    savings: '40-60%',
  },
  
  // Batch processing for efficiency
  batchProcessing: {
    enabled: true,
    batchSize: 10,
    savings: '20-30%',
  },
  
  // Local LLM for offline/non-critical
  localFallback: {
    enabled: true,
    savings: '100%',
    tasks: ['internal drafts', 'testing', 'development'],
  },
};
```

---

## Rate Limit Management

```typescript
class RateLimitManager {
  private counters: Map<string, RateCounter> = new Map();
  
  async checkLimit(provider: string): Promise<boolean> {
    const limits = RATE_LIMITS[provider];
    const counter = this.counters.get(provider) || new RateCounter();
    
    if (counter.requests >= limits.rpm) {
      await this.waitForReset(provider, 'rpm');
    }
    
    if (counter.tokens >= limits.tpm) {
      await this.waitForReset(provider, 'tpm');
    }
    
    counter.increment();
    this.counters.set(provider, counter);
    
    return true;
  }
  
  private async waitForReset(provider: string, type: string): Promise<void> {
    const resetTime = this.getResetTime(provider, type);
    const waitTime = resetTime - Date.now();
    
    if (waitTime > 0) {
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
}
```

---

## Environment Variables

```bash
# OpenAI
OPENAI_API_KEY=sk-...
OPENAI_ORG_ID=org-...

# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# Google AI
GOOGLE_AI_API_KEY=AI...

# Local LLM
LOCAL_LLM_URL=http://localhost:11434
LOCAL_LLM_MODEL=llama-3-70b

# Provider Selection
DEFAULT_PROVIDER=openai
FALLBACK_ENABLED=true
COST_OPTIMIZATION=balanced
```
