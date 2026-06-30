import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../services/auth_provider.dart';
import '../../onboarding/tutorial_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  double _passwordStrength = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authFormProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );

    if (success && mounted) {
      final authForm = ref.read(authFormProvider);
      if (authForm.successMessage != null) {
        // Email verification needed - show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authForm.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
          ),
        );
        ref.read(authFormProvider.notifier).clearSuccess();
        context.go('/login');
      } else {
        final completed = await TutorialService.isCompleted();
        if (mounted) {
          context.go(completed ? '/dashboard' : '/tutorial');
        }
      }
    }
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.25) return AppColors.error;
    if (_passwordStrength <= 0.5) return AppColors.warning;
    if (_passwordStrength <= 0.75) return AppColors.info;
    return AppColors.success;
  }

  String _getStrengthLabel() {
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.75) return 'Good';
    return 'Strong';
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
                    // Heading
                    Text(
                      'Create your account',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start creating amazing content today',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Error
                    if (authForm.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.06),
                          borderRadius: AppRadius.md,
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.15),
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
                            GestureDetector(
                              onTap: () =>
                                  ref.read(authFormProvider.notifier).clearError(),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Name row
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'First name',
                            controller: _firstNameController,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Last name',
                            controller: _lastNameController,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Email
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    AppTextField(
                      label: 'Password',
                      hint: 'Min 8 characters',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 8) return 'Min 8 characters';
                        if (!RegExp(r'[A-Z]').hasMatch(v)) {
                          return 'Need uppercase letter';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(v)) {
                          return 'Need a number';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleRegister(),
                    ),

                    // Password strength indicator
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppRadius.full,
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                minHeight: 4,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getStrengthColor(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getStrengthLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStrengthColor(),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Create account button
                    AppButton(
                      label: 'Create account',
                      isLoading: authForm.isLoading,
                      onPressed: authForm.isLoading ? null : _handleRegister,
                    ),
                    const SizedBox(height: 32),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
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
