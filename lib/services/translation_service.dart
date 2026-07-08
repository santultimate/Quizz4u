// lib/services/translation_service.dart
import 'dart:convert';

import 'package:flutter/services.dart';

import 'localization_service.dart';

/// Service UI — source unique : assets/translations/{lang}.json
class TranslationService {
  static String _currentLanguage = 'fr';
  static bool _isListening = false;
  static bool _isLoaded = false;

  static final Map<String, Map<String, String>> _cache = {};

  static Future<void> initialize() async {
    _currentLanguage = await LocalizationService.getCurrentLanguage();
    await _loadLanguage(_currentLanguage);
    await _loadLanguage('fr');

    if (!_isListening) {
      LocalizationService.languageChangeStream.listen((language) async {
        _currentLanguage = language;
        await _loadLanguage(language);
      });
      _isListening = true;
    }

    _isLoaded = true;
    print('[TranslationService] 🌍 Langue initialisée: $_currentLanguage');
  }

  static Future<void> _loadLanguage(String language) async {
    if (_cache.containsKey(language)) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/translations/$language.json');
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        _cache[language] =
            decoded.map((key, value) => MapEntry(key, value.toString()));
        return;
      }
    } catch (e) {
      print('[TranslationService] ⚠️ Chargement $language: $e');
    }

    _cache[language] = {};
  }

  static Future<void> changeLanguage(String language) async {
    if (!LocalizationService.isLanguageSupported(language)) return;
    await LocalizationService.setLanguage(language);
    _currentLanguage = language;
    await _loadLanguage(language);
  }

  static String getCurrentLanguage() => _currentLanguage;

  static String translate(String key) {
    if (!_isLoaded) {
      return _cache[_currentLanguage]?[key] ??
          _cache['fr']?[key] ??
          key;
    }

    return _cache[_currentLanguage]?[key] ??
        _cache['fr']?[key] ??
        key;
  }

  static String translateWithParams(String key, Map<String, String> params) {
    var translation = translate(key);
    params.forEach((param, value) {
      translation = translation.replaceAll('{$param}', value);
    });
    return translation;
  }

  static bool hasTranslation(String key) {
    return _cache[_currentLanguage]?.containsKey(key) ??
        _cache['fr']?.containsKey(key) ??
        false;
  }

  static Map<String, String> getAllTranslations() {
    return Map<String, String>.from(
      _cache[_currentLanguage] ?? _cache['fr'] ?? {},
    );
  }
}
