import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service de gestion des streaks (jours consécutifs de jeu)
class StreakService {
  static const String _streakKey = 'current_streak';
  static const String _lastPlayDateKey = 'last_play_date';
  static const String _longestStreakKey = 'longest_streak';
  static const String _totalDaysPlayedKey = 'total_days_played';

  /// Obtenir la streak actuelle
  static Future<int> getCurrentStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_streakKey) ?? 0;
    } catch (e) {
      Logger.error('StreakService', 'Erreur récupération streak actuelle', e);
      return 0;
    }
  }

  /// Obtenir la plus longue streak
  static Future<int> getLongestStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_longestStreakKey) ?? 0;
    } catch (e) {
      Logger.error(
          'StreakService', 'Erreur récupération plus longue streak', e);
      return 0;
    }
  }

  /// Obtenir le total de jours joués
  static Future<int> getTotalDaysPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_totalDaysPlayedKey) ?? 0;
    } catch (e) {
      Logger.error('StreakService', 'Erreur récupération total jours joués', e);
      return 0;
    }
  }

  /// Enregistrer une partie jouée aujourd'hui
  /// Retourne true si la streak continue, false si elle est réinitialisée
  static Future<bool> recordPlay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = _formatDate(today);

      final lastPlayDateString = prefs.getString(_lastPlayDateKey);

      if (lastPlayDateString == null) {
        // Première fois qu'on joue
        await prefs.setInt(_streakKey, 1);
        await prefs.setString(_lastPlayDateKey, todayString);
        await prefs.setInt(_totalDaysPlayedKey, 1);
        await prefs.setInt(_longestStreakKey, 1);
        Logger.info('StreakService', 'Premier jour de jeu enregistré');
        return true;
      }

      final lastPlayDate = DateTime.parse(lastPlayDateString);
      final daysDifference = today.difference(lastPlayDate).inDays;

      if (daysDifference == 0) {
        // Déjà joué aujourd'hui, streak continue
        Logger.info(
            'StreakService', 'Déjà joué aujourd\'hui, streak maintenue');
        return true;
      } else if (daysDifference == 1) {
        // Jours consécutifs - streak continue
        final currentStreak = (prefs.getInt(_streakKey) ?? 0) + 1;
        await prefs.setInt(_streakKey, currentStreak);
        await prefs.setString(_lastPlayDateKey, todayString);

        // Mettre à jour le total de jours joués
        final totalDays = (prefs.getInt(_totalDaysPlayedKey) ?? 0) + 1;
        await prefs.setInt(_totalDaysPlayedKey, totalDays);

        // Mettre à jour la plus longue streak si nécessaire
        final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
        if (currentStreak > longestStreak) {
          await prefs.setInt(_longestStreakKey, currentStreak);
          Logger.info('StreakService',
              'Nouvelle plus longue streak : $currentStreak jours');
        }

        Logger.success(
            'StreakService', 'Streak continue : $currentStreak jours');
        return true;
      } else {
        // Streak cassée - réinitialiser
        await prefs.setInt(_streakKey, 1);
        await prefs.setString(_lastPlayDateKey, todayString);

        // Mettre à jour le total de jours joués
        final totalDays = (prefs.getInt(_totalDaysPlayedKey) ?? 0) + 1;
        await prefs.setInt(_totalDaysPlayedKey, totalDays);

        Logger.warning('StreakService',
            'Streak réinitialisée (dernier jeu il y a $daysDifference jours)');
        return false;
      }
    } catch (e) {
      Logger.error('StreakService', 'Erreur enregistrement partie', e);
      return false;
    }
  }

  /// Vérifier si la streak est en danger (dernier jeu hier)
  static Future<bool> isStreakInDanger() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPlayDateString = prefs.getString(_lastPlayDateKey);

      if (lastPlayDateString == null) return false;

      final lastPlayDate = DateTime.parse(lastPlayDateString);
      final today = DateTime.now();
      final daysDifference = today.difference(lastPlayDate).inDays;

      // Streak en danger si dernière partie hier (sera cassée si on ne joue pas aujourd'hui)
      return daysDifference == 1;
    } catch (e) {
      Logger.error('StreakService', 'Erreur vérification danger streak', e);
      return false;
    }
  }

  /// Obtenir les statistiques complètes
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPlayDateString = prefs.getString(_lastPlayDateKey);

      return {
        'currentStreak': prefs.getInt(_streakKey) ?? 0,
        'longestStreak': prefs.getInt(_longestStreakKey) ?? 0,
        'totalDaysPlayed': prefs.getInt(_totalDaysPlayedKey) ?? 0,
        'lastPlayDate': lastPlayDateString,
        'isInDanger': await isStreakInDanger(),
      };
    } catch (e) {
      Logger.error('StreakService', 'Erreur récupération stats streak', e);
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'totalDaysPlayed': 0,
        'lastPlayDate': null,
        'isInDanger': false,
      };
    }
  }

  /// Réinitialiser toutes les stats de streak
  static Future<void> resetStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_streakKey);
      await prefs.remove(_lastPlayDateKey);
      await prefs.remove(_longestStreakKey);
      await prefs.remove(_totalDaysPlayedKey);
      Logger.info('StreakService', 'Streak réinitialisée');
    } catch (e) {
      Logger.error('StreakService', 'Erreur réinitialisation streak', e);
    }
  }

  /// Formater une date en string (YYYY-MM-DD)
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtenir le message de streak pour affichage
  static Future<String> getStreakMessage() async {
    final currentStreak = await getCurrentStreak();

    if (currentStreak == 0) {
      return 'Commencez votre série aujourd\'hui ! 🔥';
    } else if (currentStreak == 1) {
      return '1 jour consécutif ! Continuez ! 💪';
    } else if (currentStreak < 7) {
      return '$currentStreak jours consécutifs ! 🔥';
    } else if (currentStreak < 30) {
      return '$currentStreak jours consécutifs ! Impressionnant ! 🌟';
    } else if (currentStreak < 100) {
      return '$currentStreak jours consécutifs ! Incroyable ! 🏆';
    } else {
      return '$currentStreak jours consécutifs ! LÉGENDAIRE ! 👑';
    }
  }
}
