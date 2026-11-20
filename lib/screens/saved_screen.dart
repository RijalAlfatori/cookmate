import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/state_view.dart';
import 'detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SavedScreen — Resep Tersimpan (tersedia offline)
// List kartu horizontal dengan thumbnail 80x80 rounded, badge kategori,
// preview catatan pribadi, swipe-to-dismiss + dialog konfirmasi & SnackBar Undo.
// ─────────────────────────────────────────────────────────────────────────────

class SavedScreen extends StatefulWidget {
  /// Callback untuk pindah ke tab Home (dari empty state)
  final VoidCallback? onGoHome;
  const SavedScreen({super.key, this.onGoHome});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final StorageService _storage = StorageService();
  List<Meal> _saved = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Load dari SharedPreferences ───────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _isLoading = true);
    final meals = await _storage.getSavedRecipes();
    if (mounted) {
      setState(() {
        _saved = meals;
        _isLoading = false;
      });
    }
  }

  // ── Hapus dengan Undo SnackBar ────────────────────────────────────────────
  Future<void> _delete(Meal meal) async {
    final idx = _saved.indexOf(meal);
    setState(() => _saved.remove(meal));
    await _storage.removeRecipe(meal.idMeal);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"${meal.strMeal}" dihapus dari favorit',
                style: AppTextStyles.bodyMd(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textSecondary,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: AppColors.accent,
          onPressed: () async {
            await _storage.saveRecipe(meal);
            if (mounted) {
              setState(() {
                _saved.insert(idx.clamp(0, _saved.length), meal);
              });
            }
          },
        ),
      ),
    );
  }

  // ── Dialog konfirmasi hapus via tombol trash ─────────────────────────────
  Future<void> _confirmDelete(Meal meal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Resep?', style: AppTextStyles.titleMd()),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${meal.strMeal}" dari daftar favorit?',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: AppTextStyles.label(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _delete(meal);
    }
  }

  // ── Navigasi ke detail (data lokal → offline support) ─────────────────────
  Future<void> _goToDetail(Meal meal) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            FadeTransition(opacity: anim, child: DetailScreen(meal: meal)),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
    // Refresh setelah kembali (mungkin catatan diperbarui)
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            Expanded(child: _buildBody(isDark)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        24,
        AppTheme.pagePadding,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resep Tersimpan',
                  style: AppTextStyles.display(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoading
                      ? 'Memuat...'
                      : '${_saved.length} resep favoritmu',
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
              Icons.bookmark_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        children: const [
          ShimmerListTile(),
          ShimmerListTile(),
          ShimmerListTile(),
        ],
      );
    }

    if (_saved.isEmpty) {
      return StateView(
        icon: Icons.bookmark_border_rounded,
        title: 'Belum Ada Resep Favorit',
        description:
            'Simpan resep kesukaanmu dengan menekan ikon 🔖 pada halaman detail resep.',
        action: FilledButton.icon(
          onPressed: widget.onGoHome,
          icon: const Icon(Icons.explore_rounded, size: 18),
          label: const Text('Jelajahi Resep'),
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding,
          0,
          AppTheme.pagePadding,
          24,
        ),
        itemCount: _saved.length,
        itemBuilder: (_, i) {
          final meal = _saved[i];
          return _buildSavedCard(meal, isDark);
        },
      ),
    );
  }

  // ── Kartu item tersimpan (Thumbnail 80x80, Swipe-to-dismiss) ──────────────
  Widget _buildSavedCard(Meal meal, bool isDark) {
    return Dismissible(
      key: Key('saved-${meal.idMeal}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(meal),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
        ),
      ),
      child: GestureDetector(
        onTap: () => _goToDetail(meal),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Thumbnail Rounded (80x80) ──────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  meal.strMealThumb,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.primarySoft,
                    child: const Icon(Icons.restaurant_rounded,
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Informasi resep ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal,
                      style: AppTextStyles.cardTitleLg(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Badge kategori & area
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (meal.strCategory != null)
                          _miniChip(meal.strCategory!, AppColors.primary,
                              AppColors.primarySoft),
                        if (meal.strArea != null)
                          _miniChip(
                            meal.strArea!,
                            const Color(0xFF1565C0),
                            const Color(0xFFE3F2FD),
                          ),
                      ],
                    ),
                    // Preview catatan pribadi (maksimal 2 baris, italic, sticky note icon)
                    if (meal.personalNote?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.sticky_note_2_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meal.personalNote!,
                              style: AppTextStyles.captionSm(
                                color: isDark
                                    ? AppColors.darkTextSec
                                    : AppColors.textSecondary,
                              ).copyWith(fontStyle: FontStyle.italic),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Tombol hapus (Trash Icon) ───────────────────────────
              IconButton(
                tooltip: 'Hapus dari favorit',
                onPressed: () => _confirmDelete(meal),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.error.withValues(alpha: 0.08),
                  minimumSize: const Size(44, 44),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSm(color: textColor),
      ),
    );
  }
}
