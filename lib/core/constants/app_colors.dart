import 'package:flutter/material.dart';

/// Centralized design system colors.
class AppColors {
  AppColors._();

  // Monotone palette inspired by Brunch app
  static const Color primary = Color(0xFF222222); // Deep black
  static const Color secondary = Color(0xFF4A4A4A); // Dark gray
  static const Color tertiary = Color(0xFF7F8C8D); // Medium gray

  // Background colors
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Light gray

  // Text colors
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF7F8C8D);
  static const Color hint = Color(0xFFB0B8C1);

  // Accent colors (minimal)
  static const Color accent = Color(0xFF6C5CE7); // Subtle purple for key actions
  static const Color accentLight = Color(0xFFA29BFE);

  // Border and divider
  static const Color border = Color(0xFFEDEFF2);
  static const Color divider = Color(0xFFE0E0E0);

  // Error and success
  static const Color error = Color(0xFFDB4C40);
  static const Color success = Color(0xFF5CBA47);
}
