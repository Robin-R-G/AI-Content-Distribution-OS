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

      final publicRoutes = ['/', '/login', '/register', '/forgot-password', '/tutorial'];
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
    ],
  );
});
