import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';

class CommunityQuestionService {
  static const String _communityQuestionsKey = 'community_questions';
  static const String _userContributionsKey = 'user_contributions';

  // Questions communautaires stockées localement (simulation)
  static final List<Map<String, dynamic>> _communityQuestions = [];

  // Questions proposées par les utilisateurs
  static final List<Map<String, dynamic>> _userProposedQuestions = [];

  // Initialiser le service
  static Future<void> initialize() async {
    await _loadCommunityQuestions();
    await _loadUserContributions();
    print('[CommunityQuestionService] ✅ Service initialisé');
  }

  // Charger les questions communautaires
  static Future<void> _loadCommunityQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questionsStr = prefs.getString(_communityQuestionsKey);

      if (questionsStr != null) {
        final questions = json.decode(questionsStr) as List<dynamic>;
        _communityQuestions.addAll(questions.cast<Map<String, dynamic>>());
      } else {
        // Questions communautaires par défaut
        _communityQuestions.addAll(_getDefaultCommunityQuestions());
        await _saveCommunityQuestions();
      }

      print(
          '[CommunityQuestionService] 📚 ${_communityQuestions.length} questions communautaires chargées');
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur chargement: $e');
    }
  }

  // Charger les contributions utilisateur
  static Future<void> _loadUserContributions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contributionsStr = prefs.getString(_userContributionsKey);

      if (contributionsStr != null) {
        final contributions = json.decode(contributionsStr) as List<dynamic>;
        _userProposedQuestions
            .addAll(contributions.cast<Map<String, dynamic>>());
      }

      print(
          '[CommunityQuestionService] 👥 ${_userProposedQuestions.length} contributions utilisateur');
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur chargement contributions: $e');
    }
  }

  // Obtenir des questions communautaires pour une catégorie
  static List<QuestionModel> getCommunityQuestions(String category,
      {int count = 5}) {
    List<QuestionModel> questions = [];

    // Filtrer par catégorie et mélanger
    final categoryQuestions = _communityQuestions
        .where((q) => q['category'] == category)
        .toList()
      ..shuffle();

    // Prendre les questions avec les meilleures notes
    categoryQuestions
        .sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));

    final selectedQuestions = categoryQuestions.take(count).toList();

    for (final questionData in selectedQuestions) {
      questions.add(QuestionModel(
        question: questionData['question'],
        answers: Map<String, bool>.from(questionData['answers']),
        correctAnswer: questionData['correctAnswer'],
      ));
    }

    print(
        '[CommunityQuestionService] 🎯 ${questions.length} questions communautaires pour $category');
    return questions;
  }

  // Proposer une nouvelle question
  static Future<bool> proposeQuestion({
    required String question,
    required Map<String, bool> answers,
    required String correctAnswer,
    required String category,
    String? explanation,
    String? difficulty,
  }) async {
    try {
      final questionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'question': question,
        'answers': answers,
        'correctAnswer': correctAnswer,
        'category': category,
        'explanation': explanation ?? '',
        'difficulty': difficulty ?? 'medium',
        'rating': 3.0, // Note initiale
        'votes': 1,
        'status': 'pending', // pending, approved, rejected
        'proposedBy': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'proposedDate': DateTime.now().toIso8601String(),
        'type': 'community',
      };

      _userProposedQuestions.add(questionData);
      await _saveUserContributions();

      print('[CommunityQuestionService] ✅ Question proposée: $question');
      return true;
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur proposition: $e');
      return false;
    }
  }

  // Noter une question
  static Future<void> rateQuestion(String questionId, double rating) async {
    try {
      // Trouver la question dans les questions communautaires
      final questionIndex =
          _communityQuestions.indexWhere((q) => q['id'] == questionId);

      if (questionIndex != -1) {
        final question = _communityQuestions[questionIndex];
        final currentRating = question['rating'] ?? 0.0;
        final currentVotes = question['votes'] ?? 0;

        // Calculer la nouvelle note moyenne
        final newVotes = currentVotes + 1;
        final newRating = ((currentRating * currentVotes) + rating) / newVotes;

        question['rating'] = newRating;
        question['votes'] = newVotes;

        await _saveCommunityQuestions();

        print('[CommunityQuestionService] ⭐ Question notée: $rating/5');
      }
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur notation: $e');
    }
  }

  // Obtenir les questions les plus populaires
  static List<QuestionModel> getPopularQuestions(String category,
      {int count = 5}) {
    List<QuestionModel> questions = [];

    final popularQuestions = _communityQuestions
        .where((q) => q['category'] == category && (q['votes'] ?? 0) >= 5)
        .toList()
      ..sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));

    final selectedQuestions = popularQuestions.take(count).toList();

    for (final questionData in selectedQuestions) {
      questions.add(QuestionModel(
        question: questionData['question'],
        answers: Map<String, bool>.from(questionData['answers']),
        correctAnswer: questionData['correctAnswer'],
      ));
    }

    return questions;
  }

  // Obtenir les questions récentes
  static List<QuestionModel> getRecentQuestions(String category,
      {int count = 5}) {
    List<QuestionModel> questions = [];

    final recentQuestions = _communityQuestions
        .where((q) => q['category'] == category)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(b['proposedDate'] ?? DateTime.now().toIso8601String())
              .compareTo(DateTime.parse(
                  a['proposedDate'] ?? DateTime.now().toIso8601String())));

    final selectedQuestions = recentQuestions.take(count).toList();

    for (final questionData in selectedQuestions) {
      questions.add(QuestionModel(
        question: questionData['question'],
        answers: Map<String, bool>.from(questionData['answers']),
        correctAnswer: questionData['correctAnswer'],
      ));
    }

    return questions;
  }

  // Obtenir des statistiques communautaires
  static Map<String, dynamic> getCommunityStats() {
    final totalQuestions = _communityQuestions.length;
    final pendingQuestions =
        _userProposedQuestions.where((q) => q['status'] == 'pending').length;
    final averageRating = totalQuestions > 0
        ? _communityQuestions
                .map((q) => q['rating'] ?? 0.0)
                .reduce((a, b) => a + b) /
            totalQuestions
        : 0.0;

    final categoryStats = <String, int>{};
    for (final question in _communityQuestions) {
      final category = question['category'] ?? 'Autre';
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }

    return {
      'totalQuestions': totalQuestions,
      'pendingQuestions': pendingQuestions,
      'averageRating': averageRating,
      'categoryStats': categoryStats,
      'userContributions': _userProposedQuestions.length,
    };
  }

  // Questions communautaires par défaut
  static List<Map<String, dynamic>> _getDefaultCommunityQuestions() {
    return [
      {
        'id': 'comm_1',
        'question': 'Quel est le plat national du Mali ?',
        'answers': {'Tô': true, 'Riz': false, 'Pasta': false, 'Pizza': false},
        'correctAnswer': 'Tô',
        'category': 'Culture générale',
        'explanation':
            'Le tô est un plat traditionnel malien fait de farine de mil.',
        'difficulty': 'easy',
        'rating': 4.2,
        'votes': 15,
        'status': 'approved',
        'proposedBy': 'community',
        'proposedDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'type': 'community',
      },
      {
        'id': 'comm_2',
        'question': 'Combien de régions administratives compte le Mali ?',
        'answers': {'10': true, '8': false, '12': false, '14': false},
        'correctAnswer': '10',
        'category': 'Afrique',
        'explanation': 'Le Mali est divisé en 10 régions administratives.',
        'difficulty': 'medium',
        'rating': 3.8,
        'votes': 12,
        'status': 'approved',
        'proposedBy': 'community',
        'proposedDate':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'type': 'community',
      },
      {
        'id': 'comm_3',
        'question': 'Quelle est la formule de l\'aire d\'un cercle ?',
        'answers': {
          'π × r²': true,
          '2 × π × r': false,
          'π × d': false,
          'r²': false
        },
        'correctAnswer': 'π × r²',
        'category': 'Mathématiques',
        'explanation':
            'L\'aire d\'un cercle se calcule avec π multiplié par le rayon au carré.',
        'difficulty': 'medium',
        'rating': 4.5,
        'votes': 20,
        'status': 'approved',
        'proposedBy': 'community',
        'proposedDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'type': 'community',
      },
      {
        'id': 'comm_4',
        'question': 'Quel est le symbole chimique de l\'or ?',
        'answers': {'Au': true, 'Ag': false, 'Fe': false, 'Cu': false},
        'correctAnswer': 'Au',
        'category': 'Sciences',
        'explanation': 'Au vient du latin "aurum" qui signifie or.',
        'difficulty': 'easy',
        'rating': 4.0,
        'votes': 18,
        'status': 'approved',
        'proposedBy': 'community',
        'proposedDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'type': 'community',
      },
      {
        'id': 'comm_5',
        'question': 'Qui a fondé l\'Empire du Mali ?',
        'answers': {
          'Soundiata Keïta': true,
          'Mansa Moussa': false,
          'Askia Mohamed': false,
          'Sonni Ali': false
        },
        'correctAnswer': 'Soundiata Keïta',
        'category': 'Histoire du Mali',
        'explanation':
            'Soundiata Keïta a fondé l\'Empire du Mali au XIIIe siècle.',
        'difficulty': 'hard',
        'rating': 4.3,
        'votes': 14,
        'status': 'approved',
        'proposedBy': 'community',
        'proposedDate': DateTime.now()
            .subtract(const Duration(hours: 12))
            .toIso8601String(),
        'type': 'community',
      },
    ];
  }

  // Sauvegarder les questions communautaires
  static Future<void> _saveCommunityQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _communityQuestionsKey, json.encode(_communityQuestions));
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur sauvegarde: $e');
    }
  }

  // Sauvegarder les contributions utilisateur
  static Future<void> _saveUserContributions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _userContributionsKey, json.encode(_userProposedQuestions));
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur sauvegarde contributions: $e');
    }
  }

  // Modérer une question proposée (pour les admins)
  static Future<void> moderateQuestion(String questionId, String status) async {
    try {
      final questionIndex =
          _userProposedQuestions.indexWhere((q) => q['id'] == questionId);

      if (questionIndex != -1) {
        final question = _userProposedQuestions[questionIndex];
        question['status'] = status;

        if (status == 'approved') {
          // Ajouter aux questions communautaires
          _communityQuestions.add(question);
          await _saveCommunityQuestions();
        }

        await _saveUserContributions();

        print('[CommunityQuestionService] ✅ Question modérée: $status');
      }
    } catch (e) {
      print('[CommunityQuestionService] ❌ Erreur modération: $e');
    }
  }

  // Obtenir les questions en attente de modération
  static List<Map<String, dynamic>> getPendingQuestions() {
    return _userProposedQuestions
        .where((q) => q['status'] == 'pending')
        .toList();
  }
}
