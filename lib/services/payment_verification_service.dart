import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';

class PaymentVerificationService {
  // URLs de vérification des stores
  // Unused URLs - kept for future implementation
  // static const String _googlePlayVerifyUrl =
  //     'https://www.googleapis.com/androidpublisher/v3/applications';
  // static const String _appStoreVerifyUrl =
  //     'https://api.storekit.itunes.apple.com/inApps/v1/transactions';

  // Clés de stockage
  static const String _verificationKey = 'payment_verification';
  static const String _lastVerificationKey = 'last_payment_verification';

  // Intervalle de vérification (24 heures)
  static const Duration _verificationInterval = Duration(hours: 24);

  // Vérifier la validité d'un paiement
  static Future<bool> verifyPayment({
    required String transactionId,
    required String productId,
    required String platform, // 'google_play' ou 'app_store'
    String? receiptData,
  }) async {
    try {
      print(
          '[PaymentVerification] 🔍 Vérification du paiement: $transactionId');

      // Vérifier d'abord en local si déjà vérifié
      final localVerification = await _getLocalVerification(transactionId);
      if (localVerification != null && localVerification['verified'] == true) {
        print('[PaymentVerification] ✅ Paiement déjà vérifié localement');
        return true;
      }

      bool isVerified = false;

      if (platform == 'google_play') {
        isVerified = await _verifyGooglePlayPayment(transactionId, productId);
      } else if (platform == 'app_store') {
        isVerified = await _verifyAppStorePayment(receiptData ?? '');
      } else {
        print('[PaymentVerification] ❌ Plateforme non supportée: $platform');
        return false;
      }

      // Sauvegarder le résultat de la vérification
      await _saveVerificationResult(transactionId, isVerified);

      if (isVerified) {
        print('[PaymentVerification] ✅ Paiement vérifié avec succès');
        // Activer le premium si la vérification réussit
        await PremiumService.activatePremium();
      } else {
        print('[PaymentVerification] ❌ Paiement non vérifié');
      }

      return isVerified;
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur lors de la vérification: $e');
      return false;
    }
  }

  // Vérifier un paiement Google Play (simulation - nécessite une clé API réelle)
  static Future<bool> _verifyGooglePlayPayment(
      String transactionId, String productId) async {
    try {
      // NOTE: Dans un vrai projet, vous devriez:
      // 1. Utiliser une clé API Google Play Console
      // 2. Vérifier côté serveur pour la sécurité
      // 3. Valider le token de réception

      print(
          '[PaymentVerification] 🔍 Vérification Google Play: $transactionId');

      // Simulation de vérification
      // Dans la réalité, vous feriez une requête à l'API Google Play
      await Future.delayed(const Duration(seconds: 2));

      // Pour les tests, on considère que la vérification réussit si le transactionId n'est pas vide
      final isValid = transactionId.isNotEmpty && productId.isNotEmpty;

      print('[PaymentVerification] 📊 Résultat Google Play: $isValid');
      return isValid;
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur Google Play: $e');
      return false;
    }
  }

  // Vérifier un paiement App Store (simulation - nécessite une clé API réelle)
  static Future<bool> _verifyAppStorePayment(String receiptData) async {
    try {
      // NOTE: Dans un vrai projet, vous devriez:
      // 1. Utiliser une clé API Apple
      // 2. Vérifier côté serveur pour la sécurité
      // 3. Valider le receipt avec Apple

      print('[PaymentVerification] 🔍 Vérification App Store');

      // Simulation de vérification
      // Dans la réalité, vous feriez une requête à l'API Apple
      await Future.delayed(const Duration(seconds: 2));

      // Pour les tests, on considère que la vérification réussit si le receipt n'est pas vide
      final isValid = receiptData.isNotEmpty;

      print('[PaymentVerification] 📊 Résultat App Store: $isValid');
      return isValid;
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur App Store: $e');
      return false;
    }
  }

  // Vérification périodique des paiements
  static Future<void> performPeriodicVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastVerificationStr = prefs.getString(_lastVerificationKey);

      // Vérifier si on doit faire une vérification
      if (lastVerificationStr != null) {
        final lastVerification = DateTime.parse(lastVerificationStr);
        final now = DateTime.now();

        if (now.difference(lastVerification) < _verificationInterval) {
          print('[PaymentVerification] ⏰ Vérification pas encore nécessaire');
          return;
        }
      }

      print('[PaymentVerification] 🔄 Vérification périodique en cours...');

      // Récupérer les informations de paiement stockées
      final transactionId = prefs.getString('purchase_transaction_id');
      final productId = prefs.getString('purchase_product_id');

      if (transactionId != null && productId != null) {
        // Déterminer la plateforme
        final platform = Platform.isAndroid ? 'google_play' : 'app_store';

        // Vérifier le paiement
        final isVerified = await verifyPayment(
          transactionId: transactionId,
          productId: productId,
          platform: platform,
        );

        if (!isVerified) {
          print(
              '[PaymentVerification] ⚠️ Paiement non vérifié - désactivation premium');
          await PremiumService.deactivatePremium();
        }
      }

      // Mettre à jour la dernière vérification
      await prefs.setString(
          _lastVerificationKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur vérification périodique: $e');
    }
  }

  // Obtenir la vérification locale d'un paiement
  static Future<Map<String, dynamic>?> _getLocalVerification(
      String transactionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verificationData =
          prefs.getString('${_verificationKey}_$transactionId');

      if (verificationData != null) {
        return json.decode(verificationData) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur lecture vérification locale: $e');
      return null;
    }
  }

  // Sauvegarder le résultat de la vérification
  static Future<void> _saveVerificationResult(
      String transactionId, bool isVerified) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verificationData = {
        'transactionId': transactionId,
        'verified': isVerified,
        'verificationDate': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
        '${_verificationKey}_$transactionId',
        json.encode(verificationData),
      );

      print('[PaymentVerification] 💾 Résultat de vérification sauvegardé');
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur sauvegarde vérification: $e');
    }
  }

  // Vérifier l'intégrité du premium
  static Future<bool> verifyPremiumIntegrity() async {
    try {
      final isPremium = await PremiumService.isPremiumUser();

      if (isPremium) {
        print('[PaymentVerification] 🔍 Vérification intégrité premium...');

        // Effectuer une vérification périodique
        await performPeriodicVerification();

        // Vérifier à nouveau le statut après vérification
        final stillPremium = await PremiumService.isPremiumUser();
        return stillPremium;
      }

      return false;
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur vérification intégrité: $e');
      return false;
    }
  }

  // Nettoyer les vérifications expirées (plus de 30 jours)
  static Future<void> cleanupExpiredVerifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final expiredKeys = <String>[];

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      for (final key in keys) {
        if (key.startsWith(_verificationKey)) {
          final verificationData = prefs.getString(key);
          if (verificationData != null) {
            try {
              final data =
                  json.decode(verificationData) as Map<String, dynamic>;
              final verificationDate = DateTime.parse(data['verificationDate']);

              if (verificationDate.isBefore(cutoffDate)) {
                expiredKeys.add(key);
              }
            } catch (e) {
              // Si on ne peut pas parser la date, on considère comme expiré
              expiredKeys.add(key);
            }
          }
        }
      }

      // Supprimer les clés expirées
      for (final key in expiredKeys) {
        await prefs.remove(key);
      }

      if (expiredKeys.isNotEmpty) {
        print(
            '[PaymentVerification] 🧹 ${expiredKeys.length} vérifications expirées supprimées');
      }
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur nettoyage: $e');
    }
  }

  // Obtenir les statistiques de vérification
  static Future<Map<String, dynamic>> getVerificationStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int totalVerifications = 0;
      int successfulVerifications = 0;
      DateTime? lastVerification;

      for (final key in keys) {
        if (key.startsWith(_verificationKey)) {
          final verificationData = prefs.getString(key);
          if (verificationData != null) {
            try {
              final data =
                  json.decode(verificationData) as Map<String, dynamic>;
              totalVerifications++;

              if (data['verified'] == true) {
                successfulVerifications++;
              }

              final verificationDate = DateTime.parse(data['verificationDate']);
              if (lastVerification == null ||
                  verificationDate.isAfter(lastVerification)) {
                lastVerification = verificationDate;
              }
            } catch (e) {
              // Ignorer les données corrompues
            }
          }
        }
      }

      return {
        'totalVerifications': totalVerifications,
        'successfulVerifications': successfulVerifications,
        'successRate': totalVerifications > 0
            ? (successfulVerifications / totalVerifications * 100)
            : 0,
        'lastVerification': lastVerification?.toIso8601String(),
        'isPremium': await PremiumService.isPremiumUser(),
      };
    } catch (e) {
      print('[PaymentVerification] ❌ Erreur statistiques: $e');
      return {
        'totalVerifications': 0,
        'successfulVerifications': 0,
        'successRate': 0,
        'isPremium': false,
      };
    }
  }
}
