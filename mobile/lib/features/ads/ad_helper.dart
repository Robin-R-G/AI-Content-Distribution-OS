import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../features/ads/ad_service.dart';

class AdInterstitial {
  static final AdService _adService = AdService();

  static void load() {
    _adService.loadInterstitialAd(
      callbacks: AdLoadCallbacks(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  static Future<void> showIfAvailable() async {
    _adService.showInterstitialAd();
  }
}

class AdLoadCallbacks {
  final void Function(InterstitialAd) onAdLoaded;
  final void Function(LoadAdError) onAdFailedToLoad;

  AdLoadCallbacks({
    required this.onAdLoaded,
    required this.onAdFailedToLoad,
  });
}
