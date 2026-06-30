import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _contentController = TextEditingController();
  String _selectedPlatform = 'Instagram';

  final _platforms = [
    {'name': 'Instagram', 'icon': Icons.camera_alt_rounded, 'color': Color(0xFFE4405F)},
    {'name': 'Twitter', 'icon': Icons.chat_bubble_rounded, 'color': Color(0xFF1DA1F2)},
    {'name': 'LinkedIn', 'icon': Icons.work_rounded, 'color': Color(0xFF0A66C2)},
    {'name': 'YouTube', 'icon': Icons.play_circle_rounded, 'color': Color(0xFFFF0000)},
    {'name': 'TikTok', 'icon': Icons.music_note_rounded, 'color': Color(0xFF000000)},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Post',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Post',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform selector
            Text(
              'Select Platform',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _platforms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final platform = _platforms[index];
                  final isSelected = _selectedPlatform == platform['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlatform = platform['name'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? (platform['color'] as Color).withValues(alpha: 0.1) : AppColors.surface,
                        borderRadius: AppRadius.full,
                        border: Border.all(
                          color: isSelected ? (platform['color'] as Color) : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            platform['icon'] as IconData,
                            size: 16,
                            color: isSelected ? platform['color'] as Color : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            platform['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? platform['color'] as Color : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Content area
            Text(
              'Content',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lg,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'What do you want to share?',
                  hintStyle: GoogleFonts.inter(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AI generate button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: AppRadius.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Generate Caption',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
