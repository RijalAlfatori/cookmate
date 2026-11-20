import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CookMate Design System — Color Tokens
// Seed: #E65100 (Deep Orange). Material 3 ColorScheme.fromSeed.
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary     = Color(0xFFE65100); // Deep Orange
  static const Color primaryDark = Color(0xFFBF360C);
  static const Color primarySoft = Color(0xFFFFF3E0); // pale orange bg
  static const Color accent      = Color(0xFFFFB300); // Amber – highlight/star

  // ── Neutrals (Light) ─────────────────────────────────────────────────────
  static const Color background  = Color(0xFFFAFAFA);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceVar  = Color(0xFFF5F5F5); // subtle off-white
  static const Color border      = Color(0xFFEEEEEE);

  // ── Text (Light) ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1F1B16);
  static const Color textSecondary = Color(0xFF6B6258);
  static const Color textHint      = Color(0xFFBBB0A8);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color error   = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57F17);

  // ── Dark-mode overrides (used in AppTheme.dark) ───────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface    = Color(0xFF1E1E1E);
  static const Color darkBorder     = Color(0xFF2C2C2C);
  static const Color darkText       = Color(0xFFF5EDE7);
  static const Color darkTextSec    = Color(0xFFBCAFAA);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.07),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get chipShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.28),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
