import 'ad_service.dart';
import 'premium_service.dart';

/// Service centralisé pour gérer les publicités avec vérification premium
/// Toutes les publicités passent par ce service pour s'assurer qu'elles ne s'affichent pas pour les utilisateurs premium
class PremiumAdService {
  /// Afficher une publicité interstitielle (seulement si pas premium)
  static Future<void> showInterstitialAd({String? context}) async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showInterstitialAd();
        print('[PremiumAdService] ✅ Publicité interstitielle affichée');
      } else {
        print(
            '[PremiumAdService] 🚫 Utilisateur premium - aucune publicité interstitielle');
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité interstitielle: $e');
    }
  }

  /// Afficher une publicité interstitielle stratégique (seulement si pas premium)
  static Future<void> showStrategicInterstitial() async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showStrategicInterstitial();
        print('[PremiumAdService] ✅ Publicité stratégique affichée');
      } else {
        print(
            '[PremiumAdService] 🚫 Utilisateur premium - aucune publicité stratégique');
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité stratégique: $e');
    }
  }

  /// Afficher une publicité interstitielle de fin de jeu (seulement si pas premium)
  static Future<void> showEndGameInterstitial() async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showEndGameInterstitial();
        print('[PremiumAdService] ✅ Publicité fin de jeu affichée');
      } else {
        print(
            '[PremiumAdService] 🚫 Utilisateur premium - aucune publicité fin de jeu');
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité fin de jeu: $e');
    }
  }

  /// Afficher une publicité interstitielle de changement de catégorie (seulement si pas premium)
  static Future<void> showCategoryChangeInterstitial() async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showCategoryChangeInterstitial();
        print('[PremiumAdService] ✅ Publicité changement catégorie affichée');
      } else {
        print(
            '[PremiumAdService] 🚫 Utilisateur premium - aucune publicité changement catégorie');
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité changement catégorie: $e');
    }
  }

  /// Afficher une publicité interstitielle de série (seulement si pas premium)
  static Future<void> showStreakInterstitial() async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showStreakInterstitial();
        print('[PremiumAdService] ✅ Publicité série affichée');
      } else {
        print(
            '[PremiumAdService] 🚫 Utilisateur premium - aucune publicité série');
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur publicité série: $e');
    }
  }

  /// Créer une bannière publicitaire (seulement si pas premium)
  static Future<dynamic> createBannerAd() async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        final bannerAd = await AdService.createBannerAd();
        print('[PremiumAdService] ✅ Bannière publicitaire créée');
        return bannerAd;
      } else {
        print(
            '[PremiumAdService] 🚫 Utilisateur premium - aucune bannière publicitaire');
        return null;
      }
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur création bannière: $e');
      return null;
    }
  }

  /// Afficher une publicité récompensée avec bonus XP (seulement si pas premium)
  static Future<void> showRewardedAdForXPBonus({
    required Function(int) onRewarded,
  }) async {
    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (!isPremium) {
        await AdService.showRewardedAdForXPBonus(onRewarded: onRewarded);
        print('[PremiumAdService] ✅ Publicité récompensée affichée');
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
    try {
      final isPremium = await PremiumService.isPremiumUser();
      return !isPremium;
    } catch (e) {
      print('[PremiumAdService] ❌ Erreur vérification statut premium: $e');
      return true; // Par défaut, permettre les publicités en cas d'erreur
    }
  }

  /// Obtenir le statut premium de l'utilisateur
  static Future<bool> isPremiumUser() async {
    return await PremiumService.isPremiumUser();
  }

  /// Obtenir des statistiques sur les publicités (pour debug)
  static Future<Map<String, dynamic>> getAdStats() async {
    final isPremium = await PremiumService.isPremiumUser();
    return {
      'isPremium': isPremium,
      'canShowAds': !isPremium,
      'premiumActivationDate': await PremiumService.getPremiumActivationDate(),
    };
  }
}









