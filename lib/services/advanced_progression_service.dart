import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedProgressionService {
  static const String _levelKey = 'player_level';
  static const String _xpKey = 'player_xp';
  static const String _streakKey = 'current_streak';
  static const String _bestStreakKey = 'best_streak';
  static const String _achievementsKey = 'achievements_unlocked';
  static const String _dailyGoalsKey = 'daily_goals';
  static const String _weeklyChallengesKey = 'weekly_challenges';

  // Configuration des niveaux
  static const Map<int, Map<String, dynamic>> _levelConfig = {
    1: {
      'xpRequired': 0,
      'title': 'Débutant',
      'color': 0xFF4CAF50,
      'unlock': 'Accès aux bases'
    },
    5: {
      'xpRequired': 500,
      'title': 'Étudiant',
      'color': 0xFF2196F3,
      'unlock': 'Questions moyennes'
    },
    10: {
      'xpRequired': 1500,
      'title': 'Connaisseur',
      'color': 0xFF9C27B0,
      'unlock': 'Questions difficiles'
    },
    15: {
      'xpRequired': 3500,
      'title': 'Expert',
      'color': 0xFFFF9800,
      'unlock': 'Défis spéciaux'
    },
    20: {
      'xpRequired': 7000,
      'title': 'Maître',
      'color': 0xFFE91E63,
      'unlock': 'Mode créateur'
    },
    25: {
      'xpRequired': 12000,
      'title': 'Légende',
      'color': 0xFF795548,
      'unlock': 'Tout débloqué'
    },
  };

  // Système d'achievements
  static const Map<String, Map<String, dynamic>> _achievements = {
    'first_quiz': {
      'name': 'Premier Pas',
      'description': 'Complétez votre premier quiz',
      'icon': '🎯',
      'xpReward': 50,
      'unlocked': false,
    },
    'perfect_score': {
      'name': 'Parfait',
      'description': 'Obtenez un score parfait (10/10)',
      'icon': '🏆',
      'xpReward': 100,
      'unlocked': false,
    },
    'streak_7': {
      'name': 'Série de 7',
      'description': 'Jouez 7 jours consécutifs',
      'icon': '🔥',
      'xpReward': 200,
      'unlocked': false,
    },
    'category_master': {
      'name': 'Maître de Catégorie',
      'description': 'Complétez 50 quiz dans une catégorie',
      'icon': '👑',
      'xpReward': 300,
      'unlocked': false,
    },
    'speed_demon': {
      'name': 'Démon de Vitesse',
      'description': 'Répondez à 10 questions en moins de 30 secondes',
      'icon': '⚡',
      'xpReward': 150,
      'unlocked': false,
    },
    'night_owl': {
      'name': 'Oiseau de Nuit',
      'description': 'Jouez après minuit',
      'icon': '🦉',
      'xpReward': 75,
      'unlocked': false,
    },
    'early_bird': {
      'name': 'Lève-tôt',
      'description': 'Jouez avant 6h du matin',
      'icon': '🐦',
      'xpReward': 75,
      'unlocked': false,
    },
    'weekend_warrior': {
      'name': 'Guerrier du Weekend',
      'description': 'Jouez 5 quiz un weekend',
      'icon': '⚔️',
      'xpReward': 125,
      'unlocked': false,
    },
  };

  // Objectifs quotidiens
  static const Map<String, Map<String, dynamic>> _dailyGoals = {
    'quiz_3': {
      'name': 'Quiz Quotidien',
      'description': 'Complétez 3 quiz aujourd\'hui',
      'target': 3,
      'xpReward': 100,
      'icon': '📚',
    },
    'perfect_quiz': {
      'name': 'Quiz Parfait',
      'description': 'Obtenez un score parfait',
      'target': 1,
      'xpReward': 150,
      'icon': '🎯',
    },
    'categories_2': {
      'name': 'Explorateur',
      'description': 'Jouez dans 2 catégories différentes',
      'target': 2,
      'xpReward': 75,
      'icon': '🗺️',
    },
    'speed_quiz': {
      'name': 'Rapide comme l\'éclair',
      'description': 'Complétez un quiz en moins de 2 minutes',
      'target': 1,
      'xpReward': 100,
      'icon': '⚡',
    },
  };

  // Défis hebdomadaires
  static const Map<String, Map<String, dynamic>> _weeklyChallenges = {
    'marathon': {
      'name': 'Marathon du Savoir',
      'description': 'Complétez 20 quiz cette semaine',
      'target': 20,
      'xpReward': 500,
      'icon': '🏃‍♂️',
      'difficulty': 'hard',
    },
    'perfectionist': {
      'name': 'Perfectionniste',
      'description': 'Obtenez 5 scores parfaits cette semaine',
      'target': 5,
      'xpReward': 400,
      'icon': '💎',
      'difficulty': 'medium',
    },
    'explorer': {
      'name': 'Grand Explorateur',
      'description': 'Jouez dans toutes les catégories cette semaine',
      'target': 5,
      'xpReward': 300,
      'icon': '🧭',
      'difficulty': 'medium',
    },
    'streak_master': {
      'name': 'Maître de la Série',
      'description': 'Maintenez une série de 7 jours',
      'target': 7,
      'xpReward': 600,
      'icon': '🔥',
      'difficulty': 'hard',
    },
  };

  // Ajouter de l'XP avec système de bonus
  static Future<int> addExperience({
    required int baseXP,
    String? reason,
    bool isPerfectScore = false,
    bool isStreakBonus = false,
    bool isTimeBonus = false,
    bool isCategoryBonus = false,
  }) async {
    int totalXP = baseXP;
    List<String> bonuses = [];

    // Bonus score parfait
    if (isPerfectScore) {
      totalXP += (baseXP * 0.5).round();
      bonuses.add('Score parfait (+${(baseXP * 0.5).round()} XP)');
    }

    // Bonus série
    if (isStreakBonus) {
      final streak = await getCurrentStreak();
      final streakBonus = min(streak * 10, 100); // Max 100 XP bonus
      totalXP += streakBonus;
      bonuses.add('Série $streak jours (+$streakBonus XP)');
    }

    // Bonus temps
    if (isTimeBonus) {
      totalXP += (baseXP * 0.3).round();
      bonuses.add('Rapidité (+${(baseXP * 0.3).round()} XP)');
    }

    // Bonus catégorie
    if (isCategoryBonus) {
      totalXP += (baseXP * 0.2).round();
      bonuses.add('Variété (+${(baseXP * 0.2).round()} XP)');
    }

    // Ajouter l'XP
    await _addXP(totalXP);

    // Vérifier les achievements
    await _checkAchievements();

    // Vérifier les objectifs quotidiens
    await _updateDailyGoals();

    // Vérifier les défis hebdomadaires
    await _updateWeeklyChallenges();

    print('[AdvancedProgression] +$totalXP XP (base: $baseXP)');
    if (bonuses.isNotEmpty) {
      print('[AdvancedProgression] Bonus: ${bonuses.join(', ')}');
    }

    return totalXP;
  }

  // Obtenir le niveau actuel
  static Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  // Obtenir l'XP actuel
  static Future<int> getCurrentXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  // Obtenir la série actuelle
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // Obtenir la meilleure série
  static Future<int> getBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestStreakKey) ?? 0;
  }

  // Obtenir les informations du niveau
  static Future<Map<String, dynamic>> getLevelInfo() async {
    final currentLevel = await getCurrentLevel();
    final currentXP = await getCurrentXP();

    // Trouver le prochain niveau
    int nextLevel = currentLevel;
    for (final level in _levelConfig.keys) {
      if (level > currentLevel) {
        nextLevel = level;
        break;
      }
    }

    final currentLevelConfig = _levelConfig[currentLevel] ?? _levelConfig[1]!;
    final nextLevelConfig = _levelConfig[nextLevel] ?? _levelConfig[25]!;

    final xpForNextLevel =
        nextLevelConfig['xpRequired'] - currentLevelConfig['xpRequired'];
    final xpProgress = currentXP - currentLevelConfig['xpRequired'];
    final progressPercentage = xpForNextLevel > 0
        ? (xpProgress / xpForNextLevel * 100).clamp(0.0, 100.0)
        : 100.0;

    return {
      'currentLevel': currentLevel,
      'currentXP': currentXP,
      'nextLevel': nextLevel,
      'title': currentLevelConfig['title'],
      'color': currentLevelConfig['color'],
      'unlock': currentLevelConfig['unlock'],
      'xpProgress': xpProgress,
      'xpForNextLevel': xpForNextLevel,
      'progressPercentage': progressPercentage,
    };
  }

  // Obtenir les achievements
  static Future<List<Map<String, dynamic>>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedAchievements = prefs.getStringList(_achievementsKey) ?? [];

    return _achievements.entries.map((entry) {
      final achievement = Map<String, dynamic>.from(entry.value);
      achievement['id'] = entry.key;
      achievement['unlocked'] = unlockedAchievements.contains(entry.key);
      return achievement;
    }).toList();
  }

  // Obtenir les objectifs quotidiens
  static Future<List<Map<String, dynamic>>> getDailyGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    // final dailyGoalsData = prefs.getString('${_dailyGoalsKey}_$today') ?? '{}'; // Unused

    // Réinitialiser les objectifs si c'est un nouveau jour
    if (!prefs.containsKey('${_dailyGoalsKey}_$today')) {
      await _resetDailyGoals();
    }

    return _dailyGoals.entries.map((entry) {
      final goal = Map<String, dynamic>.from(entry.value);
      goal['id'] = entry.key;
      goal['progress'] = 0; // TODO: Calculer le progrès réel
      goal['completed'] = false; // TODO: Vérifier la completion
      return goal;
    }).toList();
  }

  // Obtenir les défis hebdomadaires
  static Future<List<Map<String, dynamic>>> getWeeklyChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final weekStart = _getWeekStart();
    // final weeklyChallengesData =
    //     prefs.getString('${_weeklyChallengesKey}_$weekStart') ?? '{}'; // Unused

    // Réinitialiser les défis si c'est une nouvelle semaine
    if (!prefs.containsKey('${_weeklyChallengesKey}_$weekStart')) {
      await _resetWeeklyChallenges();
    }

    return _weeklyChallenges.entries.map((entry) {
      final challenge = Map<String, dynamic>.from(entry.value);
      challenge['id'] = entry.key;
      challenge['progress'] = 0; // TODO: Calculer le progrès réel
      challenge['completed'] = false; // TODO: Vérifier la completion
      return challenge;
    }).toList();
  }

  // Ajouter de l'XP
  static Future<void> _addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXP = await getCurrentXP();
    final newXP = currentXP + xp;

    await prefs.setInt(_xpKey, newXP);

    // Vérifier le level up
    await _checkLevelUp();
  }

  // Vérifier le level up
  static Future<void> _checkLevelUp() async {
    final currentLevel = await getCurrentLevel();
    final currentXP = await getCurrentXP();

    for (final level in _levelConfig.keys) {
      if (level > currentLevel &&
          currentXP >= _levelConfig[level]!['xpRequired']) {
        await _levelUp(level);
      }
    }
  }

  // Level up
  static Future<void> _levelUp(int newLevel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, newLevel);

    print('[AdvancedProgression] 🎉 Level up! Nouveau niveau: $newLevel');

    // TODO: Déclencher une animation de level up
    // TODO: Afficher une notification
    // TODO: Débloquer de nouveaux contenus
  }

  // Vérifier les achievements
  static Future<void> _checkAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedAchievements = prefs.getStringList(_achievementsKey) ?? [];

    for (final entry in _achievements.entries) {
      if (unlockedAchievements.contains(entry.key)) continue;

      bool shouldUnlock = false;

      switch (entry.key) {
        case 'first_quiz':
          // TODO: Vérifier si le joueur a complété son premier quiz
          break;
        case 'perfect_score':
          // TODO: Vérifier si le joueur a obtenu un score parfait
          break;
        case 'streak_7':
          shouldUnlock = await getCurrentStreak() >= 7;
          break;
        case 'category_master':
          // TODO: Vérifier les quiz par catégorie
          break;
        case 'speed_demon':
          // TODO: Vérifier les temps de réponse
          break;
        case 'night_owl':
          final now = DateTime.now();
          shouldUnlock = now.hour >= 0 && now.hour < 6;
          break;
        case 'early_bird':
          final now = DateTime.now();
          shouldUnlock = now.hour >= 4 && now.hour < 6;
          break;
        case 'weekend_warrior':
          // TODO: Vérifier les quiz du weekend
          break;
      }

      if (shouldUnlock) {
        await _unlockAchievement(entry.key);
      }
    }
  }

  // Débloquer un achievement
  static Future<void> _unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedAchievements = prefs.getStringList(_achievementsKey) ?? [];

    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
      await prefs.setStringList(_achievementsKey, unlockedAchievements);

      final achievement = _achievements[achievementId]!;
      await addExperience(
          baseXP: achievement['xpReward'], reason: 'Achievement débloqué');

      print(
          '[AdvancedProgression] 🏆 Achievement débloqué: ${achievement['name']}');

      // TODO: Afficher une notification d'achievement
    }
  }

  // Mettre à jour les objectifs quotidiens
  static Future<void> _updateDailyGoals() async {
    // TODO: Implémenter la logique de mise à jour des objectifs quotidiens
  }

  // Mettre à jour les défis hebdomadaires
  static Future<void> _updateWeeklyChallenges() async {
    // TODO: Implémenter la logique de mise à jour des défis hebdomadaires
  }

  // Réinitialiser les objectifs quotidiens
  static Future<void> _resetDailyGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('${_dailyGoalsKey}_$today', '{}');
  }

  // Réinitialiser les défis hebdomadaires
  static Future<void> _resetWeeklyChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final weekStart = _getWeekStart();
    await prefs.setString('${_weeklyChallengesKey}_$weekStart', '{}');
  }

  // Obtenir le début de la semaine
  static String _getWeekStart() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    final weekStart = now.subtract(Duration(days: daysFromMonday));
    return weekStart.toIso8601String().split('T')[0];
  }

  // Obtenir les statistiques complètes
  static Future<Map<String, dynamic>> getCompleteStats() async {
    return {
      'levelInfo': await getLevelInfo(),
      'achievements': await getAchievements(),
      'dailyGoals': await getDailyGoals(),
      'weeklyChallenges': await getWeeklyChallenges(),
      'currentStreak': await getCurrentStreak(),
      'bestStreak': await getBestStreak(),
    };
  }
}
