class AdMobConfig {
  // Application ID officiel Quizz4U
  static const String applicationId = 'ca-app-pub-7487587531173203~1375704927';

  // IDs de production pour Quizz4U
  static const String bannerAdUnitId = 'ca-app-pub-7487587531173203/3898760638';
  static const String interstitialAdUnitId =
      'ca-app-pub-7487587531173203/7039095147';
  static const String rewardedAdUnitId =
      'ca-app-pub-7487587531173203/8463537623';

  // IDs de test Google (pour développement uniquement)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Mode de développement (false = production, true = test)
  // Mode production activé - les IDs sont validés dans AdMob Console
  static const bool isTestMode = false;

  // Obtenir les IDs selon le mode
  static String getBannerAdUnitId() {
    return isTestMode ? testBannerAdUnitId : bannerAdUnitId;
  }

  static String getInterstitialAdUnitId() {
    return isTestMode ? testInterstitialAdUnitId : interstitialAdUnitId;
  }

  static String getRewardedAdUnitId() {
    return isTestMode ? testRewardedAdUnitId : rewardedAdUnitId;
  }
}
