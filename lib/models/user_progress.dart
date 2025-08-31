class UserProgress {
  int experiencePoints;
  int level;
  int totalQuestionsAnswered;
  int correctAnswers;
  int totalScore;
  List<String> badges;
  Map<String, int> categoryStats;
  DateTime lastPlayed;

  UserProgress({
    this.experiencePoints = 0,
    this.level = 1,
    this.totalQuestionsAnswered = 0,
    this.correctAnswers = 0,
    this.totalScore = 0,
    List<String>? badges,
    Map<String, int>? categoryStats,
    DateTime? lastPlayed,
  })  : badges = badges ?? [],
        categoryStats = categoryStats ?? {},
        lastPlayed = lastPlayed ?? DateTime.now();

  // Calculer le niveau basé sur l'XP
  int get currentLevel {
    return (experiencePoints / 100).floor() + 1;
  }

  // XP nécessaire pour le prochain niveau
  int get xpForNextLevel {
    return (level * 100) - experiencePoints;
  }

  // Pourcentage de progression vers le prochain niveau
  double get levelProgress {
    int xpInCurrentLevel = experiencePoints % 100;
    return xpInCurrentLevel / 100.0;
  }

  // Calculer le taux de réussite
  double get accuracyRate {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (correctAnswers / totalQuestionsAnswered) * 100;
  }

  // Ajouter de l'XP
  void addExperience(int xp) {
    experiencePoints += xp;
    level = currentLevel;
    lastPlayed = DateTime.now();
  }

  // Ajouter une réponse
  void addAnswer(bool isCorrect, int score) {
    totalQuestionsAnswered++;
    if (isCorrect) {
      correctAnswers++;
    }
    totalScore += score;
    lastPlayed = DateTime.now();
  }

  // Ajouter des statistiques par catégorie
  void addCategoryStats(String category, bool isCorrect) {
    // Créer une clé pour les bonnes réponses
    String correctKey = '${category}_correct';
    String totalKey = '${category}_total';

    if (!categoryStats.containsKey(correctKey)) {
      categoryStats[correctKey] = 0;
    }
    if (!categoryStats.containsKey(totalKey)) {
      categoryStats[totalKey] = 0;
    }

    // Incrémenter le total
    categoryStats[totalKey] = categoryStats[totalKey]! + 1;

    // Incrémenter les bonnes réponses si correct
    if (isCorrect) {
      categoryStats[correctKey] = categoryStats[correctKey]! + 1;
    }
  }

  // Obtenir les statistiques détaillées par catégorie
  Map<String, dynamic> getCategoryStats(String category) {
    String correctKey = '${category}_correct';
    String totalKey = '${category}_total';

    int correct = categoryStats[correctKey] ?? 0;
    int total = categoryStats[totalKey] ?? 0;
    double accuracy = total > 0 ? (correct / total) * 100 : 0.0;

    return {
      'correct': correct,
      'total': total,
      'accuracy': accuracy,
      'wrong': total - correct,
    };
  }

  // Obtenir toutes les statistiques par catégorie
  Map<String, Map<String, dynamic>> getAllCategoryStats() {
    Map<String, Map<String, dynamic>> allStats = {};

    // Extraire les catégories uniques
    Set<String> categories = {};
    for (String key in categoryStats.keys) {
      if (key.endsWith('_total')) {
        categories.add(key.replaceAll('_total', ''));
      }
    }

    // Calculer les statistiques pour chaque catégorie
    for (String category in categories) {
      allStats[category] = getCategoryStats(category);
    }

    return allStats;
  }

  // Vérifier et ajouter des badges
  void checkAndAddBadges() {
    // Badge pour 100 questions
    if (totalQuestionsAnswered >= 100 && !badges.contains('questionnaire')) {
      badges.add('questionnaire');
    }

    // Badge pour 90% de réussite
    if (accuracyRate >= 90 && !badges.contains('expert')) {
      badges.add('expert');
    }

    // Badge pour niveau 10
    if (level >= 10 && !badges.contains('veteran')) {
      badges.add('veteran');
    }

    // Badge pour 1000 points
    if (totalScore >= 1000 && !badges.contains('champion')) {
      badges.add('champion');
    }
  }

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'experiencePoints': experiencePoints,
      'level': level,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'correctAnswers': correctAnswers,
      'totalScore': totalScore,
      'badges': badges,
      'categoryStats': categoryStats,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  // Créer depuis une Map
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    // Gérer la migration des anciennes statistiques de catégorie
    Map<String, int> categoryStats = {};
    dynamic rawCategoryStats = map['categoryStats'];

    if (rawCategoryStats != null) {
      if (rawCategoryStats is Map) {
        // Nouveau format : Map<String, int> avec _correct et _total
        for (var entry in rawCategoryStats.entries) {
          if (entry.value is int) {
            categoryStats[entry.key] = entry.value;
          }
        }
      }
    }

    return UserProgress(
      experiencePoints: map['experiencePoints'] ?? 0,
      level: map['level'] ?? 1,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      categoryStats: categoryStats,
      lastPlayed: map['lastPlayed'] != null
          ? DateTime.parse(map['lastPlayed'])
          : DateTime.now(),
    );
  }
}
