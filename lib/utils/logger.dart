import 'package:flutter/foundation.dart';

/// Système de logging centralisé pour remplacer les print() dispersés
///
/// Avantages :
/// - Logs structurés avec niveaux (debug, info, warning, error)
/// - Désactivation automatique en production (si kReleaseMode)
/// - Format uniforme pour faciliter le debugging
/// - Possibilité d'ajouter un système de crash reporting
class Logger {
  // Configuration
  static const bool _enableDebugLogs = true;
  static const bool _enableInfoLogs = true;
  static const bool _enableWarningLogs = true;
  static const bool _enableErrorLogs = true;

  // Tags pour identifier la source des logs
  static const String _tagSeparator = ' | ';

  /// Log de debug (développement uniquement)
  static void debug(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (!_enableDebugLogs || kReleaseMode) return;
    _log('🐛 DEBUG', tag, message, error, stackTrace);
  }

  /// Log d'information (comportement normal)
  static void info(String tag, String message) {
    if (!_enableInfoLogs) return;
    _log('ℹ️ INFO', tag, message);
  }

  /// Log d'avertissement (problème mineur)
  static void warning(String tag, String message, [Object? error]) {
    if (!_enableWarningLogs) return;
    _log('⚠️ WARNING', tag, message, error);
  }

  /// Log d'erreur (problème critique)
  static void error(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (!_enableErrorLogs) return;
    _log('❌ ERROR', tag, message, error, stackTrace);
  }

  /// Log de succès (action réussie)
  static void success(String tag, String message) {
    if (!_enableInfoLogs) return;
    _log('✅ SUCCESS', tag, message);
  }

  /// Log de performance (timing)
  static void performance(String tag, String operation, Duration duration) {
    if (!_enableDebugLogs || kReleaseMode) return;
    _log('⚡ PERFORMANCE', tag, '$operation en ${duration.inMilliseconds}ms');
  }

  /// Méthode interne pour formater et afficher les logs
  static void _log(String level, String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final formattedMessage = '[$timestamp]$level$_tagSeparator[$tag] $message';

    if (error != null) {
      print('$formattedMessage\nErreur: $error');
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    } else {
      print(formattedMessage);
    }

    // TODO: Future - Envoyer les erreurs critiques à Firebase Crashlytics
    // if (level.contains('ERROR') && kReleaseMode) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
  }

  /// Mesurer le temps d'exécution d'une fonction
  static T measurePerformance<T>(
      String tag, String operation, T Function() function) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = function();
      stopwatch.stop();
      performance(tag, operation, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error(tag, 'Erreur lors de $operation', e, stackTrace);
      rethrow;
    }
  }

  /// Mesurer le temps d'exécution d'une fonction async
  static Future<T> measurePerformanceAsync<T>(
      String tag, String operation, Future<T> Function() function) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      performance(tag, operation, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error(tag, 'Erreur lors de $operation', e, stackTrace);
      rethrow;
    }
  }
}
