import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConfig {
  // Your AdMob IDs
  static const String appId = 'ca-app-pub-5962347895188248~6704765879';
  static const String bannerAdUnitId = 'ca-app-pub-5962347895188248/2859065806';
  static const String interstitialAdUnitId = 'ca-app-pub-5962347895188248/1545984137';
  static const String rewardedAdUnitId = 'ca-app-pub-5962347895188248/6056074782';
  static const String appOpenAdUnitId = 'ca-app-pub-5962347895188248/2116829770';
  static const String nativeAdUnitId = 'ca-app-pub-5962347895188248/4429122174';

  // Frequency caps (user-friendly limits)
  static const int interstitialCooldownSeconds = 180; // 3 minutes between interstitials
  static const int maxInterstitialsPerSession = 5;
  static const int maxBannersPerSession = 999;
  static const int maxRewardedPerSession = 10;
  static const int maxAppOpenPerSession = 1; // Only on cold start
  static const int maxNativeAdsPerFeed = 3;

  // Smart trigger settings
  static const int minActionsBeforeInterstitial = 3; // Show after 3 user actions
  static const Duration sessionTimeout = Duration(hours: 1);
}
