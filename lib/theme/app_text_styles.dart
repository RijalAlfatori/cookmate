import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CookMate Design System — Typography (Plus Jakarta Sans)
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // ── Display / Greeting ────────────────────────────────────────────────────
  static TextStyle display({Color color = AppColors.textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.2,
      );

  static TextStyle displaySm({Color color = AppColors.textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.25,
      );

  // ── Section Titles ────────────────────────────────────────────────────────
  static TextStyle titleLg({Color color = AppColors.textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle titleMd({Color color = AppColors.textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  // ── Card Titles ───────────────────────────────────────────────────────────
  static TextStyle cardTitle({Color color = AppColors.textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.35,
      );

  static TextStyle cardTitleLg({Color color = AppColors.textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.35,
      );

  // ── Body ─────────────────────────────────────────────────────────────────
  static TextStyle body({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.55,
      );

  /// Khusus langkah memasak agar nyaman dibaca
  static TextStyle bodyStep({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.65,
      );

  static TextStyle bodyMd({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // ── Caption / Badge ───────────────────────────────────────────────────────
  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle captionSm({Color color = AppColors.textHint}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // ── Button / Label ────────────────────────────────────────────────────────
  static TextStyle button({Color color = Colors.white}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle label({Color color = AppColors.primary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
