import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InfoBadge — pill kecil untuk Kategori, Area, Tags
// ─────────────────────────────────────────────────────────────────────────────

class InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primarySoft;
    final tc = textColor ?? AppColors.primary;
    final ic = iconColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: ic),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.captionSm(color: tc)),
        ],
      ),
    );
  }
}
