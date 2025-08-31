// lib/models/question_model.dart
class QuestionModel {
  String question; // Texte de la question
  Map<String, bool> answers; // Réponses sous forme de Map
  String correctAnswer; // Réponse correcte
  String? explanation; // Explication de la réponse (optionnel)
  String? difficulty; // Niveau de difficulté (easy, medium, hard)
  String? subcategory; // Sous-catégorie de la question

  QuestionModel({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    this.explanation,
    this.difficulty,
    this.subcategory,
  });
}
