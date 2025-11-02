import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';
import 'payment_verification_service.dart';

class EnhancedPurchaseService {
  // ✅ ID correspondant à Google Play Console
  static const String _premiumProductId = 'premium_lifetime';
  static const String _premiumProductIdIOS = 'premium_lifetime';

  // 📝 TODO: Créer ces produits dans Play Console si vous voulez des abonnements
  static const String _monthlyProductId = 'premium_monthly';
  static const String _yearlyProductId = 'premium_yearly';

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static List<ProductDetails> _products = [];
  static bool _isAvailable = false;
  static bool _isInitialized = false;

  // États du processus de paiement
  static DateTime? _purchaseStartTime;

  // Callbacks pour les événements de paiement
  static Function(PurchaseDetails)? _onPurchaseSuccess;
  static Function(String)? _onPurchaseError;
  static Function()? _onPurchaseCancel;

  // Initialiser le service d'achat amélioré
  static Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      print('[EnhancedPurchase] 🛒 Achats in-app disponibles: $_isAvailable');

      if (_isAvailable) {
        _subscription = _inAppPurchase.purchaseStream.listen(
          _onPurchaseUpdate,
          onDone: () => _subscription?.cancel(),
          onError: (error) {
            print('[EnhancedPurchase] ❌ Erreur d\'achat: $error');
            _onPurchaseError?.call(error.toString());
          },
        );

        await _loadProducts();
        _isInitialized = true;
        print('[EnhancedPurchase] ✅ Service d\'achat initialisé avec succès');
      } else {
        print('[EnhancedPurchase] ⚠️ Achats in-app non disponibles');
      }
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de l\'initialisation: $e');
      _onPurchaseError?.call('Erreur d\'initialisation: $e');
    }
  }

  // Charger tous les produits disponibles
  static Future<void> _loadProducts() async {
    try {
      // ✅ Pour l'instant, charger uniquement le produit créé dans Play Console
      final Set<String> productIds = {
        _premiumProductId, // premium_lifetime
        // 📝 Décommenter quand les abonnements seront créés dans Play Console:
        // _monthlyProductId,
        // _yearlyProductId,
      };

      print('[EnhancedPurchase] 📦 Chargement des produits: $productIds');

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print(
            '[EnhancedPurchase] ⚠️ Produits non trouvés: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        print(
            '[EnhancedPurchase] ❌ Erreur lors du chargement: ${response.error}');
        return;
      }

      _products = response.productDetails;
      print('[EnhancedPurchase] ✅ ${_products.length} produits chargés');

      for (final product in _products) {
        print(
            '[EnhancedPurchase] 📋 ${product.id}: ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors du chargement des produits: $e');
    }
  }

  // Obtenir les produits disponibles
  static List<ProductDetails> getAvailableProducts() {
    return _products;
  }

  // Obtenir le produit premium principal
  static ProductDetails? getPremiumProduct() {
    if (_products.isEmpty) {
      print(
          '[EnhancedPurchaseService] ⚠️ Aucun produit disponible (mode test/émulateur)');
      return null;
    }

    try {
      return _products.firstWhere(
        (product) =>
            product.id == _premiumProductId ||
            product.id == _premiumProductIdIOS,
        orElse: () => _products.first,
      );
    } catch (e) {
      print('[EnhancedPurchaseService] ❌ Erreur récupération produit: $e');
      return null;
    }
  }

  // Obtenir les options d'abonnement
  static Map<String, ProductDetails> getSubscriptionOptions() {
    final Map<String, ProductDetails> options = {};

    for (final product in _products) {
      if (product.id == _monthlyProductId) {
        options['monthly'] = product;
      } else if (product.id == _yearlyProductId) {
        options['yearly'] = product;
      }
    }

    return options;
  }

  // Démarrer un achat avec gestion d'erreur améliorée
  static Future<bool> purchasePremium({
    Function(PurchaseDetails)? onSuccess,
    Function(String)? onError,
    Function()? onCancel,
  }) async {
    try {
      if (!_isAvailable || !_isInitialized) {
        onError?.call('Service de paiement non disponible');
        return false;
      }

      final product = getPremiumProduct();
      if (product == null) {
        onError?.call('Produit premium non trouvé');
        return false;
      }

      // Enregistrer les callbacks
      _onPurchaseSuccess = onSuccess;
      _onPurchaseError = onError;
      _onPurchaseCancel = onCancel;

      // Réinitialiser l'état
      _purchaseStartTime = DateTime.now();

      print('[EnhancedPurchase] 🚀 Démarrage de l\'achat: ${product.id}');

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        _onPurchaseCancel?.call();
        return false;
      }

      return true;
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de l\'achat: $e');
      onError?.call('Erreur lors de l\'achat: $e');
      return false;
    }
  }

  // Acheter un abonnement
  static Future<bool> purchaseSubscription(
    String productId, {
    Function(PurchaseDetails)? onSuccess,
    Function(String)? onError,
    Function()? onCancel,
  }) async {
    try {
      if (!_isAvailable || !_isInitialized) {
        onError?.call('Service de paiement non disponible');
        return false;
      }

      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw StateError('Produit non trouvé'),
      );

      // Enregistrer les callbacks
      _onPurchaseSuccess = onSuccess;
      _onPurchaseError = onError;
      _onPurchaseCancel = onCancel;

      // Réinitialiser l'état
      _purchaseStartTime = DateTime.now();

      print('[EnhancedPurchase] 🚀 Démarrage de l\'abonnement: ${product.id}');

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        _onPurchaseCancel?.call();
        return false;
      }

      return true;
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de l\'abonnement: $e');
      onError?.call('Erreur lors de l\'abonnement: $e');
      return false;
    }
  }

  // Gérer les mises à jour d'achat
  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
          '[EnhancedPurchase] 📝 Mise à jour d\'achat: ${purchaseDetails.status}');

      // Traitement de l'achat

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('[EnhancedPurchase] ⏳ Achat en attente...');
          break;

        case PurchaseStatus.purchased:
          _handlePurchaseSuccess(purchaseDetails);
          break;

        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          _handlePurchaseCancel(purchaseDetails);
          break;

        case PurchaseStatus.restored:
          _handlePurchaseRestored(purchaseDetails);
          break;
      }

      // Finaliser l'achat
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Gérer le succès d'achat
  static void _handlePurchaseSuccess(PurchaseDetails purchaseDetails) async {
    try {
      print('[EnhancedPurchase] ✅ Achat réussi: ${purchaseDetails.productID}');

      // Vérifier le temps d'achat pour éviter les doublons
      if (_purchaseStartTime != null) {
        final duration = DateTime.now().difference(_purchaseStartTime!);
        if (duration.inSeconds < 1) {
          print('[EnhancedPurchase] ⚠️ Achat trop rapide, possible doublon');
          return;
        }
      }

      // Vérifier le paiement avant d'activer le premium
      final isVerified = await PaymentVerificationService.verifyPayment(
        transactionId: purchaseDetails.purchaseID ?? '',
        productId: purchaseDetails.productID,
        platform: Platform.isAndroid ? 'google_play' : 'app_store',
        receiptData: purchaseDetails.verificationData.serverVerificationData,
      );

      if (isVerified) {
        // Activer le premium seulement si la vérification réussit
        await PremiumService.activatePremium();

        // Sauvegarder les détails de l'achat
        await _savePurchaseDetails(purchaseDetails);

        // Notifier le succès
        _onPurchaseSuccess?.call(purchaseDetails);
      } else {
        print('[EnhancedPurchase] ❌ Paiement non vérifié - premium non activé');
        _onPurchaseError?.call('Échec de la vérification du paiement');
      }

      print('[EnhancedPurchase] 🎉 Premium activé avec succès');
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de l\'activation: $e');
      _onPurchaseError?.call('Erreur lors de l\'activation: $e');
    }
  }

  // Gérer l'erreur d'achat
  static void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    final error = purchaseDetails.error;
    print('[EnhancedPurchase] ❌ Erreur d\'achat: ${error?.message}');

    String errorMessage = 'Erreur d\'achat inconnue';
    if (error != null) {
      // Gestion des codes d'erreur simplifiée
      if (error.message.toLowerCase().contains('pending')) {
        errorMessage = 'Paiement en attente';
      } else if (error.message.toLowerCase().contains('invalid')) {
        errorMessage = 'Paiement invalide';
      } else if (error.message.toLowerCase().contains('not allowed')) {
        errorMessage = 'Paiement non autorisé';
      } else if (error.message.toLowerCase().contains('not available')) {
        errorMessage = 'Produit non disponible';
      } else if (error.message.toLowerCase().contains('network')) {
        errorMessage = 'Erreur de connexion réseau';
      } else if (error.message.toLowerCase().contains('cancelled')) {
        errorMessage = 'Paiement annulé';
      } else {
        errorMessage = error.message.isNotEmpty
            ? error.message
            : 'Erreur d\'achat inconnue';
      }
    }

    _onPurchaseError?.call(errorMessage);
  }

  // Gérer l'annulation d'achat
  static void _handlePurchaseCancel(PurchaseDetails purchaseDetails) {
    print('[EnhancedPurchase] 🚫 Achat annulé par l\'utilisateur');
    _onPurchaseCancel?.call();
  }

  // Gérer la restauration d'achat
  static void _handlePurchaseRestored(PurchaseDetails purchaseDetails) async {
    try {
      print(
          '[EnhancedPurchase] 🔄 Achat restauré: ${purchaseDetails.productID}');

      // Activer le premium
      await PremiumService.activatePremium();

      // Sauvegarder les détails de l'achat
      await _savePurchaseDetails(purchaseDetails);

      _onPurchaseSuccess?.call(purchaseDetails);
      print('[EnhancedPurchase] 🎉 Achat restauré avec succès');
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de la restauration: $e');
      _onPurchaseError?.call('Erreur lors de la restauration: $e');
    }
  }

  // Sauvegarder les détails de l'achat
  static Future<void> _savePurchaseDetails(
      PurchaseDetails purchaseDetails) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'purchase_transaction_id', purchaseDetails.purchaseID ?? '');
      await prefs.setString('purchase_product_id', purchaseDetails.productID);
      await prefs.setString('purchase_date', DateTime.now().toIso8601String());
      await prefs.setString('purchase_verification_data',
          purchaseDetails.verificationData.serverVerificationData);

      print('[EnhancedPurchase] 💾 Détails d\'achat sauvegardés');
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de la sauvegarde: $e');
    }
  }

  // Restaurer les achats
  static Future<bool> restorePurchases() async {
    try {
      if (!_isAvailable || !_isInitialized) {
        print(
            '[EnhancedPurchase] ❌ Service non disponible pour la restauration');
        return false;
      }

      print('[EnhancedPurchase] 🔄 Restauration des achats...');

      await _inAppPurchase.restorePurchases();

      // Vérifier si le premium est déjà activé
      final isPremium = await PremiumService.isPremiumUser();
      if (isPremium) {
        print('[EnhancedPurchase] ✅ Premium déjà activé');
        return true;
      }

      print('[EnhancedPurchase] ⚠️ Aucun achat à restaurer');
      return false;
    } catch (e) {
      print('[EnhancedPurchase] ❌ Erreur lors de la restauration: $e');
      return false;
    }
  }

  // Vérifier l'état du service
  static bool isReady() {
    return _isAvailable && _isInitialized && _products.isNotEmpty;
  }

  // Obtenir le prix formaté du produit premium
  static String getFormattedPrice() {
    final product = getPremiumProduct();
    return product?.price ?? '2,99€';
  }

  // Obtenir les statistiques d'achat
  static Future<Map<String, dynamic>> getPurchaseStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'isPremium': await PremiumService.isPremiumUser(),
        'transactionId': prefs.getString('purchase_transaction_id'),
        'productId': prefs.getString('purchase_product_id'),
        'purchaseDate': prefs.getString('purchase_date'),
        'serviceReady': isReady(),
        'productsAvailable': _products.length,
      };
    } catch (e) {
      print(
          '[EnhancedPurchase] ❌ Erreur lors de la récupération des stats: $e');
      return {
        'isPremium': false,
        'serviceReady': false,
        'productsAvailable': 0,
      };
    }
  }

  // Nettoyer les ressources
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _products.clear();
    _isInitialized = false;
    print('[EnhancedPurchase] 🧹 Service nettoyé');
  }
}
