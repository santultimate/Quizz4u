import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import 'localization_service.dart'; // Pour détecter la langue courante

/// ⚡ QuestionService Optimisé - Fix ANR Google Play Console
///
/// Corrections critiques:
/// 1. Utilisation de compute() pour JSON lourd (évite blocage thread UI)
/// 2. Chargement progressif (catégories essentielles d'abord)
/// 3. Timeouts sur toutes les opérations
/// 4. Cache en mémoire
class QuestionServiceOptimized {
  static final Map<String, List<QuestionModel>> _allQuestions = {};
  static bool _isLoaded = false;
  static bool _isLoadingInProgress = false;
  static String _currentLanguage = 'fr'; // Langue par défaut

  // Historique des questions récemment utilisées
  static final Map<String, List<String>> _recentlyUsedQuestions = {};
  static final Map<String, DateTime> _lastPlayedDates = {};

  static const int _maxRecentlyUsed = 15;

  // ⚡ Configuration des catégories essentielles (chargées en priorité)
  static const List<String> _essentialCategories = [
    'Culture générale',
    'Sciences',
  ];

  // Définir les catégories et leurs fichiers
  static const Map<String, String> categoryFiles = {
    'Histoire du Mali': 'assets/questions/enriched_history_questions.json',
    'Culture générale': 'assets/questions/enriched_culture_questions.json',
    'Sciences': 'assets/questions/enriched_science_questions.json',
    'Mathématiques': 'assets/questions/math_questions.json',
    'Afrique': 'assets/questions/africa_questions.json',
    'Football': 'assets/questions/football_questions.json',
    'Musique': 'assets/questions/music_questions.json',
    'Arts et Culture': 'assets/questions/arts_culture_questions_expansion.json',
    'Politique et Économie':
        'assets/questions/politics_economy_questions_expansion.json',
    'Technologie et Innovation':
        'assets/questions/technology_questions_expansion.json',
    'Santé et Médecine':
        'assets/questions/health_medicine_questions_expansion.json',
    'Environnement et Écologie':
        'assets/questions/environment_questions_expansion.json',
  };

  /// 🌍 Catégories qui ont des traductions disponibles
  static const List<String> _categoriesWithTranslations = [
    // Catégories expansion (5)
    'Arts et Culture',
    'Politique et Économie',
    'Technologie et Innovation',
    'Santé et Médecine',
    'Environnement et Écologie',
    // 🆕 Nouvelles traductions intégrales (7) - 27 Oct 2025
    'Histoire du Mali',
    'Culture générale',
    'Sciences',
    'Mathématiques',
    'Afrique',
    'Football',
    'Musique',
  ];

  /// 🌍 Mettre à jour la langue courante
  static Future<void> updateCurrentLanguage() async {
    _currentLanguage = await LocalizationService.getCurrentLanguage();
    print('[QuestionServiceOpt] 🌍 Langue mise à jour: $_currentLanguage');
  }

  /// 🌍 Obtenir le nom du fichier traduit selon la langue actuelle
  static String _getTranslatedFilePath(String category, String originalPath) {
    // Vérifier si cette catégorie a des traductions
    if (!_categoriesWithTranslations.contains(category)) {
      return originalPath; // Pas de traduction, garder le fichier original
    }

    // Utiliser la langue courante stockée
    if (_currentLanguage == 'fr') {
      return originalPath; // Français = fichier original
    }

    // Convertir le code de langue (français -> arabe, etc.)
    final Map<String, String> langCodes = {
      'ar': 'ar',
      'en': 'en',
      'zh': 'zh',
      'hi': 'hi',
      'es': 'es',
    };

    final String? langCode = langCodes[_currentLanguage];
    if (langCode == null) {
      return originalPath; // Langue non supportée, garder le français
    }

    // Construire le nom du fichier traduit: file_ar.json
    final String translatedPath =
        originalPath.replaceAll('.json', '_$langCode.json');
    print('[QuestionServiceOpt] 🌍 Fichier traduit: $translatedPath');
    return translatedPath;
  }

  /// ⚡ Fonction statique pour décodage JSON dans isolate
  static Map<String, dynamic> _parseJsonString(String jsonString) {
    return json.decode(jsonString);
  }

  /// ⚡ ÉTAPE 1: Charger seulement les catégories essentielles (< 3 secondes)
  static Future<void> loadEssentialQuestions() async {
    if (_isLoaded) return;
    if (_isLoadingInProgress) {
      print('[QuestionServiceOpt] ⚠️ Chargement déjà en cours');
      return;
    }

    _isLoadingInProgress = true;

    try {
      // 🌍 Mettre à jour la langue courante avant de charger
      await updateCurrentLanguage();

      print(
          '[QuestionServiceOpt] ⚡ Chargement rapide (catégories essentielles)...');
      final startTime = DateTime.now();

      // Charger seulement les catégories essentielles
      for (String category in _essentialCategories) {
        if (categoryFiles.containsKey(category)) {
          await _loadCategory(category, categoryFiles[category]!).timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              print('[QuestionServiceOpt] ⚠️ Timeout $category - Ignoré');
              _allQuestions[category] = [];
              _recentlyUsedQuestions[category] = [];
              _lastPlayedDates[category] = DateTime.now();
            },
          );
        }
      }

      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      print(
          '[QuestionServiceOpt] ✅ Catégories essentielles chargées en ${loadTime}ms');

      _isLoaded = true;
      _isLoadingInProgress = false;

      // ⚡ Charger le reste en arrière-plan (non-bloquant)
      _loadRemainingCategoriesInBackground();
    } catch (e, stack) {
      print('[QuestionServiceOpt] ❌ Erreur chargement essentiel: $e');
      print(stack);
      _isLoadingInProgress = false;

      // Fallback: créer des catégories vides
      for (String category in _essentialCategories) {
        _allQuestions[category] ??= [];
        _recentlyUsedQuestions[category] ??= [];
        _lastPlayedDates[category] ??= DateTime.now();
      }
    }
  }

  /// ⚡ ÉTAPE 2: Charger les catégories restantes en arrière-plan
  static void _loadRemainingCategoriesInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      print('[QuestionServiceOpt] 🔄 Chargement catégories secondaires...');

      for (String category in categoryFiles.keys) {
        if (!_essentialCategories.contains(category)) {
          try {
            await _loadCategory(category, categoryFiles[category]!).timeout(
              const Duration(seconds: 4),
              onTimeout: () {
                print('[QuestionServiceOpt] ⚠️ Timeout $category');
                _allQuestions[category] = [];
              },
            );
          } catch (e) {
            print('[QuestionServiceOpt] ❌ Erreur $category: $e');
            _allQuestions[category] = [];
          }
        }
      }

      print('[QuestionServiceOpt] ✅ Toutes les catégories chargées');
      _allCategoriesLoaded = true;
    });
  }

  /// ⚡ Charger une catégorie avec compute() pour éviter blocage UI
  static Future<void> _loadCategory(String category, String filePath) async {
    try {
      // 🌍 Obtenir le fichier traduit si disponible
      final String translatedFilePath =
          _getTranslatedFilePath(category, filePath);

      // 1. Charger le fichier JSON (I/O asynchrone) - avec fallback au français si erreur
      String jsonString;
      try {
        jsonString = await rootBundle.loadString(translatedFilePath);
        print(
            '[QuestionServiceOpt] ✅ Fichier traduit chargé: $translatedFilePath');
      } catch (e) {
        // Fallback au fichier français si le fichier traduit n'existe pas
        print(
            '[QuestionServiceOpt] ⚠️ Fichier traduit non trouvé, fallback au français');
        jsonString = await rootBundle.loadString(filePath);
      }

      // 2. ✅ Décodage dans un isolate séparé (évite blocage UI)
      final dynamic jsonData = await compute(_parseJsonString, jsonString);

      // 3. Parser les questions
      List<QuestionModel> questions = [];
      List<dynamic> questionsList = [];

      // Gérer les différents formats possibles
      if (jsonData is List) {
        // Format 1: Array direct
        questionsList = jsonData;
      } else if (jsonData is Map) {
        // Format 2: Map avec catégorie
        // Pour les fichiers traduits, la clé peut être traduite (ex: "艺术与文化" au lieu de "Arts et Culture")
        // On cherche d'abord avec le nom français, sinon on prend la première clé
        String? categoryKey = category;
        if (!jsonData.containsKey(category)) {
          // Prendre la première clé du Map (qui devrait être la catégorie traduite)
          if (jsonData.keys.isNotEmpty) {
            categoryKey = jsonData.keys.first;
            print(
                '[QuestionServiceOpt] 🌍 Catégorie traduite: $categoryKey (au lieu de $category)');
          }
        }

        if (categoryKey != null && jsonData.containsKey(categoryKey)) {
          var categoryData = jsonData[categoryKey];

          // Format 2A: {"Category": [...]}
          if (categoryData is List) {
            questionsList = categoryData;
          }
          // Format 2B: {"Category": {"Subcategory": [...]}}
          else if (categoryData is Map) {
            // Parcourir toutes les sous-catégories
            categoryData.forEach((subcategoryName, subcategoryQuestions) {
              if (subcategoryQuestions is List) {
                questionsList.addAll(subcategoryQuestions);
              }
            });
          }
        }
      }

      if (questionsList.isEmpty) {
        print('[QuestionServiceOpt] ⚠️ Aucune question trouvée pour $category');
        _allQuestions[category] = [];
        _recentlyUsedQuestions[category] = [];
        _lastPlayedDates[category] = DateTime.now();
        return;
      }

      // Parser chaque question
      for (var questionData in questionsList) {
        try {
          Map<String, bool> answers = {};
          String correctAnswer = '';

          // Format 1: answers = {"answer": true/false}
          if (questionData.containsKey('answers') &&
              questionData['answers'] is Map) {
            questionData['answers'].forEach((key, value) {
              answers[key] = value;
            });
            answers.forEach((key, value) {
              if (value == true) correctAnswer = key;
            });
          }
          // Format 2: options = ["answer1", "answer2"], correctAnswer = "answer1"
          else if (questionData.containsKey('options') &&
              questionData['options'] is List) {
            correctAnswer = questionData['correctAnswer'] ?? '';
            for (var option in questionData['options']) {
              answers[option.toString()] = option.toString() == correctAnswer;
            }
          } else {
            print('[QuestionServiceOpt] ⚠️ Format de réponses non reconnu');
            continue;
          }

          if (correctAnswer.isEmpty) {
            print('[QuestionServiceOpt] ⚠️ Pas de bonne réponse trouvée');
            continue;
          }

          questions.add(
            QuestionModel(
              id: questionData['id']?.toString(),
              question: questionData['question'] ?? '',
              answers: answers,
              correctAnswer: correctAnswer,
              explanation: questionData['explanation'] ?? '',
              difficulty: questionData['difficulty'] ?? 'medium',
              subcategory: questionData['subcategory'] ?? '',
            ),
          );
        } catch (e) {
          // Ignorer les questions malformées
          print('[QuestionServiceOpt] ⚠️ Question invalide ignorée: $e');
        }
      }

      _allQuestions[category] = questions;
      _recentlyUsedQuestions[category] = [];
      _lastPlayedDates[category] = DateTime.now();

      print('[QuestionServiceOpt] ✅ $category: ${questions.length} questions');
    } catch (e) {
      print('[QuestionServiceOpt] ❌ Erreur $category: $e');
      _allQuestions[category] = [];
      _recentlyUsedQuestions[category] = [];
      _lastPlayedDates[category] = DateTime.now();
    }
  }

  static bool _allCategoriesLoaded = false;

  /// Attendre que toutes les catégories soient chargées (max [timeout]).
  static Future<void> waitForAllCategories({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (_allCategoriesLoaded) return;

    final deadline = DateTime.now().add(timeout);
    while (!_allCategoriesLoaded && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Garantir qu'une catégorie est prête avant le quiz (évite race condition).
  static Future<void> ensureCategoryReady(String category) async {
    await waitForAllCategories();

    if (_allQuestions.containsKey(category) &&
        _allQuestions[category]!.isNotEmpty) {
      return;
    }

    final filePath = categoryFiles[category];
    if (filePath == null) {
      print('[QuestionServiceOpt] ⚠️ Catégorie inconnue: $category');
      return;
    }

    await _loadCategory(category, filePath);
  }

  /// Obtenir questions aléatoires pour une catégorie
  /// [preferredDifficulty]: 'facile'|'moyen'|'difficile' (settings) ou null
  static List<QuestionModel> getRandomQuestionsForCategory(
    String category,
    int count, {
    String? preferredDifficulty,
  }) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      print('[QuestionServiceOpt] ⚠️ Catégorie $category non chargée');
      return [];
    }

    List<QuestionModel> allQuestionsInCategory = _allQuestions[category]!;

    if (allQuestionsInCategory.isEmpty) {
      print('[QuestionServiceOpt] ⚠️ Aucune question dans $category');
      return [];
    }

    // Filtrer les questions récemment utilisées
    List<QuestionModel> availableQuestions = allQuestionsInCategory.where((q) {
      return !_recentlyUsedQuestions[category]!.contains(q.id);
    }).toList();

    // Si pas assez de questions disponibles, réinitialiser l'historique
    if (availableQuestions.length < count) {
      print('[QuestionServiceOpt] 🔄 Réinitialisation historique $category');
      _recentlyUsedQuestions[category]!.clear();
      availableQuestions = List<QuestionModel>.from(allQuestionsInCategory);
    }

    // Filtre difficulté (souple) : prioriser le niveau choisi, compléter sinon
    if (preferredDifficulty != null && preferredDifficulty.isNotEmpty) {
      final target = _normalizeDifficulty(preferredDifficulty);
      final preferred = availableQuestions
          .where((q) => _normalizeDifficulty(q.difficulty) == target)
          .toList();
      if (preferred.length >= count) {
        availableQuestions = preferred;
      } else if (preferred.isNotEmpty) {
        final others = availableQuestions
            .where((q) => _normalizeDifficulty(q.difficulty) != target)
            .toList()
          ..shuffle(Random());
        availableQuestions = [...preferred, ...others];
      }
    }

    // Mélanger et sélectionner
    availableQuestions.shuffle(Random());
    int questionsToSelect = min(count, availableQuestions.length);
    List<QuestionModel> selectedQuestions =
        availableQuestions.sublist(0, questionsToSelect);

    // Mettre à jour l'historique
    for (var question in selectedQuestions) {
      _recentlyUsedQuestions[category]!.add(question.id);
      if (_recentlyUsedQuestions[category]!.length > _maxRecentlyUsed) {
        _recentlyUsedQuestions[category]!.removeAt(0);
      }
    }

    print('[QuestionServiceOpt] ✅ $questionsToSelect questions pour $category'
        '${preferredDifficulty != null ? " (diff=$preferredDifficulty)" : ""}');
    return selectedQuestions;
  }

  static String _normalizeDifficulty(String? raw) {
    final d = (raw ?? 'medium').toLowerCase().trim();
    switch (d) {
      case 'facile':
      case 'easy':
      case 'e':
        return 'easy';
      case 'difficile':
      case 'hard':
      case 'h':
        return 'hard';
      case 'moyen':
      case 'medium':
      case 'm':
      default:
        return 'medium';
    }
  }

  /// Trouver une question par id dans une catégorie.
  static QuestionModel? findQuestionById(String category, String id) {
    final list = _allQuestions[category];
    if (list == null) return null;
    for (final q in list) {
      if (q.id == id) return q;
    }
    return null;
  }

  /// Obtenir toutes les catégories disponibles
  static List<String> getAllCategories() {
    return _allQuestions.keys.toList();
  }

  /// Obtenir le nombre total de questions
  static int getTotalQuestionCount() {
    return _allQuestions.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Obtenir le nombre de questions pour une catégorie
  static int getQuestionCountForCategory(String category) {
    return _allQuestions[category]?.length ?? 0;
  }

  /// Vérifier si les questions sont chargées
  static bool get isLoaded => _isLoaded;

  /// Réinitialiser l'historique pour une catégorie
  static void resetHistoryForCategory(String category) {
    if (_recentlyUsedQuestions.containsKey(category)) {
      _recentlyUsedQuestions[category]!.clear();
      print('[QuestionServiceOpt] 🔄 Historique réinitialisé: $category');
    }
  }

  /// Réinitialiser tout l'historique
  static void resetAllHistory() {
    _recentlyUsedQuestions.forEach((key, value) {
      value.clear();
    });
    print('[QuestionServiceOpt] 🔄 Historique global réinitialisé');
  }

  /// 🌍 Recharger les questions pour une nouvelle langue
  static Future<void> reloadQuestionsForLanguage(String newLanguage) async {
    print(
        '[QuestionServiceOpt] 🌍 Rechargement questions pour langue: $newLanguage');

    // Réinitialiser l'état
    _isLoaded = false;
    _isLoadingInProgress = false;
    _allCategoriesLoaded = false;
    _currentLanguage = newLanguage;
    _allQuestions.clear();
    _recentlyUsedQuestions.clear();
    _lastPlayedDates.clear();

    // Recharger les catégories essentielles
    // ⚠️ Note: loadEssentialQuestions() appelle déjà _loadRemainingCategoriesInBackground()
    // donc pas besoin de l'appeler ici pour éviter la duplication
    await loadEssentialQuestions();

    print('[QuestionServiceOpt] ✅ Questions rechargées en $_currentLanguage');
  }

  /// Obtenir les statistiques de chargement
  static Map<String, dynamic> getLoadingStats() {
    return {
      'isLoaded': _isLoaded,
      'isLoadingInProgress': _isLoadingInProgress,
      'categoriesCount': _allQuestions.length,
      'totalQuestions': getTotalQuestionCount(),
      'categoriesLoaded': _allQuestions.keys.toList(),
    };
  }

  /// ⚡ Méthodes de compatibilité avec l'ancien QuestionService

  /// Obtenir toutes les questions d'une catégorie
  static List<QuestionModel> getAllQuestionsForCategory(String category) {
    return _allQuestions[category] ?? [];
  }

  /// Obtenir des questions intelligentes (alias de getRandomQuestionsForCategory)
  static List<QuestionModel> getIntelligentQuestionsForCategory(
    String category, {
    required int count,
  }) {
    return getRandomQuestionsForCategory(category, count);
  }

  /// Obtenir des questions smart (alias de getRandomQuestionsForCategory)
  static List<QuestionModel> getSmartQuestionsForCategory(
    String category, {
    required int count,
  }) {
    return getRandomQuestionsForCategory(category, count);
  }
}
