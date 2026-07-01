import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../router/app_router.dart';

class OneSignalService {
  static bool _dialogShown = false;

  /// Initialize the OneSignal SDK and register observers.
  static Future<void> initialize(String appId) async {
    try {
      // Set Log Level for debug
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Initialize OneSignal
      await OneSignal.initialize(appId);

      // Register push subscription observer
      OneSignal.User.pushSubscription.addObserver((state) {
        try {
          debugPrint('OneSignal Push Subscription changed: ${state.current.id}');
          _checkAndShowVerificationDialog();
        } catch (e) {
          debugPrint('Error in OneSignal subscription observer callback: $e');
        }
      });

      // Evaluate subscription state immediately
      _checkAndShowVerificationDialog();
    } catch (e) {
      debugPrint('Error during OneSignalService.initialize: $e');
    }
  }

  /// Private helper to check subscription and present native dialog
  static void _checkAndShowVerificationDialog() {
    if (_dialogShown) return;

    final subscriptionId = OneSignal.User.pushSubscription.id;
    if (subscriptionId != null &&
        subscriptionId.isNotEmpty &&
        !subscriptionId.startsWith('local-')) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        _dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Your OneSignal SDK integration is complete!"),
            content: const Text(
              "You can now send Push Notifications & In-App Messages through OneSignal. Tap below to enable push notifications."
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  requestPermission();
                },
                child: const Text("Got it"),
              ),
            ],
          ),
        );
      } else {
        // If context isn't ready yet, wait and try again
        Future.delayed(
          const Duration(milliseconds: 500),
          _checkAndShowVerificationDialog,
        );
      }
    }
  }

  /// Request push notifications permission
  static Future<bool> requestPermission() async {
    return await OneSignal.Notifications.requestPermission(true);
  }

  /// Log in a user with their external ID
  static void login(String externalId) {
    OneSignal.login(externalId);
  }

  /// Log out the user
  static void logout() {
    OneSignal.logout();
  }

  /// Add email subscription
  static void addEmail(String email) {
    OneSignal.User.addEmail(email);
  }

  /// Remove email subscription
  static void removeEmail(String email) {
    OneSignal.User.removeEmail(email);
  }

  /// Add SMS subscription
  static void addSms(String number) {
    OneSignal.User.addSms(number);
  }

  /// Remove SMS subscription
  static void removeSms(String number) {
    OneSignal.User.removeSms(number);
  }

  /// Add a single tag
  static void addTag(String key, String value) {
    OneSignal.User.addTagWithKey(key, value);
  }

  /// Remove a tag
  static void removeTag(String key) {
    OneSignal.User.removeTag(key);
  }

  /// Add multiple tags
  static void addTags(Map<String, String> tags) {
    OneSignal.User.addTags(tags);
  }

  /// Remove multiple tags
  static void removeTags(List<String> keys) {
    OneSignal.User.removeTags(keys);
  }

  /// Set logging level
  static void setLogLevel(OSLogLevel logLevel) {
    OneSignal.Debug.setLogLevel(logLevel);
  }
}
