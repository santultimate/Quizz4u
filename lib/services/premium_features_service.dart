import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class PremiumFeaturesService {
  static const String _premiumKey = 'premium_status';
  static const String _trialKey = 'trial_status';
  static const String _conversionKey = 'conversion_events';

  // Fonctionnalités premium avec valeur perçue
  static const Map<String, Map<String, dynamic>> _premiumFeatures = {
    'ad_free': {
      'name': 'Sans Publicités',
      'description': 'Profitez du jeu sans interruption publicitaire',
      'value_score': 9.5,
      'conversion_potential': 0.8,
    },
    'unlimited_questions': {
      'name': 'Questions Illimitées',
      'description': 'Accédez à toutes les questions sans limite',
      'value_score': 8.5,
      'conversion_potential': 0.7,
    },
    'advanced_analytics': {
      'name': 'Analyses Avancées',
      'description': 'Statistiques détaillées et graphiques de progression',
      'value_score': 7.5,
      'conversion_potential': 0.6,
    },
    'custom_themes': {
      'name': 'Thèmes Personnalisés',
      'description': 'Personnalisez l\'apparence de l\'application',
      'value_score': 6.5,
      'conversion_potential': 0.5,
    },
    'priority_support': {
      'name': 'Support Prioritaire',
      'description': 'Assistance rapide et personnalisée',
      'value_score': 6.0,
      'conversion_potential': 0.4,
    },
    'exclusive_badges': {
      'name': 'Badges Exclusifs',
      'description': 'Badges spéciaux uniquement pour les membres premium',
      'value_score': 7.0,
      'conversion_potential': 0.6,
    },
    'offline_mode': {
      'name': 'Mode Hors Ligne',
      'description': 'Jouez même sans connexion internet',
      'value_score': 8.0,
      'conversion_potential': 0.7,
    },
    'ai_tutor': {
      'name': 'Tuteur IA',
      'description': 'Explications personnalisées et conseils d\'apprentissage',
      'value_score': 9.0,
      'conversion_potential': 0.8,
    },
  };

  // Stratégies de conversion
  static const Map<String, Map<String, dynamic>> _conversionStrategies = {
    'friction_reduction': {
      'name': 'Réduction des Frictions',
      'description': 'Simplifier le processus d\'achat',
      'effectiveness': 0.9,
    },
    'social_proof': {
      'name': 'Preuve Sociale',
      'description': 'Afficher les avis et statistiques d\'autres utilisateurs',
      'effectiveness': 0.8,
    },
    'urgency_scarcity': {
      'name': 'Urgence et Rareté',
      'description': 'Offres limitées dans le temps',
      'effectiveness': 0.7,
    },
    'value_demonstration': {
      'name': 'Démonstration de Valeur',
      'description': 'Montrer clairement les bénéfices',
      'effectiveness': 0.85,
    },
    'free_trial': {
      'name': 'Essai Gratuit',
      'description': 'Permettre de tester les fonctionnalités premium',
      'effectiveness': 0.75,
    },
  };

  static Future<void> initialize() async {
    print('[PremiumFeaturesService] 💎 Initialisation du service premium');
    
    // Configurer les fonctionnalités premium
    await _setupPremiumFeatures();
    
    // Initialiser les stratégies de conversion
    await _setupConversionStrategies();
    
    print('[PremiumFeaturesService] ✅ Service premium initialisé');
  }

  static Future<void> _setupPremiumFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Enregistrer les fonctionnalités disponibles
    for (String featureKey in _premiumFeatures.keys) {
      String enabledKey = 'premium_feature_$featureKey';
      if (!prefs.containsKey(enabledKey)) {
        await prefs.setBool(enabledKey, true);
      }
    }
    
    print('[PremiumFeaturesService] 🎯 ${_premiumFeatures.length} fonctionnalités premium configurées');
  }

  static Future<void> _setupConversionStrategies() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Initialiser les événements de conversion
    if (!prefs.containsKey(_conversionKey)) {
      await prefs.setStringList(_conversionKey, []);
    }
    
    print('[PremiumFeaturesService] 🚀 Stratégies de conversion configurées');
  }

  // VÉRIFICATION DU STATUT PREMIUM
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  static Future<bool> isInTrialPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    String trialStart = prefs.getString(_trialKey) ?? '';
    
    if (trialStart.isEmpty) return false;
    
    DateTime startDate = DateTime.parse(trialStart);
    int daysSinceStart = DateTime.now().difference(startDate).inDays;
    
    return daysSinceStart <= 7; // Essai gratuit de 7 jours
  }

  // GESTION DES FONCTIONNALITÉS PREMIUM
  static Future<bool> isFeatureAvailable(String featureKey) async {
    if (await isPremiumUser()) return true;
    if (await isInTrialPeriod()) return true;
    
    // Certaines fonctionnalités peuvent être disponibles gratuitement
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_feature_$featureKey') ?? false;
  }

  static Future<Map<String, dynamic>> getFeatureInfo(String featureKey) async {
    return _premiumFeatures[featureKey] ?? {};
  }

  static Future<List<Map<String, dynamic>>> getAvailableFeatures() async {
    List<Map<String, dynamic>> availableFeatures = [];
    
    for (String featureKey in _premiumFeatures.keys) {
      if (await isFeatureAvailable(featureKey)) {
        Map<String, dynamic> feature = Map.from(_premiumFeatures[featureKey]!);
        feature['key'] = featureKey;
        availableFeatures.add(feature);
      }
    }
    
    return availableFeatures;
  }

  // STRATÉGIES DE CONVERSION INTELLIGENTES
  static Future<Map<String, dynamic>> getOptimalConversionStrategy() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Analyser l'historique de conversion
    List<String> conversionEvents = prefs.getStringList(_conversionKey) ?? [];
    
    // Déterminer la stratégie optimale basée sur l'historique
    Map<String, int> strategyScores = {};
    
    for (String event in conversionEvents) {
      List<String> parts = event.split(',');
      if (parts.length >= 2) {
        String strategy = parts[0];
        strategyScores[strategy] = (strategyScores[strategy] ?? 0) + 1;
      }
    }
    
    // Recommander la stratégie la plus efficace
    String bestStrategy = 'value_demonstration'; // Par défaut
    int bestScore = 0;
    
    for (String strategy in strategyScores.keys) {
      if (strategyScores[strategy]! > bestScore) {
        bestScore = strategyScores[strategy]!;
        bestStrategy = strategy;
      }
    }
    
    return {
      'strategy': bestStrategy,
      'info': _conversionStrategies[bestStrategy] ?? {},
      'score': bestScore,
    };
  }

  // DÉCLENCHEURS DE CONVERSION
  static Future<void> triggerConversionEvent(String eventType, {Map<String, dynamic>? context}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Enregistrer l'événement
    List<String> events = prefs.getStringList(_conversionKey) ?? [];
    String event = '${DateTime.now().millisecondsSinceEpoch},$eventType';
    
    if (context != null) {
      event += ',${context.toString()}';
    }
    
    events.add(event);
    
    // Garder seulement les 100 derniers événements
    if (events.length > 100) {
      events = events.sublist(events.length - 100);
    }
    
    await prefs.setStringList(_conversionKey, events);
    
    print('[PremiumFeaturesService] 🎯 Événement de conversion: $eventType');
  }

  // CALCUL DE LA VALEUR PERÇUE
  static Future<double> calculatePerceivedValue() async {
    double totalValue = 0.0;
    int featureCount = 0;
    
    for (String featureKey in _premiumFeatures.keys) {
      if (await isFeatureAvailable(featureKey)) {
        Map<String, dynamic> feature = _premiumFeatures[featureKey]!;
        totalValue += feature['value_score'] ?? 0.0;
        featureCount++;
      }
    }
    
    return featureCount > 0 ? totalValue / featureCount : 0.0;
  }

  // RECOMMANDATIONS DE PRIX DYNAMIQUES
  static Future<Map<String, dynamic>> getDynamicPricingRecommendation() async {
    double perceivedValue = await calculatePerceivedValue();
    List<String> conversionEvents = await _getRecentConversionEvents();
    
    // Analyser les patterns de conversion
    Map<String, dynamic> analysis = _analyzeConversionPatterns(conversionEvents);
    
    // Recommandation de prix basée sur la valeur perçue
    double basePrice = 4.99; // Prix de base
    double valueMultiplier = perceivedValue / 7.0; // Normaliser sur 7
    double recommendedPrice = basePrice * valueMultiplier;
    
    return {
      'recommended_price': recommendedPrice,
      'perceived_value': perceivedValue,
      'conversion_rate': analysis['conversion_rate'] ?? 0.0,
      'price_sensitivity': analysis['price_sensitivity'] ?? 0.5,
      'optimal_discount': _calculateOptimalDiscount(analysis),
    };
  }

  static Future<List<String>> _getRecentConversionEvents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> events = prefs.getStringList(_conversionKey) ?? [];
    
    // Garder seulement les événements des 30 derniers jours
    DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    List<String> recentEvents = [];
    
    for (String event in events) {
      List<String> parts = event.split(',');
      if (parts.isNotEmpty) {
        int timestamp = int.tryParse(parts[0]) ?? 0;
        DateTime eventDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        
        if (eventDate.isAfter(thirtyDaysAgo)) {
          recentEvents.add(event);
        }
      }
    }
    
    return recentEvents;
  }

  static Map<String, dynamic> _analyzeConversionPatterns(List<String> events) {
    int totalEvents = events.length;
    int conversionEvents = 0;
    List<double> prices = [];
    
    for (String event in events) {
      List<String> parts = event.split(',');
      if (parts.length >= 2) {
        if (parts[1] == 'purchase') {
          conversionEvents++;
        }
        
        if (parts.length >= 3) {
          double price = double.tryParse(parts[2]) ?? 0.0;
          if (price > 0) {
            prices.add(price);
          }
        }
      }
    }
    
    double conversionRate = totalEvents > 0 ? conversionEvents / totalEvents : 0.0;
    double avgPrice = prices.isNotEmpty ? prices.reduce((a, b) => a + b) / prices.length : 0.0;
    
    return {
      'conversion_rate': conversionRate,
      'average_price': avgPrice,
      'price_sensitivity': _calculatePriceSensitivity(prices),
      'total_events': totalEvents,
    };
  }

  static double _calculatePriceSensitivity(List<double> prices) {
    if (prices.length < 2) return 0.5;
    
    // Calculer la variance des prix pour estimer la sensibilité
    double mean = prices.reduce((a, b) => a + b) / prices.length;
    double variance = prices.map((p) => pow(p - mean, 2)).reduce((a, b) => a + b) / prices.length;
    
    return variance / mean; // Coefficient de variation
  }

  static double _calculateOptimalDiscount(Map<String, dynamic> analysis) {
    double conversionRate = analysis['conversion_rate'] ?? 0.0;
    double priceSensitivity = analysis['price_sensitivity'] ?? 0.5;
    
    // Logique de remise optimale
    if (conversionRate < 0.1) {
      return 0.5; // 50% de remise si faible conversion
    } else if (conversionRate < 0.2) {
      return 0.3; // 30% de remise si conversion moyenne
    } else if (priceSensitivity > 1.0) {
      return 0.2; // 20% de remise si sensibilité au prix élevée
    } else {
      return 0.1; // 10% de remise par défaut
    }
  }

  // ANALYTICS ET OPTIMISATION
  static Future<Map<String, dynamic>> getPremiumAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    
    bool isPremium = await isPremiumUser();
    bool inTrial = await isInTrialPeriod();
    double perceivedValue = await calculatePerceivedValue();
    
    List<String> conversionEvents = prefs.getStringList(_conversionKey) ?? [];
    Map<String, dynamic> conversionAnalysis = _analyzeConversionPatterns(conversionEvents);
    
    return {
      'premium_users': isPremium ? 1 : 0,
      'trial_users': inTrial ? 1 : 0,
      'perceived_value': perceivedValue,
      'conversion_rate': conversionAnalysis['conversion_rate'] ?? 0.0,
      'average_price': conversionAnalysis['average_price'] ?? 0.0,
      'total_conversion_events': conversionEvents.length,
      'feature_usage': await _getFeatureUsageStats(),
    };
  }

  static Future<Map<String, int>> _getFeatureUsageStats() async {
    Map<String, int> usage = {};
    
    for (String featureKey in _premiumFeatures.keys) {
      final prefs = await SharedPreferences.getInstance();
      int usageCount = prefs.getInt('feature_usage_$featureKey') ?? 0;
      usage[featureKey] = usageCount;
    }
    
    return usage;
  }

  // RECOMMANDATIONS D'OPTIMISATION
  static Future<List<String>> getOptimizationRecommendations() async {
    List<String> recommendations = [];
    
    Map<String, dynamic> analytics = await getPremiumAnalytics();
    double conversionRate = analytics['conversion_rate'] ?? 0.0;
    double perceivedValue = analytics['perceived_value'] ?? 0.0;
    
    if (conversionRate < 0.15) {
      recommendations.add('Améliorer le taux de conversion premium (actuel: ${(conversionRate * 100).toStringAsFixed(1)}%)');
    }
    
    if (perceivedValue < 7.0) {
      recommendations.add('Augmenter la valeur perçue des fonctionnalités premium (actuel: ${perceivedValue.toStringAsFixed(1)})');
    }
    
    Map<String, int> featureUsage = analytics['feature_usage'] ?? {};
    for (String feature in featureUsage.keys) {
      if (featureUsage[feature]! < 10) {
        recommendations.add('Promouvoir l\'utilisation de la fonctionnalité: $feature');
      }
    }
    
    return recommendations;
  }
}
