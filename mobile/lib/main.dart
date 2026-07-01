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
import 'features/ai/ai_service.dart';
import 'features/credits/credit_service.dart';
import 'features/payment/payment_service.dart';
import 'features/admin/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  // Initialize ads
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('MobileAds init failed: $e');
  }

  // Initialize OneSignal
  try {
    await OneSignalService.initialize(EnvConfig.oneSignalAppId);
  } catch (e) {
    debugPrint('OneSignal init failed: $e');
  }

  // Initialize services (wrapped in try-catch so app doesn't crash)
  try { await AiService().initialize(); } catch (e) { debugPrint('AiService init failed: $e'); }
  try { await CreditService().initialize(); } catch (e) { debugPrint('CreditService init failed: $e'); }
  try { await PaymentService().initialize(); } catch (e) { debugPrint('PaymentService init failed: $e'); }
  try { await AdminService().initialize(); } catch (e) { debugPrint('AdminService init failed: $e'); }

  // Preload app open ad (only shows on cold start)
  try { AppOpenAdHandler.preload(); } catch (e) { debugPrint('AppOpenAd preload failed: $e'); }

  // Initialize ad manager
  try { AdManager().initialize(); } catch (e) { debugPrint('AdManager init failed: $e'); }

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
