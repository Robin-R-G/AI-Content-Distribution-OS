import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../ai/ai_service.dart';

class AiGenerateScreen extends StatefulWidget {
  const AiGenerateScreen({super.key});

  @override
  State<AiGenerateScreen> createState() => _AiGenerateScreenState();
}

class _AiGenerateScreenState extends State<AiGenerateScreen> {
  final _promptController = TextEditingController();
  String _selectedType = 'Caption';
  bool _isGenerating = false;
  String? _result;
  String? _error;

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

  String _taskForType(String type) {
    switch (type) {
      case 'Caption':
        return 'Write a social media caption';
      case 'Hashtags':
        return 'Generate relevant hashtags';
      case 'Thread':
        return 'Write a Twitter/X thread';
      case 'Bio':
        return 'Write a social media bio';
      default:
        return 'Generate content';
    }
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      setState(() => _error = 'Please enter a topic or keywords');
      return;
    }

    setState(() {
      _isGenerating = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await AiService().generate(
        prompt: prompt,
        task: _taskForType(_selectedType),
      );
      if (mounted) {
        setState(() {
          _result = result;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Generation failed. Please try again.';
          _isGenerating = false;
        });
      }
    }
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

            GestureDetector(
              onTap: _isGenerating ? null : _generate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: _isGenerating ? null : AppColors.primaryGradient,
                  color: _isGenerating ? AppColors.textTertiary.withValues(alpha: 0.3) : null,
                  borderRadius: AppRadius.lg,
                  boxShadow: _isGenerating ? [] : AppShadows.primaryGlow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGenerating)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isGenerating ? 'Generating...' : 'Generate',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'Generated $_selectedType',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _result!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _result!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied to clipboard'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: AppRadius.sm,
                        ),
                        child: Text(
                          'Copy',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
