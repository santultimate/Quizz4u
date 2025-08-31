import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import 'badge_service.dart';

class ProgressService {
  static const String _progressKey = 'user_progress';
  static UserProgress? _currentProgress;

  // Obtenir la progression actuelle
  static UserProgress get currentProgress {
    _currentProgress ??= UserProgress();
    return _currentProgress!;
  }

  // Charger la progression depuis le stockage
  static Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);

      if (progressJson != null) {
        final progressMap = json.decode(progressJson) as Map<String, dynamic>;
        _currentProgress = UserProgress.fromMap(progressMap);
        print(
            '[ProgressService] ✅ Progression chargée: Niveau ${_currentProgress!.level}, XP: ${_currentProgress!.experiencePoints}');
      } else {
        _currentProgress = UserProgress();
        print('[ProgressService] 🆕 Nouvelle progression créée');
      }
    } catch (e) {
      print('[ProgressService] ❌ Erreur chargement progression: $e');
      _currentProgress = UserProgress();
    }
  }

  // Sauvegarder la progression
  static Future<void> saveProgress() async {
    try {
      if (_currentProgress != null) {
        final prefs = await SharedPreferences.getInstance();
        final progressJson = json.encode(_currentProgress!.toMap());
        await prefs.setString(_progressKey, progressJson);
        print('[ProgressService] ✅ Progression sauvegardée');
      }
    } catch (e) {
      print('[ProgressService] ❌ Erreur sauvegarde progression: $e');
    }
  }

  // Ajouter de l'expérience
  static Future<void> addExperience(int xp, {String? reason}) async {
    final oldLevel = _currentProgress?.level ?? 1;
    _currentProgress?.addExperience(xp);

    print(
        '[ProgressService] 🎯 +$xp XP ajouté${reason != null ? ' ($reason)' : ''}');
    print(
        '[ProgressService] 📊 Niveau: $oldLevel → ${_currentProgress?.level}');

    // Vérifier si niveau supérieur
    if (_currentProgress?.level != null && _currentProgress!.level > oldLevel) {
      print(
          '[ProgressService] 🎉 Niveau supérieur atteint: ${_currentProgress!.level}');
    }

    await saveProgress();
  }

  // Ajouter une réponse
  static Future<void> addAnswer(bool isCorrect, int score, String category,
      {String difficulty = 'mixed'}) async {
    print(
        '[ProgressService] 🎯 Début addAnswer: isCorrect=$isCorrect, score=$score, category=$category, difficulty=$difficulty');

    if (_currentProgress == null) {
      print(
          '[ProgressService] ⚠️ _currentProgress est null, création d\'une nouvelle progression');
      _currentProgress = UserProgress();
    }

    _currentProgress?.addAnswer(isCorrect, score);
    _currentProgress?.addCategoryStats(category, isCorrect);

    // Debug: Afficher les statistiques de la catégorie après mise à jour
    print(
        '[ProgressService] 📊 Statistiques catégorie $category après mise à jour: ${_currentProgress?.getCategoryStats(category)}');

    // Calculer XP basé sur la réponse (système progressif)
    int xp = 0;

    if (isCorrect) {
      // XP de base pour bonne réponse (plus modéré)
      xp = 5;

      // Bonus XP basé sur le score (réduit)
      int scoreBonus = (score / 20).round(); // Réduit de 10 à 20
      xp += scoreBonus;

      // Bonus XP basé sur la difficulté
      if (difficulty == 'hard' || difficulty == 'difficile') {
        xp += 3; // Bonus pour questions difficiles
      } else if (difficulty == 'medium' || difficulty == 'moyen') {
        xp += 1; // Petit bonus pour questions moyennes
      }

      // Bonus XP basé sur le niveau actuel (plus difficile = plus de XP)
      int levelBonus = ((_currentProgress?.level ?? 1) / 5)
          .round(); // Bonus tous les 5 niveaux
      xp += levelBonus;
    } else {
      // XP de participation (réduit)
      xp = 1; // Réduit de 2 à 1
    }

    // Plafonner l'XP maximum par question
    xp = xp.clamp(1, 15); // Maximum 15 XP par question

    print(
        '[ProgressService] 🎯 XP calculé: $xp (isCorrect=$isCorrect, score=$score)');

    await addExperience(xp,
        reason: isCorrect ? 'Bonne réponse' : 'Participation');

    // Vérifier les badges classiques
    _currentProgress?.checkAndAddBadges();

    // Vérifier les nouveaux badges spécialisés
    List<String> newBadges =
        BadgeService.checkAllBadges(_currentProgress!, category, difficulty);
    if (newBadges.isNotEmpty) {
      print('[ProgressService] 🏆 Nouveaux badges obtenus: $newBadges');
      await saveProgress(); // Sauvegarder immédiatement les nouveaux badges
    }

    print(
        '[ProgressService] 📈 Réponse enregistrée: ${isCorrect ? "✅" : "❌"} (+$score points)');
    print(
        '[ProgressService] 📊 XP total: ${_currentProgress?.experiencePoints}, Niveau: ${_currentProgress?.level}');
  }

  // Obtenir les statistiques
  static Future<Map<String, dynamic>> getStats() async {
    print('[ProgressService] 📊 getStats() appelé');

    if (_currentProgress == null) {
      print('[ProgressService] ⚠️ _currentProgress est null, retour map vide');
      return {};
    }

    // Récupérer le nom du joueur depuis SharedPreferences
    String playerName = 'Joueur';
    try {
      final prefs = await SharedPreferences.getInstance();
      playerName = prefs.getString('player_name') ?? 'Joueur';
    } catch (e) {
      print('[ProgressService] ❌ Erreur lors de la récupération du nom: $e');
    }

    Map<String, dynamic> stats = {
      'level': _currentProgress!.level,
      'experiencePoints': _currentProgress!.experiencePoints,
      'xpForNextLevel': _currentProgress!.xpForNextLevel,
      'levelProgress': _currentProgress!.levelProgress,
      'totalQuestions': _currentProgress!.totalQuestionsAnswered,
      'correctAnswers': _currentProgress!.correctAnswers,
      'accuracyRate': _currentProgress!.accuracyRate,
      'totalScore': _currentProgress!.totalScore,
      'badges': _currentProgress!.badges,
      'categoryStats': _currentProgress!.getAllCategoryStats(),
      'lastPlayed': _currentProgress!.lastPlayed.toIso8601String(),
      'playerName': playerName,
    };

    print('[ProgressService] 📊 Statistiques retournées: $stats');
    print(
        '[ProgressService] 📊 Statistiques par catégorie détaillées: ${_currentProgress!.getAllCategoryStats()}');
    return stats;
  }

  // Réinitialiser la progression
  static Future<void> resetProgress() async {
    _currentProgress = UserProgress();
    await saveProgress();
    print('[ProgressService] 🔄 Progression réinitialisée');
  }

  // Obtenir le titre du niveau
  static String getLevelTitle(int level) {
    if (level < 5) return 'Débutant';
    if (level < 10) return 'Intermédiaire';
    if (level < 15) return 'Avancé';
    if (level < 20) return 'Expert';
    if (level < 25) return 'Maître';
    if (level < 30) return 'Légende';
    return 'Mythique';
  }

  // Obtenir la description du badge
  static String getBadgeDescription(String badge) {
    // Vérifier d'abord les nouveaux badges spécialisés
    Map<String, dynamic>? badgeInfo = BadgeService.getBadgeInfo(badge);
    if (badgeInfo != null) {
      return badgeInfo['description'] ?? 'Badge spécialisé';
    }

    // Badges classiques
    switch (badge) {
      case 'questionnaire':
        return 'A répondu à 100 questions';
      case 'expert':
        return 'Taux de réussite de 90%';
      case 'veteran':
        return 'Niveau 10 atteint';
      case 'champion':
        return '1000 points accumulés';
      default:
        return 'Badge mystérieux';
    }
  }

  // Obtenir l'icône du badge
  static String getBadgeIcon(String badge) {
    // Vérifier d'abord les nouveaux badges spécialisés
    Map<String, dynamic>? badgeInfo = BadgeService.getBadgeInfo(badge);
    if (badgeInfo != null) {
      return badgeInfo['icon'] ?? '🎖️';
    }

    // Badges classiques
    switch (badge) {
      case 'questionnaire':
        return '📝';
      case 'expert':
        return '🎯';
      case 'veteran':
        return '⚔️';
      case 'champion':
        return '🏆';
      default:
        return '🎖️';
    }
  }

  // Obtenir le nom du badge
  static String getBadgeName(String badge) {
    // Vérifier d'abord les nouveaux badges spécialisés
    Map<String, dynamic>? badgeInfo = BadgeService.getBadgeInfo(badge);
    if (badgeInfo != null) {
      return badgeInfo['name'] ?? 'Badge Spécialisé';
    }

    // Badges classiques
    switch (badge) {
      case 'questionnaire':
        return 'Questionnaire';
      case 'expert':
        return 'Expert';
      case 'veteran':
        return 'Vétéran';
      case 'champion':
        return 'Champion';
      default:
        return 'Badge Mystérieux';
    }
  }
}
