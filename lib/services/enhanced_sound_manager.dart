import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedSoundManager {
  static final EnhancedSoundManager _instance =
      EnhancedSoundManager._internal();
  factory EnhancedSoundManager() => _instance;
  EnhancedSoundManager._internal();

  late AudioPlayer _backgroundPlayer;
  late AudioPlayer _effectPlayer;

  bool _isInitialized = false;
  bool _soundEnabled = true;
  bool _backgroundMusicEnabled = true;
  bool _isAdPlaying = false;

  double _masterVolume = 1.0;
  double _backgroundVolume = 0.3;
  double _effectVolume = 0.7;

  // Sound file paths
  static const String backgroundMusicPath = 'sounds/background.mp3';
  static const String goodSoundPath = 'sounds/good.mp3';
  static const String badSoundPath = 'sounds/bad.mp3';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[EnhancedSoundManager] 🔧 Début initialisation...');

      // Configuration du contexte audio global
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

      // Création des lecteurs
      _backgroundPlayer = AudioPlayer();
      _effectPlayer = AudioPlayer();

      // Configuration des modes de lecture
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _effectPlayer.setReleaseMode(ReleaseMode.stop);

      print(
          '[EnhancedSoundManager] 🔧 Mode boucle activé pour la musique de fond');

      // Chargement des paramètres
      await _loadSettings();

      _isInitialized = true;
      print('[EnhancedSoundManager] ✅ Initialisation réussie');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur d\'initialisation: $e');
      _isInitialized = false;
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _backgroundMusicEnabled =
          prefs.getBool('background_music_enabled') ?? true;
      _masterVolume = prefs.getDouble('master_volume') ?? 1.0;
      _backgroundVolume = prefs.getDouble('background_volume') ?? 0.3;
      _effectVolume = prefs.getDouble('effect_volume') ?? 0.7;

      print(
          '[EnhancedSoundManager] ⚙️ Paramètres chargés - Sons: $_soundEnabled, Musique: $_backgroundMusicEnabled');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur chargement paramètres: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('background_music_enabled', _backgroundMusicEnabled);
      await prefs.setDouble('master_volume', _masterVolume);
      await prefs.setDouble('background_volume', _backgroundVolume);
      await prefs.setDouble('effect_volume', _effectVolume);
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur sauvegarde paramètres: $e');
    }
  }

  // ===== LOGIQUE SIMPLIFIÉE POUR LA MUSIQUE DE FOND =====

  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) await initialize();

    // Vérifications de base
    if (!_backgroundMusicEnabled || !_soundEnabled) {
      print('[EnhancedSoundManager] 🔇 Musique de fond désactivée');
      return;
    }

    if (_isAdPlaying) {
      print(
          '[EnhancedSoundManager] 📺 Musique de fond ignorée (publicité en cours)');
      return;
    }

    try {
      print('[EnhancedSoundManager] 🎵 Lancement musique de fond');

      // Arrêter la musique en cours
      await _backgroundPlayer.stop();

      // Configurer et lancer
      await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);
      await _backgroundPlayer.setSource(AssetSource(backgroundMusicPath));
      await _backgroundPlayer.resume();

      print('[EnhancedSoundManager] ✅ Musique de fond lancée');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur musique de fond: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      print('[EnhancedSoundManager] ⏹️ Musique de fond arrêtée');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur arrêt musique: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      print('[EnhancedSoundManager] ⏸️ Musique de fond en pause');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur pause musique: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    try {
      await _backgroundPlayer.resume();
      print('[EnhancedSoundManager] ▶️ Musique de fond reprise');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur reprise musique: $e');
    }
  }

  // ===== LOGIQUE SIMPLIFIÉE POUR LES EFFETS SONORES =====

  Future<void> playGoodSound() async {
    if (!_isInitialized) await initialize();
    if (!_soundEnabled) {
      print('[EnhancedSoundManager] 🔇 Sons désactivés');
      return;
    }

    try {
      print('[EnhancedSoundManager] ✅ Lecture son bonne réponse');

      // Créer un nouveau lecteur pour éviter les conflits
      final player = AudioPlayer();
      await player.setVolume(_effectVolume * _masterVolume);
      await player.play(AssetSource(goodSoundPath));

      print('[EnhancedSoundManager] ✅ Son bonne réponse joué');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur son bonne réponse: $e');
    }
  }

  Future<void> playBadSound() async {
    if (!_isInitialized) await initialize();
    if (!_soundEnabled) {
      print('[EnhancedSoundManager] 🔇 Sons désactivés');
      return;
    }

    try {
      print('[EnhancedSoundManager] ❌ Lecture son mauvaise réponse');

      // Créer un nouveau lecteur pour éviter les conflits
      final player = AudioPlayer();
      await player.setVolume(_effectVolume * _masterVolume);
      await player.play(AssetSource(badSoundPath));

      print('[EnhancedSoundManager] ✅ Son mauvaise réponse joué');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur son mauvaise réponse: $e');
    }
  }

  // ===== GESTION DES PUBLICITÉS =====

  void setAdPlaying(bool isPlaying) {
    _isAdPlaying = isPlaying;
    print(
        '[EnhancedSoundManager] 📺 État publicité: ${isPlaying ? "en cours" : "terminée"}');
  }

  // ===== PARAMÈTRES =====

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();

    if (!enabled) {
      await stopBackgroundMusic();
    } else if (_backgroundMusicEnabled && !_isAdPlaying) {
      await playBackgroundMusic();
    }

    print(
        '[EnhancedSoundManager] 🔊 Sons ${enabled ? 'activés' : 'désactivés'}');
  }

  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _backgroundMusicEnabled = enabled;
    await _saveSettings();

    if (enabled && _soundEnabled && !_isAdPlaying) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }

    print(
        '[EnhancedSoundManager] 🎵 Musique de fond ${enabled ? 'activée' : 'désactivée'}');
  }

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _updateVolumes();
    print('[EnhancedSoundManager] 🔊 Volume principal: $_masterVolume');
  }

  Future<void> setBackgroundVolume(double volume) async {
    _backgroundVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _updateVolumes();
    print('[EnhancedSoundManager] 🎵 Volume musique: $_backgroundVolume');
  }

  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _updateVolumes();
    print('[EnhancedSoundManager] 🔊 Volume effets: $_effectVolume');
  }

  Future<void> _updateVolumes() async {
    try {
      await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);
      await _effectPlayer.setVolume(_effectVolume * _masterVolume);
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur mise à jour volumes: $e');
    }
  }

  // ===== GETTERS =====

  bool get soundEnabled => _soundEnabled;
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  double get masterVolume => _masterVolume;
  double get backgroundVolume => _backgroundVolume;
  double get effectVolume => _effectVolume;
  bool get isAdPlaying => _isAdPlaying;

  // ===== NETTOYAGE =====

  Future<void> dispose() async {
    try {
      await _backgroundPlayer.dispose();
      await _effectPlayer.dispose();
      _isInitialized = false;
      print('[EnhancedSoundManager] 🧹 Ressources libérées');
    } catch (e) {
      print('[EnhancedSoundManager] ❌ Erreur nettoyage: $e');
    }
  }
}
