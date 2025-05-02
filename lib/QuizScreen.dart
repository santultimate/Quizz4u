import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'Questions_examples.dart'; // Importer les questions définies
import 'models/QuestionModel.dart'; // Importer le modèle Question
import 'dart:async'; // Nécessaire pour le Timer

class QuizScreen extends StatelessWidget {
  final String category;

  QuizScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    // Filtrer les questions selon la catégorie
    List<QuestionModel> questions = getQuestionsForCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: $category'),
        backgroundColor: Colors.green[700],
      ),
      body: QuizPage(questions: questions),
    );
  }

  List<QuestionModel> getQuestionsForCategory(String category) {
    switch (category) {
      case 'Sciences':
        return scienceQuestions;
      case 'Culture générale':
        return cultureGeneralQuestions;
      case 'Mathématiques':
        return mathQuestions;
      default:
        return [];
    }
  }
}

class QuizPage extends StatefulWidget {
  final List<QuestionModel> questions;

  QuizPage({required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  int timer = 30; // Durée du timer en secondes
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.timer == 0) {
        _nextQuestion();
      } else {
        setState(() {
          this.timer--;
        });
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        timer = 30;
      });
      _timer.cancel();
      _startTimer();
    } else {
      _timer.cancel();
      _showResult();
    }
  }

  void checkAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        score++;
      }
      _nextQuestion();
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Fin du quiz'),
        content: Text('Votre score est $score/${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation sablier
            SizedBox(
              height: 100,
              child: Lottie.asset(
                'assets/animations/hourglass.json',
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 20),

            // Timer texte
            Text(
              'Temps restant: $timer secondes',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 30),

            // Question
            Text(
              question.question,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontFamily: 'Raleway',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Réponses
            ...question.answers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(entry.value),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green[700],
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
