// import 'package:shared_preferences/shared_preferences.dart'; // Unused import
import 'premium_service.dart';

class PremiumFeaturesService {
  // Fonctionnalités premium disponibles
  static const Map<String, Map<String, dynamic>> premiumFeatures = {
    'unlimited_questions': {
      'title': 'Questions Illimitées',
      'description': 'Accès à toutes les questions sans limite',
      'icon': '♾️',
      'benefit': 'Plus jamais de questions épuisées',
    },
    'advanced_statistics': {
      'title': 'Statistiques Avancées',
      'description': 'Analyses détaillées de vos performances',
      'icon': '📊',
      'benefit': 'Comprenez vos points forts et faibles',
    },
    'custom_themes': {
      'title': 'Thèmes Personnalisés',
      'description': 'Choisissez parmi 10+ thèmes colorés',
      'icon': '🎨',
      'benefit': 'Personnalisez votre expérience de jeu',
    },
    'priority_support': {
      'title': 'Support Prioritaire',
      'description': 'Aide rapide et dédiée',
      'icon': '🛟',
      'benefit': 'Résolution rapide de vos problèmes',
    },
    'ad_free_experience': {
      'title': 'Expérience Sans Pub',
      'description': 'Jouez sans interruption publicitaire',
      'icon': '🚫📺',
      'benefit': 'Concentration totale sur le jeu',
    },
    'exclusive_challenges': {
      'title': 'Défis Exclusifs',
      'description': 'Accès aux défis premium quotidiens',
      'icon': '⭐',
      'benefit': 'Défis spéciaux avec récompenses bonus',
    },
    'export_data': {
      'title': 'Export de Données',
      'description': 'Exportez vos statistiques et progrès',
      'icon': '📤',
      'benefit': 'Gardez une trace de vos performances',
    },
    'multiplayer_mode': {
      'title': 'Mode Multijoueur',
      'description': 'Défiez vos amis en temps réel',
      'icon': '👥',
      'benefit': 'Compétition amicale et fun',
    },
  };

  // Vérifier si une fonctionnalité premium est disponible
  static Future<bool> hasFeature(String featureKey) async {
    final isPremium = await PremiumService.isPremiumUser();
    return isPremium;
  }

  // Obtenir toutes les fonctionnalités premium
  static Map<String, Map<String, dynamic>> getAllFeatures() {
    return premiumFeatures;
  }

  // Obtenir les fonctionnalités premium avec leur statut
  static Future<List<Map<String, dynamic>>> getFeaturesWithStatus() async {
    final isPremium = await PremiumService.isPremiumUser();
    final features = <Map<String, dynamic>>[];

    for (final entry in premiumFeatures.entries) {
      final feature = Map<String, dynamic>.from(entry.value);
      feature['key'] = entry.key;
      feature['isAvailable'] = isPremium;
      features.add(feature);
    }

    return features;
  }

  // Obtenir les avantages premium pour l'affichage
  static Future<List<String>> getPremiumBenefits() async {
    return [
      '🎯 Questions illimitées dans toutes les catégories',
      '📊 Statistiques détaillées et analyses de performance',
      '🎨 10+ thèmes personnalisés pour personnaliser votre jeu',
      '🚫 Expérience 100% sans publicité',
      '⭐ Défis quotidiens exclusifs avec récompenses bonus',
      '👥 Mode multijoueur pour défier vos amis',
      '🛟 Support prioritaire 24/7',
      '📤 Export de vos données et statistiques',
      '⚡ Accès anticipé aux nouvelles fonctionnalités',
      '🏆 Badges et récompenses exclusifs',
    ];
  }

  // Vérifier les fonctionnalités premium pour les défis quotidiens
  static Future<Map<String, dynamic>> getDailyChallengePremiumFeatures() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'bonusRewards': isPremium ? 2.0 : 1.0, // Double récompenses
      'extraTime': isPremium ? 30 : 0, // 30 secondes bonus
      'hints': isPremium ? 2 : 0, // 2 indices par défi
      'skipQuestions': isPremium ? 1 : 0, // 1 question sautée par défi
      'exclusiveChallenges': isPremium, // Défis exclusifs
    };
  }

  // Vérifier les fonctionnalités premium pour les statistiques
  static Future<Map<String, dynamic>> getStatisticsPremiumFeatures() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'detailedAnalytics': isPremium,
      'performanceInsights': isPremium,
      'exportData': isPremium,
      'historicalData': isPremium ? 365 : 30, // Jours de données
      'comparisonTools': isPremium,
    };
  }

  // Vérifier les fonctionnalités premium pour les thèmes
  static Future<Map<String, dynamic>> getThemesPremiumFeatures() async {
    final isPremium = await PremiumService.isPremiumUser();

    return {
      'isPremium': isPremium,
      'availableThemes': isPremium
          ? [
              'Classique',
              'Sombre',
              'Neon',
              'Nature',
              'Ocean',
              'Sunset',
              'Galaxy',
              'Forest',
              'Candy',
              'Minimalist',
              'Retro',
              'Cyber'
            ]
          : ['Classique', 'Sombre'],
      'customColors': isPremium,
      'animatedThemes': isPremium,
    };
  }

  // Obtenir le message d'upgrade premium
  static Future<String> getUpgradeMessage(String featureName) async {
    return '🔒 Cette fonctionnalité est disponible avec la version premium.\n'
        'Débloquez $featureName et bien plus encore !';
  }

  // Vérifier si l'utilisateur peut accéder à une fonctionnalité
  static Future<bool> canAccessFeature(String featureKey) async {
    // Certaines fonctionnalités sont toujours disponibles
    final alwaysAvailableFeatures = ['basic_quiz', 'basic_statistics'];

    if (alwaysAvailableFeatures.contains(featureKey)) {
      return true;
    }

    return await hasFeature(featureKey);
  }

  // Obtenir le statut premium pour l'affichage
  static Future<Map<String, dynamic>> getPremiumStatus() async {
    final isPremium = await PremiumService.isPremiumUser();
    final activationDate = await PremiumService.getPremiumActivationDate();

    return {
      'isPremium': isPremium,
      'activationDate': activationDate,
      'featuresUnlocked': isPremium ? premiumFeatures.length : 0,
      'totalFeatures': premiumFeatures.length,
      'premiumLevel': isPremium ? 'Premium' : 'Gratuit',
      'benefits': await getPremiumBenefits(),
    };
  }

  // Simuler l'activation premium (pour les tests)
  static Future<void> simulatePremiumActivation() async {
    await PremiumService.activatePremium();
    print('[PremiumFeaturesService] 🎉 Mode premium simulé activé');
  }

  // Obtenir les fonctionnalités populaires
  static List<String> getPopularFeatures() {
    return [
      'ad_free_experience',
      'unlimited_questions',
      'custom_themes',
      'advanced_statistics',
      'exclusive_challenges',
    ];
  }

  // Obtenir les fonctionnalités récentes ajoutées
  static List<String> getRecentFeatures() {
    return [
      'multiplayer_mode',
      'export_data',
      'custom_themes',
      'exclusive_challenges',
    ];
  }
}
