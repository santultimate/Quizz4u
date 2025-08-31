import 'package:shared_preferences/shared_preferences.dart';
import 'enhanced_sound_manager.dart';

/// Service unifié pour la gestion audio
/// Facade simple pour EnhancedSoundManager
class UnifiedAudioService {
  static UnifiedAudioService? _instance;
  static UnifiedAudioService get instance =>
      _instance ??= UnifiedAudioService._();

  UnifiedAudioService._();

  // Gestionnaire audio principal
  final EnhancedSoundManager _enhancedManager = EnhancedSoundManager();

  // État
  bool _isInitialized = false;

  /// Initialise le service audio unifié
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print(
          '[UnifiedAudioService] 🔄 Initialisation du service audio unifié...');

      // Initialiser le gestionnaire audio
      await _enhancedManager.initialize();

      _isInitialized = true;
      print('[UnifiedAudioService] ✅ Service audio unifié initialisé');
    } catch (e) {
      print('[UnifiedAudioService] ❌ Erreur d\'initialisation: $e');
    }
  }

  // ===== MUSIQUE DE FOND =====

  /// Joue la musique de fond
  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) return;

    // Vérifier si la musique est activée
    final prefs = await SharedPreferences.getInstance();
    final musicEnabled = prefs.getBool('background_music_enabled') ?? true;

    if (!musicEnabled) {
      print(
          '[UnifiedAudioService] 🔇 Musique de fond désactivée dans les paramètres');
      return;
    }

    print('[UnifiedAudioService] 🎵 Lancement musique de fond...');
    await _enhancedManager.playBackgroundMusic();
  }

  /// Arrête la musique de fond
  Future<void> stopBackgroundMusic() async {
    if (!_isInitialized) return;
    await _enhancedManager.stopBackgroundMusic();
  }

  /// Met en pause la musique de fond
  Future<void> pauseBackgroundMusic() async {
    if (!_isInitialized) return;
    await _enhancedManager.pauseBackgroundMusic();
  }

  /// Reprend la musique de fond
  Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized) return;
    await _enhancedManager.resumeBackgroundMusic();
  }

  // ===== EFFETS SONORES =====

  /// Joue le son de bonne réponse
  Future<void> playGoodSound() async {
    if (!_isInitialized) return;
    await _enhancedManager.playGoodSound();
  }

  /// Joue le son de mauvaise réponse
  Future<void> playBadSound() async {
    if (!_isInitialized) return;
    await _enhancedManager.playBadSound();
  }

  /// Joue le son de clic
  Future<void> playClickSound() async {
    if (!_isInitialized) return;
    // Utiliser le son good comme son de clic
    await _enhancedManager.playGoodSound();
  }

  // ===== GESTION DES PUBLICITÉS =====

  /// Indique qu'une publicité commence
  void setAdPlaying(bool isPlaying) {
    if (!_isInitialized) return;
    _enhancedManager.setAdPlaying(isPlaying);
  }

  // ===== PARAMÈTRES =====

  /// Active/désactive les effets sonores
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    if (!_isInitialized) return;

    print('[UnifiedAudioService] 🔊 Changement effets sonores: $enabled');
    await _enhancedManager.setSoundEnabled(enabled);

    // Sauvegarder la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    print(
        '[UnifiedAudioService] ✅ Effets sonores ${enabled ? 'activés' : 'désactivés'}');
  }

  /// Active/désactive la musique de fond
  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    if (!_isInitialized) return;

    print('[UnifiedAudioService] �� Changement musique de fond: $enabled');
    await _enhancedManager.setBackgroundMusicEnabled(enabled);

    // Sauvegarder la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_music_enabled', enabled);

    print(
        '[UnifiedAudioService] ✅ Musique de fond ${enabled ? 'activée' : 'désactivée'}');
  }

  /// Définit le volume de la musique de fond
  Future<void> setBackgroundVolume(double volume) async {
    if (!_isInitialized) return;
    await _enhancedManager.setBackgroundVolume(volume);
  }

  /// Définit le volume des effets sonores
  Future<void> setEffectsVolume(double volume) async {
    if (!_isInitialized) return;
    await _enhancedManager.setEffectVolume(volume);
  }

  /// Définit le volume principal
  Future<void> setMasterVolume(double volume) async {
    if (!_isInitialized) return;
    await _enhancedManager.setMasterVolume(volume);
  }

  /// Réinitialise les paramètres audio
  Future<void> resetSettings() async {
    if (!_isInitialized) return;

    print('[UnifiedAudioService] 🔄 Réinitialisation des paramètres audio');

    // Réinitialiser le gestionnaire audio
    await _enhancedManager.setSoundEnabled(true);
    await _enhancedManager.setBackgroundMusicEnabled(true);
    await _enhancedManager.setMasterVolume(1.0);
    await _enhancedManager.setBackgroundVolume(0.3);
    await _enhancedManager.setEffectVolume(0.7);

    print('[UnifiedAudioService] ✅ Paramètres audio réinitialisés');
  }

  // ===== GETTERS =====

  /// Getters pour l'état
  bool get isSoundEffectsEnabled => _enhancedManager.soundEnabled;
  bool get isBackgroundMusicEnabled => _enhancedManager.backgroundMusicEnabled;
  double get backgroundVolume => _enhancedManager.backgroundVolume;
  double get effectsVolume => _enhancedManager.effectVolume;
  bool get isInitialized => _isInitialized;
  bool get isAdPlaying => _enhancedManager.isAdPlaying;

  // ===== NETTOYAGE =====

  /// Nettoie les ressources
  Future<void> dispose() async {
    try {
      await _enhancedManager.dispose();
      _isInitialized = false;
      print('[UnifiedAudioService] 🧹 Ressources libérées');
    } catch (e) {
      print('[UnifiedAudioService] ❌ Erreur nettoyage: $e');
    }
  }
}
