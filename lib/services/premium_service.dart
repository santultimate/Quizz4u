import 'cached_preferences_service.dart'; // ⚡ OPTIMISÉ

class PremiumService {
  static const String _premiumKey = 'is_premium_user';
  static const String _premiumActivationDateKey = 'premium_activation_date';
  static const String _premiumPrice = '2.99'; // Prix en euros

  // ⚡ OPTIMISÉ: Vérifier si l'utilisateur a la version premium (avec cache)
  static Future<bool> isPremiumUser() async {
    bool isPremium = await CachedPreferencesService.getBool(
      _premiumKey,
      defaultValue: false,
    );

    // Vérifier aussi l'achat direct
    bool hasPurchased = await CachedPreferencesService.getBool(
      'premium_purchased',
      defaultValue: false,
    );

    return isPremium || hasPurchased;
  }

  // ⚡ OPTIMISÉ: Activer la version premium
  static Future<void> activatePremium() async {
    await CachedPreferencesService.setBool(_premiumKey, true);
    await CachedPreferencesService.setString(
      _premiumActivationDateKey,
      DateTime.now().toIso8601String(),
    );

    print('[PremiumService] ✅ Version premium activée');
  }

  // ⚡ OPTIMISÉ: Désactiver la version premium (pour les tests)
  static Future<void> deactivatePremium() async {
    await CachedPreferencesService.setBool(_premiumKey, false);
    await CachedPreferencesService.remove(_premiumActivationDateKey);

    print('[PremiumService] ❌ Version premium désactivée');
  }

  // Obtenir le prix de la version premium
  static String getPremiumPrice() {
    return _premiumPrice;
  }

  // ⚡ OPTIMISÉ: Obtenir la date d'activation premium
  static Future<String?> getPremiumActivationDate() async {
    return await CachedPreferencesService.getString(
      _premiumActivationDateKey,
      defaultValue: '',
    );
  }

  // ⚡ OPTIMISÉ: Obtenir les statistiques premium
  static Future<Map<String, dynamic>> getPremiumStats() async {
    bool isPremium = await isPremiumUser();
    String? activationDate = await getPremiumActivationDate();

    return {
      'is_premium': isPremium,
      'activation_date': activationDate,
      'days_since_activation':
          activationDate != null && activationDate.isNotEmpty
              ? DateTime.now().difference(DateTime.parse(activationDate)).inDays
              : 0,
    };
  }

  // Simuler un achat (pour le développement)
  static Future<void> simulatePurchase() async {
    await activatePremium();
    print('[PremiumService] 🧪 Achat simulé pour le développement');
  }

  // Vérifier l'état premium avec logs détaillés
  static Future<void> checkPremiumStatus() async {
    bool isPremium = await isPremiumUser();
    String? activationDate = await getPremiumActivationDate();

    print('[PremiumService] 📊 Statut Premium:');
    print('[PremiumService] - Premium actif: $isPremium');
    print('[PremiumService] - Date d\'activation: $activationDate');

    if (isPremium && activationDate != null) {
      int days =
          DateTime.now().difference(DateTime.parse(activationDate)).inDays;
      print('[PremiumService] - Jours depuis activation: $days');
    }
  }
}
