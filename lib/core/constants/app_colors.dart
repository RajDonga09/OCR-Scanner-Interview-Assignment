import 'package:flutter/material.dart';

/// Centralised colour palette for the entire app.
///
/// All widgets read colours from here so the theme can be swapped from a
/// single location without searching the codebase.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF1F6FEB);
  static const Color primaryDark = Color(0xFF0B4FCB);
  static const Color secondary = Color(0xFF14B8A6);

  // Surfaces
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF3F8);
  static const Color divider = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Decorative
  static const Color cardGradientStart = Color(0xFF1F6FEB);
  static const Color cardGradientEnd = Color(0xFF8B5CF6);
  static const Color passbookGradientStart = Color(0xFF14B8A6);
  static const Color passbookGradientEnd = Color(0xFF22D3EE);

  // Misc
  static const Color shimmer = Color(0xFFE5E7EB);
  static const Color overlay = Color(0x80000000);
}
