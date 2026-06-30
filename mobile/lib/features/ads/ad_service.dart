import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConfig {
  static const String bannerAdUnitId = kReleaseMode
      ? 'ca-app-pub-xxxxxxxxxxxxx/yyyyyyyyyy'
      : 'ca-app-pub-3940256099942544/6300978111';

  static const String interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-xxxxxxxxxxxxx/yyyyyyyyyy'
      : 'ca-app-pub-3940256099942544/1033173712';

  static const String nativeAdUnitId = kReleaseMode
      ? 'ca-app-pub-xxxxxxxxxxxxx/yyyyyyyyyy'
      : 'ca-app-pub-3940256099942544/2247696110';

  static const AdSize bannerSize = AdSize.banner;
  static const bool adsEnabled = true;
  static const int maxAdRetries = 3;
}

class AdService {
  final int _bannerLoadAttempts = 0;
  int _interstitialLoadAttempts = 0;
  InterstitialAd? _interstitialAd;

  void loadInterstitialAd({
    required Function(InterstitialAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    _interstitialLoadAttempts = 0;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onComplete}) {
    if (_interstitialAd == null) {
      onComplete?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onComplete?.call();
      },
    );
    _interstitialAd!.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
