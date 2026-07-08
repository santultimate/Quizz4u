// lib/models/question_model.dart
class QuestionModel {
  final String id;
  String question;
  Map<String, bool> answers;
  String correctAnswer;
  String? explanation;
  String? difficulty;
  String? subcategory;

  QuestionModel({
    String? id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    this.explanation,
    this.difficulty,
    this.subcategory,
  }) : id = id ?? _fallbackId(question);

  /// Id dérivé si absent du JSON (legacy).
  static String _fallbackId(String question) =>
      'legacy_${question.hashCode.abs()}';
}
