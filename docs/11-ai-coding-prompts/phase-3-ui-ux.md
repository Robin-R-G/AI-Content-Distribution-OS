# Phase 3: UI/UX Flutter Prompts

## 3.1 Generate Flutter Project Structure

**Phase:** 3-UI/UX
**Output:** `lib/` directory structure
**Inputs:** Architecture, design system

```
Generate Flutter project structure for Social Media AI.

## Project Structure
```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── app_config.dart
│   ├── routes.dart
│   ├── theme.dart
│   └── constants.dart
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── interceptors.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── utils/
│       ├── extensions.dart
│       ├── formatters.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   ├── dashboard/
│   │   └── [same structure]
│   ├── posts/
│   │   └── [same structure]
│   ├── analytics/
│   │   └── [same structure]
│   ├── social_accounts/
│   │   └── [same structure]
│   ├── ai_generation/
│   │   └── [same structure]
│   ├── team/
│   │   └── [same structure]
│   ├── settings/
│   │   └── [same structure]
│   └── notifications/
│       └── [same structure]
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── inputs/
│   │   ├── modals/
│   │   └── navigation/
│   ├── models/
│   └── services/
└── injection.dart
```

## Key Files to Generate

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ProviderScope(child: SocialMediaAIApp()));
}
```

### app.dart
Generate MaterialApp with theme, routing, and providers.

### injection.dart
Generate dependency injection setup using Riverpod.

Generate all core files with proper patterns, error handling, and documentation.
```

**Expected Output:** Complete Flutter project structure with 100+ files following clean architecture.

---

## 3.2 Generate Design System

**Phase:** 3-UI/UX
**Output:** `lib/config/theme.dart` + design tokens
**Inputs:** Brand guidelines, accessibility requirements

```
Generate complete design system for Social Media AI Flutter app.

## Color Palette
```dart
class AppColors {
  // Primary
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);
  
  // Secondary
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF059669);
  
  // Neutral
  static const white = Color(0xFFFFFFFF);
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
  static const black = Color(0xFF000000);
  
  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Platform colors
  static const instagram = Color(0xFFE4405F);
  static const twitter = Color(0xFF1DA1F2);
  static const facebook = Color(0xFF1877F2);
  static const linkedin = Color(0xFF0A66C2);
  static const tiktok = Color(0xFF000000);
  static const youtube = Color(0xFFFF0000);
}
```

## Typography
```dart
class AppTypography {
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );
  // ... complete typography scale
}
```

## Spacing
```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

## Border Radius
```dart
class AppRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const full = 999.0;
}
```

## Shadows
Generate elevation system with shadows for light and dark themes.

## Component Themes
Generate ThemeData with:
- ColorScheme
- AppBarTheme
- CardTheme
- ElevatedButtonTheme
- InputDecorationTheme
- BottomNavigationBarTheme
- DrawerTheme
- DialogTheme
- SnackBarTheme

## Dark Theme
Generate complete dark theme with proper contrast ratios.

Generate complete theme file with all design tokens and component themes.
```

**Expected Output:** 15-20 page design system with colors, typography, spacing, and component themes.

---

## 3.3 Generate Auth Screens

**Phase:** 3-UI/UX
**Output:** `lib/features/auth/presentation/pages/`
**Inputs:** Design system, auth flow

```
Generate complete authentication screens for Social Media AI.

## Screens to Generate

### 1. Splash Screen
- App logo animation
- Loading indicator
- Auto-navigation logic

### 2. Onboarding Screen (3 pages)
- Page 1: Value proposition with illustration
- Page 2: Feature highlights
- Page 3: Get started CTA
- Page indicators
- Skip button

### 3. Login Screen
- Email/password fields
- Social login buttons (Google, Apple)
- Forgot password link
- Sign up link
- Form validation
- Loading states
- Error handling

### 4. Register Screen
- Full name field
- Email field
- Password field with strength indicator
- Confirm password field
- Terms acceptance checkbox
- Social signup buttons
- Already have account link

### 5. Forgot Password Screen
- Email input
- Send reset link button
- Success message
- Back to login link

### 6. Reset Password Screen
- New password field
- Confirm password field
- Reset button
- Success animation

### 7. Email Verification Screen
- Verification sent message
- Resend email button
- Change email option
- Auto-check for verification

### 8. 2FA Setup Screen
- QR code display
- Manual entry code
- Verification input
- Backup codes display

### 9. 2FA Verification Screen
- 6-digit code input
- Remember device option
- Use backup code link

## Widget Components to Generate
- SocialLoginButton
- PasswordStrengthIndicator
- VerificationCodeInput
- AuthHeader (logo + title)
- AuthFooter (links)

Generate complete Flutter widgets with:
- Proper state management (Riverpod)
- Form validation
- Error handling
- Loading states
- Responsive layout
- Accessibility support
- Dark mode support
```

**Expected Output:** 10+ auth screens with complete Flutter code, state management, and form handling.

---

## 3.4 Generate Dashboard Screens

**Phase:** 3-UI/UX
**Output:** `lib/features/dashboard/presentation/pages/`
**Inputs:** Design system, analytics requirements

```
Generate complete dashboard screens for Social Media AI.

## Screens to Generate

### 1. Main Dashboard
- Welcome header with user name
- Quick stats cards (posts, followers, engagement)
- Recent posts preview
- Upcoming scheduled posts
- AI suggestions widget
- Platform connection status
- Quick actions FAB

### 2. Content Calendar
- Monthly/weekly/daily views
- Drag-and-drop post scheduling
- Color-coded by platform
- Post status indicators
- Create post modal
- Filter by platform/status

### 3. Post Detail
- Full post preview
- Platform-specific previews
- Edit/delete actions
- Analytics preview
- Comments section
- Version history

### 4. Create Post
- Rich text editor
- Media upload area
- Platform selector
- Schedule picker
- AI assist button
- Hashtag suggestions
- Character count per platform
- Preview panel

### 5. Analytics Overview
- Key metrics cards
- Engagement chart (line)
- Top posts table
- Audience demographics
- Platform comparison
- Time range selector

### 6. Social Accounts
- Connected accounts list
- Account health indicators
- Reconnect buttons
- Platform stats
- Disconnect option
- Add account button

### 7. AI Generation
- Content type selector
- Input prompt area
- Generation options
- History list
- Save to library
- Rate generation

### 8. Content Library
- Grid/list view toggle
- Search and filter
- Folder organization
- Upload area
- Preview modal
- Bulk actions

## Widget Components
- StatCard
- PlatformIcon
- PostPreview
- EngagementChart
- QuickActions
- NotificationBadge

Generate complete Flutter widgets with:
- Riverpod providers
- Responsive layouts
- Pull-to-refresh
- Infinite scrolling
- Skeleton loading
- Empty states
- Error states
- Accessibility
```

**Expected Output:** 8+ dashboard screens with charts, lists, and interactive components.

---

## 3.5 Generate Content Creation Screens

**Phase:** 3-UI/UX
**Output:** `lib/features/posts/presentation/`
**Inputs:** Design system, AI features

```
Generate content creation screens for Social Media AI.

## Screens to Generate

### 1. Post Composer
- Multi-platform content tabs
- Rich text formatting
- Character counter per platform
- Media attachment area
- AI assist panel
- Hashtag suggestions
- Emoji picker
- Schedule/publish buttons

### 2. AI Content Assistant
- Prompt input area
- Content type selector
- Tone/voice options
- Generated content cards
- Regenerate button
- Edit and use button
- History list

### 3. Media Picker
- Gallery grid view
- Camera capture
- Stock photo search
- AI image generation
- Image editor
- Crop and filter tools

### 4. Hashtag Research
- Trending hashtags
- Platform-specific suggestions
- Saved hashtag groups
- Performance metrics
- Copy to clipboard
- Add to post

### 5. Content Templates
- Template gallery
- Category filters
- Preview modal
- Customize template
- Save as template
- Share template

### 6. Post Preview
- Platform-specific previews
- Desktop/mobile preview
- Story/reel preview
- Link preview card
- Hashtag display

### 7. Schedule Post
- Date/time picker
- Time zone selector
- Optimal time suggestions
- Recurring schedule
- Queue position
- Confirmation

### 8. Bulk Upload
- CSV upload area
- Template download
- Validation results
- Preview table
- Schedule all button
- Error handling

## Widget Components
- ContentEditor
- PlatformSelector
- MediaGrid
- HashtagChip
- CharacterCounter
- SchedulePicker
- PreviewCard

Generate complete Flutter widgets with:
- Multi-platform support
- AI integration
- Media handling
- Drag-and-drop
- Real-time preview
- Offline support
```

**Expected Output:** 8+ content creation screens with rich editing and AI features.

---

## 3.6 Generate Analytics Screens

**Phase:** 3-UI/UX
**Output:** `lib/features/analytics/presentation/`
**Inputs:** Design system, analytics requirements

```
Generate analytics screens for Social Media AI.

## Screens to Generate

### 1. Analytics Dashboard
- KPI cards (followers, engagement, reach, impressions)
- Engagement trend chart (line)
- Platform comparison (bar)
- Top performing posts (table)
- Audience demographics (pie)
- Time period selector

### 2. Post Analytics
- Individual post metrics
- Engagement breakdown
- Audience reached
- Link clicks
- Saves and shares
- Comments analysis

### 3. Audience Insights
- Demographics (age, gender, location)
- Active hours heatmap
- Interest categories
- Follower growth chart
- Audience overlap

### 4. Platform Analytics
- Platform-specific metrics
- Content type performance
- Best posting times
- Hashtag performance
- Competitor comparison

### 5. Growth Analytics
- Follower growth timeline
- Engagement rate trends
- Reach and impressions
- Growth milestones
- Projected growth

### 6. Competitor Analytics
- Competitor list
- Performance comparison
- Content comparison
- Growth comparison
- Benchmark metrics

### 7. Custom Reports
- Report builder
- Metric selector
- Date range
- Platform filter
- Export options (PDF, CSV)

### 8. Export Center
- Report templates
- Schedule exports
- Export history
- Download files

## Chart Widgets to Generate
- LineChart (engagement trends)
- BarChart (platform comparison)
- PieChart (demographics)
- HeatMap (active hours)
- AreaChart (growth)
- DonutChart (content mix)

Generate complete Flutter widgets with:
- Interactive charts (fl_chart)
- Real-time updates
- Export functionality
- Responsive layouts
- Skeleton loading
```

**Expected Output:** 8+ analytics screens with interactive charts and data visualization.

---

## 3.7 Generate Settings Screens

**Phase:** 3-UI/UX
**Output:** `lib/features/settings/presentation/`
**Inputs:** Design system, user preferences

```
Generate settings screens for Social Media AI.

## Screens to Generate

### 1. Settings Home
- Profile section
- Account settings
- Notification preferences
- Appearance settings
- Billing settings
- Help and support
- About section

### 2. Profile Settings
- Avatar upload
- Display name
- Bio
- Website
- Time zone
- Language preference
- Save button

### 3. Account Settings
- Email address (change)
- Password (change)
- Two-factor authentication
- Connected accounts
- Delete account
- Export data

### 4. Notification Settings
- Email notifications toggle
- Push notifications toggle
- Notification types:
  - Post published
  - Post failed
  - Team mentions
  - Analytics reports
  - Billing alerts
  - Product updates

### 5. Appearance Settings
- Theme selector (light/dark/system)
- Accent color picker
- Compact mode toggle
- Font size selector
- Sidebar position

### 6. Billing Settings
- Current plan display
- Usage statistics
- Upgrade/downgrade
- Payment method
- Invoice history
- Cancel subscription

### 7. Team Settings
- Member list
- Invite member
- Role management
- Pending invitations
- Remove member

### 8. API Settings
- API keys list
- Generate new key
- Revoke key
- Usage statistics
- Documentation link

### 9. Privacy Settings
- Profile visibility
- Activity status
- Data sharing preferences
- Cookie preferences

### 10. Help & Support
- Help center link
- Contact support
- Feature requests
- Bug report
- Status page
- Documentation

## Widget Components
- SettingsTile
- ToggleSwitch
- AvatarPicker
- ColorPicker
- ThemeSelector
- PlanCard

Generate complete Flutter widgets with:
- Form handling
- Validation
- State persistence
- Responsive layout
- Accessibility
```

**Expected Output:** 10+ settings screens with complete form handling and preferences.

---

## 3.8 Generate Responsive Layouts

**Phase:** 3-UI/UX
**Output:** `lib/shared/widgets/layout/`
**Inputs:** Design system, screen requirements

```
Generate responsive layout system for Social Media AI.

## Layout Components to Generate

### 1. ResponsiveLayout
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  
  // Breakpoints:
  // Mobile: < 600px
  // Tablet: 600-1024px
  // Desktop: > 1024px
}
```

### 2. AppShell
- Sidebar navigation (desktop)
- Bottom navigation (mobile)
- Top app bar
- Content area
- Floating action button

### 3. Sidebar
- Collapsible design
- Navigation items
- Workspace selector
- User avatar
- Collapse/expand button

### 4. BottomNavigation
- 5 tabs max
- Icons with labels
- Badge support
- Active indicator

### 5. TopBar
- Page title
- Search button
- Notification bell
- Profile avatar
- Menu button (mobile)

### 6. ContentGrid
- Responsive grid
- Dynamic columns
- Gap spacing
- Wrap support

### 7. SplitView
- Resizable panels
- Collapse support
- Drag handle
- Mobile: stacked

### 8. TabBar
- Scrollable tabs
- Indicator animation
- Badge support
- Overflow menu

### 9. ModalBottomSheet
- Drag to dismiss
- Scrollable content
- Action buttons
- Keyboard handling

### 10. ResponsiveContainer
- Max width constraint
- Center alignment
- Padding responsive

## Breakpoint System
```dart
class Breakpoints {
  static const mobile = 600;
  static const tablet = 1024;
  static const desktop = 1440;
  
  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < mobile;
    
  static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= mobile &&
    MediaQuery.of(context).size.width < tablet;
    
  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= tablet;
}
```

## Navigation Patterns
- Mobile: Bottom nav + stack navigation
- Tablet: Collapsible sidebar + stack
- Desktop: Persistent sidebar + nested routes

Generate complete responsive layout system with all components.
```

**Expected Output:** 10+ responsive layout components supporting mobile, tablet, and desktop.
