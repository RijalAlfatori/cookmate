import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget kartu resep untuk ditampilkan di GridView
/// Menampilkan gambar dengan Hero animation, nama resep, dan tombol panah
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Gambar Resep dengan Hero animation ──────────────────────
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'meal_image_${meal.idMeal}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    meal.strMealThumb,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    // Tampilkan placeholder abu-abu saat gambar sedang dimuat
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.shimmer,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.accent,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.primaryLight,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ─── Info Resep ───────────────────────────────────────────────
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            meal.strMeal,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (meal.strCategory != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              meal.strCategory!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Tombol ikon panah kanan
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
