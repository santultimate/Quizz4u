import 'dart:math';
import 'ad_policy.dart';
import 'ad_service.dart';
import 'premium_service.dart';

// Types de publicités contextuelles
enum AdContext {
  levelUp,
  badgeEarned,
  quizComplete,
  streakMilestone,
  performanceBonus,
  categoryComplete,
}

class SmartAdStrategy {
  static int _questionsSinceLastAd = 0;
  static int _sessionsToday = 0;
  static DateTime? _lastAdTime;
  static final Random _random = Random();

  // Configuration de la stratégie intelligente (optimisée pour UX)
  static const int MIN_QUESTIONS_BETWEEN_ADS =
      10; // Minimum 10 questions entre les pubs (↑ doublé)
  static const int MAX_QUESTIONS_BETWEEN_ADS =
      15; // Maximum 15 questions entre les pubs (↑ doublé)
  static const int DAILY_AD_LIMIT = 8; // Maximum 8 pubs par jour (↓ réduit)
  static const int MIN_TIME_BETWEEN_ADS =
      60; // 60 secondes minimum entre les pubs (↑ doublé)

  /// Fréquence + politique globale (premium, toggle pubs, plateforme).
  static Future<bool> canShowAd({AdContext? context}) async {
    if (!await AdPolicy.canShow(AdFormat.interstitial)) {
      return false;
    }

    final now = DateTime.now();

    // Vérifier la limite quotidienne
    if (_sessionsToday >= DAILY_AD_LIMIT) {
      print(
          '[SmartAdStrategy] 📊 Limite quotidienne atteinte: $_sessionsToday/$DAILY_AD_LIMIT');
      return false;
    }

    // Vérifier le temps minimum entre les publicités
    if (_lastAdTime != null) {
      final timeSinceLastAd = now.difference(_lastAdTime!).inSeconds;
      if (timeSinceLastAd < MIN_TIME_BETWEEN_ADS) {
        print(
            '[SmartAdStrategy] ⏰ Trop tôt pour une nouvelle pub: ${timeSinceLastAd}s/$MIN_TIME_BETWEEN_ADS');
        return false;
      }
    }

    // Vérifier le nombre de questions depuis la dernière pub
    if (_questionsSinceLastAd < MIN_QUESTIONS_BETWEEN_ADS) {
      print(
          '[SmartAdStrategy] 📝 Pas assez de questions: $_questionsSinceLastAd/$MIN_QUESTIONS_BETWEEN_ADS');
      return false;
    }

    // Bonus pour les contextes spéciaux
    if (context != null) {
      return _shouldShowContextualAd(context);
    }

    return true;
  }

  // Déterminer si une publicité contextuelle doit être affichée
  static bool _shouldShowContextualAd(AdContext context) {
    switch (context) {
      case AdContext.levelUp:
        return _random.nextDouble() < 0.8; // 80% de chance
      case AdContext.badgeEarned:
        return _random.nextDouble() < 0.6; // 60% de chance
      case AdContext.quizComplete:
        return _random.nextDouble() < 0.7; // 70% de chance
      case AdContext.streakMilestone:
        return _random.nextDouble() < 0.9; // 90% de chance
      case AdContext.performanceBonus:
        return _random.nextDouble() < 0.5; // 50% de chance
      case AdContext.categoryComplete:
        return _random.nextDouble() < 0.6; // 60% de chance
    }
  }

  // Afficher une publicité intelligente
  static Future<void> showSmartAd({AdContext? context}) async {
    if (!await canShowAd(context: context)) {
      print(
          '[SmartAdStrategy] 🚫 Publicité refusée par la stratégie intelligente');
      return;
    }

    try {
      // Choisir le type de publicité selon le contexte
      if (context != null) {
        await _showContextualAd(context);
      } else {
        await _showRegularAd();
      }

      // Mettre à jour les compteurs
      _questionsSinceLastAd = 0;
      _sessionsToday++;
      _lastAdTime = DateTime.now();

      print('[SmartAdStrategy] ✅ Publicité affichée avec succès');
    } catch (e) {
      print('[SmartAdStrategy] ❌ Erreur affichage publicité: $e');
    }
  }

  // Afficher une publicité contextuelle (toujours via showInterstitialAd — pas de récursion)
  static Future<void> _showContextualAd(AdContext context) async {
    switch (context) {
      case AdContext.levelUp:
        print('[SmartAdStrategy] 🎉 Publicité de niveau supérieur');
        break;
      case AdContext.badgeEarned:
        print('[SmartAdStrategy] 🏆 Publicité de badge obtenu');
        break;
      case AdContext.quizComplete:
        print('[SmartAdStrategy] 🎯 Publicité de fin de quiz');
        break;
      case AdContext.streakMilestone:
        print('[SmartAdStrategy] 🔥 Publicité de série');
        break;
      case AdContext.performanceBonus:
        print('[SmartAdStrategy] ⭐ Publicité de performance');
        break;
      case AdContext.categoryComplete:
        print('[SmartAdStrategy] 📚 Publicité de catégorie complétée');
        break;
    }
    await AdService.showInterstitialAd();
  }

  // Afficher une publicité régulière
  static Future<void> _showRegularAd() async {
    // Choisir aléatoirement entre interstitielle et récompensée
    if (_random.nextDouble() < 0.7) {
      print('[SmartAdStrategy] 📺 Publicité interstitielle régulière');
      await AdService.showInterstitialAd();
    } else {
      print('[SmartAdStrategy] 🎁 Publicité récompensée');
      await AdService.showRewardedAdForXPBonus(
        onRewarded: (bonusXP) {
          print('[SmartAdStrategy] 🎁 Bonus XP obtenu: +$bonusXP');
        },
      );
    }
  }

  // Incrémenter le compteur de questions
  static void incrementQuestionCount() {
    _questionsSinceLastAd++;
    print(
        '[SmartAdStrategy] 📊 Questions depuis dernière pub: $_questionsSinceLastAd');
  }

  // Réinitialiser les compteurs (appelé au début d'une nouvelle session)
  static void resetSession() {
    _questionsSinceLastAd = 0;
    print('[SmartAdStrategy] 🔄 Session réinitialisée');
  }

  // Réinitialiser les compteurs quotidiens (appelé à minuit)
  static void resetDailyCounters() {
    _sessionsToday = 0;
    _lastAdTime = null;
    print('[SmartAdStrategy] 📅 Compteurs quotidiens réinitialisés');
  }

  // Obtenir les statistiques de la stratégie
  static Map<String, dynamic> getStats() {
    return {
      'questionsSinceLastAd': _questionsSinceLastAd,
      'sessionsToday': _sessionsToday,
      'lastAdTime': _lastAdTime?.toIso8601String(),
      'dailyLimit': DAILY_AD_LIMIT,
      'minQuestionsBetweenAds': MIN_QUESTIONS_BETWEEN_ADS,
    };
  }

  // Vérifier si l'utilisateur est un utilisateur premium
  static Future<bool> isPremiumUser() async {
    return PremiumService.isPremiumUser();
  }

  // Ajuster la stratégie pour les utilisateurs premium
  static Future<void> adjustForPremium() async {
    if (await isPremiumUser()) {
      // Réduire drastiquement les publicités pour les utilisateurs premium
      _sessionsToday = (_sessionsToday * 0.1).round(); // 90% de réduction
      print('[SmartAdStrategy] 👑 Stratégie ajustée pour utilisateur premium');
    }
  }

  // Suggérer une publicité récompensée
  static Future<void> suggestRewardedAd({
    required String reason,
    required Function(int) onRewarded,
  }) async {
    print('[SmartAdStrategy] 💡 Suggestion de publicité récompensée: $reason');

    try {
      await AdService.showRewardedAdForXPBonus(
        onRewarded: onRewarded,
      );
    } catch (e) {
      print('[SmartAdStrategy] ❌ Erreur publicité récompensée: $e');
    }
  }

  // Afficher une publicité de récompense pour bonus XP
  static Future<void> showXPBonusAd({
    required Function(int) onRewarded,
  }) async {
    await suggestRewardedAd(
      reason: 'Bonus XP',
      onRewarded: onRewarded,
    );
  }

  // Afficher une publicité pour continuer après échec
  static Future<void> showContinueAd({
    required Function() onRewarded,
  }) async {
    await AdService.showRewardedAdForContinue(
      onRewarded: onRewarded,
    );
  }
}
