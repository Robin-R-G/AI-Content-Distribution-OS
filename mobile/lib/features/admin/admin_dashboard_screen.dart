import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../shared/models/subscription_plan.dart';
import '../ai/ai_service.dart';
import '../admin/admin_service.dart';
import '../credits/credit_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await AdminService().initialize();
    final ai = AiService();
    await ai.initialize();
    ai.onLowToken = (name, remaining) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Warning: $name has only $remaining tokens left'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ));
      }
    };
    ai.onTokenExhausted = (name) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$name token limit exhausted - auto-disabled'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    };
    ai.onProviderDown = (name, error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$name is down: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    };
    await CreditService().initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ai = AiService();
    final hasAlerts = ai.lowTokenAlerts.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Admin Panel',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          if (hasAlerts)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warning, borderRadius: AppRadius.xs),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text('${ai.lowTokenAlerts.length}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2), borderRadius: AppRadius.xs),
            child: Text('ADMIN',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: AppColors.darkSurface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(children: [
            _buildTab('Plans', 0),
            _buildTab('AI Tools', 1),
            _buildTab('Rewards', 2),
            _buildTab('Users', 3),
          ]),
        ),
        if (hasAlerts)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.warning.withValues(alpha: 0.1),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(child: Text(
                  '${ai.lowTokenAlerts.length} AI provider alert(s) - check AI Tools tab',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning))),
              GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Text('View',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning))),
            ]),
          ),
        Expanded(
          child: IndexedStack(index: _selectedTab, children: [
            _buildPlansTab(),
            _buildAiKeysTab(),
            _buildRewardsTab(),
            _buildUsersTab(),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTab(String label, int index) {
    final sel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border(
            bottom: BorderSide(color: sel ? AppColors.primary : Colors.transparent, width: 2))),
        child: Text(label, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            color: sel ? Colors.white : Colors.white.withValues(alpha: 0.5))),
      ),
    );
  }

  Widget _buildEditButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.primaryMuted, borderRadius: AppRadius.xs),
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ),
    );
  }

  // ==================== PLANS TAB ====================
  Widget _buildPlansTab() {
    final plans = AdminService().plans;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.border, width: 0.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(plan.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Rs.${plan.priceInr.toStringAsFixed(0)}/mo',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ]),
            const SizedBox(height: 8),
            Text('${plan.dailyAiCredits} credits/day  ${plan.maxSocialAccounts} accounts  ${plan.maxScheduledPosts} posts',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              _buildEditButton('Edit', () => _showEditPlanDialog(index, plan)),
              const SizedBox(width: 8),
              if (plan.tier != PlanTier.free)
                _buildEditButton('Reset', () { AdminService().resetPlans(); setState(() {}); }),
            ]),
          ]),
        );
      },
    );
  }

  // ==================== AI KEYS TAB ====================
  Widget _buildAiKeysTab() {
    final ai = AiService();
    final providers = ai.providers;
    final stats = ai.stats;
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: AppRadius.md),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _statItem('Providers', '${providers.length}'),
          _statItem('Requests', '${stats.totalRequests}'),
          _statItem('Success', '${(stats.successRate * 100).toStringAsFixed(0)}%'),
          _statItem('Tokens', '${stats.totalTokensUsed}'),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () async { await ai.checkAllProvidersHealth(); setState(() {}); },
            icon: const Icon(Icons.health_and_safety_rounded, size: 16),
            label: Text('Check Health', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.sm)),
          )),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(
            onPressed: () async { await ai.resetDailyTokens(); setState(() {}); },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('Reset Tokens', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.info,
                side: const BorderSide(color: AppColors.info),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.sm)),
          )),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: providers.length + 1,
        itemBuilder: (context, index) {
          if (index == providers.length) {
            return GestureDetector(
              onTap: () => _showAddProviderDialog(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primaryMuted, borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Add AI Provider',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ]),
              ),
            );
          }
          return _buildProviderCard(providers[index], index);
        },
      )),
    ]);
  }

  Widget _statItem(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
    ]);
  }

  Widget _buildProviderCard(AiProvider provider, int index) {
    final ai = AiService();
    final isLow = provider.isTokenLow && !provider.isTokenExhausted;
    final isExhausted = provider.isTokenExhausted;

    Color hc;
    String hl;
    switch (provider.health) {
      case ProviderHealth.healthy: hc = AppColors.success; hl = 'Healthy'; break;
      case ProviderHealth.degraded: hc = AppColors.warning; hl = 'Degraded'; break;
      case ProviderHealth.down: hc = AppColors.error; hl = 'Down'; break;
      case ProviderHealth.unknown: hc = AppColors.textTertiary; hl = 'Unknown'; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: AppRadius.md,
          border: Border.all(
              color: isExhausted ? AppColors.error : isLow ? AppColors.warning : AppColors.border,
              width: isExhausted || isLow ? 1.5 : 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 24, height: 24,
                  decoration: BoxDecoration(color: AppColors.primaryMuted, borderRadius: AppRadius.xs),
                  child: Center(child: Text('${index + 1}',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(provider.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(provider.model, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
              ]),
            ]),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: hc.withValues(alpha: 0.1), borderRadius: AppRadius.xs),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: hc)),
                  const SizedBox(width: 4),
                  Text(hl, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: hc)),
                ]),
              ),
              const SizedBox(width: 8),
              Switch(value: provider.enabled, onChanged: (v) {
                ai.updateProvider(index, provider.copyWith(enabled: v));
                setState(() {});
              }, activeColor: AppColors.primary),
            ]),
          ]),
        ),
        if (provider.dailyTokenLimit > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Token Usage', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                Text('${provider.tokensUsedToday} / ${provider.dailyTokenLimit}',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                        color: isExhausted ? AppColors.error : isLow ? AppColors.warning : AppColors.textPrimary)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: AppRadius.full, child: LinearProgressIndicator(
                  value: provider.tokenUsagePercent.clamp(0.0, 1.0),
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(isExhausted ? AppColors.error : isLow ? AppColors.warning : AppColors.primary),
                  minHeight: 6)),
              if (isExhausted)
                Padding(padding: const EdgeInsets.only(top: 4), child: Text('Token limit reached - provider auto-disabled',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w500)))
              else if (isLow)
                Padding(padding: const EdgeInsets.only(top: 4), child: Text('Tokens running low - ${provider.tokensRemaining} remaining',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w500))),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Text(
              'API Key: ${provider.hasApiKey ? '${provider.apiKey!.substring(0, 8.clamp(0, (provider.apiKey?.length ?? 0)))}...' : 'Not set'}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
        ),
        if (provider.lastError != null)
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text('Last error: ${provider.lastError}',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.error),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(children: [
            _buildEditButton('Edit', () => _showEditProviderDialog(index, provider)),
            const SizedBox(width: 8),
            if (index > 0)
              _buildEditButton('Up', () { ai.moveProvider(index, index - 1); setState(() {}); }),
            if (index < ai.providers.length - 1) ...[
              const SizedBox(width: 8),
              _buildEditButton('Down', () { ai.moveProvider(index, index + 1); setState(() {}); }),
            ],
            const Spacer(),
            _buildEditButton('Remove', () { ai.removeProvider(index); setState(() {}); }),
          ]),
        ),
      ]),
    );
  }

  // ==================== REWARDS TAB ====================
  Widget _buildRewardsTab() {
    final admin = AdminService();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ad Reward Amounts', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildRewardRow('AI Credits per Ad', admin.rewardAiCredits, (v) => admin.updateRewards(aiCredits: v)),
        _buildRewardRow('Schedule Slots per Ad', admin.rewardScheduleSlots, (v) => admin.updateRewards(scheduleSlots: v)),
        _buildRewardRow('Analytics Days per Ad', admin.rewardAnalyticsDays, (v) => admin.updateRewards(analyticsDays: v)),
      ]),
    );
  }

  Widget _buildRewardRow(String label, int value, Function(int) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
        Row(children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline, size: 22), color: AppColors.error,
              onPressed: value > 1 ? () => onChanged(value - 1) : null),
          Container(width: 40, alignment: Alignment.center,
              child: Text('$value', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(icon: const Icon(Icons.add_circle_outline, size: 22), color: AppColors.primary,
              onPressed: () => onChanged(value + 1)),
        ]),
      ]),
    );
  }

  // ==================== USERS TAB ====================
  Widget _buildUsersTab() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textTertiary),
      const SizedBox(height: 16),
      Text('User Management', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Connect to Supabase to manage users',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary)),
    ]));
  }

  // ==================== DIALOGS ====================
  void _showEditPlanDialog(int index, SubscriptionPlan plan) {
    final nc = TextEditingController(text: plan.name);
    final dc = TextEditingController(text: plan.description);
    final pc = TextEditingController(text: plan.priceInr.toStringAsFixed(0));
    final cc = TextEditingController(text: plan.dailyAiCredits.toString());
    final ac = TextEditingController(text: plan.maxSocialAccounts.toString());
    final sc = TextEditingController(text: plan.maxScheduledPosts.toString());

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      title: Text('Edit ${plan.name} Plan'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dField('Name', nc), _dField('Description', dc),
        _dField('Price (Rs./mo)', pc, num: true),
        _dField('Daily AI Credits', cc, num: true),
        _dField('Max Social Accounts', ac, num: true),
        _dField('Max Scheduled Posts', sc, num: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          AdminService().updatePlan(index, plan.copyWith(
            name: nc.text, description: dc.text,
            priceInr: double.tryParse(pc.text) ?? plan.priceInr,
            dailyAiCredits: int.tryParse(cc.text) ?? plan.dailyAiCredits,
            maxSocialAccounts: int.tryParse(ac.text) ?? plan.maxSocialAccounts,
            maxScheduledPosts: int.tryParse(sc.text) ?? plan.maxScheduledPosts,
          ));
          Navigator.pop(ctx); setState(() {});
        }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save')),
      ],
    ));
  }

  void _showEditProviderDialog(int index, AiProvider provider) {
    final nc = TextEditingController(text: provider.name);
    final uc = TextEditingController(text: provider.baseUrl);
    final kc = TextEditingController(text: provider.apiKey ?? '');
    final mc = TextEditingController(text: provider.model);
    final tc = TextEditingController(text: provider.dailyTokenLimit.toString());

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      title: Text('Edit ${provider.name}'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dField('Name', nc), _dField('Base URL', uc),
        _dField('API Key', kc, pw: true), _dField('Model', mc),
        _dField('Daily Token Limit', tc, num: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          AiService().updateProvider(index, provider.copyWith(
            name: nc.text, baseUrl: uc.text, apiKey: kc.text, model: mc.text,
            dailyTokenLimit: int.tryParse(tc.text) ?? provider.dailyTokenLimit,
          ));
          Navigator.pop(ctx); setState(() {});
        }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save')),
      ],
    ));
  }

  void _showAddProviderDialog() {
    final nc = TextEditingController();
    final uc = TextEditingController();
    final kc = TextEditingController();
    final mc = TextEditingController();
    final tc = TextEditingController(text: '1000');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      title: const Text('Add AI Provider'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dField('Name', nc), _dField('Base URL', uc),
        _dField('API Key', kc, pw: true), _dField('Model', mc),
        _dField('Daily Token Limit', tc, num: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (nc.text.isNotEmpty) {
            AiService().addProvider(AiProvider(
              name: nc.text, baseUrl: uc.text, apiKey: kc.text, model: mc.text,
              enabled: true, dailyTokenLimit: int.tryParse(tc.text) ?? 1000,
            ));
            Navigator.pop(ctx); setState(() {});
          }
        }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add')),
      ],
    ));
  }

  Widget _dField(String label, TextEditingController c, {bool pw = false, bool num = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: c, obscureText: pw,
          keyboardType: num ? TextInputType.number : null,
          decoration: InputDecoration(
            labelText: label, labelStyle: GoogleFonts.inter(fontSize: 13),
            border: OutlineInputBorder(borderRadius: AppRadius.sm),
            focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          )),
    );
  }
}
