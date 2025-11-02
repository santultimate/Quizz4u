import 'package:shared_preferences/shared_preferences.dart';

/// ⚡ Service de cache pour SharedPreferences - Fix ANR
/// 
/// Problème résolu:
/// - SharedPreferences est lent (accès disque)
/// - Appels répétés bloquent le thread UI
/// 
/// Solution:
/// - Cache en mémoire avec TTL (Time To Live)
/// - Accès ultra-rapide aux valeurs fréquentes
class CachedPreferencesService {
  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};

  // Durée de validité du cache (1 minute par défaut)
  static const Duration _cacheDuration = Duration(minutes: 1);

  /// Initialiser le service (à appeler au démarrage)
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    print('[CachedPrefs] ✅ Service initialisé');
  }

  /// ⚡ Lire une valeur booléenne (avec cache)
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    // Vérifier le cache
    if (_isCacheValid(key)) {
      print('[CachedPrefs] 📦 Cache HIT: $key');
      return _cache[key] as bool;
    }

    // Cache miss - lire depuis SharedPreferences
    _prefs ??= await SharedPreferences.getInstance();
    final value = _prefs!.getBool(key) ?? defaultValue;

    // Mettre en cache
    _cache[key] = value;
    _cacheTime[key] = DateTime.now();

    print('[CachedPrefs] 💾 Cache MISS: $key = $value');
    return value;
  }

  /// ⚡ Lire une valeur entière (avec cache)
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    if (_isCacheValid(key)) {
      return _cache[key] as int;
    }

    _prefs ??= await SharedPreferences.getInstance();
    final value = _prefs!.getInt(key) ?? defaultValue;

    _cache[key] = value;
    _cacheTime[key] = DateTime.now();

    return value;
  }

  /// ⚡ Lire une chaîne (avec cache)
  static Future<String> getString(String key, {String defaultValue = ''}) async {
    if (_isCacheValid(key)) {
      return _cache[key] as String;
    }

    _prefs ??= await SharedPreferences.getInstance();
    final value = _prefs!.getString(key) ?? defaultValue;

    _cache[key] = value;
    _cacheTime[key] = DateTime.now();

    return value;
  }

  /// ⚡ Lire une valeur double (avec cache)
  static Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    if (_isCacheValid(key)) {
      return _cache[key] as double;
    }

    _prefs ??= await SharedPreferences.getInstance();
    final value = _prefs!.getDouble(key) ?? defaultValue;

    _cache[key] = value;
    _cacheTime[key] = DateTime.now();

    return value;
  }

  /// ⚡ Lire une liste de chaînes (avec cache)
  static Future<List<String>> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) async {
    if (_isCacheValid(key)) {
      return _cache[key] as List<String>;
    }

    _prefs ??= await SharedPreferences.getInstance();
    final value = _prefs!.getStringList(key) ?? defaultValue;

    _cache[key] = value;
    _cacheTime[key] = DateTime.now();

    return value;
  }

  /// 💾 Écrire une valeur booléenne (et mettre à jour le cache)
  static Future<bool> setBool(String key, bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.setBool(key, value);

    if (success) {
      _cache[key] = value;
      _cacheTime[key] = DateTime.now();
    }

    return success;
  }

  /// 💾 Écrire une valeur entière (et mettre à jour le cache)
  static Future<bool> setInt(String key, int value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.setInt(key, value);

    if (success) {
      _cache[key] = value;
      _cacheTime[key] = DateTime.now();
    }

    return success;
  }

  /// 💾 Écrire une chaîne (et mettre à jour le cache)
  static Future<bool> setString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.setString(key, value);

    if (success) {
      _cache[key] = value;
      _cacheTime[key] = DateTime.now();
    }

    return success;
  }

  /// 💾 Écrire une valeur double (et mettre à jour le cache)
  static Future<bool> setDouble(String key, double value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.setDouble(key, value);

    if (success) {
      _cache[key] = value;
      _cacheTime[key] = DateTime.now();
    }

    return success;
  }

  /// 💾 Écrire une liste de chaînes (et mettre à jour le cache)
  static Future<bool> setStringList(String key, List<String> value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.setStringList(key, value);

    if (success) {
      _cache[key] = value;
      _cacheTime[key] = DateTime.now();
    }

    return success;
  }

  /// 🗑️ Supprimer une clé (et vider le cache)
  static Future<bool> remove(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.remove(key);

    if (success) {
      _cache.remove(key);
      _cacheTime.remove(key);
    }

    return success;
  }

  /// 🗑️ Tout effacer (et vider le cache)
  static Future<bool> clear() async {
    _prefs ??= await SharedPreferences.getInstance();
    final success = await _prefs!.clear();

    if (success) {
      _cache.clear();
      _cacheTime.clear();
    }

    return success;
  }

  /// 🔄 Invalider le cache d'une clé spécifique
  static void invalidateCache(String key) {
    _cache.remove(key);
    _cacheTime.remove(key);
    print('[CachedPrefs] 🔄 Cache invalidé: $key');
  }

  /// 🔄 Invalider tout le cache
  static void invalidateAllCache() {
    _cache.clear();
    _cacheTime.clear();
    print('[CachedPrefs] 🔄 Tout le cache invalidé');
  }

  /// ✅ Vérifier si une valeur est en cache et valide
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTime.containsKey(key)) {
      return false;
    }

    final age = DateTime.now().difference(_cacheTime[key]!);
    return age < _cacheDuration;
  }

  /// 📊 Obtenir les statistiques du cache
  static Map<String, dynamic> getCacheStats() {
    int validCache = 0;
    int expiredCache = 0;

    _cacheTime.forEach((key, time) {
      final age = DateTime.now().difference(time);
      if (age < _cacheDuration) {
        validCache++;
      } else {
        expiredCache++;
      }
    });

    return {
      'totalKeys': _cache.length,
      'validKeys': validCache,
      'expiredKeys': expiredCache,
      'cacheDuration': _cacheDuration.inSeconds,
      'keys': _cache.keys.toList(),
    };
  }

  /// 🧹 Nettoyer le cache expiré
  static void cleanExpiredCache() {
    final keysToRemove = <String>[];

    _cacheTime.forEach((key, time) {
      final age = DateTime.now().difference(time);
      if (age >= _cacheDuration) {
        keysToRemove.add(key);
      }
    });

    for (var key in keysToRemove) {
      _cache.remove(key);
      _cacheTime.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      print('[CachedPrefs] 🧹 ${keysToRemove.length} clés expirées nettoyées');
    }
  }
}






