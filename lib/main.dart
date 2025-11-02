import 'dart:async';
import 'package:flutter/material.dart';
import 'services/question_service_optimized.dart'; // ⚡ OPTIMISÉ
import 'services/settings_service.dart';
import 'services/ad_service.dart';
import 'models/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/enhanced_premium_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'services/premium_service.dart';
import 'services/translation_service.dart';
import 'services/localization_service.dart';
import 'services/unified_audio_service_optimized.dart'; // ⚡ OPTIMISÉ
import 'services/question_translation_service.dart';
import 'components/flame_animations.dart';
import 'services/progress_service.dart';
import 'services/leaderboard_service.dart';
import 'services/badge_notification_service.dart';
import 'services/badge_service.dart';
import 'theme/app_theme.dart';
import 'home.dart' as home_screen;
import 'screens/loading_screen.dart';
import 'widgets/ad_banner_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print('[main] 🚀 Démarrage de Quiz4U...');

  // Lancer l'application avec l'écran de chargement
  // Toutes les initialisations se feront dans LoadingScreen
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _themeMode = 'système';
  StreamSubscription<String>? _languageSubscription;
  String _currentLanguage = 'fr'; // Langue actuelle pour forcer le rebuild

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadCurrentLanguage();
    _setupLanguageListener();
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LocalizationService.getCurrentLanguage();
    setState(() {
      _currentLanguage = language;
    });
  }

  void _setupLanguageListener() {
    // Écouter les changements de langue
    _languageSubscription =
        LocalizationService.languageChangeStream.listen((language) async {
      print('[MyApp] 🌍 Changement de langue détecté: $language');

      // 🌍 Recharger les questions traduites
      try {
        await QuestionServiceOptimized.reloadQuestionsForLanguage(language);
        print('[MyApp] ✅ Questions rechargées pour langue: $language');
      } catch (e) {
        print('[MyApp] ⚠️ Erreur rechargement questions: $e');
      }

      // Forcer le rebuild COMPLET de toute l'application avec une nouvelle clé
      if (mounted) {
        setState(() {
          _currentLanguage = language;
        });
        print('[MyApp] ✅ Interface complète rechargée avec langue: $language');
      }
    });
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await SettingsService.getThemeMode();

    // Validation du thème - s'assurer qu'il correspond aux options disponibles
    final validThemeModes = ['clair', 'sombre', 'système'];
    final validatedThemeMode =
        validThemeModes.contains(themeMode) ? themeMode : 'système';

    setState(() {
      _themeMode = validatedThemeMode;
    });
    print('[MyApp] 🎨 Thème chargé: $_themeMode (validé: $validatedThemeMode)');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(
          _currentLanguage), // Clé qui change avec la langue pour forcer le rebuild
      title: 'Quizz4u',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _getThemeMode(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/home': (context) =>
            home_screen.HomeScreen(key: ValueKey(_currentLanguage)),
        '/about': (context) => AboutScreen(key: ValueKey(_currentLanguage)),
        '/settings': (context) => SettingsScreen(
              key: ValueKey(_currentLanguage),
              onThemeChanged: _loadThemeMode,
            ),
        '/premium': (context) =>
            EnhancedPremiumScreen(key: ValueKey(_currentLanguage)),
        '/daily_challenge': (context) =>
            DailyChallengeScreen(key: ValueKey(_currentLanguage)),
        '/statistics': (context) =>
            LeaderboardScreen(key: ValueKey(_currentLanguage)),
        '/profile': (context) => ProfileScreen(key: ValueKey(_currentLanguage)),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // Utiliser les thèmes prédéfinis de AppTheme
    return brightness == Brightness.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  ThemeMode _getThemeMode() {
    switch (_themeMode) {
      case 'clair':
        return ThemeMode.light;
      case 'sombre':
        return ThemeMode.dark;
      case 'système':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}

// ========== ACCUEIL ==========
// Note: Le HomeScreen principal est maintenant dans lib/home.dart
// Cette version a été migrée vers un design moderne avec animations

// ========== ÉCRAN QUIZ ==========
class QuizScreen extends StatefulWidget {
  final String category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionModel> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final loadedQuestions = await getQuestionsForCategory(widget.category);
    setState(() {
      questions = loadedQuestions;
      isLoading = false;
    });
  }

  Future<List<QuestionModel>> getQuestionsForCategory(String category) async {
    // ⚡ Les questions sont déjà chargées dans LoadingScreen
    if (!QuestionServiceOptimized.isLoaded) {
      await QuestionServiceOptimized.loadEssentialQuestions();
    }
    return QuestionServiceOptimized.getSmartQuestionsForCategory(category,
        count: 10);
  }

  @override
  Widget build(BuildContext context) {
    // Traduire la catégorie avant de l'afficher
    final translatedCategory =
        QuestionTranslationService.translateCategory(widget.category);

    if (isLoading || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(TranslationService.translateWithParams(
              'quiz_category_title', {'category': translatedCategory})),
          backgroundColor: Colors.purple[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                TranslationService.translate('loading_questions'),
                style: const TextStyle(fontSize: 18, fontFamily: 'Raleway'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translateWithParams(
            'quiz_category_title', {'category': translatedCategory})),
        backgroundColor: Colors.purple[700],
      ),
      body: QuizPage(questions: questions, category: widget.category),
    );
  }
}

// ========== PAGE DU QUIZ ==========
class QuizPage extends StatefulWidget {
  final List<QuestionModel> questions;
  final String category;

  const QuizPage({super.key, required this.questions, required this.category});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  Timer? _timer;
  double progress = 1.0;
  int totalTime = 15;
  bool isPaused = false;
  bool showCorrectAnswer = false;
  bool isSpeaking = false;
  bool autoSpeechEnabled = true;
  bool backgroundMusicEnabled = true;
  bool animationsEnabled = true;
  int questionsSinceLastAd = 0;

  // Variables pour les animations Flame
  bool _showGoodAnimation = false;
  bool _showLevelUpAnimation = false;

  late FlutterTts flutterTts;
  late AnimationController _timerAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initializeAnimations();
    _loadSettings();
    _loadInterstitialAd();

    // Lire la première question si TTS est activé
    if (autoSpeechEnabled) {
      _speakQuestion();
    }

    _startTimer(); // Démarrer le timer
  }

  void _initializeAnimations() {
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final timerDuration = prefs.getInt('timer_duration') ?? 15;
    print(
        '[QuizPage] 🔄 Chargement paramètres timer: $totalTime -> $timerDuration secondes');
    setState(() {
      autoSpeechEnabled = prefs.getBool('tts_enabled') ?? true;
      backgroundMusicEnabled = prefs.getBool('background_music') ?? true;
      animationsEnabled = prefs.getBool('animations_enabled') ?? true;
      totalTime = timerDuration;
    });
    print('[QuizPage] ✅ Timer configuré: $totalTime secondes');
    print(
        '[QuizPage] ✅ Animations: ${animationsEnabled ? 'activées' : 'désactivées'}');

    // Initialiser TTS
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Démarrer la musique de fond si activée
    if (backgroundMusicEnabled) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          UnifiedAudioServiceOptimized.instance.playBackgroundMusic();
        }
      });
    }
  }

  // Méthode pour charger les paramètres sans relire la question
  Future<void> _loadSettingsWithoutTTS() async {
    final prefs = await SharedPreferences.getInstance();
    final timerDuration = prefs.getInt('timer_duration') ?? 15;
    setState(() {
      autoSpeechEnabled = prefs.getBool('tts_enabled') ?? true;
      backgroundMusicEnabled = prefs.getBool('background_music') ?? true;
      animationsEnabled = prefs.getBool('animations_enabled') ?? true;
      totalTime = timerDuration;
    });
  }

  void _loadInterstitialAd() async {
    await AdService.loadInterstitialAd();
  }

  // Méthode pour lire la question actuelle
  void _speakQuestion() async {
    if (!autoSpeechEnabled || currentQuestionIndex >= widget.questions.length) {
      return;
    }

    final currentQuestion = widget.questions[currentQuestionIndex];
    await flutterTts.speak(currentQuestion.question);
  }

  // Méthode pour arrêter la lecture
  void _stopSpeaking() async {
      await flutterTts.stop();
  }

  // Méthode pour basculer l'activation du TTS (appui long)
  void _toggleTTS() async {
    final prefs = await SharedPreferences.getInstance();
      setState(() {
      autoSpeechEnabled = !autoSpeechEnabled;
    });
    await prefs.setBool('tts_enabled', autoSpeechEnabled);

    if (autoSpeechEnabled) {
        _speakQuestion();
      } else {
      _stopSpeaking();
    }
  }

  void _startTimer() {
    // Arrêter le timer précédent s'il existe
    _timer?.cancel();

    print('[QuizPage] 🕐 Démarrage timer: $totalTime secondes');

    // Démarrer une animation fluide du timer
    _timerAnimationController.duration = Duration(seconds: totalTime);
    _timerAnimationController.reset();
    _timerAnimationController.forward();

    // Timer pour vérifier la fin
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
      setState(() {
          progress = 1.0 - _timerAnimationController.value;

          if (progress <= 0) {
            _timer?.cancel();
            _checkAnswer(null);
          }
        });
      }
    });
  }

  void _checkAnswer(String? answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;
      showCorrectAnswer = true;
    });

    _timer?.cancel();

    final currentQuestion = widget.questions[currentQuestionIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    if (isCorrect) {
      score++;
      // Jouer le son et l'animation pour bonne réponse
      UnifiedAudioServiceOptimized.instance.playGoodSound();
      if (animationsEnabled) {
        setState(() {
          _showGoodAnimation = true;
        });
      }
    } else {
      // Jouer le son pour mauvaise réponse
      UnifiedAudioServiceOptimized.instance.playBadSound();
    }

    // Enregistrer automatiquement la réponse pour les statistiques
    ProgressService.addAnswer(isCorrect, 1, widget.category);

    // Incrémenter le compteur de questions pour les publicités
    questionsSinceLastAd++;

    // Attendre que l'animation se termine avant de passer à la question suivante
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
      setState(() {
          _showGoodAnimation = false;
          selectedAnswer = null;
          showCorrectAnswer = false;
          progress = 1.0;
          currentQuestionIndex++;
        });

        if (currentQuestionIndex < widget.questions.length) {
          // Recharger les paramètres avant la question suivante (sans relire la question)
          _loadSettingsWithoutTTS();

          // Afficher une publicité après chaque 3 questions
          if (questionsSinceLastAd >= 3) {
            // Arrêter la musique avant la publicité
            if (backgroundMusicEnabled) {
              UnifiedAudioServiceOptimized.instance.stopBackgroundMusic();
            }

            // Vérifier le statut premium de manière asynchrone
            PremiumService.isPremiumUser().then((isPremium) {
              if (!isPremium) {
                AdService.showInterstitialAd();
                questionsSinceLastAd = 0;
                _loadInterstitialAd(); // Recharger une nouvelle publicité
              } else {
                print(
                    '[QuizScreen] 🚫 Utilisateur premium - aucune publicité stratégique');
              }
            });

            // Reprendre la musique après la publicité
    Future.delayed(const Duration(seconds: 2), () {
              if (backgroundMusicEnabled && mounted) {
                UnifiedAudioServiceOptimized.instance.playBackgroundMusic();
              }
            });
          }

          _startTimer();
          _speakQuestion(); // Lire la nouvelle question
    } else {
          _finishQuiz();
        }
      }
    });
  }

  void _finishQuiz() async {
    // Vérifier les nouveaux badges
    final newBadges = BadgeService.checkAllBadges(
        ProgressService.currentProgress, widget.category, 'mixed');

    // Afficher l'animation de niveau si bon score et animations activées
    if (score >= (widget.questions.length * 0.8) && animationsEnabled) {
    setState(() {
        _showLevelUpAnimation = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
      setState(() {
            _showLevelUpAnimation = false;
          });
        }
      });
    }

    // Afficher les notifications de badges après l'animation de niveau
    if (newBadges.isNotEmpty) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          BadgeNotificationService.showMultipleBadgeNotifications(
        context,
            newBadges,
          );
        }
      });
    }

    // Sauvegarder le score (commenté car ProgressService.saveScore n'existe pas)
    // await ProgressService.saveScore(widget.category, score, widget.questions.length);

    // Afficher les résultats après un délai
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _showResults();
      }
    });
  }

  void _showResults() async {
    final accuracy = score / widget.questions.length;
    final percentage = (accuracy * 100).toInt();

    // SAUVEGARDER LE SCORE AVANT TOUT
    print('[QuizPage] 🎯 Sauvegarde du score final...');
    try {
      // Calculer les statistiques finales
      int totalQuestionsAnswered = widget.questions.length;
      double accuracyRate = (score / totalQuestionsAnswered) * 100;

      // Enregistrer le score total dans la progression
      int totalXP = score; // 1 point = 1 XP
      await ProgressService.addExperience(totalXP,
          reason: 'Score Quiz ${widget.category}');
      print('[QuizPage] 🎯 XP total ajouté: +$totalXP XP');

      // Ajouter un bonus pour la précision
      if (accuracyRate >= 80) {
        int bonusXP =
            (accuracyRate - 80).round() * 2; // Bonus pour haute précision
        await ProgressService.addExperience(bonusXP, reason: 'Bonus Précision');
        print('[QuizPage] 🎁 Bonus précision: +$bonusXP XP');
      }

      // Ajouter un bonus pour le score élevé
      if (score >= totalQuestionsAnswered * 8) {
        // 80% du score max
        int bonusXP = 10;
        await ProgressService.addExperience(bonusXP,
            reason: 'Bonus Score Élevé');
        print('[QuizPage] 🎁 Bonus score élevé: +$bonusXP XP');
      }

      // Calculer les bonnes réponses basées sur le score réel
      int correctAnswers = 0;
      int wrongAnswers = 0;

      // Le score est directement le nombre de bonnes réponses
      // (pas multiplié par 10 comme dans l'ancienne logique)
      correctAnswers = score;
      wrongAnswers = totalQuestionsAnswered - correctAnswers;

      // S'assurer que les valeurs sont cohérentes
      if (correctAnswers > totalQuestionsAnswered) {
        correctAnswers = totalQuestionsAnswered;
        wrongAnswers = 0;
      }
      if (wrongAnswers < 0) {
        wrongAnswers = 0;
      }

      // Bonus de performance par catégorie
      double categoryPerformance =
          (correctAnswers / totalQuestionsAnswered) * 100;

      // Bonus pour excellente performance (90%+)
      if (categoryPerformance >= 90) {
        int performanceBonus = 15;
        await ProgressService.addExperience(performanceBonus,
            reason: 'Bonus Performance ${widget.category}');
        print(
            '[QuizPage] 🏆 Bonus performance catégorie: +$performanceBonus XP');
      }
      // Bonus pour bonne performance (80-89%)
      else if (categoryPerformance >= 80) {
        int performanceBonus = 10;
        await ProgressService.addExperience(performanceBonus,
            reason: 'Bonus Performance ${widget.category}');
        print(
            '[QuizPage] 🏆 Bonus performance catégorie: +$performanceBonus XP');
      }
      // Bonus pour performance correcte (70-79%)
      else if (categoryPerformance >= 70) {
        int performanceBonus = 5;
        await ProgressService.addExperience(performanceBonus,
            reason: 'Bonus Performance ${widget.category}');
        print(
            '[QuizPage] 🏆 Bonus performance catégorie: +$performanceBonus XP');
      }

      // Les statistiques sont déjà enregistrées automatiquement lors de chaque réponse
      print(
          '[QuizPage] 📊 Statistiques automatiquement enregistrées pendant le quiz');

      print(
          '[QuizPage] 📊 Statistiques complètes: $correctAnswers bonnes, $wrongAnswers mauvaises sur $totalQuestionsAnswered');

      // Forcer la mise à jour des statistiques
      await ProgressService.loadProgress();

      print(
          '[QuizPage] ✅ Score final sauvegardé: $score points, Précision: ${accuracyRate.toStringAsFixed(1)}%');

      // Afficher un message de confirmation
      if (context.mounted) {
        int totalBonus =
            (accuracyRate >= 80 ? (accuracyRate - 80).round() * 2 : 0) +
                (score >= totalQuestionsAnswered * 8 ? 10 : 0) +
                (categoryPerformance >= 90
                    ? 15
                    : categoryPerformance >= 80
                        ? 10
                        : categoryPerformance >= 70
                            ? 5
                            : 0);

        String performanceMessage = '';
        if (categoryPerformance >= 90) {
          performanceMessage = '🏆 Performance excellente !';
        } else if (categoryPerformance >= 80) {
          performanceMessage = '🏆 Performance très bonne !';
        } else if (categoryPerformance >= 70) {
          performanceMessage = '🏆 Performance correcte !';
        }

        // ✅ Vérifier que le widget est toujours monté avant d'utiliser context
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '🎯 ${TranslationService.translate('score_saved')} +$totalXP XP + $totalBonus ${TranslationService.translate('bonus')}'),
                if (performanceMessage.isNotEmpty)
                  Text(performanceMessage,
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('[QuizPage] ❌ Erreur sauvegarde score: $e');
    }

    // LANCEMENT DE LA PUB À LA FIN DU QUIZ (seulement si pas premium)
    print('[QuizPage] 📺 Vérification publicité fin de quiz');
    await UnifiedAudioServiceOptimized.instance.stopBackgroundMusic();
    final isPremium = await PremiumService.isPremiumUser();
    if (!isPremium) {
      await AdService.showInterstitialAd();
      await Future.delayed(const Duration(seconds: 1));
    } else {
      print('[QuizPage] 🚫 Utilisateur premium - aucune publicité fin de quiz');
    }
    await UnifiedAudioServiceOptimized.instance.playBackgroundMusic();

    // ✅ Vérifier que le widget est toujours monté avant d'utiliser context
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.purple[100],
          title: Text(
            score >= (widget.questions.length * 0.8)
                ? '🎉 ${TranslationService.translate('excellent')}'
                : TranslationService.translate('well_played'),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.purple,
              fontFamily: 'Raleway',
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $score/${widget.questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Raleway',
                  color: Colors.purple,
                ),
              ),
                          const SizedBox(height: 10),
                          Text(
                '$percentage%',
                            style: const TextStyle(
                  fontSize: 18,
                              fontFamily: 'Raleway',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),

              // 💰 Bannière publicitaire sur l'écran de résultats
              const AdBannerWidget(
                placement: 'quiz_results_main',
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 8),
              ),

              const SizedBox(height: 10),

                  // Boutons d'action
                  Row(
                    children: [
                  Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                            MaterialPageRoute(
                            builder: (context) => LeaderboardScreen(
                              currentScore: score,
                              totalQuestions: widget.questions.length,
                              category: widget.category,
                              accuracy: accuracy,
                            ),
                            ),
                          );
                        },
                      icon: const Icon(Icons.emoji_events),
                      label: Text(TranslationService.translate('records')),
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                        Navigator.of(context).pop();
                        LeaderboardService.shareScore(
                          playerName: 'Joueur',
                          score: score,
                          totalQuestions: widget.questions.length,
                          category: widget.category,
                          accuracy: accuracy,
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: Text(TranslationService.translate('share')),
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const home_screen.HomeScreen(),
                  ),
                );
              },
              child: Text(
                TranslationService.translate('back_to_menu'),
                style: const TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _pulseAnimationController.dispose();
    flutterTts.stop();

    // Arrêter la musique de fond
    UnifiedAudioServiceOptimized.instance.stopBackgroundMusic();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= widget.questions.length) {
    return Scaffold(
      backgroundColor: Colors.purple,
        body: Stack(
          children: [
            Center(
              child: Text(
                TranslationService.translate('quiz_finished'),
                style: const TextStyle(
                  fontSize: 32,
            color: Colors.white,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
            if (_showLevelUpAnimation)
              LevelUpConfetti(
                onComplete: () {
                  setState(() {
                    _showLevelUpAnimation = false;
                  });
                },
              ),
          ],
        ),
      );
    }

    final currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.purple,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Barre de progression et chronomètre
            Column(
              children: [
                // Barre de progression
            Container(
                  height: 8,
              decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white24,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (currentQuestionIndex + 1) / widget.questions.length,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Chronomètre animé
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white24,
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      Color timerColor = Colors.white;
                      if (progress <= 0.3) {
                        timerColor = Colors.red;
                      } else if (progress <= 0.6) {
                        timerColor = Colors.orange;
                      }

                  return Container(
                        width: (MediaQuery.of(context).size.width *
                                progress *
                                0.9)
                            .clamp(
                                0.0, MediaQuery.of(context).size.width * 0.9),
                    decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: timerColor,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Informations du quiz
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                      '${TranslationService.translate('score')}: $score',
                          style: const TextStyle(
                        fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        Text(
                      '${TranslationService.translate('question')} ${currentQuestionIndex + 1}/${widget.questions.length}',
                          style: const TextStyle(
                        fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ],
                    ),
              ],
            ),
            const SizedBox(height: 20),

            // Question avec bouton TTS
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Bouton TTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
              children: [
                      GestureDetector(
                        onTap: _speakQuestion, // Appui simple pour relire
                        onLongPress:
                            _toggleTTS, // Appui long pour activer/désactiver
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: autoSpeechEnabled
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color:
                                  autoSpeechEnabled ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                autoSpeechEnabled
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                      color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                autoSpeechEnabled
                                    ? TranslationService.translate(
                                        'tts_enabled')
                                    : TranslationService.translate(
                                        'tts_disabled'),
                                style: const TextStyle(
                      color: Colors.white,
                                  fontSize: 12,
                      fontFamily: 'Raleway',
                                  fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Question
                  Expanded(
                    child: Center(
                      child: Text(
                        currentQuestion.question,
          style: const TextStyle(
                          fontSize: 24,
            color: Colors.white,
            fontFamily: 'Raleway',
          ),
                        textAlign: TextAlign.center,
                      ),
          ),
        ),
      ],
              ),
            ),

            // Zone des réponses avec plus d'espace
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Réponses (toujours présentes)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      ...currentQuestion.answers.keys.map((option) {
                        final isSelected = selectedAnswer == option;
                        final isCorrect =
                            option == currentQuestion.correctAnswer;
                        final showCorrect = showCorrectAnswer && isCorrect;

                        Color buttonColor = Colors.white24;
                        Color textColor = Colors.white;

                        if (isSelected && isCorrect) {
                          buttonColor = Colors.green;
                          textColor = Colors.white;
                        } else if (isSelected && !isCorrect) {
                          buttonColor = Colors.red;
                          textColor = Colors.white;
                        } else if (showCorrect) {
                          buttonColor = Colors.green;
                          textColor = Colors.white;
                        }

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: TextButton(
                            onPressed: selectedAnswer == null
                                ? () => _checkAnswer(option)
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: buttonColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            child: Text(
                              option,
                        style: TextStyle(
                                fontSize: 18,
                                color: textColor,
                          fontFamily: 'Raleway',
                        ),
                      ),
                          ),
                        );
                      }),
                    ],
                  ),

                  // Animations superposées
                  if (_showGoodAnimation && animationsEnabled)
                    Positioned.fill(
                      child: GoodAnswerParticles(
                        onComplete: () {
                          if (mounted) {
                            setState(() {
                              _showGoodAnimation = false;
                            });
                          }
                        },
                      ),
                    ),

                  if (_showLevelUpAnimation && animationsEnabled)
                    Positioned.fill(
                      child: LevelUpConfetti(
                        onComplete: () {
                          if (mounted) {
                            setState(() {
                              _showLevelUpAnimation = false;
                            });
                          }
                        },
                      ),
                    ),
                ],
                              ),
                            ),
                          ],
                        ),
                ),
    );
  }
}
