import 'dart:convert';

import 'cached_preferences_service.dart';
import '../models/question_model.dart';
import 'question_service_optimized.dart';

/// Stocke les questions ratées pour le mode révision.
class ReviewService {
  static const String _key = 'review_wrong_questions';
  static const int _maxItems = 100;

  /// Entrées: {id, category, questionPreview, wrongAt}
  static Future<List<Map<String, dynamic>>> getWrongEntries() async {
    final raw = await CachedPreferencesService.getString(_key, defaultValue: '');
    if (raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<int> getWrongCount() async => (await getWrongEntries()).length;

  static Future<void> recordWrong({
    required String questionId,
    required String category,
    required String questionPreview,
  }) async {
    if (questionId.isEmpty) return;
    final entries = await getWrongEntries();
    entries.removeWhere((e) => e['id'] == questionId && e['category'] == category);
    entries.insert(0, {
      'id': questionId,
      'category': category,
      'questionPreview': questionPreview.length > 80
          ? '${questionPreview.substring(0, 80)}…'
          : questionPreview,
      'wrongAt': DateTime.now().toIso8601String(),
    });
    while (entries.length > _maxItems) {
      entries.removeLast();
    }
    await CachedPreferencesService.setString(_key, json.encode(entries));
  }

  static Future<void> removeResolved(String questionId, String category) async {
    final entries = await getWrongEntries();
    entries.removeWhere((e) => e['id'] == questionId && e['category'] == category);
    await CachedPreferencesService.setString(_key, json.encode(entries));
  }

  static Future<void> clearAll() async {
    await CachedPreferencesService.setString(_key, '[]');
  }

  /// Charge jusqu'à [count] questions depuis la banque à partir des IDs ratés.
  static Future<List<QuestionModel>> loadReviewQuestions({int count = 10}) async {
    await QuestionServiceOptimized.waitForAllCategories(
      timeout: const Duration(seconds: 10),
    );
    final entries = await getWrongEntries();
    if (entries.isEmpty) return [];

    final questions = <QuestionModel>[];
    final seen = <String>{};

    for (final entry in entries) {
      if (questions.length >= count) break;
      final id = entry['id']?.toString() ?? '';
      final category = entry['category']?.toString() ?? '';
      if (id.isEmpty || category.isEmpty) continue;
      final key = '$category::$id';
      if (seen.contains(key)) continue;
      seen.add(key);

      await QuestionServiceOptimized.ensureCategoryReady(category);
      final q = QuestionServiceOptimized.findQuestionById(category, id);
      if (q != null) {
        questions.add(q);
      }
    }
    return questions;
  }
}
