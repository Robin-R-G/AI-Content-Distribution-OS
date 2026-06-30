# 06 - Social Accounts Screens

## 1. Connected Accounts List

**Purpose:** View and manage all connected social media accounts.

**Layout:** Table/card view with account details, health status, and management actions.

**Key Components:**
- Account cards (platform icon, account name, handle, avatar)
- Connection status indicator (green/red/yellow)
- Last sync timestamp
- Token expiration warning
- Platform-specific metrics preview
- "Connect Account" button
- Bulk disconnect option
- Filter by platform/status
- Search by account name

**Navigation:** Accessible from Settings > Social Accounts or sidebar.

**States:**
- Loading: Skeleton cards
- Error: "Could not load accounts"
- Empty: "No accounts connected" with onboarding

**Responsive:** List on mobile, grid on desktop.

---

## 2. Connect Account (OAuth Flow)

**Purpose:** Guide user through platform OAuth authentication to connect a social account.

**Layout:** Step-by-step wizard with platform selection, authorization, and confirmation.

**Key Components:**
- Platform selector grid (Twitter, Instagram, LinkedIn, etc.)
- "Connect" button per platform
- OAuth popup/redirect flow
- Authorization status indicator
- Permission scope display
- "Authorize" confirmation
- Success/failure message
- "Add Another Account" option
- Troubleshooting tips

**Navigation:** Opens from Connected Accounts "Connect" button.

**States:**
- Loading: OAuth redirect in progress
- Error: "Authorization failed" with retry
- Empty: Platform selection step

**Responsive:** Full-screen wizard on mobile, centered modal on desktop.

---

## 3. Account Details

**Purpose:** Comprehensive view of a single connected account with all metadata.

**Layout:** Two-panel layout: left with account info, right with metrics and settings.

**Key Components:**
- Account avatar and name
- Platform and handle
- Connection date
- Token status and expiration
- Permission scopes
- Follower count
- Last 5 posts preview
- Activity log
- Settings panel
- Disconnect button

**Navigation:** Opens from Connected Accounts list click.

**States:**
- Loading: Detail skeleton
- Error: "Could not load account details"
- Empty: N/A (always has account)

**Responsive:** Single column on mobile, two panels on desktop.

---

## 4. Account Health

**Purpose:** Monitor connection health, token status, and potential issues.

**Layout:** Health dashboard with status indicators, warnings, and diagnostics.

**Key Components:**
- Overall health score (Good, Warning, Critical)
- Token status (Valid, Expiring, Expired)
- API rate limit status
- Last successful sync
- Error log (recent failures)
- "Test Connection" button
- "Reconnect" button
- Health history chart
- Alert notifications

**Navigation:** Accessible from account details or accounts list health column.

**States:**
- Loading: Health check spinner
- Error: "Health check failed"
- Empty: "Health data pending"

**Responsive:** Compact status on mobile, full dashboard on desktop.

---

## 5. Token Status

**Purpose:** Detailed view of authentication token status and expiration.

**Layout:** Token info card with status, expiration, and renewal options.

**Key Components:**
- Token type (OAuth, API key)
- Status badge (Active, Expiring Soon, Expired)
- Expiration date/time
- Time until expiration
- Last refreshed
- Permissions granted
- "Refresh Token" button
- "Renew Authorization" button
- Token history log

**Navigation:** From account details > Security tab.

**States:**
- Loading: Token info skeleton
- Error: "Could not check token"
- Empty: N/A

**Responsive:** Compact card on all sizes.

---

## 6. Disconnect Account

**Purpose:** Remove a connected social account with confirmation and data retention options.

**Layout:** Confirmation modal with warning and options.

**Key Components:**
- Warning message about disconnection
- Impact preview (data will stop syncing)
- "Keep historical data" toggle
- "Notify team" checkbox
- Confirmation input
- "Cancel" and "Disconnect" buttons
- Reconnection instructions

**Navigation:** Opens from account details or list actions.

**States:**
- Loading: None
- Error: "Could not disconnect" with retry
- Empty: N/A

**Responsive:** Centered modal on all sizes.

---

## 7. Permissions

**Purpose:** View and manage OAuth permissions/scopes for connected accounts.

**Layout:** Permissions list with toggle controls and descriptions.

**Key Components:**
- Permission list (Read, Write, Delete, Analytics, etc.)
- Current status per permission (granted/denied)
- Toggle to request additional permissions
- Permission descriptions
- "Update Permissions" button
- Re-authorization flow
- Platform-specific permission notes

**Navigation:** From account details > Permissions tab.

**States:**
- Loading: Permissions skeleton
- Error: "Could not load permissions"
- Empty: "No permissions configured"

**Responsive:** List view on all sizes.

---

## 8. Default Settings

**Purpose:** Configure default posting settings for each connected account.

**Layout:** Form with default options per account.

**Key Components:**
- Default hashtags input
- Default mentions input
- Default content type (image, video, text)
- Auto-add UTM parameters toggle
- Default link shortener setting
- Auto-pilot settings
- Content approval requirements
- Timezone setting
- "Save Defaults" button

**Navigation:** From account details > Settings tab or Settings > Defaults.

**States:**
- Loading: Settings form skeleton
- Error: "Could not load settings"
- Empty: Default values shown

**Responsive:** Form stacks vertically on mobile.

---

## 9. Account Groups

**Purpose:** Organize social accounts into logical groups (e.g., "Client A", "Personal").

**Layout:** Group management with list of groups and accounts within each.

**Key Components:**
- Group list (name, account count, color)
- Create new group button
- Group editor (name, color, description)
- Account assignment (drag or checkbox)
- Group actions (edit, delete, share)
- Default group option
- Group analytics view

**Navigation:** From Settings > Account Groups or Accounts list.

**States:**
- Loading: Group list skeleton
- Error: "Could not load groups"
- Empty: "No groups created" with CTA

**Responsive:** List on mobile, grid on desktop.

---

## 10. Account Comparison

**Purpose:** Compare metrics across multiple connected accounts side-by-side.

**Layout:** Comparison table with accounts as columns and metrics as rows.

**Key Components:**
- Account selector (add/remove columns)
- Metric rows (followers, engagement, reach, growth)
- Comparative bar charts
- Ranking indicators
- "Best performer" badges
- Export comparison button
- Date range selector
- Platform filter

**Navigation:** From Analytics > Account Comparison or Accounts list.

**States:**
- Loading: Table skeleton
- Error: "Could not load comparison"
- Empty: "Select accounts to compare"

**Responsive:** Horizontal scroll on mobile, full table on desktop.

---

## 11. Reconnect

**Purpose:** Re-authenticate a disconnected or expired account connection.

**Layout:** Reconnection wizard similar to initial OAuth flow.

**Key Components:**
- Connection status explanation
- "Reconnect" button
- OAuth flow (same as initial connect)
- Data preservation options
- Reconnection history
- "Test Connection" after reconnection

**Navigation:** Opens from account health warning or disconnected status.

**States:**
- Loading: OAuth redirect
- Error: "Reconnection failed" with retry
- Empty: N/A

**Responsive:** Same as OAuth flow.

---

## 12. Analytics Summary (per account)

**Purpose:** Quick analytics snapshot for a specific connected account.

**Layout:** Compact card with key metrics and sparklines.

**Key Components:**
- Follower count and growth
- Engagement rate
- Last post metrics
- 7-day trend sparkline
- "View Full Analytics" link
- Platform-specific metrics

**Navigation:** From account details or accounts list hover.

**States:**
- Loading: Skeleton metrics
- Error: "Analytics unavailable"
- Empty: "Not enough data"

**Responsive:** Compact card on all sizes.

---

## 13. Platform Settings

**Purpose:** Platform-specific settings and configurations for connected accounts.

**Layout:** Tabbed interface per platform with platform-unique settings.

**Key Components:**
- Platform tabs
- Twitter: thread settings, quote tweet permissions
- Instagram: story settings, reel settings, shopping tags
- LinkedIn: article settings, company page options
- Facebook: page settings, group posting options
- Platform API version display
- Platform-specific feature toggles

**Navigation:** From account details > Platform Settings.

**States:**
- Loading: Settings skeleton
- Error: "Could not load platform settings"
- Empty: Default settings shown

**Responsive:** Tabs scroll horizontally, content stacks.

---

## 14. Webhook Config

**Purpose:** Configure webhooks for real-time platform events (mentions, messages, etc.).

**Layout:** Webhook configuration form with endpoint setup and event selection.

**Key Components:**
- Webhook URL input
- Secret key display/regenerate
- Event type checkboxes (mentions, messages, comments, etc.)
- Test webhook button
- Webhook log (recent deliveries)
- Enable/disable toggle
- Payload format preview
- Retry policy settings

**Navigation:** From Settings > Webhooks or account details.

**States:**
- Loading: Config skeleton
- Error: "Could not load webhook config"
- Empty: "No webhooks configured"

**Responsive:** Form stacks vertically on mobile.

---

## 15. API Key Management

**Purpose:** Manage API keys for programmatic access to social account data.

**Layout:** API keys list with create/revoke options.

**Key Components:**
- API keys table (name, prefix, created, last used, scopes)
- Create new key button
- Key creation form (name, scopes, expiration)
- Key display (shown once on creation)
- Copy key button
- Revoke key button
- Usage log per key
- Rate limit status

**Navigation:** From Settings > API Keys or developer settings.

**States:**
- Loading: Table skeleton
- Error: "Could not load API keys"
- Empty: "No API keys" with CTA

**Responsive:** Table scrolls horizontally on mobile.

---

## Screen Relationships

```
Connected Accounts List
├── Connect Account (OAuth Flow)
├── Account Details
│   ├── Account Health
│   ├── Token Status
│   ├── Permissions
│   ├── Default Settings
│   ├── Platform Settings
│   └── Analytics Summary
├── Disconnect Account
├── Reconnect
├── Account Groups
├── Account Comparison
├── Webhook Config
└── API Key Management
```

## Design Tokens

- **Account card height:** 80px
- **Health indicator size:** 12px
- **Platform icon size:** 32px
- **Avatar size:** 48px (list), 64px (detail)
- **Status badge height:** 24px
- **Permission toggle width:** 44px
- **API key prefix font:** monospace 14px
- **Table row height:** 56px
- **Spacing:** 8px base unit
