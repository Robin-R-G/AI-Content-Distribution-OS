import { v4 as uuidv4 } from 'uuid';

interface PromptTemplate {
  id: string;
  name: string;
  category: string;
  template: string;
  variables: string[];
  version: number;
  abTestGroup?: string;
  metrics?: { impressions: number; uses: number; avgRating: number };
  createdAt: Date;
  updatedAt: Date;
}

interface ABTestConfig {
  testId: string;
  promptAId: string;
  promptBId: string;
  trafficSplit: number;
  metrics: { a: number; b: number };
  winner?: string;
  status: 'running' | 'completed';
}

export class PromptManager {
  private db: any;
  private redis: any;
  private activeTests: Map<string, ABTestConfig> = new Map();

  constructor(db: any, redis: any) {
    this.db = db;
    this.redis = redis;
  }

  async getPrompt(category: string, name: string): Promise<PromptTemplate> {
    const cacheKey = `prompt:${category}:${name}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const prompt = await this.db.promptTemplate.findFirst({
      where: { category, name, version: { equals: await this.getLatestVersion(category, name) } },
    });

    if (!prompt) throw new Error(`Prompt not found: ${category}/${name}`);
    await this.redis.setex(cacheKey, 3600, JSON.stringify(prompt));
    return prompt;
  }

  async renderPrompt(category: string, nameOrVariables: string | Record<string, unknown>): Promise<string> {
    let prompt: PromptTemplate;
    let variables: Record<string, unknown>;

    if (typeof nameOrVariables === 'string') {
      prompt = await this.getPrompt(category, nameOrVariables);
      variables = {};
    } else {
      prompt = await this.getPrompt(category, category);
      variables = nameOrVariables;
    }

    return this.renderTemplate(prompt.template, variables);
  }

  validatePrompt(prompt: string): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    const variablePattern = /\{\{(\w+)\}\}/g;
    const matches = prompt.match(variablePattern);

    if (!matches) return { valid: true, errors: [] };

    const uniqueVars = new Set(matches.map((m) => m.replace(/[{}]/g, '')));
    for (const variable of uniqueVars) {
      if (!/^[a-zA-Z_]\w*$/.test(variable)) {
        errors.push(`Invalid variable name: ${variable}`);
      }
    }

    const openBraces = (prompt.match(/\{\{/g) || []).length;
    const closeBraces = (prompt.match(/\}\}/g) || []).length;
    if (openBraces !== closeBraces) {
      errors.push('Mismatched template braces');
    }

    if (prompt.length > 10000) {
      errors.push('Prompt exceeds maximum length of 10000 characters');
    }

    return { valid: errors.length === 0, errors };
  }

  async listPrompts(category?: string): Promise<PromptTemplate[]> {
    const where: any = {};
    if (category) where.category = category;

    return this.db.promptTemplate.findMany({
      where,
      orderBy: [{ category: 'asc' }, { name: 'asc' }, { version: 'desc' }],
    });
  }

  async createPrompt(data: Omit<PromptTemplate, 'id' | 'version' | 'createdAt' | 'updatedAt'>): Promise<PromptTemplate> {
    const validation = this.validatePrompt(data.template);
    if (!validation.valid) throw new Error(`Invalid prompt: ${validation.errors.join(', ')}`);

    const version = await this.getLatestVersion(data.category, data.name) + 1;
    const prompt = await this.db.promptTemplate.create({
      data: {
        ...data,
        id: uuidv4(),
        version,
        metrics: { impressions: 0, uses: 0, avgRating: 0 },
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    });

    await this.invalidateCache(data.category, data.name);
    return prompt;
  }

  async updatePrompt(id: string, data: Partial<PromptTemplate>): Promise<PromptTemplate> {
    const existing = await this.db.promptTemplate.findUnique({ where: { id } });
    if (!existing) throw new Error('Prompt not found');

    if (data.template) {
      const validation = this.validatePrompt(data.template);
      if (!validation.valid) throw new Error(`Invalid prompt: ${validation.errors.join(', ')}`);
    }

    const newVersion = await this.getLatestVersion(existing.category, existing.name) + 1;
    const prompt = await this.db.promptTemplate.update({
      where: { id },
      data: { ...data, version: newVersion, updatedAt: new Date() },
    });

    await this.invalidateCache(existing.category, existing.name);
    return prompt;
  }

  async deletePrompt(id: string): Promise<void> {
    const prompt = await this.db.promptTemplate.findUnique({ where: { id } });
    if (!prompt) throw new Error('Prompt not found');
    await this.db.promptTemplate.delete({ where: { id } });
    await this.invalidateCache(prompt.category, prompt.name);
  }

  async startABTest(promptAId: string, promptBId: string, trafficSplit: number = 0.5): Promise<ABTestConfig> {
    const testId = uuidv4();
    const config: ABTestConfig = {
      testId,
      promptAId,
      promptBId,
      trafficSplit,
      metrics: { a: 0, b: 0 },
      status: 'running',
    };
    this.activeTests.set(testId, config);
    await this.redis.set(`ab_test:${testId}`, JSON.stringify(config));
    return config;
  }

  async selectVariant(testId: string): Promise<'a' | 'b'> {
    const config = this.activeTests.get(testId);
    if (!config || config.status !== 'completed') {
      return Math.random() < (config?.trafficSplit ?? 0.5) ? 'a' : 'b';
    }
    return config.winner === 'a' ? 'a' : 'b';
  }

  async recordABTestResult(testId: string, variant: 'a' | 'b', success: boolean): Promise<void> {
    const config = this.activeTests.get(testId);
    if (!config) return;
    if (success) config.metrics[variant]++;
    await this.redis.set(`ab_test:${testId}`, JSON.stringify(config));

    const totalA = config.metrics.a + 1;
    const totalB = config.metrics.b + 1;
    if (totalA + totalB >= 100) {
      config.status = 'completed';
      config.winner = config.metrics.a > config.metrics.b ? 'a' : 'b';
    }
  }

  private renderTemplate(template: string, variables: Record<string, unknown>): string {
    return template.replace(/\{\{(\w+)\}\}/g, (_, key) => {
      const value = variables[key];
      return value !== undefined ? String(value) : `{{${key}}}`;
    });
  }

  private async getLatestVersion(category: string, name: string): Promise<number> {
    const latest = await this.db.promptTemplate.findFirst({
      where: { category, name },
      orderBy: { version: 'desc' },
      select: { version: true },
    });
    return latest?.version ?? 0;
  }

  private async invalidateCache(category: string, name: string): Promise<void> {
    await this.redis.del(`prompt:${category}:${name}`);
  }
}
