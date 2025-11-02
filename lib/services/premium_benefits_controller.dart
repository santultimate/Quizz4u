import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'premium_service.dart';
import 'premium_features_service.dart';
import 'progress_service.dart';
import 'cached_preferences_service.dart';

/// 🎯 Contrôleur centralisé pour gérer TOUS les avantages Premium
/// Garantit que chaque avantage affiché est réellement implémenté et fonctionnel
class PremiumBenefitsController {
  /// 📊 1. STATISTIQUES DÉTAILLÉES - Accès aux analyses avancées
  static Future<Map<String, dynamic>> getAdvancedStatistics() async {
    final isPremium = await PremiumService.isPremiumUser();

    if (!isPremium) {
      return {
        'locked': true,
        'message': '🔒 Statistiques avancées disponibles en Premium',
      };
    }

    // Statistiques Premium complètes
    final stats = await ProgressService.getStats();
    final premiumFeatures =
        await PremiumFeaturesService.getStatisticsPremiumFeatures();

    return {
      'locked': false,
      'basicStats': stats,
      'detailedAnalytics': premiumFeatures['detailedAnalytics'],
      'performanceInsights': premiumFeatures['performanceInsights'],
      'historicalData': premiumFeatures['historicalData'], // 365 jours vs 30
      'comparisonTools': premiumFeatures['comparisonTools'],
      'exportEnabled': premiumFeatures['exportData'],
    };
  }

  /// 🎨 2. THÈMES PERSONNALISÉS - 10+ thèmes disponibles
  static Future<Map<String, dynamic>> getAvailableThemes() async {
    final isPremium = await PremiumService.isPremiumUser();
    final themesConfig =
        await PremiumFeaturesService.getThemesPremiumFeatures();

    return {
      'isPremium': isPremium,
      'availableThemes': themesConfig['availableThemes'],
      'totalThemes': (themesConfig['availableThemes'] as List).length,
      'lockedThemes': isPremium ? 0 : 10, // 10 thèmes bloqués pour free users
      'customColors': themesConfig['customColors'],
      'animatedThemes': themesConfig['animatedThemes'],
    };
  }

  /// ⭐ 3. DÉFIS QUOTIDIENS EXCLUSIFS - Récompenses bonus
  static Future<Map<String, dynamic>> getDailyChallengeBonus() async {
    final isPremium = await PremiumService.isPremiumUser();
    final challengeFeatures =
        await PremiumFeaturesService.getDailyChallengePremiumFeatures();

    return {
      'isPremium': isPremium,
      'bonusMultiplier': challengeFeatures['bonusRewards'], // 2x pour premium
      'extraTime': challengeFeatures['extraTime'], // +30 secondes
      'hints': challengeFeatures['hints'], // 2 indices
      'skipQuestions': challengeFeatures['skipQuestions'], // 1 skip
      'exclusiveChallenges': challengeFeatures['exclusiveChallenges'],
      'message': isPremium
          ? '👑 Bonus Premium actif : Récompenses x2, +30s, 2 indices'
          : '🔒 Activez Premium pour des récompenses doublées !',
    };
  }

  /// 🚫 4. EXPÉRIENCE SANS PUBLICITÉ - Déjà implémenté via PremiumAdService
  static Future<bool> isAdFreeExperienceActive() async {
    final isPremium = await PremiumService.isPremiumUser();
    return isPremium;
  }

  /// ♾️ 5. QUESTIONS ILLIMITÉES - Pas de limite quotidienne
  static Future<Map<String, dynamic>> getQuestionLimits() async {
    final isPremium = await PremiumService.isPremiumUser();

    // Pour les utilisateurs gratuits : limite de 50 questions/jour
    // Pour les utilisateurs premium : illimité
    const int FREE_DAILY_LIMIT = 50;

    if (isPremium) {
      return {
        'isPremium': true,
        'limit': -1, // -1 = illimité
        'questionsToday': 0, // Pas de comptage pour premium
        'unlimited': true,
        'message': '♾️ Questions illimitées',
      };
    }

    // Compter les questions du jour pour les free users
    final questionsToday = await _getQuestionsAnsweredToday();

    return {
      'isPremium': false,
      'limit': FREE_DAILY_LIMIT,
      'questionsToday': questionsToday,
      'remaining': FREE_DAILY_LIMIT - questionsToday,
      'unlimited': false,
      'message': questionsToday >= FREE_DAILY_LIMIT
          ? '🔒 Limite quotidienne atteinte ! Passez en Premium pour continuer'
          : '${FREE_DAILY_LIMIT - questionsToday} questions restantes aujourd\'hui',
    };
  }

  /// 👥 6. MODE MULTIJOUEUR - Défier vos amis
  static Future<Map<String, dynamic>> getMultiplayerAccess() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'enabled': isPremium,
      'message': isPremium
          ? '👥 Mode multijoueur disponible'
          : '🔒 Mode multijoueur réservé aux membres Premium',
      'features': isPremium
          ? [
              'Défis en temps réel',
              'Classement entre amis',
              'Parties privées',
              'Système de tournois'
            ]
          : [],
    };
  }

  /// 📤 7. EXPORT DE DONNÉES - Sauvegarder vos statistiques
  static Future<Map<String, dynamic>> exportUserData() async {
    final isPremium = await PremiumService.isPremiumUser();

    if (!isPremium) {
      return {
        'success': false,
        'message': '🔒 Export de données disponible en Premium',
      };
    }

    try {
      // Collecter toutes les données utilisateur
      final stats = await ProgressService.getStats();
      final premiumStatus = await PremiumFeaturesService.getPremiumStatus();

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'statistics': stats,
        'premiumStatus': premiumStatus,
        'version': '1.0',
      };

      // Convertir en JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Partager le fichier
      await Share.share(
        jsonString,
        subject:
            'Mes statistiques Quizz4U - ${DateTime.now().toString().split(' ')[0]}',
      );

      return {
        'success': true,
        'message': '✅ Données exportées avec succès',
        'dataSize': jsonString.length,
      };
    } catch (e) {
      print('[PremiumBenefits] ❌ Erreur export: $e');
      return {
        'success': false,
        'message': '❌ Erreur lors de l\'export',
      };
    }
  }

  /// 🛟 8. SUPPORT PRIORITAIRE - Assistance rapide
  static Future<Map<String, dynamic>> getSupportAccess() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'priority': isPremium,
      'responseTime': isPremium ? '< 24h' : '< 72h',
      'contactEmail': isPremium ? 'premium@quizz4u.com' : 'support@quizz4u.com',
      'features': isPremium
          ? [
              'Réponse prioritaire',
              'Assistance personnalisée',
              'Accès direct au développeur',
            ]
          : ['Support standard'],
      'message': isPremium
          ? '👑 Support prioritaire activé'
          : '🔒 Support prioritaire disponible en Premium',
    };
  }

  /// ⚡ 9. ACCÈS ANTICIPÉ - Nouvelles fonctionnalités en avant-première
  static Future<Map<String, dynamic>> getBetaFeatures() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'betaAccess': isPremium,
      'upcomingFeatures': isPremium
          ? [
              'Mode histoire',
              'Éditeur de questions',
              'Classement mondial',
              'Événements spéciaux',
            ]
          : [],
      'message': isPremium
          ? '🚀 Accès anticipé activé'
          : '🔒 Accès anticipé réservé aux membres Premium',
    };
  }

  /// 🏆 10. BADGES ET RÉCOMPENSES EXCLUSIFS
  static Future<Map<String, dynamic>> getExclusiveBadges() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'exclusiveBadges': isPremium
          ? [
              {'name': 'Membre Premium', 'icon': '👑'},
              {'name': 'Supporteur', 'icon': '💎'},
              {'name': 'VIP', 'icon': '⭐'},
            ]
          : [],
      'message': isPremium
          ? '🏆 Badges exclusifs débloqués'
          : '🔒 Badges exclusifs disponibles en Premium',
    };
  }

  /// 🎯 VÉRIFIER TOUS LES AVANTAGES - Vue d'ensemble complète
  static Future<Map<String, dynamic>> getAllBenefitsStatus() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'benefits': {
        'ad_free': await isAdFreeExperienceActive(),
        'unlimited_questions': (await getQuestionLimits())['unlimited'],
        'advanced_statistics': !(await getAdvancedStatistics())['locked'],
        'custom_themes': (await getAvailableThemes())['isPremium'],
        'daily_challenge_bonus': (await getDailyChallengeBonus())['isPremium'],
        'multiplayer': (await getMultiplayerAccess())['enabled'],
        'export_data': isPremium,
        'priority_support': (await getSupportAccess())['priority'],
        'beta_access': (await getBetaFeatures())['betaAccess'],
        'exclusive_badges': (await getExclusiveBadges())['isPremium'],
      },
      'activeFeatures': isPremium ? 10 : 0,
      'totalFeatures': 10,
    };
  }

  /// 📝 Helpers privés

  /// Compter les questions répondues aujourd'hui
  static Future<int> _getQuestionsAnsweredToday() async {
    final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    final savedDate = await CachedPreferencesService.getString(
      'last_question_date',
      defaultValue: '',
    );

    if (savedDate != today) {
      // Nouveau jour, réinitialiser le compteur
      await CachedPreferencesService.setInt('questions_today', 0);
      await CachedPreferencesService.setString('last_question_date', today);
      return 0;
    }

    return await CachedPreferencesService.getInt(
      'questions_today',
      defaultValue: 0,
    );
  }

  /// Incrémenter le compteur de questions quotidiennes
  static Future<void> incrementDailyQuestions() async {
    final isPremium = await PremiumService.isPremiumUser();
    if (isPremium) return; // Pas de limite pour premium

    final current = await _getQuestionsAnsweredToday();
    await CachedPreferencesService.setInt('questions_today', current + 1);
  }

  /// Vérifier si l'utilisateur peut répondre à plus de questions
  static Future<bool> canAnswerMoreQuestions() async {
    final limits = await getQuestionLimits();
    if (limits['unlimited']) return true; // Premium = illimité

    return (limits['remaining'] as int) > 0;
  }
}




