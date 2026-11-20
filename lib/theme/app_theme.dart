import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CookMate Design System — ThemeData (Light + Dark)
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Radius constants ──────────────────────────────────────────────────────
  static const double radiusCard   = 20;
  static const double radiusButton = 14;
  static const double radiusSearch = 16;
  static const double radiusChip   = 999; // pill

  // ── Spacing constants ─────────────────────────────────────────────────────
  static const double pagePadding = 20;
  static const double gridSpacing = 16;

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      // Global text theme (Plus Jakarta Sans)
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.titleMd(),
        centerTitle: false,
      ),

      // ── NavigationBar (M3) ───────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.captionSm(color: AppColors.primary);
          }
          return AppTextStyles.captionSm(color: AppColors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      // ── Buttons ───────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.button(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.label(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSearch),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSearch),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSearch),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVar,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.caption(),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMd(color: Colors.white),
        elevation: 4,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: const Color(0xFFFF8A65), // softer orange on dark bg
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: const Color(0xFFEF9A9A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.titleMd(color: AppColors.darkText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.captionSm(color: const Color(0xFFFF8A65));
          }
          return AppTextStyles.captionSm(color: AppColors.darkTextSec);
        }),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: AppTextStyles.bodyMd(color: AppColors.darkText),
      ),
    );
  }
}
