import 'dart:async';
import 'package:flutter/material.dart';
import 'Questions_examples.dart';
import 'package:question_pour_toi/models/QuestionModel.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizz4u',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

// ========== ACCUEIL ==========
class HomeScreen extends StatelessWidget {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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

  CategorySelectionScreen({required this.onCategorySelected});

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
        padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
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
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CategoryButton({required this.title, required this.onTap});

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
class QuizScreen extends StatelessWidget {
  final String category;

  QuizScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    List<QuestionModel> questions = getQuestionsForCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: $category'),
        backgroundColor: Colors.purple[700],
      ),
      body: QuizPage(questions: questions),
    );
  }

  List<QuestionModel> getQuestionsForCategory(String category) {
    List<QuestionModel> questions;

    switch (category) {
      case 'Sciences':
        questions = List.from(scienceQuestions);
        break;
      case 'Culture générale':
        questions = List.from(cultureGeneralQuestions);
        break;
      case 'Mathématiques':
        questions = List.from(mathQuestions);
        break;
      default:
        questions = [];
    }

    questions.shuffle();
    return questions.take(10).toList();
  }
}

// ========== PAGE DU QUIZ ==========
class QuizPage extends StatefulWidget {
  final List<QuestionModel> questions;

  QuizPage({required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  Timer? _timer;
  double progress = 1.0;
  final int totalTime = 7;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    progress = 1.0;
    _timer?.cancel();
    int timeLeft = totalTime;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        progress = timeLeft / totalTime;
        if (timeLeft <= 0) {
          timer.cancel();
          goToNextQuestion();
        }
      });
    });
  }

  void checkAnswer(String answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;
      if (answer ==
          widget.questions[currentQuestionIndex].correctAnswer) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () => goToNextQuestion());
  }

  void goToNextQuestion() {
    _timer?.cancel();
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        startTimer();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: score, total: widget.questions.length),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.purple,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 30),
            Text(
              question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 30),
            ...question.answers.entries.map(
              (entry) {
                final isSelected = selectedAnswer == entry.key;
                final isCorrect =
                    entry.key == question.correctAnswer;
                Color backgroundColor = Colors.white;
                if (selectedAnswer != null) {
                  if (isCorrect) {
                    backgroundColor = Colors.green;
                  } else if (isSelected) {
                    backgroundColor = Colors.red;
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
                          vertical: 12, horizontal: 16),
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.purple,
                        fontFamily: 'Raleway',
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ========== ÉCRAN DE RÉSULTAT ==========
class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz terminé !\nScore : $score / $total',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontFamily: 'Signatra',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: const Text('Menu principal'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Rejouer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}