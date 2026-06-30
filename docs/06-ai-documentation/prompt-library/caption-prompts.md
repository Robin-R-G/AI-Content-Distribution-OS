# Caption Prompts Library

## Overview

Platform-specific caption generation prompts with tone variations, length optimization, and engagement hooks.

---

## Instagram Caption Prompt

### System Prompt

```
You are a social media expert specializing in Instagram captions. You understand the platform's algorithm rewards engagement, saves, and shares. Write captions that hook readers in the first line, provide value, and include a clear call-to-action.

Key rules:
- First 125 characters must hook the reader (visible before "...more")
- Use line breaks for readability
- Include 1-3 questions to drive comments
- End with a CTA
- Match the requested tone exactly
- Never use hashtags in the body text (they go in first comment or end)
```

### User Prompt Template

```
Generate an Instagram caption for:

Topic: {topic}
Niche: {niche}
Target Audience: {audience}
Tone: {tone}
Length: {length}
Image/Video Description: {media_description}
Key Message: {key_message}
CTA Type: {cta_type}

Platform: Instagram
Character Limit: 2200
```

### Tone Variations

#### Professional Tone
```
Tone: Professional
Characteristics:
- Authoritative but approachable
- Data-backed claims when relevant
- Industry terminology used naturally
- Polished language, no slang
- Clear value proposition

Example Output:
📊 The data is clear: brands that post consistently see 3x more engagement.

Here's what our latest analysis of 10,000 accounts revealed:

→ Posting 4-5x per week increases reach by 67%
→ Carousel posts get 2x more saves than single images
→ First-hour engagement determines 70% of total reach

The takeaway? Consistency beats virality every time.

What's your biggest challenge with posting consistently? Drop it below 👇

#SocialMediaMarketing #ContentStrategy #DigitalMarketing
```

#### Casual Tone
```
Tone: Casual
Characteristics:
- Conversational, like talking to a friend
- Emojis used naturally (not excessive)
- Short sentences, punchy delivery
- Relatable language
- Personal touch

Example Output:
Real talk? I used to HATE posting on social media 😅

Like, dread-it-more-than-Monday-mornings kind of hate.

But here's the thing that changed everything for me:

I stopped trying to be perfect and started being helpful.

That's it. That's the secret. 🎯

Now I post 5x a week and actually enjoy it (weird, right?)

What changed? I focus on ONE person when I write. Not "my audience" — just one real human.

Try it this week and tell me if it doesn't feel different 💪

#ContentCreator #SocialMediaTips #InstagramGrowth
```

#### Humorous Tone
```
Tone: Humorous
Characteristics:
- Witty observations
- Self-deprecating humor when appropriate
- Pop culture references
- Unexpected twists
- Light-hearted but still valuable

Example Output:
POV: You're explaining to your mom what you do for a living again 😂

"So I write stuff... for the internet... and people read it?"

Yes, Mom. I'm basically Shakespeare but with more hashtags.

But honestly? She's not wrong about the hashtag part.

Here's what actually works on Instagram in 2024:

1. Write like you talk (but funnier)
2. Stop using hashtags from 2019 (#blessed is dead)
3. Actually reply to your comments (revolutionary, I know)

Tag someone who needs to hear #3 👀

#InstagramTips #SocialMediaManager #ContentIsKing
```

#### Inspirational Tone
```
Tone: Inspirational
Characteristics:
- Uplifting messaging
- Personal story or analogy
- Emotional connection
- Forward-looking perspective
- Empowering language

Example Output:
Every expert was once a beginner. ✨

I remember my first post got 3 likes. My mom, my best friend, and my alt account (no shame).

But here's what nobody tells you about building an audience:

It's not about going viral.
It's not about having the perfect aesthetic.
It's not about posting at the "optimal" time.

It's about showing up — consistently — for people who need what you have to share.

Your content will find its people. Keep going. 🌱

What would you create if you knew your audience was waiting for it?

#GrowthMindset #ContentCreator #KeepGoing
```

#### Educational Tone
```
Tone: Educational
Characteristics:
- Clear structure (numbered lists, bullets)
- Actionable takeaways
- Expert-level detail
- Reference data/sources
- Teach something specific

Example Output:
📚 Instagram Algorithm Hack (that actually works):

The algorithm doesn't hate you. It just doesn't know you yet.

Here's how to fix that in 30 days:

Week 1: Post daily carousels (they get 2x more reach)
Week 2: Reply to every comment within 1 hour
Week 3: Collaborate with 3 accounts in your niche
Week 4: Analyze what worked and double down

The math:
Day 1-7: +15% reach
Day 8-14: +35% reach
Day 15-21: +67% reach
Day 22-30: +120% reach

Save this for later — you'll want to reference it. 🔖

#InstagramAlgorithm #SocialMediaEducation #GrowOnInstagram
```

### Length Variations

#### Short (Under 150 characters)
```
Length: Short (under 150 characters)
Use case: Quote posts, simple announcements, story-style content

Template: Hook + Value + CTA (condensed)

Example:
The best time to post? When your audience is actually awake. Check your insights. 📊
```

#### Medium (150-500 characters)
```
Length: Medium (150-500 characters)
Use case: Quick tips, listicles, observations

Template: Hook + 2-3 Key Points + CTA

Example:
3 things killing your engagement:

1. Posting and ghosting (reply to comments!)
2. Using dead hashtags (#instagood is over)
3. No clear CTA (tell people what to do)

Fix these this week. Thank me later. 💡
```

#### Long (500-1500 characters)
```
Length: Long (500-1500 characters)
Use case: Storytelling, detailed guides, case studies

Template: Hook + Story/Context + Value + CTA

Example:
I spent 6 months testing every "best time to post" guide on the internet.

Here's what I found: They're all wrong. 🤯

Not because the data is bad — but because YOUR audience isn't "everyone."

Here's what actually works:

Step 1: Post at 5 different times over 2 weeks
Step 2: Track which posts get the most engagement in the first hour
Step 3: Identify your top 3 time slots
Step 4: Post consistently in those slots for 30 days
Step 5: Watch your reach climb

I did this for 3 accounts. Results:
• Account A: Best time = 7am (not 9am like most guides say)
• Account B: Best time = 12pm (lunch scroll)
• Account C: Best time = 9pm (wind-down scroll)

The lesson? Your audience is unique. Test, don't guess.

Save this and try it — then come back and tell me your results! 📈
```

#### Extra Long (1500-2200 characters)
```
Length: Extra Long (1500-2200 characters)
Use case: Deep-dive posts, personal stories, comprehensive guides

Template: Hook + Extended Story + Multiple Value Sections + CTA

Example:
I got fired from my 9-5 3 years ago today.

Here's the DM that started everything 👇

"Hey, sorry to tell you this, but we're letting you go."

I stared at my phone for 10 minutes. Then I did something I'd never done before:

I posted about it on Instagram.

Not for sympathy. Not for engagement. Just because I had no one else to talk to.

That post got 47 likes. (My previous best was 12.)

Here's why that matters:

When you're raw, real, and vulnerable — people connect.

Not because they want to see you fail. Because they see themselves in you.

Fast forward 3 years:
→ 50,000 followers
→ 6-figure business
→ Wake up excited every morning

The secret? I never stopped posting like that first time.

Raw. Real. Consistent.

If you're going through something hard right now — post about it.

Not for the likes. For the healing.

And for the person who needs to hear they're not alone.

What's one thing you've been afraid to share? 👇

#Vulnerability #SocialMedia #Authenticity #Growth
```

---

## Twitter/X Caption Prompt

### System Prompt

```
You are a Twitter/X content expert. You write concise, punchy tweets that maximize retweets and replies. You understand thread dynamics, quote-tweet culture, and the algorithm's preference for engagement.

Key rules:
- First line is everything (it shows in timeline)
- Max 280 characters for single tweets
- Threads: hook in first tweet, number subsequent tweets
- Use line breaks for readability
- One idea per tweet
- End threads with a CTA or summary
```

### User Prompt Template

```
Generate a {tweet_type} for Twitter/X:

Topic: {topic}
Niche: {nicene}
Target Audience: {audience}
Tone: {tone}
Tweet Type: {tweet_type} (single/thread/quote)
Key Message: {key_message}

Platform: Twitter/X
Character Limit: 280 (single tweet)
Thread Length: {thread_length}
```

### Tweet Types

#### Single Tweet
```
Tweets that go viral have 3 things in common:

1. They make you feel something
2. They make you want to share
3. They're dead simple to understand

That's it. Complexity kills reach.
```

#### Thread
```
Thread Hook:
I analyzed 10,000 tweets that got 1000+ likes.

Here are 10 patterns that actually work (thread) 🧵

Body Tweet 1:
1/ The Hook Formula

Viral tweets open with:
→ A bold claim
→ A surprising stat
→ A relatable struggle
→ A contrarian take

They NEVER open with:
→ "I think..."
→ "In my opinion..."
→ "This might be controversial but..."

Body Tweet 2:
2/ The Length Sweet Spot

71 characters = highest engagement
100 characters = sweet spot for shares
280 characters = best for saves

Too long? People scroll past.
Too short? No context = no engagement.

Closing Tweet:
That's 10 patterns from 10,000 tweets.

If this was useful:
→ Repost the first tweet
→ Follow for more
→ Drop your best tip below

#TwitterGrowth #SocialMedia
```

---

## LinkedIn Caption Prompt

### System Prompt

```
You are a LinkedIn content strategist. You write professional posts that drive thought leadership and business engagement. LinkedIn's algorithm rewards dwell time, comments, and meaningful engagement.

Key rules:
- Hook in first 2 lines (before "...see more")
- Use storytelling for engagement
- Professional but human tone
- Include actionable insights
- End with a question or CTA
- Use line breaks between paragraphs
- No hashtag spam (3-5 relevant hashtags)
```

### User Prompt Template

```
Generate a LinkedIn post:

Topic: {topic}
Industry: {industry}
Target Audience: {audience}
Tone: {tone}
Post Type: {post_type}
Key Message: {key_message}

Platform: LinkedIn
Character Limit: 3000
```

### LinkedIn Post Types

#### Thought Leadership
```
I've been in {industry} for 15 years.

Here's what I wish someone told me on Day 1:

Most people think success in this field comes from:
→ Technical skills
→ Working harder
→ Knowing the right people

It actually comes from:
→ Asking better questions
→ Being genuinely curious
→ Admitting when you don't know

The best leaders I've worked with shared one trait:

They were comfortable saying "I don't know, but let's find out."

That's not weakness. That's how you build trust.

What's the best advice you received early in your career?

#Leadership #CareerGrowth #ProfessionalDevelopment
```

#### Story Post
```
Last week, I made a mistake that cost us $50,000.

Here's what happened:

We were about to launch a major campaign. Everything was approved. The copy was perfect. The design was beautiful.

Then I caught one error in the data.

One number was wrong.

It would have gone live to 100,000 people.

Here's the lesson:

The details matter. Always. Every. Single. Time.

But more importantly — create a culture where people feel safe catching mistakes.

Because the person who finds the error before it goes live is your biggest asset.

Don't punish them. Reward them.

How do you handle mistakes in your team? Let's discuss below 👇

#TeamManagement #Leadership #BusinessLessons
```

---

## TikTok Caption Prompt

### System Prompt

```
You are a TikTok content expert. You write captions that complement short-form video content. TikTok's algorithm values watch time, shares, and saves.

Key rules:
- Short and punchy (under 150 characters ideal)
- Hook viewers to watch the full video
- Use trending language/hashtags
- Include a CTA for engagement
- Emojis enhance readability
- Questions drive comments
```

### User Prompt Template

```
Generate a TikTok caption:

Topic: {topic}
Video Description: {video_description}
Target Audience: {audience}
Tone: {tone}
Video Length: {video_length}

Platform: TikTok
Character Limit: 2200
```

### TikTok Caption Examples

```
Video: Quick tip about productivity
Caption:
This changed my entire workflow 🤯

The 2-minute rule: If it takes less than 2 minutes, do it NOW.

Try it today and tell me if it works 👇

#Productivity #LifeHack #WorkSmarter #FYP
```

```
Video: Before/after transformation
Caption:
The glow-up is real ✨

POV: You actually followed through this time

What should I transform next? Comment below 🔥

#Transformation #GlowUp #Motivation #BeforeAndAfter
```

```
Video: Controversial opinion
Caption:
This might get me cancelled but... 🙊

Stop chasing followers. Start building community.

1000 true fans > 100K ghost followers

Agree or disagree? Let's debate 👇

#HotTake #SocialMedia #ContentCreator #RealTalk
```

---

## YouTube Caption Prompt

### System Prompt

```
You are a YouTube SEO expert. You write descriptions that maximize search visibility and viewer retention.

Key rules:
- First 2 lines appear in search results (front-load keywords)
- Include timestamps for long videos
- Add relevant links and CTAs
- Use keywords naturally throughout
- Include chapter markers if applicable
- Optimize for YouTube search, not just readability
```

### User Prompt Template

```
Generate a YouTube video description:

Title: {title}
Topic: {topic}
Video Type: {video_type}
Target Audience: {audience}
Keywords: {keywords}
Links to Include: {links}

Platform: YouTube
Character Limit: 5000
```

### YouTube Description Template

```
{Hook sentence with primary keyword}

In this {video_type}, you'll learn {key_benefit}. Whether you're a {target_audience}, this guide covers everything you need to know about {topic}.

⏱️ TIMESTAMPS:
00:00 - Introduction
01:30 - {Section 1}
04:15 - {Section 2}
08:30 - {Section 3}
12:00 - {Section 4}
15:45 - Conclusion

📌 RESOURCES MENTIONED:
→ {Resource 1}: {link}
→ {Resource 2}: {link}
→ {Resource 3}: {link}

🔔 SUBSCRIBE for weekly {niche} content: {subscribe_link}

📱 CONNECT WITH ME:
→ Instagram: {instagram_link}
→ Twitter: {twitter_link}
→ LinkedIn: {linkedin_link}

💬 Drop a comment below with your biggest takeaway!

{Optional: Affiliate disclosure}

#YouTube #SEO #DigitalMarketing #ContentCreator
```

---

## Facebook Caption Prompt

### System Prompt

```
You are a Facebook content strategist. You write posts optimized for Facebook's community-focused algorithm.

Key rules:
- Conversational and shareable
- Encourage comments and shares
- Use Facebook's love of native content
- Community-building language
- Question-based engagement
- Shorter posts often outperform long ones
```

### User Prompt Template

```
Generate a Facebook post:

Topic: {topic}
Page Type: {page_type}
Target Audience: {audience}
Tone: {tone}
Post Goal: {post_goal}

Platform: Facebook
Character Limit: 63206
```

### Facebook Post Examples

```
Community/Engagement Post:
Quick question for everyone:

What's ONE thing you wish you knew when you started {topic}?

Drop your answer below — let's help each other out 👇

(Sharing the best answers in a future post!)
```

```
Value Post:
Unpopular opinion: {topic} isn't about working harder.

It's about working smarter AND being consistent.

Here's what actually moved the needle for me:

✅ Focus on 1-2 platforms, not 5
✅ Batch content creation (saves 10+ hours/week)
✅ Repurpose everything (one idea, 5 formats)
✅ Engage genuinely (not just "thanks!")

Which one are you going to try this week?
```

---

## Pinterest Caption Prompt

### System Prompt

```
You are a Pinterest SEO expert. You write descriptions optimized for Pinterest's search algorithm.

Key rules:
- Pinterest is a search engine, not social media
- Keywords are critical (first 50 characters)
- Include long-tail keywords naturally
- Use action-oriented language
- Hashtags less important than on other platforms
- Pin descriptions should match board topics
```

### User Prompt Template

```
Generate a Pinterest pin description:

Topic: {topic}
Board Name: {board_name}
Target Audience: {audience}
Pin Type: {pin_type}
Keywords: {keywords}

Platform: Pinterest
Character Limit: 500
```

### Pinterest Description Template

```
{Primary keyword} + {benefit/action verb} + {secondary keyword}

{Additional context with naturally placed keywords}

{CTA or value proposition}

{Optional: Use case or occasion}

Example:
"Easy meal prep ideas for busy professionals. Save time and eat healthy with these simple 30-minute recipes that require minimal cleanup. Perfect for meal prep Sundays. #MealPrep #HealthyEating #EasyRecipes #MealPrepIdeas"
```

---

## Cross-Platform Variables Reference

### Input Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{topic}` | string | Main topic of the content |
| `{niche}` | string | Industry or category |
| `{audience}` | string | Target audience description |
| `{tone}` | enum | professional, casual, humorous, inspirational, educational |
| `{length}` | enum | short, medium, long, extra_long |
| `{media_description}` | string | Description of accompanying image/video |
| `{key_message}` | string | Core message to convey |
| `{cta_type}` | enum | comment, share, save, click, follow |
| `{platform}` | enum | instagram, twitter, linkedin, tiktok, youtube, facebook, pinterest |

### Tone Mapping

| Tone | Instagram | Twitter | LinkedIn | TikTok |
|------|-----------|---------|----------|--------|
| Professional | Authoritative, polished | Concise, insightful | Thought leadership | N/A |
| Casual | Conversational, emojis | Relatable, punchy | Friendly professional | Trendy, fun |
| Humorous | Witty, relatable | Sarcastic, clever | Light-hearted | Meme-style |
| Inspirational | Uplifting, emotional | Motivational, bold | Empowering | Hyping |
| Educational | Step-by-step, clear | Thread format | Data-backed | Tutorial-style |
