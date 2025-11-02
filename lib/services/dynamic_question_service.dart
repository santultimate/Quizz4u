import 'dart:math';
import '../models/question_model.dart';
import 'question_service.dart';

class DynamicQuestionService {
  // Questions basées sur l'actualité et les événements
  static final Map<String, List<Map<String, dynamic>>> _contextualQuestions = {
    'actualite': [],
    'saisonnier': [],
    'historique_date': [],
    'geographie_temps_reel': [],
    'science_actuelle': [],
  };

  // Générateurs de questions dynamiques
  static final List<QuestionGenerator> _questionGenerators = [
    DateBasedQuestionGenerator(),
    MathChallengeGenerator(),
    WordPlayGenerator(),
    LogicPuzzleGenerator(),
    CurrentEventsGenerator(),
    SeasonalGenerator(),
  ];

  // Initialiser le service
  static Future<void> initialize() async {
    await _loadContextualQuestions();
    print(
        '[DynamicQuestionService] ✅ Service initialisé avec ${_questionGenerators.length} générateurs');
  }

  // Charger les questions contextuelles
  static Future<void> _loadContextualQuestions() async {
    try {
      // Questions saisonnières
      _contextualQuestions['saisonnier'] = _generateSeasonalQuestions();

      // Questions basées sur la date
      _contextualQuestions['historique_date'] = _generateDateBasedQuestions();

      // Questions géographiques
      _contextualQuestions['geographie_temps_reel'] =
          _generateGeographyQuestions();

      print('[DynamicQuestionService] 📚 Questions contextuelles chargées');
    } catch (e) {
      print('[DynamicQuestionService] ❌ Erreur chargement: $e');
    }
  }

  // Générer des questions dynamiques pour une catégorie
  static List<QuestionModel> generateDynamicQuestions(String category,
      {int count = 5}) {
    List<QuestionModel> questions = [];

    // 1. Questions contextuelles (30% du total)
    int contextualCount = (count * 0.3).round();
    questions.addAll(_getContextualQuestions(category, contextualCount));

    // 2. Questions générées dynamiquement (40% du total)
    int dynamicCount = (count * 0.4).round();
    questions.addAll(_generateDynamicQuestions(category, dynamicCount));

    // 3. Questions variées existantes (30% du total)
    int existingCount = count - questions.length;
    questions.addAll(_getVariedExistingQuestions(category, existingCount));

    // Mélanger et retourner
    questions.shuffle();
    return questions.take(count).toList();
  }

  // Questions contextuelles
  static List<QuestionModel> _getContextualQuestions(
      String category, int count) {
    List<QuestionModel> questions = [];

    // Questions saisonnières
    if (_contextualQuestions['saisonnier']!.isNotEmpty) {
      final seasonalQuestions = _contextualQuestions['saisonnier']!
          .take(count ~/ 2)
          .map((q) => QuestionModel(
                question: q['question'],
                answers: Map<String, bool>.from(q['answers']),
                correctAnswer: q['correctAnswer'],
              ))
          .toList();
      questions.addAll(seasonalQuestions);
    }

    // Questions basées sur la date
    if (_contextualQuestions['historique_date']!.isNotEmpty) {
      final dateQuestions = _contextualQuestions['historique_date']!
          .take(count - questions.length)
          .map((q) => QuestionModel(
                question: q['question'],
                answers: Map<String, bool>.from(q['answers']),
                correctAnswer: q['correctAnswer'],
              ))
          .toList();
      questions.addAll(dateQuestions);
    }

    return questions;
  }

  // Questions générées dynamiquement
  static List<QuestionModel> _generateDynamicQuestions(
      String category, int count) {
    List<QuestionModel> questions = [];

    for (var generator in _questionGenerators) {
      if (questions.length >= count) break;

      try {
        final generatedQuestions =
            generator.generateQuestions(category, count - questions.length);
        questions.addAll(generatedQuestions);
      } catch (e) {
        print(
            '[DynamicQuestionService] ⚠️ Erreur générateur ${generator.runtimeType}: $e');
      }
    }

    return questions;
  }

  // Questions existantes avec plus de variété
  static List<QuestionModel> _getVariedExistingQuestions(
      String category, int count) {
    try {
      // Connecter au QuestionService existant
      return QuestionService.getIntelligentQuestionsForCategory(category,
          count: count);
    } catch (e) {
      print(
          '[DynamicQuestionService] ❌ Erreur récupération questions existantes: $e');
      return [];
    }
  }

  // Générer des questions saisonnières
  static List<Map<String, dynamic>> _generateSeasonalQuestions() {
    final now = DateTime.now();
    final month = now.month;

    List<Map<String, dynamic>> questions = [];

    if (month >= 12 || month <= 2) {
      // Hiver
      questions.addAll([
        {
          'question': 'Quel est le solstice d\'hiver dans l\'hémisphère nord ?',
          'answers': {
            '21 décembre': true,
            '21 juin': false,
            '21 mars': false,
            '21 septembre': false
          },
          'correctAnswer': '21 décembre',
          'category': 'Culture générale',
          'type': 'saisonnier'
        },
        {
          'question': 'Quel animal hiberne pendant l\'hiver ?',
          'answers': {
            'Ours': true,
            'Lion': false,
            'Éléphant': false,
            'Girafe': false
          },
          'correctAnswer': 'Ours',
          'category': 'Sciences',
          'type': 'saisonnier'
        }
      ]);
    } else if (month >= 3 && month <= 5) {
      // Printemps
      questions.addAll([
        {
          'question': 'Quel est l\'équinoxe de printemps ?',
          'answers': {
            '21 mars': true,
            '21 juin': false,
            '21 décembre': false,
            '21 septembre': false
          },
          'correctAnswer': '21 mars',
          'category': 'Culture générale',
          'type': 'saisonnier'
        }
      ]);
    } else if (month >= 6 && month <= 8) {
      // Été
      questions.addAll([
        {
          'question': 'Quel est le solstice d\'été ?',
          'answers': {
            '21 juin': true,
            '21 mars': false,
            '21 décembre': false,
            '21 septembre': false
          },
          'correctAnswer': '21 juin',
          'category': 'Culture générale',
          'type': 'saisonnier'
        }
      ]);
    } else {
      // Automne
      questions.addAll([
        {
          'question': 'Quel est l\'équinoxe d\'automne ?',
          'answers': {
            '21 septembre': true,
            '21 mars': false,
            '21 juin': false,
            '21 décembre': false
          },
          'correctAnswer': '21 septembre',
          'category': 'Culture générale',
          'type': 'saisonnier'
        }
      ]);
    }

    return questions;
  }

  // Générer des questions basées sur la date
  static List<Map<String, dynamic>> _generateDateBasedQuestions() {
    final now = DateTime.now();
    List<Map<String, dynamic>> questions = [];

    // Questions basées sur le jour du mois
    questions.add({
      'question': 'Quel jour sommes-nous ce mois ?',
      'answers': {
        '${now.day}': true,
        '${now.day + 1}': false,
        '${now.day - 1}': false,
        '${now.day + 2}': false
      },
      'correctAnswer': '${now.day}',
      'category': 'Culture générale',
      'type': 'date'
    });

    // Questions basées sur l'année
    questions.add({
      'question': 'En quelle année sommes-nous ?',
      'answers': {
        '${now.year}': true,
        '${now.year - 1}': false,
        '${now.year + 1}': false,
        '${now.year - 2}': false
      },
      'correctAnswer': '${now.year}',
      'category': 'Culture générale',
      'type': 'date'
    });

    return questions;
  }

  // Générer des questions géographiques
  static List<Map<String, dynamic>> _generateGeographyQuestions() {
    return [
      {
        'question': 'Quelle est la capitale du Mali ?',
        'answers': {
          'Bamako': true,
          'Sikasso': false,
          'Mopti': false,
          'Gao': false
        },
        'correctAnswer': 'Bamako',
        'category': 'Afrique',
        'type': 'géographie'
      }
    ];
  }
}

// Interface pour les générateurs de questions
abstract class QuestionGenerator {
  List<QuestionModel> generateQuestions(String category, int count);
}

// Générateur de questions basées sur la date
class DateBasedQuestionGenerator extends QuestionGenerator {
  @override
  List<QuestionModel> generateQuestions(String category, int count) {
    List<QuestionModel> questions = [];
    final now = DateTime.now();

    // Questions de calcul avec la date
    questions.add(QuestionModel(
      question: 'Combien de jours y a-t-il dans ${now.year} ?',
      answers: {
        '${DateTime(now.year + 1).difference(DateTime(now.year)).inDays}': true,
        '365':
            DateTime(now.year + 1).difference(DateTime(now.year)).inDays == 365,
        '366':
            DateTime(now.year + 1).difference(DateTime(now.year)).inDays == 366,
        '364': false,
      },
      correctAnswer:
          '${DateTime(now.year + 1).difference(DateTime(now.year)).inDays}',
    ));

    return questions.take(count).toList();
  }
}

// Générateur de défis mathématiques
class MathChallengeGenerator extends QuestionGenerator {
  @override
  List<QuestionModel> generateQuestions(String category, int count) {
    if (category != 'Mathématiques') return [];

    List<QuestionModel> questions = [];
    final random = Random();

    for (int i = 0; i < count; i++) {
      final a = random.nextInt(20) + 1;
      final b = random.nextInt(20) + 1;
      final operation = random.nextInt(4);

      String question;
      Map<String, bool> answers;
      String correctAnswer;

      switch (operation) {
        case 0: // Addition
          question = 'Combien font $a + $b ?';
          final result = a + b;
          answers = {
            '$result': true,
            '${result + 1}': false,
            '${result - 1}': false,
            '${result + 2}': false,
          };
          correctAnswer = '$result';
          break;
        case 1: // Soustraction
          question = 'Combien font $a - $b ?';
          final result = a - b;
          answers = {
            '$result': true,
            '${result + 1}': false,
            '${result - 1}': false,
            '${result + 2}': false,
          };
          correctAnswer = '$result';
          break;
        case 2: // Multiplication
          question = 'Combien font $a × $b ?';
          final result = a * b;
          answers = {
            '$result': true,
            '${result + 1}': false,
            '${result - 1}': false,
            '${result + 2}': false,
          };
          correctAnswer = '$result';
          break;
        default: // Division
          question = 'Combien font ${a * b} ÷ $a ?';
          final result = b;
          answers = {
            '$result': true,
            '${result + 1}': false,
            '${result - 1}': false,
            '${result + 2}': false,
          };
          correctAnswer = '$result';
          break;
      }

      questions.add(QuestionModel(
        question: question,
        answers: answers,
        correctAnswer: correctAnswer,
      ));
    }

    return questions;
  }
}

// Générateur de jeux de mots
class WordPlayGenerator extends QuestionGenerator {
  @override
  List<QuestionModel> generateQuestions(String category, int count) {
    if (category != 'Culture générale') return [];

    return [
      QuestionModel(
        question: 'Quel mot français contient toutes les voyelles ?',
        answers: {
          'Oiseau': true,
          'Maison': false,
          'Château': false,
          'Bureau': false,
        },
        correctAnswer: 'Oiseau',
      ),
      QuestionModel(
        question: 'Quelle est la plus longue rivière du monde ?',
        answers: {
          'Le Nil': true,
          'L\'Amazone': false,
          'Le Mississippi': false,
          'Le Danube': false,
        },
        correctAnswer: 'Le Nil',
      ),
    ].take(count).toList();
  }
}

// Générateur de puzzles logiques
class LogicPuzzleGenerator extends QuestionGenerator {
  @override
  List<QuestionModel> generateQuestions(String category, int count) {
    return [
      QuestionModel(
        question:
            'Si 2 chats attrapent 2 souris en 2 minutes, combien de chats faut-il pour attraper 100 souris en 100 minutes ?',
        answers: {
          '2 chats': true,
          '100 chats': false,
          '50 chats': false,
          '1 chat': false,
        },
        correctAnswer: '2 chats',
      ),
    ].take(count).toList();
  }
}

// Générateur d'actualités (simulé)
class CurrentEventsGenerator extends QuestionGenerator {
  @override
  List<QuestionModel> generateQuestions(String category, int count) {
    // Dans une vraie app, vous pourriez intégrer une API d'actualités
    return [];
  }
}

// Générateur saisonnier
class SeasonalGenerator extends QuestionGenerator {
  @override
  List<QuestionModel> generateQuestions(String category, int count) {
    return DynamicQuestionService._generateSeasonalQuestions()
        .take(count)
        .map((q) => QuestionModel(
              question: q['question'],
              answers: Map<String, bool>.from(q['answers']),
              correctAnswer: q['correctAnswer'],
            ))
        .toList();
  }
}
