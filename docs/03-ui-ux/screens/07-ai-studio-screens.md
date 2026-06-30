# 07 - AI Studio Screens

## 1. AI Studio Dashboard

**Purpose:** Central hub for all AI-powered tools and features.

**Layout:** Grid of AI tool cards with usage stats and quick access. Top bar with credits display.

**Key Components:**
- AI tool cards (icons, titles, descriptions, usage counts)
- Credits remaining display
- Recent AI generations list
- Favorite tools section
- Tool categories (Content, Analysis, Automation)
- "What's New" announcements
- Quick start templates
- Usage trends chart

**Navigation:** Main AI Studio entry from sidebar.

**States:**
- Loading: Skeleton grid
- Error: "AI Studio unavailable" with retry
- Empty: Onboarding tour prompt

**Responsive:** 2 columns on mobile, 3-4 on desktop.

---

## 2. Caption Generator

**Purpose:** Generate platform-optimized captions from topics, images, or keywords.

**Layout:** Input panel on left, generated results on right, preview at bottom.

**Key Components:**
- Input area (topic, keywords, or image upload)
- Platform selector
- Tone dropdown (professional, casual, humorous, etc.)
- Length slider (short, medium, long)
- "Generate" button
- Results list (3-5 variations)
- Character count per result
- Copy/Use buttons per result
- "Regenerate" button
- History of generations
- Save to favorites

**Navigation:** From AI Studio dashboard or post composer AI button.

**States:**
- Loading: Generation spinner
- Error: "Generation failed" with retry
- Empty: Input prompt with examples

**Responsive:** Stacked panels on mobile, side-by-side on desktop.

---

## 3. Title Generator

**Purpose:** Create compelling headlines for posts, articles, and threads.

**Layout:** Similar to caption generator with title-specific options.

**Key Components:**
- Content description input
- Title type selector (question, list, how-to, statement, curiosity)
- Character limit input
- SEO score indicator
- Readability score
- "Generate" button
- Results list with copy/use buttons
- A/B test variant generation

**Navigation:** From AI Studio or content planning tools.

**States:**
- Loading: Generation spinner
- Error: "Could not generate titles"
- Empty: Input with title examples

**Responsive:** Same as caption generator.

---

## 4. Content Ideas

**Purpose:** Generate content ideas based on niche, trends, and audience interests.

**Layout:** Idea cards with categories, save, and "Create Post" actions.

**Key Components:**
- Niche/topic input
- Idea type selector (educational, entertaining, promotional, trending)
- Generated idea cards (title, description, rationale)
- Save to idea bank button
- "Create Post" button per idea
- Refresh/regenerate button
- Idea bank (saved ideas)
- Trending topics integration
- Content calendar suggestions

**Navigation:** From AI Studio dashboard or content planning.

**States:**
- Loading: Idea generation spinner
- Error: "Could not generate ideas"
- Empty: Topic input prompt

**Responsive:** Single column on mobile, grid on desktop.

---

## 5. Trend Prediction

**Purpose:** Predict upcoming trends and viral content opportunities.

**Layout:** Trend timeline with prediction confidence and opportunity scores.

**Key Components:**
- Trend timeline (past, present, predicted)
- Prediction confidence percentage
- Opportunity score (1-10)
- Related hashtags and topics
- Platform-specific predictions
- "Create Post" button for trending topics
- Historical accuracy display
- Set alert for trend threshold
- Export trend report

**Navigation:** From AI Studio > Trends or Analytics > Trends.

**States:**
- Loading: Prediction analysis
- Error: "Prediction unavailable"
- Empty: "Analyzing trend data..."

**Responsive:** Timeline scrolls horizontally on mobile.

---

## 6. Viral Analyzer

**Purpose:** Analyze why content goes viral and suggest viral elements for new content.

**Layout:** Input for viral content analysis, output with insights and recommendations.

**Key Components:**
- URL/post upload for analysis
- Viral elements breakdown (emotion, timing, format, hooks)
- Score per element
- Comparison to similar viral content
- "Apply to New Post" button
- Historical viral posts library
- Viral formula templates
- A/B test suggestions

**Navigation:** From AI Studio > Viral Tools.

**States:**
- Loading: Analysis spinner
- Error: "Analysis failed"
- Empty: URL/input prompt

**Responsive:** Stacked analysis panels on mobile.

---

## 7. Content Repurposer

**Purpose:** Transform content across formats (blog → tweets, video → clips, long → short).

**Layout:** Source panel, transformation options, output preview.

**Key Components:**
- Source input (URL, text, file upload)
- Transformation type selector
- Platform presets (Twitter thread, Instagram carousel, LinkedIn post)
- AI analysis of source content
- Generated outputs list
- Edit per output
- "Use All" or "Use Selected" buttons
- Quality score per output
- Batch repurpose option

**Navigation:** From AI Studio or post composer.

**States:**
- Loading: Analysis spinner
- Error: "Could not analyze content"
- Empty: Source selection prompt

**Responsive:** Stacked panels on mobile, side-by-side on desktop.

---

## 8. Translation

**Purpose:** Translate content to multiple languages with cultural context.

**Layout:** Source text panel, language selector, translation output.

**Key Components:**
- Source text input
- Source language auto-detect or manual
- Target language multi-select
- Translation output per language
- Cultural context notes
- Localized hashtag suggestions
- "Use Translation" button per language
- Batch translation option
- Translation memory (saved translations)

**Navigation:** From AI Studio or post composer translation option.

**States:**
- Loading: Translation spinner
- Error: "Translation failed"
- Empty: Text input prompt

**Responsive:** Stacked panels on mobile, side-by-side on desktop.

---

## 9. Rewriter

**Purpose:** Rewrite content for different tones, styles, or platforms.

**Layout:** Original text input, tone/style selector, rewritten outputs.

**Key Components:**
- Original text input
- Rewrite goal (simplify, formalize, make witty, shorten, expand)
- Tone slider
- Platform-specific rewrites
- Generated variations (3-5)
- Diff view (changes highlighted)
- "Use This" button per variation
- Readability score comparison
- Plagiarism check indicator

**Navigation:** From AI Studio or post composer edit tools.

**States:**
- Loading: Rewriting spinner
- Error: "Rewrite failed"
- Empty: Text input prompt

**Responsive:** Stacked panels on mobile.

---

## 10. Script Writer

**Purpose:** Generate scripts for videos, podcasts, and presentations.

**Layout:** Script type selector, input parameters, generated script with sections.

**Key Components:**
- Script type (video, podcast, presentation, ad)
- Topic/input
- Duration/length target
- Tone and style
- Generated script with sections
- Edit per section
- Export options (PDF, text, subtitle file)
- Voiceover timing marks
- CTA suggestions
- "Record" or "Generate Audio" button

**Navigation:** From AI Studio > Video Tools or Content Creation.

**States:**
- Loading: Script generation
- Error: "Could not generate script"
- Empty: Topic input prompt

**Responsive:** Editor on desktop, simplified on mobile.

---

## 11. Auto-Reply

**Purpose:** AI-powered automatic responses to comments and messages.

**Layout:** Configuration panel with reply rules, templates, and moderation queue.

**Key Components:**
- Auto-reply rules (trigger keywords, sentiment, platform)
- Reply templates per rule
- Tone and brand voice settings
- Moderation queue (AI-recommended replies for approval)
- Reply history and analytics
- Performance metrics (response time, satisfaction)
- Enable/disable toggle
- Escalation rules (when to notify human)
- A/B test reply variants

**Navigation:** From AI Studio > Automation or Settings > Auto-Reply.

**States:**
- Loading: Rules load
- Error: "Auto-reply unavailable"
- Empty: "No rules configured" with setup wizard

**Responsive:** Table/card view, stacks on mobile.

---

## 12. Content Calendar AI

**Purpose:** AI-generated content calendar with topic suggestions and optimal timing.

**Layout:** Calendar view with AI-suggested posts, topics, and themes.

**Key Components:**
- Monthly/weekly calendar
- AI-suggested posts per day (topic, format, time)
- Content themes and campaigns
- Content mix recommendations
- "Add Suggestion" button per day
- Custom event/holiday integration
- Content pillar balance chart
- Gap analysis (underrepresented topics)
- Export calendar option

**Navigation:** From AI Studio or main Calendar.

**States:**
- Loading: Calendar generation
- Error: "Could not generate calendar"
- Empty: "Set up content pillars to get started"

**Responsive:** Week view on mobile, month on desktop.

---

## 13. Image Generation

**Purpose:** Generate custom images for social media posts using AI.

**Layout:** Prompt input, style selector, generated images gallery.

**Key Components:**
- Text prompt input
- Style selector (photorealistic, illustration, abstract, etc.)
- Aspect ratio selector
- Color palette input
- "Generate" button
- Generated images grid (4 options)
- Edit/enhance button per image
- Download/use buttons
- Generation history
- Prompt templates library
- Reference image upload

**Navigation:** From AI Studio or post composer media section.

**States:**
- Loading: Generation spinner (with progress)
- Error: "Generation failed" with retry
- Empty: Prompt input with examples

**Responsive:** 2 columns on mobile, 4 on desktop.

---

## 14. Prompt Library

**Purpose:** Save, organize, and share AI prompts for consistent results.

**Layout:** Prompt list with categories, search, and editor.

**Key Components:**
- Prompt cards (title, preview, category, usage count)
- Category sidebar
- Search bar
- Create new prompt button
- Prompt editor (text, variables, tags)
- Import/export prompts
- Share prompts with team
- Favorite prompts
- Usage analytics per prompt
- Prompt templates

**Navigation:** From AI Studio > Prompt Library.

**States:**
- Loading: List skeleton
- Error: "Could not load prompts"
- Empty: "No prompts saved" with CTA

**Responsive:** List on mobile, grid on desktop.

---

## 15. AI Usage/Credits

**Purpose:** Monitor AI feature usage, credits remaining, and billing.

**Layout:** Usage dashboard with charts, credit balance, and purchase options.

**Key Components:**
- Credits remaining (big number display)
- Usage breakdown by feature (chart)
- Usage trends over time
- Credit cost per feature
- Purchase credits button
- Usage alerts/thresholds
- Team usage breakdown
- Export usage report
- Upgrade plan prompt (if near limit)

**Navigation:** From AI Studio header or Settings > AI Credits.

**States:**
- Loading: Usage data load
- Error: "Usage data unavailable"
- Empty: "No usage yet"

**Responsive:** Metric cards stack on mobile, grid on desktop.

---

## Screen Relationships

```
AI Studio Dashboard
├── Caption Generator → Post Composer
├── Title Generator → Post Composer
├── Content Ideas → Post Composer / Idea Bank
├── Trend Prediction → Content Ideas / Post Composer
├── Viral Analyzer → Post Composer
├── Content Repurposer → Post Composer
├── Translation → Post Composer
├── Rewriter → Post Composer
├── Script Writer → Video/Audio Tools
├── Auto-Reply → Settings / Moderation Queue
├── Content Calendar AI → Calendar / Queue
├── Image Generation → Media Library / Post Composer
├── Prompt Library → All AI Tools
└── AI Usage/Credits → Billing
```

## Design Tokens

- **Tool card size:** 200px × 160px
- **Credits display font:** 32px bold
- **Generated result card:** 100% width, 80px min-height
- **Image grid gap:** 8px
- **Prompt card height:** 80px
- **Loading spinner size:** 24px
- **Confidence badge:** 24px height
- **Font sizes:** 14px (body), 16px (subheading), 20px (heading)
- **Spacing:** 8px base unit
