import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GameResumeService {
  static const String _gameStateKey = 'paused_game_state';
  static const String _gameTimestampKey = 'paused_game_timestamp';
  static const int _maxPauseDuration = 30; // 30 minutes maximum

  // État du jeu en pause
  static Future<void> saveGameState({
    required String category,
    required int currentQuestionIndex,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required List<String> questions,
    required List<String> userAnswers,
    required List<bool> isCorrect,
    required double timeRemaining,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    Map<String, dynamic> gameState = {
      'category': category,
      'currentQuestionIndex': currentQuestionIndex,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'questions': questions,
      'userAnswers': userAnswers,
      'isCorrect': isCorrect,
      'timeRemaining': timeRemaining,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_gameStateKey, jsonEncode(gameState));
    await prefs.setString(_gameTimestampKey, DateTime.now().toIso8601String());
    
    print('[GameResumeService] 💾 État du jeu sauvegardé pour $category');
  }

  // Vérifier s'il y a un jeu en pause
  static Future<bool> hasPausedGame() async {
    final prefs = await SharedPreferences.getInstance();
    String? gameState = prefs.getString(_gameStateKey);
    String? timestamp = prefs.getString(_gameTimestampKey);
    
    if (gameState == null || timestamp == null) {
      return false;
    }

    // Vérifier si le jeu n'est pas trop ancien
    DateTime pauseTime = DateTime.parse(timestamp);
    int minutesSincePause = DateTime.now().difference(pauseTime).inMinutes;
    
    if (minutesSincePause > _maxPauseDuration) {
      // Supprimer l'ancien état
      await clearPausedGame();
      return false;
    }

    return true;
  }

  // Récupérer l'état du jeu en pause
  static Future<Map<String, dynamic>?> getPausedGameState() async {
    final prefs = await SharedPreferences.getInstance();
    String? gameStateJson = prefs.getString(_gameStateKey);
    
    if (gameStateJson == null) {
      return null;
    }

    try {
      Map<String, dynamic> gameState = jsonDecode(gameStateJson);
      
      // Vérifier la validité de l'état
      if (!_isValidGameState(gameState)) {
        await clearPausedGame();
        return null;
      }

      return gameState;
    } catch (e) {
      print('[GameResumeService] ❌ Erreur lors du décodage de l\'état: $e');
      await clearPausedGame();
      return null;
    }
  }

  // Vérifier la validité de l'état du jeu
  static bool _isValidGameState(Map<String, dynamic> gameState) {
    List<String> requiredFields = [
      'category',
      'currentQuestionIndex',
      'score',
      'correctAnswers',
      'totalQuestions',
      'questions',
      'userAnswers',
      'isCorrect',
      'timeRemaining',
    ];

    for (String field in requiredFields) {
      if (!gameState.containsKey(field)) {
        return false;
      }
    }

    // Vérifier que les listes ont la bonne taille
    List questions = gameState['questions'] ?? [];
    List userAnswers = gameState['userAnswers'] ?? [];
    List isCorrect = gameState['isCorrect'] ?? [];
    
    if (questions.length != userAnswers.length || 
        questions.length != isCorrect.length) {
      return false;
    }

    return true;
  }

  // Effacer l'état du jeu en pause
  static Future<void> clearPausedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
    await prefs.remove(_gameTimestampKey);
    print('[GameResumeService] 🗑️ État du jeu en pause effacé');
  }

  // Afficher le dialogue de reprise
  static Future<bool> showResumeDialog(BuildContext context) async {
    Map<String, dynamic>? gameState = await getPausedGameState();
    
    if (gameState == null) {
      return false;
    }

    String category = gameState['category'] ?? 'Inconnue';
    int currentQuestion = gameState['currentQuestionIndex'] ?? 0;
    int totalQuestions = gameState['totalQuestions'] ?? 10;
    int score = gameState['score'] ?? 0;
    int correctAnswers = gameState['correctAnswers'] ?? 0;
    
    // Calculer le temps écoulé depuis la pause
    String timestamp = gameState['timestamp'] ?? '';
    String timeElapsed = '';
    if (timestamp.isNotEmpty) {
      DateTime pauseTime = DateTime.parse(timestamp);
      Duration elapsed = DateTime.now().difference(pauseTime);
      int minutes = elapsed.inMinutes;
      int seconds = elapsed.inSeconds % 60;
      timeElapsed = '${minutes}m ${seconds}s';
    }

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.play_circle, color: Colors.green, size: 30),
            const SizedBox(width: 10),
            const Text(
              'Reprendre le Jeu ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie: $category',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),
            Text('Progression: ${currentQuestion + 1}/$totalQuestions questions'),
            Text('Score actuel: $score points'),
            Text('Bonnes réponses: $correctAnswers/$currentQuestion'),
            if (timeElapsed.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                'Temps écoulé: $timeElapsed',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: const Text(
                'Voulez-vous reprendre votre partie en cours ?',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Ne pas reprendre
            },
            child: const Text('Nouvelle Partie'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Reprendre
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reprendre'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Obtenir les informations du jeu en pause
  static Future<Map<String, dynamic>> getPausedGameInfo() async {
    Map<String, dynamic>? gameState = await getPausedGameState();
    
    if (gameState == null) {
      return {};
    }

    String category = gameState['category'] ?? 'Inconnue';
    int currentQuestion = gameState['currentQuestionIndex'] ?? 0;
    int totalQuestions = gameState['totalQuestions'] ?? 10;
    int score = gameState['score'] ?? 0;
    int correctAnswers = gameState['correctAnswers'] ?? 0;
    
    // Calculer le temps écoulé
    String timestamp = gameState['timestamp'] ?? '';
    String timeElapsed = '';
    if (timestamp.isNotEmpty) {
      DateTime pauseTime = DateTime.parse(timestamp);
      Duration elapsed = DateTime.now().difference(pauseTime);
      int minutes = elapsed.inMinutes;
      int seconds = elapsed.inSeconds % 60;
      timeElapsed = '${minutes}m ${seconds}s';
    }

    return {
      'category': category,
      'currentQuestion': currentQuestion,
      'totalQuestions': totalQuestions,
      'score': score,
      'correctAnswers': correctAnswers,
      'progress': (currentQuestion / totalQuestions * 100).toStringAsFixed(1),
      'timeElapsed': timeElapsed,
      'canResume': true,
    };
  }

  // Vérifier si le jeu peut être repris
  static Future<bool> canResumeGame() async {
    if (!await hasPausedGame()) {
      return false;
    }

    Map<String, dynamic>? gameState = await getPausedGameState();
    if (gameState == null) {
      return false;
    }

    // Vérifier que le jeu n'est pas terminé
    int currentQuestion = gameState['currentQuestionIndex'] ?? 0;
    int totalQuestions = gameState['totalQuestions'] ?? 10;
    
    return currentQuestion < totalQuestions;
  }

  // Obtenir le temps restant avant expiration
  static Future<String> getTimeUntilExpiration() async {
    final prefs = await SharedPreferences.getInstance();
    String? timestamp = prefs.getString(_gameTimestampKey);
    
    if (timestamp == null) {
      return '';
    }

    DateTime pauseTime = DateTime.parse(timestamp);
    DateTime expirationTime = pauseTime.add(Duration(minutes: _maxPauseDuration));
    Duration remaining = expirationTime.difference(DateTime.now());
    
    if (remaining.isNegative) {
      return 'Expiré';
    }

    int minutes = remaining.inMinutes;
    int seconds = remaining.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
