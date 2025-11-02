// lib/services/localization_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';

  // Langues supportées (6 langues dont les 3 plus parlées au monde)
  static const List<String> supportedLanguages = [
    'fr',
    'en',
    'ar',
    'zh',
    'hi',
    'es'
  ];
  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'ar': 'العربية',
    'zh': '中文', // Chinois Mandarin
    'hi': 'हिन्दी', // Hindi
    'es': 'Español', // Espagnol
  };

  // StreamController pour notifier les changements de langue
  static final StreamController<String> _languageChangeController =
      StreamController<String>.broadcast();

  // Stream pour écouter les changements de langue
  static Stream<String> get languageChangeStream =>
      _languageChangeController.stream;

  // Obtenir la langue actuelle
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'fr'; // Français par défaut
  }

  // Définir la langue
  static Future<void> setLanguage(String language) async {
    if (!supportedLanguages.contains(language)) {
      throw ArgumentError('Langue non supportée: $language');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    print('[LocalizationService] 🌍 Langue changée vers: $language');

    // Notifier tous les écouteurs du changement de langue
    _languageChangeController.add(language);
  }

  // Détecter la langue du système
  static String detectSystemLanguage() {
    // Pour l'instant, retourner français par défaut
    // Dans une vraie implémentation, on utiliserait Platform.localeName
    return 'fr';
  }

  // Vérifier si une langue est supportée
  static bool isLanguageSupported(String language) {
    return supportedLanguages.contains(language);
  }

  // Obtenir le nom d'affichage de la langue
  static String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
}
