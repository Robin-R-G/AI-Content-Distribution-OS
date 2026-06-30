# Phase 6: AI/ML Prompts

## 6.1 Generate AI Prompt Library

**Phase:** 6-AI
**Output:** `lib/features/ai_generation/data/prompts/`
**Inputs:** AI requirements, content types

```
Generate comprehensive AI prompt library for Social Media AI.

## Prompt Library Structure

### Caption Prompts
```
prompts/
├── captions/
│   ├── general.txt
│   ├── instagram.txt
│   ├── twitter.txt
│   ├── linkedin.txt
│   ├── tiktok.txt
│   └── youtube.txt
├── hashtags/
│   ├── trending.txt
│   ├── niche.txt
│   ├── branded.txt
│   └── platform_specific.txt
├── titles/
│   ├── blog.txt
│   ├── video.txt
│   └── social.txt
├── ideas/
│   ├── content_calendar.txt
│   ├── trending_topics.txt
│   └── seasonal.txt
└── repurpose/
    ├── cross_platform.txt
    └── format_conversion.txt
```

### System Prompts
```typescript
export const systemPrompts = {
  caption: `You are an expert social media copywriter. Create engaging captions that:
- Match the platform's tone and style
- Include relevant emojis
- Drive engagement
- Include a clear call-to-action
- Stay within character limits`,

  hashtags: `You are a hashtag research expert. Generate relevant hashtags that:
- Are trending on the platform
- Match the content topic
- Mix popular and niche tags
- Avoid banned hashtags
- Stay within platform limits`,

  ideas: `You are a content strategist. Generate content ideas that:
- Align with current trends
- Match the brand voice
- Drive engagement
- Are platform-appropriate
- Consider seasonal relevance`
};
```

### Template Variables
```typescript
export interface PromptVariables {
  topic: string;
  platform: string;
  tone?: string;
  length?: 'short' | 'medium' | 'long';
  target_audience?: string;
  include_emojis?: boolean;
  include_hashtags?: boolean;
  include_cta?: boolean;
  language?: string;
}
```

## Caption Templates

### Instagram Caption Template
```
Create an Instagram caption for a post about {topic}.

Requirements:
- Tone: {tone}
- Length: {length}
- Include emojis: {include_emojis}
- Include hashtags: {include_hashtags}
- Include CTA: {include_cta}
- Target audience: {target_audience}

The caption should:
1. Start with a hook (first line is visible before "more")
2. Tell a story or share insight
3. Include relevant emojis
4. End with a call-to-action
5. Include 5-10 relevant hashtags

Platform constraints:
- Character limit: 2,200
- Hashtag limit: 30 (recommended: 5-10)
- First line visible: ~125 characters
```

### Twitter Caption Template
```
Create a Twitter/X tweet about {topic}.

Requirements:
- Tone: {tone}
- Character limit: 280
- Include emojis: {include_emojis}
- Include hashtags: {include_hashtags}
- Include CTA: {include_cta}

The tweet should:
1. Be concise and impactful
2. Start with a hook
3. Use line breaks for readability
4. Include 1-3 hashtags
5. End with engagement prompt
```

[Continue for LinkedIn, TikTok, YouTube]

## Hashtag Templates

### Trending Hashtags
```
Generate trending hashtags for a post about {topic} on {platform}.

Requirements:
- Mix of popular (1M+ posts) and niche (10K-100K posts)
- 5-10 hashtags total
- Platform-appropriate
- Avoid banned hashtags
- Include branded hashtag if provided: {brand_hashtag}

Format: Return as comma-separated list
```

### Niche Hashtags
```
Generate niche hashtags for {topic} in the {niche} space.

Requirements:
- Focus on engaged communities
- 10-20 hashtags
- Mix of sizes (small, medium, large)
- Relevant to specific audience
```

## Title Templates

### Blog Title
```
Generate 5 blog title options for: {topic}

Requirements:
- Include power words
- Use numbers if appropriate
- Create curiosity
- SEO-friendly
- Under 60 characters for meta title

Format:
1. Title option 1
2. Title option 2
...
```

### Video Title
```
Generate 5 YouTube video title options for: {topic}

Requirements:
- Include keywords
- Create curiosity gap
- Under 60 characters
- Avoid clickbait
- Include emotional triggers
```

## Content Ideas Templates

### Content Calendar
```
Generate 30 content ideas for {platform} in the {niche} space.

Requirements:
- Mix of content types (educational, entertaining, promotional)
- Include trending topics
- Consider seasonal relevance
- Platform-appropriate formats
- Include hooks and angles

Format:
Day 1: [Content type] - [Topic] - [Hook]
Day 2: ...
```

### Trending Topics
```
Identify 10 trending topics in {niche} for {platform}.

Requirements:
- Currently viral or growing
- Relevant to target audience
- Brand-safe
- Include content angles
- Suggest timing
```

Generate complete prompt library with templates for all content types.
```

**Expected Output:** 50+ prompt templates across all content types and platforms.

---

## 6.2 Generate Caption Prompts

**Phase:** 6-AI
**Output:** Caption generation system
**Inputs:** Platform specs, content requirements

```
Generate AI caption generation system for Social Media AI.

## Caption Generation Service

### generateCaption(params: CaptionParams)
```typescript
interface CaptionParams {
  topic: string;
  platform: Platform;
  tone?: 'professional' | 'casual' | 'humorous' | 'inspirational' | 'educational';
  length?: 'short' | 'medium' | 'long';
  include_emojis?: boolean;
  include_hashtags?: boolean;
  include_cta?: boolean;
  target_audience?: string;
  brand_voice?: string;
  language?: string;
}

interface CaptionResult {
  caption: string;
  hashtags: string[];
  emojis: string[];
  character_count: number;
  readability_score: number;
  engagement_prediction: number;
}
```

### Platform-Specific Rules

#### Instagram
- Max length: 2,200 characters
- First line hook: ~125 characters
- Hashtag limit: 30 (recommend 5-10)
- Emoji usage: Moderate to heavy
- Line breaks: Use for readability

#### Twitter/X
- Max length: 280 characters
- No line breaks (use thread for longer)
- Hashtag limit: 2-3
- Emoji usage: Light
- Concise and punchy

#### LinkedIn
- Max length: 3,000 characters
- Professional tone
- Hashtag limit: 3-5
- Emoji usage: Light to moderate
- Storytelling format

#### TikTok
- Max length: 2,200 characters
- Casual and authentic
- Hashtag limit: 5-10
- Emoji usage: Heavy
- Trend-aware

#### YouTube
- Max length: 5,000 characters (description)
- First 2 lines visible
- Hashtag limit: 15
- Include timestamps for longer content

### Tone Profiles
```typescript
const toneProfiles = {
  professional: {
    vocabulary: 'formal',
    sentence_structure: 'complex',
    emoji_frequency: 'low',
    cta_style: 'direct'
  },
  casual: {
    vocabulary: 'informal',
    sentence_structure: 'varied',
    emoji_frequency: 'moderate',
    cta_style: 'friendly'
  },
  humorous: {
    vocabulary: 'playful',
    sentence_structure: 'varied',
    emoji_frequency: 'moderate',
    cta_style: 'engaging'
  },
  inspirational: {
    vocabulary: 'elevated',
    sentence_structure: 'flowing',
    emoji_frequency: 'moderate',
    cta_style: 'motivational'
  },
  educational: {
    vocabulary: 'clear',
    sentence_structure: 'structured',
    emoji_frequency: 'low',
    cta_style: 'informative'
  }
};
```

### Caption Templates by Type

#### Promotional
```
🚀 [Hook - attention grabber]

[Problem statement or pain point]

[Solution - your product/service]

[Benefit 1]
[Benefit 2]
[Benefit 3]

[CTA - clear call to action]

[Hashtags]
```

#### Educational
```
📚 [Topic introduction]

Did you know? [Interesting fact]

Here's what you need to know:

1️⃣ [Point 1]
2️⃣ [Point 2]
3️⃣ [Point 3]

💡 Pro tip: [Expert insight]

[Question to drive engagement]

[Hashtags]
```

#### Inspirational
```
✨ [Opening quote or statement]

[Story or anecdote]

[Lesson learned]

[Application to audience]

[CTA - share your story]

[Hashtags]
```

Generate complete caption generation system with all templates and rules.
```

**Expected Output:** Complete caption generation system with platform-specific rules and templates.

---

## 6.3 Generate Title Prompts

**Phase:** 6-AI
**Output:** Title generation system
**Inputs:** Content types, SEO requirements

```
Generate AI title generation system for Social Media AI.

## Title Generation Service

### generateTitles(params: TitleParams)
```typescript
interface TitleParams {
  content: string;
  type: 'blog' | 'video' | 'social' | 'email' | 'ad';
  platform?: Platform;
  style?: 'listicle' | 'how-to' | 'question' | 'statement' | 'curiosity';
  count?: number;
  max_length?: number;
  include_keywords?: string[];
}

interface TitleResult {
  titles: string[];
  scores: {
    readability: number;
    seo: number;
    engagement: number;
    curiosity: number;
  };
}
```

### Title Formulas

#### Listicle
```
[Number] [Adjective] [Noun] to [Achieve Result]

Examples:
- 10 Powerful Ways to Boost Your Engagement
- 7 Secret Strategies Top Creators Use
- 5 Simple Steps to Double Your Followers
```

#### How-To
```
How to [Achieve Result] in [Timeframe] (Without [Pain Point])

Examples:
- How to Create Viral Content in 30 Minutes
- How to Grow Your Audience Without Paid Ads
- How to Schedule Posts While You Sleep
```

#### Question
```
[Question That Challenges Assumption]?

Examples:
- Are You Making These Content Mistakes?
- What If There Was a Better Way to Post?
- Ready to Transform Your Social Media?
```

#### Statement
```
[Bold Claim]: [Supporting Statement]

Examples:
- This Changed Everything: How AI is Revolutionizing Content
- The Truth About Social Media Growth
- Why Top Creators Are Switching to AI
```

#### Curiosity Gap
```
[Incomplete Thought]... (And Why It Matters)

Examples:
- I Tried This for 30 Days... The Results Surprised Me
- The One Thing Top Creators Won't Tell You
- What Happens When You Stop Posting Manually
```

### SEO Title Optimization
- Include primary keyword in first 60 characters
- Use power words (Ultimate, Essential, Proven)
- Include numbers when relevant
- Create emotional response
- Avoid clickbait

### Platform-Specific Title Rules

#### YouTube
- Max 60 characters
- Front-load keywords
- Include emotional triggers
- Use brackets for context [2024]

#### Blog
- Max 60 characters for meta
- Include primary keyword
- Use power words
- Create curiosity

#### LinkedIn
- Professional tone
- Include industry keywords
- Thought leadership angle
- Max 150 characters

Generate complete title generation system with all formulas and rules.
```

**Expected Output:** Complete title generation system with SEO optimization and platform rules.

---

## 6.4 Generate Hashtag Prompts

**Phase:** 6-AI
**Output:** Hashtag generation system
**Inputs:** Platform data, trending topics

```
Generate AI hashtag generation system for Social Media AI.

## Hashtag Generation Service

### generateHashtags(params: HashtagParams)
```typescript
interface HashtagParams {
  content: string;
  platform: Platform;
  count?: number;
  trending?: boolean;
  niche?: string;
  brand_hashtag?: string;
  exclude?: string[];
}

interface HashtagResult {
  hashtags: Hashtag[];
  categories: {
    trending: Hashtag[];
    niche: Hashtag[];
    branded: Hashtag[];
    evergreen: Hashtag[];
  };
  strategy: string;
}

interface Hashtag {
  tag: string;
  posts_count: number;
  engagement_rate: number;
  difficulty: 'low' | 'medium' | 'high';
  category: string;
}
```

### Hashtag Strategy by Platform

#### Instagram
- Optimal count: 5-10
- Mix sizes: 2 large, 3 medium, 5 small
- Use 3-5 branded hashtags
- Research banned hashtags
- Update regularly

#### Twitter/X
- Optimal count: 1-3
- Trending hashtags preferred
- Brand hashtag optional
- Keep concise

#### LinkedIn
- Optimal count: 3-5
- Industry-specific
- Professional tone
- Avoid overuse

#### TikTok
- Optimal count: 5-10
- Trending hashtags critical
- Challenge hashtags
- Niche community tags

#### YouTube
- Optimal count: 3-15
- Include in description
- Mix broad and specific
- SEO-friendly

### Hashtag Categories

#### Trending
```typescript
const trendingHashtags = {
  instagram: ['#trending', '#viral', '#explore', '#instagood', '#photooftheday'],
  twitter: ['#trending', '#breaking', '#news', '#twitter'],
  tiktok: ['#fyp', '#viral', '#trending', '#foryou', '#tiktok'],
  linkedin: ['#professional', '#business', '#leadership', '#innovation']
};
```

#### Niche (Example: Marketing)
```typescript
const nicheHashtags = {
  marketing: ['#digitalmarketing', '#contentmarketing', '#socialmediamarketing', '#marketingtips'],
  fitness: ['#fitness', '#workout', '#healthylifestyle', '#fitfam'],
  food: ['#foodie', '#foodporn', '#instafood', '#homecooking']
};
```

### Hashtag Research Algorithm
1. Analyze content for keywords
2. Search platform for related hashtags
3. Check engagement metrics
4. Verify not banned
5. Mix sizes for optimal reach
6. Add branded hashtags
7. Generate strategy explanation

### Hashtag Performance Tracking
```typescript
interface HashtagPerformance {
  tag: string;
  uses: number;
  reach: number;
  engagement: number;
  trend: 'rising' | 'stable' | 'declining';
}
```

Generate complete hashtag generation system with research and tracking.
```

**Expected Output:** Complete hashtag generation system with research and performance tracking.

---

## 6.5 Generate Translation Prompts

**Phase:** 6-AI
**Output:** Translation service
**Inputs:** Language support, localization

```
Generate AI translation system for Social Media AI.

## Translation Service

### translateContent(params: TranslationParams)
```typescript
interface TranslationParams {
  content: string;
  source_language: string;
  target_languages: string[];
  context?: string;
  tone?: string;
  preserve_emojis?: boolean;
  preserve_hashtags?: boolean;
}

interface TranslationResult {
  translations: {
    [language: string]: {
      content: string;
      hashtags: string[];
      cultural_notes: string[];
    };
  };
}
```

### Supported Languages
```typescript
const supportedLanguages = {
  en: 'English',
  es: 'Spanish',
  fr: 'French',
  de: 'German',
  it: 'Italian',
  pt: 'Portuguese',
  nl: 'Dutch',
  ja: 'Japanese',
  ko: 'Korean',
  zh: 'Chinese',
  ar: 'Arabic',
  hi: 'Hindi',
  th: 'Thai',
  vi: 'Vietnamese',
  id: 'Indonesian',
  tr: 'Turkish',
  pl: 'Polish',
  ru: 'Russian'
};
```

### Translation Guidelines

#### Cultural Adaptation
- Adapt idioms to target culture
- Consider color symbolism
- Adjust humor appropriately
- Respect cultural norms
- Localize examples

#### Social Media Specifics
- Preserve emojis (universal)
- Adapt hashtag style per platform
- Consider character limits
- Localize trending topics
- Adapt CTA style

#### Tone Preservation
- Maintain brand voice
- Adapt formality level
- Preserve emotional impact
- Consider cultural context

### Translation Memory
```typescript
interface TranslationMemory {
  source: string;
  target: string;
  language: string;
  context: string;
  approved: boolean;
}
```

### Quality Checks
1. Grammar verification
2. Tone consistency
3. Character limit check
4. Emoji preservation
5. Hashtag relevance
6. Cultural appropriateness

Generate complete translation system with cultural adaptation.
```

**Expected Output:** Complete translation system with 18+ languages and cultural adaptation.

---

## 6.6 Generate AI Service Layer

**Phase:** 6-AI
**Output:** `lib/features/ai_generation/data/services/`
**Inputs:** AI requirements, provider APIs

```
Generate AI service layer for Social Media AI.

## AI Service Architecture

### Provider Abstraction
```typescript
interface AIProvider {
  generateCaption(params: CaptionParams): Promise<string>;
  generateHashtags(params: HashtagParams): Promise<string[]>;
  generateTitle(params: TitleParams): Promise<string[]>;
  translateContent(params: TranslationParams): Promise<TranslationResult>;
}
```

### OpenAI Provider
```typescript
class OpenAIProvider implements AIProvider {
  private client: OpenAI;
  
  async generateCaption(params: CaptionParams): Promise<string> {
    const prompt = this.buildCaptionPrompt(params);
    const response = await this.client.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { role: 'system', content: systemPrompts.caption },
        { role: 'user', content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 500
    });
    return response.choices[0].message.content;
  }
  
  // Implement other methods...
}
```

### Anthropic Provider
```typescript
class AnthropicProvider implements AIProvider {
  private client: Anthropic;
  
  async generateCaption(params: CaptionParams): Promise<string> {
    const prompt = this.buildCaptionPrompt(params);
    const response = await this.client.messages.create({
      model: 'claude-3-opus-20240229',
      max_tokens: 500,
      messages: [{ role: 'user', content: prompt }]
    });
    return response.content[0].text;
  }
  
  // Implement other methods...
}
```

### Response Caching
```typescript
class AICache {
  private redis: Redis;
  
  async get(key: string): Promise<string | null> {
    return await this.redis.get(`ai:${key}`);
  }
  
  async set(key: string, value: string, ttl: number): Promise<void> {
    await this.redis.setex(`ai:${key}`, ttl, value);
  }
  
  generateKey(params: any): string {
    return crypto.createHash('md5')
      .update(JSON.stringify(params))
      .digest('hex');
  }
}
```

### Rate Limiting
```typescript
class AIRateLimiter {
  private limits: Map<string, RateLimit>;
  
  async checkLimit(userId: string): Promise<boolean> {
    const limit = this.limits.get(userId);
    if (!limit) return true;
    return limit.remaining > 0;
  }
  
  async consumeToken(userId: string): Promise<void> {
    // Decrease remaining tokens
  }
}
```

### Token Counting
```typescript
class TokenCounter {
  count(text: string, model: string): number {
    // Approximate token count
    return Math.ceil(text.length / 4);
  }
  
  estimateCost(tokens: number, model: string): number {
    const rates: Record<string, number> = {
      'gpt-4': 0.03 / 1000,
      'gpt-3.5-turbo': 0.002 / 1000,
      'claude-3-opus': 0.015 / 1000
    };
    return tokens * (rates[model] || 0.01 / 1000);
  }
}
```

### Error Handling
```typescript
class AIError extends Error {
  constructor(
    message: string,
    public provider: string,
    public code: string,
    public retryable: boolean
  ) {
    super(message);
  }
}

// Retry logic with exponential backoff
async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1 || !error.retryable) {
        throw error;
      }
      await delay(Math.pow(2, i) * 1000);
    }
  }
  throw new Error('Max retries exceeded');
}
```

### Main AI Service
```typescript
class AIService {
  private providers: Map<string, AIProvider>;
  private cache: AICache;
  private rateLimiter: AIRateLimiter;
  private tokenCounter: TokenCounter;
  
  constructor() {
    this.providers = new Map();
    this.cache = new AICache();
    this.rateLimiter = new AIRateLimiter();
    this.tokenCounter = new TokenCounter();
  }
  
  async generate(params: GenerateParams): Promise<GenerateResult> {
    // Check cache
    const cached = await this.cache.get(this.cache.generateKey(params));
    if (cached) return JSON.parse(cached);
    
    // Check rate limit
    if (!await this.rateLimiter.checkLimit(params.userId)) {
      throw new AIError('Rate limit exceeded', 'system', 'RATE_LIMIT', true);
    }
    
    // Select provider
    const provider = this.selectProvider(params);
    
    // Generate with retry
    const result = await withRetry(() => provider.generate(params));
    
    // Cache result
    await this.cache.set(
      this.cache.generateKey(params),
      JSON.stringify(result),
      3600
    );
    
    // Track usage
    await this.trackUsage(params, result);
    
    return result;
  }
}
```

Generate complete AI service layer with providers, caching, and rate limiting.
```

**Expected Output:** Complete AI service layer with provider abstraction, caching, and rate limiting.
