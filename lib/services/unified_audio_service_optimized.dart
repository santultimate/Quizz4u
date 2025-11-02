import 'package:audioplayers/audioplayers.dart';
import 'cached_preferences_service.dart';

/// ⚡ Service Audio Optimisé - Fix ANR audioplayers
///
/// Corrections critiques:
/// 1. Préchargement des fichiers audio en arrière-plan
/// 2. Timeouts sur toutes les opérations audio
/// 3. Cache des préférences (CachedPreferencesService)
/// 4. Gestion d'erreurs robuste
class UnifiedAudioServiceOptimized {
  static UnifiedAudioServiceOptimized? _instance;
  static UnifiedAudioServiceOptimized get instance =>
      _instance ??= UnifiedAudioServiceOptimized._();

  UnifiedAudioServiceOptimized._();

  // Gestionnaires audio
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  // État
  bool _isInitialized = false;
  bool _soundEnabled = true;
  bool _backgroundMusicEnabled = true;
  double _masterVolume = 1.0;
  double _backgroundVolume = 0.2; // ✅ Réduit de 0.3 à 0.2 (standard jeux)
  double _effectVolume = 0.7;
  bool _isAdPlaying = false;
  bool _wasPlayingBeforeAd = false; // ✅ Pour mémoriser l'état avant publicité

  // ⚡ Cache des sources audio préchargées
  bool _audioPreloaded = false;

  /// ⚡ Initialise le service audio (NON-BLOQUANT)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[AudioServiceOpt] 🔄 Initialisation rapide...');

      // ⚡ Charger les paramètres depuis le cache (rapide)
      await _loadSettingsFromCache().timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print(
              '[AudioServiceOpt] ⚠️ Timeout préférences - Valeurs par défaut');
        },
      );

      // ⚡ Configuration des players (rapide)
      await _configureAudioPlayers().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {
          print('[AudioServiceOpt] ⚠️ Timeout configuration - Continuer');
        },
      );

      _isInitialized = true;
      print('[AudioServiceOpt] ✅ Service audio initialisé');

      // ⚡ Précharger les fichiers audio EN ARRIÈRE-PLAN (non-bloquant)
      _preloadAudioInBackground();
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur initialisation: $e');
      // Continuer avec les valeurs par défaut
      _isInitialized = true;
    }
  }

  /// ⚡ Charger les paramètres depuis le cache mémoire
  Future<void> _loadSettingsFromCache() async {
    try {
      _soundEnabled = await CachedPreferencesService.getBool(
        'sound_enabled',
        defaultValue: true,
      );
      _backgroundMusicEnabled = await CachedPreferencesService.getBool(
        'background_music_enabled',
        defaultValue: true,
      );
      _masterVolume = await CachedPreferencesService.getDouble(
        'master_volume',
        defaultValue: 1.0,
      );
      _backgroundVolume = await CachedPreferencesService.getDouble(
        'background_volume',
        defaultValue: 0.3,
      );
      _effectVolume = await CachedPreferencesService.getDouble(
        'effect_volume',
        defaultValue: 0.7,
      );

      print('[AudioServiceOpt] ✅ Paramètres chargés depuis cache');
    } catch (e) {
      print('[AudioServiceOpt] ⚠️ Erreur chargement paramètres: $e');
    }
  }

  /// ⚡ Configurer les audio players
  Future<void> _configureAudioPlayers() async {
    try {
      // Mode de lecture en boucle pour la musique de fond
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);

      // Mode normal pour les effets sonores
      await _effectPlayer.setReleaseMode(ReleaseMode.stop);

      print('[AudioServiceOpt] ✅ Players configurés');
    } catch (e) {
      print('[AudioServiceOpt] ⚠️ Erreur configuration players: $e');
    }
  }

  /// ⚡ Précharger les fichiers audio EN ARRIÈRE-PLAN (non-bloquant)
  void _preloadAudioInBackground() {
    if (_audioPreloaded) return;

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('[AudioServiceOpt] 🔄 Préchargement audio en arrière-plan...');

        // Précharger la musique de fond
        if (_backgroundMusicEnabled) {
          await _backgroundPlayer
              .setSource(AssetSource('sounds/background.mp3'))
              .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              print(
                  '[AudioServiceOpt] ⚠️ Timeout préchargement background.mp3');
            },
          );
        }

        // Précharger les effets sonores
        await _effectPlayer.setSource(AssetSource('sounds/good.mp3')).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('[AudioServiceOpt] ⚠️ Timeout préchargement good.mp3');
          },
        );

        _audioPreloaded = true;
        print('[AudioServiceOpt] ✅ Audio préchargé');
      } catch (e) {
        print('[AudioServiceOpt] ⚠️ Erreur préchargement: $e');
        // Continuer sans préchargement
      }
    });
  }

  // ===== MUSIQUE DE FOND =====

  /// ⚡ Joue la musique de fond (NON-BLOQUANT)
  Future<void> playBackgroundMusic() async {
    // ✅ Ne vérifier que _backgroundMusicEnabled et _isAdPlaying
    // Si pas encore initialisé, on initialise d'abord
    if (!_isInitialized) {
      print(
          '[AudioServiceOpt] ⚠️ Pas encore initialisé - initialisation automatique');
      await initialize();
    }

    if (!_backgroundMusicEnabled || _isAdPlaying) {
      print(
          '[AudioServiceOpt] ⏭️ Musique ignorée (enabled:$_backgroundMusicEnabled, ad:$_isAdPlaying)');
      return;
    }

    try {
      // ✅ Vérifier l'état actuel du player
      final currentState = _backgroundPlayer.state;

      // Si déjà en cours de lecture, ne rien faire
      if (currentState == PlayerState.playing) {
        print('[AudioServiceOpt] 🎵 Musique déjà en cours de lecture');
        return;
      }

      // ✅ Définir le volume AVANT de jouer
      await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);

      // ✅ Si en pause, reprendre
      if (currentState == PlayerState.paused) {
        await _backgroundPlayer.resume();
        print('[AudioServiceOpt] ▶️ Musique reprise depuis pause');
        return;
      }

      // ✅ Sinon, démarrer depuis le début
      await _backgroundPlayer
          .play(
        AssetSource('sounds/background.mp3'),
        volume: _backgroundVolume * _masterVolume,
      )
          .timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('[AudioServiceOpt] ⚠️ Timeout lecture background.mp3');
        },
      );

      print('[AudioServiceOpt] 🎵 Musique de fond démarrée');
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur musique de fond: $e');
      // Continuer sans musique
    }
  }

  /// Arrête la musique de fond
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      print('[AudioServiceOpt] 🔇 Musique de fond arrêtée');
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur arrêt musique: $e');
    }
  }

  /// Met en pause la musique de fond
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      print('[AudioServiceOpt] ⏸️ Musique de fond en pause');
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur pause musique: $e');
    }
  }

  // ===== EFFETS SONORES =====

  /// ⚡ Joue un son de bonne réponse (NON-BLOQUANT)
  Future<void> playGoodSound() async {
    if (!_isInitialized || !_soundEnabled || _isAdPlaying) return;

    try {
      await _effectPlayer.setVolume(_effectVolume * _masterVolume);

      // ✅ Lecture avec timeout
      await _effectPlayer.play(AssetSource('sounds/good.mp3')).timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print('[AudioServiceOpt] ⚠️ Timeout good.mp3');
        },
      );

      print('[AudioServiceOpt] 🎉 Son "bonne réponse" joué');
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur son bonne réponse: $e');
    }
  }

  /// ⚡ Joue un son de mauvaise réponse (NON-BLOQUANT)
  Future<void> playBadSound() async {
    if (!_isInitialized || !_soundEnabled || _isAdPlaying) return;

    try {
      await _effectPlayer.setVolume(_effectVolume * _masterVolume);

      await _effectPlayer.play(AssetSource('sounds/bad.mp3')).timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print('[AudioServiceOpt] ⚠️ Timeout bad.mp3');
        },
      );

      print('[AudioServiceOpt] 🔊 Son "mauvaise réponse" joué');
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur son mauvaise réponse: $e');
    }
  }

  // ===== PARAMÈTRES =====

  /// Active/désactive tous les sons
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await CachedPreferencesService.setBool('sound_enabled', enabled);
    print('[AudioServiceOpt] 🔊 Sons ${enabled ? "activés" : "désactivés"}');
  }

  /// Active/désactive la musique de fond
  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _backgroundMusicEnabled = enabled;
    await CachedPreferencesService.setBool('background_music_enabled', enabled);

    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }

    print(
        '[AudioServiceOpt] 🎵 Musique de fond ${enabled ? "activée" : "désactivée"}');
  }

  /// Définit le volume principal
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    await CachedPreferencesService.setDouble('master_volume', _masterVolume);

    // Appliquer immédiatement
    await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);

    print('[AudioServiceOpt] 🔊 Volume principal: $_masterVolume');
  }

  /// Définit le volume de la musique de fond
  Future<void> setBackgroundVolume(double volume) async {
    _backgroundVolume = volume.clamp(0.0, 1.0);
    await CachedPreferencesService.setDouble(
        'background_volume', _backgroundVolume);

    // Appliquer immédiatement
    await _backgroundPlayer.setVolume(_backgroundVolume * _masterVolume);

    print('[AudioServiceOpt] 🎵 Volume musique: $_backgroundVolume');
  }

  /// Définit le volume des effets sonores
  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    await CachedPreferencesService.setDouble('effect_volume', _effectVolume);
    print('[AudioServiceOpt] 🔊 Volume effets: $_effectVolume');
  }

  // ===== GESTION PUBLICITÉS =====

  /// Indique qu'une pub est en cours de lecture
  void setAdPlayingState(bool isPlaying) {
    if (isPlaying) {
      // ✅ Sauvegarder l'état AVANT la pub
      _wasPlayingBeforeAd = (_backgroundPlayer.state == PlayerState.playing);
      print(
          '[AudioServiceOpt] 📺 Pub démarre - Musique était: ${_wasPlayingBeforeAd ? "active" : "inactive"}');
      _isAdPlaying = true;
      pauseBackgroundMusic();
    } else {
      // ✅ Relancer UNIQUEMENT si la musique jouait avant ET si toujours activée
      _isAdPlaying = false;
      if (_wasPlayingBeforeAd && _backgroundMusicEnabled) {
        print('[AudioServiceOpt] 📺 Pub terminée - Relance musique');
        playBackgroundMusic();
      } else {
        print('[AudioServiceOpt] 📺 Pub terminée - Musique reste éteinte');
      }
      _wasPlayingBeforeAd = false; // Reset
    }
  }

  /// Alias pour compatibilité avec ad_service.dart
  void setAdPlaying(bool isPlaying) => setAdPlayingState(isPlaying);

  // ===== GETTERS =====

  bool get isInitialized => _isInitialized;
  bool get isSoundEnabled => _soundEnabled;
  bool get isBackgroundMusicEnabled => _backgroundMusicEnabled;
  double get masterVolume => _masterVolume;
  double get backgroundVolume => _backgroundVolume;
  double get effectVolume => _effectVolume;
  bool get isAdPlaying => _isAdPlaying;

  /// Libérer les ressources
  Future<void> dispose() async {
    try {
      await _backgroundPlayer.dispose();
      await _effectPlayer.dispose();
      print('[AudioServiceOpt] 🗑️ Ressources libérées');
    } catch (e) {
      print('[AudioServiceOpt] ❌ Erreur dispose: $e');
    }
  }
}
