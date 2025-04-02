import 'package:flutter/material.dart';

/// Color constants used throughout the app
class AppColors {
  // Primary colors
  static const Color purple = Color(0xFFE8DEF8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Text colors
  static const Color textDark = Color(0xFF1D1B20);
  static const Color textMedium = Color(0xFF4A4459);
  static const Color textLight = Color(0xFF49454F);

  // Border colors
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color outline = Color(0xFF79747E);
}

/// Text styles used throughout the app
class AppTextStyles {
  static const TextStyle regular = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.0,
    color: AppColors.textMedium,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.0,
    color: AppColors.textLight,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.0,
    color: AppColors.black,
  );
}