import { v4 as uuidv4 } from 'uuid';
import type {
  AIJob,
  AIRequest,
  AIResponse,
  CaptionRequest,
  TitleRequest,
  HashtagRequest,
  ThumbnailRequest,
  TranslateRequest,
  RewriteRequest,
  TrendRequest,
  ViralRequest,
  ContentIdeasRequest,
  AIProvider,
  AIModel,
  AICostEstimate,
} from './types';

interface ProviderClient {
  generate(prompt: string, options?: { model?: string; maxTokens?: number; temperature?: number }): Promise<{ content: string; tokensUsed: number }>;
}

const PROVIDER_FALLBACK: AIProvider[] = ['openai', 'anthropic', 'google', 'groq', 'azure'];

export class AIService {
  private db: any;
  private redis: any;
  private promptManager: any;
  private providers: Map<AIProvider, ProviderClient> = new Map();
  private providerModels: Record<AIProvider, string> = {
    openai: 'gpt-4o',
    anthropic: 'claude-sonnet-4-20250514',
    google: 'gemini-pro',
    groq: 'llama-3.1-70b-versatile',
    azure: 'gpt-4o',
    replicate: 'stability-ai/sdxl',
  };

  constructor(db: any, redis: any, promptManager: any, providers?: Map<AIProvider, ProviderClient>) {
    this.db = db;
    this.redis = redis;
    this.promptManager = promptManager;
    if (providers) this.providers = providers;
  }

  async generateCaption(request: CaptionRequest): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('caption', {
      platform: request.platform,
      tone: request.tone ?? 'engaging',
      maxLength: request.maxLength ?? 2200,
      includeEmojis: request.includeEmojis ?? true,
      includeHashtags: request.includeHashtags ?? false,
      imageDescription: request.imageDescription ?? '',
      context: request.context ?? '',
      language: request.language ?? 'en',
    });
    return this.executeWithFallback(prompt, request.platform);
  }

  async generateTitle(request: TitleRequest): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('title', {
      topic: request.topic,
      platform: request.platform,
      style: request.style ?? 'engaging',
      maxLength: request.maxLength ?? 100,
      language: request.language ?? 'en',
    });
    return this.executeWithFallback(prompt, request.platform);
  }

  async generateHashtags(request: HashtagRequest): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('hashtag', {
      content: request.content,
      platform: request.platform,
      count: request.count ?? 30,
      trending: request.trending ?? true,
      niche: request.niche ?? '',
      language: request.language ?? 'en',
    });
    return this.executeWithFallback(prompt, request.platform);
  }

  async generateThumbnail(request: ThumbnailRequest): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('thumbnail', {
      description: request.prompt,
      style: request.style ?? 'modern',
      dimensions: request.dimensions ?? { width: 1280, height: 720 },
    });
    return this.executeWithFallback(prompt, 'image');
  }

  async translate(text: string, targetLang: string, options?: { sourceLang?: string; tone?: string; preserveFormatting?: boolean }): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('translate', {
      text,
      targetLang,
      sourceLang: options?.sourceLang ?? 'auto',
      tone: options?.tone ?? 'neutral',
      preserveFormatting: options?.preserveFormatting ?? true,
    });
    return this.executeWithFallback(prompt, 'translation');
  }

  async rewrite(text: string, style: string, options?: { maxLength?: number; platform?: string }): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('rewrite', {
      text,
      style,
      maxLength: options?.maxLength,
      platform: options?.platform ?? '',
    });
    return this.executeWithFallback(prompt, 'rewrite');
  }

  async predictTrend(niche: string, dateRange: { start: string; end: string }): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('trend', {
      niche,
      startDate: dateRange.start,
      endDate: dateRange.end,
    });
    return this.executeWithFallback(prompt, 'trend');
  }

  async predictViral(content: string, platform: string): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('viral', {
      content,
      platform,
    });
    return this.executeWithFallback(prompt, 'viral');
  }

  async generateContentIdeas(niche: string, count: number, platform?: string): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('content_ideas', {
      niche,
      count,
      platform: platform ?? 'all',
    });
    return this.executeWithFallback(prompt, 'ideas');
  }

  async generateScript(type: string, topic: string, options?: { duration?: number; tone?: string; platform?: string }): Promise<AIResponse> {
    const prompt = await this.promptManager.renderPrompt('script', {
      type,
      topic,
      duration: options?.duration ?? 60,
      tone: options?.tone ?? 'engaging',
      platform: options?.platform ?? 'youtube',
    });
    return this.executeWithFallback(prompt, 'script');
  }

  async getPrompts(category?: string): Promise<any[]> {
    return this.promptManager.listPrompts(category);
  }

  async getCredits(userId: string): Promise<number> {
    const credits = await this.db.creditBalance.findUnique({ where: { userId } });
    return credits?.credits ?? 0;
  }

  async estimateCost(provider: AIProvider, model: string, tokens: number): Promise<AICostEstimate> {
    const rates: Record<AIProvider, { input: number; output: number }> = {
      openai: { input: 0.005, output: 0.015 },
      anthropic: { input: 0.003, output: 0.015 },
      google: { input: 0.001, output: 0.002 },
      groq: { input: 0.0005, output: 0.001 },
      azure: { input: 0.005, output: 0.015 },
      replicate: { input: 0.004, output: 0.004 },
    };
    const rate = rates[provider] ?? rates.openai;
    const inputCost = (tokens / 1000) * rate.input;
    const outputCost = (tokens / 1000) * rate.output;

    return {
      provider,
      model,
      inputTokens: tokens,
      outputTokens: Math.floor(tokens * 0.3),
      estimatedCost: parseFloat((inputCost + outputCost).toFixed(4)),
      currency: 'USD',
    };
  }

  private async executeWithFallback(prompt: string, category: string): Promise<AIResponse> {
    const cacheKey = `ai:cache:${category}:${Buffer.from(prompt).toString('base64').slice(0, 64)}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    for (const provider of PROVIDER_FALLBACK) {
      const client = this.providers.get(provider);
      if (!client) continue;

      try {
        const start = Date.now();
        const result = await client.generate(prompt, { model: this.providerModels[provider] });
        const response: AIResponse = {
          content: result.content,
          tokensUsed: result.tokensUsed,
          provider,
          model: this.providerModels[provider],
          latencyMs: Date.now() - start,
        };

        await this.redis.setex(cacheKey, 3600, JSON.stringify(response));
        await this.recordUsage(provider, result.tokensUsed);
        return response;
      } catch {
        continue;
      }
    }

    throw new Error('All AI providers failed');
  }

  private async recordUsage(provider: AIProvider, tokens: number): Promise<void> {
    await this.db.usageRecord.create({
      data: { id: uuidv4(), provider, tokens, createdAt: new Date() },
    });
  }
}
