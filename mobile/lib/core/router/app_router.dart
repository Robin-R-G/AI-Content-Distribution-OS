import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/register_screen.dart';
import '../../features/auth/forgot_password/forgot_password_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/post_create/post_create_screen.dart';
import '../../features/ai_generate/ai_generate_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/posts_list/posts_list_screen.dart';
import '../../features/onboarding/tutorial_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/subscription/subscription_plans_screen.dart';
import '../../features/admin/admin_login_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final location = state.matchedLocation;

      final publicRoutes = ['/', '/login', '/register', '/forgot-password', '/tutorial', '/admin'];
      final isPublicRoute = publicRoutes.contains(location);

      if (session == null && !isPublicRoute) {
        return '/login';
      }

      if (session != null && (location == '/login' || location == '/register')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/post-create',
        builder: (context, state) => const PostCreateScreen(),
      ),
      GoRoute(
        path: '/ai-generate',
        builder: (context, state) => const AiGenerateScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/posts',
        builder: (context, state) => const PostsListScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final planTier = state.uri.queryParameters['plan'];
          final amount = double.tryParse(state.uri.queryParameters['amount'] ?? '');
          return PaymentScreen(planTier: planTier, amount: amount);
        },
      ),
      GoRoute(
        path: '/subscription-plans',
        builder: (context, state) => const SubscriptionPlansScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});
