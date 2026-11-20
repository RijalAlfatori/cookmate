import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IngredientTile — baris bahan dengan titik oranye, nama kiri, takaran kanan
// ─────────────────────────────────────────────────────────────────────────────

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final bool showDivider;

  const IngredientTile({
    super.key,
    required this.ingredient,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              // Titik/bullet oranye
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Nama bahan
              Expanded(
                child: Text(
                  ingredient.name,
                  style: AppTextStyles.bodyMd(color: AppColors.textPrimary),
                ),
              ),
              // Takaran
              if (ingredient.measure.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ingredient.measure,
                    style: AppTextStyles.captionSm(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 36,
            endIndent: 16,
            color: AppColors.border,
          ),
      ],
    );
  }
}
