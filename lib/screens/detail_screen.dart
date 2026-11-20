import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/info_badge.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/note_card.dart';
import '../widgets/shimmer_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DetailScreen — Detail Resep Lengkap
// SliverAppBar parallax dengan Hero gambar, back/bookmark glass button,
// panel konten curved overlap (radius 28), badges, ingredient cards,
// numbered cooking steps, personal note section with animated switcher/size.
// ─────────────────────────────────────────────────────────────────────────────

class DetailScreen extends StatefulWidget {
  final Meal meal;
  const DetailScreen({super.key, required this.meal});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Meal? _fullMeal;
  bool _isLoading = true;
  bool _isSaved = false;

  // Animasi scale bounce pada bookmark
  late final AnimationController _bookmarkCtrl;
  late final Animation<double> _bookmarkScale;

  @override
  void initState() {
    super.initState();
    _bookmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _bookmarkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bookmarkCtrl, curve: Curves.easeOut));

    _initialize();
  }

  @override
  void dispose() {
    _bookmarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final saved = await _storage.isRecipeSaved(widget.meal.idMeal);

    // Jika data resep sudah lengkap (misal dari SavedScreen atau search lengkap)
    if (widget.meal.strInstructions != null &&
        widget.meal.ingredients.isNotEmpty) {
      if (mounted) {
        setState(() {
          _fullMeal = widget.meal;
          _isSaved = saved;
          _isLoading = false;
        });
      }
      return;
    }

    // Fetch data detail lengkap dari TheMealDB lookup endpoint
    try {
      final detail = await _api.getMealById(widget.meal.idMeal);
      if (mounted) {
        setState(() {
          _fullMeal = detail ?? widget.meal;
          _isSaved = saved;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fullMeal = widget.meal;
          _isSaved = saved;
          _isLoading = false;
        });
      }
    }
  }

  // ── Toggle Bookmark dengan Haptic Feedback & Scale Bounce ─────────────────
  Future<void> _toggleBookmark() async {
    if (_fullMeal == null) return;
    HapticFeedback.lightImpact();
    _bookmarkCtrl.forward(from: 0);

    if (_isSaved) {
      await _storage.removeRecipe(_fullMeal!.idMeal);
      if (mounted) {
        setState(() => _isSaved = false);
        _showSnackBar(
          icon: Icons.bookmark_remove_rounded,
          message: 'Dihapus dari favorit',
          isPositive: false,
        );
      }
    } else {
      await _storage.saveRecipe(_fullMeal!);
      if (mounted) {
        setState(() => _isSaved = true);
        _showSnackBar(
          icon: Icons.bookmark_added_rounded,
          message: 'Resep berhasil disimpan ke favorit!',
        );
      }
    }
  }

  // ── Simpan Catatan Pribadi ────────────────────────────────────────────────
  Future<void> _saveNote(String note) async {
    if (_fullMeal == null) return;
    await _storage.updateNote(_fullMeal!.idMeal, note);
    if (mounted) {
      setState(() {
        _fullMeal = _fullMeal!.copyWith(personalNote: note);
      });
    }
  }

  void _showSnackBar({
    required IconData icon,
    required String message,
    bool isPositive = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMd(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor:
            isPositive ? AppColors.primary : AppColors.textSecondary,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingSkeleton();
    return _buildDetail();
  }

  // ── Loading Skeleton Header ───────────────────────────────────────────────
  Widget _buildLoadingSkeleton() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const SafeArea(
        child: SingleChildScrollView(
          child: ShimmerDetailHeader(),
        ),
      ),
    );
  }

  // ── Detail Utama ──────────────────────────────────────────────────────────
  Widget _buildDetail() {
    final meal = _fullMeal!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(meal, theme),
          SliverToBoxAdapter(child: _buildContentPanel(meal, theme)),
        ],
      ),
    );
  }

  // ── SliverAppBar dengan Parallax & Glass Buttons ──────────────────────────
  Widget _buildSliverAppBar(Meal meal, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Gambar Hero (tag recipe-{idMeal}) ────────────────────
            Hero(
              tag: 'recipe-${meal.idMeal}',
              child: Image.network(
                meal.strMealThumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primarySoft,
                  child: const Icon(
                    Icons.restaurant_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // ── Gradient Overlay Atas (agar tombol glass terbaca) ────
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // ── Gradient Overlay Bawah (transisi halus ke panel) ──────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Glass Buttons: Back & Bookmark ───────────────────────
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _glassButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Kembali',
                      onTap: () => Navigator.pop(context),
                    ),
                    ScaleTransition(
                      scale: _bookmarkScale,
                      child: _glassButton(
                        icon: _isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        iconColor: _isSaved ? AppColors.accent : Colors.white,
                        tooltip:
                            _isSaved ? 'Hapus dari favorit' : 'Simpan resep',
                        onTap: _toggleBookmark,
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

  Widget _glassButton({
    required IconData icon,
    Color iconColor = Colors.white,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  // ── Panel Konten Melengkung (Radius 28, Overlap Sedikit ke Gambar) ────────
  Widget _buildContentPanel(Meal meal, ThemeData theme) {
    final steps = _parseSteps(meal.strInstructions ?? '');
    final isDark = theme.brightness == Brightness.dark;

    return Transform.translate(
      offset: const Offset(0, -24), // Overlap ke gambar
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding,
            24,
            AppTheme.pagePadding,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator pill kecil di tengah atas panel
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // ── Nama Resep Besar ────────────────────────────────────
              Text(
                meal.strMeal,
                style: AppTextStyles.displaySm(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // ── Badge Kategori & Area (Asal Negara) ──────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (meal.strCategory != null)
                    InfoBadge(
                      icon: Icons.category_rounded,
                      label: meal.strCategory!,
                    ),
                  if (meal.strArea != null)
                    InfoBadge(
                      icon: Icons.location_on_rounded,
                      label: meal.strArea!,
                      backgroundColor:
                          const Color(0xFF1565C0).withValues(alpha: 0.1),
                      textColor: const Color(0xFF1565C0),
                      iconColor: const Color(0xFF1565C0),
                    ),
                  if (meal.strTags != null && meal.strTags!.isNotEmpty)
                    ...meal.strTags!
                        .split(',')
                        .where((t) => t.trim().isNotEmpty)
                        .take(3)
                        .map(
                          (tag) => InfoBadge(
                            icon: Icons.local_offer_rounded,
                            label: tag.trim(),
                            backgroundColor:
                                AppColors.accent.withValues(alpha: 0.15),
                            textColor: AppColors.warning,
                            iconColor: AppColors.warning,
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 28),
              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              const SizedBox(height: 24),

              // ── Section Bahan-Bahan ───────────────────────────────────
              _buildSectionHeader(
                Icons.local_grocery_store_rounded,
                'Bahan-Bahan',
                subtitle: '${meal.ingredients.length} item terdaftar',
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              if (meal.ingredients.isEmpty)
                Text(
                  'Informasi bahan tidak tersedia.',
                  style: AppTextStyles.body(
                    color: isDark
                        ? AppColors.darkTextSec
                        : AppColors.textSecondary,
                  ),
                )
              else
                _buildIngredients(meal.ingredients, isDark),

              const SizedBox(height: 28),
              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              const SizedBox(height: 24),

              // ── Section Langkah Memasak ───────────────────────────────
              _buildSectionHeader(
                Icons.format_list_numbered_rounded,
                'Langkah Memasak',
                subtitle: '${steps.length} langkah persiapan',
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              if (steps.isEmpty)
                Text(
                  'Instruksi memasak tidak tersedia.',
                  style: AppTextStyles.body(
                    color: isDark
                        ? AppColors.darkTextSec
                        : AppColors.textSecondary,
                  ),
                )
              else
                _buildSteps(steps, isDark),

              const SizedBox(height: 28),

              // ── Section Catatan Masak Pribadi ────────────────────────
              _buildNoteSection(meal, isDark),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Section ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    String? subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMd(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: AppTextStyles.captionSm(
                  color:
                      isDark ? AppColors.darkTextSec : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Daftar Bahan dalam Kartu Putih ────────────────────────────────────────
  Widget _buildIngredients(List<Ingredient> ingredients, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: ingredients.asMap().entries.map((e) {
          return IngredientTile(
            ingredient: e.value,
            showDivider: e.key < ingredients.length - 1,
          );
        }).toList(),
      ),
    );
  }

  // ── Langkah Memasak Bernomor ──────────────────────────────────────────────
  Widget _buildSteps(List<String> steps, bool isDark) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final num = e.key + 1;
        final text = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lingkaran oranye bernomor
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$num',
                    style: AppTextStyles.captionSm(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Teks langkah dalam kartu rapi
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: AppColors.softShadow,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.bodyStep(
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Section Catatan Masak Pribadi (AnimatedSwitcher & AnimatedSize) ───────
  Widget _buildNoteSection(Meal meal, bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _isSaved
          ? Column(
              key: const ValueKey('note_visible'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  Icons.sticky_note_2_rounded,
                  'Catatan Masak Pribadi',
                  subtitle: 'Tersimpan otomatis di HP (Offline)',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                NoteCard(
                  initialNote: meal.personalNote,
                  onSave: _saveNote,
                ),
              ],
            )
          : Padding(
              key: const ValueKey('note_hint'),
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Simpan resep ini untuk menambahkan catatan masak pribadimu.',
                        style: AppTextStyles.bodyMd(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Helper parsing instruksi teks panjang menjadi daftar langkah ─────────
  List<String> _parseSteps(String instructions) {
    if (instructions.trim().isEmpty) return [];

    // Pecah berdasarkan baris baru atau nomor langkah
    final lines = instructions
        .split(RegExp(r'\r?\n+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.length > 3)
        .toList();

    return lines;
  }
}
