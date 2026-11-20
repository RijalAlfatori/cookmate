import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/cook_search_bar.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/state_view.dart';
import 'detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — Eksplorasi & Pencarian Resep
// Header sapaan dinamis, Search bar, Category chips scrollable to center,
// Staggered animated recipe grid, Loading shimmer, Error & Empty state.
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Pertahankan state saat tab berganti

  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _chipScroll = ScrollController();

  List<MealCategory> _categories = [];
  List<Meal> _meals = [];

  String _selectedCategory = 'Beef';
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _errorMsg;

  // Fallback kategori statis jika API gagal dimuat
  static const List<String> _fallbackCats = [
    'Beef',
    'Chicken',
    'Seafood',
    'Dessert',
    'Pasta',
    'Vegetarian',
    'Lamb',
    'Pork',
    'Side',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadByCategory(_selectedCategory);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _chipScroll.dispose();
    super.dispose();
  }

  // ── Sapaan dinamis sesuai jam ──────────────────────────────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi 👋';
    if (hour < 15) return 'Selamat siang 👋';
    if (hour < 18) return 'Selamat sore 👋';
    return 'Selamat malam 👋';
  }

  // ── Load kategori dari API ─────────────────────────────────────────────────
  Future<void> _loadCategories() async {
    try {
      final cats = await _api.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
      // Menggunakan fallback statis
    }
  }

  // ── Load resep berdasarkan kategori ───────────────────────────────────────
  Future<void> _loadByCategory(String cat) async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
      _errorMsg = null;
      _searchQuery = '';
    });
    _searchCtrl.clear();
    try {
      final meals = await _api.getMealsByCategory(cat);
      if (mounted) {
        setState(() {
          _meals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ── Pencarian resep secara real-time ──────────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _loadByCategory(_selectedCategory);
      return;
    }
    setState(() {
      _isLoading = true;
      _isSearching = true;
      _errorMsg = null;
      _searchQuery = query.trim();
    });
    try {
      final meals = await _api.searchMeals(query.trim());
      if (mounted) {
        setState(() {
          _meals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ── Handle klik kategori dengan scroll otomatis ke tengah ─────────────────
  void _onCategoryTap(String cat, int index) {
    setState(() => _selectedCategory = cat);
    _loadByCategory(cat);

    // Gulir chip aktif otomatis ke tengah
    if (_chipScroll.hasClients) {
      const approxChipWidth = 100.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final targetOffset =
          (index * approxChipWidth) - (screenWidth / 2) + (approxChipWidth / 2);
      final clampedOffset = targetOffset.clamp(
        0.0,
        _chipScroll.position.maxScrollExtent,
      );
      _chipScroll.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToDetail(Meal meal) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: DetailScreen(meal: meal),
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _isSearching
              ? _search(_searchQuery)
              : _loadByCategory(_selectedCategory),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(theme)),
              // ── Search Bar ──────────────────────────────────────────
              SliverToBoxAdapter(child: _buildSearchBar()),
              // ── Kategori Horizontal ─────────────────────────────────
              if (!_isSearching) SliverToBoxAdapter(child: _buildCategories()),
              // ── Section Title ("Rekomendasi untukmu" + counter) ──────
              SliverToBoxAdapter(child: _buildSectionTitle(theme)),
              // ── Konten Grid / Shimmer / Error / Empty ───────────────
              _buildSliverContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        24,
        AppTheme.pagePadding,
        4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.darkTextSec : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mau masak apa hari ini?',
                  style: AppTextStyles.display(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Logo Badge
          Semantics(
            label: 'CookMate App Logo',
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.chipShadow,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: 16,
      ),
      child: CookSearchBar(
        hintText: 'Cari resep favoritmu...',
        controller: _searchCtrl,
        onChanged: _search,
        onSubmitted: _search,
        onCleared: () => _loadByCategory(_selectedCategory),
      ),
    );
  }

  // ── Chips Kategori ────────────────────────────────────────────────────────
  Widget _buildCategories() {
    final names = _categories.isNotEmpty
        ? _categories.map((c) => c.strCategory).toList()
        : _fallbackCats;

    return SizedBox(
      height: 46,
      child: ListView.builder(
        controller: _chipScroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        itemCount: names.length,
        itemBuilder: (_, i) {
          final cat = names[i];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              label: cat,
              isSelected: isSelected,
              onTap: () => _onCategoryTap(cat, i),
            ),
          );
        },
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        22,
        AppTheme.pagePadding,
        14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                _isSearching ? 'Hasil: "$_searchQuery"' : 'Rekomendasi untukmu',
                style: AppTextStyles.titleMd(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              if (!_isSearching) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedCategory,
                    style: AppTextStyles.captionSm(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
          if (!_isLoading && _meals.isNotEmpty)
            Text(
              '${_meals.length} resep',
              style: AppTextStyles.caption(
                color: isDark ? AppColors.darkTextSec : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // ── Sliver Konten Utama ───────────────────────────────────────────────────
  Widget _buildSliverContent() {
    // 1. Loading State (Shimmer Skeleton Grid)
    if (_isLoading) {
      return const SliverShimmerGrid(itemCount: 6);
    }

    // 2. Error State (Pesan ramah + Tombol Coba Lagi)
    if (_errorMsg != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          message: _errorMsg!,
          onRetry: () => _isSearching
              ? _search(_searchQuery)
              : _loadByCategory(_selectedCategory),
        ),
      );
    }

    // 3. Empty State (Resep tidak ditemukan)
    if (_meals.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: StateView(
          icon: Icons.no_meals_rounded,
          title: 'Resep Tidak Ditemukan',
          description: _isSearching
              ? 'Coba kata kunci lain atau periksa ejaan pencarianmu.'
              : 'Belum ada resep di kategori ini.',
          action: _isSearching
              ? FilledButton.icon(
                  onPressed: () {
                    _searchCtrl.clear();
                    _loadByCategory(_selectedCategory);
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Kembali ke Beranda'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTextStyles.button(),
                  ),
                )
              : null,
        ),
      );
    }

    // 4. Success State (GridView dengan animasi staggered)
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        0,
        AppTheme.pagePadding,
        24,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final meal = _meals[index];
            return _StaggeredCard(
              index: index,
              child: RecipeCard(
                idMeal: meal.idMeal,
                name: meal.strMeal,
                imageUrl: meal.strMealThumb,
                category: meal.strCategory,
                onTap: () => _goToDetail(meal),
              ),
            );
          },
          childCount: _meals.length,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StaggeredCard — animasi fade & slide-up bertahap saat kartu grid dimuat
// ─────────────────────────────────────────────────────────────────────────────

class _StaggeredCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredCard({required this.index, required this.child});

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final delay = (widget.index % 10) * 45; // stagger delay ms
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
