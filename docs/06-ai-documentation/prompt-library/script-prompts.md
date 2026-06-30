# Script Prompts Library

## Overview

Video and audio script prompts for YouTube, Reels/TikTok, podcasts, and webinars.

---

## YouTube Video Script Prompt

### System Prompt

```
You are a YouTube scriptwriter specializing in engaging, retention-optimized video content. You understand watch time optimization, audience retention patterns, and storytelling for video.

Script Structure:
1. Hook (0-30 seconds)
2. Introduction (30-60 seconds)
3. Value Sections (Main content)
4. Engagement Points (Mid-roll)
5. Summary/CTA (Final 30-60 seconds)

Key Rules:
- Hook must grab attention in first 5 seconds
- Use pattern interrupts to maintain attention
- Include engagement prompts throughout
- End with clear CTA
- Keep sentences conversational
- Include visual/audio cues
```

### User Prompt Template

```
Write a YouTube video script for:

Title: {video_title}
Topic: {topic}
Niche: {niche}
Target Audience: {audience}
Video Length: {length}
Style: {style}
Key Points: {key_points}

Provide:
- Full script with timestamps
- Visual/audio cues
- B-roll suggestions
- Engagement points
- CTA placement
```

### YouTube Script Template

```yaml
youtube_script:
  title: "10 Email Marketing Tips That Actually Work"
  duration: "12 minutes"
  style: "educational"
  
  sections:
    hook:
      time: "0:00-0:30"
      content: |
        "I analyzed over 1,000 email campaigns,
        and these 10 tips appeared in every single
        high-performing one.
        
        And number 7? Most marketers get it completely wrong."
      visual: "Fast-paced text overlays, data graphics"
      audio: "Upbeat background music"
    
    intro:
      time: "0:30-1:30"
      content: |
        "If you're tired of sending emails that nobody opens,
        you're in the right place.
        
        I'm [Name], and for the past 5 years, I've helped
        businesses increase their email open rates by an
        average of 41%.
        
        Today, I'm sharing the exact strategies that made
        that possible.
        
        Before we start, make sure to subscribe and hit
        the bell so you don't miss future tips."
      visual: "Talking head, subscribe animation"
      audio: "Music fades down"
    
    section_1:
      time: "1:30-2:30"
      title: "Tip 1: Write Like You Talk"
      content: |
        "The first tip is simple but powerful:
        write your subject lines like you'd write a text message.
        
        Here's why this works:
        
        Most email subject lines sound like they were written
        by robots. 'Monthly Newsletter - January Edition.'
        
        Nobody wants to open that.
        
        Instead, try something like: 'Quick question about
        your marketing strategy.'
        
        See the difference? One sounds like spam, the other
        sounds like a friend."
      visual: "Split screen comparison, before/after"
      audio: "Sound effect for comparison"
      engagement_point: "Pause and ask: 'Raise your hand if
        you've been guilty of robot subject lines.'"
    
    section_2:
      time: "2:30-3:45"
      title: "Tip 2: Front-Load the Value"
      content: |
        "Your subject line has one job: get the open.
        
        And the way to do that is to front-load the value.
        
        Instead of: 'Our latest blog post about email marketing'
        
        Try: 'Double your open rates with this one change'
        
        The first tells them what it is. The second tells
        them what they'll get."
      visual: "Email examples on screen"
    
    mid_roll_engagement:
      time: "4:00"
      content: |
        "Quick question: What's your current email open rate?
        Drop it in the comments below. I'll personally review
        the first 50 and give feedback."
      visual: "Comment animation, pointing down"
    
    [Continue for all 10 tips]
    
    outro:
      time: "11:00-12:00"
      content: |
        "And those are the 10 email marketing tips that
        actually work.
        
        If you found this helpful, hit that like button.
        It really helps the channel.
        
        And make sure to subscribe for more marketing
        tips every week.
        
        I'll see you in the next one."
      visual: "End screen with subscribe button"
      audio: "Outro music"
```

---

## Reel/TikTok Script Prompt

### System Prompt

```
You are a short-form video scriptwriter. You create scripts optimized for 15-60 second videos on Instagram Reels and TikTok.

Key Rules:
- Hook in first 1-3 seconds
- One clear message per video
- Fast-paced delivery
- Visual-friendly scripts
- Trend-aware
- Strong CTA
```

### User Prompt Template

```
Write a Reel/TikTok script for:

Topic: {topic}
Duration: {duration} (15s/30s/60s)
Platform: {platform}
Style: {style}
Tone: {tone}
Trending Audio: {audio_if_any}

Provide:
- Script with timestamps
- Visual directions
- Text overlay suggestions
- Music/sound cues
- CTA
```

### Reel/TikTok Script Templates

#### 15-Second Script
```yaml
script_15s:
  topic: "Email subject line tip"
  duration: "15 seconds"
  
  script:
    - time: "0:00-0:03"
      visual: "Close up face, shocked expression"
      text_overlay: "STOP writing boring subject lines"
      audio: "Trending sound - dramatic"
    
    - time: "0:03-0:08"
      visual: "Show phone with bad subject line"
      text_overlay: "This gets 2% open rate"
      audio: "Sound continues"
    
    - time: "0:08-0:12"
      visual: "Show phone with good subject line"
      text_overlay: "This gets 41% open rate"
      audio: "Sound climax"
    
    - time: "0:12-0:15"
      visual: "Point to camera"
      text_overlay: "Comment 'SUBJECT' for the formula"
      audio: "Sound ends"
```

#### 30-Second Script
```yaml
script_30s:
  topic: "Marketing tip"
  duration: "30 seconds"
  
  script:
    - time: "0:00-0:03"
      visual: "Walking toward camera"
      text_overlay: "The marketing tip nobody talks about"
      audio: "Trending sound"
    
    - time: "0:03-0:10"
      visual: "Talking to camera"
      content: "Most marketers focus on getting more followers. But the real money is in your email list."
      audio: "Music continues low"
    
    - time: "0:10-0:20"
      visual: "Show data/results"
      content: "I grew my email list from 0 to 10,000 in 6 months. Here's the one thing that worked."
      audio: "Music builds"
    
    - time: "0:20-0:27"
      visual: "Talking to camera"
      content: "I created a free lead magnet that solves one specific problem. That's it."
      audio: "Music peak"
    
    - time: "0:27-0:30"
      visual: "Point to camera/bio"
      text_overlay: "Free template in bio"
      audio: "Music ends"
```

#### 60-Second Script
```yaml
script_60s:
  topic: "Email marketing strategy"
  duration: "60 seconds"
  
  script:
    - time: "0:00-0:05"
      visual: "Hook moment, dramatic"
      text_overlay: "How I got 41% email open rates"
      audio: "Trending sound"
    
    - time: "0:05-0:15"
      visual: "Talking to camera"
      content: "After analyzing 1,000 email campaigns, I found the one pattern every high-performing email shared."
      audio: "Music continues"
    
    - time: "0:15-0:30"
      visual: "Show examples on screen"
      content: "It's not about what you say. It's about how you say it. The best subject lines sound like texts from friends, not marketing emails."
      audio: "Music builds"
    
    - time: "0:30-0:45"
      visual: "Show results"
      content: "I changed my subject line strategy and my open rates jumped from 18% to 41% in 30 days."
      audio: "Music peak"
    
    - time: "0:45-0:55"
      visual: "Talking to camera"
      content: "Want the exact formula? I made a free guide with 50 subject line templates."
      audio: "Music fades"
    
    - time: "0:55-0:60"
      visual: "Point to bio"
      text_overlay: "Free guide in bio"
      audio: "Music ends"
```

---

## Podcast Script Prompt

### System Prompt

```
You are a podcast scriptwriter. You create engaging audio content with natural conversation flow, clear segments, and listener engagement.

Script Structure:
1. Cold Open (15-30 seconds)
2. Intro Music (10-15 seconds)
3. Welcome & Context (1-2 minutes)
4. Main Content (divided into segments)
5. Key Takeaways (2-3 minutes)
6. CTA & Outro (1-2 minutes)
```

### User Prompt Template

```
Write a podcast episode script for:

Episode Title: {title}
Topic: {topic}
Niche: {niche}
Format: {format} (solo/interview/co-host)
Duration: {duration}
Target Audience: {audience}
Key Points: {key_points}

Provide:
- Full script with timestamps
- Segment breakdowns
- Engagement prompts
- Show notes outline
```

### Podcast Script Template

```yaml
podcast_script:
  title: "The Truth About Email Marketing Nobody Tells You"
  format: "solo"
  duration: "30 minutes"
  
  segments:
    cold_open:
      time: "0:00-0:20"
      content: |
        "What if I told you that the email marketing advice
        you've been following is actually hurting your business?
        
        Today, I'm breaking down the myths, revealing the data,
        and giving you the exact strategy that doubled my
        open rates in 30 days."
      audio: "Dramatic pause, music sting"
    
    intro:
      time: "0:20-1:30"
      music: "Theme music fades in"
      content: |
        "Welcome to [Podcast Name], the show where we cut
        through the marketing noise and focus on what actually
        works.
        
        I'm your host, [Name], and today we're diving deep
        into email marketing.
        
        Before we start, if you're new here, make sure to
        subscribe so you don't miss our weekly episodes.
        
        And if you've been listening for a while, I'd love
        to hear from you. Leave a review on Apple Podcasts
        and let me know what topics you want covered."
    
    segment_1:
      title: "The Email Marketing Lie"
      time: "1:30-10:00"
      content: |
        "Let me start with a controversial statement:
        Most email marketing advice is outdated.
        
        Here's why I say that:
        
        The strategies that worked 5 years ago don't work
        today. Inbox algorithms have changed. User behavior
        has changed. But most marketers are still following
        playbooks from 2019.
        
        Let me give you an example...
        
        [Continue with detailed content]
        
        And here's the data that proves it..."
      audio: "Subtle background music"
      transitions: ["Now, let's talk about...", "Here's where it gets interesting...", "But wait, there's more..."]
    
    mid_episode_engagement:
      time: "15:00"
      content: |
        "Quick break to ask you something:
        What's your biggest email marketing challenge?
        
        Send me a DM on Instagram @[handle] or email
        me at [email]. I read every single message, and
        I might feature your question in a future episode."
    
    takeaways:
      time: "25:00-28:00"
      content: |
        "Alright, let's recap the key takeaways from today:
        
        Number 1: Write subject lines like you'd write a text.
        
        Number 2: Front-load the value in every email.
        
        Number 3: Segment your list or accept low engagement.
        
        Number 4: Test one variable at a time.
        
        Number 5: Clean your list regularly."
    
    outro:
      time: "28:00-30:00"
      content: |
        "That's it for today's episode. If you found this
        valuable, here's how you can support the show:
        
        1. Leave a review on Apple Podcasts
        2. Share this episode with one friend who needs it
        3. Subscribe so you don't miss next week's episode
        
        Speaking of next week, we're talking about social
        media algorithms and how to actually beat them.
        
        You won't want to miss it.
        
        Until then, keep testing, keep learning, and keep
        growing."
      audio: "Outro music fades in"
```

---

## Webinar Script Prompt

### System Prompt

```
You are a webinar scriptwriter. You create engaging presentation scripts that educate, build trust, and convert attendees.

Webinar Structure:
1. Pre-show (5 minutes before)
2. Opening (5 minutes)
3. Introduction & Credibility (5 minutes)
4. Problem/Pain Points (10 minutes)
5. Solution/Framework (15 minutes)
6. Case Studies/Proof (10 minutes)
7. Q&A (10-15 minutes)
8. Offer/CTA (5 minutes)
9. Closing (5 minutes)
```

### User Prompt Template

```
Write a webinar script for:

Title: {webinar_title}
Topic: {topic}
Niche: {niche}
Duration: {duration}
Audience: {audience}
Goal: {goal}
Offer: {offer_if_any}

Provide:
- Full script with timestamps
- Slide suggestions
- Engagement prompts
- Q&A preparation
- CTA structure
```

### Webinar Script Template

```yaml
webinar_script:
  title: "How to Double Your Email Open Rates in 30 Days"
  duration: "60 minutes"
  goal: "Educate and convert to paid course"
  
  sections:
    pre_show:
      time: "-5:00 to 0:00"
      content: |
        "Welcome! We'll get started in just a few minutes.
        While you wait, drop your name and where you're
        from in the chat. I love seeing where everyone
        is tuning in from."
      slides: "Welcome slide with countdown"
    
    opening:
      time: "0:00-5:00"
      content: |
        "Welcome everyone! Thank you so much for being here.
        
        Today, I'm going to share the exact email marketing
        strategy that increased our open rates from 18% to
        41% in just 30 days.
        
        But first, a quick question: How many of you have
        tried multiple email marketing strategies with
        little to no results?
        
        [Pause for responses]
        
        You're not alone. And by the end of this webinar,
        you'll know exactly why those strategies failed
        and what actually works."
      slides: "Title slide, agenda overview"
      engagement: "Poll: What's your current open rate?"
    
    credibility:
      time: "5:00-10:00"
      content: |
        "Before we dive in, let me quickly share why you
        should listen to me.
        
        I've been in email marketing for 7 years. I've
        managed over 500 email campaigns. I've sent over
        10 million emails.
        
        But more importantly, I've tested everything.
        And I'm going to share only what the data shows
        actually works."
      slides: "Bio, credentials, results"
    
    problem:
      time: "10:00-20:00"
      content: |
        "Let's talk about why your emails aren't getting
        opened.
        
        Problem #1: You're writing for robots, not humans.
        
        Most email subject lines sound like they were
        written by marketing departments. 'Monthly Newsletter
        - January Edition.' Nobody wants to open that.
        
        Problem #2: You're sending at the wrong time.
        
        I bet you've read that the best time to send is
        Tuesday at 10 AM. But that's for 'average' audiences.
        Your audience isn't average.
        
        Problem #3: You're treating everyone the same.
        
        Sending the same email to everyone on your list
        is like sending the same birthday gift to every
        person you know. It doesn't work."
      slides: "Problem slides with data"
      engagement: "Chat: Which problem resonates most?"
    
    solution:
      time: "20:00-35:00"
      content: |
        "Now let's fix these problems.
        
        Solution #1: The Human Subject Line Formula
        
        Here's how it works:
        Step 1: Write your subject line
        Step 2: Read it out loud
        Step 3: Ask: 'Would I open this if a friend sent it?'
        Step 4: If no, rewrite until yes
        
        Solution #2: The Personal Send Time Strategy
        
        Instead of guessing, let your data tell you:
        [Explain method]
        
        Solution #3: The 3-Segment Minimum
        
        At minimum, segment your list into:
        [Explain segmentation]"
      slides: "Solution slides with steps"
      engagement: "Poll: Which solution will you try first?"
    
    case_study:
      time: "35:00-45:00"
      content: |
        "Let me show you this in action.
        
        Case Study: [Client Name]
        
        Before: 12% open rate, 200 subscribers
        After: 38% open rate, 2,500 subscribers
        
        Here's exactly what we did:
        [Detailed breakdown]
        
        And the best part? This took less than 2 hours
        to implement."
      slides: "Before/after results, implementation steps"
    
    q_and_a:
      time: "45:00-55:00"
      content: |
        "Alright, let's take some questions.
        
        I see we have some great questions in the chat.
        
        [Address questions]"
      engagement: "Live Q&A"
    
    offer:
      time: "55:00-60:00"
      content: |
        "If you want to implement this faster, I have
        something for you.
        
        I've created a complete email marketing course
        that walks you through every step.
        
        It includes:
        - 50 subject line templates
        - Segmentation guide
        - Automation workflows
        - A/B testing framework
        
        And for everyone on this webinar, I'm offering
        30% off with code WEBINAR30.
        
        The link is in the chat. This offer expires
        in 24 hours."
      slides: "Course overview, pricing, CTA"
    
    closing:
      time: "60:00"
      content: |
        "Thank you so much for being here today.
        
        Remember: Write like a human, send at the right
        time, and segment your list.
        
        If you implement just these three things, you'll
        see results.
        
        See you in the next webinar!"
      slides: "Thank you, contact info"
```

---

## Content Format Specifications

### YouTube Specifications

| Element | Specification |
|---------|---------------|
| Title | 60-70 characters |
| Description | First 2 lines crucial, 5000 char max |
| Tags | 10-15 relevant tags |
| Thumbnail | 1280x720, under 2MB |
| Captions | Always include (accessibility + SEO) |
| End Screen | Last 20 seconds |
| Cards | 3-5 per video |

### Reel/TikTok Specifications

| Element | Specification |
|---------|---------------|
| Length | 15-60 seconds (optimal: 30s) |
| Hook | First 1-3 seconds |
| Text | Large, readable, centered |
| Music | Trending audio when possible |
| CTA | Clear, simple action |
| Hashtags | 3-5 relevant |

### Podcast Specifications

| Element | Specification |
|---------|---------------|
| Episode Length | 20-45 minutes |
| Intro | Under 2 minutes |
| Segments | Clear transitions |
| Show Notes | Timestamps, links, summary |
| Artwork | 3000x3000, high quality |
| RSS Feed | Optimized for all platforms |

### Webinar Specifications

| Element | Specification |
|---------|---------------|
| Duration | 45-60 minutes |
| Slides | Clean, minimal text |
| Engagement | Polls every 10-15 minutes |
| Q&A | Dedicated segment |
| Recording | Always record for replay |
| Follow-up | Email sequence within 24 hours |
