import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlameAudioManager {
  static FlameAudioManager? _instance;
  static FlameAudioManager get instance => _instance ??= FlameAudioManager._();

  FlameAudioManager._();

  // Gestionnaires audio
  AudioPlayer? _backgroundMusic;

  // État audio
  bool _isInitialized = false;
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  double _backgroundVolume = 0.3;
  double _effectsVolume = 0.7;

  // Cache des sons préchargés
  final Map<String, String> _cachedSounds = {};

  /// Initialise le gestionnaire audio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[FlameAudioManager] 🔄 Initialisation...');

      // Charger les paramètres sauvegardés
      await _loadSettings();

      // Précharger les sons
      await _preloadSounds();

      _isInitialized = true;
      print('[FlameAudioManager] ✅ Initialisation réussie');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur d\'initialisation: $e');
    }
  }

  /// Charge les paramètres audio sauvegardés
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _backgroundMusicEnabled = prefs.getBool('background_music_enabled') ?? true;
    _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
    _backgroundVolume = prefs.getDouble('background_volume') ?? 0.3;
    _effectsVolume = prefs.getDouble('effects_volume') ?? 0.7;

    print(
        '[FlameAudioManager] ⚙️ Paramètres chargés: musique=$_backgroundMusicEnabled, sons=$_soundEffectsEnabled');
  }

  /// Sauvegarde les paramètres audio
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('background_music_enabled', _backgroundMusicEnabled);
    await prefs.setBool('sound_effects_enabled', _soundEffectsEnabled);
    await prefs.setDouble('background_volume', _backgroundVolume);
    await prefs.setDouble('effects_volume', _effectsVolume);
  }

  /// Précharge tous les sons
  Future<void> _preloadSounds() async {
    try {
      print('[FlameAudioManager] 🎵 Préchargement des sons...');

      // Sons principaux
      _cachedSounds['background'] = 'sounds/background.mp3';
      _cachedSounds['good'] = 'sounds/good.mp3';
      _cachedSounds['bad'] = 'sounds/bad.mp3';
      _cachedSounds['click'] = 'sounds/click.mp3';

      print('[FlameAudioManager] ✅ Sons préchargés');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur préchargement: $e');
    }
  }

  /// Joue la musique de fond
  Future<void> playBackgroundMusic() async {
    if (!_backgroundMusicEnabled || !_isInitialized) return;

    try {
      // Arrêter la musique précédente
      await stopBackgroundMusic();

      // Créer un nouveau lecteur
      _backgroundMusic = AudioPlayer();

      // Charger et jouer la musique
      await _backgroundMusic!
          .setSource(AssetSource(_cachedSounds['background']!));
      await _backgroundMusic!.setVolume(_backgroundVolume);
      await _backgroundMusic!.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusic!.resume();

      print('[FlameAudioManager] 🎵 Musique de fond lancée');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur musique de fond: $e');
    }
  }

  /// Arrête la musique de fond
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusic?.stop();
      await _backgroundMusic?.dispose();
      _backgroundMusic = null;
      print('[FlameAudioManager] ⏹️ Musique de fond arrêtée');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur arrêt musique: $e');
    }
  }

  /// Met en pause la musique de fond
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusic?.pause();
      print('[FlameAudioManager] ⏸️ Musique de fond en pause');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur pause musique: $e');
    }
  }

  /// Reprend la musique de fond
  Future<void> resumeBackgroundMusic() async {
    try {
      await _backgroundMusic?.resume();
      print('[FlameAudioManager] ▶️ Musique de fond reprise');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur reprise musique: $e');
    }
  }

  /// Joue un effet sonore
  Future<void> playSoundEffect(String soundName) async {
    if (!_soundEffectsEnabled || !_isInitialized) return;

    try {
      final audioSource = _cachedSounds[soundName];
      if (audioSource == null) {
        print('[FlameAudioManager] ⚠️ Son non trouvé: $soundName');
        return;
      }

      // Créer un lecteur temporaire pour l'effet sonore
      final player = AudioPlayer();
      await player.setSource(AssetSource(audioSource));
      await player.setVolume(_effectsVolume);
      await player.resume();

      // Nettoyer automatiquement après la lecture
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });

      print('[FlameAudioManager] 🔊 Effet sonore joué: $soundName');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur effet sonore: $e');
    }
  }

  /// Joue le son "good"
  Future<void> playGoodSound() async {
    await playSoundEffect('good');
  }

  /// Joue le son "bad"
  Future<void> playBadSound() async {
    await playSoundEffect('bad');
  }

  /// Joue le son de clic
  Future<void> playClickSound() async {
    await playSoundEffect('click');
  }

  /// Active/désactive la musique de fond
  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _backgroundMusicEnabled = enabled;
    await _saveSettings();

    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }

    print(
        '[FlameAudioManager] 🎵 Musique de fond: ${enabled ? "activée" : "désactivée"}');
  }

  /// Active/désactive les effets sonores
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _soundEffectsEnabled = enabled;
    await _saveSettings();
    print(
        '[FlameAudioManager] 🔊 Effets sonores: ${enabled ? "activés" : "désactivés"}');
  }

  /// Définit le volume de la musique de fond
  Future<void> setBackgroundVolume(double volume) async {
    _backgroundVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();

    if (_backgroundMusic != null) {
      await _backgroundMusic!.setVolume(_backgroundVolume);
    }

    print(
        '[FlameAudioManager] 🔊 Volume musique: ${(_backgroundVolume * 100).round()}%');
  }

  /// Définit le volume des effets sonores
  Future<void> setEffectsVolume(double volume) async {
    _effectsVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    print(
        '[FlameAudioManager] 🔊 Volume effets: ${(_effectsVolume * 100).round()}%');
  }

  /// Getters pour l'état
  bool get isBackgroundMusicEnabled => _backgroundMusicEnabled;
  bool get isSoundEffectsEnabled => _soundEffectsEnabled;
  double get backgroundVolume => _backgroundVolume;
  double get effectsVolume => _effectsVolume;
  bool get isInitialized => _isInitialized;

  /// Nettoie les ressources
  Future<void> dispose() async {
    try {
      await stopBackgroundMusic();
      _cachedSounds.clear();
      _isInitialized = false;
      print('[FlameAudioManager] 🧹 Ressources libérées');
    } catch (e) {
      print('[FlameAudioManager] ❌ Erreur nettoyage: $e');
    }
  }
}
