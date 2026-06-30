# 05 - Analytics Screens

## 1. Overview Dashboard

**Purpose:** High-level analytics summary across all connected platforms.

**Layout:** Grid of metric cards, trend charts, and comparative widgets. Top bar with date range selector and filters.

**Key Components:**
- Metric cards (Followers, Engagement, Reach, Impressions, Growth)
- Trend sparklines per metric
- Period comparison (vs. last period)
- Platform breakdown donut chart
- Top performing content snippet
- Engagement rate gauge
- Follower growth line chart
- Quick date range buttons (7d, 30d, 90d, Custom)
- Export report button

**Navigation:** Main Analytics entry point from sidebar.

**States:**
- Loading: Skeleton grid
- Error: "Analytics unavailable" with retry
- Empty: "Connect accounts to see analytics"

**Responsive:** 2-column grid on mobile, 4-column on desktop.

---

## 2. Platform Analytics

**Purpose:** Detailed analytics per connected social platform.

**Layout:** Platform tabs with dedicated dashboard per platform showing platform-specific metrics.

**Key Components:**
- Platform tabs (Twitter, Instagram, LinkedIn, etc.)
- Platform-specific metrics (e.g., Twitter impressions, Instagram saves)
- Follower growth chart
- Engagement breakdown
- Post type performance (image, video, text)
- Best performing posts table
- Audience activity heatmap
- Platform health indicators

**Navigation:** From Overview > Platform breakdown or sidebar.

**States:**
- Loading: Skeleton tabs and charts
- Error: "Could not load platform analytics"
- Empty: "No data for this platform"

**Responsive:** Tabs scroll horizontally, content stacks on mobile.

---

## 3. Audience Demographics

**Purpose:** Understand audience composition across platforms.

**Layout:** Dashboard with demographic charts and filters.

**Key Components:**
- Age distribution bar chart
- Gender split pie chart
- Geographic heatmap (countries/cities)
- Language distribution
- Interest categories
- Device breakdown (mobile/desktop)
- Active hours heatmap
- Follower growth by demographic
- Platform comparison toggle

**Navigation:** From Overview > Audience tab or sidebar.

**States:**
- Loading: Chart skeletons
- Error: "Demographics unavailable"
- Empty: "Not enough audience data"

**Responsive:** Charts stack vertically, tables scroll horizontally.

---

## 4. Engagement Metrics

**Purpose:** Deep dive into engagement data (likes, comments, shares, saves).

**Layout:** Metric cards with detailed charts and breakdowns.

**Key Components:**
- Total engagement metric card
- Engagement rate card
- Engagement trend line chart
- Breakdown by type (likes, comments, shares, saves)
- Engagement by post type
- Engagement by platform
- Top engaging posts table
- Engagement velocity chart (speed of engagement)
- Comparison to industry benchmarks

**Navigation:** From Overview > Engagement or sidebar.

**States:**
- Loading: Skeleton charts
- Error: "Could not load engagement data"
- Empty: "No engagement data yet"

**Responsive:** Cards and charts stack on mobile.

---

## 5. Growth Metrics

**Purpose:** Track follower/audience growth over time.

**Layout:** Growth charts with net change indicators and projections.

**Key Components:**
- Total followers metric card
- Net follower change (period)
- Follower growth line chart
- Growth by platform stacked area chart
- Follower sources (organic, paid, referral)
- Unfollow rate indicator
- Growth projections (AI)
- Milestone tracker (next goal)
- Growth comparison to competitors

**Navigation:** From Overview > Growth or sidebar.

**States:**
- Loading: Chart skeleton
- Error: "Growth data unavailable"
- Empty: "Tracking started [date]"

**Responsive:** Charts stack vertically on mobile.

---

## 6. Content Performance

**Purpose:** Analyze which content types and topics perform best.

**Layout:** Comparative charts with content type breakdown and topic analysis.

**Key Components:**
- Content type performance (image, video, text, carousel, story)
- Topic/theme analysis
- Hashtag performance
- Posting time correlation
- Content length vs. engagement
- Media quality impact
- Content mix pie chart
- Performance trends over time
- AI content recommendations

**Navigation:** From Overview > Content or sidebar.

**States:**
- Loading: Chart skeletons
- Error: "Could not analyze content"
- Empty: "Not enough content for analysis"

**Responsive:** Charts and tables stack on mobile.

---

## 7. Best Posts

**Purpose:** Showcase top-performing posts with detailed metrics.

**Layout:** Card grid or ranked list of best posts with metrics.

**Key Components:**
- Post cards (thumbnail, caption, metrics)
- Ranking by metric (engagement, reach, clicks)
- Platform badge
- Performance vs. average indicator
- "Repurpose" button
- "View Details" link
- Date published
- Engagement breakdown

**Navigation:** From Overview > Best Posts or Content Performance.

**States:**
- Loading: Skeleton cards
- Error: "Could not load best posts"
- Empty: "No posts with sufficient data"

**Responsive:** Single column on mobile, 2-3 on desktop.

---

## 8. Hashtag Performance

**Purpose:** Analyze hashtag effectiveness and discover new hashtags.

**Layout:** Hashtag table with performance metrics and recommendations.

**Key Components:**
- Hashtag performance table (hashtag, posts, engagement, reach)
- Hashtag cloud visualization
- Trending hashtags in niche
- Hashtag usage frequency
- Engagement per hashtag
- Hashtag recommendations (AI)
- Saved hashtag sets
- Hashtag comparison tool

**Navigation:** From Content Performance > Hashtags or AI Studio.

**States:**
- Loading: Skeleton table
- Error: "Could not analyze hashtags"
- Empty: "No hashtag data yet"

**Responsive:** Table scrolls horizontally on mobile.

---

## 9. Optimal Times

**Purpose:** Data-driven recommendations for best posting times.

**Layout:** Heatmap visualization with recommendations and scheduling integration.

**Key Components:**
- Engagement heatmap (days × hours)
- "Best Times" badges
- Platform-specific heatmaps
- Comparison to current schedule
- "Schedule at Best Time" button
- Time zone adjuster
- Historical trend chart
- AI reasoning explanation

**Navigation:** From Overview > Optimal Times or Schedule Post modal.

**States:**
- Loading: Heatmap skeleton
- Error: "Could not analyze times"
- Empty: "Not enough data for time analysis"

**Responsive:** Heatmap scales, details in tooltip on mobile.

---

## 10. Competitor Comparison

**Purpose:** Benchmark performance against competitor accounts.

**Layout:** Side-by-side comparison charts with competitor selection.

**Key Components:**
- Competitor selector (add/remove accounts)
- Metric comparison cards (followers, engagement, growth)
- Comparative line charts
- Content type comparison
- Posting frequency comparison
- Engagement rate ranking
- Strengths/weaknesses analysis (AI)
- Gap opportunities (AI)

**Navigation:** From Analytics > Competitors or sidebar.

**States:**
- Loading: Comparison skeleton
- Error: "Could not fetch competitor data"
- Empty: "Add competitors to compare"

**Responsive:** Side-by-side on desktop, stacked on mobile.

---

## 11. Date Range Selector

**Purpose:** Flexible date range selection for all analytics views.

**Layout:** Dropdown with presets and custom range picker.

**Key Components:**
- Preset buttons (Today, Yesterday, 7d, 30d, 90d, YTD, Custom)
- Calendar date picker (start/end)
- Compare to previous period toggle
- Compare to custom range
- "Apply" button
- Selected range display

**Navigation:** Global component in analytics top bar.

**States:**
- Loading: None
- Error: None
- Empty: Default to last 30 days

**Responsive:** Compact on mobile, expanded on desktop.

---

## 12. Report Builder

**Purpose:** Create custom analytics reports with selected metrics and visualizations.

**Layout:** Drag-and-drop report builder with widget palette.

**Key Components:**
- Widget palette (charts, tables, metrics, text)
- Report canvas (drag to arrange)
- Widget configuration panel
- Date range selector
- Platform filters
- Report title and description
- Preview mode
- Save report button
- Schedule report button
- Share report button

**Navigation:** From Analytics > Reports or sidebar.

**States:**
- Loading: Builder init
- Error: "Could not load builder"
- Empty: Template selection prompt

**Responsive:** Simplified builder on mobile, full on desktop.

---

## 13. Export

**Purpose:** Export analytics data and reports in various formats.

**Layout:** Export modal with format options and settings.

**Key Components:**
- Format selector (PDF, CSV, PNG, PPTX)
- Date range confirmation
- Platform selection
- Metric selection
- Include charts toggle
- Include raw data toggle
- "Export" button
- Export history list

**Navigation:** Available from any analytics view via export button.

**States:**
- Loading: Export generation
- Error: "Export failed" with retry
- Empty: No previous exports

**Responsive:** Compact modal on all sizes.

---

## 14. Scheduled Reports

**Purpose:** Automate report generation and delivery on schedule.

**Layout:** List of scheduled reports with create/edit options.

**Key Components:**
- Scheduled reports table (name, frequency, recipients, next run)
- Create new schedule button
- Frequency selector (daily, weekly, monthly)
- Recipient email list
- Report template selection
- Delivery format preference
- Enable/disable toggle
- Run now button
- Delete schedule button

**Navigation:** From Analytics > Scheduled Reports or Settings.

**States:**
- Loading: Table skeleton
- Error: "Could not load schedules"
- Empty: "No scheduled reports"

**Responsive:** Table scrolls horizontally on mobile.

---

## 15. Real-Time Analytics

**Purpose:** Live-updating analytics for active campaigns or events.

**Layout:** Live dashboard with auto-refreshing charts and counters.

**Key Components:**
- Live engagement counter
- Real-time reach/impressions
- Active post performance
- Live audience map
- Refresh interval selector (5s, 15s, 30s, 60s)
- Pause/resume live feed
- Alert thresholds (engagement spike)
- Snapshot button (capture current state)

**Navigation:** From Analytics > Real-Time or campaign dashboard.

**States:**
- Loading: Connecting to live feed
- Error: "Connection lost" with reconnect
- Empty: "No active posts to track"

**Responsive:** Compact metrics on mobile, full dashboard on desktop.

---

## 16. Historical View

**Purpose:** Long-term trend analysis with year-over-year comparisons.

**Layout:** Long-range charts with comparison overlays.

**Key Components:**
- Year-over-year comparison charts
- Long-term trend lines (1y, 2y, all time)
- Seasonal pattern detection
- Growth milestones timeline
- Historical best/worst periods
- Data granularity toggle (daily, weekly, monthly)
- Anomaly detection markers
- Export historical data button

**Navigation:** From Analytics > Historical or date range custom view.

**States:**
- Loading: Chart skeleton
- Error: "Historical data unavailable"
- Empty: "Limited historical data"

**Responsive:** Charts stack vertically on mobile.

---

## 17. Goal Tracking

**Purpose:** Set and track progress toward social media goals.

**Layout:** Goal cards with progress bars and projection charts.

**Key Components:**
- Goal cards (metric, target, current, progress %)
- Progress bar with milestone markers
- Projection chart (on track / at risk)
- Goal history (past goals achieved)
- Create new goal button
- Goal types (followers, engagement, reach, revenue)
- Time period per goal
- Team assignment
- Celebration animation on achievement

**Navigation:** From Analytics > Goals or Dashboard widget.

**States:**
- Loading: Goal skeleton
- Error: "Could not load goals"
- Empty: "No goals set" with CTA

**Responsive:** Goal cards stack vertically on mobile.

---

## 18. ROI Calculator

**Purpose:** Calculate return on investment for social media activities.

**Layout:** Input form for costs and output for ROI metrics.

**Key Components:**
- Cost inputs (ads, tools, team time)
- Revenue attribution (direct, assisted)
- ROI formula display
- ROI percentage and dollar value
- Cost per engagement
- Cost per follower
- Cost per click
- Comparison to industry benchmarks
- "Improve ROI" AI suggestions
- Export ROI report button

**Navigation:** From Analytics > ROI or Settings.

**States:**
- Loading: Calculation spinner
- Error: "Could not calculate ROI"
- Empty: Input form with guidance

**Responsive:** Form stacks vertically on mobile.

---

## 19. Analytics Sharing

**Purpose:** Share analytics reports and dashboards with team members or clients.

**Layout:** Share modal with permission settings and link generation.

**Key Components:**
- Recipient email input
- Permission level (view, comment, edit)
- Shareable link generation
- Link expiration setting
- Password protection option
- Email delivery option
- Embed code generation
- Shared reports list
- Access revocation

**Navigation:** From any analytics view via share button.

**States:**
- Loading: Link generation
- Error: "Could not share" with retry
- Empty: No shared reports

**Responsive:** Compact modal on all sizes.

---

## 20. White-Label Reports

**Purpose:** Generate branded reports with custom logos, colors, and domain.

**Layout:** Report preview with branding customization panel.

**Key Components:**
- Brand logo upload
- Color scheme picker
- Custom header/footer
- Custom domain (for shared reports)
- Report template selection
- Preview mode
- Download branded PDF
- Schedule branded reports
- Client management (assign reports to clients)

**Navigation:** From Analytics > White-Label or Agency settings.

**States:**
- Loading: Preview generation
- Error: "Could not generate preview"
- Empty: Branding setup wizard

**Responsive:** Side-by-side editor and preview on desktop, stacked on mobile.

---

## Screen Relationships

```
Overview Dashboard
├── Platform Analytics (per platform)
├── Audience Demographics
├── Engagement Metrics
├── Growth Metrics
├── Content Performance
│   ├── Best Posts
│   ├── Hashtag Performance
│   └── Optimal Times
├── Competitor Comparison
├── Date Range Selector (global)
├── Report Builder → Export / Scheduled Reports
├── Real-Time Analytics
├── Historical View
├── Goal Tracking
├── ROI Calculator
├── Analytics Sharing
└── White-Label Reports
```

## Design Tokens

- **Metric card height:** 120px
- **Chart height:** 300px (standard), 200px (compact)
- **Heatmap cell size:** 24px × 24px
- **Progress bar height:** 8px
- **Table row height:** 48px
- **Goal progress bar height:** 12px
- **Report canvas grid:** 12 columns
- **Font sizes:** 12px (label), 14px (body), 20px (metric), 28px (headline)
- **Spacing:** 8px base unit
- **Color scale:** Success (green), Warning (amber), Error (red), Info (blue)
