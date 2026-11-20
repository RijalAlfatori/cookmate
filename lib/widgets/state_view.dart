import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StateView — widget generik untuk Error & Empty state
// Ikon besar dalam lingkaran soft, judul, deskripsi, tombol aksi opsional.
// ─────────────────────────────────────────────────────────────────────────────

class StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  /// Warna lingkaran ikon. Default: AppColors.primarySoft
  final Color? iconBgColor;
  final Color? iconColor;

  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.iconBgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBgColor ?? AppColors.primarySoft;
    final ic = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ikon dalam lingkaran ──────────────────────────────────────
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: ic),
            ),
            const SizedBox(height: 24),

            // ── Judul ────────────────────────────────────────────────────
            Text(title, style: AppTextStyles.titleMd(), textAlign: TextAlign.center),
            const SizedBox(height: 8),

            // ── Deskripsi ────────────────────────────────────────────────
            Text(
              description,
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),

            // ── Tombol aksi opsional ─────────────────────────────────────
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ErrorView — StateView khusus error + tombol "Coba Lagi"
// ─────────────────────────────────────────────────────────────────────────────

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StateView(
      icon: Icons.cloud_off_rounded,
      title: 'Ups, Terjadi Masalah',
      description: message,
      iconBgColor: AppColors.error.withValues(alpha: 0.1),
      iconColor: AppColors.error,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Coba Lagi'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextStyles.button(),
        ),
      ),
    );
  }
}
