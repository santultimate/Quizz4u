import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import 'dynamic_question_service.dart';

class DailyEngagementService {
  static const String _dailyLoginKey = 'daily_login_streak';
  static const String _dailyQuestionsKey = 'daily_questions_answered';
  static const String _lastActiveDateKey = 'last_active_date';
  static const String _engagementLevelKey = 'engagement_level';

  // Niveaux d'engagement
  static const Map<String, Map<String, dynamic>> _engagementLevels = {
    'nouveau': {
      'name': 'Nouveau Joueur',
      'minDays': 0,
      'maxDays': 3,
      'bonusMultiplier': 1.0,
      'specialQuestions': 0,
      'color': 0xFF4CAF50,
    },
    'actif': {
      'name': 'Joueur Actif',
      'minDays': 4,
      'maxDays': 14,
      'bonusMultiplier': 1.2,
      'specialQuestions': 1,
      'color': 0xFF2196F3,
    },
    'habituel': {
      'name': 'Habitué',
      'minDays': 15,
      'maxDays': 30,
      'bonusMultiplier': 1.5,
      'specialQuestions': 2,
      'color': 0xFFFF9800,
    },
    'expert': {
      'name': 'Expert',
      'minDays': 31,
      'maxDays': 60,
      'bonusMultiplier': 2.0,
      'specialQuestions': 3,
      'color': 0xFF9C27B0,
    },
    'maitre': {
      'name': 'Maître',
      'minDays': 61,
      'maxDays': 999,
      'bonusMultiplier': 2.5,
      'specialQuestions': 5,
      'color': 0xFFE91E63,
    },
  };

  // Événements spéciaux
  static const Map<String, Map<String, dynamic>> _specialEvents = {
    'weekend_boost': {
      'name': 'Weekend Boost',
      'days': [6, 7], // Samedi et dimanche
      'bonusMultiplier': 1.5,
      'description': 'Bonus weekend !',
    },
    'streak_bonus': {
      'name': 'Streak Bonus',
      'trigger': 7, // Tous les 7 jours
      'bonusMultiplier': 2.0,
      'description': 'Bonus de série !',
    },
    'monthly_challenge': {
      'name': 'Défi Mensuel',
      'trigger': 'monthly',
      'bonusMultiplier': 3.0,
      'description': 'Défi mensuel spécial !',
    },
  };

  // Enregistrer une session de jeu quotidienne
  static Future<void> recordDailySession({
    required int questionsAnswered,
    required int correctAnswers,
    required List<String> categories,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayStr = _formatDate(today);

      // Mettre à jour la série de connexions
      await _updateLoginStreak(today);

      // Enregistrer les questions du jour
      final dailyData = {
        'date': todayStr,
        'questionsAnswered': questionsAnswered,
        'correctAnswers': correctAnswers,
        'categories': categories,
        'engagementLevel': await getCurrentEngagementLevel(),
        'bonusApplied': await getTodayBonusMultiplier(),
      };

      await prefs.setString(_dailyQuestionsKey, json.encode(dailyData));

      // Mettre à jour le niveau d'engagement
      await _updateEngagementLevel();

      print(
          '[DailyEngagement] ✅ Session quotidienne enregistrée: $questionsAnswered questions');
    } catch (e) {
      print('[DailyEngagement] ❌ Erreur enregistrement: $e');
    }
  }

  // Obtenir le niveau d'engagement actuel
  static Future<Map<String, dynamic>> getCurrentEngagementLevel() async {
    final streak = await getLoginStreak();

    for (final level in _engagementLevels.entries) {
      if (streak >= level.value['minDays'] &&
          streak <= level.value['maxDays']) {
        return {
          'key': level.key,
          ...level.value,
          'currentStreak': streak,
        };
      }
    }

    return _engagementLevels['maitre']!;
  }

  // Obtenir le multiplicateur de bonus d'aujourd'hui
  static Future<double> getTodayBonusMultiplier() async {
    double multiplier = 1.0;

    // Bonus du niveau d'engagement
    final engagementLevel = await getCurrentEngagementLevel();
    multiplier *= engagementLevel['bonusMultiplier'];

    // Bonus d'événements spéciaux
    multiplier *= await _getSpecialEventMultiplier();

    return multiplier;
  }

  // Générer des questions personnalisées pour l'engagement
  static Future<List<QuestionModel>> generateEngagementQuestions(
      String category,
      {int count = 5}) async {
    final engagementLevel = await getCurrentEngagementLevel();
    final specialQuestionsCount = engagementLevel['specialQuestions'] ?? 0;

    List<QuestionModel> questions = [];

    // Questions dynamiques (60%)
    final dynamicCount = (count * 0.6).round();
    questions.addAll(DynamicQuestionService.generateDynamicQuestions(category,
        count: dynamicCount));

    // Questions spéciales d'engagement (40% ou selon le niveau)
    final specialCount = count - questions.length;
    final maxSpecialQuestions =
        specialQuestionsCount > 0 ? specialQuestionsCount : specialCount;
    final finalSpecialCount = specialCount > 0
        ? (specialCount > maxSpecialQuestions
            ? maxSpecialQuestions
            : specialCount)
        : 0;

    if (finalSpecialCount > 0) {
      questions.addAll(
          _generateSpecialEngagementQuestions(category, finalSpecialCount));
    }

    print(
        '[DailyEngagement] 🎯 Questions d\'engagement générées: ${questions.length} (niveau: ${engagementLevel['name']})');
    return questions.take(count).toList();
  }

  // Obtenir des statistiques d'engagement
  static Future<Map<String, dynamic>> getEngagementStats() async {
    try {
      final streak = await getLoginStreak();
      final engagementLevel = await getCurrentEngagementLevel();
      final todayBonus = await getTodayBonusMultiplier();

      // Statistiques de la semaine
      final weekStats = await _getWeeklyStats();

      return {
        'currentStreak': streak,
        'engagementLevel': engagementLevel,
        'todayBonusMultiplier': todayBonus,
        'weekStats': weekStats,
        'nextLevelProgress': _calculateNextLevelProgress(streak),
        'specialEvents': await _getActiveSpecialEvents(),
      };
    } catch (e) {
      print('[DailyEngagement] ❌ Erreur stats: $e');
      return {};
    }
  }

  // Obtenir la série de connexions
  static Future<int> getLoginStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_dailyLoginKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Mettre à jour la série de connexions
  static Future<void> _updateLoginStreak(DateTime today) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActiveStr = prefs.getString(_lastActiveDateKey);
      final currentStreak = prefs.getInt(_dailyLoginKey) ?? 0;

      if (lastActiveStr != null) {
        final lastActive = DateTime.parse(lastActiveStr);
        final daysDifference = today.difference(lastActive).inDays;

        if (daysDifference == 1) {
          // Connexion quotidienne - augmenter la série
          await prefs.setInt(_dailyLoginKey, currentStreak + 1);
        } else if (daysDifference > 1) {
          // Série brisée - recommencer
          await prefs.setInt(_dailyLoginKey, 1);
        }
        // Si daysDifference == 0, c'est le même jour, ne rien faire
      } else {
        // Premier jour
        await prefs.setInt(_dailyLoginKey, 1);
      }

      await prefs.setString(_lastActiveDateKey, today.toIso8601String());
    } catch (e) {
      print('[DailyEngagement] ❌ Erreur mise à jour série: $e');
    }
  }

  // Mettre à jour le niveau d'engagement
  static Future<void> _updateEngagementLevel() async {
    final streak = await getLoginStreak();

    for (final level in _engagementLevels.entries) {
      if (streak >= level.value['minDays'] &&
          streak <= level.value['maxDays']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_engagementLevelKey, level.key);
        break;
      }
    }
  }

  // Obtenir le multiplicateur d'événements spéciaux
  static Future<double> _getSpecialEventMultiplier() async {
    double multiplier = 1.0;
    final today = DateTime.now();
    final weekday = today.weekday;

    // Weekend boost
    if ([6, 7].contains(weekday)) {
      multiplier *= _specialEvents['weekend_boost']!['bonusMultiplier'];
    }

    // Streak bonus
    final streak = await getLoginStreak();
    if (streak % _specialEvents['streak_bonus']!['trigger'] == 0 &&
        streak > 0) {
      multiplier *= _specialEvents['streak_bonus']!['bonusMultiplier'];
    }

    return multiplier;
  }

  // Générer des questions spéciales d'engagement
  static List<QuestionModel> _generateSpecialEngagementQuestions(
      String category, int count) {
    List<QuestionModel> questions = [];

    // Questions de défi personnel
    questions.add(QuestionModel(
      question: 'Quelle est votre série de connexions actuelle ?',
      answers: {
        'Consultez vos statistiques !': true,
        '5 jours': false,
        '10 jours': false,
        'Je ne sais pas': false,
      },
      correctAnswer: 'Consultez vos statistiques !',
    ));

    // Questions de motivation
    questions.add(QuestionModel(
      question: 'Combien de jours faut-il pour former une habitude ?',
      answers: {
        '21 jours': true,
        '7 jours': false,
        '30 jours': false,
        '14 jours': false,
      },
      correctAnswer: '21 jours',
    ));

    return questions.take(count).toList();
  }

  // Obtenir les statistiques de la semaine
  static Future<Map<String, dynamic>> _getWeeklyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dailyDataStr = prefs.getString(_dailyQuestionsKey);

      if (dailyDataStr != null) {
        final dailyData = json.decode(dailyDataStr) as Map<String, dynamic>;
        final questionsAnswered = dailyData['questionsAnswered'] ?? 0;
        final correctAnswers = dailyData['correctAnswers'] ?? 0;

        return {
          'questionsAnswered': questionsAnswered,
          'correctAnswers': correctAnswers,
          'categories': dailyData['categories'] ?? [],
          'accuracy': questionsAnswered > 0
              ? (correctAnswers / questionsAnswered * 100).round()
              : 0,
        };
      }

      return {
        'questionsAnswered': 0,
        'correctAnswers': 0,
        'categories': [],
        'accuracy': 0,
      };
    } catch (e) {
      return {
        'questionsAnswered': 0,
        'correctAnswers': 0,
        'categories': [],
        'accuracy': 0,
      };
    }
  }

  // Calculer le progrès vers le niveau suivant
  static Map<String, dynamic> _calculateNextLevelProgress(int currentStreak) {
    for (final level in _engagementLevels.entries) {
      if (currentStreak >= level.value['minDays'] &&
          currentStreak <= level.value['maxDays']) {
        final nextLevelDays = level.value['maxDays'] + 1;
        final progress = (currentStreak - level.value['minDays']) /
            (level.value['maxDays'] - level.value['minDays']);

        return {
          'currentLevel': level.value['name'],
          'nextLevel': _getNextLevelName(level.key),
          'progress': progress,
          'daysToNext': nextLevelDays - currentStreak,
        };
      }
    }

    return {
      'currentLevel': 'Maître',
      'nextLevel': 'Légende',
      'progress': 1.0,
      'daysToNext': 0,
    };
  }

  // Obtenir le nom du niveau suivant
  static String _getNextLevelName(String currentLevel) {
    final levels = ['nouveau', 'actif', 'habituel', 'expert', 'maitre'];
    final currentIndex = levels.indexOf(currentLevel);

    if (currentIndex < levels.length - 1) {
      return _engagementLevels[levels[currentIndex + 1]]!['name'];
    }

    return 'Légende';
  }

  // Obtenir les événements spéciaux actifs
  static Future<List<Map<String, dynamic>>> _getActiveSpecialEvents() async {
    List<Map<String, dynamic>> activeEvents = [];
    final today = DateTime.now();
    final weekday = today.weekday;
    final streak = await getLoginStreak();

    // Weekend boost
    if ([6, 7].contains(weekday)) {
      activeEvents.add(_specialEvents['weekend_boost']!);
    }

    // Streak bonus
    if (streak % _specialEvents['streak_bonus']!['trigger'] == 0 &&
        streak > 0) {
      activeEvents.add(_specialEvents['streak_bonus']!);
    }

    return activeEvents;
  }

  // Formater une date
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
