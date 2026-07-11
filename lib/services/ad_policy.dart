import 'dart:io';

import 'premium_service.dart';
import 'settings_service.dart';

/// Formats publicitaires gérés par la politique unique.
enum AdFormat {
  banner,
  interstitial,
  rewarded,
}

/// Point d'entrée unique pour décider si une pub peut s'afficher.
///
/// Règles:
/// - Plateforme mobile uniquement
/// - Premium → aucune pub
/// - `ads_enabled=false` → bloque bannières et interstitiels
/// - Récompensées restent autorisées (opt-in utilisateur) sauf premium
class AdPolicy {
  static Future<bool> canShow(AdFormat format) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }

    try {
      final isPremium = await PremiumService.isPremiumUser();
      if (isPremium) {
        print('[AdPolicy] 🚫 Bloqué (premium) format=$format');
        return false;
      }

      if (format != AdFormat.rewarded) {
        final adsEnabled = await SettingsService.isAdsEnabled();
        if (!adsEnabled) {
          print('[AdPolicy] 🚫 Bloqué (ads désactivées) format=$format');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('[AdPolicy] ⚠️ Erreur politique ads: $e — refus par défaut');
      return false;
    }
  }

  /// Alias pratique pour les pubs forcées (bannière / interstitiel).
  static Future<bool> canShowForcedAds() => canShow(AdFormat.interstitial);

  /// Snapshot debug (premium + toggle + plateforme).
  static Future<Map<String, dynamic>> status() async {
    final isPremium = await PremiumService.isPremiumUser();
    final adsEnabled = await SettingsService.isAdsEnabled();
    final mobile = Platform.isAndroid || Platform.isIOS;
    return {
      'isPremium': isPremium,
      'adsEnabled': adsEnabled,
      'isMobilePlatform': mobile,
      'canShowBanner': await canShow(AdFormat.banner),
      'canShowInterstitial': await canShow(AdFormat.interstitial),
      'canShowRewarded': await canShow(AdFormat.rewarded),
    };
  }
}

