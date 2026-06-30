# Calendar Prompts Library

## Overview

Content calendar generation prompts for weekly/monthly planning, content pillars, and batch creation workflows.

---

## Weekly Calendar Prompt

### System Prompt

```
You are a content calendar strategist. You create balanced, strategic weekly content plans that maximize engagement and maintain consistency.

Calendar Principles:
1. Content pillar balance (40% education, 30% engagement, 20% entertainment, 10% promotion)
2. Platform-specific optimization
3. Audience behavior alignment
4. Algorithm-friendly posting
5. Batch creation efficiency
6. Flexibility for trends
```

### User Prompt Template

```
Create a weekly content calendar for:

Niche: {niche}
Platforms: {platforms}
Posting Frequency: {frequency}
Content Pillars: {pillars}
Team Capacity: {capacity}
Special Events: {events}
Goals: {goals}

Provide:
- Daily content plan
- Platform-specific posts
- Hashtag sets
- Posting times
- Content briefs
```

### Weekly Calendar Template

```yaml
weekly_calendar:
  week: "Week of {date}"
  niche: "digital marketing"
  theme: "Email Marketing Week"
  
  content_pillars_distribution:
    education: 40%
    engagement: 30%
    entertainment: 20%
    promotion: 10%
  
  monday:
    theme: "Motivation + Education"
    instagram:
      post_type: "reel"
      pillar: "education"
      topic: "Why email marketing is not dead"
      hook: "Email marketing is NOT dead. Here's proof."
      caption: "Email marketing generates $42 for every $1 spent. Yet most marketers ignore it. Here's why you shouldn't... {continue}"
      hashtags: "#EmailMarketing #MarketingTips #DigitalMarketing"
      time: "7:00 AM"
      content_brief: "Create 30-second reel with data points showing email marketing ROI"
    
    tiktok:
      post_type: "video"
      pillar: "entertainment"
      topic: "Marketing jargon explained by 5-year-old"
      hook: "POV: You're explaining SEO to a 5-year-old"
      caption: "When marketing gets too complicated 😂 #Marketing #SEO #LearnOnTikTok"
      time: "12:00 PM"
      content_brief: "Create 15-second video with trending audio, text overlays"
    
    linkedin:
      post_type: "text"
      pillar: "education"
      topic: "The email strategy that increased our open rates by 41%"
      hook: "Last quarter, our email open rates were 18%."
      caption: "Last quarter, our email open rates were 18%. Today, they're 41%. Here's the strategy that made it happen... {continue}"
      hashtags: "#EmailMarketing #MarketingStrategy #DigitalMarketing"
      time: "9:00 AM"
      content_brief: "Write thought leadership post with data and personal story"
  
  tuesday:
    theme: "Tutorial + Engagement"
    instagram:
      post_type: "carousel"
      pillar: "education"
      topic: "How to write subject lines that get opened"
      hook: "Stop writing boring subject lines."
      caption: "Your subject line has ONE job: get the open. Here are 7 formulas that actually work (swipe →)"
      hashtags: "#EmailSubjectLines #EmailMarketing #Copywriting"
      time: "7:00 AM"
      slides: 7
      content_brief: "Create carousel with 7 subject line formulas, each slide one formula"
    
    twitter:
      post_type: "thread"
      pillar: "education"
      topic: "7 email subject line formulas"
      hook: "I analyzed 1,000 email campaigns. These 7 subject line formulas appear in every high-performing one. 🧵"
      tweets: 8
      time: "10:00 AM"
      content_brief: "Write 8-tweet thread, one formula per tweet"
    
    linkedin:
      post_type: "poll"
      pillar: "engagement"
      topic: "What's your biggest email marketing challenge?"
      options: ["Low open rates", "High unsubscribe rates", "No time to write", "Don't know what to send"]
      time: "12:00 PM"
      content_brief: "Create poll with follow-up content based on results"
  
  wednesday:
    theme: "Story + Community"
    instagram:
      post_type: "stories"
      pillar: "engagement"
      topic: "Behind-the-scenes + Q&A"
      content: "Share workspace, daily routine, answer follower questions"
      time: "Multiple throughout day"
      content_brief: "Stories series: morning routine, work setup, Q&A sticker, poll"
    
    tiktok:
      post_type: "video"
      pillar: "entertainment"
      topic: "Day in the life of a marketer"
      hook: "Day in my life as a social media manager"
      caption: "This is what I actually do all day 😅 #DayInTheLife #Marketing #WorkLife"
      time: "7:00 PM"
      content_brief: "60-second day-in-the-life video with trending audio"
    
    linkedin:
      post_type: "story"
      pillar: "engagement"
      topic: "The lesson I learned from my biggest failure"
      hook: "3 years ago, I lost my biggest client."
      content: "Personal story with professional lesson"
      time: "8:00 AM"
      content_brief: "Write personal story post with business lesson"
  
  thursday:
    theme: "Value + Proof"
    instagram:
      post_type: "reel"
      pillar: "education"
      topic: "Quick tip: Email segmentation"
      hook: "This one change doubled my open rates."
      caption: "Segmentation isn't optional anymore. Here's the simplest way to start..."
      hashtags: "#EmailSegmentation #EmailMarketing #MarketingTips"
      time: "7:00 AM"
      content_brief: "30-second reel with step-by-step segmentation guide"
    
    youtube:
      post_type: "video"
      pillar: "education"
      topic: "Complete email marketing guide for beginners"
      hook: "How to start email marketing from scratch"
      duration: "12 minutes"
      time: "10:00 AM"
      content_brief: "Full tutorial video with screen sharing, examples"
    
    twitter:
      post_type: "tweet"
      pillar: "engagement"
      topic: "Question/engagement post"
      content: "What's the one marketing tool you can't live without?"
      time: "2:00 PM"
      content_brief: "Engagement tweet to drive replies"
  
  friday:
    theme: "Fun + Community"
    instagram:
      post_type: "reel"
      pillar: "entertainment"
      topic: "Marketing fails compilation"
      hook: "Marketing fails that keep me up at night 😂"
      caption: "We've all been there 😅 #MarketingFails #SocialMedia #Relatable"
      time: "7:00 AM"
      content_brief: "Compilation reel with trending audio, text overlays"
    
    tiktok:
      post_type: "video"
      pillar: "entertainment"
      topic: "Marketing trend that needs to die"
      hook: "This marketing trend needs to STOP"
      caption: "Unpopular opinion incoming 🙊 #MarketingHotTake #SocialMedia #HotTake"
      time: "12:00 PM"
      content_brief: "Hot take video with strong opinion, trending audio"
    
    linkedin:
      post_type: "text"
      pillar: "engagement"
      topic: "Weekend reading recommendations"
      hook: "3 articles that changed how I think about marketing"
      content: "Share valuable resources with personal commentary"
      time: "9:00 AM"
      content_brief: "Resource-sharing post with personal insights"
  
  saturday:
    theme: "Casual + Personal"
    instagram:
      post_type: "reel"
      pillar: "entertainment"
      topic: "Weekend vibes + personal content"
      hook: "Saturday morning vibes ☕"
      caption: "Taking a break to recharge for next week. What are you up to? 👇"
      time: "10:00 AM"
      content_brief: "Casual lifestyle content, no hard sell"
    
    stories:
      content: "Weekend activities, personal content, engagement stickers"
      time: "Throughout day"
      content_brief: "Authentic personal stories, polls, question boxes"
  
  sunday:
    theme: "Planning + Preview"
    instagram:
      post_type: "carousel"
      pillar: "education"
      topic: "Weekly recap + next week preview"
      hook: "This week we covered: {topics}"
      content: "Summarize week's content, tease next week"
      time: "6:00 PM"
      content_brief: "Recap carousel with key takeaways"
    
    stories:
      content: "Week recap, next week teaser, community highlight"
      time: "5:00 PM"
      content_brief: "Stories series: recap, preview, community feature"
```

---

## Monthly Calendar Prompt

### User Prompt Template

```
Create a monthly content calendar for:

Month: {month}
Niche: {niche}
Platforms: {platforms}
Goals: {goals}
Events: {events}
Campaigns: {campaigns}
Budget: {budget}

Provide:
- Monthly themes
- Weekly breakdowns
- Content pillars
- Key dates
- Campaign integration
- Resource allocation
```

### Monthly Calendar Template

```yaml
monthly_calendar:
  month: "{month}"
  niche: "fitness"
  
  monthly_theme: "New Year, New You"
  monthly_goals:
    - "Increase followers by 10%"
    - "Launch email course"
    - "Build community engagement"
  
  content_pillars:
    education: 35%
    motivation: 30%
    entertainment: 20%
    promotion: 15%
  
  week_1:
    theme: "Goal Setting"
    focus: "Help audience set realistic goals"
    key_content:
      - "How to set fitness goals that actually stick"
      - "The science of goal achievement"
      - "Goal-setting workshop (live)"
    hashtags: ["#FitnessGoals", "#GoalSetting", "#NewYear"]
    campaign: "Email course launch announcement"
  
  week_2:
    theme: "Building Habits"
    focus: "Habit formation strategies"
    key_content:
      - "The 2-minute rule for building habits"
      - "Habit tracker walkthrough"
      - "Client habit transformation stories"
    hashtags: ["#Habits", "#Consistency", "#FitnessJourney"]
    campaign: "Email course open enrollment"
  
  week_3:
    theme: "Overcoming Obstacles"
    focus: "Common challenges and solutions"
    key_content:
      - "Why you keep quitting (and how to stop)"
      - "Motivation vs discipline"
      - "Q&A: Your biggest challenges"
    hashtags: ["#Motivation", "#Discipline", "#NeverGiveUp"]
    campaign: "Email course testimonials"
  
  week_4:
    theme: "Review & Adjust"
    focus: "Monthly review and planning"
    key_content:
      - "How to review your progress"
      - "Adjusting your strategy"
      - "February preview"
    hashtags: ["#Progress", "#Review", "#FitnessUpdate"]
    campaign: "Email course last chance"
  
  key_dates:
    - date: "January 1"
      event: "New Year's Day"
      content_angle: "New beginnings, fresh starts"
      priority: "high"
    
    - date: "January 15"
      event: "Mid-month motivation"
      content_angle: "Keeping resolutions alive"
      priority: "medium"
    
    - date: "January 31"
      event: "Month-end review"
      content_angle: "Progress check, celebrate wins"
      priority: "medium"
  
  campaign_integration:
    campaign: "30-Day Fitness Challenge"
    timeline: "Full month"
    content_touchpoints:
      - "Week 1: Announcement and sign-up"
      - "Week 2: Daily tips and motivation"
      - "Week 3: Progress check and testimonials"
      - "Week 4: Results and next steps"
    email_sequence: "Daily challenge emails"
    landing_page: "Optimized for conversions"
```

---

## Content Pillars Prompt

### System Prompt

```
You define and structure content pillars that provide consistent, strategic content themes.
```

### User Prompt Template

```
Define content pillars for:

Niche: {niche}
Brand: {brand_name}
Audience: {audience}
Goals: {goals}
Voice: {brand_voice}

Provide:
- 4-5 content pillars
- Percentage distribution
- Topic examples for each
- Content formats for each
- Hashtag strategies
```

### Content Pillars Template

```yaml
content_pillars:
  brand: "{brand_name}"
  niche: "digital marketing"
  
  pillars:
    - name: "Education"
      percentage: 40%
      description: "Teach valuable skills and knowledge"
      topics:
        - "How-to guides"
        - "Tutorial content"
        - "Industry insights"
        - "Tool reviews"
        - "Strategy breakdowns"
      content_formats:
        - "Carousel posts"
        - "Tutorial videos"
        - "Thread posts"
        - "Blog articles"
      hashtags:
        primary: ["#MarketingTips", "#DigitalMarketing", "#LearnMarketing"]
        secondary: ["#HowTo", "#Tutorial", "#MarketingEducation"]
      goals: ["Establish authority", "Drive saves/shares", "Build email list"]
    
    - name: "Motivation"
      percentage: 25%
      description: "Inspire and encourage action"
      topics:
        - "Success stories"
        - "Mindset shifts"
        - "Overcoming challenges"
        - "Goal achievement"
        - "Personal journey"
      content_formats:
        - "Inspirational reels"
        - "Story posts"
        - "Quote graphics"
        - "Before/after content"
      hashtags:
        primary: ["#Motivation", "#Inspiration", "#SuccessMindset"]
        secondary: ["#GrowthMindset", "#NeverGiveUp", "#Hustle"]
      goals: ["Build emotional connection", "Increase shares", "Drive engagement"]
    
    - name: "Entertainment"
      percentage: 20%
      description: "Make them laugh, relate, or enjoy"
      topics:
        - "Industry humor"
        - "Relatable moments"
        - "Trending content"
        - "Behind-the-scenes"
        - "Day-in-the-life"
      content_formats:
        - "Reels with trending audio"
        - "Memes"
        - "Story polls/questions"
        - "TikTok-style content"
      hashtags:
        primary: ["#MarketingHumor", "#Relatable", "#MarketingLife"]
        secondary: ["#MarketingMemes", "#WorkLife", "#OfficeHumor"]
      goals: ["Increase reach", "Build personality", "Drive comments"]
    
    - name: "Community"
      percentage: 10%
      description: "Build relationships and engagement"
      topics:
        - "Q&A sessions"
        - "Follower features"
        - "Polls and questions"
        - "Collaborations"
        - "User-generated content"
      content_formats:
        - "Stories with stickers"
        - "Live sessions"
        - "Collaborative posts"
        - "Community highlights"
      hashtags:
        primary: ["#Community", "#MarketingCommunity", "#Connect"]
        secondary: ["#Networking", "#MarketingFriends", "#Together"]
      goals: ["Build loyalty", "Increase engagement", "Create advocates"]
    
    - name: "Promotion"
      percentage: 5%
      description: "Showcase products/services"
      topics:
        - "Product features"
        - "Customer testimonials"
        - "Special offers"
        - "Case studies"
        - "Service explanations"
      content_formats:
        - "Product demos"
        - "Testimonial graphics"
        - "Announcement posts"
        - "Limited-time offers"
      hashtags:
        primary: ["#[BrandName]", "#ProductLaunch", "#SpecialOffer"]
        secondary: ["#CustomerLove", "#Testimonial", "#Results"]
      goals: ["Drive sales", "Generate leads", "Show social proof"]
```

---

## Batch Creation Prompt

### System Prompt

```
You create batch content production workflows that maximize efficiency while maintaining quality.
```

### User Prompt Template

```
Create a batch creation workflow for:

Content Type: {content_type}
Quantity: {quantity}
Platforms: {platforms}
Time Available: {time}
Team Size: {team}
Tools Available: {tools}

Provide:
- Workflow steps
- Time allocation
- Templates to use
- Quality checklist
- Distribution plan
```

### Batch Creation Template

```yaml
batch_creation:
  content_type: "instagram_carousel"
  quantity: 10
  platforms: ["instagram"]
  time_available: "4 hours"
  
  workflow:
    phase_1_research:
      duration: "30 minutes"
      tasks:
        - task: "Topic research"
          time: "15 minutes"
          output: "List of 10 topics with angles"
        
        - task: "Competitor analysis"
          time: "10 minutes"
          output: "Top-performing content reference"
        
        - task: "Hashtag research"
          time: "5 minutes"
          output: "Hashtag sets for each post"
    
    phase_2_creation:
      duration: "2 hours"
      tasks:
        - task: "Write all captions"
          time: "30 minutes"
          output: "10 captions with hooks and CTAs"
        
        - task: "Create design templates"
          time: "15 minutes"
          output: "Reusable carousel templates"
        
        - task: "Design all carousels"
          time: "60 minutes"
          output: "10 completed carousels"
        
        - task: "Add text overlays"
          time: "15 minutes"
          output: "Final designs with text"
    
    phase_3_quality:
      duration: "30 minutes"
      tasks:
        - task: "Proofread all content"
          time: "10 minutes"
          output: "Error-free captions"
        
        - task: "Check design consistency"
          time: "10 minutes"
          output: "Brand-aligned designs"
        
        - task: "Verify hashtags and tags"
          time: "10 minutes"
          output: "Optimized hashtag sets"
    
    phase_4_scheduling:
      duration: "30 minutes"
      tasks:
        - task: "Upload to scheduler"
          time: "15 minutes"
          output: "All content queued"
        
        - task: "Set posting times"
          time: "10 minutes"
          output: "Optimized schedule"
        
        - task: "Final review"
          time: "5 minutes"
          output: "Schedule confirmed"
  
  templates:
    caption_template: |
      {Hook line}
      
      {Value proposition}
      
      {Key points with emoji bullets}
      
      {CTA}
      
      {Hashtags}
    
    carousel_template:
      slide_1: "Hook slide - Bold statement"
      slide_2_8: "Content slides - One point each"
      slide_9: "CTA slide - Call to action"
  
  quality_checklist:
    - "Hook grabs attention in first line"
    - "Caption under 2200 characters"
    - "Hashtags relevant and varied"
    - "CTA clear and actionable"
    - "Design consistent with brand"
    - "Text readable at small size"
    - "No typos or errors"
    - "Images high quality"
```

---

## Content Repurposing Calendar

### User Prompt Template

```
Create a repurposing calendar for:

Original Content: {content_description}
Platforms: {platforms}
Timeframe: {timeframe}

Provide:
- Repurposing schedule
- Platform-specific adaptations
- Content variations
- Cross-promotion strategy
```

### Repurposing Calendar Template

```yaml
repurposing_calendar:
  original_content: "YouTube video: 10 Email Marketing Tips"
  duration: "12 minutes"
  
  week_1:
    day_1:
      platform: "youtube"
      content: "Full video publish"
      time: "10:00 AM"
    
    day_2:
      platform: "instagram"
      content: "Carousel: 10 tips summary"
      time: "7:00 AM"
    
    day_3:
      platform: "twitter"
      content: "Thread: 10 tips"
      time: "10:00 AM"
    
    day_4:
      platform: "tiktok"
      content: "Tip #1 video"
      time: "12:00 PM"
    
    day_5:
      platform: "linkedin"
      content: "Article version"
      time: "9:00 AM"
    
    day_6:
      platform: "pinterest"
      content: "10 pins (one per tip)"
      time: "2:00 PM"
    
    day_7:
      platform: "email"
      content: "Newsletter with video embed"
      time: "8:00 AM"
  
  week_2:
    day_1:
      platform: "tiktok"
      content: "Tip #2 video"
      time: "12:00 PM"
    
    day_2:
      platform: "instagram"
      content: "Reel: Tip #1"
      time: "7:00 AM"
    
    [Continue for all tips]
  
  week_3:
    - platform: "instagram"
      content: "Behind-the-scenes of creating video"
    
    - platform: "twitter"
      content: "Results/feedback thread"
    
    - platform: "linkedin"
      content: "Personal story post"
  
  week_4:
    - platform: "youtube"
      content: "Follow-up video responding to comments"
    
    - platform: "all"
      content: "Roundup post with best responses"
```
