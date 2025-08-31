import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const String _premiumKey = 'is_premium_user';
  static const String _premiumActivationDateKey = 'premium_activation_date';
  static const String _premiumPrice = '2.99'; // Prix en euros

  // Vérifier si l'utilisateur a la version premium
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isPremium = prefs.getBool(_premiumKey) ?? false;
    
    // Vérifier aussi l'achat direct
    bool hasPurchased = prefs.getBool('premium_purchased') ?? false;
    
    return isPremium || hasPurchased;
  }

  // Activer la version premium
  static Future<void> activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    await prefs.setString(_premiumActivationDateKey, DateTime.now().toIso8601String());
    
    print('[PremiumService] ✅ Version premium activée');
  }

  // Désactiver la version premium (pour les tests)
  static Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, false);
    await prefs.remove(_premiumActivationDateKey);
    
    print('[PremiumService] ❌ Version premium désactivée');
  }

  // Obtenir le prix de la version premium
  static String getPremiumPrice() {
    return _premiumPrice;
  }

  // Obtenir la date d'activation premium
  static Future<String?> getPremiumActivationDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_premiumActivationDateKey);
  }

  // Obtenir les statistiques premium
  static Future<Map<String, dynamic>> getPremiumStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    bool isPremium = await isPremiumUser();
    String? activationDate = await getPremiumActivationDate();
    
    return {
      'is_premium': isPremium,
      'activation_date': activationDate,
      'days_since_activation': activationDate != null 
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
      int days = DateTime.now().difference(DateTime.parse(activationDate)).inDays;
      print('[PremiumService] - Jours depuis activation: $days');
    }
  }
}
