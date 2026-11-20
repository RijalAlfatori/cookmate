import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RecipeCard — kartu resep untuk GridView
// Hero animation (tag: "recipe-{idMeal}"), gradient overlay, scale on press via AnimatedScale
// ─────────────────────────────────────────────────────────────────────────────

class RecipeCard extends StatefulWidget {
  final String idMeal;
  final String name;
  final String imageUrl;
  final String? category;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.idMeal,
    required this.name,
    required this.imageUrl,
    this.category,
    required this.onTap,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Gambar dengan Hero (tag unik recipe-{idMeal}) ────────────
                Hero(
                  tag: 'recipe-${widget.idMeal}',
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _buildImagePlaceholder();
                    },
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  ),
                ),

                // ── Gradient overlay gelap tipis di bawah gambar ────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.45, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Teks nama resep di atas gradient ────────────────────────
                Positioned(
                  left: 12,
                  right: 40,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.category != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.category!,
                            style: AppTextStyles.captionSm(color: Colors.white),
                          ),
                        ),
                      Text(
                        widget.name,
                        style: AppTextStyles.cardTitle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── Tombol panah dalam lingkaran oranye kecil ───────────────
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primarySoft,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.primary,
          size: 36,
        ),
      ),
    );
  }
}
