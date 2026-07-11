import 'ad_policy.dart';
import 'ad_service.dart';
import 'premium_service.dart';

/// Façade fine : délègue à [AdService] (qui applique déjà [AdPolicy]).
/// Conservée pour compatibilité avec les anciens appels.
class PremiumAdService {
  /// Afficher une publicité interstitielle (seulement si autorisé)
  static Future<void> showInterstitialAd({String? context}) async {
    try {
      await AdService.showInterstitialAd();
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité interstitielle: $e');
    }
  }

  /// Afficher une publicité interstitielle stratégique
  static Future<void> showStrategicInterstitial() async {
    try {
      await AdService.showStrategicInterstitial();
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité stratégique: $e');
    }
  }

  /// Afficher une publicité interstitielle de fin de jeu
  static Future<void> showEndGameInterstitial() async {
    try {
      await AdService.showEndGameInterstitial();
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité fin de jeu: $e');
    }
  }

  /// Afficher une publicité interstitielle de changement de catégorie
  static Future<void> showCategoryChangeInterstitial() async {
    try {
      await AdService.showCategoryChangeInterstitial();
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité changement catégorie: $e');
    }
  }

  /// Afficher une publicité interstitielle de série
  static Future<void> showStreakInterstitial() async {
    try {
      await AdService.showStreakInterstitial();
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité série: $e');
    }
  }

  /// Créer une bannière publicitaire
  static Future<dynamic> createBannerAd() async {
    try {
      return await AdService.createBannerAd();
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur création bannière: $e');
      return null;
    }
  }

  /// Afficher une publicité récompensée avec bonus XP
  static Future<void> showRewardedAdForXPBonus({
    required Function(int) onRewarded,
  }) async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showRewardedAdForXPBonus(onRewarded: onRewarded);
      } else {
        // Utilisateur premium - donner le bonus directement
        const bonusXP = 50;
        onRewarded(bonusXP);
        print(
            '[PremiumAdService] 👑 Bonus premium donné directement: +$bonusXP XP');
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité récompensée: $e');
    }
  }

  /// Vérifier si l'utilisateur peut voir des publicités
  static Future<bool> canShowAds() async {
    return AdPolicy.canShow(AdFormat.interstitial);
  }

  /// Obtenir le statut premium de l'utilisateur
  static Future<bool> isPremiumUser() async {
    return PremiumService.isPremiumUser();
  }

  /// Obtenir des statistiques sur les publicités (pour debug)
  static Future<Map<String, dynamic>> getAdStats() async {
    return AdPolicy.status();
  }
}
