import 'dart:convert';
import 'dart:math';
import 'dart:math' show min;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';

class QuestionService {
  static final Map<String, List<QuestionModel>> _allQuestions = {};
  static bool _isLoaded = false;

  // Historique des questions récemment utilisées (pour éviter les répétitions)
  static final Map<String, List<String>> _recentlyUsedQuestions = {};
  static final Map<String, DateTime> _lastPlayedDates = {};

  // Configuration pour la variété des questions
  static const int _maxRecentlyUsed =
      20; // Questions récemment utilisées à éviter
  static const int _cooldownDays =
      3; // Jours avant de pouvoir rejouer une question
  static const int _preferredVarietyThreshold =
      50; // Seuil pour forcer la variété

  // Charger toutes les questions depuis les fichiers JSON séparés
  static Future<void> loadQuestions() async {
    if (_isLoaded) return;

    try {
      print('[QuestionService] 📚 Début du chargement des questions...');

      // Définir les catégories et leurs fichiers correspondants
      Map<String, String> categoryFiles = {
        'Histoire du Mali': 'assets/questions/mali_history_questions.json',
        'Culture générale': 'assets/questions/general_culture_questions.json',
        'Sciences': 'assets/questions/science_questions.json',
        'Mathématiques': 'assets/questions/math_questions.json',
        'Afrique': 'assets/questions/africa_questions.json',
      };

      // ÉTAPE 1: Charger les catégories de base (format simple)
      for (String category in categoryFiles.keys) {
        try {
          final String jsonString = await rootBundle.loadString(
            categoryFiles[category]!,
          );
          final List<dynamic> questionsList = json.decode(jsonString);

          List<QuestionModel> questions = [];

          for (var questionData in questionsList) {
            Map<String, bool> answers = {};
            questionData['answers'].forEach((key, value) {
              answers[key] = value;
            });

            questions.add(
              QuestionModel(
                question: questionData['question'],
                answers: answers,
                correctAnswer: questionData['correctAnswer'],
              ),
            );
          }

          _allQuestions[category] = questions;

          // Initialiser l'historique pour cette catégorie
          _recentlyUsedQuestions[category] = [];
          _lastPlayedDates[category] = DateTime.now();

          print(
              '[QuestionService] ✅ Catégorie $category chargée: ${questions.length} questions');
        } catch (e) {
          print('Erreur lors du chargement de la catégorie $category: $e');
        }
      }

      // ÉTAPE 2: Charger les questions d'extension pour les catégories existantes
      try {
        final String extensionJsonString = await rootBundle.loadString(
          'assets/questions/questions_extension_phase1.json',
        );
        final Map<String, dynamic> extensionData =
            json.decode(extensionJsonString);

        for (String category in extensionData.keys) {
          if (_allQuestions.containsKey(category)) {
            List<QuestionModel> extensionQuestions = [];

            // Gérer le format avec sous-catégories
            if (extensionData[category] is Map) {
              Map<String, dynamic> subcategories = extensionData[category];

              for (String subcategory in subcategories.keys) {
                List<dynamic> questionsList = subcategories[subcategory];

                for (var questionData in questionsList) {
                  Map<String, bool> answers = {};

                  // Gérer les deux formats : 'options' et 'answers'
                  List<dynamic> options =
                      questionData['options'] ?? questionData['answers'] ?? [];

                  for (int i = 0; i < options.length; i++) {
                    String option = options[i];
                    answers[option] = option == questionData['correctAnswer'];
                  }

                  extensionQuestions.add(
                    QuestionModel(
                      question: questionData['question'],
                      answers: answers,
                      correctAnswer: questionData['correctAnswer'],
                      explanation: questionData['explanation'],
                      difficulty: questionData['difficulty'],
                      subcategory: questionData['subcategory'],
                    ),
                  );
                }
              }
            } else {
              // Format simple (liste directe)
              List<dynamic> questionsList = extensionData[category];

              for (var questionData in questionsList) {
                Map<String, bool> answers = {};

                // Gérer les deux formats : 'options' et 'answers'
                List<dynamic> options =
                    questionData['options'] ?? questionData['answers'] ?? [];

                for (int i = 0; i < options.length; i++) {
                  String option = options[i];
                  answers[option] = option == questionData['correctAnswer'];
                }

                extensionQuestions.add(
                  QuestionModel(
                    question: questionData['question'],
                    answers: answers,
                    correctAnswer: questionData['correctAnswer'],
                    explanation: questionData['explanation'],
                    difficulty: questionData['difficulty'],
                  ),
                );
              }
            }

            _allQuestions[category]!.addAll(extensionQuestions);
            print(
                '[QuestionService] 📚 ${extensionQuestions.length} questions d\'extension ajoutées à $category');
          }
        }
      } catch (e) {
        print(
            '[QuestionService] ⚠️ Erreur lors du chargement des extensions: $e');
      }

      // ÉTAPE 3: Charger les nouvelles catégories de la Phase 2
      try {
        final String phase2JsonString = await rootBundle.loadString(
          'assets/questions/phase2_new_categories.json',
        );
        final Map<String, dynamic> phase2Data = json.decode(phase2JsonString);

        for (String category in phase2Data.keys) {
          // Vérifier si la catégorie existe déjà
          if (_allQuestions.containsKey(category)) {
            print(
                '[QuestionService] ⚠️ Catégorie $category existe déjà, ignorée');
            continue; // Ignorer les doublons
          }

          List<QuestionModel> phase2Questions = [];

          for (String subcategory in phase2Data[category].keys) {
            List<dynamic> subcategoryQuestions =
                phase2Data[category][subcategory];

            for (var questionData in subcategoryQuestions) {
              Map<String, bool> answers = {};
              for (int i = 0; i < questionData['options'].length; i++) {
                String option = questionData['options'][i];
                answers[option] = option == questionData['correctAnswer'];
              }

              phase2Questions.add(
                QuestionModel(
                  question: questionData['question'],
                  answers: answers,
                  correctAnswer: questionData['correctAnswer'],
                  explanation: questionData['explanation'],
                  difficulty: questionData['difficulty'],
                  subcategory: questionData['subcategory'],
                ),
              );
            }
          }

          _allQuestions[category] = phase2Questions;
          _recentlyUsedQuestions[category] = [];
          _lastPlayedDates[category] = DateTime.now();

          print(
              '[QuestionService] 🆕 ${phase2Questions.length} questions de la Phase 2 ajoutées à $category');
        }
      } catch (e) {
        print(
            '[QuestionService] ⚠️ Erreur lors du chargement des questions Phase 2: $e');
      }

      // ÉTAPE 4: Charger les questions avancées de la Phase 3
      try {
        final String phase3JsonString = await rootBundle.loadString(
          'assets/questions/phase3_advanced_questions.json',
        );
        final Map<String, dynamic> phase3Data = json.decode(phase3JsonString);

        for (String category in phase3Data.keys) {
          // Vérifier si la catégorie existe déjà
          if (_allQuestions.containsKey(category)) {
            print(
                '[QuestionService] ⚠️ Catégorie $category existe déjà, ignorée');
            continue; // Ignorer les doublons
          }

          List<QuestionModel> phase3Questions = [];

          for (String subcategory in phase3Data[category].keys) {
            List<dynamic> subcategoryQuestions =
                phase3Data[category][subcategory];

            for (var questionData in subcategoryQuestions) {
              Map<String, bool> answers = {};
              for (int i = 0; i < questionData['options'].length; i++) {
                String option = questionData['options'][i];
                answers[option] = option == questionData['correctAnswer'];
              }

              phase3Questions.add(
                QuestionModel(
                  question: questionData['question'],
                  answers: answers,
                  correctAnswer: questionData['correctAnswer'],
                  explanation: questionData['explanation'],
                  difficulty: questionData['difficulty'],
                  subcategory: questionData['subcategory'],
                ),
              );
            }
          }

          _allQuestions[category] = phase3Questions;
          _recentlyUsedQuestions[category] = [];
          _lastPlayedDates[category] = DateTime.now();

          print(
              '[QuestionService] 🎯 ${phase3Questions.length} questions avancées de la Phase 3 ajoutées à $category');
        }
      } catch (e) {
        print(
            '[QuestionService] ⚠️ Erreur lors du chargement des questions Phase 3: $e');
      }

      // ÉTAPE 5: Charger les extensions massives de la Phase 4
      try {
        final String phase4JsonString = await rootBundle.loadString(
          'assets/questions/massive_extension_phase4.json',
        );
        final Map<String, dynamic> phase4Data = json.decode(phase4JsonString);

        for (String category in phase4Data.keys) {
          if (_allQuestions.containsKey(category)) {
            // Ajouter les questions aux catégories existantes
            List<QuestionModel> existingQuestions = _allQuestions[category]!;

            for (String subcategory in phase4Data[category].keys) {
              List<dynamic> subcategoryQuestions =
                  phase4Data[category][subcategory];

              for (var questionData in subcategoryQuestions) {
                Map<String, bool> answers = {};
                for (int i = 0; i < questionData['options'].length; i++) {
                  String option = questionData['options'][i];
                  answers[option] = option == questionData['correctAnswer'];
                }

                existingQuestions.add(
                  QuestionModel(
                    question: questionData['question'],
                    answers: answers,
                    correctAnswer: questionData['correctAnswer'],
                    explanation: questionData['explanation'],
                    difficulty: questionData['difficulty'],
                    subcategory: questionData['subcategory'],
                  ),
                );
              }
            }

            print(
                '[QuestionService] 🚀 Extensions massives ajoutées à $category: ${existingQuestions.length} questions total');
          }
        }
      } catch (e) {
        print(
            '[QuestionService] ⚠️ Erreur lors du chargement des extensions Phase 4: $e');
      }

      // ÉTAPE 6: Charger les questions premium de la Phase 6
      try {
        final String phase6JsonString = await rootBundle.loadString(
          'assets/questions/premium_questions_phase6.json',
        );
        final Map<String, dynamic> phase6Data = json.decode(phase6JsonString);

        for (String category in phase6Data.keys) {
          if (_allQuestions.containsKey(category)) {
            // Ajouter les questions aux catégories existantes
            List<QuestionModel> existingQuestions = _allQuestions[category]!;

            for (String subcategory in phase6Data[category].keys) {
              List<dynamic> subcategoryQuestions =
                  phase6Data[category][subcategory];

              for (var questionData in subcategoryQuestions) {
                Map<String, bool> answers = {};
                for (int i = 0; i < questionData['options'].length; i++) {
                  String option = questionData['options'][i];
                  answers[option] = option == questionData['correctAnswer'];
                }

                existingQuestions.add(
                  QuestionModel(
                    question: questionData['question'],
                    answers: answers,
                    correctAnswer: questionData['correctAnswer'],
                    explanation: questionData['explanation'],
                    difficulty: questionData['difficulty'],
                    subcategory: questionData['subcategory'],
                  ),
                );
              }
            }

            print(
                '[QuestionService] 💎 Questions premium ajoutées à $category: ${existingQuestions.length} questions total');
          }
        }
      } catch (e) {
        print(
            '[QuestionService] ⚠️ Erreur lors du chargement des questions premium Phase 6: $e');
      }

      // ÉTAPE 7: Charger les questions enrichies de la Phase 7
      try {
        final String phase7JsonString = await rootBundle.loadString(
          'assets/questions/enriched_questions_phase7.json',
        );
        final Map<String, dynamic> phase7Data = json.decode(phase7JsonString);

        for (String category in phase7Data.keys) {
          if (_allQuestions.containsKey(category)) {
            // Ajouter les questions aux catégories existantes
            List<QuestionModel> existingQuestions = _allQuestions[category]!;

            for (String subcategory in phase7Data[category].keys) {
              List<dynamic> subcategoryQuestions =
                  phase7Data[category][subcategory];

              for (var questionData in subcategoryQuestions) {
                Map<String, bool> answers = {};
                for (int i = 0; i < questionData['options'].length; i++) {
                  String option = questionData['options'][i];
                  answers[option] = option == questionData['correctAnswer'];
                }

                existingQuestions.add(
                  QuestionModel(
                    question: questionData['question'],
                    answers: answers,
                    correctAnswer: questionData['correctAnswer'],
                    explanation: questionData['explanation'],
                    difficulty: questionData['difficulty'],
                    subcategory: questionData['subcategory'],
                  ),
                );
              }
            }

            _allQuestions[category] = existingQuestions;
            print(
                '[QuestionService] 🌟 ${existingQuestions.length} questions enrichies Phase 7 ajoutées à $category');
          }
        }
      } catch (e) {
        print(
            '[QuestionService] ⚠️ Erreur lors du chargement des questions Phase 7: $e');
      }

      _isLoaded = true;

      // Afficher un résumé final du chargement
      print('\n📊 === RÉSUMÉ DU CHARGEMENT DES QUESTIONS ===');
      for (String category in _allQuestions.keys) {
        int questionCount = _allQuestions[category]!.length;
        print('✅ $category: $questionCount questions');
      }
      print(
          '📊 Total: ${_allQuestions.values.expand((x) => x).length} questions chargées\n');

      // Charger l'historique depuis le stockage local
      await _loadQuestionHistory();

      print(
          '[QuestionService] ✅ ${_allQuestions.length} catégories chargées avec variété intelligente');
    } catch (e) {
      print('Erreur lors du chargement des questions: $e');
    }
  }

  // Obtenir des questions intelligentes avec variété maximale
  static List<QuestionModel> getSmartQuestionsForCategory(
    String category, {
    int count = 10,
  }) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    List<QuestionModel> allCategoryQuestions =
        List.from(_allQuestions[category]!);

    print(
        '[QuestionService] 🎲 Début du mélange pour $category (${allCategoryQuestions.length} questions disponibles)');

    // FILTRAGE ANTI-RÉPÉTITION : Exclure les questions récemment utilisées
    List<QuestionModel> availableQuestions =
        _filterRecentlyUsedQuestions(allCategoryQuestions, category);

    print(
        '[QuestionService] 🚫 Questions filtrées: ${allCategoryQuestions.length - availableQuestions.length} exclues (récemment utilisées)');
    print(
        '[QuestionService] ✅ Questions disponibles: ${availableQuestions.length}');

    // Vérifier s'il y a assez de questions disponibles
    if (availableQuestions.length < count) {
      print(
          '[QuestionService] ⚠️ Pas assez de questions disponibles, réinitialisation de l\'historique');
      _recentlyUsedQuestions[category] = [];
      availableQuestions = allCategoryQuestions;
    }

    // MÉLANGE AMÉLIORÉ : Utiliser plusieurs techniques de mélange
    Random random = Random();

    // 1. Premier mélange basique
    availableQuestions.shuffle(random);

    // 2. Mélange par sous-catégories si disponibles
    _shuffleBySubcategories(availableQuestions, random);

    // 3. Mélange par difficulté
    _shuffleByDifficulty(availableQuestions, random);

    // 4. Mélange final pour garantir l'aléatoire
    availableQuestions.shuffle(random);

    List<QuestionModel> selectedQuestions =
        availableQuestions.take(count).toList();

    // VÉRIFICATION ANTI-DOUBLONS : Éliminer les doublons dans la sélection
    selectedQuestions = _removeDuplicates(selectedQuestions);

    // Si on a perdu des questions à cause des doublons, en prendre d'autres
    while (selectedQuestions.length < count &&
        availableQuestions.length > selectedQuestions.length) {
      List<QuestionModel> remainingQuestions = availableQuestions
          .where((q) => !selectedQuestions.contains(q))
          .toList();

      if (remainingQuestions.isNotEmpty) {
        selectedQuestions.add(remainingQuestions.first);
        selectedQuestions = _removeDuplicates(selectedQuestions);
      } else {
        break;
      }
    }

    // Mélanger les réponses pour chaque question
    for (var question in selectedQuestions) {
      _shuffleAnswers(question);
      _markQuestionAsUsed(category, question);
    }

    // VÉRIFICATION FINALE : S'assurer qu'il n'y a pas de répétitions
    _verifyVariety(selectedQuestions, category);

    // Sauvegarder l'historique
    _saveQuestionHistory();

    // Debug: Afficher les premières questions sélectionnées
    String debugQuestions = selectedQuestions
        .take(3)
        .map((q) => q.question.substring(0, min(30, q.question.length)) + '...')
        .join(', ');

    print(
        '[QuestionService] 🎯 $category: ${selectedQuestions.length} questions sélectionnées (${availableQuestions.length} disponibles) - NOUVEAU LOT');
    print('[QuestionService] 🔍 Debug - Premières questions: $debugQuestions');
    print('[QuestionService] ✅ Mélange terminé avec succès');

    return selectedQuestions;
  }

  // Vérifier si une question est disponible (pas récemment utilisée)
  static bool _isQuestionAvailable(String category, QuestionModel question) {
    List<String> recentQuestions = _recentlyUsedQuestions[category] ?? [];

    // Vérifier si la question a été récemment utilisée
    if (recentQuestions.contains(question.question)) {
      return false;
    }

    return true;
  }

  // Filtrer les questions récemment utilisées
  static List<QuestionModel> _filterRecentlyUsedQuestions(
      List<QuestionModel> allQuestions, String category) {
    List<String> recentQuestions = _recentlyUsedQuestions[category] ?? [];

    // Filtrer les questions qui ne sont pas dans l'historique récent
    List<QuestionModel> availableQuestions = allQuestions.where((question) {
      return !recentQuestions.contains(question.question);
    }).toList();

    return availableQuestions;
  }

  // Marquer une question comme utilisée
  static void _markQuestionAsUsed(String category, QuestionModel question) {
    List<String> recentQuestions = _recentlyUsedQuestions[category] ?? [];

    // Vérifier si la question n'est pas déjà dans l'historique
    if (!recentQuestions.contains(question.question)) {
      // Ajouter la question à l'historique récent
      recentQuestions.add(question.question);

      // Limiter la taille de l'historique
      if (recentQuestions.length > _maxRecentlyUsed) {
        recentQuestions.removeAt(0);
      }

      _recentlyUsedQuestions[category] = recentQuestions;
      _lastPlayedDates[category] = DateTime.now();

      print(
          '[QuestionService] 📝 Question marquée comme utilisée: ${question.question.substring(0, min(30, question.question.length))}...');
    } else {
      print(
          '[QuestionService] ⚠️ Question déjà dans l\'historique: ${question.question.substring(0, min(30, question.question.length))}...');
    }
  }

  // Obtenir des questions avec rotation intelligente
  static List<QuestionModel> getRotatingQuestionsForCategory(
    String category, {
    int count = 10,
  }) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    List<QuestionModel> allQuestions = List.from(_allQuestions[category]!);
    int totalQuestions = allQuestions.length;

    // Calculer l'index de départ basé sur la date
    DateTime now = DateTime.now();
    int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    int startIndex = (dayOfYear * count) % totalQuestions;

    // Sélectionner les questions avec rotation
    List<QuestionModel> selectedQuestions = [];
    for (int i = 0; i < count; i++) {
      int index = (startIndex + i) % totalQuestions;
      selectedQuestions.add(allQuestions[index]);
    }

    // Mélanger les réponses
    for (var question in selectedQuestions) {
      _shuffleAnswers(question);
    }

    print(
        '[QuestionService] 🔄 $category: Rotation quotidienne (jour $dayOfYear, index $startIndex)');

    return selectedQuestions;
  }

  // NOUVELLE FONCTION : Obtenir des questions complètement aléatoires
  static List<QuestionModel> getRandomQuestionsForCategory(
    String category, {
    int count = 10,
  }) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    List<QuestionModel> allQuestions = List.from(_allQuestions[category]!);

    // Mélanger complètement et sélectionner
    allQuestions.shuffle(Random());
    List<QuestionModel> selectedQuestions = allQuestions.take(count).toList();

    // Mélanger les réponses
    for (var question in selectedQuestions) {
      _shuffleAnswers(question);
    }

    print(
        '[QuestionService] 🎲 $category: ${selectedQuestions.length} questions aléatoires (${allQuestions.length} total)');

    return selectedQuestions;
  }

  // Obtenir des questions par niveau de difficulté
  static List<QuestionModel> getQuestionsByDifficulty(
    String category, {
    int count = 10,
    String difficulty = 'mixed', // 'easy', 'medium', 'hard', 'mixed'
  }) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    List<QuestionModel> allQuestions = List.from(_allQuestions[category]!);
    List<QuestionModel> filteredQuestions = [];

    // Filtrer par difficulté (basé sur la longueur de la question et des réponses)
    for (var question in allQuestions) {
      bool matchesDifficulty = _matchesDifficulty(question, difficulty);
      if (matchesDifficulty) {
        filteredQuestions.add(question);
      }
    }

    // Si pas assez de questions, prendre toutes
    if (filteredQuestions.length < count) {
      filteredQuestions = List.from(allQuestions);
    }

    // Mélanger et sélectionner
    filteredQuestions.shuffle(Random());
    List<QuestionModel> selectedQuestions =
        filteredQuestions.take(count).toList();

    // Mélanger les réponses
    for (var question in selectedQuestions) {
      _shuffleAnswers(question);
    }

    print(
        '[QuestionService] 📊 $category: $difficulty (${selectedQuestions.length}/${filteredQuestions.length})');

    return selectedQuestions;
  }

  // Vérifier si une question correspond à la difficulté
  static bool _matchesDifficulty(QuestionModel question, String difficulty) {
    int questionLength = question.question.length;
    int avgAnswerLength = question.answers.keys
            .map((answer) => answer.length)
            .reduce((a, b) => a + b) ~/
        question.answers.length;

    switch (difficulty) {
      case 'easy':
        return questionLength < 100 && avgAnswerLength < 30;
      case 'medium':
        return questionLength >= 100 &&
            questionLength < 200 &&
            avgAnswerLength >= 30 &&
            avgAnswerLength < 60;
      case 'hard':
        return questionLength >= 200 || avgAnswerLength >= 60;
      default:
        return true; // mixed
    }
  }

  // Méthode pour mélanger les réponses d'une question
  static void _shuffleAnswers(QuestionModel question) {
    Random random = Random();

    // Créer une liste des réponses avec leurs valeurs booléennes
    List<MapEntry<String, bool>> answersList =
        question.answers.entries.toList();

    // Mélanger les réponses
    answersList.shuffle(random);

    // Recréer la map avec les réponses mélangées
    Map<String, bool> shuffledAnswers = {};
    for (var entry in answersList) {
      shuffledAnswers[entry.key] = entry.value;
    }

    // Remplacer les réponses de la question
    question.answers = shuffledAnswers;
  }

  // Sauvegarder l'historique des questions
  static Future<void> _saveQuestionHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Sauvegarder les questions récemment utilisées
      Map<String, List<String>> historyToSave = {};
      _recentlyUsedQuestions.forEach((category, questions) {
        historyToSave[category] = questions;
      });

      await prefs.setString('question_history', json.encode(historyToSave));

      // Sauvegarder les dates de dernière utilisation
      Map<String, String> datesToSave = {};
      _lastPlayedDates.forEach((category, date) {
        datesToSave[category] = date.toIso8601String();
      });

      await prefs.setString('question_dates', json.encode(datesToSave));

      print('[QuestionService] 💾 Historique sauvegardé');
    } catch (e) {
      print('[QuestionService] ❌ Erreur sauvegarde historique: $e');
    }
  }

  // Charger l'historique des questions
  static Future<void> _loadQuestionHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Charger les questions récemment utilisées
      String? historyString = prefs.getString('question_history');
      if (historyString != null) {
        Map<String, dynamic> historyData = json.decode(historyString);
        historyData.forEach((category, questions) {
          _recentlyUsedQuestions[category] = List<String>.from(questions);
        });
      }

      // Charger les dates de dernière utilisation
      String? datesString = prefs.getString('question_dates');
      if (datesString != null) {
        Map<String, dynamic> datesData = json.decode(datesString);
        datesData.forEach((category, dateString) {
          _lastPlayedDates[category] = DateTime.parse(dateString);
        });
      }

      print('[QuestionService] 📂 Historique chargé');
    } catch (e) {
      print('[QuestionService] ❌ Erreur chargement historique: $e');
    }
  }

  // Obtenir des statistiques de variété
  static Map<String, dynamic> getVarietyStats(String category) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return {};
    }

    int totalQuestions = _allQuestions[category]!.length;
    int recentlyUsed = _recentlyUsedQuestions[category]?.length ?? 0;
    double varietyPercentage =
        ((totalQuestions - recentlyUsed) / totalQuestions) * 100;

    return {
      'totalQuestions': totalQuestions,
      'recentlyUsed': recentlyUsed,
      'available': totalQuestions - recentlyUsed,
      'varietyPercentage': varietyPercentage.roundToDouble(),
      'lastPlayed': _lastPlayedDates[category]?.toIso8601String(),
    };
  }

  // Réinitialiser l'historique pour une catégorie
  static void resetHistoryForCategory(String category) {
    _recentlyUsedQuestions[category] = [];
    _lastPlayedDates[category] = DateTime.now();
    _saveQuestionHistory();
    print('[QuestionService] 🔄 Historique réinitialisé pour $category');
  }

  // Réinitialiser l'historique pour toutes les catégories
  static void resetAllHistory() {
    _recentlyUsedQuestions.clear();
    _lastPlayedDates.clear();
    _saveQuestionHistory();
    print(
        '[QuestionService] 🔄 Historique réinitialisé pour toutes les catégories');
  }

  // Vérifier si une question spécifique a été récemment utilisée
  static bool isQuestionRecentlyUsed(String category, String questionText) {
    List<String> recentQuestions = _recentlyUsedQuestions[category] ?? [];
    return recentQuestions.contains(questionText);
  }

  // Obtenir le nombre de questions récemment utilisées pour une catégorie
  static int getRecentlyUsedCount(String category) {
    return _recentlyUsedQuestions[category]?.length ?? 0;
  }

  // Obtenir le pourcentage de variété pour une catégorie
  static double getVarietyPercentage(String category) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return 0.0;
    }

    int totalQuestions = _allQuestions[category]!.length;
    int recentlyUsed = getRecentlyUsedCount(category);

    if (totalQuestions == 0) return 0.0;

    return ((totalQuestions - recentlyUsed) / totalQuestions) * 100;
  }

  // Obtenir toutes les questions d'une catégorie
  static List<QuestionModel> getAllQuestionsForCategory(String category) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return [];
    }

    return List.from(_allQuestions[category]!);
  }

  // Obtenir la liste des catégories disponibles
  static List<String> getAvailableCategories() {
    return _allQuestions.keys.toList();
  }

  // Vérifier si les questions sont chargées
  static bool get isLoaded => _isLoaded;

  // Obtenir le nombre total de questions par catégorie
  static int getQuestionCountForCategory(String category) {
    if (!_isLoaded || !_allQuestions.containsKey(category)) {
      return 0;
    }
    return _allQuestions[category]!.length;
  }

  // Réinitialiser le service (pour les tests ou rechargement)
  static void reset() {
    _allQuestions.clear();
    _recentlyUsedQuestions.clear();
    _lastPlayedDates.clear();
    _isLoaded = false;
  }

  // Mélanger par sous-catégories
  static void _shuffleBySubcategories(
      List<QuestionModel> questions, Random random) {
    // Grouper les questions par sous-catégorie
    Map<String, List<QuestionModel>> subcategoryGroups = {};

    for (var question in questions) {
      String subcategory = question.subcategory ?? 'general';
      subcategoryGroups.putIfAbsent(subcategory, () => []).add(question);
    }

    // Mélanger chaque groupe de sous-catégorie
    subcategoryGroups.forEach((subcategory, groupQuestions) {
      groupQuestions.shuffle(random);
    });

    // Reconstituer la liste en alternant les sous-catégories
    questions.clear();
    List<String> subcategories = subcategoryGroups.keys.toList();
    subcategories.shuffle(random);

    int maxLength = subcategoryGroups.values
        .map((list) => list.length)
        .reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      for (String subcategory in subcategories) {
        if (i < subcategoryGroups[subcategory]!.length) {
          questions.add(subcategoryGroups[subcategory]![i]);
        }
      }
    }

    print(
        '[QuestionService] 🔀 Mélange par sous-catégories: ${subcategoryGroups.length} groupes');
  }

  // Mélanger par difficulté
  static void _shuffleByDifficulty(
      List<QuestionModel> questions, Random random) {
    // Grouper les questions par difficulté
    Map<String, List<QuestionModel>> difficultyGroups = {
      'easy': [],
      'medium': [],
      'hard': [],
    };

    for (var question in questions) {
      String difficulty = _getQuestionDifficulty(question);
      difficultyGroups[difficulty]!.add(question);
    }

    // Mélanger chaque groupe de difficulté
    difficultyGroups.forEach((difficulty, groupQuestions) {
      groupQuestions.shuffle(random);
    });

    // Reconstituer la liste en alternant les difficultés
    questions.clear();
    List<String> difficulties = ['easy', 'medium', 'hard'];
    difficulties.shuffle(random);

    int maxLength = difficultyGroups.values
        .map((list) => list.length)
        .reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      for (String difficulty in difficulties) {
        if (i < difficultyGroups[difficulty]!.length) {
          questions.add(difficultyGroups[difficulty]![i]);
        }
      }
    }

    print(
        '[QuestionService] 📊 Mélange par difficulté: ${difficultyGroups['easy']!.length} facile, ${difficultyGroups['medium']!.length} moyen, ${difficultyGroups['hard']!.length} difficile');
  }

  // Déterminer la difficulté d'une question
  static String _getQuestionDifficulty(QuestionModel question) {
    int questionLength = question.question.length;
    int avgAnswerLength = question.answers.keys
            .map((answer) => answer.length)
            .reduce((a, b) => a + b) ~/
        question.answers.length;

    if (questionLength < 100 && avgAnswerLength < 30) {
      return 'easy';
    } else if (questionLength >= 200 || avgAnswerLength >= 60) {
      return 'hard';
    } else {
      return 'medium';
    }
  }

  // Vérifier et éliminer les doublons dans une liste de questions
  static List<QuestionModel> _removeDuplicates(List<QuestionModel> questions) {
    Set<String> seenQuestions = {};
    List<QuestionModel> uniqueQuestions = [];

    for (var question in questions) {
      if (!seenQuestions.contains(question.question)) {
        seenQuestions.add(question.question);
        uniqueQuestions.add(question);
      } else {
        print(
            '[QuestionService] 🚫 Doublon détecté et éliminé: ${question.question.substring(0, min(30, question.question.length))}...');
      }
    }

    if (uniqueQuestions.length < questions.length) {
      print(
          '[QuestionService] 🧹 ${questions.length - uniqueQuestions.length} doublons éliminés');
    }

    return uniqueQuestions;
  }

  // Vérifier la variété d'une liste de questions
  static void _verifyVariety(List<QuestionModel> questions, String category) {
    Set<String> uniqueQuestions = questions.map((q) => q.question).toSet();
    double varietyPercentage =
        (uniqueQuestions.length / questions.length) * 100;

    print(
        '[QuestionService] 📊 Variété vérifiée: ${uniqueQuestions.length}/${questions.length} questions uniques (${varietyPercentage.toStringAsFixed(1)}%)');

    if (varietyPercentage < 100) {
      print(
          '[QuestionService] ⚠️ Attention: Des répétitions ont été détectées');
    } else {
      print('[QuestionService] ✅ Variété parfaite: Aucune répétition détectée');
    }
  }
}
