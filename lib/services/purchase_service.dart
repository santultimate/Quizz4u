import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';

class PurchaseService {
  static const String _premiumProductId = 'quizz4u_premium';
  static const String _premiumProductIdIOS = 'quizz4u_premium_ios';

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static List<ProductDetails> _products = [];
  static bool _isAvailable = false;
  static bool _isInitialized = false;

  // Initialiser le service d'achat
  static Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      print('[PurchaseService] Achats in-app disponibles: $_isAvailable');

      if (_isAvailable) {
        _subscription = _inAppPurchase.purchaseStream.listen(
          _onPurchaseUpdate,
          onDone: () => _subscription?.cancel(),
          onError: (error) =>
              print('[PurchaseService] Erreur d\'achat: $error'),
        );

        await _loadProducts();
        _isInitialized = true;
        print('[PurchaseService] Service d\'achat initialisé avec succès');
      } else {
        print(
            '[PurchaseService] Achats in-app non disponibles sur cette plateforme');
      }
    } catch (e) {
      print('[PurchaseService] Erreur lors de l\'initialisation: $e');
    }
  }

  // Charger les produits disponibles
  static Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = {
        _premiumProductId,
        _premiumProductIdIOS,
      };

      print('[PurchaseService] Chargement des produits: $productIds');

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print(
            '[PurchaseService] Produits non trouvés: ${response.notFoundIDs}');
        print(
            '[PurchaseService] Vérifiez que les produits sont configurés dans Google Play Console/App Store Connect');
      }

      if (response.productDetails.isNotEmpty) {
        print(
            '[PurchaseService] Produits trouvés: ${response.productDetails.length}');
        for (var product in response.productDetails) {
          print(
              '[PurchaseService] - ${product.id}: ${product.title} (${product.price})');
        }
      }

      _products = response.productDetails;
    } catch (e) {
      print('[PurchaseService] Erreur lors du chargement des produits: $e');
    }
  }

  // Obtenir le produit premium
  static ProductDetails? getPremiumProduct() {
    try {
      return _products.firstWhere(
        (product) =>
            product.id == _premiumProductId ||
            product.id == _premiumProductIdIOS,
        orElse: () => throw Exception('Produit premium non trouvé'),
      );
    } catch (e) {
      print('[PurchaseService] Produit premium non disponible: $e');
      return null;
    }
  }

  // Effectuer l'achat
  static Future<bool> purchasePremium() async {
    if (!_isAvailable) {
      print('[PurchaseService] Achats in-app non disponibles');
      return false;
    }

    if (!_isInitialized) {
      print('[PurchaseService] Service non initialisé');
      return false;
    }

    try {
      final ProductDetails? product = getPremiumProduct();
      if (product == null) {
        print('[PurchaseService] Produit premium non disponible');
        return false;
      }

      print(
          '[PurchaseService] Tentative d\'achat: ${product.id} - ${product.price}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      print('[PurchaseService] Résultat de l\'achat: $success');
      return success;
    } catch (e) {
      print('[PurchaseService] Erreur lors de l\'achat: $e');
      return false;
    }
  }

  // Gérer les mises à jour d'achat
  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
          '[PurchaseService] Mise à jour d\'achat: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('[PurchaseService] Achat en cours...');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('[PurchaseService] Erreur d\'achat: ${purchaseDetails.error}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Vérifier et activer l'achat
  static Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    print(
        '[PurchaseService] Vérification de l\'achat: ${purchaseDetails.productID}');

    // Vérifier que c'est bien le produit premium
    if (purchaseDetails.productID == _premiumProductId ||
        purchaseDetails.productID == _premiumProductIdIOS) {
      
      // Sauvegarder l'achat localement
      await _savePurchaseLocally(purchaseDetails);
      
      // Activer le mode premium
      await PremiumService.activatePremium();
      print('[PurchaseService] Version premium activée avec succès !');
    }
  }

  // Sauvegarder l'achat localement
  static Future<void> _savePurchaseLocally(PurchaseDetails purchaseDetails) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('premium_purchased', true);
    await prefs.setString('purchase_date', DateTime.now().toIso8601String());
    await prefs.setString('purchase_id', purchaseDetails.purchaseID ?? '');
    await prefs.setString('product_id', purchaseDetails.productID);
    
    print('[PurchaseService] Achat sauvegardé localement');
  }

  // Restaurer les achats (pour iOS)
  static Future<void> restorePurchases() async {
    if (_isAvailable) {
      print('[PurchaseService] Restauration des achats...');
      await _inAppPurchase.restorePurchases();
    } else {
      print(
          '[PurchaseService] Restauration impossible - achats non disponibles');
    }
  }

  // Vérifier si l'utilisateur a déjà acheté
  static Future<bool> hasPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    bool purchased = prefs.getBool('premium_purchased') ?? false;
    
    // Vérifier aussi le service premium
    bool isPremium = await PremiumService.isPremiumUser();
    
    return purchased || isPremium;
  }

  // Obtenir les informations d'achat
  static Future<Map<String, dynamic>> getPurchaseInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'purchased': prefs.getBool('premium_purchased') ?? false,
      'purchase_date': prefs.getString('purchase_date'),
      'purchase_id': prefs.getString('purchase_id'),
      'product_id': prefs.getString('product_id'),
    };
  }

  // Vérifier si le service est prêt
  static bool isReady() {
    return _isAvailable && _isInitialized && _products.isNotEmpty;
  }

  // Nettoyer les ressources
  static void dispose() {
    _subscription?.cancel();
  }

  // Obtenir le prix formaté
  static String getFormattedPrice() {
    try {
      final product = getPremiumProduct();
      return product?.price ?? '2.99€';
    } catch (e) {
      return '2.99€';
    }
  }
}
