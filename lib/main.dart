import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/planner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi portrait untuk kestabilan UI mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparan modern
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const CookMateApp());
}

/// Root widget aplikasi CookMate
class CookMateApp extends StatelessWidget {
  const CookMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookMate',
      debugShowCheckedModeBanner: false,
      // ─── Design System Themes (Light & Dark) ──────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
    );
  }
}

/// Navigasi Utama dengan Material 3 NavigationBar
/// Mengelola 3 tab: Jelajah (Home), Tersimpan (Favorit), dan Meal Planner
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onGoHome() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Halaman dipertahankan state-nya dengan IndexedStack
    final pages = [
      const HomeScreen(),
      SavedScreen(onGoHome: _onGoHome),
      PlannerScreen(onExplore: _onGoHome),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // ─── Material 3 NavigationBar (Floating / Rounded Top) ───────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Jelajah',
                tooltip: 'Halaman Eksplorasi Resep',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Tersimpan',
                tooltip: 'Halaman Resep Tersimpan',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Planner',
                tooltip: 'Halaman Meal Planner',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
