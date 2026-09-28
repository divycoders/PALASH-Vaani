import 'package:flutter/material.dart';

/// PALASH-Vaani Color Palette
///
/// Designed with earthy terracotta and Palash (Flame of the Forest) tones,
/// reflecting tribal Indian heritage, rural classroom accessibility,
/// and high-contrast readability.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Palash / Terracotta)
  static const Color primary = Color(0xFFD84315); // Deep Palash Vermillion
  static const Color primaryLight = Color(0xFFFF7043);
  static const Color primaryDark = Color(0xFF9F0000);
  static const Color primaryContainer = Color(0xFFFFCCBC);
  static const Color onPrimaryContainer = Color(0xFF4E1500);

  // Secondary Accents (Earthy Ochre / Forest Green)
  static const Color secondary = Color(0xFF2E7D32); // Forest Green
  static const Color secondaryLight = Color(0xFF60AD5E);
  static const Color secondaryDark = Color(0xFF005005);
  static const Color secondaryContainer = Color(0xFFC8E6C9);

  // Tertiary (Warm Ochre / Marigold)
  static const Color tertiary = Color(0xFFEF6C00); // Warm Ochre
  static const Color tertiaryContainer = Color(0xFFFFE0B2);

  // Neutral & Surface Colors
  static const Color background = Color(0xFFF9F7F4); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1EAE4);
  static const Color outline = Color(0xFFBCAAA4);
  static const Color outlineVariant = Color(0xFFE0D7D3);

  // Text Colors
  static const Color textPrimary = Color(0xFF261C18);
  static const Color textSecondary = Color(0xFF5D4037);
  static const Color textMuted = Color(0xFF8D6E63);
  static const Color textOnPrimary = Colors.white;

  // Status & Utility Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color offline = Color(0xFF546E7A);
  static const Color online = Color(0xFF2E7D32);

  // Educational Tag Colors
  static const Color tagMath = Color(0xFF1565C0);
  static const Color tagLanguage = Color(0xFF7B1FA2);
  static const Color tagScience = Color(0xFF00796B);
}
