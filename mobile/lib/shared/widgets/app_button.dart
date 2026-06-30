import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isGoogle;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGoogle = false,
    this.icon,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.isGoogle
            ? _buildGoogleButton()
            : widget.isOutlined
                ? _buildOutlinedButton()
                : _buildPrimaryButton(),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.backgroundColor == null
              ? AppColors.primaryGradient
              : null,
          color: widget.backgroundColor,
          borderRadius: AppRadius.md,
          boxShadow: widget.onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.md,
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(widget.label),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: widget.foregroundColor ?? AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.foregroundColor ?? AppColors.textPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              child: const Icon(
                Icons.g_mobiledata_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}
