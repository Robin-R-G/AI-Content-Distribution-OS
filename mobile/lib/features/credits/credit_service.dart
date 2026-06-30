import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/subscription_plan.dart';

class CreditService {
  static final CreditService _instance = CreditService._();
  factory CreditService() => _instance;
  CreditService._();

  // Ad reward amounts (configurable by admin)
  int rewardAiCredits = 5;
  int rewardScheduleSlots = 3;
  int rewardAnalyticsDays = 2;

  static const _rewardAiKey = 'reward_ai_credits';
  static const _rewardScheduleKey = 'reward_schedule_slots';
  static const _rewardAnalyticsKey = 'reward_analytics_days';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    rewardAiCredits = prefs.getInt(_rewardAiKey) ?? 5;
    rewardScheduleSlots = prefs.getInt(_rewardScheduleKey) ?? 3;
    rewardAnalyticsDays = prefs.getInt(_rewardAnalyticsKey) ?? 2;
  }

  Future<void> saveRewardConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_rewardAiKey, rewardAiCredits);
    await prefs.setInt(_rewardScheduleKey, rewardScheduleSlots);
    await prefs.setInt(_rewardAnalyticsKey, rewardAnalyticsDays);
  }

  void updateRewardAmounts({
    int? aiCredits,
    int? scheduleSlots,
    int? analyticsDays,
  }) {
    if (aiCredits != null) rewardAiCredits = aiCredits;
    if (scheduleSlots != null) rewardScheduleSlots = scheduleSlots;
    if (analyticsDays != null) rewardAnalyticsDays = analyticsDays;
    saveRewardConfig();
  }
}

class CreditState {
  final int aiCredits;
  final int scheduleSlots;
  final int analyticsDays;
  final int totalEarnedToday;
  final int maxAdsPerDay;

  const CreditState({
    this.aiCredits = 50,
    this.scheduleSlots = 0,
    this.analyticsDays = 0,
    this.totalEarnedToday = 0,
    this.maxAdsPerDay = 5,
  });

  CreditState copyWith({
    int? aiCredits,
    int? scheduleSlots,
    int? analyticsDays,
    int? totalEarnedToday,
    int? maxAdsPerDay,
  }) =>
      CreditState(
        aiCredits: aiCredits ?? this.aiCredits,
        scheduleSlots: scheduleSlots ?? this.scheduleSlots,
        analyticsDays: analyticsDays ?? this.analyticsDays,
        totalEarnedToday: totalEarnedToday ?? this.totalEarnedToday,
        maxAdsPerDay: maxAdsPerDay ?? this.maxAdsPerDay,
      );

  bool get canWatchAd => totalEarnedToday < maxAdsPerDay;
  int get adsRemaining => maxAdsPerDay - totalEarnedToday;
}

class CreditNotifier extends StateNotifier<CreditState> {
  CreditNotifier() : super(const CreditState()) {
    _load();
  }

  static const _totalEarnedKey = 'credits_total_earned_today';
  static const _lastResetKey = 'credits_last_reset';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final totalEarned = prefs.getInt(_totalEarnedKey) ?? 0;
    final lastReset = prefs.getString(_lastResetKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Reset daily counter if it's a new day
    if (lastReset != today) {
      await prefs.setInt(_totalEarnedKey, 0);
      await prefs.setString(_lastResetKey, today);
      state = state.copyWith(totalEarnedToday: 0);
    } else {
      state = state.copyWith(totalEarnedToday: totalEarned);
    }
  }

  Future<bool> earnFromAd(String rewardType) async {
    if (!state.canWatchAd) return false;

    final creditService = CreditService();
    int amount = 0;

    switch (rewardType) {
      case 'AI Generations':
        amount = creditService.rewardAiCredits;
        break;
      case 'Scheduling Slots':
        amount = creditService.rewardScheduleSlots;
        break;
      case 'Analytics Days':
        amount = creditService.rewardAnalyticsDays;
        break;
    }

    // Update earned today
    final newEarned = state.totalEarnedToday + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalEarnedKey, newEarned);

    state = state.copyWith(
      totalEarnedToday: newEarned,
      aiCredits: state.aiCredits + amount,
    );
    return true;
  }
}

final creditServiceProvider = Provider<CreditService>((ref) {
  return CreditService();
});

final creditProvider =
    StateNotifierProvider<CreditNotifier, CreditState>((ref) {
  return CreditNotifier();
});
