// lib/models/QuestionModel.dart
class QuestionModel {
  String question; // Texte de la question
  Map<String, bool> answers; // Réponses sous forme de Map
  String correctAnswer; // Réponse correcte

  QuestionModel({
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });
}
