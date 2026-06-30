import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../services/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authFormProvider.notifier).resetPassword(
          _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authForm = ref.watch(authFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: AppRadius.lg,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Heading
                    Text(
                      'Reset password',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your email and we'll send you a reset link",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Success message
                    if (authForm.successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.06),
                          borderRadius: AppRadius.md,
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authForm.successMessage!,
                                style: GoogleFonts.inter(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Error message
                    if (authForm.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.06),
                          borderRadius: AppRadius.md,
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authForm.error!,
                                style: GoogleFonts.inter(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email field
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim().toLowerCase())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleReset(),
                    ),
                    const SizedBox(height: 28),

                    // Send reset link button
                    AppButton(
                      label: 'Send reset link',
                      isLoading: authForm.isLoading,
                      onPressed: authForm.isLoading ? null : _handleReset,
                    ),
                    const SizedBox(height: 24),

                    // Back to sign in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
