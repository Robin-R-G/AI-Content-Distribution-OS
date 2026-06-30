# Content Ideas Prompts Library

## Overview

Content idea generation prompts for niche topics, trending subjects, calendar planning, and series content.

---

## Niche Content Ideas Prompt

### System Prompt

```
You are a content idea generator specializing in social media. You generate relevant, engaging content ideas that align with audience interests, platform algorithms, and business goals.

Idea Generation Framework:
1. Audience Pain Points
2. Industry Trends
3. Seasonal Relevance
4. Content Format Variety
5. Engagement Potential
6. Brand Alignment
```

### User Prompt Template

```
Generate content ideas for:

Niche: {niche}
Industry: {industry}
Target Audience: {audience}
Platforms: {platforms}
Content Pillars: {content_pillars}
Goals: {goals}
Current Content: {existing_content}

Generate:
- 30 content ideas
- Categorized by pillar
- Platform-optimized
- With hooks and angles
```

### Content Ideas Output

```yaml
content_ideas:
  niche: "digital marketing"
  total_ideas: 30
  categories:
    education:
      - idea: "How to create a content calendar from scratch"
        platform: "instagram"
        format: "carousel"
        hook: "I used to post randomly. Then I made this calendar."
        key_points: ["Planning tools", "Content themes", "Scheduling"]
        engagement_potential: "high"
      
      - idea: "5 email marketing mistakes killing your open rates"
        platform: "twitter"
        format: "thread"
        hook: "I analyzed 1,000 emails. These mistakes were everywhere."
        key_points: ["Subject lines", "Send times", "Segmentation"]
        engagement_potential: "very_high"
    
    motivation:
      - idea: "From 0 to 10K followers: My honest journey"
        platform: "linkedin"
        format: "story_post"
        hook: "12 months ago, I had 200 followers."
        key_points: ["Challenges", "Lessons", "Milestones"]
        engagement_potential: "high"
    
    entertainment:
      - idea: "Marketing jargon explained by a 5-year-old"
        platform: "tiktok"
        format: "video"
        hook: "POV: You're explaining SEO to your kid"
        key_points: ["SEO", "ROI", "KPI"]
        engagement_potential: "viral"
    
    community:
      - idea: "What's your biggest marketing challenge? (Q&A)"
        platform: "instagram"
        format: "stories_qa"
        hook: "Let's solve your problems together"
        key_points: ["Community engagement", "Problem solving"]
        engagement_potential: "medium"
```

---

## Trending Topics Prompt

### System Prompt

```
You identify trending topics in specific niches and recommend timely content angles.

Trend Sources:
1. Platform trending sections
2. Hashtag trends
3. News and current events
4. Industry publications
5. Competitor content
6. Audience questions
```

### User Prompt Template

```
Find trending topics for:

Niche: {niche}
Time Period: {next_7_days/next_30_days}
Platforms: {platforms}
Audience: {audience}
Competitor Accounts: {competitors}

Provide:
- Top 10 trending topics
- Content angles for each
- Timeliness assessment
- Competition level
- Content recommendations
```

### Trending Topics Output

```yaml
trending_topics:
  niche: "social media marketing"
  timeframe: "next_7_days"
  
  topics:
    - topic: "Instagram algorithm updates"
      trend_source: "official_announcement"
      timeliness: "high (breaks within 48 hours)"
      competition: "high"
      content_angles:
        - "What the update means for creators"
        - "How to adapt your strategy"
        - "My honest reaction to the changes"
      recommended_format: "reel + carousel"
      hashtags: ["#InstagramUpdate", "#AlgorithmChange", "#SocialMediaNews"]
    
    - topic: "AI content creation debate"
      trend_source: "viral_discussion"
      timeliness: "medium (ongoing conversation)"
      competition: "medium"
      content_angles:
        - "AI vs human content: My results"
        - "How I use AI ethically"
        - "The future of content creation"
      recommended_format: "carousel + thread"
      hashtags: ["#AI", "#ContentCreation", "#MarketingAI"]
    
    - topic: "Creator economy backlash"
      trend_source: "news_coverage"
      timeliness: "high (breaking story)"
      competition: "low"
      content_angles:
        - "My honest take on creator burnout"
        - "The reality behind the highlight reel"
        - "How to sustainably grow as a creator"
      recommended_format: "story post + reel"
      hashtags: ["#CreatorEconomy", "#Burnout", "#RealTalk"]
```

---

## Content Calendar Prompt

### System Prompt

```
You are a content calendar strategist. You create comprehensive content calendars that balance consistency, variety, and strategic goals.

Calendar Framework:
1. Content Pillars Distribution
2. Platform-Specific Posting
3. Seasonal Alignment
4. Campaign Integration
5. Engagement Balance
6. Repurposing Strategy
```

### User Prompt Template

```
Create a content calendar for:

Niche: {niche}
Platforms: {platforms}
Posting Frequency: {frequency}
Content Pillars: {pillars}
Goals: {goals}
Special Events: {events}
Team Capacity: {capacity}

Provide:
- Weekly content plan
- Monthly themes
- Platform-specific schedules
- Content types
- Hashtag strategies
```

### Weekly Content Calendar

```yaml
weekly_calendar:
  niche: "fitness"
  week: "Week 1 - January"
  
  monday:
    theme: "Motivation Monday"
    platforms:
      instagram:
        post_type: "reel"
        content: "Weekly motivation + workout preview"
        hook: "New week, new gains. Here's your plan."
        hashtags: ["#MotivationMonday", "#FitnessGoals", "#WorkoutPlan"]
        time: "7:00 AM"
      
      tiktok:
        post_type: "video"
        content: "Quick motivational clip"
        hook: "Monday reminder: You showed up. That's half the battle."
        time: "12:00 PM"
      
      linkedin:
        post_type: "text"
        content: "Professional fitness + discipline"
        hook: "The discipline you build in the gym translates to everything else."
        time: "9:00 AM"
  
  tuesday:
    theme: "Tutorial Tuesday"
    platforms:
      instagram:
        post_type: "carousel"
        content: "Exercise form guide"
        hook: "Stop doing this exercise wrong."
        slides: 7
        time: "7:00 AM"
      
      youtube:
        post_type: "video"
        content: "Full workout tutorial"
        hook: "Full body workout you can do anywhere"
        duration: "15 minutes"
        time: "10:00 AM"
  
  wednesday:
    theme: "Wellness Wednesday"
    platforms:
      instagram:
        post_type: "reel"
        content: "Mental health + fitness"
        hook: "Fitness isn't just physical."
        time: "7:00 AM"
      
      tiktok:
        post_type: "video"
        content: "Recovery tips"
        hook: "Why rest days matter more than workout days"
        time: "12:00 PM"
  
  thursday:
    theme: "Transformation Thursday"
    platforms:
      instagram:
        post_type: "carousel"
        content: "Client transformation"
        hook: "6 months of consistency > 6 months of excuses"
        time: "7:00 AM"
      
      linkedin:
        post_type: "story"
        content: "Client success story"
        hook: "She almost gave up. Here's what changed."
        time: "9:00 AM"
  
  friday:
    theme: "Fun Friday"
    platforms:
      instagram:
        post_type: "reel"
        content: "Gym humor/relatable"
        hook: "POV: You said you'd only do 1 more set"
        time: "7:00 AM"
      
      tiktok:
        post_type: "video"
        content: "Trending audio + fitness"
        hook: "When someone says they don't have time to work out"
        time: "12:00 PM"
  
  saturday:
    theme: "Community Saturday"
    platforms:
      instagram:
        post_type: "stories"
        content: "Q&A + poll"
        hook: "What should I cover next week?"
        time: "10:00 AM"
      
      tiktok:
        post_type: "stitch"
        content: "Answering follower questions"
        hook: "Replying to @user"
        time: "2:00 PM"
  
  sunday:
    theme: "Self-Care Sunday"
    platforms:
      instagram:
        post_type: "reel"
        content: "Recovery and self-care"
        hook: "Sunday reset for the week ahead"
        time: "11:00 AM"
      
      stories:
        content: "Week recap + preview"
        hook: "This week we accomplished..."
```

### Monthly Theme Calendar

```yaml
monthly_themes:
  january:
    theme: "New Year, New Goals"
    focus: "Goal setting, planning, fresh starts"
    content_pillars:
      education: 30%
      motivation: 40%
      entertainment: 20%
      community: 10%
    
    weekly_themes:
      week_1: "Goal Setting Framework"
      week_2: "Building Habits"
      week_3: "Overcoming Obstacles"
      week_4: "Review and Adjust"
    
    special_content:
      - "New Year's Resolution series"
      - "2024 fitness predictions"
      - "Goal setting workshop (live)"
    
    hashtags:
      primary: ["#NewYear", "#FitnessGoals", "#2024Goals"]
      secondary: ["#GoalSetting", "#NewYearResolution", "#FitFam"]
  
  february:
    theme: "Love Your Body"
    focus: "Self-love, body positivity, sustainable fitness"
    content_pillars:
      education: 25%
      motivation: 35%
      entertainment: 25%
      community: 15%
    
    weekly_themes:
      week_1: "Body Positivity"
      week_2: "Sustainable Fitness"
      week_3: "Self-Care Practices"
      week_4: "Valentine's Self-Love"
    
    special_content:
      - "Body positivity challenge"
      - "Self-love workout series"
      - "Couples workout (if applicable)"
    
    hashtags:
      primary: ["#BodyPositivity", "#SelfLove", "#FitnessJourney"]
      secondary: ["#LoveYourself", "#HealthyLifestyle", "#FitLife"]
```

---

## Series Content Prompt

### System Prompt

```
You create content series ideas that build audience loyalty and consistent engagement.

Series Framework:
1. Recurring Format
2. Numbered Episodes
3. Cliffhangers
4. Audience Participation
5. Binge-worthy Structure
6. Cross-platform Integration
```

### User Prompt Template

```
Create content series for:

Niche: {niche}
Platform: {platform}
Audience: {audience}
Goal: {goal}
Frequency: {frequency}
Duration: {duration}

Provide:
- 5 series ideas
- Episode breakdowns
- Hook for each episode
- Engagement strategy
- Cross-platform repurposing
```

### Content Series Ideas

```yaml
content_series:
  niche: "fitness"
  platform: "instagram"
  
  series_1:
    title: "30-Day Transformation Challenge"
    format: "daily_reel"
    episodes: 30
    hook: "Day 1 of my 30-day transformation. Follow along."
    structure:
      day_1_10: "Foundation and habits"
      day_11_20: "Intensity increase"
      day_21_30: "Results and reflection"
    engagement_strategy:
      - "Daily check-ins in comments"
      - "Weekly progress photos"
      - "Follower participation challenge"
    cross_platform:
      tiktok: "Highlight clips"
      youtube: "Weekly recap videos"
      linkedin: "Discipline and consistency lessons"
  
  series_2:
    title: "Exercise Anatomy"
    format: "carousel_series"
    episodes: 12
    hook: "Stop doing this exercise wrong. Let me show you."
    structure:
      episodes_1_4: "Upper body exercises"
      episodes_5_8: "Lower body exercises"
      episodes_9_12: "Core and full body"
    engagement_strategy:
      - "Save-worthy educational content"
      - "Quiz in stories after each post"
      - "Request specific exercises"
    cross_platform:
      tiktok: "Quick tutorial versions"
      youtube: "Full workout tutorials"
      blog: "Detailed written guides"
  
  series_3:
    title: "Real People, Real Results"
    format: "story_series"
    episodes: weekly
    hook: "She almost gave up. Here's what changed."
    structure:
      format: "Client transformation story"
      length: "3-5 story frames"
      frequency: "Weekly"
    engagement_strategy:
      - "Feature followers"
      - "Before/after comparisons"
      - "Tips from transformations"
    cross_platform:
      instagram_feed: "Carousel version"
      linkedin: "Professional success angle"
      tiktok: "Quick transformation clips"
```

---

## Content Repurposing Ideas Prompt

### User Prompt Template

```
Generate repurposing ideas for:

Original Content: {content_description}
Original Platform: {original_platform}
Performance: {performance_metrics}

Generate:
- 10 repurposing ideas
- Platform-optimized versions
- New angles and hooks
- Content format variations
```

### Repurposing Ideas Output

```yaml
repurposing_ideas:
  original:
    type: "Blog post"
    title: "10 Email Marketing Tips"
    platform: "website"
    performance: "5,000 views, 200 shares"
  
  repurposed_content:
    - idea: "Instagram Carousel"
      format: "10-slide carousel"
      hook: "10 email tips that actually work (swipe →)"
      changes: "Visual format, bullet points, emojis"
      platform: "instagram"
    
    - idea: "Twitter Thread"
      format: "10-tweet thread"
      hook: "I analyzed 1,000 email campaigns. Here are 10 tips that actually work 🧵"
      changes: "One tip per tweet, concise language"
      platform: "twitter"
    
    - idea: "TikTok Series"
      format: "10 short videos"
      hook: "Email tip #1: Stop doing this"
      changes: "One tip per video, quick format"
      platform: "tiktok"
    
    - idea: "YouTube Video"
      format: "10-minute tutorial"
      hook: "How to double your email open rates"
      changes: "Deeper explanation, examples, demo"
      platform: "youtube"
    
    - idea: "LinkedIn Article"
      format: "Long-form post"
      hook: "The email marketing strategy that increased our open rates by 41%"
      changes: "Professional angle, data-focused"
      platform: "linkedin"
    
    - idea: "Email Newsletter"
      format: "Weekly tip email"
      hook: "This one email tip changed everything"
      changes: "Exclusive content, personal angle"
      platform: "email"
    
    - idea: "Pinterest Pins"
      format: "10 individual pins"
      hook: "Email Marketing Tip: {specific tip}"
      changes: "Visual graphics, each tip as separate pin"
      platform: "pinterest"
    
    - idea: "Podcast Episode"
      format: "20-minute episode"
      hook: "Let's talk about email marketing that actually works"
      changes: "Conversational, examples, stories"
      platform: "podcast"
    
    - idea: "Infographic"
      format: "Visual summary"
      hook: "10 Email Marketing Tips (Visual Guide)"
      changes: "Data visualization, shareable format"
      platform: "all platforms"
    
    - idea: "Case Study"
      format: "Detailed breakdown"
      hook: "How we increased email open rates by 41%"
      changes: "Results-focused, methodology, data"
      platform: "blog/linkedin"
```

---

## Content Idea Validation Prompt

### User Prompt Template

```
Validate these content ideas:

Ideas: {content_ideas_list}
Niche: {niche}
Audience: {audience}
Platform: {platform}
Goals: {goals}

For each idea, provide:
- Viral potential (1-10)
- Relevance score (1-10)
- Effort level (low/medium/high)
- Priority ranking
- Improvement suggestions
```

### Idea Validation Output

```yaml
idea_validation:
  ideas:
    - idea: "10 Email Marketing Tips"
      viral_potential: 7
      relevance: 9
      effort: "medium"
      priority: "high"
      improvements:
        - "Add specific data points"
        - "Include before/after examples"
        - "Make it more contrarian"
    
    - idea: "Email Marketing vs Social Media"
      viral_potential: 8
      relevance: 8
      effort: "medium"
      priority: "high"
      improvements:
        - "Add personal experience"
        - "Include comparison data"
        - "Create debate angle"
    
    - idea: "My Email Marketing Setup"
      viral_potential: 5
      relevance: 7
      effort: "low"
      priority: "medium"
      improvements:
        - "Add more personal story"
        - "Include specific tools and results"
        - "Make it more relatable"
  
  recommendations:
    top_3_to_create:
      - "Email Marketing vs Social Media (debate angle)"
      - "10 Email Marketing Tips (with data)"
      - "My Email Marketing Setup (personal story)"
    
    ideas_to_combine:
      - "Combine tips + setup into comprehensive guide"
    
    ideas_to_revisit_later:
      - "Email marketing trends (wait for more data)"
```
