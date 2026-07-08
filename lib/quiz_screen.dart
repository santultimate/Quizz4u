import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'services/question_service_optimized.dart'; // ⚡ OPTIMISÉ // Importer le service de questions
// import 'utils/safe_navigator.dart'; // ⚡ Pour fix "No focused window" ANR - Non utilisé
import 'models/question_model.dart'; // Importer le modèle Question
import 'models/daily_challenge.dart'; // Importer le modèle DailyChallenge
import 'services/daily_challenge_service.dart'; // Importer le service des défis quotidiens
import 'dart:async'; // Nécessaire pour le Timer
import 'dart:math';
import 'services/unified_audio_service_optimized.dart'; // ⚡ OPTIMISÉ
import 'services/settings_service.dart';
import 'services/ad_service.dart'; // Importer le service d'annonce
import 'services/progress_service.dart'; // Importer le service de progression
import 'services/smart_ad_strategy.dart'; // Importer la stratégie publicitaire intelligente
import 'services/premium_service.dart'; // Importer le service premium
import 'services/daily_engagement_service.dart'; // Importer le service d'engagement quotidien
import 'services/translation_service.dart'; // Importer le service de traduction
import 'services/multilingual_tts_service.dart'; // Importer le service TTS multilingue
import 'services/localization_service.dart'; // Importer le service de localisation
import 'services/question_translation_service.dart'; // Importer le service de traduction des questions
// import 'services/auto_question_translator.dart'; // Importer le service de traduction automatique - Non utilisé maintenant
import 'services/leaderboard_service.dart'; // Importer le service de classement pour partager le score
// Importer le service de test publicitaire
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/ad_banner_widget.dart'; // Pour les bannières publicitaires

class QuizScreen extends StatelessWidget {
  final String category;
  final bool isDailyChallenge;
  final DailyChallenge? challenge;

  const QuizScreen({
    super.key,
    required this.category,
    this.isDailyChallenge = false,
    this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translateWithParams(
            'quiz_category_title', {
          'category': QuestionTranslationService.translateCategory(category)
        })),
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          },
          tooltip: 'Retour au menu principal',
        ),
        actions: [
          // Bouton pour recharger les questions
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Passer l'instruction de rechargement à QuizPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    category: category,
                    isDailyChallenge: isDailyChallenge,
                    challenge: challenge,
                  ),
                ),
              );
            },
            tooltip: TranslationService.translate('new_questions'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(TranslationService.translate('how_to_play')),
                  content:
                      Text(TranslationService.translate('how_to_play_body')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(TranslationService.translate('ok')),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: QuizPage(
        category: category,
        isDailyChallenge: isDailyChallenge,
        challenge: challenge,
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String category;
  final bool isDailyChallenge;
  final DailyChallenge? challenge;

  const QuizPage({
    super.key,
    required this.category,
    this.isDailyChallenge = false,
    this.challenge,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int correctAnswers = 0; // Ajouter le compteur de bonnes réponses
  int timer = SettingsService.defaultTimerDuration;
  int _timerDuration = SettingsService.defaultTimerDuration;
  int totalQuestions = 10;
  bool isPaused = false;
  bool isGameOver = false;
  bool isLoading = true;
  bool ttsActive = false;
  bool _backgroundMusicEnabled = true;
  bool _soundEnabled = true;
  bool _ttsEnabled = false;

  // 🎲 Stocker les réponses mélangées pour chaque question
  final Map<int, List<MapEntry<String, bool>>> _shuffledAnswers = {};

  late Timer _timer;
  late Timer _audioSettingsTimer;
  late AnimationController _timerController;
  late AnimationController _questionController;
  late AnimationController _feedbackController;
  late Animation<double> _questionAnimation;
  late Animation<double> _feedbackAnimation;

  // Variables pour le feedback visuel
  bool? _selectedAnswerCorrect;
  int? _selectedAnswerIndex; // Index de la réponse sélectionnée
  bool _showFeedback = false;
  bool _isAnswering = false; // Flag pour empêcher de répondre plusieurs fois

  // allQuestions nécessaire pour _loadAllQuestions
  List<QuestionModel> allQuestions = [];
  List<QuestionModel> currentQuestions = [];
  Random random = Random();
  int questionsSinceLastAd = 0;

  @override
  void initState() {
    super.initState();
    print('[QuizScreen] initState - initialisation');
    _initializeAnimations();
    _loadTimerDuration(); // ⏱️ Charger la durée du timer depuis les paramètres
    _initializeQuestions();
    _initializeAudio();
    AdService
        .loadInterstitialAd(); // Charger la pub interstitielle au démarrage
  }

  Future<void> _initializeQuestions() async {
    print('[QuizScreen] 🔄 Début _initializeQuestions pour ${widget.category}');

    try {
      // ⚡ OPTIMISÉ: Questions déjà chargées dans LoadingScreen
      if (!QuestionServiceOptimized.isLoaded) {
        print('[QuizScreen] 🔄 Chargement QuestionServiceOpt...');
        await QuestionServiceOptimized.loadEssentialQuestions();
        print('[QuizScreen] ✅ QuestionServiceOpt chargé');
      } else {
        print('[QuizScreen] ✅ QuestionService déjà chargé (skip)');
      }

      // ProgressService est léger, on peut le recharger
      print('[QuizScreen] 🔄 Chargement ProgressService...');
      await ProgressService.loadProgress();
      print('[QuizScreen] ✅ ProgressService chargé');

      // TTS déjà initialisé dans LoadingScreen - on skip pour performance
      print('[QuizScreen] ℹ️ TTS déjà initialisé dans LoadingScreen (skip)');

      print('[QuizScreen] 🔄 Génération questions aléatoires...');
      _generateRandomQuestions();
      print('[QuizScreen] ✅ Questions générées: ${currentQuestions.length}');

      // Charger les paramètres audio avant de lancer la musique
      print('[QuizScreen] 🔄 Chargement paramètres audio...');
      await _loadAudioSettings();
      print('[QuizScreen] ✅ Paramètres audio chargés');

      print('[QuizScreen] 🔄 Mise à jour isLoading = false');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('[QuizScreen] ✅ UI mise à jour, isLoading = false');

      // Debug: Afficher l'état des paramètres audio
      print('[QuizScreen] DEBUG - État final des paramètres audio:');
      print(
          '[QuizScreen] DEBUG - _backgroundMusicEnabled = $_backgroundMusicEnabled');
      print('[QuizScreen] DEBUG - _soundEnabled = $_soundEnabled');
      print('[QuizScreen] DEBUG - _ttsEnabled = $_ttsEnabled');

      // Lancer la musique de fond au début du quiz
      print('[QuizScreen] 🔄 Démarrage musique de fond...');
      await _startBackgroundMusic();
      _startTimer();
      _startAudioSettingsCheck();
      print('[QuizScreen] ✅ Initialisation complète terminée!');
    } catch (e, stackTrace) {
      print('[QuizScreen] ❌ ERREUR dans _initializeQuestions: $e');
      print('[QuizScreen] ❌ StackTrace: $stackTrace');

      // Toujours essayer de terminer le chargement même en cas d'erreur
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isTimerComfortable() => timer > (_timerDuration * 2) ~/ 3;

  bool _isTimerWarning() => timer > _timerDuration ~/ 3;

  void _initializeAnimations() {
    _timerController = AnimationController(
      duration: Duration(seconds: SettingsService.defaultTimerDuration),
      vsync: this,
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOutBack),
    );

    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.bounceOut),
    );
  }

  void _loadAllQuestions() {
    // Charger toutes les questions de la catégorie choisie uniquement
    allQuestions =
        QuestionServiceOptimized.getAllQuestionsForCategory(widget.category);
  }

  void _generateRandomQuestions() {
    currentQuestions.clear();

    if (widget.isDailyChallenge && widget.challenge != null) {
      // Mode défi quotidien - utiliser les questions spécifiques du défi
      totalQuestions = widget.challenge!.targetScore;
      // Charger les questions de manière synchrone d'abord
      _loadDailyChallengeQuestionsSync();
    } else {
      // Mode normal - 10 questions ALÉATOIRES depuis la banque globale
      totalQuestions = 10;

      // S'assurer que les questions sont chargées (Synchrone - déjà chargées dans initState)
      // QuestionServiceOptimized.ensureQuestionsLoaded(); // Supprimé car déjà chargé dans initState

      // 🎲 NOUVEAU : Sélectionner 10 questions COMPLÈTEMENT ALÉATOIRES
      // depuis la banque globale de questions de la catégorie
      // Cela garantit un nouveau lot à chaque partie (pas de répétition du même lot)
      final randomSeed = DateTime.now().millisecondsSinceEpoch;
      print(
          '[QuizScreen] 🎲 Génération de questions aléatoires avec seed: $randomSeed');

      currentQuestions = QuestionServiceOptimized.getRandomQuestionsForCategory(
        widget.category,
        totalQuestions,
      );

      // Vérifier qu'il y a des questions disponibles
      if (currentQuestions.isEmpty) {
        print(
            '[QuizScreen] ❌ Aucune question disponible pour ${widget.category}');
        // Essayer de charger des questions intelligentes comme fallback
        currentQuestions =
            QuestionServiceOptimized.getIntelligentQuestionsForCategory(
          widget.category,
          count: totalQuestions,
        );
        if (currentQuestions.isNotEmpty) {
          print(
              '[QuizScreen] ✅ Questions de fallback chargées: ${currentQuestions.length}');
        }
      }

      // Mélanger une dernière fois pour maximiser l'aléatoire
      currentQuestions.shuffle(Random(randomSeed));

      // ⚠️ LIMITER à exactement 10 questions (ne pas charger plus)
      if (currentQuestions.length > totalQuestions) {
        currentQuestions = currentQuestions.sublist(0, totalQuestions);
        print('[QuizScreen] ✂️ Questions limitées à $totalQuestions');
      }

      // 🌍 Les questions sont déjà traduites par QuestionServiceOptimized
      // qui charge les fichiers traduits selon la langue
      print('[QuizScreen] ✅ Questions chargées (traduites automatiquement)');

      // ⚠️ DÉSACTIVÉ : Les questions d'engagement sont inappropriées dans les quiz par catégorie
      // _loadEngagementQuestions();

      print(
          '[QuizScreen] 🎯 ${currentQuestions.length} questions aléatoires générées pour ${widget.category}');

      // Debug : Afficher les premières questions pour vérifier la variété
      if (currentQuestions.length >= 3) {
        print('[QuizScreen] 🔍 Premières questions: ');
        for (int i = 0; i < 3; i++) {
          final preview = currentQuestions[i].question.length > 40
              ? '${currentQuestions[i].question.substring(0, 40)}...'
              : currentQuestions[i].question;
          print('  $i. $preview');
        }
      }
    }

    // 🎲 MÉLANGER les réponses pour toutes les questions
    _shuffleAllAnswers();
  }

  /// 🎲 Mélanger les réponses pour éviter que la bonne réponse soit toujours en première position
  void _shuffleAllAnswers() {
    _shuffledAnswers.clear();
    for (int i = 0; i < currentQuestions.length; i++) {
      final question = currentQuestions[i];
      final answersList = question.answers.entries.toList();
      answersList.shuffle(Random());
      _shuffledAnswers[i] = answersList;
    }
    print(
        '[QuizScreen] 🎲 Réponses mélangées pour ${currentQuestions.length} questions');
  }

  void _loadDailyChallengeQuestionsSync() {
    try {
      print(
          '[QuizScreen] 🎯 Chargement synchrone des questions du défi quotidien...');
      // Utiliser les questions intelligentes comme fallback immédiat
      currentQuestions =
          QuestionServiceOptimized.getIntelligentQuestionsForCategory(
        widget.category,
        count: totalQuestions,
      );

      // 🌍 NE PAS TRADUIRE - Les questions restent en français
      print(
          '[QuizScreen] ℹ️ Questions du défi en français (traduction désactivée)');

      // 🎲 MÉLANGER les réponses
      _shuffleAllAnswers();

      // Charger les questions du défi en arrière-plan (mais pas les questions d'engagement génériques)
      // _loadDailyChallengeQuestions(); // ⚠️ DÉSACTIVÉ temporairement
    } catch (e) {
      print('[QuizScreen] ❌ Erreur chargement synchrone questions défi: $e');
      currentQuestions =
          QuestionServiceOptimized.getIntelligentQuestionsForCategory(
        widget.category,
        count: totalQuestions,
      );

      // 🌍 NE PAS TRADUIRE en cas d'erreur non plus
      print(
          '[QuizScreen] ℹ️ Questions en français (erreur - traduction désactivée)');

      // 🎲 MÉLANGER les réponses
      _shuffleAllAnswers();
    }
  }

  Future<void> _loadDailyChallengeQuestions() async {
    try {
      print('[QuizScreen] 🎯 Chargement des questions du défi quotidien...');
      currentQuestions =
          await DailyChallengeService.getCurrentChallengeQuestions();

      if (currentQuestions.isEmpty) {
        print(
            '[QuizScreen] ⚠️ Aucune question trouvée pour le défi, utilisation des questions normales');
        currentQuestions =
            QuestionServiceOptimized.getSmartQuestionsForCategory(
          widget.category,
          count: totalQuestions,
        );
      } else {
        print(
            '[QuizScreen] ✅ ${currentQuestions.length} questions chargées pour le défi quotidien');
      }

      // 🌍 NE PAS TRADUIRE - Les questions restent en français
      print(
          '[QuizScreen] ℹ️ Questions du défi en français (async - traduction désactivée)');
    } catch (e) {
      print('[QuizScreen] ❌ Erreur chargement questions défi: $e');
      // Fallback vers les questions intelligentes
      currentQuestions =
          QuestionServiceOptimized.getIntelligentQuestionsForCategory(
        widget.category,
        count: totalQuestions,
      );

      // 🌍 NE PAS TRADUIRE en cas d'erreur non plus
      print(
          '[QuizScreen] ℹ️ Questions en français (erreur async - traduction désactivée)');

      // 🎲 MÉLANGER les réponses
      _shuffleAllAnswers();
    }
  }

  void _startTimer() {
    _timerController.forward();
    _questionController.forward();

    // Lancer la TTS pour la première question si activée
    if (_ttsEnabled && currentQuestions.isNotEmpty) {
      _speakQuestion();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && !isGameOver && !_isAnswering) {
        // ✅ Ajout vérification _isAnswering
        if (this.timer == 0) {
          // ✅ Vérifier une dernière fois avant d'appeler _nextQuestion()
          if (!_isAnswering && mounted) {
            _nextQuestion();
          }
        } else {
          // ✅ Check mounted avant setState dans Timer
          if (mounted) {
            setState(() {
              this.timer--;
              _timerController.value = 1.0 -
                  (this.timer / _timerDuration.toDouble());
            });
          }

          // Avertissement TTS multilingue pour le temps restant
          // ⚠️ TEMPORAIREMENT DÉSACTIVÉ pour éviter les crashs
          // if (_ttsEnabled && this.timer <= 10 && this.timer > 0) {
          //   MultilingualTTSService.speakTimeRemaining(this.timer);
          // }
        }
      }
    });
  }

  void _pauseGame() {
    // ✅ Check mounted avant setState
    if (!mounted) return;

    setState(() {
      isPaused = true;
    });
    _timerController.stop();
    MultilingualTTSService.stop();
    setState(() {
      ttsActive = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('game_paused')),
        content: Text(TranslationService.translate('continue_game_question')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeGame();
            },
            child: Text(TranslationService.translate('continue')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: Text(TranslationService.translate('restart')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(TranslationService.translate('quit')),
          ),
        ],
      ),
    );
  }

  void _resumeGame() {
    // ✅ Check mounted avant setState
    if (!mounted) return;

    setState(() {
      isPaused = false;
    });
    _timerController.forward();
    // Reprendre la lecture TTS si activée
    if (_ttsEnabled && currentQuestions.isNotEmpty) {
      _speakQuestion();
    }
  }

  void _restartGame() async {
    // ✅ Check mounted avant setState
    if (!mounted) return;

    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      correctAnswers = 0; // Réinitialiser le compteur de bonnes réponses
      timer = _timerDuration; // ⏱️ Utiliser la durée configurée
      isPaused = false;
      isGameOver = false;
      isLoading = true;
    });
    _timerController.reset();
    _questionController.reset();
    _generateRandomQuestions();

    // ✅ Check mounted avant deuxième setState
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    // Relancer la musique de fond lors du redémarrage
    await _startBackgroundMusic();
    _startTimer();
  }

  void _nextQuestion() {
    print('[QuizScreen] 🔄 Passage à la question suivante...');

    // Réinitialiser le feedback visuel et débloquer les réponses
    setState(() {
      _showFeedback = false;
      _selectedAnswerCorrect = null;
      _selectedAnswerIndex = null;
      _isAnswering = false; // 🔓 Débloquer pour la prochaine question
    });
    _feedbackController.reset();
    print('[QuizScreen] 🔓 Réponses déverrouillées');

    // ⚠️ CORRECTION: S'arrêter à totalQuestions (10) au lieu de continuer jusqu'à la fin de currentQuestions
    if (currentQuestionIndex < totalQuestions - 1 &&
        currentQuestionIndex < currentQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        timer = _timerDuration; // ⏱️ Utiliser la durée configurée
      });

      print(
          '[QuizScreen] ⏱️ Redémarrage du timer pour question ${currentQuestionIndex + 1}/$totalQuestions');

      // ⏱️ S'assurer que l'ancien timer est bien annulé avant d'en créer un nouveau
      try {
        _timer.cancel();
      } catch (e) {
        print('[QuizScreen] ⚠️ Timer déjà annulé: $e');
      }

      // ✅ ORDRE CORRIGÉ : Reset AVANT de démarrer le nouveau timer
      _timerController.reset();
      _questionController.reset();

      // Redémarrer le timer avec contrôleurs réinitialisés
      _startTimer();

      // Lancer les animations
      _timerController.forward();
      _questionController.forward();

      print(
          '[QuizScreen] ✅ Question ${currentQuestionIndex + 1}/${currentQuestions.length} chargée');

      // Lancer la TTS pour la nouvelle question si activée
      if (_ttsEnabled && currentQuestions.isNotEmpty) {
        _speakQuestion();
      }
    } else {
      print('[QuizScreen] 🏁 Dernière question - fin du jeu');
      _endGame();
    }
  }

  void checkAnswer(int answerIndex, bool isCorrect) async {
    print(
        '[QuizScreen] DEBUG - checkAnswer appelée avec isCorrect: $isCorrect, answerIndex: $answerIndex');
    print('[QuizScreen] DEBUG - _soundEnabled = $_soundEnabled');

    // 🚫 Empêcher de répondre plusieurs fois à la même question
    if (isPaused || isGameOver || _isAnswering) {
      print(
          '[QuizScreen] ⚠️ Réponse ignorée (isPaused=$isPaused, isGameOver=$isGameOver, _isAnswering=$_isAnswering)');
      return;
    }

    // Marquer qu'on est en train de traiter une réponse
    _isAnswering = true;
    print('[QuizScreen] 🔒 Réponse verrouillée');

    // ⏸️ ARRÊTER LE TIMER IMMÉDIATEMENT quand on répond
    _timer.cancel();
    _timerController.stop();
    print('[QuizScreen] ⏸️ Timer arrêté - réponse donnée');

    // Afficher le feedback visuel immédiatement
    setState(() {
      _selectedAnswerCorrect = isCorrect;
      _selectedAnswerIndex =
          answerIndex; // Stocker l'index de la réponse sélectionnée
      _showFeedback = true;
    });

    // Démarrer l'animation de feedback
    print('[QuizScreen] 🎨 Démarrage animation feedback: isCorrect=$isCorrect');
    _feedbackController.reset();
    _feedbackController.forward();

    int timeBonus = (timer / 3).round();
    int pointsEarned = isCorrect ? 10 + timeBonus : 0;
    setState(() {
      if (isCorrect) {
        score += pointsEarned;
        correctAnswers++; // Incrémenter le compteur de bonnes réponses
      }
    });

    // Enregistrer la progression
    print(
        '[QuizScreen] 🎯 Tentative d\'enregistrement progression: isCorrect=$isCorrect, points=$pointsEarned, category=${widget.category}');
    try {
      await ProgressService.addAnswer(isCorrect, pointsEarned, widget.category);
      print('[QuizScreen] ✅ Progression enregistrée avec succès');

      // Mettre à jour le défi quotidien si applicable
      if (widget.isDailyChallenge && isCorrect) {
        await DailyChallengeService.updateProgress(1);
        print('[QuizScreen] 🎯 Progression défi quotidien mise à jour');
      }
    } catch (e) {
      print('[QuizScreen] ❌ Erreur enregistrement progression: $e');
    }

    // Jouer les sons de réponse
    if (_soundEnabled) {
      try {
        if (isCorrect) {
          print('[QuizScreen] 🎵 Bonne réponse - jouer son good.mp3');
          await UnifiedAudioServiceOptimized.instance.playGoodSound();
        } else {
          print('[QuizScreen] 🎵 Mauvaise réponse - jouer son bad.mp3');
          await UnifiedAudioServiceOptimized.instance.playBadSound();
        }
      } catch (e) {
        print('[QuizScreen] ❌ Erreur lors de la lecture du son: $e');
      }
    } else {
      print('[QuizScreen] 🔇 Sons désactivés dans les paramètres');
    }

    // Lire le feedback TTS multilingue (NON-BLOQUANT)
    // ⚠️ TEMPORAIREMENT DÉSACTIVÉ pour éviter les crashs
    // if (_ttsEnabled) {
    //   // ⚡ Ne pas await pour ne pas bloquer le gameplay
    //   MultilingualTTSService.speakFeedback(isCorrect).then((_) {
    //     print('[QuizScreen] 🎤 Feedback TTS multilingue lu');
    //   }).catchError((e) {
    //     print('[QuizScreen] ❌ Erreur TTS feedback: $e');
    //   });
    // }

    // ⏩ PASSAGE IMMÉDIAT À LA QUESTION SUIVANTE (ne pas attendre la pub)
    print(
        '[QuizScreen] ⏱️ Attente 500ms avant passage à la question suivante...');
    await Future.delayed(const Duration(
        milliseconds:
            500)); // ✅ Réduit de 1000ms à 500ms pour feedback plus rapide

    print('[QuizScreen] 🚀 Appel de _nextQuestion()...');
    if (mounted) {
      _nextQuestion();
    } else {
      print('[QuizScreen] ⚠️ Widget démonté, skip _nextQuestion');
      return;
    }

    // 📺 AFFICHER LA PUB EN ARRIÈRE-PLAN (NON-BLOQUANT)
    // Ne pas await pour ne pas bloquer le gameplay
    SmartAdStrategy.incrementQuestionCount();

    if (await SmartAdStrategy.canShowAd()) {
      print('[QuizScreen] 📺 Tentative affichage publicité (non-bloquant)...');
      AdService.showStrategicInterstitial().then((_) {
        // Relancer la musique de fond après la pub
        if (_backgroundMusicEnabled && mounted) {
          print(
              '[QuizScreen] 🎵 Relance de la musique de fond après publicité');
          _startBackgroundMusic();
        }
      }).catchError((e) {
        print('[QuizScreen] ❌ Erreur publicité (ignorée): $e');
      });
    }
  }

  void _showScorePopup(int points) {
    // Afficher un pop-up animé pour le score
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: _feedbackAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _feedbackAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '+$points points',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Bonne réponse !',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    // Fermer le pop-up après 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _endGame() async {
    print('[QuizScreen] 🎯 _endGame() appelé - Fin du quiz');
    setState(() {
      isGameOver = true;
    });
    _timer.cancel();
    _timerController.stop();

    // Arrêter la musique de fond à la fin du jeu
    await _stopBackgroundMusic();

    // ⚠️ TTS DÉSACTIVÉ TEMPORAIREMENT - Bloque l'affichage du dialogue
    // // Lire le score final avec TTS multilingue
    // if (_ttsEnabled) {
    //   try {
    //     await MultilingualTTSService.speakScore(score);
    //     print('[QuizScreen] 🎤 Score final TTS multilingue lu');
    //   } catch (e) {
    //     print('[QuizScreen] ❌ Erreur TTS score final: $e');
    //   }
    // }
    print('[QuizScreen] ⚠️ TTS désactivé temporairement');

    // 🎯 AFFICHER LE DIALOGUE D'ABORD (priorité absolue à l'expérience utilisateur)
    print('[QuizScreen] 🎯 Affichage immédiat du dialogue de résultat...');
    if (mounted) {
      print('[QuizScreen] ✅ Widget monté - dialogue affiché');
      _showResult();
    } else {
      print(
          '[QuizScreen] ❌ Widget non monté - impossible d\'afficher le dialogue');
      return;
    }

    // Sauvegarder le score EN ARRIÈRE-PLAN (ne pas bloquer le dialogue)
    print('[QuizScreen] 🎯 Sauvegarde du score en arrière-plan...');
    _saveScore().then((_) {
      print('[QuizScreen] ✅ _saveScore() terminé');
    }).catchError((e) {
      print('[QuizScreen] ❌ Erreur sauvegarde en arrière-plan: $e');
    });

    // Afficher une publicité interstitielle APRÈS (non critique)
    // L'utilisateur peut voir ses résultats pendant que la pub se prépare
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;

      try {
        final isPremium = await PremiumService.isPremiumUser();
        if (!isPremium) {
          print('[QuizScreen] 📺 Affichage publicité (après dialogue)...');
          await AdService.showEndGameInterstitial();
        } else {
          print(
              '[QuizScreen] 🚫 Utilisateur premium - aucune publicité fin de quiz');
        }
      } catch (e) {
        print('[QuizScreen] ❌ Erreur publicité fin de quiz: $e');
      }
    });
  }

  Future<void> _saveScore() async {
    try {
      print('[QuizScreen] 🎯 Sauvegarde automatique du score final...');

      // Calculer les statistiques finales
      int totalQuestionsAnswered = currentQuestionIndex + 1;
      double accuracyRate = (correctAnswers / totalQuestionsAnswered) * 100;

      // Enregistrer le score total dans la progression
      int totalXP = score; // 1 point = 1 XP
      await ProgressService.addExperience(totalXP,
          reason: 'Score Quiz ${widget.category}');
      print('[QuizScreen] 🎯 XP total ajouté: +$totalXP XP');

      // Ajouter un bonus pour la précision
      if (accuracyRate >= 80) {
        int bonusXP =
            (accuracyRate - 80).round() * 2; // Bonus pour haute précision
        await ProgressService.addExperience(bonusXP, reason: 'Bonus Précision');
        print('[QuizScreen] 🎁 Bonus précision: +$bonusXP XP');
      }

      // Ajouter un bonus pour le score élevé
      if (score >= totalQuestionsAnswered * 8) {
        // 80% du score max
        int bonusXP = 10;
        await ProgressService.addExperience(bonusXP,
            reason: 'Bonus Score Élevé');
        print('[QuizScreen] 🎁 Bonus score élevé: +$bonusXP XP');
      }

      // Enregistrer les statistiques de la catégorie
      // Enregistrer les bonnes réponses
      if (correctAnswers > 0) {
        await ProgressService.addAnswer(true, correctAnswers, widget.category);
        print('[QuizScreen] 📊 Bonnes réponses enregistrées: $correctAnswers');
      }

      // Enregistrer les mauvaises réponses
      int wrongAnswers = totalQuestionsAnswered - correctAnswers;
      if (wrongAnswers > 0) {
        await ProgressService.addAnswer(false, wrongAnswers, widget.category);
        print('[QuizScreen] 📊 Mauvaises réponses enregistrées: $wrongAnswers');
      }

      print(
          '[QuizScreen] 📊 Statistiques complètes: $correctAnswers bonnes, $wrongAnswers mauvaises sur $totalQuestionsAnswered');

      print(
          '[QuizScreen] ✅ Score final sauvegardé: $score points, Précision: ${accuracyRate.toStringAsFixed(1)}%');

      // Forcer la mise à jour des statistiques
      await ProgressService.loadProgress();

      // Afficher un message de confirmation
      if (context.mounted) {
        int totalBonus =
            (accuracyRate >= 80 ? (accuracyRate - 80).round() * 2 : 0) +
                (score >= totalQuestionsAnswered * 8 ? 10 : 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationService.translateWithParams('score_saved',
                {'xp': totalXP.toString(), 'bonus': totalBonus.toString()})),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('[QuizScreen] ❌ Erreur sauvegarde score: $e');
    }
  }

  void _showResult() {
    // Définir le seuil de score minimum pour sauvegarder (ex: 50% des points possibles)
    int maxPossibleScore = totalQuestions * 10; // 10 points par question
    int scoreThreshold =
        (maxPossibleScore * 0.5).round(); // 50% du score maximum

    // Calculer le pourcentage de réussite
    double accuracyPercentage = (correctAnswers / totalQuestions) * 100;

    // Déterminer si le score est suffisamment bon pour proposer la sauvegarde
    bool isGoodScore = score >= scoreThreshold || accuracyPercentage >= 60;

    print(
        '[QuizScreen] 📊 Score: $score/$maxPossibleScore (${accuracyPercentage.toStringAsFixed(1)}%)');
    print(
        '[QuizScreen] 📊 isGoodScore: $isGoodScore (seuil: $scoreThreshold, accuracy: ${accuracyPercentage.toStringAsFixed(1)}%)');

    // Toujours afficher le dialogue avec option de partage et sauvegarde
    // même pour les scores faibles (encourager l'engagement)
    _showSaveScoreDialog();
  }

  void _showSaveScoreDialog() {
    if (!mounted) {
      print('[QuizScreen] ⚠️ Widget non monté - dialogue de sauvegarde annulé');
      return;
    }

    print('[QuizScreen] 🎯 Affichage du dialogue de sauvegarde de score');
    String playerName = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(TranslationService.translate('congratulations')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/congrats.json',
                  height: 100,
                  repeat: false,
                ),
                const SizedBox(height: 20),
                Text(
                  'Score final: $score points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Questions répondues: ${currentQuestionIndex + 1}/$totalQuestions',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Précision: ${(correctAnswers / totalQuestions * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Excellent score ! Entrez votre nom pour le sauvegarder (optionnel) :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Votre nom...',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    playerName = value.trim();
                  },
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final isPremium = await PremiumService.isPremiumUser();
                      if (!isPremium) {
                        await AdService.showRewardedAdForXPBonus(
                          onRewarded: (int bonusXP) async {
                            // Ajouter le bonus XP
                            await ProgressService.addExperience(bonusXP,
                                reason: 'Bonus Publicité');

                            // Afficher un message de confirmation
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      TranslationService.translateWithParams(
                                          'bonus_xp_earned',
                                          {'xp': bonusXP.toString()})),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        // Utilisateur premium - donner le bonus directement
                        const bonusXP = 50;
                        await ProgressService.addExperience(bonusXP,
                            reason: 'Bonus Premium');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(TranslationService.translate(
                                  'premium_bonus')),
                              backgroundColor: Colors.amber,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      print('[QuizScreen] ❌ Erreur publicité récompensée: $e');
                    }
                  },
                  icon: const Icon(Icons.play_circle),
                  label: Text(TranslationService.translate('watch_ad_for_xp')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // 💰 Bannière publicitaire sur l'écran de résultats
                const AdBannerWidget(
                  placement: 'quiz_results',
                  height: 50,
                  margin: EdgeInsets.all(0),
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        actions: [
          // Organisation en colonnes pour une meilleure présentation
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ligne 1 : Boutons principaux (Partager & Sauvegarder)
              Row(
                children: [
                  // Bouton Partager
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Utiliser le nom saisi ou "Joueur" par défaut
                        final name =
                            playerName.isNotEmpty ? playerName : 'Joueur';
                        LeaderboardService.shareScore(
                          playerName: name,
                          score: score,
                          totalQuestions: totalQuestions,
                          category: widget.category,
                          accuracy: correctAnswers / totalQuestions,
                        );
                        print(
                            '[QuizScreen] 📤 Score partagé: $name - $score points');
                        // Ne pas fermer le dialogue, permettre de partager puis sauvegarder
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(TranslationService.translate('share')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton Sauvegarder et retourner au menu
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (playerName.isEmpty) {
                          // Afficher un message d'erreur si le nom est vide
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(TranslationService.translate(
                                  'enter_name_to_save')),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return; // Ne pas fermer le dialogue
                        }

                        // Sauvegarder le score dans le leaderboard
                        await _saveScoreToLeaderboard(playerName);
                        print(
                            '[QuizScreen] ✅ Score sauvegardé dans le leaderboard: $playerName');

                        // Afficher un message de confirmation
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  TranslationService.translateWithParams(
                                      'score_saved_for', {'name': playerName})),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }

                        Navigator.pop(context);
                        // Retourner à la page d'accueil principale
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      icon: const Icon(Icons.save, size: 18),
                      label:
                          Text(TranslationService.translate('save_and_menu')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ligne 2 : Boutons secondaires (Recommencer & Retour)
              Row(
                children: [
                  // Bouton Recommencer
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Redémarrer le quiz en rechargeant la page
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizScreen(category: widget.category),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(TranslationService.translate('restart')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton Retour au menu
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Retourner au menu sans sauvegarder
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      icon: const Icon(Icons.home, size: 18),
                      label: Text(TranslationService.translate('dont_save')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💾 Sauvegarder le score dans le leaderboard
  Future<void> _saveScoreToLeaderboard(String playerName) async {
    try {
      print('[QuizScreen] 💾 Sauvegarde du score dans le leaderboard...');

      final success = await LeaderboardService.saveRecord(
        playerName: playerName,
        score: score,
        totalQuestions: totalQuestions,
        category: widget.category,
        accuracy: correctAnswers / totalQuestions,
      );

      if (success) {
        print(
            '[QuizScreen] ✅ Score sauvegardé avec succès dans le leaderboard');
        print(
            '[QuizScreen] 📊 Détails: $playerName - $score points - ${(correctAnswers / totalQuestions * 100).toStringAsFixed(1)}%');

        // Sauvegarder aussi le nom du joueur pour usage futur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('player_name', playerName);
      } else {
        print('[QuizScreen] ❌ Échec de la sauvegarde dans le leaderboard');
      }
    } catch (e) {
      print('[QuizScreen] ❌ Erreur lors de la sauvegarde du score: $e');
    }
  }

  Future<void> _savePlayerName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('player_name', name);
      print(
          '[QuizScreen] 💾 Nom du joueur sauvegardé dans SharedPreferences: $name');
    } catch (e) {
      print('[QuizScreen] ❌ Erreur lors de la sauvegarde du nom: $e');
    }
  }

  Future<void> _initializeAudio() async {
    try {
      print('[QuizScreen] 🎵 Initialisation du système audio...');

      // Initialiser le service audio unifié
      await UnifiedAudioServiceOptimized.instance.initialize();

      // Charger les paramètres audio
      await _loadAudioSettings();

      // Démarrer la musique de fond si activée
      if (_backgroundMusicEnabled && _soundEnabled) {
        await _startBackgroundMusic();
      }

      print('[QuizScreen] ✅ Système audio initialisé');
    } catch (e) {
      print('[QuizScreen] ❌ Erreur initialisation audio: $e');
    }
  }

  /// ⏱️ Charger la durée du timer depuis les paramètres
  Future<void> _loadTimerDuration() async {
    try {
      _timerDuration = await SettingsService.getTimerDuration();
      timer = _timerDuration;
      _timerController.duration = Duration(seconds: _timerDuration);
      print('[QuizScreen] ⏱️ Durée du timer chargée: $_timerDuration secondes');
    } catch (e) {
      print('[QuizScreen] ❌ Erreur chargement durée timer: $e');
      _timerDuration = SettingsService.defaultTimerDuration;
      timer = SettingsService.defaultTimerDuration;
      _timerController.duration =
          Duration(seconds: SettingsService.defaultTimerDuration);
    }
  }

  Future<void> _loadAudioSettings() async {
    _backgroundMusicEnabled = await SettingsService.isBackgroundMusicEnabled();
    _soundEnabled = await SettingsService.isSoundEnabled();
    _ttsEnabled = await SettingsService.isTtsEnabled(); // Charger l'état de TTS

    print(
        '[QuizScreen] _loadAudioSettings - Musique: $_backgroundMusicEnabled, Sons: $_soundEnabled, TTS: $_ttsEnabled');

    // Debug: Vérifier les valeurs
    print('[QuizScreen] DEBUG - _soundEnabled = $_soundEnabled');
    print(
        '[QuizScreen] DEBUG - _backgroundMusicEnabled = $_backgroundMusicEnabled');

    // Forcer la mise à jour des volumes
    if (_soundEnabled) {
      await UnifiedAudioServiceOptimized.instance.setEffectVolume(0.7);
      print('[QuizScreen] 🔊 Volume des effets réglé à 0.7');
    }

    if (_backgroundMusicEnabled) {
      await UnifiedAudioServiceOptimized.instance.setBackgroundVolume(
          SettingsService.defaultBackgroundVolume);
      print(
          '[QuizScreen] 🎵 Volume de la musique réglé à ${SettingsService.defaultBackgroundVolume}');
    }
  }

  // Méthode pour démarrer la musique de fond
  Future<void> _startBackgroundMusic() async {
    print(
        '[QuizScreen] _startBackgroundMusic - Vérification: _backgroundMusicEnabled = $_backgroundMusicEnabled');

    if (_backgroundMusicEnabled) {
      print('[QuizScreen] _startBackgroundMusic - lancement musique de fond');
      await UnifiedAudioServiceOptimized.instance.playBackgroundMusic();
    } else {
      print(
          '[QuizScreen] _startBackgroundMusic - musique de fond désactivée dans les paramètres');
    }
  }

  // Méthode pour vérifier et appliquer les paramètres audio en temps réel
  Future<void> _checkAndApplyAudioSettings() async {
    final currentBackgroundMusicEnabled =
        await SettingsService.isBackgroundMusicEnabled();
    final currentSoundEnabled = await SettingsService.isSoundEnabled();

    // Mettre à jour l'état des sons
    _soundEnabled = currentSoundEnabled;

    // Gérer la musique de fond seulement si pas de publicité
    if (!UnifiedAudioServiceOptimized.instance.isAdPlaying) {
      if (!currentBackgroundMusicEnabled && _backgroundMusicEnabled) {
        print(
            '[QuizScreen] _checkAndApplyAudioSettings - Arrêt musique de fond (désactivée)');
        await UnifiedAudioServiceOptimized.instance
            .setBackgroundMusicEnabled(false);
        _backgroundMusicEnabled = false;
      } else if (currentBackgroundMusicEnabled && !_backgroundMusicEnabled) {
        print(
            '[QuizScreen] _checkAndApplyAudioSettings - Lancement musique de fond (activée)');
        _backgroundMusicEnabled = true;
        await UnifiedAudioServiceOptimized.instance.playBackgroundMusic();
      }
    }

    print(
        '[QuizScreen] _checkAndApplyAudioSettings - État: Musique=$_backgroundMusicEnabled, Sons=$_soundEnabled, Pub=${UnifiedAudioServiceOptimized.instance.isAdPlaying}');
  }

  // Méthode pour arrêter la musique de fond
  Future<void> _stopBackgroundMusic() async {
    print('[QuizScreen] _stopBackgroundMusic - arrêt musique de fond');
    await UnifiedAudioServiceOptimized.instance
        .setBackgroundMusicEnabled(false);
  }

  // Méthode pour démarrer la vérification périodique des paramètres audio
  void _startAudioSettingsCheck() {
    _audioSettingsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isPaused && !isGameOver) {
        _checkAndApplyAudioSettings();
      }
    });
    print(
        '[QuizScreen] _startAudioSettingsCheck - Vérification audio démarrée (5s)');
  }

  // Vérifier si une question est dynamique
  bool _isDynamicQuestion(int questionIndex) {
    if (questionIndex >= currentQuestions.length) return false;

    final question = currentQuestions[questionIndex];

    // Vérifier si la question a des propriétés dynamiques
    // (basé sur le contenu ou des marqueurs spéciaux)
    return question.question.contains('Combien font') ||
        question.question.contains('En quelle année') ||
        question.question.contains('Quel jour') ||
        question.question.contains('solstice') ||
        question.question.contains('équinoxe') ||
        question.question.contains('hiberne');
  }

  // Vérifier si une question est communautaire
  bool _isCommunityQuestion(int questionIndex) {
    if (questionIndex >= currentQuestions.length) return false;

    final question = currentQuestions[questionIndex];

    // Vérifier si la question a des propriétés communautaires
    // (basé sur le contenu ou des marqueurs spéciaux)
    return question.question.contains('Mali') ||
        question.question.contains('Tô') ||
        question.question.contains('Soundiata') ||
        question.question.contains('régions administratives') ||
        question.question.contains('π × r²') ||
        question.question.contains('Au');
  }

  // ⚠️ DÉSACTIVÉ : Les questions d'engagement génériques créent de la confusion
  // car elles apparaissent dans toutes les catégories sans rapport avec le sujet
  // Exemple : "Quelle est votre série de connexions actuelle ?" dans "Histoire du Mali"

  // Charger les questions d'engagement de manière asynchrone
  Future<void> _loadEngagementQuestions() async {
    // FONCTIONNALITÉ DÉSACTIVÉE
    // Les questions d'engagement ("Quelle est votre série de connexions actuelle ?", etc.)
    // sont des questions génériques qui n'ont rien à voir avec la catégorie choisie
    // et qui apparaissent de manière inappropriée dans tous les quiz

    /* ANCIEN CODE DÉSACTIVÉ
    try {
      final engagementQuestions =
          await DailyEngagementService.generateEngagementQuestions(
        widget.category,
        count: 2,
      );

      // Ajouter aux questions existantes
      currentQuestions.addAll(engagementQuestions);
      currentQuestions.shuffle();

      // ⚠️ IMPORTANT : Remélanger les réponses après avoir mélangé les questions !
      // Sinon les réponses ne correspondent plus aux questions
      _shuffleAllAnswers();

      print(
          '[QuizScreen] 🎯 Questions d\'engagement chargées: ${engagementQuestions.length}');
    } catch (e) {
      print('[QuizScreen] ❌ Erreur chargement questions d\'engagement: $e');
    }
    */

    print(
        '[QuizScreen] ℹ️ Questions d\'engagement désactivées (pour éviter la confusion)');
  }

  @override
  void dispose() {
    print('[QuizScreen] 🧹 Début du nettoyage des ressources...');

    // ✅ Annuler les timers de manière sécurisée
    try {
      _timer.cancel();
      print('[QuizScreen] ✅ Timer principal annulé');
    } catch (e) {
      print('[QuizScreen] ⚠️ Erreur annulation timer: $e');
    }

    try {
      _audioSettingsTimer.cancel();
      print('[QuizScreen] ✅ Timer audio settings annulé');
    } catch (e) {
      print('[QuizScreen] ⚠️ Erreur annulation audio timer: $e');
    }

    // ✅ Disposer les contrôleurs d'animation de manière sécurisée
    try {
      _timerController.dispose();
      _questionController.dispose();
      _feedbackController.dispose();
      print('[QuizScreen] ✅ Animation controllers disposés');
    } catch (e) {
      print('[QuizScreen] ⚠️ Erreur dispose controllers: $e');
    }

    // ✅ Arrêter la musique de fond
    try {
      _stopBackgroundMusic();
      print('[QuizScreen] ✅ Musique de fond arrêtée');
    } catch (e) {
      print('[QuizScreen] ⚠️ Erreur arrêt musique: $e');
    }

    // ✅ Arrêter le TTS
    try {
      MultilingualTTSService.stop();
      print('[QuizScreen] ✅ TTS arrêté');
    } catch (e) {
      print('[QuizScreen] ⚠️ Erreur arrêt TTS: $e');
    }

    print('[QuizScreen] 🧹 Nettoyage des ressources terminé');
    super.dispose();
  }

  Future<void> _toggleTts(String text) async {
    if (ttsActive) {
      await MultilingualTTSService.stop();
      setState(() {
        ttsActive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(TranslationService.translate('tts_disabled')),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1)),
      );
    } else {
      await MultilingualTTSService.speak(text);
      setState(() {
        ttsActive = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(TranslationService.translate('tts_enabled')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1)),
      );
    }
  }

  void _speakQuestion() async {
    print(
        '[QuizScreen] _speakQuestion - Vérification: _ttsEnabled=$_ttsEnabled, questions=${currentQuestions.length}');

    if (_ttsEnabled && currentQuestions.isNotEmpty) {
      try {
        await MultilingualTTSService.speakQuestion(
            currentQuestions[currentQuestionIndex].question);
        print(
            '[QuizScreen] _speakQuestion - TTS multilingue activé pour la question: ${currentQuestions[currentQuestionIndex].question}');
      } catch (e) {
        print('[QuizScreen] _speakQuestion - Erreur TTS: $e');
      }
    } else {
      print('[QuizScreen] _speakQuestion - TTS désactivée ou pas de questions');
    }
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    // Arrêter la lecture TTS si on met en pause
    if (isPaused) {
      MultilingualTTSService.stop();
      setState(() {
        ttsActive = false;
      });
    }

    if (isPaused) {
      _timer.cancel();
      _timerController.stop();
      _showPauseDialog();
    } else {
      _startTimer();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quiz en pause',
          style: TextStyle(fontFamily: 'Raleway', fontSize: 24),
        ),
        content: const Text(
          'Le quiz est actuellement en pause. Appuyez sur "Reprendre" pour continuer.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              togglePause();
            },
            child: Text(TranslationService.translate('resume')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading ||
        currentQuestions.isEmpty ||
        currentQuestionIndex >= currentQuestions.length) {
      return Scaffold(
        backgroundColor: Colors.purple[700],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Chargement des questions...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Raleway',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = currentQuestions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Réduit de 20 à 12,8
            child: Column(
              children: [
                // EN-TÊTE AMÉLIORÉ AVEC SCORE ET PROGRESSION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Score avec icône
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Score: $score',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Progression avec icône
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.quiz,
                            color: Colors.cyan,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentQuestionIndex + 1}/$totalQuestions',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bouton pause amélioré
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: IconButton(
                        onPressed: _pauseGame,
                        icon: const Icon(
                          Icons.pause_circle_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10), // Réduit de 20 à 10

                // TIMER MODERNE ET VISIBLE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Réduit de 20,12 à 16,8
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isTimerComfortable()
                          ? [Colors.purple.shade400, Colors.purple.shade600]
                          : _isTimerWarning()
                              ? [Colors.orange.shade400, Colors.orange.shade600]
                              : [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: (_isTimerComfortable()
                                ? Colors.purple
                                : _isTimerWarning()
                                    ? Colors.orange
                                    : Colors.red)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        TranslationService.translateWithParams(
                            'time_remaining_seconds',
                            {'seconds': timer.toString()}),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12), // Réduit de 20 à 12

                // QUESTION AVEC DESIGN AMÉLIORÉ
                AnimatedBuilder(
                  animation: _questionAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _questionAnimation.value)),
                      child: Opacity(
                        opacity: _questionAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding:
                              const EdgeInsets.all(18), // Réduit de 25 à 18
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icône de question avec indicateur dynamique
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.quiz,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  // Indicateur pour questions dynamiques
                                  if (_isDynamicQuestion(currentQuestionIndex))
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.amber, Colors.orange],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.amber.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Dynamique',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_isCommunityQuestion(
                                      currentQuestionIndex))
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.purple,
                                            Colors.deepPurple
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.purple.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Communauté',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12), // Réduit de 20 à 12
                              Text(
                                question.question,
                                style: const TextStyle(
                                  fontSize: 20, // Réduit de 22 à 20
                                  color: Colors.white,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10), // Réduit de 15 à 10
                              // Bouton TTS amélioré
                              if (_ttsEnabled)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        _toggleTts(question.question),
                                    icon: Icon(
                                      ttsActive
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12), // Réduit de 20 à 12

                // Réponses avec animation (🎲 MÉLANGÉES)
                ...(_shuffledAnswers[currentQuestionIndex] ??
                        question.answers.entries.toList())
                    .asMap()
                    .entries
                    .map((indexedEntry) {
                  final answerIndex = indexedEntry.key;
                  final entry = indexedEntry.value;
                  final optionText = entry.key;
                  final isCorrect = entry.value;
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8), // Réduit de 10 à 8
                    child: AnimatedBuilder(
                      animation: _questionAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset:
                              Offset(0, 30 * (1 - _questionAnimation.value)),
                          child: Opacity(
                            opacity: _questionAnimation.value.clamp(0.0, 1.0),
                            child: GestureDetector(
                              onTap: () => checkAnswer(answerIndex, isCorrect),
                              child: AnimatedBuilder(
                                animation: _feedbackAnimation,
                                builder: (context, child) {
                                  Color backgroundColor =
                                      Colors.white.withValues(alpha: 0.1);
                                  Color borderColor =
                                      Colors.white.withValues(alpha: 0.2);
                                  double scale = 1.0;
                                  List<BoxShadow>? boxShadow;

                                  // Appliquer les couleurs de feedback si affiché
                                  if (_showFeedback) {
                                    // TOUJOURS montrer la bonne réponse en VERT (même si non sélectionnée)
                                    if (isCorrect) {
                                      backgroundColor =
                                          Colors.green.withValues(alpha: 0.4);
                                      borderColor = Colors.green;
                                      scale = 1.0 +
                                          (_feedbackAnimation.value * 0.15);
                                      boxShadow = [
                                        BoxShadow(
                                          color: Colors.green
                                              .withValues(alpha: 0.6),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ];
                                    }
                                    // Montrer SEULEMENT la mauvaise réponse SÉLECTIONNÉE en ROUGE
                                    else if (_selectedAnswerIndex ==
                                            answerIndex &&
                                        !isCorrect) {
                                      // Cette réponse a été sélectionnée ET elle est fausse
                                      backgroundColor =
                                          Colors.red.withValues(alpha: 0.4);
                                      borderColor = Colors.red;
                                      scale = 1.0 -
                                          (_feedbackAnimation.value * 0.05);
                                      boxShadow = [
                                        BoxShadow(
                                          color:
                                              Colors.red.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ];
                                    }
                                  }

                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical:
                                              12), // Réduit vertical de 15 à 12
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: borderColor,
                                          width: _showFeedback ? 3 : 1,
                                        ),
                                        boxShadow: boxShadow,
                                      ),
                                      child: _showFeedback &&
                                              _selectedAnswerCorrect ==
                                                  isCorrect
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  optionText,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontFamily: 'Raleway',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            )
                                          : _showFeedback &&
                                                  _selectedAnswerCorrect !=
                                                      null &&
                                                  !isCorrect
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.cancel,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      optionText,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontFamily: 'Raleway',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  optionText,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontFamily: 'Raleway',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 15),

                // Score actuel
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Score: $score points',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSimpleResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(TranslationService.translate('quiz_finished')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_emotions,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              'Score final: $score points',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Questions répondues: ${currentQuestionIndex + 1}/$totalQuestions',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Précision: ${(correctAnswers / totalQuestions * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Continuez à vous entraîner pour améliorer votre score !',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Redémarrer le quiz
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => QuizScreen(category: widget.category),
                ),
              );
            },
            child: Text(TranslationService.translate('restart')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retourner au menu principal
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(TranslationService.translate('main_menu')),
          ),
        ],
      ),
    );
  }
}
