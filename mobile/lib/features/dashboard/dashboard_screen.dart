import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/theme/colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/banner_ad_widget.dart';
import '../../shared/widgets/native_ad_widget.dart';
import '../../shared/widgets/rewarded_ad_button.dart';
import '../../shared/models/user_plan.dart';
import '../../features/ads/ad_manager.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  final AdManager _adManager = AdManager();

  @override
  Widget build(BuildContext context) {
    final userPlan = ref.watch(userPlanProvider);
    final isFree = userPlan.plan == UserPlan.free;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(isFree),
                  _buildContentTab(isFree),
                  _buildAnalyticsTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
            if (isFree)
              Container(
                color: AppColors.surface,
                child: const BannerAdWidget(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          backgroundColor: AppColors.surface,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home_rounded, size: 22),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_square, size: 22),
              selectedIcon: Icon(Icons.edit_square, size: 22),
              label: 'Content',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, size: 22),
              selectedIcon: Icon(Icons.bar_chart_rounded, size: 22),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 22),
              selectedIcon: Icon(Icons.settings_rounded, size: 22),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Pro',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Remove ads & unlock unlimited AI',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.sm,
            ),
            child: Text(
              'Upgrade',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: AppRadius.xs,
                ),
                child: const Icon(Icons.card_giftcard_rounded, size: 16, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Text(
                'Earn Rewards',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Watch short ads to unlock bonus features',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RewardedAdButton(
                rewardType: 'AI Generations',
                rewardAmount: 5,
                label: '+5 AI Gen',
                onRewarded: () {},
              ),
              RewardedAdButton(
                rewardType: 'Scheduling Slots',
                rewardAmount: 5,
                label: '+5 Schedule',
                onRewarded: () {},
              ),
              RewardedAdButton(
                rewardType: 'Analytics Days',
                rewardAmount: 3,
                label: '+3 Analytics',
                onRewarded: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(bool isFree) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Creator',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: AppRadius.md,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Upgrade banner
                if (isFree) _buildUpgradeBanner(),

                // Rewards section
                if (isFree) _buildRewardSection(),

                // Quick actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildQuickActions(),
                const SizedBox(height: 28),

                // Upcoming posts
                _buildUpcomingPosts(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Post',
            gradient: AppColors.primaryGradient,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Generate',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF06D6A0), Color(0xFF05B88A)],
            ),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.calendar_today_rounded,
            label: 'Schedule',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: AppRadius.sm,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Posts',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.md,
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 22,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No upcoming posts',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your first post to get started',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Create post',
                  isOutlined: true,
                  width: 160,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTab(bool isFree) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Library',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage and organize your content',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lg,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppRadius.sm,
                            ),
                            child: const Icon(Icons.article_outlined, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Post ${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Scheduled for tomorrow',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMuted,
                              borderRadius: AppRadius.full,
                            ),
                            child: Text(
                              'Draft',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (isFree) ...[
                  const SizedBox(height: 12),
                  const NativeAdCard(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: AppRadius.xl,
            ),
            child: const Icon(Icons.bar_chart_rounded, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Analytics',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your content performance',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.xl,
            ),
            child: const Icon(Icons.settings_rounded, size: 28, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your experience',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
