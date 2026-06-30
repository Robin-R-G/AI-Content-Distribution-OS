import 'package:flutter/material.dart';

class AppColors {
  // Primary palette — refined violet
  static const primary = Color(0xFF7C5CFC);
  static const primaryDark = Color(0xFF6246EA);
  static const primaryLight = Color(0xFF9B82FD);
  static const primaryMuted = Color(0xFFEDE9FE);

  // Accent
  static const accent = Color(0xFF06D6A0);
  static const accentDark = Color(0xFF05B88A);

  // Surfaces
  static const background = Color(0xFFF8F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F3F9);
  static const card = Color(0xFFFFFFFF);

  // Semantic
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const successMuted = Color(0xFFECFDF5);
  static const warning = Color(0xFFFBBF24);
  static const info = Color(0xFF3B82F6);

  // Text
  static const textPrimary = Color(0xFF1A1D26);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Borders
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const borderFocus = Color(0xFF7C5CFC);
  static const divider = Color(0xFFF3F4F6);

  // Shadows
  static const shadow = Color(0x0D000000);
  static const shadowMedium = Color(0x14000000);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFC), Color(0xFF9B82FD)],
  );
  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1D26), Color(0xFF2D3142)],
  );
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFC), Color(0xFF06D6A0)],
  );

  // Dark mode
  static const darkBackground = Color(0xFF0F1117);
  static const darkSurface = Color(0xFF1A1D26);
  static const darkSurfaceVariant = Color(0xFF252830);
  static const darkTextPrimary = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF2D3142);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;
}

class AppRadius {
  static const xs = BorderRadius.all(Radius.circular(4));
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(20));
  static const xxl = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}

class AppShadows {
  static final xs = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  static final sm = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static final md = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  static final lg = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  static final primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}
