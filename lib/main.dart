import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/question_service.dart';
import 'services/settings_service.dart';
import 'models/QuestionModel.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les questions au démarrage
  await QuestionService.loadQuestions();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await SettingsService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizz4u',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _getThemeMode(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/about': (context) => const AboutScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.purple,
      primaryColor: Colors.purple,
      scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.grey[800] : Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: isDark ? Colors.grey[800] : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  ThemeMode _getThemeMode() {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

// ========== ACCUEIL ==========
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Bienvenue au Quiz",
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quizz4u',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionScreen(
                      onCategorySelected: (category) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizScreen(category: category),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "Start",
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== SÉLECTION DE CATÉGORIE ==========
class CategorySelectionScreen extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategorySelectionScreen({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: const Text(
          'Choisissez une catégorie',
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          children: [
            CategoryButton(
              title: 'Sciences',
              onTap: () => onCategorySelected('Sciences'),
            ),
            const SizedBox(height: 20),
            CategoryButton(
              title: 'Culture générale',
              onTap: () => onCategorySelected('Culture générale'),
            ),
            const SizedBox(height: 20),
            CategoryButton(
              title: 'Mathématiques',
              onTap: () => onCategorySelected('Mathématiques'),
            ),
            const SizedBox(height: 20),
            CategoryButton(
              title: 'Histoire du Mali',
              onTap: () => onCategorySelected('Histoire du Mali'),
            ),
            const SizedBox(height: 20),
            CategoryButton(
              title: 'Afrique',
              onTap: () => onCategorySelected('Afrique'),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CategoryButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.purple,
            fontFamily: 'Raleway',
          ),
        ),
      ),
    );
  }
}

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
    await QuestionService.loadQuestions();

    return QuestionService.getRandomQuestionsForCategory(category, count: 10);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz: ${widget.category}'),
          backgroundColor: Colors.purple[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Chargement des questions...',
                style: TextStyle(fontSize: 18, fontFamily: 'Raleway'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.category}'),
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
    final difficulty = await SettingsService.getDifficulty();
    final ttsEnabled = await SettingsService.isTtsEnabled();

    setState(() {
      totalTime = SettingsService.getTimerDurationForDifficulty(difficulty);
      autoSpeechEnabled = ttsEnabled;
    });

    if (ttsEnabled) {
      _speakQuestion();
    }

    startTimer();
  }

  Future<void> speakQuestion(String text) async {
    setState(() {
      isSpeaking = true;
    });

    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);

    setState(() {
      isSpeaking = false;
    });
  }

  void _speakQuestion() {
    if (widget.questions.isEmpty ||
        currentQuestionIndex >= widget.questions.length) {
      return;
    }
    final question = widget.questions[currentQuestionIndex];
    speakQuestion(question.question);
  }

  void _toggleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      // Vérifier si la lecture automatique est activée
      final ttsEnabled = await SettingsService.isTtsEnabled();
      if (ttsEnabled) {
        _speakQuestion();
      } else {
        // Si la lecture automatique est désactivée, l'activer temporairement
        await SettingsService.setTtsEnabled(true);
        _speakQuestion();
      }
    }
  }

  void _toggleAutoSpeech() async {
    final currentTtsEnabled = await SettingsService.isTtsEnabled();
    await SettingsService.setTtsEnabled(!currentTtsEnabled);

    setState(() {
      autoSpeechEnabled = !currentTtsEnabled;
    });

    if (currentTtsEnabled) {
      // Désactiver la lecture automatique
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lecture automatique désactivée'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Activer la lecture automatique
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lecture automatique activée'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _checkTtsAndSpeak() async {
    final ttsEnabled = await SettingsService.isTtsEnabled();
    if (ttsEnabled) {
      _speakQuestion();
    }
  }

  void startTimer() {
    if (isPaused) return;

    progress = 1.0;
    _timer?.cancel();
    int timeLeft = totalTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused) return;

      setState(() {
        timeLeft--;
        progress = timeLeft / totalTime;

        // Animation du timer
        if (timeLeft <= 5) {
          _pulseAnimationController.repeat(reverse: true);
        }

        if (timeLeft <= 0) {
          timer.cancel();
          _showCorrectAnswerAndContinue();
        }
      });
    });
  }

  void _showCorrectAnswerAndContinue() {
    setState(() {
      showCorrectAnswer = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      goToNextQuestion();
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      _timer?.cancel();
      _pulseAnimationController.stop();
      _showPauseDialog();
    } else {
      startTimer();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quiz en pause',
          style: TextStyle(fontFamily: 'Signatra', fontSize: 24),
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

  void checkAnswer(String answer) {
    if (selectedAnswer != null || showCorrectAnswer) return;
    if (widget.questions.isEmpty ||
        currentQuestionIndex >= widget.questions.length) {
      return;
    }

    setState(() {
      selectedAnswer = answer;
      if (answer == widget.questions[currentQuestionIndex].correctAnswer) {
        score++;
      }
    });

    _timer?.cancel();
    _pulseAnimationController.stop();

    Future.delayed(const Duration(seconds: 2), () => goToNextQuestion());
  }

  void goToNextQuestion() {
    _timer?.cancel();
    _pulseAnimationController.stop();

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showCorrectAnswer = false;
      });

      _checkTtsAndSpeak();

      startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: score,
            total: widget.questions.length,
            category: widget.category,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _pulseAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty ||
        currentQuestionIndex >= widget.questions.length) {
      return Scaffold(
        backgroundColor: Colors.purple,
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

    if (widget.questions.isEmpty ||
        currentQuestionIndex >= widget.questions.length) {
      return Scaffold(
        backgroundColor: Colors.purple,
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

    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.purple,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer animé
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
                    width: MediaQuery.of(context).size.width * progress * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: timerColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Raleway',
                  ),
                ),
                Text(
                  'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Raleway',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                  ),
                  onPressed: togglePause,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleSpeech,
                      onLongPress: _toggleAutoSpeech,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: autoSpeechEnabled
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isSpeaking ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      autoSpeechEnabled ? 'Auto ON' : 'Auto OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Raleway',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ...question.answers.entries.map((entry) {
              final isSelected = selectedAnswer == entry.key;
              final isCorrect = entry.key == question.correctAnswer;
              Color backgroundColor = Colors.white;
              Color textColor = Colors.purple;

              if (selectedAnswer != null || showCorrectAnswer) {
                if (isCorrect) {
                  backgroundColor = Colors.green;
                  textColor = Colors.white;
                } else if (isSelected && !isCorrect) {
                  backgroundColor = Colors.red;
                  textColor = Colors.white;
                }
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: TextButton(
                  onPressed: () => checkAnswer(entry.key),
                  style: TextButton.styleFrom(
                    backgroundColor: backgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: Text(
                    entry.key,
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
      ),
    );
  }
}

// ========== ÉCRAN DE RÉSULTAT ==========
class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String category;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.category,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isTop3 = false;
  int _rank = 0;
  String _playerName = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _checkLeaderboard();
    _animationController.forward();
  }

  Future<void> _checkLeaderboard() async {
    final isTop3 = await LeaderboardManager.isTop3(widget.score);
    final rank = await LeaderboardManager.getRank(widget.score);

    setState(() {
      _isTop3 = isTop3;
      _rank = rank;
    });

    if (isTop3) {
      _showNameInputDialog();
    }
  }

  void _showNameInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.purple[100],
          title: const Text(
            '🎉 Félicitations ! 🎉',
            style: TextStyle(
              fontFamily: 'Signatra',
              fontSize: 24,
              color: Colors.purple,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tu es dans le TOP 3 !\nRang: #$_rank',
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Raleway',
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Ton pseudo',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.purple),
                ),
                style: const TextStyle(color: Colors.purple),
                onChanged: (value) {
                  _playerName = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_playerName.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _saveScore();
                }
              },
              child: const Text(
                'Valider',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveScore() async {
    final scoreEntry = ScoreEntry(
      playerName: _playerName,
      score: widget.score,
      category: widget.category,
      date: DateTime.now(),
      totalQuestions: widget.total,
    );

    await LeaderboardManager.addScore(scoreEntry);

    // Mettre à jour les statistiques
    final prefs = await SharedPreferences.getInstance();
    final currentTotal = prefs.getInt('totalScore') ?? 0;
    final currentGames = prefs.getInt('gamesPlayed') ?? 0;
    final currentCategoryScore = prefs.getInt('score_${widget.category}') ?? 0;

    await prefs.setInt('totalScore', currentTotal + widget.score);
    await prefs.setInt('gamesPlayed', currentGames + 1);
    await prefs.setInt(
      'score_${widget.category}',
      currentCategoryScore + widget.score,
    );
  }

  void _shareScore() {
    final message = '''
🎯 Quizz4u - Nouveau Record ! 🎯

Score: ${widget.score}/${widget.total} (${((widget.score / widget.total) * 100).toStringAsFixed(0)}%)
Catégorie: ${widget.category}
Rang: #$_rank

Peux-tu faire mieux ? 😏
    ''';

    Share.share(message, subject: 'Mon score Quizz4u');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animation de victoire
                  if (widget.score == widget.total)
                    Lottie.asset(
                      'assets/animations/congrats.json',
                      height: 150,
                      repeat: true,
                    ),

                  const SizedBox(height: 20),

                  // Score principal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isTop3 ? Colors.amber : Colors.white,
                        width: _isTop3 ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isTop3 ? '🏆 NOUVEAU RECORD ! 🏆' : 'Quiz terminé !',
                          style: TextStyle(
                            fontSize: _isTop3 ? 24 : 28,
                            fontFamily: 'Signatra',
                            color: _isTop3 ? Colors.amber : Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Score : ${widget.score} / ${widget.total}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontFamily: 'Signatra',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${((widget.score / widget.total) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Raleway',
                            color: Colors.white70,
                          ),
                        ),
                        if (_isTop3) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Rang: #$_rank',
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Raleway',
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _shareScore,
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaderboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.leaderboard),
                        label: const Text('Classement'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Menu principal',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Rejouer',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========== ÉCRAN DE STATISTIQUES ==========
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int totalScore = 0;
  int gamesPlayed = 0;
  double averageScore = 0.0;
  Map<String, int> categoryScores = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalScore = prefs.getInt('totalScore') ?? 0;
      gamesPlayed = prefs.getInt('gamesPlayed') ?? 0;
      averageScore = gamesPlayed > 0 ? totalScore / gamesPlayed : 0.0;
      categoryScores = {
        'Sciences': prefs.getInt('score_Sciences') ?? 0,
        'Culture générale': prefs.getInt('score_Culture générale') ?? 0,
        'Mathématiques': prefs.getInt('score_Mathématiques') ?? 0,
        'Histoire du Mali': prefs.getInt('score_Histoire du Mali') ?? 0,
        'Afrique': prefs.getInt('score_Afrique') ?? 0,
        'Questions Captivantes':
            prefs.getInt('score_Questions Captivantes') ?? 0,
      };
    });
  }

  Future<void> _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: const Text(
          'Statistiques',
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildStatRow('Parties jouées', gamesPlayed.toString()),
                  const SizedBox(height: 10),
                  _buildStatRow('Score total', totalScore.toString()),
                  const SizedBox(height: 10),
                  _buildStatRow('Moyenne', averageScore.toStringAsFixed(1)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Scores par catégorie',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Signatra',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: categoryScores.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaderboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '🏆 Classement',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _resetStats,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Raleway',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ========== MODÈLE POUR LES SCORES ==========
class ScoreEntry {
  final String playerName;
  final int score;
  final String category;
  final DateTime date;
  final int totalQuestions;

  ScoreEntry({
    required this.playerName,
    required this.score,
    required this.category,
    required this.date,
    required this.totalQuestions,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'category': category,
      'date': date.toIso8601String(),
      'totalQuestions': totalQuestions,
    };
  }

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      playerName: json['playerName'],
      score: json['score'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      totalQuestions: json['totalQuestions'],
    );
  }
}

// ========== GESTIONNAIRE DU LEADERBOARD ==========
class LeaderboardManager {
  static const String _leaderboardKey = 'leaderboard_scores';

  static Future<List<ScoreEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardJson = prefs.getString(_leaderboardKey);

    if (leaderboardJson == null) return [];

    final List<dynamic> jsonList = jsonDecode(leaderboardJson);
    return jsonList.map((json) => ScoreEntry.fromJson(json)).toList();
  }

  static Future<void> addScore(ScoreEntry score) async {
    final prefs = await SharedPreferences.getInstance();
    List<ScoreEntry> leaderboard = await getLeaderboard();

    leaderboard.add(score);
    leaderboard.sort((a, b) => b.score.compareTo(a.score));

    // Garder seulement les 50 meilleurs scores
    if (leaderboard.length > 50) {
      leaderboard = leaderboard.take(50).toList();
    }

    final String leaderboardJson = jsonEncode(
      leaderboard.map((score) => score.toJson()).toList(),
    );

    await prefs.setString(_leaderboardKey, leaderboardJson);
  }

  static Future<bool> isTop3(int score) async {
    final leaderboard = await getLeaderboard();
    if (leaderboard.length < 3) return true;
    return score > leaderboard[2].score;
  }

  static Future<int> getRank(int score) async {
    final leaderboard = await getLeaderboard();
    for (int i = 0; i < leaderboard.length; i++) {
      if (score >= leaderboard[i].score) {
        return i + 1;
      }
    }
    return leaderboard.length + 1;
  }
}

// ========== ÉCRAN DU LEADERBOARD ==========
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<ScoreEntry> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      isLoading = true;
    });

    final scores = await LeaderboardManager.getLeaderboard();
    setState(() {
      leaderboard = scores;
      isLoading = false;
    });
  }

  String _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[300]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: const Text(
          '🏆 Classement',
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : leaderboard.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucun score encore !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Signatra',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Joue pour être le premier !',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final score = leaderboard[index];
                    final rank = index + 1;
                    final percentage =
                        ((score.score / score.totalQuestions) * 100)
                            .toStringAsFixed(0);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _getRankColor(rank),
                          width: rank <= 3 ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getRankColor(rank),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _getRankIcon(rank),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          score.playerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${score.category} • ${score.date.day}/${score.date.month}/${score.date.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${score.score}/${score.totalQuestions}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily: 'Raleway',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
