import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Widget shimmer loading placeholder untuk kartu resep
/// Menampilkan animasi gradient bergerak saat data sedang dimuat
class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                AppColors.shimmer,
                AppColors.shimmerHighlight,
                AppColors.shimmer,
              ],
            ),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder gambar
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Placeholder teks
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Grid shimmer loading — menampilkan beberapa [ShimmerCard] sekaligus
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  const ShimmerGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
