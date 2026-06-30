# 02 - Dashboard Screens

## 1. Main Dashboard

**Purpose:** Central hub providing at-a-glance overview of social media performance, pending tasks, and AI insights.

**Layout:** Three-column layout with left sidebar (navigation), center content area (metrics cards, charts, feeds), right sidebar (notifications, quick actions). Top bar with workspace selector, search, and user profile.

**Key Components:**
- Metrics summary cards (followers, engagement, reach, impressions)
- Performance trend chart (7/30/90 day toggle)
- Upcoming posts carousel
- Recent analytics mini-chart
- AI suggestions panel
- Activity feed
- Quick action buttons

**Navigation:** Accessed via left sidebar "Dashboard" link. Cards are clickable to drill into detailed views.

**States:**
- Loading: Skeleton loaders for cards and charts
- Error: Error boundary with retry button
- Empty: Onboarding prompts to connect accounts and create first post

**Responsive:** Single column on mobile with collapsible sidebar. Cards stack vertically. Charts become scrollable horizontally.

---

## 2. Quick Actions

**Purpose:** Floating action panel for common tasks to reduce navigation steps.

**Layout:** Dropdown panel or modal triggered by "+" button in top bar or sidebar. Grid of action cards with icons and labels.

**Key Components:**
- Create Post button
- Schedule Post button
- Upload Media button
- AI Content Generator link
- Import Content button
- Team Invite button
- Analytics Report button

**Navigation:** Triggered globally from top bar "+". Actions link to respective screens.

**States:**
- Loading: Skeleton grid
- Error: Fallback with basic links
- Empty: Always shows available actions (no empty state)

**Responsive:** Full-screen modal on mobile with scrollable grid.

---

## 3. Upcoming Posts

**Purpose:** Preview of posts scheduled for the next 7-30 days with quick edit/reschedule options.

**Layout:** Horizontal scrollable carousel or vertical list with thumbnails, captions, scheduled times, and platform icons.

**Key Components:**
- Post thumbnail/preview
- Caption snippet
- Platform icons (Twitter, Instagram, etc.)
- Scheduled date/time
- Edit button
- Reschedule button
- Delete button
- Status indicator (scheduled, pending approval, queued)

**Navigation:** Click post opens post detail/edit modal. "View All" links to full content queue.

**States:**
- Loading: Shimmer placeholders
- Error: Retry prompt
- Empty: "No upcoming posts" with CTA to create one

**Responsive:** Horizontal scroll on mobile, vertical list on tablet/desktop.

---

## 4. Recent Analytics

**Purpose:** Mini chart showing performance trends for the last 7-30 days across key metrics.

**Layout:** Small card with line/bar chart, metric selector dropdown, and date range indicator.

**Key Components:**
- Chart (line for trends, bar for comparisons)
- Metric selector (engagement, reach, impressions, followers)
- Date range label
- Trend indicator (up/down arrow with percentage)
- "View Full Analytics" link

**Navigation:** Click opens full analytics dashboard with selected metric pre-selected.

**States:**
- Loading: Skeleton chart
- Error: Static "No data available"
- Empty: "Connect accounts to see analytics"

**Responsive:** Same card layout, chart adjusts width.

---

## 5. AI Suggestions

**Purpose:** Displays AI-generated content ideas, optimal posting times, and engagement predictions.

**Layout:** Card with icon, suggestion text, confidence score, and action buttons (Apply, Dismiss, Save).

**Key Components:**
- AI suggestion card (icon, title, description)
- Confidence/Relevance score badge
- "Apply" button (auto-fills composer)
- "Dismiss" button
- "Save for Later" button
- Refresh button to regenerate
- Category tags (content idea, timing, hashtag)

**Navigation:** "Apply" opens post composer with pre-filled data. "Save" adds to idea bank.

**States:**
- Loading: Skeleton cards
- Error: "AI service unavailable" message
- Empty: "No suggestions right now" with refresh option

**Responsive:** Single column list on mobile, grid on desktop.

---

## 6. Activity Feed

**Purpose:** Real-time log of team actions, post statuses, and system events.

**Layout:** Vertical scrollable feed with timestamp, user avatar, action description, and optional link.

**Key Components:**
- User avatar and name
- Action description (e.g., "John scheduled a post to Twitter")
- Timestamp
- Post thumbnail (if applicable)
- Status badge (published, failed, pending)
- "View Details" link
- Filter dropdown (All, Posts, Comments, System)

**Navigation:** Click action opens relevant detail (post, analytics, etc.).

**States:**
- Loading: Skeleton feed items
- Error: "Could not load activity"
- Empty: "No recent activity"

**Responsive:** Full width on mobile, sidebar width on desktop.

---

## 7. Notifications Panel

**Purpose:** Centralized notification center for alerts, mentions, approvals, and system messages.

**Layout:** Slide-out panel from right side or dedicated page. Tabs for All, Mentions, Approvals, System.

**Key Components:**
- Notification list with icon, title, description, timestamp
- Unread indicator (dot/badge)
- Mark all as read button
- Individual notification actions (Approve, Reply, Dismiss)
- Notification preferences link
- Tab filters

**Navigation:** Click notification opens relevant context (post, comment, settings).

**States:**
- Loading: Skeleton list
- Error: "Could not load notifications"
- Empty: "You're all caught up!"

**Responsive:** Full-screen overlay on mobile, side panel on desktop.

---

## 8. Calendar View

**Purpose:** Visual monthly/weekly calendar showing scheduled posts, campaigns, and content milestones.

**Layout:** Full-width calendar grid with day cells, post thumbnails, color-coded by platform or status.

**Key Components:**
- Month/Week/Day view toggle
- Navigation arrows (prev/next month)
- Day cells with post indicators
- Post thumbnails with platform badges
- "Add Post" button per day
- Legend for colors/statuses
- Today highlight

**Navigation:** Click day opens day detail or post composer. Click post opens post detail.

**States:**
- Loading: Calendar skeleton
- Error: "Could not load calendar"
- Empty: Empty calendar with "No posts scheduled" message

**Responsive:** Week view on mobile, full month on tablet/desktop.

---

## 9. Content Queue

**Purpose:** Ordered list of all posts waiting to be published, with drag-and-drop reordering.

**Layout:** Table or list view with columns: Order, Post Preview, Platform, Scheduled Time, Status, Actions.

**Key Components:**
- Drag handle for reordering
- Post thumbnail and caption snippet
- Platform icon(s)
- Scheduled date/time
- Status badge (Queued, Scheduled, Pending Approval)
- Edit/Reschedule/Delete buttons
- Queue settings (auto-sort by optimal time)

**Navigation:** Click post opens edit modal. Drag to reorder.

**States:**
- Loading: Table skeleton
- Error: Retry message
- Empty: "Queue is empty" with CTA

**Responsive:** Card layout on mobile, table on desktop.

---

## 10. Performance Summary

**Purpose:** Weekly/monthly automated performance report summary card.

**Layout:** Card with key metrics, trend arrows, comparison to previous period, and "View Report" link.

**Key Components:**
- Period label (e.g., "Week of Jan 15-21")
- Key metrics (engagement rate, reach, follower growth)
- Trend indicators (up/down with %)
- Mini sparkline charts
- "View Full Report" button
- "Share Report" button

**Navigation:** Opens detailed analytics report.

**States:**
- Loading: Skeleton card
- Error: "Report generation failed"
- Empty: "Not enough data for report"

**Responsive:** Same card layout, scales down on mobile.

---

## 11. Trending Topics

**Purpose:** Shows trending hashtags, topics, and viral content relevant to user's niche.

**Layout:** Card with list of trending items, each with topic name, volume, trend direction, and action button.

**Key Components:**
- Trending topic/hashtag name
- Volume/participation count
- Trend direction (rising, stable, declining)
- "Create Post" button
- "Save Topic" button
- Category filter
- "Refresh Trends" button

**Navigation:** "Create Post" opens composer with topic pre-filled. Click topic shows more details.

**States:**
- Loading: Skeleton list
- Error: "Could not fetch trends"
- Empty: "No trending topics for your niche"

**Responsive:** Horizontal scroll on mobile, list on desktop.

---

## 12. Team Activity

**Purpose:** Shows recent actions by team members for transparency and collaboration.

**Layout:** Compact feed with user avatars, action summaries, and timestamps.

**Key Components:**
- User avatar and name
- Action (e.g., "Created a post", "Approved content")
- Timestamp
- Link to relevant content
- Filter by team member
- "View All Activity" link

**Navigation:** Click action opens relevant content. Click user opens member profile.

**States:**
- Loading: Skeleton
- Error: "Could not load team activity"
- Empty: "No team activity yet"

**Responsive:** Same layout, compact on mobile.

---

## 13. Workspace Switcher

**Purpose:** Allows users to switch between different workspaces (e.g., personal, client A, client B).

**Layout:** Dropdown in top bar showing current workspace, list of workspaces, and "Create Workspace" option.

**Key Components:**
- Current workspace name and icon
- Dropdown list of workspaces
- Workspace icons/logos
- "Create Workspace" button
- "Manage Workspaces" link

**Navigation:** Selecting workspace reloads dashboard with that workspace's data.

**States:**
- Loading: Skeleton dropdown
- Error: "Could not load workspaces"
- Empty: Only "Create Workspace" shown

**Responsive:** Same dropdown, full-width on mobile.

---

## 14. Org Switcher

**Purpose:** For users belonging to multiple organizations, allows switching org context.

**Layout:** Similar to workspace switcher, dropdown in top bar or profile menu.

**Key Components:**
- Current org name and logo
- Dropdown list of organizations
- "Create Organization" option
- "Organization Settings" link

**Navigation:** Selecting org reloads with org-level data and permissions.

**States:**
- Loading: Skeleton
- Error: "Could not load organizations"
- Empty: Single org or "No organizations"

**Responsive:** Same dropdown behavior.

---

## 15. Search Results

**Purpose:** Global search across posts, analytics, team members, settings, and content.

**Layout:** Search bar in top bar with dropdown results or dedicated results page with filters.

**Key Components:**
- Search input with auto-suggest
- Result categories (Posts, Analytics, Team, Settings)
- Result items with thumbnail, title, description, date
- Filter sidebar (date range, type, platform)
- "No results found" state
- Search history/suggestions

**Navigation:** Click result opens relevant detail page.

**States:**
- Loading: Skeleton results
- Error: "Search failed"
- Empty: "No results for [query]" with suggestions

**Responsive:** Full-screen results on mobile, sidebar results on desktop.

---

## 16. Command Palette

**Purpose:** Keyboard-driven quick access to actions, navigation, and search (Cmd/Ctrl+K).

**Layout:** Modal overlay with search input, categorized results list, and keyboard shortcut hints.

**Key Components:**
- Search input with icon
- Categorized results (Actions, Navigation, Recent)
- Result items with icon, label, shortcut hint
- Keyboard navigation (arrow keys, enter, escape)
- Recent searches section
- "Did you mean?" suggestions

**Navigation:** Selecting item executes action or navigates.

**States:**
- Loading: Minimal spinner
- Error: "Command not found"
- Empty: Shows recent and suggested commands

**Responsive:** Full-width modal on mobile, centered modal on desktop.

---

## Screen Relationships

```
Main Dashboard
├── Quick Actions (modal)
├── Upcoming Posts → Post Detail/Edit
├── Recent Analytics → Full Analytics
├── AI Suggestions → Post Composer
├── Activity Feed → Content Details
├── Notifications Panel → Context Details
├── Calendar View → Day Detail/Post Composer
├── Content Queue → Post Edit/Reschedule
├── Performance Summary → Full Report
├── Trending Topics → Post Composer
├── Team Activity → Member Profile
├── Workspace Switcher → Dashboard Reload
├── Org Switcher → Dashboard Reload
├── Search Results → Various Details
└── Command Palette → Various Actions
```

## Design Tokens

- **Card padding:** 16px (mobile), 24px (desktop)
- **Card border-radius:** 12px
- **Card shadow:** 0 2px 8px rgba(0,0,0,0.08)
- **Chart height:** 200px (summary), 400px (full)
- **Feed item height:** 64px
- **Icon size:** 20px (inline), 24px (standalone)
- **Font sizes:** 14px (body), 16px (subheading), 20px (heading)
- **Spacing:** 8px base unit
