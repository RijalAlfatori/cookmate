import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlannerScreen — Fitur Opsional Meal Planner
// Jadwal menu harian (Sarapan, Makan Siang, Makan Malam) per hari dalam seminggu
// ─────────────────────────────────────────────────────────────────────────────

class PlannerScreen extends StatefulWidget {
  final VoidCallback? onExplore;
  const PlannerScreen({super.key, this.onExplore});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedDayIndex = 0;

  static const List<String> _days = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _fullDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jum\'at',
    'Sabtu',
    'Minggu',
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding,
            24,
            AppTheme.pagePadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Meal Planner', style: AppTextStyles.display()),
                        const SizedBox(height: 4),
                        Text(
                          'Rencanakan menu makanan sehatmu',
                          style: AppTextStyles.body(
                            color: isDark
                                ? AppColors.darkTextSec
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Selector Hari Horizontal ─────────────────────────────
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedDayIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        width: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surface),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                          ),
                          boxShadow:
                              isSelected ? AppColors.chipShadow : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _days[i],
                              style: AppTextStyles.captionSm(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${i + 1}',
                              style: AppTextStyles.cardTitle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkText
                                        : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ── Jadwal Menu Hari Terpilih ─────────────────────────────
              Text(
                'Menu Hari ${_fullDays[_selectedDayIndex]}',
                style: AppTextStyles.titleMd(),
              ),
              const SizedBox(height: 16),

              // Slot Sarapan
              _buildMealSlot(
                context,
                title: 'Sarapan',
                time: '07:00 - 08:30',
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFF57F17),
                bgColor: const Color(0xFFFFF9C4),
                dishName: 'Avocado Toast & Egg',
                calories: '320 kkal',
              ),
              const SizedBox(height: 14),

              // Slot Makan Siang
              _buildMealSlot(
                context,
                title: 'Makan Siang',
                time: '12:00 - 13:30',
                icon: Icons.lunch_dining_rounded,
                iconColor: AppColors.primary,
                bgColor: AppColors.primarySoft,
                dishName: 'Teriyaki Chicken Bowl',
                calories: '550 kkal',
              ),
              const SizedBox(height: 14),

              // Slot Makan Malam
              _buildMealSlot(
                context,
                title: 'Makan Malam',
                time: '18:30 - 20:00',
                icon: Icons.nights_stay_outlined,
                iconColor: const Color(0xFF5E35B1),
                bgColor: const Color(0xFFEDE7F6),
                dishName: 'Salmon Salad & Olive Oil',
                calories: '410 kkal',
              ),
              const SizedBox(height: 24),

              // ── Banner Tips Gizi ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Hidup Sehat 💡',
                            style: AppTextStyles.cardTitle(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Minum air minimal 2 liter per hari dan seimbangkan asupan protein serta sayuran segar.',
                            style: AppTextStyles.captionSm(
                              color: const Color(0xFF5D4037),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSlot(
    BuildContext context, {
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String dishName,
    required String calories,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle()),
                    Text(
                      time,
                      style: AppTextStyles.captionSm(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dishName,
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      calories,
                      style: AppTextStyles.captionSm(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
