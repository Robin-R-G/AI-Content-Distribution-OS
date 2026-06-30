import 'package:flutter_native_splash/flutter_native_splash.dart';

class Splash {
  static void precache(BuildContext context) {
    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  }

  static void remove() {
    FlutterNativeSplash.remove();
  }
}

// Use in main.dart:
// void main() {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
//   runApp(const ProviderScope(child: ContentOSApp()));
// }
//
// In SplashScreen initState after animation:
//   FlutterNativeSplash.remove();
