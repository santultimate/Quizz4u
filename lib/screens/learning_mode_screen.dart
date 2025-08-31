import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/ad_service.dart';
import '../models/question_model.dart';

class LearningModeScreen extends StatefulWidget {
  final String category;

  const LearningModeScreen({Key? key, required this.category})
      : super(key: key);

  @override
  State<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends State<LearningModeScreen> {
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  bool showExplanation = false;
  String? selectedAnswer;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    // Afficher une publicité interstitielle au début du mode apprentissage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AdService.showCategoryChangeInterstitial();
      } catch (e) {
        print('[LearningMode] ❌ Erreur publicité: $e');
      }
    });
  }

  Future<void> _loadQuestions() async {
    await QuestionService.loadQuestions();
    questions = QuestionService.getSmartQuestionsForCategory(widget.category,
        count: 20);
    setState(() {});
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == questions[currentQuestionIndex].correctAnswer;
      showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showExplanation = false;
        isCorrect = false;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedAnswer = null;
        showExplanation = false;
        isCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mode Apprentissage - ${widget.category}'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    QuestionModel currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mode Apprentissage - ${widget.category}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Text(
            '${currentQuestionIndex + 1}/${questions.length}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progression
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),

            // Question
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentQuestion.difficulty != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getDifficultyColor(currentQuestion.difficulty!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentQuestion.difficulty!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.answers.length,
                itemBuilder: (context, index) {
                  String answer = currentQuestion.answers.keys.elementAt(index);
                  bool isSelected = selectedAnswer == answer;
                  bool isCorrectAnswer =
                      answer == currentQuestion.correctAnswer;

                  Color backgroundColor = Colors.white;
                  Color borderColor = Colors.grey[300]!;

                  if (showExplanation) {
                    if (isCorrectAnswer) {
                      backgroundColor = Colors.green[50]!;
                      borderColor = Colors.green;
                    } else if (isSelected && !isCorrectAnswer) {
                      backgroundColor = Colors.red[50]!;
                      borderColor = Colors.red;
                    }
                  } else if (isSelected) {
                    backgroundColor = Colors.blue[50]!;
                    borderColor = Colors.blue;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: borderColor, width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        answer,
                        style: TextStyle(
                          fontWeight: isSelected || isCorrectAnswer
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: showExplanation && isCorrectAnswer
                          ? const Icon(Icons.check_circle,
                              color: Colors.green, size: 24)
                          : showExplanation && isSelected && !isCorrectAnswer
                              ? const Icon(Icons.cancel,
                                  color: Colors.red, size: 24)
                              : null,
                      onTap:
                          showExplanation ? null : () => _selectAnswer(answer),
                    ),
                  );
                },
              ),
            ),

            // Explication
            if (showExplanation && currentQuestion.explanation != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.info,
                            color: isCorrect ? Colors.green : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? 'Correct !' : 'Explication',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion.explanation!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Navigation
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      currentQuestionIndex > 0 ? _previousQuestion : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Précédent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? _nextQuestion
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Suivant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'facile':
        return Colors.green;
      case 'medium':
      case 'moyen':
        return Colors.orange;
      case 'hard':
      case 'difficile':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
