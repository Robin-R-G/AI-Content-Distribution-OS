# 03 - Content Creation Screens

## 1. Post Composer

**Purpose:** Primary interface for creating new social media posts with multi-platform support.

**Layout:** Two-panel layout: left panel for content editing (text, media, settings), right panel for live preview across platforms. Top bar with platform selector, save, and publish/schedule buttons.

**Key Components:**
- Platform selector (Twitter, Instagram, LinkedIn, etc.)
- Text editor area with character count
- Media upload zone (drag & drop)
- Hashtag input with suggestions
- Mention input with autocomplete
- Link shortener toggle
- UTM builder button
- Schedule/Post buttons
- AI assistant button
- Content preview tabs (per platform)

**Navigation:** Accessible from Dashboard quick actions, Content Queue, or Calendar. "Save as Draft" saves to drafts list.

**States:**
- Loading: Skeleton composer
- Error: "Could not load composer" with retry
- Empty: Clean composer with helpful placeholders

**Responsive:** Single panel on mobile with preview toggle. Two panels on tablet/desktop.

---

## 2. Rich Text Editor

**Purpose:** Advanced text formatting for long-form content (LinkedIn articles, blog previews).

**Layout:** Toolbar with formatting options above text area. Character/word count below.

**Key Components:**
- Formatting toolbar (bold, italic, underline, lists, headings)
- Text area with contenteditable
- Character/word count
- Readability score indicator
- AI tone adjustment dropdown
- Link insertion modal
- Image insertion inline
- Code block support

**Navigation:** Embedded within Post Composer for long-form content.

**States:**
- Loading: Skeleton toolbar and area
- Error: Fallback to plain text
- Empty: Placeholder text with formatting tips

**Responsive:** Toolbar collapses to overflow menu on mobile.

---

## 3. Media Uploader

**Purpose:** Upload and basic editing of images, videos, and GIFs.

**Layout:** Dropzone area with upload button. After upload, shows thumbnail with edit/crop/replace options.

**Key Components:**
- Drag & drop zone
- File browser button
- Upload progress bar
- Thumbnail preview
- Crop/Resize tool
- Filters (for images)
- Trim tool (for videos)
- Alt text input
- Caption field
- Replace/Delete buttons

**Navigation:** Integrated into Post Composer. Opens media library for existing assets.

**States:**
- Loading: Upload progress spinner
- Error: "Upload failed" with retry
- Empty: Drag & drop prompt

**Responsive:** Full-width dropzone on mobile, side panel on desktop.

---

## 4. Media Library

**Purpose:** Central repository for all uploaded media assets with search and organization.

**Layout:** Grid view of media items with filters and folders. Detail panel on selection.

**Key Components:**
- Grid/ListView toggle
- Search bar
- Folder/collection sidebar
- Media thumbnails with type badges (image, video, GIF)
- Upload button
- Select multiple mode
- Sort dropdown (date, name, size)
- Bulk actions (delete, move, tag)
- Detail panel (preview, metadata, usage history)

**Navigation:** Opens from Media Uploader or standalone. Selecting media inserts into composer.

**States:**
- Loading: Grid skeleton
- Error: "Could not load media"
- Empty: "No media uploaded yet" with upload prompt

**Responsive:** 2 columns on mobile, 4-6 on desktop.

---

## 5. AI Caption Generator

**Purpose:** Generates platform-optimized captions from topic/keywords or image analysis.

**Layout:** Input field for topic/keywords, platform selector, tone dropdown, and generated results list.

**Key Components:**
- Topic/keyword input
- Platform selector (affects tone/length)
- Tone dropdown (professional, casual, witty, etc.)
- "Generate" button
- Results list (3-5 variations)
- Character count per result
- "Use This" button per result
- "Regenerate" button
- History of generated captions

**Navigation:** Accessible from Post Composer via AI button. Generated caption fills composer.

**States:**
- Loading: Skeleton results
- Error: "AI generation failed" with retry
- Empty: Input prompt with suggestions

**Responsive:** Full width on mobile, modal on desktop.

---

## 6. AI Title Generator

**Purpose:** Creates compelling titles/headlines for posts, articles, and threads.

**Layout:** Similar to caption generator with title-specific options.

**Key Components:**
- Content description input
- Title type selector (question, list, how-to, statement)
- Character limit input
- "Generate" button
- Results list with copy/use buttons
- SEO score indicator
- Readability score

**Navigation:** Opens from composer or content planning tools.

**States:**
- Loading: Skeleton
- Error: Retry prompt
- Empty: Input with examples

**Responsive:** Same as caption generator.

---

## 7. AI Hashtag Generator

**Purpose:** Generates relevant hashtags based on content, platform, and trending topics.

**Layout:** Input for content/topic, platform selector, and hashtag results with categories.

**Key Components:**
- Content/topic input
- Platform selector (affects hashtag limits)
- Generated hashtags grouped by category (niche, trending, branded)
- Popularity indicator per hashtag
- Competition indicator (high/medium/low)
- Copy all button
- Individual add/remove
- Custom hashtag input
- Saved hashtag sets

**Navigation:** Accessible from composer. Adds hashtags to post.

**States:**
- Loading: Skeleton hashtags
- Error: "Could not generate hashtags"
- Empty: Suggestion to enter content

**Responsive:** Scrollable list on mobile, grid on desktop.

---

## 8. AI Thumbnail Generator

**Purpose:** Creates eye-catching thumbnails from video frames or images with text overlay.

**Layout:** Upload area, text overlay editor, style presets, and preview.

**Key Components:**
- Image/video frame upload
- Text overlay editor (font, size, color, position)
- Style presets (bold, minimal, branded)
- AI-suggested thumbnails
- Aspect ratio selector (16:9, 1:1, 9:16)
- Preview across platforms
- Download button
- "Use as Thumbnail" button

**Navigation:** Opens from media uploader or reel/video editor.

**States:**
- Loading: Generating thumbnails
- Error: "Generation failed"
- Empty: Upload prompt

**Responsive:** Side-by-side editor and preview on desktop, stacked on mobile.

---

## 9. Content Preview

**Purpose:** Shows how post will appear on each platform before publishing.

**Layout:** Tabbed preview with platform-specific mockups (Twitter card, Instagram grid, LinkedIn post, etc.).

**Key Components:**
- Platform tabs
- Mock platform UI showing post
- Character count indicator
- Link preview card
- Image/video preview
- Hashtag display
- "Edit for Platform" button
- "Looks Good" confirmation

**Navigation:** Accessible from composer. Switches to platform-specific editor.

**States:**
- Loading: Skeleton mockups
- Error: "Preview unavailable"
- Empty: No content to preview

**Responsive:** Tabs scroll horizontally on mobile.

---

## 10. Platform Formatting

**Purpose:** Platform-specific formatting rules and auto-adjustments.

**Layout:** Side panel showing platform rules with auto-fix suggestions.

**Key Components:**
- Platform rules list (character limit, image size, hashtag limit)
- Violation warnings with auto-fix buttons
- Format preview
- "Auto-Format" button
- Custom formatting rules
- Platform-specific tips

**Navigation:** Integrated into composer, shows warnings when content violates rules.

**States:**
- Loading: Skeleton rules
- Error: Hidden (non-critical)
- Empty: "No formatting issues"

**Responsive:** Collapsible panel on mobile.

---

## 11. Thread Composer

**Purpose:** Create multi-post threads for Twitter/LinkedIn with preview.

**Layout:** Vertical stack of post cards with add/remove/reorder. Preview panel showing thread flow.

**Key Components:**
- Thread post cards (numbered)
- Add post button
- Remove post button
- Drag to reorder
- Individual character counts
- Thread preview (connected posts)
- "Post All" button
- "Schedule Thread" button
- AI continuation suggestion

**Navigation:** Opens from composer when thread mode selected.

**States:**
- Loading: Skeleton cards
- Error: "Could not load thread"
- Empty: Single post with "Add to thread" button

**Responsive:** Vertical stack on all sizes, preview toggled.

---

## 12. Carousel Builder

**Purpose:** Create multi-image/video carousel posts for Instagram/LinkedIn.

**Layout:** Horizontal slide editor with thumbnail strip, slide editor, and preview.

**Key Components:**
- Slide thumbnails (draggable)
- Current slide editor
- Add slide button
- Remove slide button
- Reorder slides
- Per-slide image/video upload
- Per-slide text overlay
- Per-slide caption
- Carousel preview (swipe simulation)
- Aspect ratio lock

**Navigation:** Opens from composer when carousel type selected.

**States:**
- Loading: Skeleton slides
- Error: "Could not load carousel"
- Empty: Single slide with "Add slide" prompt

**Responsive:** Thumbnail strip scrolls horizontally on mobile.

---

## 13. Story Creator

**Purpose:** Create Instagram/Facebook stories with stickers, text, and effects.

**Layout:** Canvas editor with story preview, tool panel, and sticker library.

**Key Components:**
- Canvas editor (9:16 aspect ratio)
- Text tool with fonts/colors
- Sticker library (poll, quiz, countdown, emoji)
- Image/video background
- Draw tool
- Music sticker
- Link sticker
- Mention sticker
- Hashtag sticker
- Template gallery
- Preview button
- "Post Story" button

**Navigation:** Opens from composer or story tab.

**States:**
- Loading: Canvas skeleton
- Error: "Could not load editor"
- Empty: Template selection prompt

**Responsive:** Full-screen editor on mobile, windowed on desktop.

---

## 14. Reel Editor

**Purpose:** Short-form video editor for Reels/TikTok/Shorts with effects and music.

**Layout:** Timeline editor with preview, tool panel, and music library.

**Key Components:**
- Video preview (9:16)
- Timeline with trim handles
- Text overlay tool
- Music library with search
- Effects/filters panel
- Speed control
- Transition effects
- Sticker/emoji overlays
- Recording button (for new footage)
- "Post Reel" button
- Draft save button

**Navigation:** Opens from composer or reels tab.

**States:**
- Loading: Editor initialization
- Error: "Could not load editor"
- Empty: Import or record prompt

**Responsive:** Full-screen on mobile, windowed on desktop.

---

## 15. Template Selector

**Purpose:** Choose from pre-designed post templates for quick content creation.

**Layout:** Grid of template thumbnails with category filters and search.

**Key Components:**
- Template grid with previews
- Category sidebar (business, lifestyle, product, etc.)
- Search bar
- Platform filter
- "Use Template" button per template
- Preview modal
- "Save as Custom" button
- Recently used section

**Navigation:** Opens from composer "Templates" button. Selecting template opens editor.

**States:**
- Loading: Skeleton grid
- Error: "Could not load templates"
- Empty: "No templates available"

**Responsive:** 2 columns mobile, 4+ desktop.

---

## 16. Template Builder

**Purpose:** Create custom post templates from existing posts or from scratch.

**Layout:** Template editor with element palette, canvas, and properties panel.

**Key Components:**
- Element palette (text, image, shape, logo)
- Canvas editor
- Properties panel (font, color, size, position)
- Layer management
- Save as template button
- Preview across platforms
- Brand kit integration
- Variable placeholders (date, event, etc.)

**Navigation:** Opens from template selector "Create Custom" or from saved templates.

**States:**
- Loading: Editor init
- Error: "Could not load builder"
- Empty: Blank canvas with tutorial

**Responsive:** Full editor on desktop, simplified on mobile.

---

## 17. Brand Kit

**Purpose:** Manage brand assets (logos, colors, fonts, tones) for consistent content.

**Layout:** Tabbed interface with sections for logos, colors, fonts, tone, and templates.

**Key Components:**
- Logo upload and management
- Color palette editor (primary, secondary, accent)
- Font selections (primary, secondary)
- Brand tone settings
- Default hashtags
- Brand voice guidelines
- Template library
- Usage analytics

**Navigation:** Accessible from settings or composer brand button.

**States:**
- Loading: Skeleton tabs
- Error: "Could not load brand kit"
- Empty: Setup wizard prompt

**Responsive:** Tabbed layout, content stacks on mobile.

---

## 18. Emoji Picker

**Purpose:** Quick emoji selection for posts with search and frequently used.

**Layout:** Popover panel with emoji grid, search bar, and categories.

**Key Components:**
- Search bar
- Category tabs (smileys, animals, food, etc.)
- Frequently used section
- Skin tone selector
- Emoji grid
- Recently used section
- Copy/insert button

**Navigation:** Triggered from composer emoji button. Inserts at cursor.

**States:**
- Loading: Skeleton grid
- Error: Fallback to system emoji
- Empty: Shows all emojis

**Responsive:** Full-width popover on mobile, compact on desktop.

---

## 19. Mention Picker

**Purpose:** Search and insert @mentions for team members or tagged accounts.

**Layout:** Search input with autocomplete dropdown showing matching profiles.

**Key Components:**
- Search input
- Autocomplete results (avatar, name, handle)
- Recent mentions section
- Team members section
- Platform-specific handles
- "Add to post" action

**Navigation:** Triggered from @ in composer. Inserts mention at cursor.

**States:**
- Loading: Skeleton list
- Error: "Could not search mentions"
- Empty: "Type to search"

**Responsive:** Dropdown adjusts width to container.

---

## 20. Link Shortener

**Purpose:** Shorten URLs and track click analytics.

**Layout:** Input field for long URL, shortening options, and generated short link.

**Key Components:**
- Long URL input
- Custom alias option (if supported)
- Domain selector (bit.ly, tinyurl, custom)
- Short link display
- QR code generation
- Copy button
- Click analytics preview
- "Use Short Link" button

**Navigation:** Opens from composer link button. Shortened link inserts into post.

**States:**
- Loading: Shortening spinner
- Error: "Could not shorten URL"
- Empty: URL input prompt

**Responsive:** Compact modal on all sizes.

---

## 21. UTM Builder

**Purpose:** Add UTM parameters to links for campaign tracking.

**Layout:** Form with fields for source, medium, campaign, term, content, and preview URL.

**Key Components:**
- URL input
- Source field (e.g., twitter, instagram)
- Medium field (e.g., social, cpc)
- Campaign field
- Term field (optional)
- Content field (optional)
- Preview of final URL
- Copy button
- Save UTM presets
- "Apply to Link" button

**Navigation:** Opens from link shortener or composer. Applies to post link.

**States:**
- Loading: None (instant)
- Error: Validation messages
- Empty: Form with labels

**Responsive:** Full-width form on mobile, compact on desktop.

---

## 22. A/B Test Variants

**Purpose:** Create multiple variants of a post to test performance.

**Layout:** Split view showing original and variant(s) side by side.

**Key Components:**
- Original post panel
- Add variant button
- Variant panels (text, media, hashtags)
- Variant labels (A, B, C)
- Platform selector per variant
- Winning metric selector (engagement, clicks, reach)
- "Test with [X]% of audience" slider
- "Post Winner" button (after test)
- Test duration setting

**Navigation:** Opens from composer advanced options.

**States:**
- Loading: Skeleton panels
- Error: "Could not create variant"
- Empty: Original post with "Add variant" prompt

**Responsive:** Stacked on mobile, side-by-side on desktop.

---

## 23. Version History

**Purpose:** Track and restore previous versions of a post or content piece.

**Layout:** Timeline or list of versions with diffs and restore option.

**Key Components:**
- Version list (timestamp, author, summary)
- Diff view (changes highlighted)
- Restore button per version
- Compare versions selector
- Version notes
- Current version indicator

**Navigation:** Opens from post editor history button.

**States:**
- Loading: Skeleton list
- Error: "Could not load history"
- Empty: "No previous versions"

**Responsive:** List view on all sizes.

---

## 24. Collaboration Comments

**Purpose:** Team discussion and feedback on content before publishing.

**Layout:** Comment thread sidebar with reply functionality.

**Key Components:**
- Comment thread (avatar, name, text, timestamp)
- Reply button
- Resolve button
- @mention in comments
- File attachment
- Emoji reactions
- Sort by (newest, oldest)
- Comment count badge

**Navigation:** Opens from post editor comments button.

**States:**
- Loading: Skeleton comments
- Error: "Could not load comments"
- Empty: "No comments yet"

**Responsive:** Full sidebar on desktop, bottom sheet on mobile.

---

## 25. Content Repurposing

**Purpose:** Transform existing content into different formats (blog → tweets, video → clips).

**Layout:** Source content panel with transformation options and output preview.

**Key Components:**
- Source content selector (URL, file, text)
- Transformation type (long→short, text→video, etc.)
- AI analysis of source
- Generated outputs list
- Edit per output
- "Use All" or "Use Selected" buttons
- Platform presets

**Navigation:** Opens from AI Studio or composer.

**States:**
- Loading: Analysis spinner
- Error: "Could not analyze content"
- Empty: Source selection prompt

**Responsive:** Stacked panels on mobile, side-by-side on desktop.

---

## Screen Relationships

```
Post Composer
├── Rich Text Editor (long-form)
├── Media Uploader → Media Library
├── AI Caption Generator
├── AI Title Generator
├── AI Hashtag Generator
├── AI Thumbnail Generator
├── Content Preview (per platform)
├── Platform Formatting
├── Thread Composer
├── Carousel Builder
├── Story Creator
├── Reel Editor
├── Template Selector → Template Builder
├── Brand Kit
├── Emoji Picker
├── Mention Picker
├── Link Shortener → UTM Builder
├── A/B Test Variants
├── Version History
├── Collaboration Comments
└── Content Repurposing
```

## Design Tokens

- **Composer max-width:** 720px (text), 1080px (full)
- **Preview mockup width:** 320px (mobile), 480px (desktop)
- **Slide thumbnail size:** 80px × 80px
- **Timeline height:** 120px (story/reel)
- **Comment thread width:** 320px
- **Emoji picker size:** 352px × 400px
- **Canvas editor:** 1080 × 1920 (story), 1080 × 1080 (post)
- **Font sizes:** 12px (caption), 14px (body), 16px (heading)
- **Spacing:** 8px base unit
