import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF06B6D4);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const borderFocus = Color(0xFF6366F1);
  static const divider = Color(0xFFF1F5F9);
  static const shadow = Color(0x0A000000);

  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = Radius.circular(6);
  static const md = Radius.circular(10);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(24);
  static const full = Radius.circular(999);
}

class AppShadows {
  static final sm = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  static final md = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
