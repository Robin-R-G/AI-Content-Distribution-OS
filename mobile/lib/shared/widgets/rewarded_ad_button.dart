import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../features/ads/ad_config.dart';
import '../../core/theme/colors.dart';

class RewardedAdButton extends StatefulWidget {
  final String rewardType;
  final int rewardAmount;
  final String label;
  final VoidCallback? onRewarded;

  const RewardedAdButton({
    super.key,
    required this.rewardType,
    required this.rewardAmount,
    this.label = 'Watch Ad',
    this.onRewarded,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _rewardedAd = ad;
              _isAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          if (mounted) setState(() => _isAdReady = false);
        },
      ),
    );
  }

  void _showAd() {
    if (_rewardedAd == null || _isLoading) return;

    setState(() => _isLoading = true);

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        setState(() => _isLoading = false);
        ad.dispose();
        _rewardedAd = null;
        _isAdReady = false;
        _loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        setState(() => _isLoading = false);
        ad.dispose();
        _rewardedAd = null;
        _loadAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        widget.onRewarded?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+${widget.rewardAmount} ${widget.rewardType} unlocked!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
    );

    _rewardedAd = null;
    _isAdReady = false;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isAdReady ? _showAd : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isAdReady ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _isAdReady ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 16,
              color: _isAdReady ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              _isLoading ? 'Loading...' : widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _isAdReady ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            if (_isAdReady) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '+${widget.rewardAmount}',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
