import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _ttsEnabledKey = 'tts_enabled';
  static const String _timerDurationKey = 'timer_duration';
  static const String _backgroundMusicEnabledKey = 'background_music_enabled';
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _difficultyLevelKey = 'difficulty_level';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _adsEnabledKey = 'ads_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Thème
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'système';
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  // Sons
  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  // TTS
  static Future<bool> isTtsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ttsEnabledKey) ?? true;
  }

  static Future<void> setTtsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, enabled);
  }

  // Timer
  static Future<int> getTimerDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timerDurationKey) ?? 15;
  }

  static Future<void> setTimerDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timerDurationKey, duration);
  }

  // Musique de fond
  static Future<bool> isBackgroundMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_backgroundMusicEnabledKey) ?? true;
  }

  static Future<void> setBackgroundMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backgroundMusicEnabledKey, enabled);
  }

  // Animations
  static Future<bool> areAnimationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_animationsEnabledKey) ?? true;
  }

  static Future<void> setAnimationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, enabled);
  }

  // Niveau de difficulté
  static Future<String> getDifficultyLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_difficultyLevelKey) ?? 'moyen';
  }

  static Future<String> getDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_difficultyLevelKey) ?? 'moyen';
  }

  static Future<void> setDifficultyLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyLevelKey, level);
  }

  // Durée du timer selon la difficulté
  static int getTimerDurationForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
        return 45;
      case 'difficile':
        return 25;
      case 'moyen':
      default:
        return 35;
    }
  }

  // Vibrations
  static Future<bool> isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }

  // Publicités
  static Future<bool> isAdsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adsEnabledKey) ?? true;
  }

  static Future<void> setAdsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsEnabledKey, enabled);
  }

  // Notifications
  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Volumes
  static Future<double> getMasterVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('master_volume') ?? 1.0;
  }

  static Future<void> setMasterVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('master_volume', volume);
  }

  static Future<double> getBackgroundVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('background_volume') ?? 0.3;
  }

  static Future<void> setBackgroundVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('background_volume', volume);
  }

  static Future<double> getEffectVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('effect_volume') ?? 0.7;
  }

  static Future<void> setEffectVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('effect_volume', volume);
  }

  // Réinitialisation
  static Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('[SettingsService] ✅ Tous les paramètres réinitialisés');
  }

  // Effacer toutes les données
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('[SettingsService] ✅ Toutes les données effacées');
  }
}
