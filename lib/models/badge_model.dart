class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredScore;
  final BadgeType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredScore,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      requiredScore: json['requiredScore'],
      type: BadgeType.values
          .firstWhere((e) => e.toString() == 'BadgeType.${json['type']}'),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'requiredScore': requiredScore,
      'type': type.toString().split('.').last,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

enum BadgeType {
  score,
  streak,
  category,
  perfect,
  speed,
  special,
}

class BadgeManager {
  static final List<Badge> allBadges = [
    // Score Badges
    Badge(
      id: 'first_100',
      title: 'Premier Pas',
      description: 'Atteindre 100 points',
      icon: '🥉',
      requiredScore: 100,
      type: BadgeType.score,
    ),
    Badge(
      id: 'score_500',
      title: 'Quiz Master',
      description: 'Atteindre 500 points',
      icon: '🥈',
      requiredScore: 500,
      type: BadgeType.score,
    ),
    Badge(
      id: 'score_1000',
      title: 'Quiz Champion',
      description: 'Atteindre 1000 points',
      icon: '🥇',
      requiredScore: 1000,
      type: BadgeType.score,
    ),
    Badge(
      id: 'score_5000',
      title: 'Quiz Legend',
      description: 'Atteindre 5000 points',
      icon: '👑',
      requiredScore: 5000,
      type: BadgeType.score,
    ),

    // Streak Badges
    Badge(
      id: 'streak_3',
      title: 'En Forme',
      description: '3 bonnes réponses consécutives',
      icon: '🔥',
      requiredScore: 3,
      type: BadgeType.streak,
    ),
    Badge(
      id: 'streak_5',
      title: 'En Feu',
      description: '5 bonnes réponses consécutives',
      icon: '🔥🔥',
      requiredScore: 5,
      type: BadgeType.streak,
    ),
    Badge(
      id: 'streak_10',
      title: 'Incendie',
      description: '10 bonnes réponses consécutives',
      icon: '🔥🔥🔥',
      requiredScore: 10,
      type: BadgeType.streak,
    ),

    // Category Badges
    Badge(
      id: 'mali_expert',
      title: 'Expert Mali',
      description: 'Compléter 50 questions Histoire du Mali',
      icon: '🇲🇱',
      requiredScore: 50,
      type: BadgeType.category,
    ),
    Badge(
      id: 'science_expert',
      title: 'Scientifique',
      description: 'Compléter 50 questions Sciences',
      icon: '🔬',
      requiredScore: 50,
      type: BadgeType.category,
    ),
    Badge(
      id: 'math_expert',
      title: 'Mathématicien',
      description: 'Compléter 50 questions Mathématiques',
      icon: '📐',
      requiredScore: 50,
      type: BadgeType.category,
    ),
    Badge(
      id: 'africa_expert',
      title: 'Africain',
      description: 'Compléter 50 questions Afrique',
      icon: '🌍',
      requiredScore: 50,
      type: BadgeType.category,
    ),

    // Perfect Badges
    Badge(
      id: 'perfect_10',
      title: 'Parfait 10',
      description: '10/10 dans une catégorie',
      icon: '⭐',
      requiredScore: 10,
      type: BadgeType.perfect,
    ),
    Badge(
      id: 'perfect_all',
      title: 'Parfait Absolu',
      description: '10/10 dans toutes les catégories',
      icon: '💎',
      requiredScore: 50,
      type: BadgeType.perfect,
    ),

    // Speed Badges
    Badge(
      id: 'speed_demon',
      title: 'Démon de Vitesse',
      description: 'Répondre en moins de 5 secondes',
      icon: '⚡',
      requiredScore: 5,
      type: BadgeType.speed,
    ),

    // Special Badges
    Badge(
      id: 'first_quiz',
      title: 'Premier Quiz',
      description: 'Compléter votre premier quiz',
      icon: '🎯',
      requiredScore: 1,
      type: BadgeType.special,
    ),
    Badge(
      id: 'daily_player',
      title: 'Joueur Quotidien',
      description: 'Jouer 7 jours consécutifs',
      icon: '📅',
      requiredScore: 7,
      type: BadgeType.special,
    ),
  ];

  static List<Badge> getUnlockedBadges() {
    return allBadges.where((badge) => badge.isUnlocked).toList();
  }

  static List<Badge> getLockedBadges() {
    return allBadges.where((badge) => !badge.isUnlocked).toList();
  }

  static Badge? getBadgeById(String id) {
    try {
      return allBadges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }
}
