class Badge {
  final String id;
  final String titleKey; // Clé de traduction au lieu de texte
  final String descriptionKey; // Clé de traduction au lieu de texte
  final String icon;
  final int requiredScore;
  final BadgeType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.requiredScore,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      titleKey: json['titleKey'] ?? json['title'] ?? 'badge_unknown',
      descriptionKey:
          json['descriptionKey'] ?? json['description'] ?? 'badge_unknown_desc',
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
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
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
      titleKey: 'badge_first_100_title',
      descriptionKey: 'badge_first_100_desc',
      icon: '🥉',
      requiredScore: 100,
      type: BadgeType.score,
    ),
    Badge(
      id: 'score_500',
      titleKey: 'badge_score_500_title',
      descriptionKey: 'badge_score_500_desc',
      icon: '🥈',
      requiredScore: 500,
      type: BadgeType.score,
    ),
    Badge(
      id: 'score_1000',
      titleKey: 'badge_score_1000_title',
      descriptionKey: 'badge_score_1000_desc',
      icon: '🥇',
      requiredScore: 1000,
      type: BadgeType.score,
    ),
    Badge(
      id: 'score_5000',
      titleKey: 'badge_score_5000_title',
      descriptionKey: 'badge_score_5000_desc',
      icon: '👑',
      requiredScore: 5000,
      type: BadgeType.score,
    ),

    // Streak Badges
    Badge(
      id: 'streak_3',
      titleKey: 'badge_streak_3_title',
      descriptionKey: 'badge_streak_3_desc',
      icon: '🔥',
      requiredScore: 3,
      type: BadgeType.streak,
    ),
    Badge(
      id: 'streak_5',
      titleKey: 'badge_streak_5_title',
      descriptionKey: 'badge_streak_5_desc',
      icon: '🔥🔥',
      requiredScore: 5,
      type: BadgeType.streak,
    ),
    Badge(
      id: 'streak_10',
      titleKey: 'badge_streak_10_title',
      descriptionKey: 'badge_streak_10_desc',
      icon: '🔥🔥🔥',
      requiredScore: 10,
      type: BadgeType.streak,
    ),

    // Category Badges
    Badge(
      id: 'mali_expert',
      titleKey: 'badge_mali_expert_title',
      descriptionKey: 'badge_mali_expert_desc',
      icon: '🇲🇱',
      requiredScore: 50,
      type: BadgeType.category,
    ),
    Badge(
      id: 'science_expert',
      titleKey: 'badge_science_expert_title',
      descriptionKey: 'badge_science_expert_desc',
      icon: '🔬',
      requiredScore: 50,
      type: BadgeType.category,
    ),
    Badge(
      id: 'math_expert',
      titleKey: 'badge_math_expert_title',
      descriptionKey: 'badge_math_expert_desc',
      icon: '📐',
      requiredScore: 50,
      type: BadgeType.category,
    ),
    Badge(
      id: 'africa_expert',
      titleKey: 'badge_africa_expert_title',
      descriptionKey: 'badge_africa_expert_desc',
      icon: '🌍',
      requiredScore: 50,
      type: BadgeType.category,
    ),

    // Perfect Badges
    Badge(
      id: 'perfect_10',
      titleKey: 'badge_perfect_10_title',
      descriptionKey: 'badge_perfect_10_desc',
      icon: '⭐',
      requiredScore: 10,
      type: BadgeType.perfect,
    ),
    Badge(
      id: 'perfect_all',
      titleKey: 'badge_perfect_all_title',
      descriptionKey: 'badge_perfect_all_desc',
      icon: '💎',
      requiredScore: 50,
      type: BadgeType.perfect,
    ),

    // Speed Badges
    Badge(
      id: 'speed_demon',
      titleKey: 'badge_speed_demon_title',
      descriptionKey: 'badge_speed_demon_desc',
      icon: '⚡',
      requiredScore: 5,
      type: BadgeType.speed,
    ),

    // Special Badges
    Badge(
      id: 'first_quiz',
      titleKey: 'badge_first_quiz_title',
      descriptionKey: 'badge_first_quiz_desc',
      icon: '🎯',
      requiredScore: 1,
      type: BadgeType.special,
    ),
    Badge(
      id: 'daily_player',
      titleKey: 'badge_daily_player_title',
      descriptionKey: 'badge_daily_player_desc',
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
