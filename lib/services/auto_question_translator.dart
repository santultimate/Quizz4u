// lib/services/auto_question_translator.dart
import '../models/question_model.dart';
import 'translation_service.dart';
import 'bulk_auto_translator.dart';
import 'mali_history_translations.dart';
import 'mali_history_extension_translations.dart';
import 'mali_history_complete_translations.dart';
import 'culture_generale_translations.dart';
import 'culture_generale_extended_translations.dart';
import 'culture_generale_phase6_translations.dart';
import 'culture_generale_phase7_translations.dart';
import 'culture_generale_enriched_translations.dart';
import 'culture_generale_phase9_final_translations.dart';
import 'math_translations.dart';
import 'math_phase10_translations.dart';
import 'math_extensions_translations.dart';
import 'science_translations.dart';
import 'science_phase11_translations.dart';
import 'africa_translations.dart';
import 'football_translations.dart';
import 'music_translations.dart';
import 'phase2_categories_translations.dart';
import 'phase3_expert_translations.dart';
import 'phase4_extension_translations.dart';
import 'premium_phase6_translations.dart';

/// Service de traduction automatique des questions
/// Traduit les questions, réponses et explications dans la langue sélectionnée
class AutoQuestionTranslator {
  // Dictionnaire de traductions hardcodées pour les questions courantes
  static final Map<String, Map<String, Map<String, dynamic>>>
      _questionTranslations = {
    // Question: "En quelle année le Mali a-t-il obtenu son indépendance ?"
    "En quelle annee le Mali a-t-il obtenu son independance ?": {
      'en': {
        'question': 'In what year did Mali gain independence?',
        'answers': {'1958': false, '1960': true, '1962': false, '1965': false}
      },
      'ar': {
        'question': 'في أي عام حصلت مالي على الاستقلال؟',
        'answers': {'1958': false, '1960': true, '1962': false, '1965': false}
      },
      'zh': {
        'question': '马里在哪一年获得独立？',
        'answers': {'1958': false, '1960': true, '1962': false, '1965': false}
      },
      'hi': {
        'question': 'माली को किस वर्ष स्वतंत्रता मिली?',
        'answers': {'1958': false, '1960': true, '1962': false, '1965': false}
      },
      'es': {
        'question': '¿En qué año obtuvo Malí su independencia?',
        'answers': {'1958': false, '1960': true, '1962': false, '1965': false}
      }
    },

    // Question: "Quel empire a succédé à l'Empire du Mali ?"
    "Quel empire a succede a l'Empire du Mali ?": {
      'en': {
        'question': 'Which empire succeeded the Mali Empire?',
        'answers': {
          'Empire du Ghana': false,
          'Empire du Bornou': false,
          'Empire Songhai': true,
          'Empire du Kanem': false
        }
      },
      'ar': {
        'question': 'أي إمبراطورية خلفت إمبراطورية مالي؟',
        'answers': {
          'إمبراطورية غانا': false,
          'إمبراطورية بورنو': false,
          'إمبراطورية سونغاي': true,
          'إمبراطورية كانم': false
        }
      },
      'zh': {
        'question': '哪个帝国继承了马里帝国？',
        'answers': {'加纳帝国': false, '博尔努帝国': false, '桑海帝国': true, '卡内姆帝国': false}
      },
      'hi': {
        'question': 'माली साम्राज्य के बाद कौन सा साम्राज्य आया?',
        'answers': {
          'घाना साम्राज्य': false,
          'बोर्नु साम्राज्य': false,
          'सोंघई साम्राज्य': true,
          'कानेम साम्राज्य': false
        }
      },
      'es': {
        'question': '¿Qué imperio sucedió al Imperio de Malí?',
        'answers': {
          'Imperio de Ghana': false,
          'Imperio de Bornu': false,
          'Imperio Songhai': true,
          'Imperio de Kanem': false
        }
      }
    },

    // Question: "Quel était le nom de la capitale de l'Empire Songhaï ?"
    "Quel etait le nom de la capitale de l'Empire Songhai ?": {
      'en': {
        'question': 'What was the name of the capital of the Songhai Empire?',
        'answers': {
          'Tombouctou': false,
          'Djenne': false,
          'Segou': false,
          'Gao': true
        }
      },
      'ar': {
        'question': 'ما اسم عاصمة إمبراطورية سونغاي؟',
        'answers': {'تمبكتو': false, 'جيني': false, 'سيغو': false, 'غاو': true}
      },
      'zh': {
        'question': '桑海帝国的首都叫什么名字？',
        'answers': {'廷巴克图': false, '杰内': false, '塞古': false, '加奥': true}
      },
      'hi': {
        'question': 'सोंघई साम्राज्य की राजधानी का नाम क्या था?',
        'answers': {
          'टिम्बकटू': false,
          'जेने': false,
          'सेगु': false,
          'गाओ': true
        }
      },
      'es': {
        'question': '¿Cuál era el nombre de la capital del Imperio Songhai?',
        'answers': {
          'Tombuctú': false,
          'Djenné': false,
          'Ségou': false,
          'Gao': true
        }
      }
    },

    // Question: "Quel était le nom de l'empire médiéval qui a dominé l'Afrique de l'Ouest ?"
    "Quel etait le nom de l'empire medieval qui a domine l'Afrique de l'Ouest ?":
        {
      'en': {
        'question':
            'What was the name of the medieval empire that dominated West Africa?',
        'answers': {
          'Empire of Ghana': false,
          'Mali Empire': true,
          'Songhai Empire': false,
          'Kanem Empire': false
        }
      },
      'ar': {
        'question':
            'ما اسم الإمبراطورية التي سيطرت على غرب أفريقيا في العصور الوسطى؟',
        'answers': {
          'إمبراطورية غانا': false,
          'إمبراطورية مالي': true,
          'إمبراطورية سونغاي': false,
          'إمبراطورية كانم': false
        }
      },
      'zh': {
        'question': '统治西非的中世纪帝国叫什么名字？',
        'answers': {'加纳帝国': false, '马里帝国': true, '桑海帝国': false, '卡内姆帝国': false}
      },
      'hi': {
        'question':
            'पश्चिम अफ्रीका पर हावी रहने वाले मध्ययुगीन साम्राज्य का नाम क्या था?',
        'answers': {
          'घाना साम्राज्य': false,
          'माली साम्राज्य': true,
          'सोंघई साम्राज्य': false,
          'कानेम साम्राज्य': false
        }
      },
      'es': {
        'question':
            '¿Cuál era el nombre del imperio medieval que dominó África Occidental?',
        'answers': {
          'Imperio de Ghana': false,
          'Imperio de Malí': true,
          'Imperio Songhai': false,
          'Imperio de Kanem': false
        }
      }
    }
  };

  /// Traduire une question selon la langue actuelle
  static QuestionModel translateQuestion(QuestionModel question) {
    final currentLanguage = TranslationService.getCurrentLanguage();

    // Si la langue est française, retourner la question originale
    if (currentLanguage == 'fr') {
      return question;
    }

    // Chercher dans les dictionnaires de traductions hardcodées
    final questionText = question.question.trim();

    // NOUVEAUX FICHIERS: Musique, Football, Afrique (priorité haute)
    // 0a. Chercher dans Musique (8 questions traduites)
    var translation =
        MusicTranslations.translations[questionText]?[currentLanguage];

    // 0b. Si pas trouvé, chercher dans Football (8 questions traduites)
    if (translation == null) {
      translation =
          FootballTranslations.translations[questionText]?[currentLanguage];
    }

    // 0c. Si pas trouvé, chercher dans Afrique (41 questions traduites)
    if (translation == null) {
      translation =
          AfricaTranslations.translations[questionText]?[currentLanguage];
    }

    // 0d. Si pas trouvé, chercher dans Phase 2 Categories (14 questions traduites)
    // Arts et Culture, Politique, Technologie, Santé, Environnement
    if (translation == null) {
      translation = Phase2CategoriesTranslations.translations[questionText]
          ?[currentLanguage];
    }

    // 0e. Si pas trouvé, chercher dans Phase 3 Expert (7 questions traduites)
    // Questions Expert et Questions Spécialisées
    if (translation == null) {
      translation =
          Phase3ExpertTranslations.translations[questionText]?[currentLanguage];
    }

    // 0f. Si pas trouvé, chercher dans Phase 4 Extensions (6 questions traduites)
    // Histoire du Mali, Sciences, Mathématiques
    if (translation == null) {
      translation = Phase4ExtensionTranslations.translations[questionText]
          ?[currentLanguage];
    }

    // 0g. Si pas trouvé, chercher dans Questions Premium Phase 6 (22 questions traduites)
    // Histoire du Mali, Sciences, Mathématiques, Culture générale, Afrique
    if (translation == null) {
      translation = PremiumPhase6Translations.translations[questionText]
          ?[currentLanguage];
    }

    // 0. Chercher d'abord dans Culture Générale Phase 9 Final (3 questions - Phase 9 🏆 FINALE 100%)
    if (translation == null) {
      translation = CultureGeneralePhase9FinalTranslations
          .translations[questionText]?[currentLanguage];
    }

    // 0.5. Si pas trouvé, chercher dans Culture Générale Enriched (10 questions - Phase 8)
    if (translation == null) {
      translation = CultureGeneraleEnrichedTranslations
          .translations[questionText]?[currentLanguage];
    }

    // 1. Si pas trouvé, chercher dans Mathématiques Extensions (9 questions - priorité haute)
    if (translation == null) {
      translation = MathExtensionsTranslations.translations[questionText]
          ?[currentLanguage];
    }

    // 1.5. Si pas trouvé, chercher dans Mathématiques Phase 10 (Q21-Q40: 20 questions)
    if (translation == null) {
      translation =
          MathPhase10Translations.translations[questionText]?[currentLanguage];
    }

    // 1.7. Si pas trouvé, chercher dans Mathématiques Base (Q1-Q20: 20 questions)
    if (translation == null) {
      translation =
          MathTranslations.translations[questionText]?[currentLanguage];
    }

    // 2. Si pas trouvé, chercher dans Sciences Phase 11 (Q21-Q50: 30 questions)
    if (translation == null) {
      translation = SciencePhase11Translations.translations[questionText]
          ?[currentLanguage];
    }

    // 2.5. Si pas trouvé, chercher dans Sciences Base (Q1-Q20: 20 questions)
    if (translation == null) {
      translation =
          ScienceTranslations.translations[questionText]?[currentLanguage];
    }

    // 3. Si pas trouvé, chercher dans Culture Générale Phase 7 (Q51-Q69: 15 questions)
    if (translation == null) {
      translation = CultureGeneralePhase7Translations.translations[questionText]
          ?[currentLanguage];
    }

    // 4. Si pas trouvé, chercher dans Culture Générale Phase 6 (Q31-Q50: 15 questions)
    if (translation == null) {
      translation = CultureGeneralePhase6Translations.translations[questionText]
          ?[currentLanguage];
    }

    // 5. Si pas trouvé, chercher dans Culture Générale Extended (Q11-Q30: 20 questions)
    if (translation == null) {
      translation = CultureGeneraleExtendedTranslations
          .translations[questionText]?[currentLanguage];
    }

    // 6. Si pas trouvé, chercher dans Culture Générale Base (Q1-Q10: 10 questions)
    if (translation == null) {
      translation = CultureGeneraleTranslations.translations[questionText]
          ?[currentLanguage];
    }

    // 7. Si pas trouvé, chercher dans Mali History Complete (Q18-Q35: 18 questions)
    if (translation == null) {
      translation = MaliHistoryCompleteTranslations.translations[questionText]
          ?[currentLanguage];
    }

    // 8. Si pas trouvé, chercher dans Mali History Extensions (10 questions)
    if (translation == null) {
      translation = MaliHistoryExtensionTranslations.translations[questionText]
          ?[currentLanguage];
    }

    // 9. Si pas trouvé, chercher dans Mali History Base (Q1-Q17: 17 questions)
    if (translation == null) {
      translation =
          MaliHistoryTranslations.translations[questionText]?[currentLanguage];
    }

    // 10. Si pas trouvé, chercher dans les traductions legacy (4 questions hardcodées)
    if (translation == null) {
      translation = _questionTranslations[questionText]?[currentLanguage];
    }

    if (translation != null) {
      // Traduction trouvée dans l'un des dictionnaires
      Map<String, bool> translatedAnswers;

      // Gérer le format 'options' (array) ou 'answers' (map)
      if (translation.containsKey('options')) {
        // Format options (array) - convertir en map
        final options = translation['options'] as List<dynamic>;
        final correctAnswer = translation['correctAnswer'] as String?;
        translatedAnswers = {};
        for (var option in options) {
          translatedAnswers[option.toString()] =
              (correctAnswer != null && option == correctAnswer);
        }
      } else if (translation.containsKey('answers')) {
        // Format answers (map avec bool)
        translatedAnswers =
            (translation['answers'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as bool),
        );
      } else {
        // Si aucun format valide, passer à la traduction automatique
        return _autoTranslate(question, currentLanguage);
      }

      return QuestionModel(
        question: translation['question'] as String,
        answers: translatedAnswers,
        correctAnswer: question.correctAnswer,
        difficulty: question.difficulty,
        subcategory: question.subcategory,
        explanation:
            _translateExplanation(question.explanation, currentLanguage),
      );
    }

    // Si pas de traduction hardcodée, utiliser une traduction générique
    return _autoTranslate(question, currentLanguage);
  }

  /// Traduction automatique enrichie avec BulkAutoTranslator
  static QuestionModel _autoTranslate(QuestionModel question, String language) {
    // Si la langue est française, retourner tel quel
    if (language == 'fr') {
      return question;
    }

    // ✅ TRADUCTION AUTOMATIQUE RÉACTIVÉE
    // Utilisation de BulkAutoTranslator pour traduire automatiquement
    print(
        '[AutoQuestionTranslator] 🔄 Traduction automatique: ${question.question.substring(0, question.question.length > 50 ? 50 : question.question.length)}...');

    try {
      // Traduire la question
      final translatedQuestion = BulkAutoTranslator.translateQuestion(
        question.question,
        language,
        category: question.subcategory,
      );

      // Traduire les réponses et trouver la bonne réponse
      final translatedAnswers = <String, bool>{};
      String? translatedCorrectAnswer;
      
      question.answers.forEach((answer, isCorrect) {
        final translatedAnswer = BulkAutoTranslator.translateQuestion(
          answer,
          language,
          category: question.subcategory,
        );
        translatedAnswers[translatedAnswer] = isCorrect;
        
        // Identifier la bonne réponse traduite
        if (answer == question.correctAnswer) {
          translatedCorrectAnswer = translatedAnswer;
        }
      });

      // Traduire l'explication
      final translatedExplanation = question.explanation != null
          ? BulkAutoTranslator.translateQuestion(
              question.explanation!,
              language,
              category: question.subcategory,
            )
          : null;

      print(
          '[AutoQuestionTranslator] ✅ Traduction automatique réussie en $language');

      return QuestionModel(
        question: translatedQuestion,
        answers: translatedAnswers,
        correctAnswer: translatedCorrectAnswer ?? question.correctAnswer,
        difficulty: question.difficulty,
        subcategory: question.subcategory,
        explanation: translatedExplanation,
      );
    } catch (e) {
      print(
          '[AutoQuestionTranslator] ❌ Erreur traduction automatique: $e');
      print(
          '[AutoQuestionTranslator] → Retour au français (fallback)');
      return question; // Fallback en français en cas d'erreur
    }
  }

  /// Traduction d'explication
  static String _translateExplanation(String? explanation, String language) {
    if (explanation == null || explanation.isEmpty) return '';

    // Pour l'instant, retourner tel quel
    // TODO: Implémenter traduction des explications
    return explanation;
  }

  // Anciennes méthodes de traduction supprimées - remplacées par BulkAutoTranslator

  /// Traduire une liste de questions
  static List<QuestionModel> translateQuestions(List<QuestionModel> questions) {
    return questions.map((q) => translateQuestion(q)).toList();
  }

  /// Vérifier si une question a une traduction hardcodée
  static bool hasHardcodedTranslation(String questionText, String language) {
    return _questionTranslations[questionText.trim()]?[language] != null;
  }
}
