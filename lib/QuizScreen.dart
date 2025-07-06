import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'services/question_service.dart'; // Importer le service de questions
import 'models/QuestionModel.dart'; // Importer le modèle Question
import 'dart:async'; // Nécessaire pour le Timer
import 'dart:math';

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
                builder:
                    (context) => AlertDialog(
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
  int timer = 30;
  int totalQuestions = 10;
  bool isPaused = false;
  bool isGameOver = false;
  bool isLoading = true;

  late Timer _timer;
  late AnimationController _timerController;
  late AnimationController _questionController;
  late Animation<double> _timerAnimation;
  late Animation<double> _questionAnimation;

  List<QuestionModel> allQuestions = [];
  List<QuestionModel> currentQuestions = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeQuestions();
  }

  Future<void> _initializeQuestions() async {
    await QuestionService.loadQuestions();
    _loadAllQuestions();
    _generateRandomQuestions();

    setState(() {
      isLoading = false;
    });

    _startTimer();
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
    currentQuestions = QuestionService.getRandomQuestionsForCategory(
      widget.category,
      count: totalQuestions,
    );
  }

  void _startTimer() {
    _timerController.forward();
    _questionController.forward();

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
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
  }

  void _restartGame() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
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
    } else {
      _endGame();
    }
  }

  void checkAnswer(bool isCorrect) {
    if (isPaused || isGameOver) return;

    // Calculer les points bonus basés sur le temps restant
    int timeBonus = (timer / 3).round();
    int pointsEarned = isCorrect ? 10 + timeBonus : 0;

    setState(() {
      if (isCorrect) {
        score += pointsEarned;
      }
    });

    _nextQuestion();
  }

  void _endGame() {
    setState(() {
      isGameOver = true;
    });
    _timer.cancel();
    _timerController.stop();

    // Sauvegarder le score
    _saveScore();

    _showResult();
  }

  void _saveScore() {
    // Ici vous pouvez ajouter la logique pour sauvegarder le score
    // Par exemple, utiliser SharedPreferences ou une base de données
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Fin du quiz !'),
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
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Questions répondues: ${currentQuestionIndex + 1}/$totalQuestions',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
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
                child: const Text('Retour au menu'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading ||
        currentQuestions.isEmpty ||
        currentQuestionIndex >= currentQuestions.length) {
      return Scaffold(
        backgroundColor: Colors.green[700],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
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
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // Timer texte amélioré
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (timer > 20
                          ? Colors.green
                          : timer > 10
                          ? Colors.orange
                          : Colors.red)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (timer > 20
                            ? Colors.green
                            : timer > 10
                            ? Colors.orange
                            : Colors.red)
                        .withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Text(
                  '$timer secondes',
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        timer > 20
                            ? Colors.green
                            : timer > 10
                            ? Colors.orange
                            : Colors.red,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score: $score points',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Animation sablier
              SizedBox(
                height: 80,
                child: Lottie.asset(
                  'assets/animations/hourglass.json',
                  repeat: true,
                  animate: !isPaused,
                ),
              ),

              const SizedBox(height: 30),

              // Question avec animation
              Expanded(
                child: AnimatedBuilder(
                  animation: _questionAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _questionAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Réponses
              ...question.answers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: AnimatedBuilder(
                    animation: _questionAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _questionAnimation.value)),
                        child: Opacity(
                          opacity: _questionAnimation.value,
                          child: ElevatedButton(
                            onPressed:
                                isPaused
                                    ? null
                                    : () => checkAnswer(entry.value),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green[700],
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
