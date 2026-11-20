import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerBox — single animated shimmer placeholder
// ShimmerGrid & SliverShimmerGrid — responsive grid of shimmer recipe cards
// Tidak menggunakan package eksternal; murni AnimationController.
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 160,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerRecipeCard — skeleton berbentuk RecipeCard
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerRecipeCard extends StatelessWidget {
  const ShimmerRecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar skeleton
          const Expanded(
            flex: 3,
            child: ShimmerBox(height: double.infinity, borderRadius: 0),
          ),
          // Konten skeleton
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ShimmerBox(height: 11, borderRadius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(
                    height: 10,
                    width: 80,
                    borderRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverShimmerGrid — sliver grid untuk CustomScrollView (hemat memori & performa tinggi)
// ─────────────────────────────────────────────────────────────────────────────

class SliverShimmerGrid extends StatelessWidget {
  final int itemCount;
  const SliverShimmerGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const ShimmerRecipeCard(),
          childCount: itemCount,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerGrid — grid shrink-wrapped untuk box biasa
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  const ShimmerGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerRecipeCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerListTile — skeleton untuk list item di SavedScreen
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 80, height: 80, borderRadius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 13, borderRadius: 6),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 11,
                  borderRadius: 6,
                ),
                const SizedBox(height: 6),
                const ShimmerBox(height: 10, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerDetailHeader — skeleton untuk header DetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerDetailHeader extends StatelessWidget {
  const ShimmerDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(height: 320, borderRadius: 0),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(height: 22, borderRadius: 8),
              const SizedBox(height: 10),
              Row(
                children: [
                  ShimmerBox(
                    width: 90,
                    height: 28,
                    borderRadius: AppTextStyles.captionSm().fontSize ?? 12,
                  ),
                  const SizedBox(width: 8),
                  ShimmerBox(
                    width: 80,
                    height: 28,
                    borderRadius: AppTextStyles.captionSm().fontSize ?? 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
