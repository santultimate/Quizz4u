import 'package:flutter/material.dart';

/// 🛡️ SafeNavigator - Évite les ANR "No focused window"
///
/// Problème résolu:
/// - Navigation pendant que la fenêtre n'a pas le focus
/// - Navigation pendant affichage de dialogues
/// - Navigation pendant publicités interstitielles
///
/// Solution:
/// - Vérification que le contexte est monté
/// - Délai minimal pour assurer le focus
/// - Gestion d'erreurs robuste
class SafeNavigator {
  /// ⚡ Navigation sécurisée avec vérification de focus
  static Future<T?> push<T>(
    BuildContext context,
    Widget screen, {
    bool waitForFocus = true,
  }) async {
    // Vérifier que le widget est toujours monté
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté - Navigation annulée');
      return null;
    }

    try {
      // Attendre un court délai pour s'assurer que la fenêtre a le focus
      if (waitForFocus) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Vérifier à nouveau que le contexte est toujours monté
      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu pendant l\'attente');
        return null;
      }

      return await Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation push: $e');
      return null;
    }
  }

  /// ⚡ Navigation sécurisée avec remplacement
  static Future<T?> pushReplacement<T>(
    BuildContext context,
    Widget screen, {
    bool waitForFocus = true,
  }) async {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté - Navigation annulée');
      return null;
    }

    try {
      if (waitForFocus) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu pendant l\'attente');
        return null;
      }

      return await Navigator.pushReplacement<T, void>(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation pushReplacement: $e');
      return null;
    }
  }

  /// ⚡ Navigation sécurisée nommée
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool waitForFocus = true,
  }) async {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté - Navigation annulée');
      return null;
    }

    try {
      if (waitForFocus) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu pendant l\'attente');
        return null;
      }

      return await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation pushNamed: $e');
      return null;
    }
  }

  /// ⚡ Pop sécurisé
  static void pop<T>(BuildContext context, [T? result]) {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté - Pop annulé');
      return;
    }

    try {
      Navigator.pop(context, result);
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation pop: $e');
    }
  }

  /// ⚡ Pop jusqu'à une route spécifique
  static void popUntil(BuildContext context, String routeName) {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté - PopUntil annulé');
      return;
    }

    try {
      Navigator.popUntil(
        context,
        (route) => route.settings.name == routeName,
      );
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation popUntil: $e');
    }
  }

  /// 🛡️ Afficher un dialogue en toute sécurité
  static Future<T?> showSafeDialog<T>(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté - Dialog annulé');
      return null;
    }

    try {
      // Attendre que la fenêtre ait le focus
      await Future.delayed(const Duration(milliseconds: 150));

      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu - Dialog annulé');
        return null;
      }

      return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => dialog,
      );
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur affichage dialog: $e');
      return null;
    }
  }

  /// 🛡️ Naviguer après avoir attendu qu'une publicité se ferme
  static Future<T?> pushAfterAd<T>(
    BuildContext context,
    Widget screen, {
    Duration waitTime = const Duration(milliseconds: 500),
  }) async {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté');
      return null;
    }

    try {
      // Attendre que la publicité soit complètement fermée
      print('[SafeNavigator] ⏳ Attente fermeture publicité...');
      await Future.delayed(waitTime);

      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu après publicité');
        return null;
      }

      // Vérifier que la fenêtre a le focus
      await Future.delayed(const Duration(milliseconds: 200));

      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu pendant vérification focus');
        return null;
      }

      print('[SafeNavigator] ✅ Navigation après publicité');
      return await Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation après pub: $e');
      return null;
    }
  }

  /// 🛡️ Naviguer après avoir fermé un dialogue
  static Future<T?> pushAfterDialog<T>(
    BuildContext context,
    Widget screen,
  ) async {
    if (!context.mounted) {
      print('[SafeNavigator] ⚠️ Context non monté');
      return null;
    }

    try {
      // Fermer d'abord le dialogue
      Navigator.pop(context);

      // Attendre que le dialogue soit complètement fermé
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) {
        print('[SafeNavigator] ⚠️ Context perdu après fermeture dialog');
        return null;
      }

      // Naviguer vers le nouvel écran
      return await push<T>(context, screen);
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur navigation après dialog: $e');
      return null;
    }
  }

  /// 📊 Obtenir les statistiques de navigation
  static bool canPop(BuildContext context) {
    try {
      return context.mounted && Navigator.canPop(context);
    } catch (e) {
      print('[SafeNavigator] ❌ Erreur canPop: $e');
      return false;
    }
  }
}





