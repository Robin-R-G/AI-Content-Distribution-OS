import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import '../../core/theme/colors.dart';

class RewardedAdSheet extends StatefulWidget {
  final String title;
  final String description;
  final String rewardType;
  final int rewardAmount;
  final VoidCallback? onRewarded;

  const RewardedAdSheet({
    super.key,
    required this.title,
    required this.description,
    required this.rewardType,
    required this.rewardAmount,
    this.onRewarded,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    required String rewardType,
    required int rewardAmount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => RewardedAdSheet(
        title: title,
        description: description,
        rewardType: rewardType,
        rewardAmount: rewardAmount,
      ),
    );
  }

  @override
  State<RewardedAdSheet> createState() => _RewardedAdSheetState();
}

class _RewardedAdSheetState extends State<RewardedAdSheet> {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      adLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => Navigator.pop(context, false),
      ),
    );
  }

  void _showAd() {
    if (_rewardedAd == null || _isLoading) return;

    setState(() => _isLoading = true);

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        Navigator.pop(context, false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        Navigator.pop(context, false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        widget.onRewarded?.call();
        Navigator.pop(context, true);
      },
    );

    _rewardedAd = null;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${widget.rewardAmount} ${widget.rewardType}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rewardedAd != null && !_isLoading ? _showAd : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Watch Ad to Earn'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No thanks'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
