import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _difficultyKey = 'difficulty';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _ttsEnabledKey = 'tts_enabled';
  static const String _timerDurationKey = 'timer_duration';

  // Thème
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  // Difficulté
  static Future<String> getDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_difficultyKey) ?? 'normal';
  }

  static Future<void> setDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, difficulty);
  }

  // Son
  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  // Text-to-Speech
  static Future<bool> isTtsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ttsEnabledKey) ?? true;
  }

  static Future<void> setTtsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, enabled);
  }

  // Durée du timer
  static Future<int> getTimerDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timerDurationKey) ?? 15;
  }

  static Future<void> setTimerDuration(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timerDurationKey, seconds);
  }

  // Obtenir la durée du timer selon la difficulté
  static int getTimerDurationForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'facile':
        return 20;
      case 'normal':
        return 15;
      case 'difficile':
        return 10;
      default:
        return 15;
    }
  }
}
