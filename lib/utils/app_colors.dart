import 'package:flutter/material.dart';

/// Konstanta warna, theme data, dan utilitas desain untuk CookMate
/// Skema warna: Kuliner hangat dengan Deep Orange sebagai primary color
class AppColors {
  // Primary
  static const Color primary = Color(0xFFE65100);       // Deep Orange
  static const Color primaryDark = Color(0xFFD84315);   // Darker orange
  static const Color primaryLight = Color(0xFFFF8A65);  // Light orange

  // Background & Surface
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFAAAAAA);

  // Accent
  static const Color accent = Color(0xFFFFF3E0);        // Warm orange tint
  static const Color chipSelected = Color(0xFFE65100);
  static const Color chipUnselected = Color(0xFFF5F5F5);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color shimmer = Color(0xFFEEEEEE);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}

class AppShadows {
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
