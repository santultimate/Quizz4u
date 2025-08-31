import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

// Structure d'un record
class Record {
  final String playerName;
  final int score;
  final int totalQuestions;
  final String category;
  final DateTime date;
  final double accuracy;

  Record({
    required this.playerName,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.date,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'totalQuestions': totalQuestions,
      'category': category,
      'date': date.toIso8601String(),
      'accuracy': accuracy,
    };
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      playerName: json['playerName'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      accuracy: json['accuracy'].toDouble(),
    );
  }
}

class LeaderboardService {
  static const String _leaderboardKey = 'leaderboard_records';
  static const int _maxRecords = 10;

  // Sauvegarder un nouveau record
  static Future<bool> saveRecord({
    required String playerName,
    required int score,
    required int totalQuestions,
    required String category,
    required double accuracy,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_leaderboardKey) ?? [];

      // Convertir les records existants
      List<Record> records =
          recordsJson.map((json) => Record.fromJson(jsonDecode(json))).toList();

      // Créer le nouveau record
      final newRecord = Record(
        playerName: playerName,
        score: score,
        totalQuestions: totalQuestions,
        category: category,
        date: DateTime.now(),
        accuracy: accuracy,
      );

      // Ajouter le nouveau record
      records.add(newRecord);

      // Trier par score décroissant
      records.sort((a, b) => b.score.compareTo(a.score));

      // Garder seulement les meilleurs records
      if (records.length > _maxRecords) {
        records = records.take(_maxRecords).toList();
      }

      // Sauvegarder
      final newRecordsJson =
          records.map((record) => jsonEncode(record.toJson())).toList();

      await prefs.setStringList(_leaderboardKey, newRecordsJson);

      print(
          '[LeaderboardService] ✅ Record sauvegardé: $playerName - $score/$totalQuestions');
      return true;
    } catch (e) {
      print('[LeaderboardService] ❌ Erreur sauvegarde record: $e');
      return false;
    }
  }

  // Récupérer tous les records
  static Future<List<Record>> getRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_leaderboardKey) ?? [];

      List<Record> records =
          recordsJson.map((json) => Record.fromJson(jsonDecode(json))).toList();

      // Trier par score décroissant
      records.sort((a, b) => b.score.compareTo(a.score));

      return records;
    } catch (e) {
      print('[LeaderboardService] ❌ Erreur récupération records: $e');
      return [];
    }
  }

  // Récupérer les top 3 records
  static Future<List<Record>> getTop3Records() async {
    final records = await getRecords();
    return records.take(3).toList();
  }

  // Vérifier si un score est dans le top 3
  static Future<bool> isTop3Score(int score) async {
    final top3 = await getTop3Records();
    if (top3.length < 3) return true;
    return score > top3.last.score;
  }

  // Partager un score
  static Future<void> shareScore({
    required String playerName,
    required int score,
    required int totalQuestions,
    required String category,
    required double accuracy,
  }) async {
    try {
      final percentage = (score / totalQuestions * 100).toStringAsFixed(1);
      final date = DateTime.now().toString().split(' ')[0];

      final shareText = '''
🏆 Nouveau Record Quizz4U ! 🏆

👤 Joueur: $playerName
📊 Score: $score/$totalQuestions ($percentage%)
🎯 Catégorie: $category
📈 Précision: ${(accuracy * 100).toStringAsFixed(1)}%
📅 Date: $date

🎮 Télécharge Quizz4U et défie-moi !
📱 https://play.google.com/store/apps/details?id=com.quizz4u.app&pcampaignid=web_share

#Quizz4U #Quiz #Record
''';

      await Share.share(
        shareText,
        subject: 'Mon nouveau record sur Quizz4U !',
      );

      print('[LeaderboardService] ✅ Score partagé avec succès');
    } catch (e) {
      print('[LeaderboardService] ❌ Erreur partage score: $e');
    }
  }

  // Partager les top 3 records
  static Future<void> shareTop3Records() async {
    try {
      final top3 = await getTop3Records();

      if (top3.isEmpty) {
        print('[LeaderboardService] ⚠️ Aucun record à partager');
        return;
      }

      String shareText = '🏆 TOP 3 RECORDS QUIZZ4U 🏆\n\n';

      for (int i = 0; i < top3.length; i++) {
        final record = top3[i];
        final percentage =
            (record.score / record.totalQuestions * 100).toStringAsFixed(1);
        final date = record.date.toString().split(' ')[0];

        shareText += '''
🥇 ${i + 1}. ${record.playerName}
   📊 ${record.score}/${record.totalQuestions} ($percentage%)
   🎯 ${record.category}
   📅 $date
   
''';
      }

      shareText += '''
🎮 Télécharge Quizz4U et défie ces records !
#Quizz4U #Quiz #Leaderboard
''';

      await Share.share(
        shareText,
        subject: 'Top 3 Records Quizz4U',
      );

      print('[LeaderboardService] ✅ Top 3 records partagés');
    } catch (e) {
      print('[LeaderboardService] ❌ Erreur partage top 3: $e');
    }
  }

  // Effacer tous les records
  static Future<void> clearAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_leaderboardKey);
      print('[LeaderboardService] ✅ Tous les records effacés');
    } catch (e) {
      print('[LeaderboardService] ❌ Erreur effacement records: $e');
    }
  }
}
