import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import 'tutorial_service.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<_TutorialPage> _pages = const [
    _TutorialPage(
      icon: Icons.edit_note_rounded,
      title: 'Create Posts',
      subtitle: 'Write, format, and preview your content before publishing.',
      gradient: AppColors.primaryGradient,
    ),
    _TutorialPage(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Assistant',
      subtitle: 'Generate captions, hashtags, and ideas with built-in AI.',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C5CFC), Color(0xFF06D6A0)],
      ),
    ),
    _TutorialPage(
      icon: Icons.schedule_rounded,
      title: 'Schedule & Publish',
      subtitle: 'Queue posts across all your platforms at the best times.',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF06D6A0), Color(0xFF3B82F6)],
      ),
    ),
    _TutorialPage(
      icon: Icons.bar_chart_rounded,
      title: 'Track Analytics',
      subtitle: 'See what works. Monitor engagement, growth, and reach.',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), Color(0xFF7C5CFC)],
      ),
    ),
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish() async {
    await TutorialService.markCompleted();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _current == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: page.gradient,
                            boxShadow: AppShadows.primaryGlow,
                          ),
                          child: Icon(
                            page.icon,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Next / Done
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: i == _current ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: AppRadius.full,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next / Get Started
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLast ? _finish : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.full,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Get Started' : 'Next',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (!isLast) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
