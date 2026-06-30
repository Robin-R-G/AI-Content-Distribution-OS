export type AIProvider = 'openai' | 'anthropic' | 'google' | 'azure' | 'groq' | 'replicate';

export type AIModel = string;

export interface AICostEstimate {
  provider: AIProvider;
  model: AIModel;
  inputTokens: number;
  outputTokens: number;
  estimatedCost: number;
  currency: string;
}

export interface AIJob {
  id: string;
  userId: string;
  workspaceId: string;
  type: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  provider: AIProvider;
  model: AIModel;
  request: AIRequest;
  response?: AIResponse;
  cost?: AICostEstimate;
  createdAt: Date;
  completedAt?: Date;
}

export type AIRequest =
  | CaptionRequest
  | TitleRequest
  | HashtagRequest
  | ThumbnailRequest
  | TranslateRequest
  | RewriteRequest
  | TrendRequest
  | ViralRequest
  | ContentIdeasRequest;

export interface AIResponse {
  content: string;
  alternatives?: string[];
  tokensUsed: number;
  provider: AIProvider;
  model: AIModel;
  latencyMs: number;
}

export interface CaptionRequest {
  type: 'caption';
  imageDescription?: string;
  platform: string;
  tone?: string;
  maxLength?: number;
  includeEmojis?: boolean;
  includeHashtags?: boolean;
  language?: string;
  context?: string;
}

export interface TitleRequest {
  type: 'title';
  topic: string;
  platform: string;
  style?: string;
  maxLength?: number;
  language?: string;
}

export interface HashtagRequest {
  type: 'hashtags';
  content: string;
  platform: string;
  count?: number;
  trending?: boolean;
  niche?: string;
  language?: string;
}

export interface ThumbnailRequest {
  type: 'thumbnail';
  prompt: string;
  style?: string;
  dimensions?: { width: number; height: number };
 参考Image?: string;
}

export interface TranslateRequest {
  type: 'translate';
  text: string;
  targetLang: string;
  sourceLang?: string;
  tone?: string;
  preserveFormatting?: boolean;
}

export interface RewriteRequest {
  type: 'rewrite';
  text: string;
  style: 'formal' | 'casual' | 'humorous' | 'professional' | 'engaging' | 'concise';
  maxLength?: number;
  platform?: string;
}

export interface TrendRequest {
  type: 'trend';
  niche: string;
  dateRange: { start: string; end: string };
  platform?: string;
}

export interface ViralRequest {
  type: 'viral';
  content: string;
  platform: string;
}

export interface ContentIdeasRequest {
  type: 'content_ideas';
  niche: string;
  count: number;
  platform?: string;
  excludeTopics?: string[];
}
