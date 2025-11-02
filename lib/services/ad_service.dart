import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'unified_audio_service_optimized.dart'; // ⚡ OPTIMISÉ
import '../config/admob_config.dart';
import 'smart_ad_strategy.dart';

class AdService {
  // IDs AdMob pour Quizz4U - PRODUCTION
  // Application ID: ca-app-pub-7487587531173203~1375704927
  // ✅ Tous les IDs sont en mode production

  static String get bannerAdUnitId {
    return AdMobConfig.getBannerAdUnitId();
  }

  static String get interstitialAdUnitId {
    return AdMobConfig.getInterstitialAdUnitId();
  }

  static String get rewardedAdUnitId {
    return AdMobConfig.getRewardedAdUnitId();
  }

  // Initialiser AdMob
  static Future<void> initialize() async {
    try {
      // Vérifier si on est sur une plateforme mobile
      if (!Platform.isAndroid && !Platform.isIOS) {
        print(
            '[AdService] ⚠️ Plateforme non supportée pour AdMob (Web/Desktop)');
        return;
      }

      await MobileAds.instance.initialize();

      // Configuration production - pas de mode test
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Mode production - pas de testDeviceIds
          testDeviceIds: [], // Aucun appareil de test
        ),
      );

      print('[AdService] ✅ AdMob initialisé avec succès');
      print(
          '[AdService] 📊 Mode: ${AdMobConfig.isTestMode ? "TEST" : "PRODUCTION"}');
      print('[AdService] 📊 Banner ID: $bannerAdUnitId');
      print('[AdService] 📊 Interstitial ID: $interstitialAdUnitId');
      print('[AdService] 📊 Rewarded ID: $rewardedAdUnitId');

      // Charger toutes les publicités au démarrage
      await loadInterstitialAd();
      await loadRewardedAd();
    } catch (e) {
      print('[AdService] ❌ Erreur initialisation AdMob: $e');
    }
  }

  // Créer une bannière
  static Future<BannerAd?> createBannerAd() async {
    try {
      // Vérifier si on est sur une plateforme mobile
      if (!Platform.isAndroid && !Platform.isIOS) {
        print(
            '[AdService] ⚠️ Plateforme non supportée pour les bannières (Web/Desktop)');
        return null;
      }

      print('[AdService] 🔄 Création bannière publicitaire...');

      final ad = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('[AdService] ✅ Bannière chargée avec succès');
            print('[AdService] 📊 ID: ${ad.adUnitId}');
          },
          onAdFailedToLoad: (ad, error) {
            print('[AdService] ❌ Bannière échouée: $error');
            print('[AdService] 📊 Code d\'erreur: ${error.code}');
            print('[AdService] 📊 Message: ${error.message}');
            ad.dispose();
          },
          onAdOpened: (ad) {
            print('[AdService] 📺 Bannière ouverte');
          },
          onAdClosed: (ad) {
            print('[AdService] 📺 Bannière fermée');
          },
        ),
      );

      await ad.load();
      return ad;
    } catch (e) {
      print('[AdService] ❌ Erreur création bannière: $e');
      return null;
    }
  }

  // Créer une publicité interstitielle
  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    try {
      // Vérifier si on est sur une plateforme mobile
      if (!Platform.isAndroid && !Platform.isIOS) {
        print(
            '[AdService] ⚠️ Plateforme non supportée pour les interstitielles (Web/Desktop)');
        return;
      }

      print('[AdService] 🔄 Chargement publicité interstitielle...');

      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            print('[AdService] ✅ Interstitielle chargée avec succès');

            // Configurer les callbacks
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('[AdService] 📺 Publicité interstitielle fermée');
                ad.dispose();
                _interstitialAd = null;
                // Recharger automatiquement
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('[AdService] ❌ Erreur affichage interstitielle: $error');
                ad.dispose();
                _interstitialAd = null;
                // Recharger automatiquement
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('[AdService] ❌ Interstitielle échouée: $error');
            print('[AdService] 📊 Code d\'erreur: ${error.code}');
            print('[AdService] 📊 Message: ${error.message}');
            _interstitialAd = null;

            // Recharger après un délai en cas d'échec
            Future.delayed(const Duration(seconds: 30), () {
              print(
                  '[AdService] 🔄 Nouvelle tentative de chargement interstitielle...');
              loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      print('[AdService] ❌ Erreur chargement interstitielle: $e');
      _interstitialAd = null;
    }
  }

  static Future<void> showInterstitialAd() async {
    print('[AdService] 📺 Tentative d\'affichage publicité interstitielle');

    // Indiquer qu'une publicité commence
    UnifiedAudioServiceOptimized.instance.setAdPlaying(true);

    // Arrêter la musique de fond avant la publicité
    await UnifiedAudioServiceOptimized.instance.stopBackgroundMusic();

    if (_interstitialAd != null) {
      try {
        await _interstitialAd!.show();
        _interstitialAd = null;
        print('[AdService] ✅ Publicité interstitielle affichée avec succès');

        // Recharger une nouvelle publicité
        await loadInterstitialAd();
      } catch (e) {
        print('[AdService] ❌ Erreur affichage interstitielle: $e');
      }
    } else {
      print('[AdService] ⚠️ Aucune publicité interstitielle disponible');
    }

    // Attendre un peu avant de reprendre la musique
    await Future.delayed(const Duration(milliseconds: 500));

    // Indiquer que la publicité est terminée
    UnifiedAudioServiceOptimized.instance.setAdPlaying(false);

    // Reprendre la musique de fond après la publicité
    await UnifiedAudioServiceOptimized.instance.playBackgroundMusic();
    print('[AdService] 🎵 Reprise de la musique après publicité');
  }

  // Créer une publicité récompensée
  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            print('[AdService] ✅ Récompensée chargée avec succès');
          },
          onAdFailedToLoad: (error) {
            print('[AdService] ❌ Récompensée échouée: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      print('[AdService] ❌ Erreur chargement récompensée: $e');
    }
  }

  static Future<void> showRewardedAd({
    required Function() onRewarded,
  }) async {
    if (_rewardedAd != null) {
      try {
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedAd = null;
            // Recharger une nouvelle publicité
            loadRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _rewardedAd = null;
            // Recharger une nouvelle publicité
            loadRewardedAd();
          },
        );

        await _rewardedAd!.show(
          onUserEarnedReward: (_, reward) {
            onRewarded();
          },
        );
        print('[AdService] ✅ Publicité récompensée affichée');
      } catch (e) {
        print('[AdService] ❌ Erreur affichage récompensée: $e');
      }
    } else {
      print('[AdService] ⚠️ Aucune publicité récompensée disponible');
    }
  }

  // ===== NOUVELLES MÉTHODES STRATÉGIQUES =====

  // Publicité récompensée pour bonus XP
  static Future<void> showRewardedAdForXPBonus({
    required Function(int bonusXP) onRewarded,
  }) async {
    print(
        '[AdService] 🎁 Tentative d\'affichage publicité récompensée pour bonus XP');

    // Vérifier si une publicité récompensée est disponible
    if (_rewardedAd == null) {
      print('[AdService] 🔄 Rechargement de la publicité récompensée...');
      await loadRewardedAd();

      // Attendre un peu pour le chargement
      await Future.delayed(const Duration(seconds: 3));

      // Vérifier à nouveau
      if (_rewardedAd == null) {
        print('[AdService] ❌ Impossible de charger une publicité récompensée');
        // Ne pas donner de bonus XP gratuit - l'utilisateur doit regarder la pub
        print(
            '[AdService] ⚠️ Aucun bonus XP accordé - publicité non disponible');
        return;
      }
    }

    try {
      await showRewardedAd(
        onRewarded: () {
          // Bonus XP aléatoire entre 20 et 50 - SEULEMENT si la pub est regardée
          int bonusXP = 20 + (DateTime.now().millisecond % 31);
          onRewarded(bonusXP);
          print(
              '[AdService] 🎁 Bonus XP accordé après regard de la pub: $bonusXP points');
        },
      );
    } catch (e) {
      print('[AdService] ❌ Erreur lors de l\'affichage: $e');
      // Ne pas donner de bonus XP gratuit en cas d'erreur
      print('[AdService] ⚠️ Aucun bonus XP accordé - erreur d\'affichage');
    }
  }

  // Publicité récompensée pour débloquer une question
  static Future<void> showRewardedAdForQuestionHint({
    required Function() onRewarded,
  }) async {
    await showRewardedAd(
      onRewarded: () {
        onRewarded();
        print('[AdService] 💡 Indice de question débloqué');
      },
    );
  }

  // Publicité récompensée pour continuer après échec
  static Future<void> showRewardedAdForContinue({
    required Function() onRewarded,
  }) async {
    await showRewardedAd(
      onRewarded: () {
        onRewarded();
        print('[AdService] 🔄 Continuer après échec débloqué');
      },
    );
  }

  // Publicité interstitielle stratégique - après 3 questions
  static Future<void> showStrategicInterstitial() async {
    await SmartAdStrategy.showSmartAd();
  }

  // Publicité interstitielle - fin de quiz
  static Future<void> showEndGameInterstitial() async {
    await SmartAdStrategy.showSmartAd(context: AdContext.quizComplete);
  }

  // Publicité interstitielle - changement de catégorie
  static Future<void> showCategoryChangeInterstitial() async {
    await SmartAdStrategy.showSmartAd(context: AdContext.categoryComplete);
  }

  // Publicité interstitielle - après 5 bonnes réponses consécutives
  static Future<void> showStreakInterstitial() async {
    await SmartAdStrategy.showSmartAd(context: AdContext.streakMilestone);
  }

  // Forcer le rechargement de toutes les publicités
  static Future<void> reloadAllAds() async {
    print('[AdService] 🔄 Rechargement de toutes les publicités...');

    try {
      // Libérer les anciennes publicités
      _interstitialAd?.dispose();
      _rewardedAd?.dispose();
      _interstitialAd = null;
      _rewardedAd = null;

      // Recharger les nouvelles publicités
      await Future.wait([
        loadInterstitialAd(),
        loadRewardedAd(),
      ]);

      // Attendre un peu pour s'assurer du chargement
      await Future.delayed(const Duration(seconds: 2));

      print('[AdService] ✅ Toutes les publicités rechargées');
    } catch (e) {
      print('[AdService] ❌ Erreur lors du rechargement: $e');
    }
  }

  // Nettoyer les ressources
  static void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    print('[AdService] 🧹 Ressources publicitaires libérées');
  }
}
