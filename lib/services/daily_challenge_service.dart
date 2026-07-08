import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_challenge.dart';
import '../models/question_model.dart';
import 'progress_service.dart';
import 'question_service_optimized.dart';
import 'translation_service.dart'; // Importer pour traduire les messages

class DailyChallengeService {
  static const String _challengeKey = 'daily_challenge';
  static const String _streakKey = 'daily_streak';
  static const String _lastPlayedKey = 'last_daily_played';
  static const String _questionsKey = 'daily_challenge_questions';
  static const String _challengeCompletedKey = 'daily_challenge_completed';
  static const String _challengeStartTimeKey = 'daily_challenge_start_time';
  static const String _weekNumberKey = 'challenge_week_number';

  // 🆕 Constantes pour le cycle hebdomadaire
  static const int questionsPerDay = 5; // 5 questions par jour
  static const int daysInCycle = 7; // Cycle de 7 jours

  static DailyChallenge? _currentChallenge;
  static List<QuestionModel>? _currentChallengeQuestions;
  static int _streak = 0;
  static DateTime? _lastPlayed;
  static bool _isCompletedToday = false;
  static DateTime? _challengeStartTime;
  static int _currentWeekNumber = 0; // Numéro de la semaine dans le cycle

  // Initialiser le service
  static Future<void> initialize() async {
    await _loadChallenge();
    await _loadStreak();
    await _loadChallengeStatus();
  }

  // Obtenir le défi quotidien actuel
  static Future<DailyChallenge> getCurrentChallenge() async {
    if (_currentChallenge == null) {
      await _loadChallenge();
      if (_currentChallenge == null) {
        await _generateNewChallenge();
      }
    }
    return _currentChallenge!;
  }

  // Vérifier si le défi est disponible aujourd'hui
  static Future<bool> isChallengeAvailableToday() async {
    await _loadChallengeStatus();

    // Si le défi est déjà complété aujourd'hui, il n'est plus disponible
    if (_isCompletedToday) {
      return false;
    }

    // Vérifier si c'est un nouveau jour
    final today = DateTime.now();
    final lastPlayed = _lastPlayed;

    if (lastPlayed == null) {
      return true; // Premier jour
    }

    // Vérifier si c'est le même jour
    return _isSameDay(today, lastPlayed);
  }

  // Obtenir le temps restant pour le défi
  static Future<Duration?> getRemainingTime() async {
    if (_challengeStartTime == null || _isCompletedToday) {
      return null;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_challengeStartTime!);
    final timeLimit =
        _currentChallenge?.timeLimit ?? const Duration(minutes: 10);

    if (elapsed >= timeLimit) {
      // Le temps est écoulé
      await _markChallengeAsExpired();
      return Duration.zero;
    }

    return timeLimit - elapsed;
  }

  // Démarrer le défi (enregistrer l'heure de début)
  static Future<void> startChallenge() async {
    if (_isCompletedToday) {
      print('[DailyChallengeService] ⚠️ Défi déjà complété aujourd\'hui');
      return;
    }

    _challengeStartTime = DateTime.now();
    await _saveChallengeStatus();
    print('[DailyChallengeService] 🚀 Défi démarré à $_challengeStartTime');
  }

  // Marquer le défi comme complété
  static Future<void> markChallengeAsCompleted() async {
    _isCompletedToday = true;
    await _saveChallengeStatus();
    print('[DailyChallengeService] ✅ Défi marqué comme complété');
  }

  // Marquer le défi comme expiré
  static Future<void> _markChallengeAsExpired() async {
    _isCompletedToday = true;
    await _saveChallengeStatus();
    print('[DailyChallengeService] ⏰ Défi expiré - temps écoulé');
  }

  // 🆕 Obtenir le jour du cycle (1-7)
  static int _getDayOfCycle() {
    final now = DateTime.now();
    return now.weekday; // Lundi = 1, Dimanche = 7
  }

  // 🆕 Obtenir le numéro de la semaine de l'année
  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor();
  }

  // Générer un nouveau défi
  static Future<void> _generateNewChallenge() async {
    final dayOfCycle = _getDayOfCycle();
    final now = DateTime.now();
    _currentWeekNumber = _getWeekNumber(now);

    print(
        '[DailyChallengeService] 🆕 Génération défi - Jour $dayOfCycle/7 - Semaine $_currentWeekNumber');

    final baseChallenge = DailyChallengeGenerator.generateDailyChallenge();
    _currentChallenge = baseChallenge.copyWith(
      lastPlayedDate: now,
      progress: 0,
      targetScore: questionsPerDay, // 🆕 Toujours 5 questions par jour
    );

    // Générer les questions pour ce défi
    await _generateQuestionsForCurrentChallenge();

    await _saveChallenge();
    await _saveWeekNumber();
    print(
        '[DailyChallengeService] ✅ Défi généré: Jour $dayOfCycle - ${_currentChallengeQuestions?.length} questions');
  }

  // Charger le défi depuis SharedPreferences
  static Future<void> _loadChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final String? challengeJson = prefs.getString(_challengeKey);
    final String? lastPlayedJson = prefs.getString(_lastPlayedKey);

    if (challengeJson != null && lastPlayedJson != null) {
      final DailyChallenge loadedChallenge =
          DailyChallenge.fromJson(json.decode(challengeJson));
      final DateTime lastPlayedDate = DateTime.parse(lastPlayedJson);

      if (_isSameDay(lastPlayedDate, DateTime.now())) {
        _currentChallenge = loadedChallenge;
        print(
            '[DailyChallengeService] 🔄 Défi quotidien chargé: ${_currentChallenge!.titleKey}');
      } else {
        print(
            '[DailyChallengeService] 🗓️ Nouveau jour, génération d\'un nouveau défi...');
        await _generateNewChallenge();
      }
    } else {
      print(
          '[DailyChallengeService] ℹ️ Aucun défi trouvé, génération initiale...');
      await _generateNewChallenge();
    }
  }

  // Sauvegarder le défi dans SharedPreferences
  static Future<void> _saveChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _challengeKey, json.encode(_currentChallenge!.toJson()));
    await prefs.setString(
        _lastPlayedKey, _currentChallenge!.lastPlayedDate.toIso8601String());
  }

  // 🆕 Générer les questions pour le défi actuel avec seed stable
  static Future<void> _generateQuestionsForCurrentChallenge() async {
    if (_currentChallenge == null) return;

    try {
      final dayOfCycle = _getDayOfCycle();
      final weekNumber = _getWeekNumber(DateTime.now());

      // 🆕 Créer une seed stable basée sur le jour et la semaine
      // Même seed = mêmes questions pour ce jour du cycle
      final seed = dayOfCycle + (weekNumber * 1000);

      print(
          '[DailyChallengeService] 🎯 Génération questions - Jour $dayOfCycle - Seed: $seed');

      // S'assurer que les questions sont chargées
      if (!QuestionServiceOptimized.isLoaded) {
        await QuestionServiceOptimized.loadEssentialQuestions();
      }

      List<QuestionModel> allQuestions = [];

      // Pour chaque catégorie du défi, récupérer les questions
      for (String category in _currentChallenge!.categories) {
        print(
            '[DailyChallengeService] 📚 Chargement questions pour: $category');

        List<QuestionModel> categoryQuestions =
            QuestionServiceOptimized.getIntelligentQuestionsForCategory(
          category,
          count: 20,
        );

        if (categoryQuestions.isEmpty) {
          print(
              '[DailyChallengeService] ⚠️ Aucune question trouvée pour $category');
          categoryQuestions =
              QuestionServiceOptimized.getRandomQuestionsForCategory(
            category,
            20,
          );
        }

        allQuestions.addAll(categoryQuestions);
        print(
            '[DailyChallengeService] ✅ ${categoryQuestions.length} questions disponibles pour $category');
      }

      if (allQuestions.isEmpty) {
        print('[DailyChallengeService] ❌ Aucune question disponible !');
        _currentChallengeQuestions = [];
        return;
      }

      // 🆕 Mélanger avec une seed stable pour avoir les mêmes questions à chaque fois pour ce jour
      final random = Random(seed);
      for (int i = allQuestions.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = allQuestions[i];
        allQuestions[i] = allQuestions[j];
        allQuestions[j] = temp;
      }

      // 🆕 Prendre exactement 5 questions
      _currentChallengeQuestions = allQuestions.take(questionsPerDay).toList();

      print(
          '[DailyChallengeService] 🎯 ${_currentChallengeQuestions!.length} questions générées pour Jour $dayOfCycle/7');
    } catch (e) {
      print('[DailyChallengeService] ❌ Erreur génération questions: $e');
      _currentChallengeQuestions = [];
    }
  }

  // Mettre à jour la progression du défi
  static Future<void> updateProgress(int points) async {
    if (_currentChallenge != null && !_currentChallenge!.isCompleted) {
      final newProgress = _currentChallenge!.progress + points;
      if (newProgress >= _currentChallenge!.targetScore) {
        _currentChallenge = _currentChallenge!.copyWith(
          progress: _currentChallenge!.targetScore,
          isCompleted: true,
        );

        // Marquer le défi comme complété pour aujourd'hui
        await markChallengeAsCompleted();

        await _incrementStreak();

        // 🎁 BONUS DE COMPLÉTION : Récompense pour avoir TERMINÉ le défi
        // (L'XP des questions individuelles est déjà donné via ProgressService.addAnswer)
        const int completionBonus = 50;
        await ProgressService.addExperience(completionBonus,
            reason: TranslationService.translate('challenge_completion_bonus'));
        print(
            '[DailyChallengeService] 🎁 Bonus de complétion: +$completionBonus XP');

        // Ajouter les coins via l'XP (1 coin = 10 XP bonus)
        final coins = _currentChallenge!.rewards['Coins'] ?? 0;
        if (coins > 0) {
          await ProgressService.addExperience(coins * 10,
              reason:
                  'Coins ${TranslationService.translate('daily_challenge')}');
          print(
              '[DailyChallengeService] 💰 Bonus coins: +${coins * 10} XP ($coins coins)');
        }

        print(
            '[DailyChallengeService] 🎉 ${TranslationService.translate('daily_challenge')} terminé !');
      } else {
        _currentChallenge = _currentChallenge!.copyWith(progress: newProgress);
      }
      await _saveChallenge();
      print(
          '[DailyChallengeService] 📈 Progression défi: ${_currentChallenge!.progress}/${_currentChallenge!.targetScore}');
    }
  }

  // Incrémenter la série
  static Future<void> _incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastStreakDateString = prefs.getString('last_streak_date');
    DateTime? lastStreakDate = lastStreakDateString != null
        ? DateTime.parse(lastStreakDateString)
        : null;

    if (lastStreakDate == null ||
        DateTime.now().difference(lastStreakDate).inDays == 1) {
      _streak++;
      print('[DailyChallengeService] 🔥 Série incrémentée à $_streak');
    } else if (DateTime.now().difference(lastStreakDate).inDays > 1) {
      _streak = 1; // Réinitialiser si le jour n'est pas consécutif
      print('[DailyChallengeService] 💔 Série réinitialisée à 1');
    }
    await prefs.setInt(_streakKey, _streak);
    await prefs.setString('last_streak_date', DateTime.now().toIso8601String());
  }

  // Charger la série
  static Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _streak = prefs.getInt(_streakKey) ?? 0;
    _currentWeekNumber =
        prefs.getInt(_weekNumberKey) ?? _getWeekNumber(DateTime.now());
    print(
        '[DailyChallengeService] 🔥 Série chargée: $_streak - Semaine: $_currentWeekNumber');
  }

  // 🆕 Sauvegarder le numéro de la semaine
  static Future<void> _saveWeekNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weekNumberKey, _currentWeekNumber);
  }

  // Obtenir la série actuelle
  static Future<int> getStreak() async {
    if (_streak == 0) {
      final prefs = await SharedPreferences.getInstance();
      _streak = prefs.getInt(_streakKey) ?? 0;
    }
    return _streak;
  }

  // Vérifier si le défi d'aujourd'hui est terminé
  static Future<bool> isTodayCompleted() async {
    if (_currentChallenge == null) {
      await getCurrentChallenge();
    }
    return _currentChallenge?.isCompleted ?? false;
  }

  // Obtenir les statistiques des défis
  static Future<Map<String, dynamic>> getChallengeStats() async {
    final streak = await getStreak();
    final isCompleted = await isTodayCompleted();
    final progress = _currentChallenge?.progressPercentage ?? 0.0;

    return {
      'streak': streak,
      'isCompleted': isCompleted,
      'progress': progress,
      'currentChallenge': _currentChallenge,
    };
  }

  // Obtenir les questions pour le défi actuel
  static Future<List<QuestionModel>> getCurrentChallengeQuestions() async {
    try {
      // Si pas de questions chargées, les générer
      if (_currentChallengeQuestions == null ||
          _currentChallengeQuestions!.isEmpty) {
        await _generateQuestionsForCurrentChallenge();
      }

      return _currentChallengeQuestions ?? [];
    } catch (e) {
      print('[DailyChallengeService] ❌ Erreur récupération questions défi: $e');
      return [];
    }
  }

  // Vérifier si le défi a des questions disponibles
  static Future<bool> hasQuestionsAvailable() async {
    try {
      final questions = await getCurrentChallengeQuestions();
      return questions.isNotEmpty;
    } catch (e) {
      print('[DailyChallengeService] ❌ Erreur vérification questions: $e');
      return false;
    }
  }

  // Réinitialiser le défi (pour les tests)
  static Future<void> resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_challengeKey);
    await prefs.remove(_questionsKey);
    _currentChallenge = null;
    _currentChallengeQuestions = null;
    await _generateNewChallenge();
  }

  // Charger le statut du défi
  static Future<void> _loadChallengeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isCompletedToday = prefs.getBool(_challengeCompletedKey) ?? false;

      final startTimeStr = prefs.getString(_challengeStartTimeKey);
      if (startTimeStr != null) {
        _challengeStartTime = DateTime.parse(startTimeStr);
      }

      // Vérifier si c'est un nouveau jour et réinitialiser le statut
      final today = DateTime.now();
      final lastPlayed = _lastPlayed;

      if (lastPlayed != null && !_isSameDay(today, lastPlayed)) {
        // Nouveau jour - réinitialiser le statut
        _isCompletedToday = false;
        _challengeStartTime = null;
        await _saveChallengeStatus();
        print(
            '[DailyChallengeService] 🗓️ Nouveau jour - statut du défi réinitialisé');
      }
    } catch (e) {
      print('[DailyChallengeService] ❌ Erreur chargement statut: $e');
    }
  }

  // Sauvegarder le statut du défi
  static Future<void> _saveChallengeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_challengeCompletedKey, _isCompletedToday);

      if (_challengeStartTime != null) {
        await prefs.setString(
            _challengeStartTimeKey, _challengeStartTime!.toIso8601String());
      } else {
        await prefs.remove(_challengeStartTimeKey);
      }
    } catch (e) {
      print('[DailyChallengeService] ❌ Erreur sauvegarde statut: $e');
    }
  }

  // Vérifier si deux dates sont le même jour
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Obtenir les récompenses de série
  static Map<String, int> getStreakRewards(int streak) {
    if (streak >= 7) {
      return {
        'XP': 500,
        'Coins': 200
      }; // 🎉 Récompense hebdomadaire (cycle complet)
    } else if (streak >= 3) {
      return {'XP': 200, 'Coins': 100}; // Récompense de 3 jours
    } else {
      return {'XP': 50, 'Coins': 25}; // Récompense quotidienne
    }
  }

  // 🆕 Obtenir le jour actuel du cycle (1-7) et les infos du cycle
  static Map<String, dynamic> getCycleInfo() {
    final dayOfCycle = _getDayOfCycle();
    final weekNumber = _getWeekNumber(DateTime.now());

    // Noms des jours en français
    const dayNames = {
      1: 'Lundi',
      2: 'Mardi',
      3: 'Mercredi',
      4: 'Jeudi',
      5: 'Vendredi',
      6: 'Samedi',
      7: 'Dimanche',
    };

    return {
      'dayOfCycle': dayOfCycle,
      'dayName': dayNames[dayOfCycle] ?? 'Jour $dayOfCycle',
      'weekNumber': weekNumber,
      'questionsPerDay': questionsPerDay,
      'totalDays': daysInCycle,
    };
  }
}
