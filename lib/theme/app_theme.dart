import 'package:flutter/material.dart';

/// LiveCare brand colors, matched to the design mockups.
class AppColors {
  // Sidebar / navy
  static const navy = Color(0xFF0E2E52);
  static const navyDeep = Color(0xFF0A2340);
  static const navActive = Color(0xFF1D63ED);

  // Brand blue
  static const primary = Color(0xFF1D63ED);
  static const primaryDeep = Color(0xFF0B45C4);
  static const primarySoft = Color(0xFFEAF1FE);

  // Neutrals
  static const ink = Color(0xFF0F172A);
  static const body = Color(0xFF475467);
  static const muted = Color(0xFF94A3B8);
  static const line = Color(0xFFE2E8F0);
  static const surface = Color(0xFFF4F7FC);
  static const white = Colors.white;

  // Status
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const amber = Color(0xFFF59E0B);
  static const amberSoft = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFEE2E2);
  static const purple = Color(0xFF7A5AF8);
  static const purpleSoft = Color(0xFFEDE9FE);
}

/// App-wide theme.
class AppTheme {
  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.primarySoft,
        surface: AppColors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      dividerColor: AppColors.line,
    );
  }
}
