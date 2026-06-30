import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
            label: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(label),
          )
        : ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
            label: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(label),
          );

    if (width != null) {
      return SizedBox(width: width, height: 48, child: button);
    }

    return SizedBox(height: 48, child: button);
  }
}
