import 'dart:async';
import 'package:flutter/material.dart';
import 'services/question_service_optimized.dart';
import 'services/settings_service.dart';
import 'services/localization_service.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/enhanced_premium_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'theme/app_theme.dart';
import 'home.dart' as home_screen;
import 'screens/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print('[main] 🚀 Démarrage de Quiz4U...');

  // Lancer l'application avec l'écran de chargement
  // Toutes les initialisations se feront dans LoadingScreen
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _themeMode = 'système';
  StreamSubscription<String>? _languageSubscription;
  String _currentLanguage = 'fr'; // Langue actuelle pour forcer le rebuild

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadCurrentLanguage();
    _setupLanguageListener();
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LocalizationService.getCurrentLanguage();
    setState(() {
      _currentLanguage = language;
    });
  }

  void _setupLanguageListener() {
    // Écouter les changements de langue
    _languageSubscription =
        LocalizationService.languageChangeStream.listen((language) async {
      print('[MyApp] 🌍 Changement de langue détecté: $language');

      // 🌍 Recharger les questions traduites
      try {
        await QuestionServiceOptimized.reloadQuestionsForLanguage(language);
        print('[MyApp] ✅ Questions rechargées pour langue: $language');
      } catch (e) {
        print('[MyApp] ⚠️ Erreur rechargement questions: $e');
      }

      // Forcer le rebuild COMPLET de toute l'application avec une nouvelle clé
      if (mounted) {
        setState(() {
          _currentLanguage = language;
        });
        print('[MyApp] ✅ Interface complète rechargée avec langue: $language');
      }
    });
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await SettingsService.getThemeMode();

    // Validation du thème - s'assurer qu'il correspond aux options disponibles
    final validThemeModes = ['clair', 'sombre', 'système'];
    final validatedThemeMode =
        validThemeModes.contains(themeMode) ? themeMode : 'système';

    setState(() {
      _themeMode = validatedThemeMode;
    });
    print('[MyApp] 🎨 Thème chargé: $_themeMode (validé: $validatedThemeMode)');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(
          _currentLanguage), // Clé qui change avec la langue pour forcer le rebuild
      title: 'Quizz4u',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _getThemeMode(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/home': (context) =>
            home_screen.HomeScreen(key: ValueKey(_currentLanguage)),
        '/about': (context) => AboutScreen(key: ValueKey(_currentLanguage)),
        '/settings': (context) => SettingsScreen(
              key: ValueKey(_currentLanguage),
              onThemeChanged: _loadThemeMode,
            ),
        '/premium': (context) =>
            EnhancedPremiumScreen(key: ValueKey(_currentLanguage)),
        '/daily_challenge': (context) =>
            DailyChallengeScreen(key: ValueKey(_currentLanguage)),
        '/statistics': (context) =>
            LeaderboardScreen(key: ValueKey(_currentLanguage)),
        '/profile': (context) => ProfileScreen(key: ValueKey(_currentLanguage)),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // Utiliser les thèmes prédéfinis de AppTheme
    return brightness == Brightness.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  ThemeMode _getThemeMode() {
    switch (_themeMode) {
      case 'clair':
        return ThemeMode.light;
      case 'sombre':
        return ThemeMode.dark;
      case 'système':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
