# 04 - Publishing Screens

## 1. Schedule Post

**Purpose:** Set specific date/time for post publication with timezone support.

**Layout:** Calendar/time picker modal with timezone selector and confirmation.

**Key Components:**
- Calendar date picker
- Time picker (hour/minute)
- Timezone selector with search
- "Schedule for Best Time" AI suggestion
- Recurring schedule option
- Schedule confirmation summary
- "Schedule" and "Cancel" buttons

**Navigation:** Opens from post composer "Schedule" button or content queue.

**States:**
- Loading: Calendar skeleton
- Error: "Could not load scheduler"
- Empty: Current date/time selected

**Responsive:** Full-screen modal on mobile, centered modal on desktop.

---

## 2. Queue Management

**Purpose:** Manage the ordered list of posts waiting to be published with drag-and-drop reordering.

**Layout:** Table/card view with columns: Order, Post, Platform, Scheduled, Status, Actions.

**Key Components:**
- Drag handle for reordering
- Post thumbnail and caption preview
- Platform icon(s)
- Scheduled date/time
- Status badge (Queued, Scheduled, Pending)
- Edit/Reschedule/Delete buttons
- Queue settings (auto-sort by optimal time)
- Pause queue toggle
- "Add to Queue" button
- Bulk actions (select multiple, delete, reschedule)

**Navigation:** Accessible from Dashboard or Publishing section.

**States:**
- Loading: Table skeleton
- Error: "Could not load queue"
- Empty: "Queue empty" with CTA

**Responsive:** Card layout on mobile, table on desktop.

---

## 3. Publishing Calendar

**Purpose:** Visual calendar for managing all scheduled and published content.

**Layout:** Full-width calendar grid with day/week/month views. Sidebar for filters.

**Key Components:**
- View toggle (Day/Week/Month)
- Navigation arrows (prev/next)
- Day cells with post indicators
- Post thumbnails with platform badges
- Status indicators (scheduled, published, failed)
- "Add Post" button per day
- Filter sidebar (platform, status, team member)
- Today highlight
- Drag to reschedule

**Navigation:** Click post opens post detail. Click day opens day detail or composer.

**States:**
- Loading: Calendar skeleton
- Error: "Could not load calendar"
- Empty: Empty calendar with setup prompt

**Responsive:** Week view on mobile, full month on desktop.

---

## 4. Bulk Schedule

**Purpose:** Schedule multiple posts at once from CSV upload or batch selection.

**Layout:** Upload area for CSV, preview table, and scheduling options.

**Key Components:**
- CSV upload dropzone
- CSV template download link
- Preview table (columns from CSV)
- Mapping interface (CSV columns → post fields)
- Schedule option (all at once, drip, custom)
- Date/time range selector
- Platform assignment per row
- Validation errors list
- "Schedule All" button
- Progress indicator

**Navigation:** Opens from content queue or calendar bulk actions.

**States:**
- Loading: Upload/parse spinner
- Error: "Upload failed" or validation errors
- Empty: Upload prompt with template

**Responsive:** Full-width table on all sizes, horizontal scroll on mobile.

---

## 5. Auto-Publish Settings

**Purpose:** Configure automatic publishing rules for recurring content.

**Layout:** Settings form with rules engine for auto-publish triggers.

**Key Components:**
- Rule creator (trigger, condition, action)
- Trigger options (time, event, RSS feed)
- Condition filters (platform, content type, keywords)
- Action settings (publish, schedule, queue)
- Active rules list with toggle
- Rule execution history
- "Test Rule" button
- Notifications for auto-publish events

**Navigation:** Accessible from Settings > Publishing or Calendar.

**States:**
- Loading: Settings skeleton
- Error: "Could not load settings"
- Empty: "No auto-publish rules" with CTA

**Responsive:** Full-width form, sections stack on mobile.

---

## 6. Best Time Suggestions

**Purpose:** AI-recommended optimal posting times based on audience analytics.

**Layout:** Heatmap or chart showing engagement by hour/day with recommendations.

**Key Components:**
- Heatmap (days × hours) color-coded by engagement
- Platform selector (times vary by platform)
- "Best Times" badges on high-engagement slots
- Custom time override
- Schedule at suggested time button
- Comparison chart (your times vs. best times)
- Explanation of AI reasoning

**Navigation:** Opens from schedule modal or analytics.

**States:**
- Loading: Chart skeleton
- Error: "Could not analyze times"
- Empty: "Not enough data" with prompt to connect accounts

**Responsive:** Heatmap scales down, details in tooltip on mobile.

---

## 7. Platform/Account Selectors

**Purpose:** Choose which social accounts/platforms to publish to.

**Layout:** Multi-select checkboxes with platform icons and account names.

**Key Components:**
- Platform grouping (Twitter, Instagram, LinkedIn, etc.)
- Account checkboxes with avatars
- "Select All" toggle
- Account health indicators (connected, token valid)
- Platform-specific options preview
- Character limit warnings per platform
- "Selected: X accounts" summary

**Navigation:** Integrated into post composer and scheduling.

**States:**
- Loading: Checkbox skeleton
- Error: "Could not load accounts"
- Empty: "No accounts connected" with CTA

**Responsive:** List on mobile, grid on desktop.

---

## 8. Cross-Posting

**Purpose:** Configure how content adapts when posted across multiple platforms.

**Layout:** Side-by-side comparison of content per platform with adaptation options.

**Key Components:**
- Platform tabs with content previews
- Auto-adapt toggle (truncate, reformat)
- Per-platform text overrides
- Per-platform media selection
- Per-platform hashtag settings
- Per-platform schedule times
- "Mirror Post" vs. "Customize" modes
- Platform-specific feature toggles (threads, carousels, stories)

**Navigation:** Opens from composer when multiple platforms selected.

**States:**
- Loading: Preview skeleton
- Error: "Could not generate previews"
- Empty: No platforms selected

**Responsive:** Tabs scroll horizontally, content stacks vertically on mobile.

---

## 9. Post Confirmation

**Purpose:** Final review before publishing with checklist and one-click publish.

**Layout:** Modal or full page with post preview, checklist, and publish button.

**Key Components:**
- Post preview (per platform)
- Checklist (content complete, media attached, schedule set)
- Warning badges for issues
- "Edit" button to go back
- "Publish Now" button
- "Schedule" button
- "Save as Draft" button
- Confirmation dialog

**Navigation:** Opens after schedule/queue action from composer.

**States:**
- Loading: Preview skeleton
- Error: "Could not load preview"
- Empty: N/A (always has content)

**Responsive:** Full-screen on mobile, modal on desktop.

---

## 10. Publishing Progress

**Purpose:** Real-time progress indicator for publishing posts.

**Layout:** Progress bar with status messages and step indicators.

**Key Components:**
- Progress bar (0-100%)
- Step indicators (Uploading, Processing, Publishing, Confirming)
- Current step highlight
- Status messages per step
- Cancel button
- "View Post" link (after completion)

**Navigation:** Shows automatically during publishing process.

**States:**
- Loading: Active progress
- Error: Failed step with retry
- Empty: N/A

**Responsive:** Full-width progress bar on all sizes.

---

## 11. Success/Failure Notifications

**Purpose:** Confirm successful publication or alert on failure with details.

**Layout:** Success/failure modal with post preview and actions.

**Key Components:**
- Success/failure icon and message
- Post preview thumbnail
- Platform and account details
- "View Post" link
- "View Analytics" link
- "Retry" button (for failures)
- Error details (for failures)
- "Dismiss" button

**Navigation:** Shows after publishing completes.

**States:**
- Loading: Processing state
- Error: Failure details
- Empty: N/A

**Responsive:** Centered modal on all sizes.

---

## 12. Retry Failed Posts

**Purpose:** Retry publishing posts that failed due to transient errors.

**Layout:** Error details with retry options and error history.

**Key Components:**
- Error message and code
- Retry button (immediate)
- Retry at specific time
- Edit and retry
- Error history log
- "Contact Support" link
- Disable auto-retry toggle

**Navigation:** Opens from failure notification or failed posts list.

**States:**
- Loading: Retry in progress
- Error: Persistent failure
- Empty: N/A

**Responsive:** Compact layout on all sizes.

---

## 13. Drafts

**Purpose:** Manage saved drafts before publishing.

**Layout:** List/grid of drafts with search, filter, and bulk actions.

**Key Components:**
- Draft cards (thumbnail, caption preview, saved date)
- Search bar
- Filter (platform, date, author)
- Sort (last edited, created, name)
- Edit button per draft
- Delete button
- Duplicate button
- "Publish" button
- Bulk select and actions
- Empty state

**Navigation:** Accessible from Dashboard or Publishing section.

**States:**
- Loading: Skeleton grid
- Error: "Could not load drafts"
- Empty: "No drafts" with CTA

**Responsive:** List on mobile, grid on desktop.

---

## 14. Scheduled Posts List

**Purpose:** View all posts scheduled for future publication.

**Layout:** Table/card view with scheduled time, platform, status, and actions.

**Key Components:**
- Post cards (thumbnail, caption, scheduled time)
- Platform icons
- Status (Scheduled, Pending Approval, Queued)
- Edit/Reschedule/Delete buttons
- Filter by platform/date/status
- Sort by scheduled time
- "Post Now" button (override schedule)
- Calendar view toggle

**Navigation:** Accessible from Dashboard or Publishing section.

**States:**
- Loading: Skeleton
- Error: "Could not load scheduled posts"
- Empty: "No posts scheduled"

**Responsive:** Card layout on mobile, table on desktop.

---

## 15. Published Posts List

**Purpose:** View all previously published posts with performance metrics.

**Layout:** Table/card view with post preview, publish date, platform, and engagement metrics.

**Key Components:**
- Post cards (thumbnail, caption, publish date)
- Platform icons
- Engagement metrics (likes, comments, shares, reach)
- Performance badge (good, average, poor)
- Filter by platform/date/performance
- Sort by date/engagement
- "View Analytics" button
- "Repurpose" button
- "Delete" button

**Navigation:** Accessible from Analytics or Publishing section.

**States:**
- Loading: Skeleton
- Error: "Could not load published posts"
- Empty: "No published posts"

**Responsive:** Card layout on mobile, table on desktop.

---

## 16. Post Detail

**Purpose:** Comprehensive view of a single post with all metadata and actions.

**Layout:** Full post preview with metadata panel and action buttons.

**Key Components:**
- Full post preview (per platform)
- Metadata (author, created, scheduled, published dates)
- Platform details (post ID, URL)
- Engagement metrics (if published)
- Status timeline (created → scheduled → published)
- Edit/Reschedule/Delete buttons
- Duplicate button
- Analytics link
- Collaboration comments
- Version history

**Navigation:** Opens from any post list or calendar.

**States:**
- Loading: Skeleton
- Error: "Could not load post"
- Empty: N/A

**Responsive:** Full-width on mobile, two-panel on desktop.

---

## 17. Post Analytics

**Purpose:** Quick analytics view for a specific published post.

**Layout:** Compact analytics card with key metrics and trends.

**Key Components:**
- Engagement metrics (likes, comments, shares)
- Reach and impressions
- Click-through rate
- Engagement rate
- Performance vs. average
- Time-based chart (engagement over hours/days)
- Audience demographics (top)
- "View Full Analytics" link

**Navigation:** Opens from post detail or published posts list.

**States:**
- Loading: Skeleton metrics
- Error: "Analytics unavailable"
- Empty: "Not enough data yet"

**Responsive:** Compact card on mobile, expanded on desktop.

---

## 18. Delete/Archive Post

**Purpose:** Confirm deletion or archiving of posts with options.

**Layout:** Confirmation modal with warning and options.

**Key Components:**
- Warning message about deletion
- "Delete" vs. "Archive" options
- "Also remove from published" toggle
- "Notify team" checkbox
- Confirmation input (type "DELETE" for permanent)
- "Cancel" and "Confirm" buttons
- Impact preview (metrics will be lost)

**Navigation:** Opens from post detail or list actions.

**States:**
- Loading: None
- Error: "Could not delete" with retry
- Empty: N/A

**Responsive:** Centered modal on all sizes.

---

## 19. Approval Workflow

**Purpose:** Manage post approval process for team/client content.

**Layout:** Queue of posts awaiting approval with approve/reject actions.

**Key Components:**
- Approval queue list
- Post preview with full content
- Approver assignment
- Approve/Reject buttons
- Comment/feedback field
- Request changes button
- Approval status badges
- Approval history timeline
- Auto-approve rules

**Navigation:** Accessible from Dashboard notifications or Publishing section.

**States:**
- Loading: Skeleton list
- Error: "Could not load approvals"
- Empty: "No posts awaiting approval"

**Responsive:** Card layout on all sizes.

---

## 20. Post History Timeline

**Purpose:** Visual timeline of a post's lifecycle from creation to publication.

**Layout:** Vertical timeline with events and timestamps.

**Key Components:**
- Timeline events (Created, Edited, Scheduled, Approved, Published)
- Timestamps per event
- User who performed action
- Version links (for edits)
- Status indicators
- "View Version" buttons
- Current state highlight

**Navigation:** Accessible from post detail history tab.

**States:**
- Loading: Timeline skeleton
- Error: "Could not load history"
- Empty: "No history yet"

**Responsive:** Full-width timeline on all sizes.

---

## Screen Relationships

```
Schedule Post → Post Confirmation → Publishing Progress → Success/Failure
Queue Management → Schedule Post / Edit
Publishing Calendar → Schedule Post / Post Detail
Bulk Schedule → Validation → Schedule Post (batch)
Auto-Publish Settings → Queue Management
Best Time Suggestions → Schedule Post
Platform/Account Selectors → Cross-Posting → Post Confirmation
Retry Failed Posts → Publishing Progress
Drafts → Post Composer / Schedule Post
Scheduled Posts List → Post Detail / Edit / Reschedule
Published Posts List → Post Analytics / Repurpose
Post Detail → Edit / Analytics / Version History
Post Analytics → Full Analytics
Delete/Archive Post → Confirmation
Approval Workflow → Post Detail / Edit
Post History Timeline → Version History
```

## Design Tokens

- **Calendar cell size:** 80px × 80px (month view)
- **Post card height:** 120px (list), 200px (grid)
- **Progress bar height:** 8px
- **Timeline dot size:** 12px
- **Timeline line width:** 2px
- **Confirmation modal width:** 480px
- **Table row height:** 56px
- **Status badge:** 24px height, 8px padding
- **Spacing:** 8px base unit
