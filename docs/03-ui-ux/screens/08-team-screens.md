# 08 - Team Screens

## 1. Team Members

**Purpose:** View and manage all team members with roles and activity.

**Layout:** Table/card view with member details, roles, and management actions.

**Key Components:**
- Member cards (avatar, name, email, role, status)
- Role badges (Admin, Editor, Viewer, Custom)
- Last active timestamp
- Assigned accounts/projects
- Activity summary
- "Invite Member" button
- Bulk actions (remove, change role)
- Filter by role/status
- Search by name/email
- Team size counter

**Navigation:** From Settings > Team or sidebar.

**States:**
- Loading: Skeleton cards
- Error: "Could not load team"
- Empty: "No team members" with invite CTA

**Responsive:** List on mobile, table on desktop.

---

## 2. Invite Members

**Purpose:** Send invitations to new team members via email.

**Layout:** Invitation form with email input, role assignment, and permission settings.

**Key Components:**
- Email input (multiple support)
- Role selector dropdown
- Custom permission checkboxes
- Account/project assignment
- Welcome message textarea
- "Send Invitations" button
- Pending invitations list
- Resend/revoke buttons
- Bulk invite via CSV upload
- Invitation link generation

**Navigation:** From Team Members "Invite" button or Settings.

**States:**
- Loading: None
- Error: "Could not send invitation" with retry
- Empty: Form with no pending invites

**Responsive:** Full-width form on all sizes.

---

## 3. Member Details

**Purpose:** Comprehensive view of a single team member's profile, activity, and permissions.

**Layout:** Two-panel: left with profile info, right with activity and permissions.

**Key Components:**
- Profile section (avatar, name, email, role)
- Activity log (posts created, edits, approvals)
- Assigned accounts list
- Permission matrix view
- Performance metrics (if applicable)
- "Edit Role" button
- "Remove Member" button
- "Deactivate" toggle
- Connected social accounts
- Login history

**Navigation:** Opens from Team Members list click.

**States:**
- Loading: Detail skeleton
- Error: "Could not load member details"
- Empty: N/A (always has member)

**Responsive:** Single column on mobile, two panels on desktop.

---

## 4. Role Management

**Purpose:** Create and manage team roles with specific permissions.

**Layout:** Roles list with permission editor and role templates.

**Key Components:**
- Role list (name, member count, permissions summary)
- Create new role button
- Role templates (Admin, Editor, Viewer, Custom)
- Permission matrix editor
- Permission categories (Content, Analytics, Settings, Billing)
- "Save Role" button
- "Delete Role" button (if no members assigned)
- Role comparison tool
- Permission descriptions

**Navigation:** From Settings > Team > Roles.

**States:**
- Loading: Roles skeleton
- Error: "Could not load roles"
- Empty: Default roles only

**Responsive:** List on mobile, grid on desktop.

---

## 5. Custom Roles

**Purpose:** Build granular custom roles with specific permission combinations.

**Layout:** Permission builder with categories, toggles, and preview.

**Key Components:**
- Role name input
- Permission categories (collapsible sections)
- Toggle switches per permission
- Permission descriptions and tooltips
- Permission preview (what this role can do)
- "Copy from existing role" option
- Member assignment preview
- Save/cancel buttons
- Role dependency warnings

**Navigation:** From Role Management "Create Custom Role".

**States:**
- Loading: Permission tree load
- Error: "Could not load permissions"
- Empty: All toggles off (new role)

**Responsive:** Full-width form, categories stack on mobile.

---

## 6. Activity Log

**Purpose:** Audit trail of all team actions across the platform.

**Layout:** Filterable table with timestamp, user, action, and details.

**Key Components:**
- Activity table (timestamp, user, action, details, IP)
- Filter by user, action type, date range
- Search by action details
- Export activity log
- Real-time activity feed toggle
- Action categories (Content, Settings, Billing, Auth)
- Detail modal per activity
- Activity frequency chart
- Suspicious activity alerts

**Navigation:** From Settings > Team > Activity Log.

**States:**
- Loading: Table skeleton
- Error: "Could not load activity log"
- Empty: "No activity recorded"

**Responsive:** Table scrolls horizontally on mobile.

---

## 7. Approvals

**Purpose:** Manage content approval workflows with team assignments.

**Layout:** Approval queue with pending items, assignees, and approval actions.

**Key Components:**
- Approval queue (pending posts list)
- Assignee assignment per post
- Approve/Reject buttons with comment
- Request changes flow
- Approval history timeline
- Auto-approval rules
- Approval SLA tracking
- Notification settings for approvals
- Bulk approve/reject
- Approval statistics (avg time, approval rate)

**Navigation:** From Dashboard > Approvals or Settings > Approvals.

**States:**
- Loading: Queue skeleton
- Error: "Could not load approvals"
- Empty: "No pending approvals"

**Responsive:** Card layout on all sizes.

---

## 8. Client Management

**Purpose:** Manage client accounts, access, and billing for agencies.

**Layout:** Client list with details, billing, and access management.

**Key Components:**
- Client cards (name, status, accounts, billing)
- "Add Client" button
- Client onboarding wizard
- Account assignment per client
- Team member assignment per client
- Billing summary per client
- Client portal access toggle
- Client-specific branding
- Activity log per client
- Client health score

**Navigation:** From Settings > Clients or sidebar (agency view).

**States:**
- Loading: Client list skeleton
- Error: "Could not load clients"
- Empty: "No clients" with onboarding

**Responsive:** List on mobile, grid on desktop.

---

## 9. Client Portal

**Purpose:** Branded portal for clients to view their content and analytics.

**Layout:** Client-facing dashboard with limited features and branding.

**Key Components:**
- Branded header (client logo, colors)
- Content calendar view (read-only)
- Analytics dashboard (client's accounts)
- Approval workflow (client approval)
- Comment/feedback system
- Report download section
- Support/contact form
- Activity notifications
- Custom domain/URL option

**Navigation:** Accessed via unique client URL or invitation email.

**States:**
- Loading: Portal init
- Error: "Portal unavailable"
- Empty: "Welcome" onboarding

**Responsive:** Full responsive design for client devices.

---

## 10. Permissions Matrix

**Purpose:** Visual overview of all team members' permissions across features.

**Layout:** Matrix table with members as columns, permissions as rows.

**Key Components:**
- Permission matrix grid
- Member columns with avatars
- Permission rows grouped by category
- Check/cross indicators per cell
- Role badges per member
- Bulk edit permissions
- Export matrix as PDF/CSV
- Filter by permission type
- Compare two members
- Print-friendly view

**Navigation:** From Settings > Team > Permissions.

**States:**
- Loading: Matrix skeleton
- Error: "Could not load permissions"
- Empty: No members with custom permissions

**Responsive:** Horizontal scroll on mobile, full matrix on desktop.

---

## Screen Relationships

```
Team Members
├── Invite Members
├── Member Details
│   ├── Edit Role
│   └── Activity Log
├── Role Management
│   └── Custom Roles (Permission Builder)
├── Activity Log
├── Approvals
├── Client Management
│   └── Client Portal
└── Permissions Matrix
```

## Design Tokens

- **Member avatar size:** 40px (list), 64px (detail)
- **Role badge height:** 24px
- **Permission toggle width:** 44px
- **Matrix cell size:** 48px × 48px
- **Approval card height:** 120px
- **Client card height:** 100px
- **Activity row height:** 48px
- **Font sizes:** 12px (label), 14px (body), 16px (heading)
- **Spacing:** 8px base unit
