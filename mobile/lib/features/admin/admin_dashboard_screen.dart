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
    AdminService().initialize();
    AiService().initialize();
    CreditService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          'Admin Panel',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: AppRadius.xs,
            ),
            child: Text(
              'ADMIN',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.darkSurface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                _buildTab('Plans', 0),
                _buildTab('AI Keys', 1),
                _buildTab('Rewards', 2),
                _buildTab('Users', 3),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildPlansTab(),
                _buildAiKeysTab(),
                _buildRewardsTab(),
                _buildUsersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansTab() {
    final adminService = AdminService();
    final plans = adminService.plans;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '₹${plan.priceInr.toStringAsFixed(0)}/mo',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${plan.dailyAiCredits} credits/day • ${plan.maxSocialAccounts} accounts • ${plan.maxScheduledPosts} posts',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildEditButton('Edit', () => _showEditPlanDialog(index, plan)),
                  const SizedBox(width: 8),
                  if (plan.tier != PlanTier.free)
                    _buildEditButton('Reset', () {
                      adminService.resetPlans();
                      setState(() {});
                    }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryMuted,
          borderRadius: AppRadius.xs,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAiKeysTab() {
    final aiService = AiService();
    final providers = aiService.providers;

    return ListView.builder(
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
                color: AppColors.primaryMuted,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add AI Provider',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final provider = providers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: provider.enabled
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: provider.enabled,
                    onChanged: (val) {
                      aiService.updateProvider(
                        index,
                        provider.copyWith(enabled: val),
                      );
                      setState(() {});
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Model: ${provider.model}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'API Key: ${provider.apiKey != null && provider.apiKey!.isNotEmpty ? '${provider.apiKey!.substring(0, 8)}...' : 'Not set'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildEditButton('Edit', () => _showEditProviderDialog(index, provider)),
                  const SizedBox(width: 8),
                  _buildEditButton('Remove', () {
                    aiService.removeProvider(index);
                    setState(() {});
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardsTab() {
    final creditService = CreditService();
    final adminService = AdminService();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ad Reward Amounts',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildRewardRow(
            'AI Credits per Ad',
            adminService.rewardAiCredits,
            (val) => adminService.updateRewards(aiCredits: val),
          ),
          _buildRewardRow(
            'Schedule Slots per Ad',
            adminService.rewardScheduleSlots,
            (val) => adminService.updateRewards(scheduleSlots: val),
          ),
          _buildRewardRow(
            'Analytics Days per Ad',
            adminService.rewardAnalyticsDays,
            (val) => adminService.updateRewards(analyticsDays: val),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow(String label, int value, Function(int) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                color: AppColors.error,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22),
                color: AppColors.primary,
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'User Management',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to Supabase to manage users',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(int index, SubscriptionPlan plan) {
    final nameController = TextEditingController(text: plan.name);
    final descController = TextEditingController(text: plan.description);
    final priceController =
        TextEditingController(text: plan.priceInr.toStringAsFixed(0));
    final creditsController =
        TextEditingController(text: plan.dailyAiCredits.toString());
    final accountsController =
        TextEditingController(text: plan.maxSocialAccounts.toString());
    final postsController =
        TextEditingController(text: plan.maxScheduledPosts.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: Text('Edit ${plan.name} Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Name', nameController),
              _buildDialogField('Description', descController),
              _buildDialogField('Price (₹/mo)', priceController,
                  isNumber: true),
              _buildDialogField('Daily AI Credits', creditsController,
                  isNumber: true),
              _buildDialogField('Max Social Accounts', accountsController,
                  isNumber: true),
              _buildDialogField('Max Scheduled Posts', postsController,
                  isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = plan.copyWith(
                name: nameController.text,
                description: descController.text,
                priceInr: double.tryParse(priceController.text) ?? plan.priceInr,
                dailyAiCredits:
                    int.tryParse(creditsController.text) ?? plan.dailyAiCredits,
                maxSocialAccounts: int.tryParse(accountsController.text) ??
                    plan.maxSocialAccounts,
                maxScheduledPosts:
                    int.tryParse(postsController.text) ?? plan.maxScheduledPosts,
              );
              AdminService().updatePlan(index, updated);
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditProviderDialog(int index, AiProvider provider) {
    final nameController = TextEditingController(text: provider.name);
    final urlController = TextEditingController(text: provider.baseUrl);
    final keyController = TextEditingController(text: provider.apiKey ?? '');
    final modelController = TextEditingController(text: provider.model);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: Text('Edit ${provider.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Name', nameController),
              _buildDialogField('Base URL', urlController),
              _buildDialogField('API Key', keyController, isPassword: true),
              _buildDialogField('Model', modelController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = provider.copyWith(
                name: nameController.text,
                baseUrl: urlController.text,
                apiKey: keyController.text,
                model: modelController.text,
              );
              AiService().updateProvider(index, updated);
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddProviderDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final keyController = TextEditingController();
    final modelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: const Text('Add AI Provider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Name', nameController),
              _buildDialogField('Base URL', urlController),
              _buildDialogField('API Key', keyController, isPassword: true),
              _buildDialogField('Model', modelController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                AiService().addProvider(AiProvider(
                  name: nameController.text,
                  baseUrl: urlController.text,
                  apiKey: keyController.text,
                  model: modelController.text,
                  enabled: true,
                ));
                Navigator.pop(context);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller,
      {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: AppRadius.sm,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.sm,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
