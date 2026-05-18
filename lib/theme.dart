import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE8622A);
  static const primaryLight = Color(0xFFFF7043);
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF161616);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const textMuted = Color(0xFF999999);
  static const chipBackground = Color(0xFFF5F5F5);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Georgia',
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    useMaterial3: true,
  );

  static BoxDecoration get primaryGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primaryLight, AppColors.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
