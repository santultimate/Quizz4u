import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/QuestionModel.dart';

class QuestionService {
  static Map<String, List<QuestionModel>> _allQuestions = {};
  static bool _isLoaded = false;

  // Charger toutes les questions depuis les fichiers JSON séparés
  static Future<void> loadQuestions() async {
    if (_isLoaded) return;

    try {
      _allQuestions.clear();

      // Définir les catégories et leurs fichiers correspondants
      Map<String, String> categoryFiles = {
        'Histoire du Mali': 'assets/questions/mali_history_questions.json',
        'Culture générale': 'assets/questions/general_culture_questions.json',
        'Sciences': 'assets/questions/science_questions.json',
        'Mathématiques': 'assets/questions/math_questions.json',
        'Afrique': 'assets/questions/africa_questions.json',
      };

      // Charger chaque fichier de catégorie
      for (String category in categoryFiles.keys) {
        try {
          final String jsonString = await rootBundle.loadString(
            categoryFiles[category]!,
          );
          final List<dynamic> questionsList = json.decode(jsonString);

          List<QuestionModel> questions = [];

          for (var questionData in questionsList) {
            Map<String, bool> answers = {};
            questionData['answers'].forEach((key, value) {
              answers[key] = value;
            });

            questions.add(
              QuestionModel(
                question: questionData['question'],
                answers: answers,
                correctAnswer: questionData['correctAnswer'],
              ),
            );
          }

          _allQuestions[category] = questions;
        } catch (e) {
          print('Erreur lors du chargement de la catégorie $category: $e');
        }
      }

      _isLoaded = true;
    } catch (e) {
      print('Erreur lors du chargement des questions: $e');
    }
  }

  // Obtenir 10 questions aléatoires pour une catégorie
  static List<QuestionModel> getRandomQuestionsForCategory(
    String category, {
    int count = 10,
  }) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    List<QuestionModel> categoryQuestions = List.from(_allQuestions[category]!);
    categoryQuestions.shuffle(Random());

    // Mélanger les réponses de chaque question sélectionnée
    List<QuestionModel> selectedQuestions =
        categoryQuestions.take(count).toList();
    for (var question in selectedQuestions) {
      _shuffleAnswers(question);
    }

    return selectedQuestions;
  }

  // Méthode pour mélanger les réponses d'une question
  static void _shuffleAnswers(QuestionModel question) {
    Random random = Random();

    // Créer une liste des réponses avec leurs valeurs booléennes
    List<MapEntry<String, bool>> answersList =
        question.answers.entries.toList();

    // Mélanger les réponses
    answersList.shuffle(random);

    // Recréer la map avec les réponses mélangées
    Map<String, bool> shuffledAnswers = {};
    for (var entry in answersList) {
      shuffledAnswers[entry.key] = entry.value;
    }

    // Remplacer les réponses de la question
    question.answers = shuffledAnswers;
  }

  // Obtenir toutes les questions d'une catégorie
  static List<QuestionModel> getAllQuestionsForCategory(String category) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    return List.from(_allQuestions[category]!);
  }

  // Obtenir la liste des catégories disponibles
  static List<String> getAvailableCategories() {
    return _allQuestions.keys.toList();
  }

  // Vérifier si les questions sont chargées
  static bool get isLoaded => _isLoaded;

  // Obtenir le nombre total de questions par catégorie
  static int getQuestionCountForCategory(String category) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return 0;
    }
    return _allQuestions[category]!.length;
  }

  // Réinitialiser le service (pour les tests ou rechargement)
  static void reset() {
    _allQuestions.clear();
    _isLoaded = false;
  }
}
