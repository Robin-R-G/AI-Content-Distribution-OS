import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../shared/models/subscription_plan.dart';
import '../ai/ai_service.dart';
import '../credits/credit_service.dart';

class AdminConfig {
  final String adminEmail;
  final String upiId;
  final String payeeName;

  const AdminConfig({
    this.adminEmail = 'therobinrg@gmail.com',
    this.upiId = 'metherobin@oksbi',
    this.payeeName = 'ContentOS',
  });
}

class AdminService {
  static final AdminService _instance = AdminService._();
  factory AdminService() => _instance;
  AdminService._();

  static const adminEmail = 'therobinrg@gmail.com';
  static const adminPassword = 'TheRobinRG@Admin';

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // User management
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => List.unmodifiable(_users);

  // Plans (editable)
  List<SubscriptionPlan> _plans = List.from(SubscriptionPlan.defaultPlans);
  List<SubscriptionPlan> get plans => List.unmodifiable(_plans);

  // Reward config
  int _rewardAiCredits = 5;
  int _rewardScheduleSlots = 3;
  int _rewardAnalyticsDays = 2;
  int get rewardAiCredits => _rewardAiCredits;
  int get rewardScheduleSlots => _rewardScheduleSlots;
  int get rewardAnalyticsDays => _rewardAnalyticsDays;

  static const _plansKey = 'admin_plans';
  static const _rewardsKey = 'admin_rewards';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load plans
    final plansJson = prefs.getString(_plansKey);
    if (plansJson != null) {
      try {
        final list = jsonDecode(plansJson) as List;
        _plans = list.map((e) => SubscriptionPlan.fromJson(e)).toList();
      } catch (_) {
        _plans = List.from(SubscriptionPlan.defaultPlans);
      }
    }

    // Load rewards
    final rewardsJson = prefs.getString(_rewardsKey);
    if (rewardsJson != null) {
      try {
        final map = jsonDecode(rewardsJson);
        _rewardAiCredits = map['aiCredits'] ?? 5;
        _rewardScheduleSlots = map['scheduleSlots'] ?? 3;
        _rewardAnalyticsDays = map['analyticsDays'] ?? 2;
      } catch (_) {}
    }
  }

  Future<bool> login(String email, String password) async {
    if (email == adminEmail && password == adminPassword) {
      _isAdmin = true;
      return true;
    }
    _isAdmin = false;
    return false;
  }

  void logout() {
    _isAdmin = false;
  }

  // Plan management
  Future<void> updatePlan(int index, SubscriptionPlan plan) async {
    if (index >= 0 && index < _plans.length) {
      _plans[index] = plan;
      await _savePlans();
    }
  }

  Future<void> resetPlans() async {
    _plans = List.from(SubscriptionPlan.defaultPlans);
    await _savePlans();
  }

  Future<void> _savePlans() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _plans.map((p) => p.toJson()).toList();
    await prefs.setString(_plansKey, jsonEncode(json));
  }

  // Reward management
  Future<void> updateRewards({
    int? aiCredits,
    int? scheduleSlots,
    int? analyticsDays,
  }) async {
    if (aiCredits != null) _rewardAiCredits = aiCredits;
    if (scheduleSlots != null) _rewardScheduleSlots = scheduleSlots;
    if (analyticsDays != null) _rewardAnalyticsDays = analyticsDays;

    final creditService = CreditService();
    creditService.updateRewardAmounts(
      aiCredits: _rewardAiCredits,
      scheduleSlots: _rewardScheduleSlots,
      analyticsDays: _rewardAnalyticsDays,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rewardsKey, jsonEncode({
      'aiCredits': _rewardAiCredits,
      'scheduleSlots': _rewardScheduleSlots,
      'analyticsDays': _rewardAnalyticsDays,
    }));
  }
}

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});
