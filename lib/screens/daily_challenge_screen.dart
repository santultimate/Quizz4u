import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/daily_challenge.dart';
import '../services/daily_challenge_service.dart';
import '../services/unified_audio_service_optimized.dart'; // ⚡ OPTIMISÉ
import '../services/settings_service.dart';
import '../services/translation_service.dart';
import '../quiz_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with TickerProviderStateMixin {
  DailyChallenge? _challenge;
  bool _isLoading = true;
  late AnimationController _progressController;
  late AnimationController _streakController;
  late Animation<double> _progressAnimation;
  late Animation<double> _streakAnimation;

  // Timer amélioré comme dans le jeu principal
  int _timeRemaining = 0;
  Timer? _timer;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;

  // Animations supplémentaires
  late AnimationController _challengeController;
  late Animation<double> _challengeAnimation;

  // Variables pour les sons et audio (copiées du jeu principal)
  bool _soundEnabled = true;
  bool _backgroundMusicEnabled = true;
  bool _ttsEnabled = false;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initializeAnimations();
    _initializeAudio();
    _loadChallenge();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Timer controller comme dans le jeu principal
    _timerController = AnimationController(
      duration:
          const Duration(seconds: 30), // Default duration, will be updated
      vsync: this,
    );

    // Controllers pour les animations supplémentaires
    _challengeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _streakAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _streakController,
      curve: Curves.elasticOut,
    ));

    // Animation du timer comme dans le jeu principal
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.easeInOut),
    );

    // Animations supplémentaires
    _challengeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _challengeController,
      curve: Curves.bounceOut,
    ));
  }

  Future<void> _loadChallenge() async {
    try {
      final challenge = await DailyChallengeService.getCurrentChallenge();
      final stats = await DailyChallengeService.getChallengeStats();
      final isAvailable =
          await DailyChallengeService.isChallengeAvailableToday();
      final remainingTime = await DailyChallengeService.getRemainingTime();

      // ✅ Check mounted avant setState
      if (mounted) {
        setState(() {
          _challenge = challenge;
          _isLoading = false;
        });
      }

      // Animer la progression
      _progressController.forward();

      // Animer la série si elle est > 0
      if (stats['streak'] > 0) {
        _streakController.forward();
      }

      // Animer le défi
      _challengeController.forward();

      // Jouer un son de chargement si activé
      if (_soundEnabled) {
        await UnifiedAudioServiceOptimized.instance.playGoodSound();
      }

      // Démarrer le timer seulement si le défi est disponible et pas complété
      if (isAvailable &&
          remainingTime != null &&
          remainingTime > Duration.zero) {
        _startTimer();
      } else if (!isAvailable) {
        print('[DailyChallengeScreen] ⚠️ Défi non disponible aujourd\'hui');
      }
    } catch (e) {
      print('[DailyChallengeScreen] ❌ Erreur chargement défi: $e');
      // ✅ Check mounted avant setState (même dans catch)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startChallenge() async {
    if (_challenge == null) return;

    // Vérifier si le défi est disponible
    final isAvailable = await DailyChallengeService.isChallengeAvailableToday();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(TranslationService.translate('challenge_already_completed')),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Démarrer le défi (enregistrer l'heure de début)
    await DailyChallengeService.startChallenge();

    // Jouer un son de démarrage si activé
    if (_soundEnabled) {
      await UnifiedAudioServiceOptimized.instance.playGoodSound();
    }

    // Animer le bouton avant la navigation
    _challengeController.reverse().then((_) {
      _challengeController.forward();
    });

    // Naviguer vers l'écran de quiz avec les paramètres du défi
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          category: _challenge!.categories.first,
          isDailyChallenge: true,
          challenge: _challenge!,
        ),
      ),
    ).then((_) {
      // Recharger le défi après retour du quiz
      _loadChallenge();
    });
  }

  // Méthodes pour le timer amélioré
  void _startTimer() async {
    if (_challenge == null) return;

    // Obtenir le temps restant depuis le service
    final remainingTime = await DailyChallengeService.getRemainingTime();
    if (remainingTime == null || remainingTime <= Duration.zero) {
      print('[DailyChallengeScreen] ⏰ Aucun temps restant pour le défi');
      return;
    }

    _timeRemaining = remainingTime.inSeconds;
    _timerController.duration = Duration(seconds: _timeRemaining);
    _timerController.reset();
    _timerController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && mounted) {
        setState(() {
          _timeRemaining--;
          _timerController.value =
              1.0 - (_timeRemaining / _challenge!.timeLimit.inSeconds);
        });
      } else {
        _timer?.cancel();
        if (mounted) {
          _onTimeUp();
        }
      }
    });
  }

  void _onTimeUp() {
    // Logique quand le temps est écoulé
    print('[DailyChallenge] ⏰ Temps écoulé pour le défi quotidien');
    // Ici on peut ajouter une logique pour gérer la fin du défi
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _streakController.dispose();
    _timerController.dispose();
    _challengeController.dispose();
    _stopBackgroundMusic();
    flutterTts.stop();
    super.dispose();
  }

  // Méthodes audio copiées du jeu principal
  Future<void> _initializeAudio() async {
    try {
      print('[DailyChallengeScreen] 🎵 Initialisation du système audio...');

      // Initialiser le service audio unifié
      await UnifiedAudioServiceOptimized.instance.initialize();

      // Charger les paramètres audio
      await _loadAudioSettings();

      // Démarrer la musique de fond si activée
      if (_backgroundMusicEnabled && _soundEnabled) {
        await _startBackgroundMusic();
      }

      print('[DailyChallengeScreen] ✅ Système audio initialisé');
    } catch (e) {
      print('[DailyChallengeScreen] ❌ Erreur initialisation audio: $e');
    }
  }

  Future<void> _loadAudioSettings() async {
    _backgroundMusicEnabled = await SettingsService.isBackgroundMusicEnabled();
    _soundEnabled = await SettingsService.isSoundEnabled();
    _ttsEnabled = await SettingsService.isTtsEnabled();

    print(
        '[DailyChallengeScreen] _loadAudioSettings - Musique: $_backgroundMusicEnabled, Sons: $_soundEnabled, TTS: $_ttsEnabled');

    // Initialiser TTS en français
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _startBackgroundMusic() async {
    print(
        '[DailyChallengeScreen] _startBackgroundMusic - Vérification: _backgroundMusicEnabled = $_backgroundMusicEnabled');

    if (_backgroundMusicEnabled) {
      print(
          '[DailyChallengeScreen] _startBackgroundMusic - lancement musique de fond');
      await UnifiedAudioServiceOptimized.instance.playBackgroundMusic();
    } else {
      print(
          '[DailyChallengeScreen] _startBackgroundMusic - musique de fond désactivée dans les paramètres');
    }
  }

  Future<void> _stopBackgroundMusic() async {
    print(
        '[DailyChallengeScreen] _stopBackgroundMusic - arrêt musique de fond');
    await UnifiedAudioServiceOptimized.instance
        .setBackgroundMusicEnabled(false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationService.translate('daily_challenge'),
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _challenge == null
              ? const Center(child: Text('Erreur de chargement'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // En-tête avec série
                      _buildStreakHeader(),
                      const SizedBox(height: 20),

                      // Carte du défi
                      _buildChallengeCard(_challenge!, isDark),
                      const SizedBox(height: 20),

                      // Statistiques
                      _buildStatsSection(_challenge!, isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStreakHeader() {
    return FutureBuilder<Map<String, dynamic>>(
      future: DailyChallengeService.getChallengeStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final stats = snapshot.data!;
        final streak = stats['streak'] as int;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[400]!, Colors.red[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Série: $streak jour${streak > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (streak >= 3)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[800]!, Colors.grey[700]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animation Lottie pour l'icône
              SizedBox(
                width: 40,
                height: 40,
                child: Lottie.asset(
                  'assets/animations/hourglass.json',
                  width: 40,
                  height: 40,
                  repeat: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationService.translate(challenge.titleKey),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TranslationService.translate(challenge.descriptionKey),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timer amélioré comme dans le jeu principal
          _buildTimerSection(challenge, isDark),

          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.category,
                '${challenge.categories.length} catégorie${challenge.categories.length > 1 ? 's' : ''}',
                isDark,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.emoji_events,
                challenge.difficulty,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progression
          _buildProgressSection(challenge, isDark),
          const SizedBox(height: 16),

          // Récompenses
          _buildRewardsSection(challenge, isDark),
          const SizedBox(height: 32),

          // Bouton d'action
          _buildActionButton(challenge, isDark),
        ],
      ),
    );
  }

  Widget _buildTimerSection(DailyChallenge challenge, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du timer
        Row(
          children: [
            Icon(
              Icons.timer,
              size: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              TranslationService.translate('time_remaining'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            const Spacer(),
            // Affichage du temps restant
            Text(
              '${_timeRemaining}s',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _timeRemaining > 20
                    ? Colors.green
                    : _timeRemaining > 10
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Barre de progression du timer améliorée (comme dans le jeu principal)
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: AnimatedBuilder(
            animation: _timerAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _timerAnimation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _timeRemaining > 20
                            ? Colors.green
                            : _timeRemaining > 10
                                ? Colors.orange
                                : Colors.red,
                        _timeRemaining > 20
                            ? Colors.lightGreen
                            : _timeRemaining > 10
                                ? Colors.deepOrange
                                : Colors.redAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: (_timeRemaining > 20
                                ? Colors.green
                                : _timeRemaining > 10
                                    ? Colors.orange
                                    : Colors.red)
                            .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(DailyChallenge challenge, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationService.translate('progress'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: challenge.progressPercentage,
                backgroundColor: isDark ? Colors.grey[600] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  challenge.isCompleted ? Colors.green : Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${challenge.currentProgress}/${challenge.targetScore}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardsSection(DailyChallenge challenge, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationService.translate('rewards'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: challenge.rewards.entries.map((entry) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      entry.key == 'XP' ? Icons.star : Icons.monetization_on,
                      color: entry.key == 'XP' ? Colors.amber : Colors.green,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      entry.key == 'Coins'
                          ? TranslationService.translate('coins')
                          : entry.key, // "XP" reste tel quel
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsSection(DailyChallenge challenge, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('statistics'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.quiz,
                  TranslationService.translate('questions_count'),
                  '${challenge.targetScore}',
                  Colors.blue,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.timer,
                  TranslationService.translate('time_label'),
                  '${challenge.timeLimit.inMinutes}min',
                  Colors.orange,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.speed,
                  TranslationService.translate('difficulty_label'),
                  challenge.difficulty,
                  Colors.purple,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(DailyChallenge challenge, bool isDark) {
    return FutureBuilder<bool>(
      future: DailyChallengeService.isChallengeAvailableToday(),
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? true;
        final isCompleted = challenge.isCompleted || !isAvailable;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isCompleted ? null : _startChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.grey : Colors.purple[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isCompleted ? 2 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCompleted) ...[
                  Icon(isAvailable ? Icons.check_circle : Icons.schedule),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable
                        ? TranslationService.translate('challenge_completed')
                        : TranslationService.translate('challenge_unavailable'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  const Icon(Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(
                    TranslationService.translate('start_challenge'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
