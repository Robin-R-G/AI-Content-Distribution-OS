# Design System — AI Content Distribution OS

## Overview

A unified design system for Flutter web, mobile, and desktop. Tokens and components adapt to platform via `ThemeData` and responsive layout utilities.

---

## Color Palette

### Brand Colors

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#6366F1` | Primary buttons, links, active states |
| `primary-dark` | `#4F46E5` | Hover/pressed states |
| `primary-light` | `#A5B4FC` | Toggles, badges, highlights |
| `secondary` | `#0EA5E9` | Secondary actions, accents |
| `accent` | `#F59E0B` | Warnings, highlights, CTAs |

### Semantic Colors

| Token | Value | Usage |
|-------|-------|-------|
| `success` | `#10B981` | Success states, confirmations |
| `warning` | `#F59E0B` | Warning states, alerts |
| `error` | `#EF4444` | Errors, destructive actions |
| `info` | `#3B82F6` | Informational messages |

### Neutrals

| Token | Light | Dark |
|-------|-------|------|
| `background` | `#FFFFFF` | `#0F172A` |
| `surface` | `#F8FAFC` | `#1E293B` |
| `surface-elevated` | `#FFFFFF` | `#334155` |
| `border` | `#E2E8F0` | `#334155` |
| `border-subtle` | `#F1F5F9` | `#1E293B` |
| `text-primary` | `#0F172A` | `#F8FAFC` |
| `text-secondary` | `#64748B` | `#94A3B8` |
| `text-tertiary` | `#94A3B8` | `#64748B` |
| `text-inverse` | `#F8FAFC` | `#0F172A` |

### Platform Colors

| Platform | Primary Color |
|----------|--------------|
| Instagram | `#E4405F` |
| TikTok | `#000000` (with `#25F4EE` accent) |
| Twitter/X | `#1DA1F2` |
| LinkedIn | `#0A66C2` |
| Facebook | `#1877F2` |
| YouTube | `#FF0000` |
| Pinterest | `#E60023` |
| Threads | `#000000` |

---

## Typography

### Font Family

- **Primary**: Inter (Google Fonts)
- **Monospace**: JetBrains Mono (for code/data)
- **Fallback**: system-ui, -apple-system, sans-serif

### Type Scale

| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `display-lg` | 48px | 700 | 56px | Hero headings |
| `display` | 36px | 700 | 44px | Page titles |
| `heading-lg` | 30px | 600 | 38px | Section headers |
| `heading` | 24px | 600 | 32px | Card titles |
| `heading-sm` | 20px | 600 | 28px | Subsection headers |
| `body-lg` | 18px | 400 | 28px | Large body text |
| `body` | 16px | 400 | 24px | Default body |
| `body-sm` | 14px | 400 | 20px | Secondary text |
| `caption` | 12px | 400 | 16px | Labels, captions |
| `overline` | 10px | 600 | 16px | Uppercase labels |

### Responsive Type Scaling

| Breakpoint | Display | Heading | Body |
|------------|---------|---------|------|
| Mobile (< 640px) | 28px | 20px | 14px |
| Tablet (640–1024px) | 36px | 24px | 16px |
| Desktop (> 1024px) | 48px | 30px | 18px |

---

## Spacing

### Base Unit: 4px

| Token | Value |
|-------|-------|
| `space-0` | 0px |
| `space-1` | 4px |
| `space-2` | 8px |
| `space-3` | 12px |
| `space-4` | 16px |
| `space-5` | 20px |
| `space-6` | 24px |
| `space-8` | 32px |
| `space-10` | 40px |
| `space-12` | 48px |
| `space-16` | 64px |
| `space-20` | 80px |

---

## Shadows

| Token | Value |
|-------|-------|
| `shadow-xs` | `0 1px 2px rgba(0,0,0,0.05)` |
| `shadow-sm` | `0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)` |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06)` |
| `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)` |
| `shadow-xl` | `0 20px 25px rgba(0,0,0,0.1), 0 10px 10px rgba(0,0,0,0.04)` |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 4px | Badges, tags |
| `radius-md` | 8px | Buttons, inputs |
| `radius-lg` | 12px | Cards |
| `radius-xl` | 16px | Modals, sheets |
| `radius-full` | 9999px | Avatars, pills |

---

## Component Library

### Primitives

- Button (primary, secondary, ghost, destructive, icon)
- IconButton
- TextInput (text, password, search, number)
- TextArea
- Select / Dropdown
- Checkbox
- Radio
- Switch / Toggle
- Slider
- Badge
- Avatar (image, initials, icon)
- Icon (library: Phosphor Icons)
- Tooltip

### Layout

- AppShell (sidebar + topbar + content)
- Card (default, interactive, stat)
- Divider
- Spacer
- Grid (responsive: 1–12 columns)
- Stack (horizontal, vertical)
- ScrollArea

### Navigation

- TopAppBar
- SideNavigation (collapsible)
- BottomNavigation (mobile)
- Breadcrumbs
- Tabs
- Pagination
- Stepper

### Feedback

- AlertDialog
- BottomSheet
- Snackbar / Toast
- ProgressIndicator (linear, circular)
- Skeleton
- EmptyState
- ErrorState

### Data Display

- DataTable (sortable, filterable, paginated)
- List / ListItem
- Chip / Tag
- StatCard
- MetricCard
- Chart (line, bar, pie, area — via fl_chart)
- Timeline
- TreeView

### Overlays

- Modal / Dialog
- Popover
- DropdownMenu
- CommandPalette (⌘K)
- LightBox (media viewer)

### Rich Content

- RichTextEditor (via super_editor)
- MarkdownRenderer
- CodeBlock
- MediaPreview (image, video, audio)
- PostPreviewCard (platform-specific rendering)

---

## Responsive Breakpoints

| Name | Width | Columns | Gutter |
|------|-------|---------|--------|
| xs | < 640px | 4 | 16px |
| sm | 640–768px | 8 | 24px |
| md | 768–1024px | 12 | 24px |
| lg | 1024–1280px | 12 | 32px |
| xl | > 1280px | 12 | 32px |

### Layout Rules

- **Mobile**: Bottom navigation, single column, stacked cards
- **Tablet**: Collapsible sidebar, 2-column grid, side panels
- **Desktop**: Persistent sidebar, 3-column grid, split views

---

## Accessibility

- Minimum touch target: 44x44px
- Color contrast: WCAG AA (4.5:1 text, 3:1 large text)
- Focus indicators: 2px solid `primary` with 2px offset
- Screen reader labels on all interactive elements
- Semantic HTML via Flutter's `Semantics` widget
- Keyboard navigation: Tab order, Escape to close, Arrow keys in lists
- Animation: `prefers-reduced-motion` respected via `MediaQuery`
- Dynamic text scaling: Layouts support 0.8x–2.0x font scale

---

## Motion

| Token | Duration | Easing |
|-------|----------|--------|
| `instant` | 100ms | `ease-out` |
| `fast` | 200ms | `ease-in-out` |
| `normal` | 300ms | `ease-in-out` |
| `slow` | 500ms | `ease-in-out` |

### Guidelines

- Page transitions: slide + fade (300ms)
- Modals: scale from 0.95 + fade (200ms)
- Toasts: slide up from bottom (200ms)
- Skeleton loading: shimmer pulse (1500ms loop)
- Reduce motion when `MediaQuery.disableAnimations` is true

---

## Dark Mode

- Toggle available in settings and system-level
- All tokens have light/dark variants
- Platform colors maintain brand identity
- Shadows and borders adjusted for dark backgrounds
- Images and media: no inversion; use `ColorFilter` for placeholders only
