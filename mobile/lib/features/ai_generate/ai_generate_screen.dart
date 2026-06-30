import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class AiGenerateScreen extends StatefulWidget {
  const AiGenerateScreen({super.key});

  @override
  State<AiGenerateScreen> createState() => _AiGenerateScreenState();
}

class _AiGenerateScreenState extends State<AiGenerateScreen> {
  final _promptController = TextEditingController();
  String _selectedType = 'Caption';

  final _types = [
    {'name': 'Caption', 'icon': Icons.short_text_rounded},
    {'name': 'Hashtags', 'icon': Icons.tag},
    {'name': 'Thread', 'icon': Icons.format_list_bulleted_rounded},
    {'name': 'Bio', 'icon': Icons.person_outline_rounded},
  ];

  @override
  void dispose() {
    _promptController.dispose();
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
          'AI Generate',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Text(
              'Generate Type',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _types.map((type) {
                final isSelected = _selectedType == type['name'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type['name'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryMuted : AppColors.surface,
                        borderRadius: AppRadius.md,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            size: 20,
                            color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Prompt input
            Text(
              'Topic / Keywords',
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
                controller: _promptController,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., productivity tips for creators',
                  hintStyle: GoogleFonts.inter(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.lg,
                boxShadow: AppShadows.primaryGlow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Generate',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
