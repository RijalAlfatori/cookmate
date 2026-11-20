import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CategoryChip — pill aktif/tidak-aktif dengan AnimatedContainer
// Aktif: bg oranye + teks putih + shadow lembut
// Tidak aktif: bg putih + border tipis abu + teks sekunder
// ─────────────────────────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected ? AppColors.chipShadow : [],
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.caption(color: Colors.white)
              : AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
