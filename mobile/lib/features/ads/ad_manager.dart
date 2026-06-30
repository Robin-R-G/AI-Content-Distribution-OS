import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class AdManager {
  static final AdManager _instance = AdManager._();
  factory AdManager() => _instance;
  AdManager._();

  int _interstitialCount = 0;
  int _rewardedCount = 0;
  int _appOpenCount = 0;
  int _actionCount = 0;
  DateTime? _lastInterstitialTime;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoading = false;

  Function()? onAdDismissed;

  bool get isSubscribed => false;

  void initialize() {
    _preloadInterstitial();
    _preloadRewarded();
    if (!isSubscribed) _loadAppOpenAd();
  }

  // ==================== INTERSTITIAL ====================

  void _preloadInterstitial() {
    if (_interstitialCount >= AdConfig.maxInterstitialsPerSession) return;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: ${error.message}');
        },
      ),
    );
  }

  void maybeShowInterstitial({required String trigger}) {
    if (isSubscribed) return;
    if (_interstitialCount >= AdConfig.maxInterstitialsPerSession) return;
    if (_interstitialAd == null) return;

    if (_lastInterstitialTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialTime!);
      if (elapsed.inSeconds < AdConfig.interstitialCooldownSeconds) return;
    }

    _actionCount++;
    if (_actionCount < AdConfig.minActionsBeforeInterstitial) return;

    _showInterstitial();
  }

  void _showInterstitial() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _interstitialCount++;
        _lastInterstitialTime = DateTime.now();
        _actionCount = 0;
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // ==================== REWARDED ====================

  void _preloadRewarded() {
    if (_rewardedCount >= AdConfig.maxRewardedPerSession) return;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: ${error.message}');
        },
      ),
    );
  }

  Future<bool> showRewardedAd({required String rewardType, required int rewardAmount}) async {
    if (isSubscribed) return true;
    if (_rewardedAd == null) return false;

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _rewardedCount++;
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    _rewardedAd = null;
    return completer.future;
  }

  bool get canShowRewarded => _rewardedAd != null && !isSubscribed;

  // ==================== APP OPEN ====================

  void _loadAppOpenAd() {
    if (_appOpenCount >= AdConfig.maxAppOpenPerSession) return;
    if (_isAppOpenAdLoading) return;

    _isAppOpenAdLoading = true;

    AppOpenAd.load(
      adUnitId: AdConfig.appOpenAdUnitId,
      request: const AdRequest(),
      orientation: 1, // UIInterfaceOrientation.portraitUp = 1
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdLoading = false;
          debugPrint('App open failed: ${error.message}');
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    if (isSubscribed) return;
    if (_appOpenAd == null) return;
    if (_appOpenCount >= AdConfig.maxAppOpenPerSession) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _appOpenCount++;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
  }

  // ==================== CLEANUP ====================

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
