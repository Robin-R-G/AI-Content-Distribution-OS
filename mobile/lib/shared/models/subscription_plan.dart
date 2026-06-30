import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum PlanTier { free, creator, pro, agency, enterprise }

class SubscriptionPlan {
  final PlanTier tier;
  final String name;
  final String description;
  final double priceInr;
  final double? yearlyPriceInr;
  final bool adsEnabled;
  final int dailyAiCredits;
  final int maxSocialAccounts;
  final int maxScheduledPosts;
  final List<String> features;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.description,
    required this.priceInr,
    this.yearlyPriceInr,
    this.adsEnabled = true,
    this.dailyAiCredits = 50,
    this.maxSocialAccounts = 5,
    this.maxScheduledPosts = 20,
    this.features = const [],
  });

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'name': name,
        'description': description,
        'priceInr': priceInr,
        'yearlyPriceInr': yearlyPriceInr,
        'adsEnabled': adsEnabled,
        'dailyAiCredits': dailyAiCredits,
        'maxSocialAccounts': maxSocialAccounts,
        'maxScheduledPosts': maxScheduledPosts,
        'features': features,
      };

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        tier: PlanTier.values.firstWhere((t) => t.name == json['tier']),
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        priceInr: (json['priceInr'] ?? 0).toDouble(),
        yearlyPriceInr: json['yearlyPriceInr']?.toDouble(),
        adsEnabled: json['adsEnabled'] ?? true,
        dailyAiCredits: json['dailyAiCredits'] ?? 50,
        maxSocialAccounts: json['maxSocialAccounts'] ?? 5,
        maxScheduledPosts: json['maxScheduledPosts'] ?? 20,
        features: List<String>.from(json['features'] ?? []),
      );

  SubscriptionPlan copyWith({
    String? name,
    String? description,
    double? priceInr,
    double? yearlyPriceInr,
    bool? adsEnabled,
    int? dailyAiCredits,
    int? maxSocialAccounts,
    int? maxScheduledPosts,
    List<String>? features,
  }) =>
      SubscriptionPlan(
        tier: tier,
        name: name ?? this.name,
        description: description ?? this.description,
        priceInr: priceInr ?? this.priceInr,
        yearlyPriceInr: yearlyPriceInr ?? this.yearlyPriceInr,
        adsEnabled: adsEnabled ?? this.adsEnabled,
        dailyAiCredits: dailyAiCredits ?? this.dailyAiCredits,
        maxSocialAccounts: maxSocialAccounts ?? this.maxSocialAccounts,
        maxScheduledPosts: maxScheduledPosts ?? this.maxScheduledPosts,
        features: features ?? this.features,
      );

  static const defaultPlans = [
    SubscriptionPlan(
      tier: PlanTier.free,
      name: 'Free',
      description: 'Get started with basic features',
      priceInr: 0,
      adsEnabled: true,
      dailyAiCredits: 50,
      maxSocialAccounts: 2,
      maxScheduledPosts: 10,
      features: [
        '2 social accounts',
        '10 scheduled posts/day',
        '50 AI credits/day',
        'Basic analytics',
        'Watch ads for bonus credits',
      ],
    ),
    SubscriptionPlan(
      tier: PlanTier.creator,
      name: 'Creator',
      description: 'For individual creators',
      priceInr: 399,
      yearlyPriceInr: 3999,
      adsEnabled: false,
      dailyAiCredits: 500,
      maxSocialAccounts: 10,
      maxScheduledPosts: 100,
      features: [
        '10 social accounts',
        '100 scheduled posts/day',
        '500 AI credits/day',
        'Advanced analytics',
        'No ads',
        'Priority AI processing',
      ],
    ),
    SubscriptionPlan(
      tier: PlanTier.pro,
      name: 'Pro',
      description: 'For professionals and teams',
      priceInr: 999,
      yearlyPriceInr: 9999,
      adsEnabled: false,
      dailyAiCredits: 2000,
      maxSocialAccounts: 25,
      maxScheduledPosts: 500,
      features: [
        '25 social accounts',
        '500 scheduled posts/day',
        '2000 AI credits/day',
        'Full analytics suite',
        'No ads',
        'Priority AI processing',
        'Custom brand templates',
      ],
    ),
    SubscriptionPlan(
      tier: PlanTier.agency,
      name: 'Agency',
      description: 'For agencies managing multiple clients',
      priceInr: 2999,
      yearlyPriceInr: 29999,
      adsEnabled: false,
      dailyAiCredits: 10000,
      maxSocialAccounts: 100,
      maxScheduledPosts: 9999,
      features: [
        '100 social accounts',
        'Unlimited scheduled posts',
        '10,000 AI credits/day',
        'Full analytics suite',
        'No ads',
        'Dedicated AI processing',
        'Custom brand templates',
        'Team collaboration',
      ],
    ),
  ];
}

// Current user plan state
class UserPlanState {
  final PlanTier tier;
  final SubscriptionPlan plan;
  final int creditsRemaining;
  final int creditsUsedToday;
  final DateTime? premiumExpiry;

  const UserPlanState({
    this.tier = PlanTier.free,
    required this.plan,
    this.creditsRemaining = 50,
    this.creditsUsedToday = 0,
    this.premiumExpiry,
  });

  UserPlanState copyWith({
    PlanTier? tier,
    SubscriptionPlan? plan,
    int? creditsRemaining,
    int? creditsUsedToday,
    DateTime? premiumExpiry,
  }) =>
      UserPlanState(
        tier: tier ?? this.tier,
        plan: plan ?? this.plan,
        creditsRemaining: creditsRemaining ?? this.creditsRemaining,
        creditsUsedToday: creditsUsedToday ?? this.creditsUsedToday,
        premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      );

  bool get isPremium => tier != PlanTier.free;
  bool get adsEnabled => plan.adsEnabled;
  bool get hasCredits => creditsRemaining > 0;
}

class UserPlanNotifier extends StateNotifier<UserPlanState> {
  UserPlanNotifier()
      : super(
          UserPlanState(plan: SubscriptionPlan.defaultPlans.first),
        ) {
    _load();
  }

  static const _planKey = 'user_plan_tier';
  static const _creditsKey = 'user_credits';
  static const _creditsUsedKey = 'user_credits_used';
  static const _expiryKey = 'user_premium_expiry';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final tierName = prefs.getString(_planKey) ?? 'free';
    final tier = PlanTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => PlanTier.free,
    );
    final plan = SubscriptionPlan.defaultPlans.firstWhere(
      (p) => p.tier == tier,
      orElse: () => SubscriptionPlan.defaultPlans.first,
    );
    final credits = prefs.getInt(_creditsKey) ?? plan.dailyAiCredits;
    final used = prefs.getInt(_creditsUsedKey) ?? 0;
    final expiryMs = prefs.getInt(_expiryKey);
    final expiry = expiryMs != null
        ? DateTime.fromMillisecondsSinceEpoch(expiryMs)
        : null;

    state = UserPlanState(
      tier: tier,
      plan: plan,
      creditsRemaining: credits,
      creditsUsedToday: used,
      premiumExpiry: expiry,
    );
  }

  Future<void> setPlan(PlanTier tier) async {
    final plan = SubscriptionPlan.defaultPlans.firstWhere(
      (p) => p.tier == tier,
      orElse: () => SubscriptionPlan.defaultPlans.first,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, tier.name);
    await prefs.setInt(_creditsKey, plan.dailyAiCredits);
    await prefs.setInt(_creditsUsedKey, 0);

    state = UserPlanState(
      tier: tier,
      plan: plan,
      creditsRemaining: plan.dailyAiCredits,
      creditsUsedToday: 0,
      premiumExpiry: tier != PlanTier.free
          ? DateTime.now().add(const Duration(days: 30))
          : null,
    );
  }

  Future<bool> useCredit() async {
    if (state.creditsRemaining <= 0) return false;
    final newRemaining = state.creditsRemaining - 1;
    final newUsed = state.creditsUsedToday + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditsKey, newRemaining);
    await prefs.setInt(_creditsUsedKey, newUsed);
    state = state.copyWith(
      creditsRemaining: newRemaining,
      creditsUsedToday: newUsed,
    );
    return true;
  }

  Future<void> addCredits(int amount) async {
    final newAmount = state.creditsRemaining + amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditsKey, newAmount);
    state = state.copyWith(creditsRemaining: newAmount);
  }

  Future<void> resetDailyCredits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditsKey, state.plan.dailyAiCredits);
    await prefs.setInt(_creditsUsedKey, 0);
    state = state.copyWith(
      creditsRemaining: state.plan.dailyAiCredits,
      creditsUsedToday: 0,
    );
  }
}

final userPlanProvider =
    StateNotifierProvider<UserPlanNotifier, UserPlanState>((ref) {
  return UserPlanNotifier();
});
