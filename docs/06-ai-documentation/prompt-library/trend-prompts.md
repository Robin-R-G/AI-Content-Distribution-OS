# Trend Prompts Library

## Overview

Trend analysis prompts for identifying niche trends, seasonal patterns, viral opportunities, and algorithm insights.

---

## Niche Trend Analysis Prompt

### System Prompt

```
You are a trend analyst specializing in social media and digital marketing. You identify emerging trends, analyze their potential, and recommend content strategies.

Analysis Framework:
1. Trend Identification: What's emerging?
2. Platform Presence: Where is it growing?
3. Audience Relevance: Who cares about this?
4. Competition Level: How saturated?
5. Longevity Assessment: Fad or lasting?
6. Content Opportunity: How to leverage?
```

### User Prompt Template

```
Analyze trends for:

Niche: {niche}
Industry: {industry}
Target Audience: {audience}
Platforms: {platforms}
Timeframe: {timeframe}
Competitors: {competitor_handles}

Analyze:
- Top 5 emerging trends
- Declining trends to avoid
- Seasonal patterns
- Platform-specific opportunities
- Content recommendations
```

### Trend Analysis Output

```yaml
trend_analysis:
  niche: "digital marketing"
  analysis_date: "2024-01-15"
  
  emerging_trends:
    - trend: "AI-powered content creation"
      platforms: ["instagram", "tiktok", "linkedin"]
      growth_rate: "45% month-over-month"
      competition: "medium"
      longevity: "long-term (3-5 years)"
      opportunity_score: 9.2
      content_ideas:
        - "Behind-the-scenes of AI content creation"
        - "AI vs human content comparison"
        - "How I use AI to save 10 hours/week"
    
    - trend: "Authenticity over production value"
      platforms: ["tiktok", "instagram"]
      growth_rate: "32% month-over-month"
      competition: "low"
      longevity: "medium-term (1-2 years)"
      opportunity_score: 8.7
      content_ideas:
        - "Unfiltered office tour"
        - "Mistakes I made this week"
        - "Real vs curated content"
  
  declining_trends:
    - trend: "Perfectly curated feeds"
      platforms: ["instagram"]
      decline_rate: "15% month-over-month"
      reason: "Audience fatigue with perfection"
      recommendation: "Shift to authentic content"
  
  seasonal_patterns:
    - period: "Q1 (January-March)"
      trends: ["New Year goals", "productivity", "fresh starts"]
      opportunity: "high"
    
    - period: "Q2 (April-June)"
      trends: ["summer prep", "budget review", "mid-year goals"]
      opportunity: "medium"
  
  platform_opportunities:
    instagram:
      - "Carousel posts for education"
      - "Reels under 15 seconds"
      - "Collaborative posts"
    
    tiktok:
      - "Storytime content"
      - "Day-in-the-life"
      - "Trend participation"
    
    linkedin:
      - "Personal stories"
      - "Industry insights"
      - "Career advice"
```

---

## Seasonal Trend Prompt

### System Prompt

```
You are a seasonal trend analyst. You predict and identify seasonal content opportunities across industries and platforms.

Analysis Areas:
1. Holiday/Event Calendar
2. Industry-Specific Seasons
3. Cultural Moments
4. Platform Algorithm Changes
5. Consumer Behavior Shifts
6. Content Gap Opportunities
```

### User Prompt Template

```
Identify seasonal trends for:

Niche: {niche}
Industry: {industry}
Target Audience: {audience}
Geographic Focus: {region}
Time Period: {next_3_months/next_6_months/next_year}

Analyze:
- Major events/holidays
- Industry-specific seasons
- Content opportunities
- Competitor gaps
- Content calendar suggestions
```

### Seasonal Calendar Template

```yaml
seasonal_calendar:
  niche: "fitness"
  period: "January - March 2024"
  
  major_events:
    - event: "New Year"
      date: "January 1"
      content_angle: "New Year's resolutions, fresh starts"
      trending_hashtags: ["#NewYearResolution", "#FitnessGoals", "#2024Goals"]
      competition: "very_high"
      recommendation: "Focus on sustainable habits, not extreme goals"
    
    - event: "Valentine's Day"
      date: "February 14"
      content_angle: "Couples workout, self-love, relationship health"
      trending_hashtags: ["#ValentinesDay", "#CouplesWorkout", "#SelfLove"]
      competition: "high"
      recommendation: "Unique angle: solo workout as self-care"
  
  industry_seasons:
    - season: "New Year Rush"
      period: "January 1-31"
      consumer_behavior: "Gym membership surge, home equipment purchases"
      content_opportunity: "Onboarding content, beginner guides"
      competition: "extremely_high"
    
    - season: "Spring Break Prep"
      period: "February-March"
      consumer_behavior: "Beach body prep, weight loss focus"
      content_opportunity: "Quick results, transformation content"
      competition: "high"
  
  content_gaps:
    - gap: "Post-resolution motivation drop"
      timing: "Mid-January to February"
      reason: "Most creators stop posting resolution content"
      opportunity: "Motivation content when competition drops"
    
    - gap: "Mental health awareness"
      timing: "Ongoing"
      reason: "Physical fitness overshadows mental health"
      opportunity: "Holistic wellness content"
```

---

## Viral Pattern Analysis Prompt

### System Prompt

```
You are a viral content analyst. You study patterns in viral content to identify replicable elements.

Analysis Areas:
1. Content Structure Patterns
2. Emotional Triggers
3. Timing Patterns
4. Platform Algorithm Factors
5. Audience Psychology
6. Shareability Elements
```

### User Prompt Template

```
Analyze viral patterns for:

Niche: {niche}
Platform: {platform}
Time Period: {timeframe}
Content Types: {content_types}
Competitor Analysis: {competitors}

Analyze:
- Top viral content patterns
- Emotional triggers used
- Timing and frequency
- Shareability factors
- Replicable elements
```

### Viral Pattern Analysis

```yaml
viral_patterns:
  platform: "tiktok"
  niche: "finance"
  analysis_period: "last_30_days"
  
  top_patterns:
    - pattern: "Contrarian takes"
      example: "Stop saving money. Here's why."
      engagement_rate: "12.5%"
      why_it_works: "Challenges conventional wisdom, creates debate"
      replicable: true
      how_to_replicate: "Find common advice in your niche, question it with data"
    
    - pattern: "Specific numbers"
      example: "I made $4,327 last month doing this"
      engagement_rate: "9.8%"
      why_it_works: "Specificity creates credibility"
      replicable: true
      how_to_replicate: "Use exact numbers, not round figures"
    
    - pattern: "Story hooks"
      example: "POV: You just discovered the best budgeting hack"
      engagement_rate: "8.2%"
      why_it_works: "Immersive, relatable scenario"
      replicable: true
      how_to_replicate: "Start with POV or 'When you...' format"
  
  emotional_triggers:
    - trigger: "Surprise"
      usage: "45% of viral content"
      examples: ["Unexpected results", "Contrarian takes", "Hidden facts"]
    
    - trigger: "Fear of missing out"
      usage: "32% of viral content"
      examples: ["Limited time", "Everyone else knows", "Before it's too late"]
    
    - trigger: "Validation"
      usage: "28% of viral content"
      examples: ["You're not alone", "This is normal", "Relatable content"]
  
  timing_patterns:
    best_days: ["Tuesday", "Thursday", "Saturday"]
    best_times: ["7:00 AM", "12:00 PM", "7:00 PM"]
    avoid: ["Monday morning", "Friday evening"]
    reasoning: "Peak scroll times, not work hours"
  
  shareability_factors:
    - factor: "Educational value"
      correlation: 0.78
      description: "Content that teaches something gets shared"
    
    - factor: "Emotional resonance"
      correlation: 0.72
      description: "Content that makes people feel understood"
    
    - factor: "Identity expression"
      correlation: 0.65
      description: "Content that lets people express who they are"
```

---

## Algorithm Insights Prompt

### System Prompt

```
You are a social media algorithm expert. You understand how platform algorithms work and optimize content for maximum reach.

Analysis Areas:
1. Algorithm factors and weights
2. Content ranking signals
3. Engagement velocity importance
4. Content format preferences
5. Posting strategy optimization
6. Penalty factors to avoid
```

### User Prompt Template

```
Provide algorithm insights for:

Platform: {platform}
Current Performance: {current_metrics}
Goals: {goals}
Content Type: {content_type}
Audience: {audience}

Provide:
- Key algorithm factors
- Content optimization tips
- Posting strategy
- Common mistakes to avoid
- Growth hacking techniques
```

### Algorithm Insights by Platform

```yaml
algorithm_insights:
  platform: "instagram"
  last_updated: "2024-01"
  
  key_factors:
    - factor: "Interest Score"
      weight: "40%"
      description: "How likely user is to engage based on past behavior"
      optimization: "Create content similar to what your audience already engages with"
    
    - factor: "Relationship Score"
      weight: "25%"
      description: "How often user interacts with your content"
      optimization: "Respond to every comment, DM, and mention"
    
    - factor: "Timeliness"
      weight: "20%"
      description: "How recent the post is"
      optimization: "Post when your audience is most active"
    
    - factor: "Session Behavior"
      weight: "15%"
      description: "How user is currently using the app"
      optimization: "Create scroll-stopping content"
  
  content_format_preferences:
    - format: "Reels"
      reach_multiplier: "2.5x"
      recommendation: "Prioritize short-form video"
    
    - format: "Carousels"
      reach_multiplier: "1.8x"
      recommendation: "Use for educational content"
    
    - format: "Single Image"
      reach_multiplier: "1.0x"
      recommendation: "Use for announcements, quotes"
    
    - format: "Stories"
      reach_multiplier: "1.2x"
      recommendation: "Use for engagement, polls, Q&A"
  
  penalty_factors:
    - factor: "Low engagement rate"
      impact: "Reduced reach"
      prevention: "Create engaging content, ask questions"
    
    - factor: "Inconsistent posting"
      impact: "Algorithm deprioritizes"
      prevention: "Maintain consistent schedule"
    
    - factor: "Engagement bait"
      impact: "Shadowbanning"
      prevention: "Avoid 'like for like', 'follow for follow'"
  
  growth_hacks:
    - hack: "Collaborative posts"
      effectiveness: "high"
      description: "Co-author posts with other creators"
    
    - hack: "Consistent niche posting"
      effectiveness: "high"
      description: "Stay focused on one topic"
    
    - hack: "Engage before posting"
      effectiveness: "medium"
      description: "Spend 15 min engaging before your post goes live"
```

---

## Competitor Trend Analysis Prompt

### System Prompt

```
You are a competitive intelligence analyst. You analyze competitor content strategies to identify opportunities and gaps.

Analysis Framework:
1. Content Strategy Analysis
2. Engagement Pattern Analysis
3. Growth Trajectory
4. Content Gaps
5. Opportunity Identification
6. Threat Assessment
```

### User Prompt Template

```
Analyze competitor trends for:

Niche: {niche}
Competitors: {competitor_list}
Platforms: {platforms}
Time Period: {timeframe}

Analyze:
- Top performing content
- Content strategy patterns
- Engagement trends
- Growth rate
- Content gaps
- Opportunities for differentiation
```

### Competitor Analysis Output

```yaml
competitor_analysis:
  niche: "social media marketing"
  competitors: ["@competitor1", "@competitor2", "@competitor3"]
  analysis_period: "last_90_days"
  
  competitor_1:
    handle: "@competitor1"
    followers: "150K"
    growth_rate: "+5% monthly"
    posting_frequency: "5x/week"
    
    top_content_types:
      - type: "Carousel posts"
        avg_engagement: "8.2%"
        frequency: "3x/week"
      
      - type: "Reels"
        avg_engagement: "12.5%"
        frequency: "2x/week"
    
    content_themes:
      - "Industry news"
      - "How-to guides"
      - "Case studies"
    
    engagement_patterns:
      best_day: "Tuesday"
      best_time: "9:00 AM"
      avg_comments: 45
      avg_saves: 120
    
    strengths:
      - "Consistent posting schedule"
      - "High-quality carousels"
      - "Strong community engagement"
    
    weaknesses:
      - "Limited video content"
      - "No live sessions"
      - "Generic captions"
  
  opportunity_gaps:
    - gap: "Video tutorials"
      reason: "No competitor focused on this"
      opportunity_score: 8.5
      recommendation: "Create weekly video tutorial series"
    
    - gap: "Behind-the-scenes content"
      reason: "All competitors show polished content only"
      opportunity_score: 7.8
      recommendation: "Share authentic behind-the-scenes"
    
    - gap: "Interactive content"
      reason: "No polls, quizzes, or Q&A content"
      opportunity_score: 8.2
      recommendation: "Weekly interactive stories"
  
  differentiation_strategies:
    - strategy: "Authenticity"
      description: "Show real results, not just highlights"
      implementation: "Monthly income reports, honest reviews"
    
    - strategy: "Education-first"
      description: "Deep-dive tutorials vs surface tips"
      implementation: "Weekly masterclass-style posts"
    
    - strategy: "Community focus"
      description: "Feature followers, create community"
      implementation: "Weekly follower spotlight"
```

---

## Content Gap Analysis Prompt

### User Prompt Template

```
Identify content gaps in:

Niche: {niche}
Current Content: {content_list}
Competitor Content: {competitor_content}
Audience Questions: {audience_questions}
Search Trends: {trending_topics}

Analyze:
- Topics not covered
- Formats not used
- Questions unanswered
- Emerging opportunities
- Content to update
```

### Content Gap Analysis Output

```yaml
content_gaps:
  niche: "digital marketing"
  
  topic_gaps:
    - topic: "AI in marketing"
      search_volume: "high"
      competition: "medium"
      audience_interest: "very_high"
      priority: "immediate"
      content_ideas:
        - "How to use ChatGPT for email marketing"
        - "AI tools every marketer needs in 2024"
        - "AI vs human copywriting: Results"
    
    - topic: "Privacy-first marketing"
      search_volume: "medium"
      competition: "low"
      audience_interest: "high"
      priority: "high"
      content_ideas:
        - "How to market without third-party cookies"
        - "First-party data strategies"
        - "Privacy-compliant email marketing"
  
  format_gaps:
    - format: "Podcast"
      reason: "No audio content in strategy"
      opportunity: "Repurpose existing content to podcast"
      priority: "medium"
    
    - format: "Interactive content"
      reason: "No quizzes, calculators, or tools"
      opportunity: "Create marketing ROI calculator"
      priority: "high"
  
  question_gaps:
    - question: "How do I start with zero budget?"
      frequency: "asked 50+ times in comments"
      content_type: "comprehensive guide"
      priority: "immediate"
    
    - question: "What tools do you actually use?"
      frequency: "asked weekly"
      content_type: "tool review post"
      priority: "high"
```

---

## Trend Monitoring System

### Automated Trend Detection

```typescript
interface TrendAlert {
  id: string;
  trend: string;
  platform: string;
  growthRate: number;
  competitionLevel: 'low' | 'medium' | 'high';
  opportunityScore: number;
  detectedAt: Date;
  recommendedAction: string;
}

const MONITORING_CONFIG = {
  checkFrequency: 'daily',
  platforms: ['instagram', 'tiktok', 'twitter', 'linkedin'],
  alertThreshold: 0.7, // 70% opportunity score
  minGrowthRate: 20, // 20% week-over-week
};
```

### Trend Evaluation Criteria

| Factor | Weight | Description |
|--------|--------|-------------|
| Growth rate | 25% | How fast is it growing? |
| Competition | 20% | How many are doing it? |
| Relevance | 25% | Does it fit your niche? |
| Longevity | 15% | Will it last? |
| Effort | 15% | How hard to execute? |
