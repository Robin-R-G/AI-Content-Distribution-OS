# Cost Optimization

## Overview

Token counting, caching strategies, model selection, batch processing, and quota management.

---

## Token Counting

### Token Estimation

```typescript
interface TokenEstimate {
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
  estimatedCost: number;
}

function estimateTokens(text: string, isOutput: boolean = false): number {
  // Rough estimation: 1 token ≈ 4 characters for English
  // More accurate: use tokenizer library
  
  const charCount = text.length;
  const wordCount = text.split(/\s+/).length;
  
  // Heuristic estimation
  if (isOutput) {
    return Math.ceil(wordCount * 1.3); // Output tokens are slightly higher
  }
  
  return Math.ceil(charCount / 4); // Input tokens
}

function estimateCost(
  inputTokens: number,
  outputTokens: number,
  provider: string,
  model: string
): number {
  const pricing = PROVIDER_PRICING[provider][model];
  
  const inputCost = (inputTokens / 1000) * pricing.input;
  const outputCost = (outputTokens / 1000) * pricing.output;
  
  return inputCost + outputCost;
}
```

### Provider Pricing

```yaml
pricing:
  openai:
    gpt-4o:
      input: 0.005    # per 1k tokens
      output: 0.015
    gpt-4o-mini:
      input: 0.00015
      output: 0.0006
  
  anthropic:
    claude-3-5-sonnet:
      input: 0.003
      output: 0.015
    claude-3-haiku:
      input: 0.00025
      output: 0.00125
  
  google:
    gemini-pro:
      input: 0.00025
      output: 0.0005
    gemini-flash:
      input: 0.000075
      output: 0.0003
  
  local:
    llama-3-70b:
      input: 0
      output: 0
```

### Cost Estimation Calculator

```typescript
function calculateMonthlyCost(
  requestsPerDay: number,
  avgInputTokens: number,
  avgOutputTokens: number,
  provider: string,
  model: string
): MonthlyCostEstimate {
  const dailyRequests = requestsPerDay;
  const monthlyRequests = dailyRequests * 30;
  
  const dailyInputTokens = dailyRequests * avgInputTokens;
  const dailyOutputTokens = dailyRequests * avgOutputTokens;
  
  const monthlyInputTokens = monthlyRequests * avgInputTokens;
  const monthlyOutputTokens = monthlyRequests * avgOutputTokens;
  
  const dailyCost = estimateCost(dailyInputTokens, dailyOutputTokens, provider, model);
  const monthlyCost = dailyCost * 30;
  
  return {
    dailyRequests,
    monthlyRequests,
    dailyInputTokens,
    monthlyOutputTokens,
    monthlyInputTokens,
    monthlyOutputTokens,
    dailyCost,
    monthlyCost,
    annualCost: monthlyCost * 12,
  };
}

// Example usage
const estimate = calculateMonthlyCost(
  50,      // 50 requests per day
  500,     // 500 input tokens average
  300,     // 300 output tokens average
  'openai',
  'gpt-4o'
);

console.log(`Monthly cost: $${estimate.monthlyCost.toFixed(2)}`);
```

---

## Caching Strategies

### Cache Types

```yaml
cache_types:
  prompt_cache:
    description: "Cache entire prompt responses"
    ttl: 86400  # 24 hours
    hit_rate: "30-50%"
    savings: "40-60%"
    use_case: "Repeated content queries"
  
  partial_cache:
    description: "Cache prompt templates with variables"
    ttl: 604800  # 7 days
    hit_rate: "20-30%"
    savings: "20-30%"
    use_case: "Template-based generation"
  
  result_cache:
    description: "Cache similar query results"
    ttl: 259200  # 3 days
    hit_rate: "15-25%"
    savings: "15-25%"
    use_case: "Similar content requests"
```

### Cache Implementation

```typescript
interface CacheEntry {
  key: string;
  value: string;
  timestamp: Date;
  ttl: number;
  hits: number;
}

class PromptCache {
  private cache: Map<string, CacheEntry> = new Map();
  private maxSize: number;
  private defaultTTL: number;
  
  constructor(maxSize: number = 1000, defaultTTL: number = 86400) {
    this.maxSize = maxSize;
    this.defaultTTL = defaultTTL;
  }
  
  generateKey(prompt: string, params: any): string {
    const hash = createHash('sha256');
    hash.update(prompt + JSON.stringify(params));
    return hash.digest('hex');
  }
  
  get(prompt: string, params: any): string | null {
    const key = this.generateKey(prompt, params);
    const entry = this.cache.get(key);
    
    if (!entry) return null;
    
    // Check TTL
    if (Date.now() - entry.timestamp.getTime() > entry.ttl * 1000) {
      this.cache.delete(key);
      return null;
    }
    
    entry.hits++;
    return entry.value;
  }
  
  set(prompt: string, params: any, value: string, ttl?: number): void {
    const key = this.generateKey(prompt, params);
    
    // Evict oldest if at capacity
    if (this.cache.size >= this.maxSize) {
      const oldest = Array.from(this.cache.entries())
        .sort((a, b) => a[1].timestamp.getTime() - b[1].timestamp.getTime())[0];
      this.cache.delete(oldest[0]);
    }
    
    this.cache.set(key, {
      key,
      value,
      timestamp: new Date(),
      ttl: ttl || this.defaultTTL,
      hits: 0,
    });
  }
  
  getStats(): CacheStats {
    const entries = Array.from(this.cache.values());
    const totalHits = entries.reduce((sum, e) => sum + e.hits, 0);
    
    return {
      size: this.cache.size,
      totalHits,
      avgHits: totalHits / this.cache.size || 0,
      hitRate: this.calculateHitRate(),
    };
  }
}
```

### Cache Optimization Rules

```yaml
cache_optimization:
  always_cache:
    - "Platform-specific templates"
    - "Brand voice guidelines"
    - "Hashtag sets"
    - "Caption formulas"
    - "Title templates"
  
  never_cache:
    - "Real-time trending topics"
    - "User-specific content"
    - "Time-sensitive announcements"
    - "Dynamic data queries"
  
  cache_invalidation:
    triggers:
      - "Content updated"
      - "Brand voice changed"
      - "Platform rules changed"
      - "TTL expired"
    strategy: "Lazy invalidation with TTL fallback"
```

---

## Model Selection for Cost Optimization

### Cost-Performance Matrix

```yaml
model_selection:
  tier_1_budget:
    models: ["gpt-4o-mini", "claude-3-haiku", "gemini-flash"]
    cost: "$0.00015-0.001 per request"
    quality: "good"
    use_cases:
      - "Draft generation"
      - "Simple rewrites"
      - "Format conversion"
      - "Hashtag generation"
      - "Basic captions"
  
  tier_2_balanced:
    models: ["gpt-4o", "claude-3-5-sonnet", "gemini-pro"]
    cost: "$0.003-0.015 per request"
    quality: "high"
    use_cases:
      - "Final content"
      - "Complex generation"
      - "Nuanced content"
      - "Long-form writing"
  
  tier_3_premium:
    models: ["gpt-4o", "claude-3-opus"]
    cost: "$0.015-0.075 per request"
    quality: "highest"
    use_cases:
      - "Client deliverables"
      - "High-stakes content"
      - "Creative writing"
      - "Strategic planning"
```

### Smart Model Routing

```typescript
function selectOptimalModel(
  taskType: string,
  qualityRequired: 'low' | 'medium' | 'high',
  budget: number
): ModelConfig {
  const taskComplexity = getTaskComplexity(taskType);
  
  // If budget is tight, use cheapest option
  if (budget < 0.001) {
    return BUDGET_MODELS[taskType] || BUDGET_MODELS.default;
  }
  
  // If high quality required, use best model
  if (qualityRequired === 'high') {
    return PREMIUM_MODELS[taskType] || PREMIUM_MODELS.default;
  }
  
  // Otherwise, use balanced option
  return BALANCED_MODELS[taskType] || BALANCED_MODELS.default;
}

const MODEL_ROUTING = {
  caption: {
    low: { model: 'gpt-4o-mini', cost: 0.0003 },
    medium: { model: 'gpt-4o-mini', cost: 0.0003 },
    high: { model: 'gpt-4o', cost: 0.008 },
  },
  
  thread: {
    low: { model: 'gpt-4o-mini', cost: 0.001 },
    medium: { model: 'gpt-4o-mini', cost: 0.001 },
    high: { model: 'gpt-4o', cost: 0.025 },
  },
  
  blog_post: {
    low: { model: 'gpt-4o-mini', cost: 0.002 },
    medium: { model: 'gpt-4o', cost: 0.035 },
    high: { model: 'claude-3-5-sonnet', cost: 0.045 },
  },
  
  script: {
    low: { model: 'gpt-4o-mini', cost: 0.003 },
    medium: { model: 'gpt-4o', cost: 0.05 },
    high: { model: 'claude-3-5-sonnet', cost: 0.06 },
  },
};
```

---

## Batch Processing

### Batch Processing Strategy

```yaml
batch_processing:
  enabled: true
  
  rules:
    min_batch_size: 5
    max_batch_size: 20
    timeout: 60000  # 60 seconds
    
  cost_savings:
    single_request: "100% base cost"
    batch_5: "85% of base cost (15% savings)"
    batch_10: "75% of base cost (25% savings)"
    batch_20: "65% of base cost (35% savings)"
```

### Batch Implementation

```typescript
class BatchProcessor {
  private queue: BatchItem[] = [];
  private batchSize: number;
  private flushInterval: number;
  
  constructor(batchSize: number = 10, flushInterval: number = 5000) {
    this.batchSize = batchSize;
    this.flushInterval = flushInterval;
    
    // Auto-flush on interval
    setInterval(() => this.flush(), flushInterval);
  }
  
  async add(item: BatchItem): Promise<any> {
    return new Promise((resolve) => {
      this.queue.push({ ...item, resolve });
      
      if (this.queue.length >= this.batchSize) {
        this.flush();
      }
    });
  }
  
  async flush(): Promise<void> {
    if (this.queue.length === 0) return;
    
    const batch = this.queue.splice(0, this.batchSize);
    
    try {
      const results = await this.processBatch(batch);
      
      batch.forEach((item, index) => {
        item.resolve(results[index]);
      });
    } catch (error) {
      // Fall back to individual processing
      for (const item of batch) {
        try {
          const result = await this.processSingle(item);
          item.resolve(result);
        } catch (err) {
          item.resolve({ error: err.message });
        }
      }
    }
  }
  
  private async processBatch(batch: BatchItem[]): Promise<any[]> {
    // Combine prompts into single API call
    const combinedPrompt = this.combinePrompts(batch);
    
    const response = await aiClient.generate(combinedPrompt);
    
    return this.splitResponse(response, batch.length);
  }
}
```

### Batch Processing Benefits

| Batch Size | Cost Savings | Latency Impact | Use Case |
|------------|--------------|----------------|----------|
| 1 | 0% | Baseline | Individual requests |
| 5 | 15% | +20% | Small batches |
| 10 | 25% | +40% | Medium batches |
| 20 | 35% | +80% | Large batches |

---

## Quota Management

### Quota System

```yaml
quota_system:
  daily:
    requests: 5000
    tokens: 2000000
    cost: 50.00
  
  monthly:
    requests: 100000
    tokens: 50000000
    cost: 1000.00
  
  per_user:
    daily_requests: 100
    daily_tokens: 50000
    daily_cost: 1.00
```

### Quota Tracking

```typescript
class QuotaManager {
  private usage: Map<string, QuotaUsage> = new Map();
  
  async checkQuota(
    userId: string,
    quotaType: 'daily' | 'monthly',
    estimatedCost: number
  ): Promise<QuotaCheck> {
    const key = `${userId}:${quotaType}`;
    const current = this.usage.get(key) || this.getDefaults(quotaType);
    
    const limits = QUOTA_LIMITS[quotaType];
    
    if (current.requests >= limits.requests) {
      return { allowed: false, reason: 'Request limit exceeded' };
    }
    
    if (current.tokens >= limits.tokens) {
      return { allowed: false, reason: 'Token limit exceeded' };
    }
    
    if (current.cost >= limits.cost) {
      return { allowed: false, reason: 'Cost limit exceeded' };
    }
    
    return { allowed: true };
  }
  
  async recordUsage(
    userId: string,
    quotaType: 'daily' | 'monthly',
    tokens: number,
    cost: number
  ): Promise<void> {
    const key = `${userId}:${quotaType}`;
    const current = this.usage.get(key) || this.getDefaults(quotaType);
    
    current.requests++;
    current.tokens += tokens;
    current.cost += cost;
    
    this.usage.set(key, current);
  }
  
  async getUsage(userId: string): Promise<UsageReport> {
    const daily = this.usage.get(`${userId}:daily`);
    const monthly = this.usage.get(`${userId}:monthly`);
    
    return {
      daily: daily || this.getDefaults('daily'),
      monthly: monthly || this.getDefaults('monthly'),
      limits: QUOTA_LIMITS,
    };
  }
}
```

### Quota Alerts

```yaml
quota_alerts:
  thresholds:
    - percentage: 50
      action: "log_warning"
      message: "50% of quota used"
    
    - percentage: 75
      action: "send_alert"
      message: "75% of quota used"
    
    - percentage: 90
      action: "urgent_alert"
      message: "90% of quota used"
    
    - percentage: 100
      action: "block_requests"
      message: "Quota exceeded"
```

---

## Cost Optimization Strategies

### Strategy Summary

```yaml
cost_optimization_strategies:
  prompt_caching:
    description: "Cache common prompt responses"
    savings: "40-60%"
    implementation: "Redis/Memcached with TTL"
  
  model_downgrade:
    description: "Use cheaper models for simple tasks"
    savings: "60-80%"
    implementation: "Task-based routing"
  
  batch_processing:
    description: "Process multiple items in one call"
    savings: "20-35%"
    implementation: "Queue system"
  
  result_caching:
    description: "Cache similar query results"
    savings: "15-25%"
    implementation: "Semantic similarity matching"
  
  local_fallback:
    description: "Use local models for non-critical"
    savings: "100%"
    implementation: "Ollama/llama.cpp"
  
  token_compression:
    description: "Condense input context"
    savings: "15-25%"
    implementation: "Text summarization"
  
  smart_routing:
    description: "Route to cheapest suitable provider"
    savings: "30-50%"
    implementation: "Provider selection engine"
```

### Cost Optimization Implementation

```typescript
class CostOptimizer {
  private cache: PromptCache;
  private quotaManager: QuotaManager;
  private batchProcessor: BatchProcessor;
  
  async optimizeRequest(
    prompt: string,
    options: OptimizationOptions
  ): Promise<OptimizedResult> {
    // 1. Check cache first
    const cached = this.cache.get(prompt, options);
    if (cached) {
      return { source: 'cache', cost: 0, result: cached };
    }
    
    // 2. Check quota
    const quotaCheck = await this.quotaManager.checkQuota(
      options.userId,
      'daily',
      this.estimateCost(prompt, options)
    );
    
    if (!quotaCheck.allowed) {
      // Try local fallback
      return this.localFallback(prompt, options);
    }
    
    // 3. Select optimal model
    const model = this.selectOptimalModel(options);
    
    // 4. Batch if possible
    if (options.batchable) {
      return this.batchProcessor.add({ prompt, options, model });
    }
    
    // 5. Generate and cache
    const result = await this.generate(prompt, model, options);
    this.cache.set(prompt, options, result);
    
    // 6. Record usage
    await this.quotaManager.recordUsage(
      options.userId,
      'daily',
      result.tokens,
      result.cost
    );
    
    return { source: 'api', cost: result.cost, result };
  }
}
```

### Monthly Cost Report

```yaml
monthly_cost_report:
  period: "2024-01"
  
  summary:
    total_requests: 15000
    total_tokens: 8000000
    total_cost: 125.00
    budget_used: 62.5%
  
  by_provider:
    openai:
      requests: 10000
      cost: 85.00
      percentage: 68%
    
    anthropic:
      requests: 3000
      cost: 25.00
      percentage: 20%
    
    google:
      requests: 1500
      cost: 10.00
      percentage: 8%
    
    local:
      requests: 500
      cost: 0
      percentage: 0%
  
  optimization_savings:
    cache_savings: 45.00
    model_downgrade_savings: 30.00
    batch_savings: 15.00
    total_savings: 90.00
    savings_percentage: 42%
  
  recommendations:
    - "Increase cache TTL for templates"
    - "Use gpt-4o-mini for more draft tasks"
    - "Batch more carousel requests"
    - "Move simple tasks to local models"
```
