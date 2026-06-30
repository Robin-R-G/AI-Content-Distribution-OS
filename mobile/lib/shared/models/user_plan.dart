import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserPlan { free, creator, pro, agency, enterprise }

class UserPlanState {
  final UserPlan plan;
  final bool adsEnabled;
  final int dailyAiGenerations;
  final int maxSocialAccounts;
  final int maxScheduledPosts;

  const UserPlanState({
    this.plan = UserPlan.free,
    this.adsEnabled = true,
    this.dailyAiGenerations = 50,
    this.maxSocialAccounts = 5,
    this.maxScheduledPosts = 20,
  });

  UserPlanState copyWith({
    UserPlan? plan,
    bool? adsEnabled,
    int? dailyAiGenerations,
    int? maxSocialAccounts,
    int? maxScheduledPosts,
  }) {
    return UserPlanState(
      plan: plan ?? this.plan,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      dailyAiGenerations: dailyAiGenerations ?? this.dailyAiGenerations,
      maxSocialAccounts: maxSocialAccounts ?? this.maxSocialAccounts,
      maxScheduledPosts: maxScheduledPosts ?? this.maxScheduledPosts,
    );
  }

  static UserPlanState fromPlan(UserPlan plan) {
    switch (plan) {
      case UserPlan.free:
        return const UserPlanState();
      case UserPlan.creator:
        return UserPlanState(
          plan: UserPlan.creator,
          adsEnabled: false,
          dailyAiGenerations: 500,
          maxSocialAccounts: 10,
          maxScheduledPosts: 100,
        );
      case UserPlan.pro:
        return UserPlanState(
          plan: UserPlan.pro,
          adsEnabled: false,
          dailyAiGenerations: 2000,
          maxSocialAccounts: 25,
          maxScheduledPosts: 500,
        );
      case UserPlan.agency:
        return UserPlanState(
          plan: UserPlan.agency,
          adsEnabled: false,
          dailyAiGenerations: 10000,
          maxSocialAccounts: 100,
          maxScheduledPosts: 9999,
        );
      case UserPlan.enterprise:
        return UserPlanState(
          plan: UserPlan.enterprise,
          adsEnabled: false,
          dailyAiGenerations: 99999,
          maxSocialAccounts: 999,
          maxScheduledPosts: 99999,
        );
    }
  }
}

final userPlanProvider = StateNotifierProvider<UserPlanNotifier, UserPlanState>((ref) {
  return UserPlanNotifier();
});

class UserPlanNotifier extends StateNotifier<UserPlanState> {
  UserPlanNotifier() : super(const UserPlanState());

  void setPlan(UserPlan plan) {
    state = UserPlanState.fromPlan(plan);
  }

  void upgradeToCreator() => setPlan(UserPlan.creator);
  void upgradeToPro() => setPlan(UserPlan.pro);
  void upgradeToAgency() => setPlan(UserPlan.agency);
}
