// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'theme/theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
  final themeModeString = prefs.getString('theme_mode');
  final initialThemeMode = _themeModeFromString(themeModeString);

  final Widget initialScreen = hasCompletedOnboarding
      ? const HomeScreen()
      : const OnboardingScreen();

  runApp(
    MineralScannerApp(
      initialScreen: initialScreen,
      initialThemeMode: initialThemeMode,
      prefs: prefs,
    ),
  );
}

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.light;
  }
}

class MineralScannerApp extends StatefulWidget {
  final Widget initialScreen;
  final ThemeMode initialThemeMode;
  final SharedPreferences prefs;

  const MineralScannerApp({
    super.key,
    required this.initialScreen,
    required this.initialThemeMode,
    required this.prefs,
  });

  @override
  State<MineralScannerApp> createState() => _MineralScannerAppState();
}

class _MineralScannerAppState extends State<MineralScannerApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController(widget.initialThemeMode);
    _themeController.addListener(_persistThemeMode);
  }

  @override
  void dispose() {
    _themeController.removeListener(_persistThemeMode);
    _themeController.dispose();
    super.dispose();
  }

  void _persistThemeMode() {
    widget.prefs.setString('theme_mode', _themeController.value.name);
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F7A8C),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF1F7A8C),
          onPrimary: Colors.white,
          secondary: const Color(0xFF022B3A),
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF022B3A),
        );

    final darkColorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F7A8C),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF4EB1D1),
          onPrimary: const Color(0xFF01121D),
          secondary: const Color(0xFF9BCFF2),
          surface: const Color(0xFF0B1D2A),
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFC4D2E1),
        );

    return ThemeControllerScope(
      notifier: _themeController,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Mineral Scanner',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(lightColorScheme),
            darkTheme: _buildTheme(darkColorScheme),
            themeMode: themeMode,
            home: widget.initialScreen,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    final base = colorScheme.brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surface.withValues(alpha: 0.92)
            : colorScheme.surface,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
