import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class AppOpenAdHandler {
  static AppOpenAd? _appOpenAd;
  static bool _isAdLoading = false;
  static bool _showOnNextResume = false;

  static void preload() {
    if (_isAdLoading || _appOpenAd != null) return;

    _isAdLoading = true;

    AppOpenAd.load(
      adUnitId: AdConfig.appOpenAdUnitId,
      request: const AdRequest(),
      orientation: 1,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isAdLoading = false;
          debugPrint('App open ad failed: ${error.message}');
        },
      ),
    );
  }

  /// Call on cold start (app launch)
  static void showOnColdStart() {
    if (_appOpenAd == null) {
      _showOnNextResume = true;
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
  }

  /// Call on app resume from background
  /// Only shows if user hasn't been away long (cold start scenario)
  static void onAppResume() {
    if (_showOnNextResume && _appOpenAd != null) {
      showOnColdStart();
      _showOnNextResume = false;
    }
  }

  static void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
