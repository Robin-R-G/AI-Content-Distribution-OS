import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'core/services/onesignal_service.dart';
import 'features/ads/ad_manager.dart';
import 'features/ads/app_open_ad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabaseAnonKey,
  );

  // Initialize ads
  await MobileAds.instance.initialize();

  // Initialize OneSignal
  OneSignalService.initialize(EnvConfig.oneSignalAppId);

  // Preload app open ad (only shows on cold start)
  AppOpenAdHandler.preload();

  // Initialize ad manager
  AdManager().initialize();

  runApp(
    const ProviderScope(
      child: ContentOSApp(),
    ),
  );
}

class ContentOSApp extends ConsumerWidget {
  const ContentOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Show app open ad on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppOpenAdHandler.showOnColdStart();
    });

    return MaterialApp.router(
      title: 'ContentOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
