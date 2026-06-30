# 10 - Settings Screens

## 1. General Settings

**Purpose:** Core application settings for the workspace/organization.

**Layout:** Tabbed settings interface with general options.

**Key Components:**
- Workspace name input
- Workspace logo upload
- Default timezone selector
- Language preference
- Date format selector
- Time format (12h/24h)
- Default content type
- Auto-save toggle
- Keyboard shortcuts toggle
- "Save Changes" button

**Navigation:** From Settings > General or sidebar.

**States:**
- Loading: Settings form skeleton
- Error: "Could not load settings"
- Empty: Default values shown

**Responsive:** Form stacks vertically on mobile.

---

## 2. Profile Settings

**Purpose:** Manage personal profile information and preferences.

**Layout:** Profile form with avatar, personal info, and preferences.

**Key Components:**
- Avatar upload with crop tool
- Display name input
- Email input (with verification status)
- Phone number input
- Bio/about textarea
- Social links inputs
- Timezone preference
- Notification preferences link
- "Save Profile" button
- "Change Password" link
- "Delete Account" link

**Navigation:** From Settings > Profile or top-right user menu.

**States:**
- Loading: Profile form skeleton
- Error: "Could not load profile"
- Empty: N/A (always has profile)

**Responsive:** Form stacks vertically on mobile.

---

## 3. Notification Settings

**Purpose:** Configure which notifications to receive and how.

**Layout:** Notification categories with toggle switches and delivery method selectors.

**Key Components:**
- Notification categories (Content, Analytics, Team, Billing, System)
- Toggle switches per notification type
- Delivery method (In-app, Email, Push, SMS)
- Quiet hours settings
- Frequency digest options (real-time, daily, weekly)
- Notification sound toggle
- "Save Preferences" button
- Test notification button
- Mark all as read

**Navigation:** From Settings > Notifications.

**States:**
- Loading: Settings skeleton
- Error: "Could not load notification settings"
- Empty: Default (all enabled) shown

**Responsive:** Categories stack vertically on mobile.

---

## 4. Email Settings

**Purpose:** Manage email preferences and subscription.

**Layout:** Email settings with subscription options and templates.

**Key Components:**
- Primary email display
- Email verification status
- Marketing emails toggle
- Product updates toggle
- Weekly digest toggle
- Security alerts toggle (always on)
- Email signature editor
- "Update Email" button
- "Unsubscribe from All" link
- Email history log

**Navigation:** From Settings > Email or Profile.

**States:**
- Loading: Email settings skeleton
- Error: "Could not load email settings"
- Empty: Default values

**Responsive:** Form stacks vertically on mobile.

---

## 5. Security Settings

**Purpose:** Manage account security, passwords, and authentication.

**Layout:** Security dashboard with password, 2FA, and session management.

**Key Components:**
- Password change form (current, new, confirm)
- Two-factor authentication setup
- 2FA method selector (authenticator, SMS, email)
- Recovery codes display/download
- Active sessions list
- "Revoke All Sessions" button
- Login notifications toggle
- API key management link
- IP whitelist option
- Security audit log

**Navigation:** From Settings > Security.

**States:**
- Loading: Security settings skeleton
- Error: "Could not load security settings"
- Empty: Default security state

**Responsive:** Sections stack vertically on mobile.

---

## 6. API Keys

**Purpose:** Generate and manage API keys for programmatic access.

**Layout:** API keys table with create/revoke options.

**Key Components:**
- API keys table (name, prefix, created, last used, scopes)
- "Generate New Key" button
- Key creation form (name, scopes, expiration)
- Key display (shown once on creation)
- Copy key button
- Revoke key button
- Usage log per key
- Rate limit status
- API documentation link

**Navigation:** From Settings > API Keys or Developer settings.

**States:**
- Loading: Table skeleton
- Error: "Could not load API keys"
- Empty: "No API keys" with CTA

**Responsive:** Table scrolls horizontally on mobile.

---

## 7. Webhooks

**Purpose:** Configure webhook endpoints for real-time event notifications.

**Layout:** Webhook configuration with endpoint management.

**Key Components:**
- Webhook endpoints list
- "Add Webhook" button
- Endpoint URL input
- Event type checkboxes
- Secret key generation
- Test webhook button
- Delivery log (recent payloads)
- Enable/disable toggle
- Retry policy settings
- Payload format preview

**Navigation:** From Settings > Webhooks.

**States:**
- Loading: Webhooks skeleton
- Error: "Could not load webhooks"
- Empty: "No webhooks configured"

**Responsive:** List on all sizes.

---

## 8. Integrations

**Purpose:** Connect third-party tools and services.

**Layout:** Integration marketplace with installed/available integrations.

**Key Components:**
- Integration cards (logo, name, description, status)
- "Connect" or "Disconnect" buttons per integration
- Installed integrations section
- Available integrations section
- Integration categories (Analytics, CRM, Design, Project Management)
- Configuration modal per integration
- Usage analytics per integration
- "Request Integration" link

**Navigation:** From Settings > Integrations.

**States:**
- Loading: Integration cards skeleton
- Error: "Could not load integrations"
- Empty: "No integrations installed"

**Responsive:** 2 columns on mobile, 3-4 on desktop.

---

## 9. Data Export

**Purpose:** Export all account data for compliance or migration.

**Layout:** Export options with format selection and progress tracking.

**Key Components:**
- Export type selector (All data, Posts, Analytics, Media, Team)
- Format selector (JSON, CSV, PDF)
- Date range selector
- "Start Export" button
- Export history list
- Progress indicator for active exports
- Download button per export
- Export expiration (7 days)
- GDPR/CCPA compliance badges
- Data retention info

**Navigation:** From Settings > Data Export or Privacy.

**States:**
- Loading: Export options
- Error: "Could not initiate export"
- Empty: No previous exports

**Responsive:** Form stacks vertically on mobile.

---

## 10. Account Deletion

**Purpose:** Permanently delete account with data retention warnings.

**Layout:** Multi-step deletion wizard with confirmations.

**Key Components:**
- Warning message about permanent deletion
- Data that will be lost (list)
- Alternative options (pause, downgrade)
- Confirmation input (type workspace name)
- Final "Delete Account" button
- Data download option before deletion
- Team notification toggle
- 30-day grace period info
- "Contact Support" link

**Navigation:** From Settings > Account > Delete.

**States:**
- Loading: None
- Error: "Could not process deletion" with retry
- Empty: N/A

**Responsive:** Full-width warning on all sizes.

---

## 11. Workspace Settings

**Purpose:** Manage workspace-level configurations and branding.

**Layout:** Workspace configuration form with branding options.

**Key Components:**
- Workspace name input
- Workspace URL/slug input
- Logo upload
- Brand colors picker
- Default language
- Workspace description
- Visibility settings (public/private)
- Transfer ownership option
- Delete workspace option
- Workspace statistics

**Navigation:** From Settings > Workspace.

**States:**
- Loading: Settings skeleton
- Error: "Could not load workspace settings"
- Empty: Default values

**Responsive:** Form stacks vertically on mobile.

---

## 12. Organization Settings

**Purpose:** Manage organization-level settings for multi-workspace accounts.

**Layout:** Organization configuration with workspace management.

**Key Components:**
- Organization name and logo
- Billing settings (organization-level)
- Workspace list and management
- Member management (org-wide)
- Security policies (org-wide)
- SSO/SAML configuration
- Audit log
- Data residency settings
- Compliance settings

**Navigation:** From Settings > Organization (admin only).

**States:**
- Loading: Org settings skeleton
- Error: "Could not load organization settings"
- Empty: Default org setup

**Responsive:** Tabbed interface, stacks on mobile.

---

## 13. Brand Kit

**Purpose:** Manage brand assets for consistent content creation.

**Layout:** Brand kit editor with sections for logos, colors, fonts, and tone.

**Key Components:**
- Logo upload and management
- Color palette editor (primary, secondary, accent colors)
- Font selections (primary, secondary, accent)
- Brand tone settings
- Default hashtags and mentions
- Brand voice guidelines text
- Template library
- Brand usage analytics
- Export brand kit button

**Navigation:** From Settings > Brand Kit or AI Studio.

**States:**
- Loading: Brand kit skeleton
- Error: "Could not load brand kit"
- Empty: Setup wizard prompt

**Responsive:** Sections stack vertically on mobile.

---

## 14. Content Defaults

**Purpose:** Set default values for content creation across the platform.

**Layout:** Content default settings form.

**Key Components:**
- Default posting platform
- Default content type
- Default hashtag set
- Default mentions
- Auto-UTM parameters toggle
- Default link shortener
- Content approval requirements
- Default content language
- Auto-save drafts toggle
- Character count warnings toggle

**Navigation:** From Settings > Content Defaults.

**States:**
- Loading: Settings skeleton
- Error: "Could not load defaults"
- Empty: Default values shown

**Responsive:** Form stacks vertically on mobile.

---

## 15. Advanced Settings

**Purpose:** Technical and advanced configuration options.

**Layout:** Advanced settings with developer options and experimental features.

**Key Components:**
- Developer mode toggle
- Beta features opt-in
- Experimental AI features toggle
- Debug logging toggle
- Cache management
- Session management
- OAuth application management
- Custom CSS injection (Enterprise)
- API rate limit display
- System information display
- "Reset All Settings" button

**Navigation:** From Settings > Advanced.

**States:**
- Loading: Advanced settings skeleton
- Error: "Could not load advanced settings"
- Empty: Default values

**Responsive:** Sections stack vertically on mobile.

---

## Screen Relationships

```
Settings
├── General Settings
├── Profile Settings → Email Settings / Security Settings
├── Notification Settings
├── Email Settings
├── Security Settings → API Keys / Webhooks
├── API Keys
├── Webhooks
├── Integrations
├── Data Export
├── Account Deletion
├── Workspace Settings
├── Organization Settings
├── Brand Kit
├── Content Defaults
└── Advanced Settings
```

## Design Tokens

- **Settings section max-width:** 640px
- **Form field height:** 40px
- **Toggle width:** 44px
- **Avatar upload size:** 96px
- **Color swatch size:** 32px
- **API key display font:** monospace 14px
- **Warning banner padding:** 16px
- **Font sizes:** 14px (body), 16px (subheading), 20px (heading)
- **Spacing:** 8px base unit
