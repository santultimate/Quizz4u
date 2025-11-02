import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class PowerUpService {
  static const String _powerupsKey = 'available_powerups';
  static const String _powerupUsageKey = 'powerup_usage_stats';

  // Types de power-ups disponibles
  static const Map<String, Map<String, dynamic>> _powerupTypes = {
    'skip_question': {
      'name': 'Passer Question',
      'description': 'Passe automatiquement la question actuelle',
      'icon': '⏭️',
      'cost': 50, // Coins ou XP
      'rarity': 'common',
      'maxUses': 3,
    },
    'hint': {
      'name': 'Indice',
      'description': 'Révèle une lettre de la bonne réponse',
      'icon': '💡',
      'cost': 30,
      'rarity': 'common',
      'maxUses': 5,
    },
    'eliminate_2': {
      'name': 'Éliminer 2',
      'description': 'Élimine 2 mauvaises réponses',
      'icon': '🎯',
      'cost': 40,
      'rarity': 'uncommon',
      'maxUses': 3,
    },
    'time_boost': {
      'name': 'Boost Temps',
      'description': 'Ajoute 30 secondes au timer',
      'icon': '⏰',
      'cost': 35,
      'rarity': 'common',
      'maxUses': 4,
    },
    'double_points': {
      'name': 'Points Doublés',
      'description': 'Double les points pour la question suivante',
      'icon': '💰',
      'cost': 60,
      'rarity': 'rare',
      'maxUses': 2,
    },
    'perfect_answer': {
      'name': 'Réponse Parfaite',
      'description': 'Révèle la bonne réponse',
      'icon': '⭐',
      'cost': 100,
      'rarity': 'legendary',
      'maxUses': 1,
    },
    'lucky_guess': {
      'name': 'Chance Bonus',
      'description': '50% de chance de bonne réponse même si faux',
      'icon': '🍀',
      'cost': 80,
      'rarity': 'rare',
      'maxUses': 2,
    },
    'streak_protector': {
      'name': 'Protecteur de Série',
      'description': 'Protège votre série même en cas de mauvaise réponse',
      'icon': '🛡️',
      'cost': 120,
      'rarity': 'legendary',
      'maxUses': 1,
    },
  };

  // Obtenir les power-ups disponibles
  static Future<List<Map<String, dynamic>>> getAvailablePowerUps() async {
    final prefs = await SharedPreferences.getInstance();
    final powerupsData = prefs.getString(_powerupsKey) ?? '{}';

    // Si pas de données, initialiser avec des power-ups par défaut
    if (powerupsData == '{}') {
      await _initializeDefaultPowerUps();
    }

    final powerupsMap = Map<String, dynamic>.from(
        // TODO: Décoder le JSON des power-ups
        _powerupTypes.map((key, value) => MapEntry(key, {
              ...value,
              'id': key,
              'available': 0, // TODO: Récupérer depuis les données stockées
            })));

    return powerupsMap.values.cast<Map<String, dynamic>>().toList();
  }

  // Utiliser un power-up
  static Future<bool> usePowerUp(
      String powerUpId, Map<String, dynamic> context) async {
    final powerUp = _powerupTypes[powerUpId];
    if (powerUp == null) return false;

    final prefs = await SharedPreferences.getInstance();
    // final powerupsData = prefs.getString(_powerupsKey) ?? '{}'; // Unused
    // TODO: Vérifier si le power-up est disponible
    // TODO: Décrémenter le nombre d'utilisations

    // Enregistrer l'utilisation
    await _recordPowerUpUsage(powerUpId, context);

    print('[PowerUpService] 🎮 Power-up utilisé: ${powerUp['name']}');
    return true;
  }

  // Acheter un power-up
  static Future<bool> buyPowerUp(String powerUpId, int cost) async {
    // TODO: Vérifier si l'utilisateur a assez de coins/XP
    // TODO: Débiter le coût
    // TODO: Ajouter le power-up à l'inventaire

    print(
        '[PowerUpService] 💰 Power-up acheté: ${_powerupTypes[powerUpId]?['name']}');
    return true;
  }

  // Obtenir un power-up gratuit (récompense)
  static Future<void> rewardPowerUp(String powerUpId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    // final powerupsData = prefs.getString(_powerupsKey) ?? '{}'; // Unused
    // TODO: Ajouter le power-up à l'inventaire

    print(
        '[PowerUpService] 🎁 Power-up reçu: ${_powerupTypes[powerUpId]?['name']} x$quantity');
  }

  // Générateur de power-ups aléatoires
  static Future<String?> getRandomPowerUpReward() async {
    final random = Random();
    final powerupList = _powerupTypes.entries.toList();

    // Pondération par rareté
    final weights = powerupList.map((entry) {
      switch (entry.value['rarity']) {
        case 'common':
          return 50;
        case 'uncommon':
          return 30;
        case 'rare':
          return 15;
        case 'legendary':
          return 5;
        default:
          return 10;
      }
    }).toList();

    final totalWeight = weights.reduce((a, b) => a + b);
    var randomValue = random.nextInt(totalWeight);

    for (int i = 0; i < powerupList.length; i++) {
      randomValue -= weights[i];
      if (randomValue <= 0) {
        return powerupList[i].key;
      }
    }

    return powerupList.first.key;
  }

  // Initialiser les power-ups par défaut
  static Future<void> _initializeDefaultPowerUps() async {
    final prefs = await SharedPreferences.getInstance();
    // final defaultPowerUps = { // Unused - kept for future implementation
    //   'skip_question': 1,
    //   'hint': 2,
    //   'time_boost': 1,
    // };

    // TODO: Sauvegarder les power-ups par défaut
    await prefs.setString(_powerupsKey, '{}'); // Placeholder
  }

  // Enregistrer l'utilisation d'un power-up
  static Future<void> _recordPowerUpUsage(
      String powerUpId, Map<String, dynamic> context) async {
    final prefs = await SharedPreferences.getInstance();
    // final usageData = prefs.getString(_powerupUsageKey) ?? '{}'; // Unused
    // TODO: Enregistrer l'utilisation avec le contexte
  }

  // Obtenir les statistiques d'utilisation des power-ups
  static Future<Map<String, dynamic>> getPowerUpStats() async {
    final prefs = await SharedPreferences.getInstance();
    // final usageData = prefs.getString(_powerupUsageKey) ?? '{}'; // Unused

    return {
      'totalUsed': 0, // TODO: Calculer depuis les données
      'mostUsed': 'hint', // TODO: Trouver le plus utilisé
      'successRate': 0.85, // TODO: Calculer le taux de succès
    };
  }

  // Vérifier si un power-up peut être utilisé
  static Future<bool> canUsePowerUp(String powerUpId) async {
    final powerUp = _powerupTypes[powerUpId];
    if (powerUp == null) return false;

    final prefs = await SharedPreferences.getInstance();
    // final powerupsData = prefs.getString(_powerupsKey) ?? '{}'; // Unused
    // TODO: Vérifier la disponibilité

    return true; // Placeholder
  }

  // Obtenir les effets d'un power-up
  static Map<String, dynamic> getPowerUpEffect(
      String powerUpId, Map<String, dynamic> context) {
    final powerUp = _powerupTypes[powerUpId];
    if (powerUp == null) return {};

    switch (powerUpId) {
      case 'skip_question':
        return {
          'action': 'skip',
          'message': 'Question passée !',
        };
      case 'hint':
        return {
          'action': 'hint',
          'message': 'Indice révélé !',
          'hint': _generateHint(context['correctAnswer']),
        };
      case 'eliminate_2':
        return {
          'action': 'eliminate',
          'message': '2 réponses éliminées !',
          'eliminatedAnswers': _eliminateTwoWrongAnswers(context['answers']),
        };
      case 'time_boost':
        return {
          'action': 'time_boost',
          'message': '+30 secondes ajoutées !',
          'timeAdded': 30,
        };
      case 'double_points':
        return {
          'action': 'double_points',
          'message': 'Points doublés pour la prochaine question !',
          'multiplier': 2,
        };
      case 'perfect_answer':
        return {
          'action': 'reveal',
          'message': 'Réponse parfaite révélée !',
          'correctAnswer': context['correctAnswer'],
        };
      case 'lucky_guess':
        return {
          'action': 'lucky_guess',
          'message': 'Chance bonus activée !',
          'successChance': 0.5,
        };
      case 'streak_protector':
        return {
          'action': 'protect_streak',
          'message': 'Série protégée !',
        };
      default:
        return {};
    }
  }

  // Générer un indice
  static String _generateHint(String correctAnswer) {
    if (correctAnswer.length <= 2) return correctAnswer;

    final random = Random();
    final revealedIndex = random.nextInt(correctAnswer.length);
    var hint = '';

    for (int i = 0; i < correctAnswer.length; i++) {
      if (i == revealedIndex) {
        hint += correctAnswer[i];
      } else {
        hint += '_';
      }
    }

    return hint;
  }

  // Éliminer deux mauvaises réponses
  static List<String> _eliminateTwoWrongAnswers(Map<String, bool> answers) {
    final wrongAnswers = answers.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    wrongAnswers.shuffle();
    return wrongAnswers.take(2).toList();
  }
}
