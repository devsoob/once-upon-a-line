import 'package:flutter/material.dart';

/// Centralized design system colors derived from the logo gradient.
class AppColors {
  AppColors._();

  // Logo gradient stops
  static const Color logoStart = Color(0xFFFF7A7A); // #ff7a7a
  static const Color logoMid = Color(0xFFFF477E); // #ff477e
  static const Color logoEnd = Color(0xFFA853FF); // #a853ff

  // Primary palette selections
  static const Color primary = logoMid; // vibrant mid-pink
  static const Color primaryDark = Color(0xFFCC3764);
  static const Color primaryLight = Color(0xFFFF9AB2);

  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color hint = Color(0xFFB0B8C1);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[logoStart, logoMid, logoEnd],
  );
}
