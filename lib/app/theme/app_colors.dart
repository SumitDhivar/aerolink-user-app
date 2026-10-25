import 'package:flutter/material.dart';

/// Centralized color palette conforming to ARSP-DS-001.
/// All colors have been verified for WCAG AA/AAA compliance against specified backgrounds.
class AppColors {
  AppColors._();

  // Brand Core
  static const Color brandNavy = Color(0xFF16324F);
  static const Color brandNavyLight = Color(0xFF234973);
  static const Color brandNavyDark = Color(0xFF0E2033);

  // Secondary
  static const Color brandTeal = Color(0xFF087F8C);
  static const Color brandTealLight = Color(0xFF0EA3B3);
  static const Color brandTealDark = Color(0xFF065A64);

  // Accent
  static const Color brandAmber = Color(0xFFE9A23B);
  static const Color brandAmberDark = Color(0xFFB76E00);

  // Backgrounds & Surfaces
  static const Color softNeutral = Color(0xFFF6F7F9);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Semantic Status
  static const Color success = Color(0xFF1B7A43);
  static const Color successContainer = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFB76E00);
  static const Color warningContainer = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFC92A2A);
  static const Color errorContainer = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF1D6FB8);
  static const Color infoContainer = Color(0xFFEBF4FB);

  // Neutral Grayscale
  static const Color neutral900 = Color(0xFF1A202C);
  static const Color neutral800 = Color(0xFF2D3748);
  static const Color neutral700 = Color(0xFF4A5568);
  static const Color neutral600 = Color(0xFF718096);
  static const Color neutral500 = Color(0xFFA0AEC0);
  static const Color neutral400 = Color(0xFFB0BDD0);
  static const Color neutral300 = Color(0xFFCBD5E0);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral100 = Color(0xFFEDF2F7);
  static const Color neutral50 = Color(0xFFF7FAFC);
}
