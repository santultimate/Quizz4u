import '../models/user_progress.dart';

class BadgeService {
  // Configuration des badges par catégorie
  static const Map<String, Map<String, Map<String, dynamic>>> _categoryBadges =
      {
    'Culture générale': {
      'perfect_10': {
        'name_key': 'badge_culture_perfect_10_title',
        'description_key': 'badge_culture_perfect_10_desc',
        'icon': '🎭',
        'requirement': '10 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Culture générale',
        'difficulty': 'any'
      },
      'perfect_20': {
        'name_key': 'badge_culture_perfect_20_title',
        'description_key': 'badge_culture_perfect_20_desc',
        'icon': '🏛️',
        'requirement': '20 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Culture générale',
        'difficulty': 'any'
      },
      'expert_90': {
        'name_key': 'badge_culture_expert_90_title',
        'description_key': 'badge_culture_expert_90_desc',
        'icon': '📚',
        'requirement': '90% accuracy rate',
        'type': 'accuracy',
        'category': 'Culture générale',
        'difficulty': 'any'
      }
    },
    'Sciences': {
      'perfect_10': {
        'name_key': 'badge_science_perfect_10_title',
        'description_key': 'badge_science_perfect_10_desc',
        'icon': '🔬',
        'requirement': '10 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Sciences',
        'difficulty': 'any'
      },
      'perfect_20': {
        'name_key': 'badge_science_perfect_20_title',
        'description_key': 'badge_science_perfect_20_desc',
        'icon': '⚗️',
        'requirement': '20 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Sciences',
        'difficulty': 'any'
      },
      'expert_90': {
        'name_key': 'badge_science_expert_90_title',
        'description_key': 'badge_science_expert_90_desc',
        'icon': '🧪',
        'requirement': '90% accuracy rate',
        'type': 'accuracy',
        'category': 'Sciences',
        'difficulty': 'any'
      }
    },
    'Mathématiques': {
      'perfect_10': {
        'name_key': 'badge_math_perfect_10_title',
        'description_key': 'badge_math_perfect_10_desc',
        'icon': '🧮',
        'requirement': '10 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Mathématiques',
        'difficulty': 'any'
      },
      'perfect_20': {
        'name_key': 'badge_math_perfect_20_title',
        'description_key': 'badge_math_perfect_20_desc',
        'icon': '📐',
        'requirement': '20 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Mathématiques',
        'difficulty': 'any'
      },
      'expert_90': {
        'name_key': 'badge_math_expert_90_title',
        'description_key': 'badge_math_expert_90_desc',
        'icon': '🔢',
        'requirement': '90% accuracy rate',
        'type': 'accuracy',
        'category': 'Mathématiques',
        'difficulty': 'any'
      }
    },
    'Histoire du Mali': {
      'perfect_10': {
        'name_key': 'badge_history_mali_perfect_10_title',
        'description_key': 'badge_history_mali_perfect_10_desc',
        'icon': '🏺',
        'requirement': '10 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Histoire du Mali',
        'difficulty': 'any'
      },
      'perfect_20': {
        'name_key': 'badge_history_mali_perfect_20_title',
        'description_key': 'badge_history_mali_perfect_20_desc',
        'icon': '👑',
        'requirement': '20 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Histoire du Mali',
        'difficulty': 'any'
      },
      'expert_90': {
        'name_key': 'badge_history_mali_expert_90_title',
        'description_key': 'badge_history_mali_expert_90_desc',
        'icon': '📜',
        'requirement': '90% accuracy rate',
        'type': 'accuracy',
        'category': 'Histoire du Mali',
        'difficulty': 'any'
      }
    },
    'Afrique': {
      'perfect_10': {
        'name_key': 'badge_africa_perfect_10_title',
        'description_key': 'badge_africa_perfect_10_desc',
        'icon': '🌍',
        'requirement': '10 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Afrique',
        'difficulty': 'any'
      },
      'perfect_20': {
        'name_key': 'badge_africa_perfect_20_title',
        'description_key': 'badge_africa_perfect_20_desc',
        'icon': '🦁',
        'requirement': '20 correct answers in a row',
        'type': 'perfect_score',
        'category': 'Afrique',
        'difficulty': 'any'
      },
      'expert_90': {
        'name_key': 'badge_africa_expert_90_title',
        'description_key': 'badge_africa_expert_90_desc',
        'icon': '🐘',
        'requirement': '90% accuracy rate',
        'type': 'accuracy',
        'category': 'Afrique',
        'difficulty': 'any'
      }
    }
  };

  // Badges par niveau de difficulté
  static const Map<String, Map<String, dynamic>> _difficultyBadges = {
    'easy_master': {
      'name_key': 'badge_easy_master_title',
      'description_key': 'badge_easy_master_desc',
      'icon': '😊',
      'requirement': '100 correct answers in easy mode',
      'type': 'difficulty_master',
      'difficulty': 'easy'
    },
    'medium_master': {
      'name_key': 'badge_medium_master_title',
      'description_key': 'badge_medium_master_desc',
      'icon': '😐',
      'requirement': '100 correct answers in medium mode',
      'type': 'difficulty_master',
      'difficulty': 'medium'
    },
    'hard_master': {
      'name_key': 'badge_hard_master_title',
      'description_key': 'badge_hard_master_desc',
      'icon': '😰',
      'requirement': '100 correct answers in hard mode',
      'type': 'difficulty_master',
      'difficulty': 'hard'
    },
    'mixed_master': {
      'name_key': 'badge_mixed_master_title',
      'description_key': 'badge_mixed_master_desc',
      'icon': '🎯',
      'requirement': '100 correct answers in mixed mode',
      'type': 'difficulty_master',
      'difficulty': 'mixed'
    }
  };

  // Badges spéciaux de progression
  static const Map<String, Map<String, dynamic>> _specialBadges = {
    'speed_demon': {
      'name_key': 'badge_speed_demon',
      'description_key': 'badge_speed_demon_desc',
      'icon': '⚡',
      'requirement': '10 correct answers in under 2 minutes',
      'type': 'speed'
    },
    'streak_master': {
      'name_key': 'badge_streak_master',
      'description_key': 'badge_streak_master_desc',
      'icon': '🔥',
      'requirement': '15 correct answers in a row',
      'type': 'streak'
    },
    'variety_expert': {
      'name_key': 'badge_variety_expert',
      'description_key': 'badge_variety_expert_desc',
      'icon': '🎨',
      'requirement': 'Played in all categories',
      'type': 'variety'
    },
    'daily_player': {
      'name_key': 'badge_daily_player',
      'description_key': 'badge_daily_player_desc',
      'icon': '📅',
      'requirement': 'Played 7 consecutive days',
      'type': 'daily'
    }
  };

  // Vérifier et ajouter les badges par catégorie
  static List<String> checkCategoryBadges(
      UserProgress progress, String category) {
    List<String> newBadges = [];

    if (!_categoryBadges.containsKey(category)) return newBadges;

    final categoryData = _categoryBadges[category]!;
    final categoryCorrect = progress.categoryStats[category] ?? 0;
    final categoryTotal = progress.totalQuestionsAnswered; // Approximation

    // Badge perfect_10 - Score parfait sur 10 questions consécutives
    if (categoryCorrect >= 10 &&
        !progress.badges.contains('${category}_perfect_10')) {
      newBadges.add('${category}_perfect_10');
      print(
          '[BadgeService] 🏆 Nouveau badge: ${categoryData['perfect_10']?['name']}');
    }

    // Badge perfect_20 - Score parfait sur 20 questions consécutives
    if (categoryCorrect >= 20 &&
        !progress.badges.contains('${category}_perfect_20')) {
      newBadges.add('${category}_perfect_20');
      print(
          '[BadgeService] 🏆 Nouveau badge: ${categoryData['perfect_20']?['name']}');
    }

    // Badge expert_90 - 90% de précision avec au moins 10 questions
    if (categoryTotal >= 10) {
      final accuracy = (categoryCorrect / categoryTotal) * 100;
      if (accuracy >= 90 &&
          !progress.badges.contains('${category}_expert_90')) {
        newBadges.add('${category}_expert_90');
        print(
            '[BadgeService] 🏆 Nouveau badge: ${categoryData['expert_90']?['name']}');
      }
    }

    return newBadges;
  }

  // Vérifier les badges de difficulté
  static List<String> checkDifficultyBadges(
      UserProgress progress, String difficulty) {
    List<String> newBadges = [];

    // Pour l'instant, on simule les badges de difficulté
    // Dans une version future, on pourrait tracker les questions par difficulté
    if (progress.totalQuestionsAnswered >= 100 &&
        !progress.badges.contains('${difficulty}_master')) {
      newBadges.add('${difficulty}_master');
      print(
          '[BadgeService] 🏆 Nouveau badge: ${_difficultyBadges['${difficulty}_master']?['name']}');
    }

    return newBadges;
  }

  // Vérifier les badges spéciaux
  static List<String> checkSpecialBadges(UserProgress progress) {
    List<String> newBadges = [];

    // Badge speed_demon (simulation)
    if (progress.totalQuestionsAnswered >= 10 &&
        !progress.badges.contains('speed_demon')) {
      newBadges.add('speed_demon');
      print(
          '[BadgeService] 🏆 Nouveau badge: ${_specialBadges['speed_demon']!['name']}');
    }

    // Badge streak_master
    if (progress.correctAnswers >= 15 &&
        !progress.badges.contains('streak_master')) {
      newBadges.add('streak_master');
      print(
          '[BadgeService] 🏆 Nouveau badge: ${_specialBadges['streak_master']!['name']}');
    }

    // Badge variety_expert
    if (progress.categoryStats.length >= 5 &&
        !progress.badges.contains('variety_expert')) {
      newBadges.add('variety_expert');
      print(
          '[BadgeService] 🏆 Nouveau badge: ${_specialBadges['variety_expert']!['name']}');
    }

    return newBadges;
  }

  // Vérifier tous les badges
  static List<String> checkAllBadges(
      UserProgress progress, String category, String difficulty) {
    List<String> allNewBadges = [];

    // Badges par catégorie
    allNewBadges.addAll(checkCategoryBadges(progress, category));

    // Badges par difficulté
    allNewBadges.addAll(checkDifficultyBadges(progress, difficulty));

    // Badges spéciaux
    allNewBadges.addAll(checkSpecialBadges(progress));

    // Ajouter les nouveaux badges
    for (String badge in allNewBadges) {
      if (!progress.badges.contains(badge)) {
        progress.badges.add(badge);
      }
    }

    return allNewBadges;
  }

  // Obtenir les informations d'un badge
  static Map<String, dynamic>? getBadgeInfo(String badgeId) {
    // Chercher dans les badges par catégorie
    for (String category in _categoryBadges.keys) {
      if (_categoryBadges[category]!.containsKey(badgeId)) {
        return _categoryBadges[category]![badgeId];
      }
    }

    // Chercher dans les badges de difficulté
    if (_difficultyBadges.containsKey(badgeId)) {
      return _difficultyBadges[badgeId];
    }

    // Chercher dans les badges spéciaux
    if (_specialBadges.containsKey(badgeId)) {
      return _specialBadges[badgeId];
    }

    return null;
  }

  // Obtenir tous les badges disponibles
  static Map<String, Map<String, dynamic>> getAllBadges() {
    Map<String, Map<String, dynamic>> allBadges = {};

    // Ajouter les badges par catégorie
    for (String category in _categoryBadges.keys) {
      for (String badgeId in _categoryBadges[category]!.keys) {
        allBadges['${category}_$badgeId'] =
            _categoryBadges[category]![badgeId]!;
      }
    }

    // Ajouter les badges de difficulté
    allBadges.addAll(_difficultyBadges);

    // Ajouter les badges spéciaux
    allBadges.addAll(_specialBadges);

    return allBadges;
  }

  // Obtenir les badges par catégorie
  static Map<String, Map<String, dynamic>> getBadgesByCategory(
      String category) {
    return _categoryBadges[category] ?? {};
  }

  // Obtenir les statistiques de badges
  static Map<String, dynamic> getBadgeStats(UserProgress progress) {
    int totalBadges = progress.badges.length;
    int categoryBadges = 0;
    int difficultyBadges = 0;
    int specialBadges = 0;

    for (String badge in progress.badges) {
      if (badge.contains('_perfect_') || badge.contains('_expert_')) {
        categoryBadges++;
      } else if (badge.contains('_master')) {
        difficultyBadges++;
      } else {
        specialBadges++;
      }
    }

    return {
      'total': totalBadges,
      'category': categoryBadges,
      'difficulty': difficultyBadges,
      'special': specialBadges,
      'progress': (totalBadges / getAllBadges().length * 100).round()
    };
  }

  // Obtenir tous les badges disponibles (débloqués et non débloqués)
  static List<Map<String, dynamic>> getAllAvailableBadges(
      UserProgress progress) {
    List<Map<String, dynamic>> allBadges = [];

    // Ajouter tous les badges de catégorie
    for (String category in _categoryBadges.keys) {
      for (String badgeKey in _categoryBadges[category]!.keys) {
        final badgeId = '${category}_$badgeKey';
        final badgeInfo = getBadgeInfo(badgeId);
        if (badgeInfo != null) {
          Map<String, dynamic> badgeCopy = Map<String, dynamic>.from(badgeInfo);
          badgeCopy['isUnlocked'] = progress.badges.contains(badgeId);
          allBadges.add(badgeCopy);
        }
      }
    }

    // Ajouter tous les badges spéciaux
    for (String badgeKey in _specialBadges.keys) {
      final badgeInfo = getBadgeInfo(badgeKey);
      if (badgeInfo != null) {
        Map<String, dynamic> badgeCopy = Map<String, dynamic>.from(badgeInfo);
        badgeCopy['isUnlocked'] = progress.badges.contains(badgeKey);
        allBadges.add(badgeCopy);
      }
    }

    // Ajouter tous les badges de difficulté
    for (String badgeKey in _difficultyBadges.keys) {
      final badgeInfo = getBadgeInfo(badgeKey);
      if (badgeInfo != null) {
        Map<String, dynamic> badgeCopy = Map<String, dynamic>.from(badgeInfo);
        badgeCopy['isUnlocked'] = progress.badges.contains(badgeKey);
        allBadges.add(badgeCopy);
      }
    }

    // Trier par statut (débloqués en premier) puis par nom
    allBadges.sort((a, b) {
      if (a['isUnlocked'] != b['isUnlocked']) {
        return b['isUnlocked'] ? 1 : -1;
      }
      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });

    return allBadges;
  }

  // Obtenir les conditions pour débloquer un badge
  static String getBadgeRequirement(String badgeId) {
    final badgeInfo = getBadgeInfo(badgeId);
    if (badgeInfo == null) return 'Condition inconnue';

    final requirement = badgeInfo['requirement'] ?? 'Condition non spécifiée';
    final type = badgeInfo['type'] ?? '';
    final category = badgeInfo['category'] ?? '';

    switch (type) {
      case 'perfect_score':
        if (requirement.contains('10')) {
          return 'Obtenir un score parfait de 10/10 en $category';
        } else if (requirement.contains('20')) {
          return 'Obtenir un score parfait de 20/20 en $category';
        }
        break;
      case 'accuracy':
        return 'Atteindre 90% de précision en $category (minimum 10 questions)';
      case 'streak':
        return 'Obtenir 15 bonnes réponses consécutives';
      case 'variety':
        return 'Jouer dans toutes les catégories disponibles';
      case 'daily':
        return 'Jouer 7 jours consécutifs';
      case 'speed':
        return 'Répondre rapidement aux questions';
    }

    return requirement;
  }
}
