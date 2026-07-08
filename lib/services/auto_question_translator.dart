// lib/services/auto_question_translator.dart
import '../models/question_model.dart';

/// Les questions sont traduites via les fichiers JSON par langue
/// (QuestionServiceOptimized). Ce service est conservé pour compatibilité legacy.
class AutoQuestionTranslator {
  static QuestionModel translateQuestion(QuestionModel question) => question;

  static List<QuestionModel> translateQuestions(
    List<QuestionModel> questions,
  ) =>
      questions;

  static bool hasHardcodedTranslation(String questionText, String language) =>
      false;
}
