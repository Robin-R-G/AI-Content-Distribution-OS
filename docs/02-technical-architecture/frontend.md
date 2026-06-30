# Frontend Architecture

## Flutter Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── storage_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── spacing.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── string_utils.dart
│   │   └── validation_utils.dart
│   └── extensions/
│       ├── context_extensions.dart
│       └── string_extensions.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   └── auth_provider.dart
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── content/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── publishing/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── analytics/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── settings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── billing/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   ├── forms/
│   │   ├── inputs/
│   │   └── layout/
│   ├── models/
│   └── services/
│
└── config/
    ├── routes/
    │   ├── app_router.dart
    │   └── route_names.dart
    ├── providers/
    │   ├── app_providers.dart
    │   └── provider_observers.dart
    └── di/
        └── dependency_injection.dart
```

## State Management (Riverpod)

### Provider Setup

```dart
// lib/config/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth State Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Workspace Provider
final currentWorkspaceProvider = StateProvider<String?>((ref) => null);

// Content List Provider
final contentListProvider = StateNotifierProvider<ContentListNotifier, AsyncValue<List<Content>>>((ref) {
  return ContentListNotifier(ref);
});
```

### Feature-Specific Providers

```dart
// lib/features/content/presentation/providers/content_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Content Repository Provider
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ContentRepositoryImpl(client);
});

// Content List Notifier
class ContentListNotifier extends StateNotifier<AsyncValue<List<Content>>> {
  final Ref ref;

  ContentListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadContents();
  }

  Future<void> loadContents() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(contentRepositoryProvider);
      final contents = await repository.getContents();
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createContent(CreateContentRequest request) async {
    final repository = ref.read(contentRepositoryProvider);
    await repository.createContent(request);
    await loadContents();
  }

  Future<void> deleteContent(String id) async {
    final repository = ref.read(contentRepositoryProvider);
    await repository.deleteContent(id);
    await loadContents();
  }
}

// Single Content Provider
final contentProvider = FutureProvider.family<Content, String>((ref, id) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getContent(id);
});

// Content Search Provider
final contentSearchProvider = StateProvider<String>((ref) => '');

final filteredContentsProvider = Provider<AsyncValue<List<Content>>>((ref) {
  final contents = ref.watch(contentListProvider);
  final search = ref.watch(contentSearchProvider);

  return contents.whenData((list) {
    if (search.isEmpty) return list;
    return list.where((c) =>
      c.title.toLowerCase().contains(search.toLowerCase()) ||
      c.body.toLowerCase().contains(search.toLowerCase())
    ).toList();
  });
});
```

### Provider Organization

```dart
// lib/config/di/dependency_injection.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DependencyInjection {
  static void init(ProviderContainer container) {
    // Core
    container.read(supabaseClientProvider);

    // Repositories
    container.read(authRepositoryProvider);
    container.read(contentRepositoryProvider);
    container.read(publishingRepositoryProvider);
    container.read(analyticsRepositoryProvider);
  }
}
```

## Navigation (GoRouter)

### Router Configuration

```dart
// lib/config/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.session != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Main app routes
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/content',
            name: RouteNames.content,
            builder: (context, state) => const ContentListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.contentNew,
                builder: (context, state) => const ContentCreatePage(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.contentDetail,
                builder: (context, state) => ContentDetailPage(
                  id: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/edit',
                name: RouteNames.contentEdit,
                builder: (context, state) => ContentEditPage(
                  id: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/publishing',
            name: RouteNames.publishing,
            builder: (context, state) => const PublishingPage(),
          ),
          GoRoute(
            path: '/analytics',
            name: RouteNames.analytics,
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/settings',
            name: RouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/billing',
            name: RouteNames.billing,
            builder: (context, state) => const BillingPage(),
          ),
        ],
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        name: RouteNames.admin,
        builder: (context, state) => const AdminPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});
```

### Route Names

```dart
// lib/config/routes/route_names.dart
abstract class RouteNames {
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot-password';
  static const dashboard = 'dashboard';
  static const content = 'content';
  static const contentNew = 'content-new';
  static const contentDetail = 'content-detail';
  static const contentEdit = 'content-edit';
  static const publishing = 'publishing';
  static const analytics = 'analytics';
  static const settings = 'settings';
  static const billing = 'billing';
  static const admin = 'admin';
}
```

### Navigation Helpers

```dart
// lib/core/utils/navigation_utils.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationExtensions on BuildContext {
  void goToDashboard() => go('/dashboard');
  void goToContent() => go('/content');
  void goToContentNew() => go('/content/new');
  void goToContentDetail(String id) => go('/content/$id');
  void goToContentEdit(String id) => go('/content/$id/edit');
  void goToPublishing() => go('/publishing');
  void goToAnalytics() => go('/analytics');
  void goToSettings() => go('/settings');
  void goToBilling() => go('/billing');

  Future<T?> showAppDialog<T>(Widget dialog) {
    return showDialog<T>(
      context: this,
      builder: (context) => dialog,
    );
  }
}
```

## Theme System

### Theme Configuration

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: AppTypography.lightTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      textTheme: AppTypography.darkTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      // ... similar dark theme configurations
    );
  }
}
```

### Colors

```dart
// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

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
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  // Dark
  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkTextPrimary = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);

  // Status
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Platform Colors
  static const twitter = Color(0xFF1DA1F2);
  static const linkedin = Color(0xFF0A66C2);
  static const instagram = Color(0xFFE4405F);
  static const youtube = Color(0xFFFF0000);
  static const tiktok = Color(0xFF000000);
  static const facebook = Color(0xFF1877F2);
}
```

### Typography

```dart
// lib/core/theme/typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  static const String _fontFamily = 'Inter';

  static const lightTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
  );

  static const darkTheme = TextTheme(
    // Similar with dark colors
  );
}
```

## Component Library

### Shared Widgets

```dart
// lib/shared/widgets/buttons/app_button.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getStyle(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 40;
      case AppButtonSize.large:
        return 48;
    }
  }

  ButtonStyle _getStyle() {
    // Button style based on variant
  }
}
```

### Card Component

```dart
// lib/shared/widgets/cards/app_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}
```

## Responsive Design Strategy

### Breakpoints

```dart
// lib/core/constants/app_constants.dart
class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1280;
}

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet &&
      MediaQuery.of(context).size.width < Breakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktop;

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }
}
```

### Responsive Layout

```dart
// lib/shared/widgets/layout/responsive_layout.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop;
        }
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return tablet ?? desktop;
        }
        return mobile;
      },
    );
  }
}
```

### Responsive Grid

```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.getGridColumns(context);
        final itemWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}
```
