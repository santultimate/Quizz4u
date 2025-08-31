import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'services/question_service.dart'; // Importer le service de questions
import 'models/question_model.dart'; // Importer le modèle Question
import 'dart:async'; // Nécessaire pour le Timer
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'services/unified_audio_service.dart';
import 'services/settings_service.dart';
import 'services/ad_service.dart'; // Importer le service d'annonce
import 'services/progress_service.dart'; // Importer le service de progression
// Importer le service de test publicitaire
import 'package:shared_preferences/shared_preferences.dart';

class QuizScreen extends StatelessWidget {
  final String category;

  const QuizScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: $category'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Comment jouer'),
                  content: const Text(
                    '• Répondez aux questions dans le temps imparti\n'
                    '• Plus vous répondez vite, plus vous gagnez de points\n'
                    '• Utilisez le bouton pause pour faire une pause\n'
                    '• Les questions viennent de différentes catégories',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: QuizPage(category: category),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String category;

  const QuizPage({super.key, required this.category});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int correctAnswers = 0; // Ajouter le compteur de bonnes réponses
  int timer = 30;
  int totalQuestions = 10;
  bool isPaused = false;
  bool isGameOver = false;
  bool isLoading = true;
  bool ttsActive = false;
  late FlutterTts flutterTts;
  bool _backgroundMusicEnabled = true;
  bool _soundEnabled = true;
  bool _ttsEnabled = false;

  late Timer _timer;
  late Timer _audioSettingsTimer;
  late AnimationController _timerController;
  late AnimationController _questionController;
  late Animation<double> _timerAnimation;
  late Animation<double> _questionAnimation;

  List<QuestionModel> allQuestions = [];
  List<QuestionModel> currentQuestions = [];
  Random random = Random();
  int questionsSinceLastAd = 0;

  @override
  void initState() {
    super.initState();
    print('[QuizScreen] initState - initialisation');
    flutterTts = FlutterTts();
    _initializeAnimations();
    _initializeQuestions();
    _initializeAudio();
    AdService
        .loadInterstitialAd(); // Charger la pub interstitielle au démarrage
  }

  Future<void> _initializeQuestions() async {
    await QuestionService.loadQuestions();
    await ProgressService
        .loadProgress(); // Initialiser le service de progression

    // Initialiser TTS en français
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    _loadAllQuestions();
    _generateRandomQuestions();

    // Charger les paramètres audio avant de lancer la musique
    await _loadAudioSettings();

    setState(() {
      isLoading = false;
    });

    // Debug: Afficher l'état des paramètres audio
    print('[QuizScreen] DEBUG - État final des paramètres audio:');
    print(
        '[QuizScreen] DEBUG - _backgroundMusicEnabled = $_backgroundMusicEnabled');
    print('[QuizScreen] DEBUG - _soundEnabled = $_soundEnabled');
    print('[QuizScreen] DEBUG - _ttsEnabled = $_ttsEnabled');

    // Lancer la musique de fond au début du quiz
    await _startBackgroundMusic();
    _startTimer();
    _startAudioSettingsCheck();
  }

  void _initializeAnimations() {
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.easeInOut),
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOutBack),
    );
  }

  void _loadAllQuestions() {
    // Charger toutes les questions de la catégorie choisie uniquement
    allQuestions = QuestionService.getAllQuestionsForCategory(widget.category);
  }

  void _generateRandomQuestions() {
    currentQuestions.clear();

    // Sélectionner 10 questions aléatoires de la catégorie choisie uniquement
    currentQuestions = QuestionService.getSmartQuestionsForCategory(
      widget.category,
      count: totalQuestions,
    );
  }

  void _startTimer() {
    _timerController.forward();
    _questionController.forward();

    // Lancer la TTS pour la première question si activée
    if (_ttsEnabled && currentQuestions.isNotEmpty) {
      _speakQuestion();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && !isGameOver) {
        if (this.timer == 0) {
          _nextQuestion();
        } else {
          setState(() {
            this.timer--;
            _timerController.value = 1.0 - (this.timer / 30.0);
          });
        }
      }
    });
  }

  void _pauseGame() {
    setState(() {
      isPaused = true;
    });
    _timerController.stop();
    flutterTts.stop();
    setState(() {
      ttsActive = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Jeu en pause'),
        content: const Text('Voulez-vous continuer le jeu ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeGame();
            },
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('Recommencer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  void _resumeGame() {
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
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      correctAnswers = 0; // Réinitialiser le compteur de bonnes réponses
      timer = 30;
      isPaused = false;
      isGameOver = false;
      isLoading = true;
    });
    _timerController.reset();
    _questionController.reset();
    _generateRandomQuestions();

    setState(() {
      isLoading = false;
    });

    // Relancer la musique de fond lors du redémarrage
    await _startBackgroundMusic();
    _startTimer();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < currentQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        timer = 30;
      });
      _timerController.reset();
      _questionController.reset();
      _timerController.forward();
      _questionController.forward();

      // Lancer la TTS pour la nouvelle question si activée
      if (_ttsEnabled && currentQuestions.isNotEmpty) {
        _speakQuestion();
      }
    } else {
      _endGame();
    }
  }

  void checkAnswer(bool isCorrect) async {
    print(
        '[QuizScreen] DEBUG - checkAnswer appelée avec isCorrect: $isCorrect');
    print('[QuizScreen] DEBUG - _soundEnabled = $_soundEnabled');

    if (isPaused || isGameOver) return;

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
    } catch (e) {
      print('[QuizScreen] ❌ Erreur enregistrement progression: $e');
    }

    // Jouer les sons de réponse
    if (_soundEnabled) {
      try {
        if (isCorrect) {
          print('[QuizScreen] 🎵 Bonne réponse - jouer son good.mp3');
          await UnifiedAudioService.instance.playGoodSound();
        } else {
          print('[QuizScreen] 🎵 Mauvaise réponse - jouer son bad.mp3');
          await UnifiedAudioService.instance.playBadSound();
        }
      } catch (e) {
        print('[QuizScreen] ❌ Erreur lors de la lecture du son: $e');
      }
    } else {
      print('[QuizScreen] 🔇 Sons désactivés dans les paramètres');
    }

    questionsSinceLastAd++;
    if (questionsSinceLastAd >= 3) {
      // Réduire à 3 questions pour plus de fréquence
      print(
          '[QuizScreen] 📺 Affichage publicité interstitielle après $questionsSinceLastAd questions');
      try {
        // Utiliser les vraies publicités AdMob
        await AdService.showInterstitialAd();
        questionsSinceLastAd = 0;

        // Relancer la musique de fond après la pub
        if (_backgroundMusicEnabled) {
          print(
              '[QuizScreen] 🎵 Relance de la musique de fond après publicité');
          await _startBackgroundMusic();
        }
      } catch (e) {
        print('[QuizScreen] ❌ Erreur lors de l\'affichage de la publicité: $e');
        // Continuer le jeu même si la pub échoue
      }
    }
    _nextQuestion();
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

    // Sauvegarder le score
    print('[QuizScreen] 🎯 Appel de _saveScore()...');
    await _saveScore();
    print('[QuizScreen] ✅ _saveScore() terminé');

    // Afficher une publicité interstitielle à la fin du quiz
    try {
      await AdService.showEndGameInterstitial();
    } catch (e) {
      print('[QuizScreen] ❌ Erreur publicité fin de quiz: $e');
    }

    _showResult();
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
            content:
                Text('🎯 Score sauvegardé ! +$totalXP XP + $totalBonus bonus'),
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

    if (isGoodScore) {
      // Afficher le dialogue de sauvegarde pour les bons scores
      _showSaveScoreDialog();
    } else {
      // Afficher un dialogue simple pour les scores faibles
      _showSimpleResultDialog();
    }
  }

  void _showSaveScoreDialog() {
    String playerName = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Félicitations !'),
        content: Column(
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
                  await AdService.showRewardedAdForXPBonus(
                    onRewarded: (int bonusXP) async {
                      // Ajouter le bonus XP
                      await ProgressService.addExperience(bonusXP,
                          reason: 'Bonus Publicité');

                      // Afficher un message de confirmation
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎁 +$bonusXP XP bonus obtenu !'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                } catch (e) {
                  print('[QuizScreen] ❌ Erreur publicité récompensée: $e');
                }
              },
              icon: const Icon(Icons.play_circle),
              label: const Text('Regarder une pub pour +20-50 XP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Redémarrer le quiz en rechargeant la page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => QuizScreen(category: widget.category),
                ),
              );
            },
            child: const Text('Recommencer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Retourner au menu sans sauvegarder
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('Ne pas sauvegarder'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (playerName.isNotEmpty) {
                // Sauvegarder le nom du joueur
                await _savePlayerName(playerName);
                print('[QuizScreen] ✅ Nom du joueur sauvegardé: $playerName');

                // Afficher un message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Score sauvegardé pour $playerName !'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                // Afficher un message d'erreur si le nom est vide
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Veuillez entrer votre nom pour sauvegarder !'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
                return; // Ne pas fermer le dialogue
              }

              Navigator.pop(context);
              // Retourner à la page d'accueil principale
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sauvegarder & Menu'),
          ),
        ],
      ),
    );
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
      await UnifiedAudioService.instance.initialize();

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
      await UnifiedAudioService.instance.setEffectsVolume(0.7);
      print('[QuizScreen] 🔊 Volume des effets réglé à 0.7');
    }

    if (_backgroundMusicEnabled) {
      await UnifiedAudioService.instance.setBackgroundVolume(0.2);
      print('[QuizScreen] 🎵 Volume de la musique réglé à 0.2');
    }
  }

  // Méthode pour démarrer la musique de fond
  Future<void> _startBackgroundMusic() async {
    print(
        '[QuizScreen] _startBackgroundMusic - Vérification: _backgroundMusicEnabled = $_backgroundMusicEnabled');

    if (_backgroundMusicEnabled) {
      print('[QuizScreen] _startBackgroundMusic - lancement musique de fond');
      await UnifiedAudioService.instance.playBackgroundMusic();
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
    if (!UnifiedAudioService.instance.isAdPlaying) {
      if (!currentBackgroundMusicEnabled && _backgroundMusicEnabled) {
        print(
            '[QuizScreen] _checkAndApplyAudioSettings - Arrêt musique de fond (désactivée)');
        await UnifiedAudioService.instance.setBackgroundMusicEnabled(false);
        _backgroundMusicEnabled = false;
      } else if (currentBackgroundMusicEnabled && !_backgroundMusicEnabled) {
        print(
            '[QuizScreen] _checkAndApplyAudioSettings - Lancement musique de fond (activée)');
        _backgroundMusicEnabled = true;
        await UnifiedAudioService.instance.playBackgroundMusic();
      }
    }

    print(
        '[QuizScreen] _checkAndApplyAudioSettings - État: Musique=$_backgroundMusicEnabled, Sons=$_soundEnabled, Pub=${UnifiedAudioService.instance.isAdPlaying}');
  }

  // Méthode pour arrêter la musique de fond
  Future<void> _stopBackgroundMusic() async {
    print('[QuizScreen] _stopBackgroundMusic - arrêt musique de fond');
    await UnifiedAudioService.instance.setBackgroundMusicEnabled(false);
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

  @override
  void dispose() {
    _timer.cancel();
    _audioSettingsTimer.cancel();
    _timerController.dispose();
    _questionController.dispose();
    _stopBackgroundMusic();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleTts(String text) async {
    if (ttsActive) {
      await flutterTts.stop();
      setState(() {
        ttsActive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lecture désactivée'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1)),
      );
    } else {
      await flutterTts.setLanguage('fr-FR');
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(text);
      setState(() {
        ttsActive = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lecture activée'),
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
        await flutterTts.setLanguage("fr-FR");
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setVolume(1.0);
        await flutterTts.setPitch(1.0);
        await flutterTts.speak(currentQuestions[currentQuestionIndex].question);
        print(
            '[QuizScreen] _speakQuestion - TTS activé pour la question: ${currentQuestions[currentQuestionIndex].question}');
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
      flutterTts.stop();
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
            child: const Text('Reprendre'),
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
        backgroundColor: Colors.green[700],
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // En-tête avec timer et bouton pause
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progression
                  Text(
                    'Question ${currentQuestionIndex + 1}/$totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Raleway',
                    ),
                  ),

                  // Bouton pause
                  IconButton(
                    onPressed: _pauseGame,
                    icon: const Icon(
                      Icons.pause_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Timer animé amélioré
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _timerAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _timerAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              timer > 20
                                  ? Colors.green
                                  : timer > 10
                                      ? Colors.orange
                                      : Colors.red,
                              timer > 20
                                  ? Colors.lightGreen
                                  : timer > 10
                                      ? Colors.deepOrange
                                      : Colors.redAccent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: (timer > 20
                                      ? Colors.green
                                      : timer > 10
                                          ? Colors.orange
                                          : Colors.red)
                                  .withValues(alpha: 0.3),
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

              const SizedBox(height: 10),

              // Affichage du temps restant
              Text(
                '$timer s',
                style: TextStyle(
                  fontSize: 14,
                  color: timer > 20
                      ? Colors.green
                      : timer > 10
                          ? Colors.orange
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Question avec animation
              Expanded(
                child: AnimatedBuilder(
                  animation: _questionAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _questionAnimation.value)),
                      child: Opacity(
                        opacity: _questionAnimation.value,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                question.question,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              // Bouton TTS pour la question
                              if (_ttsEnabled)
                                IconButton(
                                  onPressed: () =>
                                      _toggleTts(question.question),
                                  icon: Icon(
                                    ttsActive
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Réponses avec animation
              ...question.answers.entries.map((entry) {
                final optionText = entry.key;
                final isCorrect = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: AnimatedBuilder(
                    animation: _questionAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _questionAnimation.value)),
                        child: Opacity(
                          opacity: _questionAnimation.value,
                          child: GestureDetector(
                            onTap: () => checkAnswer(isCorrect),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                optionText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Raleway',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

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
    );
  }

  void _showSimpleResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Terminé'),
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
            child: const Text('Recommencer'),
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
            child: const Text('Menu Principal'),
          ),
        ],
      ),
    );
  }
}
