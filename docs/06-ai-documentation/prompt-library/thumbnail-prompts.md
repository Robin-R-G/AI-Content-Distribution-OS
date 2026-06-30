# Thumbnail Prompts Library

## Overview

AI image generation prompts for YouTube thumbnails, Instagram graphics, and social media visuals using DALL-E, Midjourney, and other AI image generators.

---

## YouTube Thumbnail Prompt

### System Prompt

```
You are a YouTube thumbnail design expert. You create prompts for AI image generators that produce eye-catching, click-worthy thumbnails.

Key rules:
- Bold, simple composition
- High contrast colors
- Emotional facial expressions (if including people)
- Text-friendly negative space
- Brand consistency
- Mobile-first (readable at small sizes)
```

### User Prompt Template

```
Generate a YouTube thumbnail prompt for:

Video Title: {video_title}
Topic: {topic}
Niche: {niche}
Style: {style}
Mood: {mood}
Elements: {elements_to_include}

Platform: YouTube
Dimensions: 1280x720 (16:9)
Aspect Ratio: 16:9
```

### Thumbnail Styles

#### Minimalist
```
Style: Minimalist
Description: Clean, white/light background, single focal point, bold text

Prompt: "Minimalist YouTube thumbnail, clean white background, {subject}, bold red accent element, professional photography, high contrast, studio lighting, 4K quality, 16:9 aspect ratio"

Example Elements:
- Single product on white background
- Person with clean background
- Simple icon with text space
```

#### Bold & Vibrant
```
Style: Bold and Vibrant
Description: Saturated colors, high energy, attention-grabbing

Prompt: "Bold vibrant YouTube thumbnail, {subject}, saturated colors, neon accents, dynamic composition, high energy, dramatic lighting, pop art influence, 16:9 aspect ratio, 4K"

Example Elements:
- Bright gradients
- Neon text effects
- High saturation photography
```

#### Professional/Business
```
Style: Professional
Description: Clean, corporate, trustworthy

Prompt: "Professional business YouTube thumbnail, {subject}, clean corporate design, blue and white color scheme, modern typography, professional photography, 16:9 aspect ratio, 4K"

Example Elements:
- Professional headshot
- Office/business setting
- Clean data visualization
```

#### Dramatic/Cinematic
```
Style: Dramatic
Description: Movie-poster style, dramatic lighting, cinematic

Prompt: "Cinematic YouTube thumbnail, {subject}, dramatic lighting, movie poster style, dark background with rim lighting, moody atmosphere, film grain, 16:9 aspect ratio, 4K"

Example Elements:
- Dramatic portrait
- Stormy/dramatic sky
- High-contrast lighting
```

#### Fun/Playful
```
Style: Fun and Playful
Description: Cartoon elements, bright colors, approachable

Prompt: "Fun playful YouTube thumbnail, {subject}, cartoon elements, bright pastel colors, rounded shapes, friendly atmosphere, illustrated accents, 16:9 aspect ratio, 4K"

Example Elements:
- Emoji-style graphics
- Hand-drawn elements
- Confetti/party elements
```

### YouTube Thumbnail Dimensions

| Element | Specification |
|---------|---------------|
| Resolution | 1280 x 720 pixels |
| Aspect Ratio | 16:9 |
| File Size | Under 2MB |
| Format | JPG, PNG, GIF |
| Safe Zone | Keep text within center 80% |
| Mobile | Must be readable at 168x94px |

### YouTube Thumbnail Text Rules

```
Maximum Characters: 4-5 words
Font Style: Bold, sans-serif
Font Size: Large enough to read at small size
Color: High contrast with background
Shadow/Outline: Add for readability
Placement: Avoid bottom-right (timestamp covers)
```

---

## Instagram Post Graphic Prompt

### System Prompt

```
You are an Instagram graphic designer. You create prompts for AI image generators that produce on-brand, engaging visuals for Instagram feed and stories.

Key rules:
- Match brand aesthetic
- Optimized for mobile viewing
- Text overlays must be readable
- Consider grid layout when designing
- Use brand colors consistently
```

### User Prompt Template

```
Generate an Instagram graphic prompt for:

Post Type: {post_type} (feed, story, reel_cover)
Topic: {topic}
Brand Colors: {brand_colors}
Style: {style}
Text Overlay: {text_content}

Platform: Instagram
Dimensions: {dimensions}
```

### Instagram Dimensions

| Type | Dimensions | Aspect Ratio |
|------|------------|--------------|
| Feed Post | 1080x1080 | 1:1 |
| Feed Post (Portrait) | 1080x1350 | 4:5 |
| Feed Post (Landscape) | 1080x566 | 1.91:1 |
| Story | 1080x1920 | 9:16 |
| Reel Cover | 1080x1920 | 9:16 |
| Carousel | 1080x1080 | 1:1 |
| Profile Picture | 320x320 | 1:1 |

### Instagram Graphic Styles

#### Quote Post
```
Prompt: "Elegant Instagram quote graphic, {quote_text}, minimalist design, {brand_color} accent, clean typography, serif font for quote, sans-serif for attribution, subtle texture background, 1080x1080, 4K"

Variations:
- Dark mode: Black background, white text
- Light mode: White background, black text
- Branded: Brand color background, white text
- Gradient: Color gradient background
```

#### Tip/Educational
```
Prompt: "Instagram educational carousel cover, {topic}, modern flat design, {brand_colors}, icon-based illustration, clean layout, numbered list design, 1080x1080, 4K"

Layout Elements:
- Number/icon in circle
- Bold headline
- Supporting icon
- Clean background
```

#### Announcement
```
Prompt: "Instagram announcement graphic, {announcement_text}, bold typography, {brand_colors}, celebration elements, confetti/ribbons, professional design, 1080x1080, 4K"

Elements:
- Bold headline
- Supporting details
- CTA button design
- Brand logo placement
```

---

## Instagram Story Prompt

### Story Frame Types

#### Poll/Question
```
Prompt: "Instagram story poll template, {question}, interactive design, {brand_colors}, two-option layout, engaging graphics, thumb-stopping design, 1080x1920, 9:16"

Design Elements:
- Centered question
- Two clear options
- Brand-consistent colors
- Swipe-up area clear
```

#### Behind-the-Scenes
```
Prompt: "Instagram story behind-the-scenes, candid moment, natural lighting, {brand_colors} overlay, casual aesthetic, authentic feel, 1080x1920, 9:16"

Design Elements:
- Authentic photo
- Text overlay space
- Brand color accents
- Reply button area clear
```

#### Countdown/Event
```
Prompt: "Instagram story countdown, {event_name}, {date}, urgent design, {brand_colors}, countdown timer graphic, eye-catching, 1080x1920, 9:16"

Design Elements:
- Large date/number
- Event name
- Brand elements
- Reminder sticker area
```

---

## LinkedIn Banner Prompt

### User Prompt Template

```
Generate a LinkedIn banner prompt for:

Profile Type: {profile_type} (personal, company)
Industry: {industry}
Brand Colors: {brand_colors}
Message: {message}

Platform: LinkedIn
Dimensions: 1584x396 (4:1)
```

### LinkedIn Banner Styles

#### Professional Headshot Background
```
Prompt: "Professional LinkedIn banner, subtle gradient background in {brand_colors}, minimalist geometric shapes, professional atmosphere, corporate design, 1584x396, 4:1 ratio"

Elements:
- Subtle gradient
- Geometric accents
- Space for headshot overlay
- Professional typography
```

#### Company Branding
```
Prompt: "Corporate LinkedIn banner, {company_name} branding, {brand_colors}, industry-related imagery, professional design, modern aesthetic, 1584x396, 4:1 ratio"

Elements:
- Company logo area
- Brand colors prominent
- Industry imagery
- Value proposition text
```

---

## Twitter/X Header Prompt

### User Prompt Template

```
Generate a Twitter/X header prompt for:

Profile Type: {profile_type}
Niche: {niche}
Brand Colors: {brand_colors}

Platform: Twitter/X
Dimensions: 1500x500 (3:1)
```

### Twitter Header Styles
```
Prompt: "Twitter profile header, {theme}, {brand_colors}, clean modern design, professional, 1500x500, 3:1 ratio"

Variations:
- Minimalist gradient
- Industry-themed imagery
- Personal branding with headshot space
- Company branding
```

---

## Podcast Cover Art Prompt

### User Prompt Template

```
Generate podcast cover art prompt for:

Podcast Name: {podcast_name}
Niche: {niche}
Style: {style}
Brand Colors: {brand_colors}

Platform: All podcast platforms
Dimensions: 3000x3000 (1:1)
Minimum: 1400x1400
```

### Podcast Cover Styles

#### Bold & Modern
```
Prompt: "Podcast cover art, {podcast_name}, bold typography, {brand_colors}, modern design, high contrast, professional, 3000x3000, 1:1 ratio"

Design Rules:
- Title readable at small size
- High contrast colors
- Minimal text (name only)
- Recognizable at 55x55px
```

#### Illustrative
```
Prompt: "Podcast cover art illustration, {podcast_name}, custom illustration, {brand_colors}, unique style, memorable design, 3000x3000, 1:1 ratio"

Elements:
- Custom illustration
- Bold title
- Distinctive style
- Brand colors
```

---

## Brand Consistency System

### Brand Kit Variables

```yaml
brand_kit:
  colors:
    primary: "#FF6B35"
    secondary: "#004E89"
    accent: "#1A936F"
    background: "#FFFFFF"
    text: "#1A1A1A"
  
  fonts:
    heading: "Montserrat Bold"
    body: "Open Sans"
    accent: "Playfair Display"
  
  style:
    tone: "professional yet approachable"
    imagery: "clean, modern, minimal"
    textures: "subtle gradients, soft shadows"
  
  logo:
    primary: "logo-primary.svg"
    icon: "logo-icon.svg"
    watermark: "logo-watermark.png"
```

### Prompt Template with Branding

```
Create a {content_type} for {platform}:

Brand Guidelines:
- Colors: {primary_color}, {secondary_color}, {accent_color}
- Style: {brand_style}
- Typography: {font_style}
- Mood: {brand_mood}

Content Requirements:
- Topic: {topic}
- Message: {key_message}
- Text Overlay: {text_content}
- Dimensions: {platform_dimensions}

Output: AI image generation prompt optimized for {tool}
```

---

## AI Image Generator Specific Prompts

### DALL-E 3 Prompt Structure

```
"A {style} {content_type} for {platform}, featuring {subject}, {composition}, {color_scheme}, {lighting}, {background}, {quality_modifiers}, {aspect_ratio}"

Quality Modifiers:
- "high quality"
- "professional"
- "4K"
- "detailed"
- "sharp focus"
- "studio lighting"

Negative Prompts (what to avoid):
- "blurry"
- "low quality"
- "distorted"
- "text errors"
- "watermark"
```

### Midjourney Prompt Structure

```
{content_type} for {platform}, {subject}, {style} style, {color_scheme}, {composition}, {lighting} --ar {ratio} --v 6 --q 2 --s 750

Parameters:
--ar: Aspect ratio (16:9, 1:1, 9:16)
--v: Version (6 is latest)
--q: Quality (1-2)
--s: Stylize (0-1000)
--no: Negative prompt
```

### Stable Diffusion Prompt Structure

```
Positive Prompt:
{content_type}, {subject}, {style}, {details}, {quality}

Negative Prompt:
blurry, low quality, distorted, text, watermark, deformed, ugly

Parameters:
Steps: 30-50
CFG Scale: 7-12
Sampler: DPM++ 2M Karras
Size: {width}x{height}
```

---

## Thumbnail A/B Testing

### Testing Framework

```typescript
interface ThumbnailTest {
  id: string;
  videoId: string;
  variants: ThumbnailVariant[];
  metrics: {
    impressions: number;
    clicks: number;
    ctr: number;
  };
  winner: string | null;
}

interface ThumbnailVariant {
  id: string;
  prompt: string;
  imageUrl: string;
  changes: string[];
}
```

### A/B Test Variables

| Variable | Test Options |
|----------|--------------|
| Color | Warm vs Cool vs Neutral |
| Text | With text vs Without text |
| Face | With face vs Without face |
| Expression | Excited vs Curious vs Surprised |
| Composition | Left-aligned vs Centered vs Right |
| Background | Simple vs Detailed vs Gradient |
| Font | Bold vs Rounded vs Serif |

### Testing Process

1. Generate 2-4 variants using different prompts
2. Upload to YouTube Studio as experiment
3. Run for 48-72 hours minimum
4. Measure CTR difference
5. Implement winner
6. Document learnings for future prompts
