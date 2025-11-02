class DailyChallenge {
  final String id;
  final String titleKey; // Clé de traduction au lieu de texte
  final String descriptionKey; // Clé de traduction au lieu de texte
  final int targetScore;
  final Duration timeLimit;
  final List<String> categories;
  final Map<String, int> rewards;
  final DateTime date;
  final bool isCompleted;
  final int currentProgress;
  final String difficulty;
  final String icon;
  DateTime lastPlayedDate;
  int progress;

  DailyChallenge({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.targetScore,
    required this.timeLimit,
    required this.categories,
    required this.rewards,
    required this.date,
    this.isCompleted = false,
    this.currentProgress = 0,
    this.difficulty = 'medium',
    this.icon = '🎯',
    DateTime? lastPlayedDate,
    this.progress = 0,
  }) : lastPlayedDate = lastPlayedDate ?? DateTime.now();

  // Progression en pourcentage
  double get progressPercentage {
    if (targetScore == 0) return 0.0;
    return (progress / targetScore).clamp(0.0, 1.0);
  }

  // Vérifier si le défi est terminé
  bool get isFinished {
    return progress >= targetScore;
  }

  // Obtenir la récompense principale
  String get mainReward {
    return rewards.entries.first.key;
  }

  // Obtenir la valeur de la récompense principale
  int get mainRewardValue {
    return rewards.entries.first.value;
  }

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'targetScore': targetScore,
      'timeLimit': timeLimit.inMinutes,
      'categories': categories,
      'rewards': rewards,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'currentProgress': currentProgress,
      'difficulty': difficulty,
      'icon': icon,
    };
  }

  // Convertir en JSON pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'targetScore': targetScore,
      'timeLimit': timeLimit.inMinutes,
      'categories': categories,
      'rewards': rewards,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'currentProgress': currentProgress,
      'difficulty': difficulty,
      'icon': icon,
      'lastPlayedDate': lastPlayedDate.toIso8601String(),
      'progress': progress,
    };
  }

  // Créer depuis une Map
  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'] ?? '',
      titleKey: map['titleKey'] ?? map['title'] ?? 'challenge_unknown',
      descriptionKey: map['descriptionKey'] ??
          map['description'] ??
          'challenge_unknown_desc',
      targetScore: map['targetScore'] ?? 0,
      timeLimit: Duration(minutes: map['timeLimit'] ?? 10),
      categories: List<String>.from(map['categories'] ?? []),
      rewards: Map<String, int>.from(map['rewards'] ?? {}),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      isCompleted: map['isCompleted'] ?? false,
      currentProgress: map['currentProgress'] ?? 0,
      difficulty: map['difficulty'] ?? 'medium',
      icon: map['icon'] ?? '🎯',
    );
  }

  // Créer depuis JSON
  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] ?? '',
      titleKey: json['titleKey'] ?? json['title'] ?? 'challenge_unknown',
      descriptionKey: json['descriptionKey'] ??
          json['description'] ??
          'challenge_unknown_desc',
      targetScore: json['targetScore'] ?? 0,
      timeLimit: Duration(minutes: json['timeLimit'] ?? 10),
      categories: List<String>.from(json['categories'] ?? []),
      rewards: Map<String, int>.from(json['rewards'] ?? {}),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isCompleted: json['isCompleted'] ?? false,
      currentProgress: json['currentProgress'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
      icon: json['icon'] ?? '🎯',
      lastPlayedDate: DateTime.parse(
          json['lastPlayedDate'] ?? DateTime.now().toIso8601String()),
      progress: json['progress'] ?? 0,
    );
  }

  // Créer une copie avec des valeurs mises à jour
  DailyChallenge copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    int? targetScore,
    Duration? timeLimit,
    List<String>? categories,
    Map<String, int>? rewards,
    DateTime? date,
    bool? isCompleted,
    int? currentProgress,
    String? difficulty,
    String? icon,
    DateTime? lastPlayedDate,
    int? progress,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      targetScore: targetScore ?? this.targetScore,
      timeLimit: timeLimit ?? this.timeLimit,
      categories: categories ?? this.categories,
      rewards: rewards ?? this.rewards,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      currentProgress: currentProgress ?? this.currentProgress,
      difficulty: difficulty ?? this.difficulty,
      icon: icon ?? this.icon,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      progress: progress ?? this.progress,
    );
  }
}

// Générateur de défis quotidiens
class DailyChallengeGenerator {
  static final List<Map<String, dynamic>> _challengeTemplates = [
    {
      'titleKey': 'challenge_math_title',
      'descriptionKey': 'challenge_math_desc',
      'targetScore': 5,
      'timeLimit': 3,
      'categories': ['Mathématiques'],
      'rewards': {'XP': 50, 'Coins': 25},
      'difficulty': 'medium',
      'icon': '🧮',
    },
    {
      'titleKey': 'challenge_cultural_explorer_title',
      'descriptionKey': 'challenge_cultural_explorer_desc',
      'targetScore': 5,
      'timeLimit': 4,
      'categories': ['Culture générale', 'Histoire du Mali', 'Afrique'],
      'rewards': {'XP': 75, 'Coins': 40},
      'difficulty': 'medium',
      'icon': '🌍',
    },
    {
      'titleKey': 'challenge_scientist_title',
      'descriptionKey': 'challenge_scientist_desc',
      'targetScore': 5,
      'timeLimit': 4,
      'categories': ['Sciences'],
      'rewards': {'XP': 60, 'Coins': 30},
      'difficulty': 'medium',
      'icon': '🔬',
    },
    {
      'titleKey': 'challenge_express_title',
      'descriptionKey': 'challenge_express_desc',
      'targetScore': 5,
      'timeLimit': 2,
      'categories': ['Culture générale'],
      'rewards': {'XP': 100, 'Coins': 50},
      'difficulty': 'hard',
      'icon': '⚡',
    },
    {
      'titleKey': 'challenge_mixed_title',
      'descriptionKey': 'challenge_mixed_desc',
      'targetScore': 5,
      'timeLimit': 5,
      'categories': [
        'Culture générale',
        'Sciences',
        'Mathématiques',
        'Histoire du Mali',
        'Afrique'
      ],
      'rewards': {'XP': 80, 'Coins': 40},
      'difficulty': 'medium',
      'icon': '🎯',
    },
  ];

  // Générer un défi quotidien aléatoire
  static DailyChallenge generateDailyChallenge() {
    final today = DateTime.now();
    final random =
        DateTime.now().millisecondsSinceEpoch % _challengeTemplates.length;
    final template = _challengeTemplates[random];

    return DailyChallenge(
      id: 'daily_${today.year}_${today.month}_${today.day}',
      titleKey: template['titleKey'],
      descriptionKey: template['descriptionKey'],
      targetScore: template['targetScore'],
      timeLimit: Duration(minutes: template['timeLimit']),
      categories: List<String>.from(template['categories']),
      rewards: Map<String, int>.from(template['rewards']),
      date: today,
      difficulty: template['difficulty'],
      icon: template['icon'],
    );
  }

  // Générer un défi personnalisé basé sur les préférences
  static DailyChallenge generatePersonalizedChallenge({
    required List<String> preferredCategories,
    required String difficulty,
  }) {
    final today = DateTime.now();

    // Filtrer les templates selon les préférences
    final suitableTemplates = _challengeTemplates.where((template) {
      final templateCategories = List<String>.from(template['categories']);
      return templateCategories
              .any((cat) => preferredCategories.contains(cat)) &&
          template['difficulty'] == difficulty;
    }).toList();

    if (suitableTemplates.isEmpty) {
      // Fallback vers un défi générique
      return generateDailyChallenge();
    }

    final random =
        DateTime.now().millisecondsSinceEpoch % suitableTemplates.length;
    final template = suitableTemplates[random];

    return DailyChallenge(
      id: 'personalized_${today.year}_${today.month}_${today.day}',
      titleKey: template['titleKey'],
      descriptionKey: template['descriptionKey'],
      targetScore: template['targetScore'],
      timeLimit: Duration(minutes: template['timeLimit']),
      categories: List<String>.from(template['categories']),
      rewards: Map<String, int>.from(template['rewards']),
      date: today,
      difficulty: template['difficulty'],
      icon: template['icon'],
    );
  }
}
