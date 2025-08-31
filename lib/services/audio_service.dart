import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service audio unifié pour Quizz4U
/// Remplace tous les autres gestionnaires audio pour éviter les conflits
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();

  AudioService._();

  // Lecteurs audio
  late AudioPlayer _backgroundPlayer;
  late AudioPlayer _effectPlayer;

  // État
  bool _isInitialized = false;
  bool _soundEnabled = true;
  bool _backgroundMusicEnabled = true;

  // Volumes
  double _masterVolume = 1.0;
  double _backgroundVolume = 0.2;
  double _effectVolume = 0.7;

  // Chemins des fichiers audio
  static const String _backgroundMusicPath = 'sounds/background.mp3';
  static const String _goodSoundPath = 'sounds/good.mp3';
  static const String _badSoundPath = 'sounds/bad.mp3';

  /// Initialise le service audio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[AudioService] 🔄 Initialisation du service audio...');

      // Configuration audio globale
      AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      // Créer les lecteurs
      _backgroundPlayer = AudioPlayer();
      _effectPlayer = AudioPlayer();

      // Configuration des lecteurs
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _effectPlayer.setReleaseMode(ReleaseMode.stop);

      // Charger les paramètres
      await _loadSettings();

      _isInitialized = true;
      print('[AudioService] ✅ Service audio initialisé');
    } catch (e) {
      print('[AudioService] ❌ Erreur d\'initialisation: $e');
    }
  }

  /// Charge les paramètres audio
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _backgroundMusicEnabled =
          prefs.getBool('background_music_enabled') ?? true;
      _masterVolume = prefs.getDouble('master_volume') ?? 1.0;
      _backgroundVolume = prefs.getDouble('background_volume') ?? 0.2;
      _effectVolume = prefs.getDouble('effect_volume') ?? 0.7;

      print('[AudioService] ⚙️ Paramètres chargés');
    } catch (e) {
      print('[AudioService] ❌ Erreur chargement paramètres: $e');
    }
  }

  /// Sauvegarde les paramètres audio
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('background_music_enabled', _backgroundMusicEnabled);
      await prefs.setDouble('master_volume', _masterVolume);
      await prefs.setDouble('background_volume', _backgroundVolume);
      await prefs.setDouble('effect_volume', _effectVolume);
    } catch (e) {
      print('[AudioService] ❌ Erreur sauvegarde paramètres: $e');
    }
  }

  /// Joue la musique de fond
  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) await initialize();
    if (!_backgroundMusicEnabled || !_soundEnabled) {
      print('[AudioService] 🔇 Musique de fond désactivée');
      return;
    }

    try {
      print('[AudioService] 🎵 Lancement musique de fond...');

      await _backgroundPlayer.stop();
      await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);
      await _backgroundPlayer.play(AssetSource(_backgroundMusicPath));

      print('[AudioService] ✅ Musique de fond lancée');
    } catch (e) {
      print('[AudioService] ❌ Erreur musique de fond: $e');
    }
  }

  /// Arrête la musique de fond
  Future<void> stopBackgroundMusic() async {
    if (!_isInitialized) return;

    try {
      await _backgroundPlayer.stop();
      print('[AudioService] ⏹️ Musique de fond arrêtée');
    } catch (e) {
      print('[AudioService] ❌ Erreur arrêt musique: $e');
    }
  }

  /// Met en pause la musique de fond
  Future<void> pauseBackgroundMusic() async {
    if (!_isInitialized) return;

    try {
      await _backgroundPlayer.pause();
      print('[AudioService] ⏸️ Musique de fond mise en pause');
    } catch (e) {
      print('[AudioService] ❌ Erreur pause musique: $e');
    }
  }

  /// Reprend la musique de fond
  Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized) return;

    try {
      await _backgroundPlayer.resume();
      print('[AudioService] ▶️ Musique de fond reprise');
    } catch (e) {
      print('[AudioService] ❌ Erreur reprise musique: $e');
    }
  }

  /// Joue le son de bonne réponse
  Future<void> playGoodSound() async {
    if (!_isInitialized) await initialize();
    if (!_soundEnabled) {
      print('[AudioService] 🔇 Sons désactivés');
      return;
    }

    try {
      print('[AudioService] ✅ Lecture son bonne réponse');

      await _effectPlayer.stop();
      await _effectPlayer.setVolume(_effectVolume * _masterVolume);
      await _effectPlayer.play(AssetSource(_goodSoundPath));

      print('[AudioService] ✅ Son bonne réponse joué');
    } catch (e) {
      print('[AudioService] ❌ Erreur son bonne réponse: $e');
    }
  }

  /// Joue le son de mauvaise réponse
  Future<void> playBadSound() async {
    if (!_isInitialized) await initialize();
    if (!_soundEnabled) {
      print('[AudioService] 🔇 Sons désactivés');
      return;
    }

    try {
      print('[AudioService] ❌ Lecture son mauvaise réponse');

      await _effectPlayer.stop();
      await _effectPlayer.setVolume(_effectVolume * _masterVolume);
      await _effectPlayer.play(AssetSource(_badSoundPath));

      print('[AudioService] ✅ Son mauvaise réponse joué');
    } catch (e) {
      print('[AudioService] ❌ Erreur son mauvaise réponse: $e');
    }
  }

  /// Active/désactive les sons
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();

    if (!enabled) {
      await stopBackgroundMusic();
    } else if (_backgroundMusicEnabled) {
      await playBackgroundMusic();
    }

    print('[AudioService] 🔊 Sons ${enabled ? 'activés' : 'désactivés'}');
  }

  /// Active/désactive les effets sonores (alias pour setSoundEnabled)
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    await setSoundEnabled(enabled);
  }

  /// Active/désactive la musique de fond
  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _backgroundMusicEnabled = enabled;
    await _saveSettings();

    if (enabled && _soundEnabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }

    print(
        '[AudioService] 🎵 Musique de fond ${enabled ? 'activée' : 'désactivée'}');
  }

  /// Définit le volume principal
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _updateVolumes();
    print(
        '[AudioService] 🔊 Volume principal: ${(_masterVolume * 100).round()}%');
  }

  /// Définit le volume de la musique de fond
  Future<void> setBackgroundVolume(double volume) async {
    _backgroundVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _updateVolumes();
    print(
        '[AudioService] 🎵 Volume musique: ${(_backgroundVolume * 100).round()}%');
  }

  /// Définit le volume des effets
  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _updateVolumes();
    print('[AudioService] 🔊 Volume effets: ${(_effectVolume * 100).round()}%');
  }

  /// Alias pour setEffectVolume
  Future<void> setEffectsVolume(double volume) async {
    await setEffectVolume(volume);
  }

  /// Met à jour tous les volumes
  Future<void> _updateVolumes() async {
    try {
      await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);
      await _effectPlayer.setVolume(_effectVolume * _masterVolume);
    } catch (e) {
      print('[AudioService] ❌ Erreur mise à jour volumes: $e');
    }
  }

  /// Réinitialise les paramètres audio
  Future<void> resetSettings() async {
    print('[AudioService] 🔄 Réinitialisation des paramètres audio');

    await setSoundEnabled(true);
    await setBackgroundMusicEnabled(true);
    await setMasterVolume(1.0);
    await setBackgroundVolume(0.2);
    await setEffectVolume(0.7);

    print('[AudioService] ✅ Paramètres audio réinitialisés');
  }

  /// Getters pour l'état
  bool get soundEnabled => _soundEnabled;
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  double get masterVolume => _masterVolume;
  double get backgroundVolume => _backgroundVolume;
  double get effectVolume => _effectVolume;
  bool get isInitialized => _isInitialized;

  /// Nettoie les ressources
  Future<void> dispose() async {
    try {
      await _backgroundPlayer.dispose();
      await _effectPlayer.dispose();
      _isInitialized = false;
      print('[AudioService] 🧹 Ressources libérées');
    } catch (e) {
      print('[AudioService] ❌ Erreur nettoyage: $e');
    }
  }
}
