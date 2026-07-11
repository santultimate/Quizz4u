import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'translation_service.dart';

class QuestionTranslationService {
  static Map<String, Map<String, dynamic>> _questionTranslations = {};
  static bool _isInitialized = false;

  // Initialiser le service de traduction des questions
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // D'abord créer les traductions par défaut (hardcodées)
    _createDefaultTranslations();

    try {
      // Ensuite charger les traductions depuis les fichiers JSON (si disponibles)
      // Cela écrasera les traductions hardcodées avec les traductions des fichiers
      try {
        final String questionsFr =
            await rootBundle.loadString('assets/translations/questions_fr.json');
        _questionTranslations['fr'] = json.decode(questionsFr);
        print('[QuestionTranslationService] ✅ Questions FR chargées depuis JSON');
      } catch (e) {
        print('[QuestionTranslationService] ⚠️ Utilisation traductions FR hardcodées');
      }

      try {
        final String questionsEn =
            await rootBundle.loadString('assets/translations/questions_en.json');
        _questionTranslations['en'] = json.decode(questionsEn);
        print('[QuestionTranslationService] ✅ Questions EN chargées depuis JSON');
      } catch (e) {
        print('[QuestionTranslationService] ⚠️ Utilisation traductions EN hardcodées');
      }

      try {
        final String questionsAr =
            await rootBundle.loadString('assets/translations/questions_ar.json');
        _questionTranslations['ar'] = json.decode(questionsAr);
        print('[QuestionTranslationService] ✅ Questions AR chargées depuis JSON');
      } catch (e) {
        print('[QuestionTranslationService] ⚠️ Utilisation traductions AR hardcodées');
      }

      _isInitialized = true;
      print(
          '[QuestionTranslationService] ✅ Service de traduction des questions initialisé');
    } catch (e) {
      print('[QuestionTranslationService] ❌ Erreur initialisation: $e');
      _isInitialized = true; // Continuer avec les traductions hardcodées
    }
  }

  // Créer des traductions par défaut
  static void _createDefaultTranslations() {
    _questionTranslations = {
      'fr': {
        'categories': {
          'Histoire du Mali': 'Histoire du Mali',
          'Culture générale': 'Culture générale',
          'Sciences': 'Sciences',
          'Mathématiques': 'Mathématiques',
          'Afrique': 'Afrique',
          'Football': 'Football',
          'Musique': 'Musique',
          'Technologie et Innovation': 'Technologie et Innovation',
          'Santé et Médecine': 'Santé et Médecine',
          'Environnement et Écologie': 'Environnement et Écologie',
          'Arts et Culture': 'Arts et Culture',
          'Politique et Économie': 'Politique et Économie',
        },
        'difficulties': {
          'Facile': 'Facile',
          'Moyen': 'Moyen',
          'Difficile': 'Difficile',
        }
      },
      'en': {
        'categories': {
          'Histoire du Mali': 'Mali History',
          'Culture générale': 'General Knowledge',
          'Sciences': 'Sciences',
          'Mathématiques': 'Mathematics',
          'Afrique': 'Africa',
          'Football': 'Football',
          'Musique': 'Music',
          'Technologie et Innovation': 'Technology and Innovation',
          'Santé et Médecine': 'Health and Medicine',
          'Environnement et Écologie': 'Environment and Ecology',
          'Arts et Culture': 'Arts and Culture',
          'Politique et Économie': 'Politics and Economy',
        },
        'difficulties': {
          'Facile': 'Easy',
          'Moyen': 'Medium',
          'Difficile': 'Hard',
        }
      },
      'ar': {
        'categories': {
          'Histoire du Mali': 'تاريخ مالي',
          'Culture générale': 'الثقافة العامة',
          'Sciences': 'العلوم',
          'Mathématiques': 'الرياضيات',
          'Afrique': 'أفريقيا',
          'Football': 'كرة القدم',
          'Musique': 'الموسيقى',
          'Technologie et Innovation': 'التكنولوجيا والابتكار',
          'Santé et Médecine': 'الصحة والطب',
          'Environnement et Écologie': 'البيئة والإيكولوجيا',
          'Arts et Culture': 'الفنون والثقافة',
          'Politique et Économie': 'السياسة والاقتصاد',
        },
        'difficulties': {
          'Facile': 'سهل',
          'Moyen': 'متوسط',
          'Difficile': 'صعب',
        }
      },
      'zh': {
        'categories': {
          'Histoire du Mali': '马里历史',
          'Culture générale': '常识',
          'Sciences': '科学',
          'Mathématiques': '数学',
          'Afrique': '非洲',
          'Football': '足球',
          'Musique': '音乐',
          'Technologie et Innovation': '技术与创新',
          'Santé et Médecine': '健康与医学',
          'Environnement et Écologie': '环境与生态',
          'Arts et Culture': '艺术与文化',
          'Politique et Économie': '政治与经济',
        },
        'difficulties': {
          'Facile': '简单',
          'Moyen': '中等',
          'Difficile': '困难',
        }
      },
      'hi': {
        'categories': {
          'Histoire du Mali': 'माली का इतिहास',
          'Culture générale': 'सामान्य संस्कृति',
          'Sciences': 'विज्ञान',
          'Mathématiques': 'गणित',
          'Afrique': 'अफ्रीका',
          'Football': 'फुटबॉल',
          'Musique': 'संगीत',
          'Technologie et Innovation': 'प्रौद्योगिकी और नवाचार',
          'Santé et Médecine': 'स्वास्थ्य और चिकित्सा',
          'Environnement et Écologie': 'पर्यावरण और पारिस्थितिकी',
          'Arts et Culture': 'कला और संस्कृति',
          'Politique et Économie': 'राजनीति और अर्थशास्त्र',
        },
        'difficulties': {
          'Facile': 'आसान',
          'Moyen': 'मध्यम',
          'Difficile': 'कठिन',
        }
      },
      'es': {
        'categories': {
          'Histoire du Mali': 'Historia de Malí',
          'Culture générale': 'Cultura general',
          'Sciences': 'Ciencias',
          'Mathématiques': 'Matemáticas',
          'Afrique': 'África',
          'Football': 'Fútbol',
          'Musique': 'Música',
          'Technologie et Innovation': 'Tecnología e Innovación',
          'Santé et Médecine': 'Salud y Medicina',
          'Environnement et Écologie': 'Medio Ambiente y Ecología',
          'Arts et Culture': 'Artes y Cultura',
          'Politique et Économie': 'Política y Economía',
        },
        'difficulties': {
          'Facile': 'Fácil',
          'Moyen': 'Medio',
          'Difficile': 'Difícil',
        }
      }
    };
    _isInitialized = true;
  }

  // Traduire une catégorie
  static String translateCategory(String category) {
    final currentLanguage = TranslationService.getCurrentLanguage();
    final translations = _questionTranslations[currentLanguage];

    if (translations != null && translations['categories'] != null) {
      return translations['categories'][category] ?? category;
    }
    return category;
  }

  // Traduire une difficulté
  static String translateDifficulty(String difficulty) {
    final currentLanguage = TranslationService.getCurrentLanguage();
    final translations = _questionTranslations[currentLanguage];

    if (translations != null && translations['difficulties'] != null) {
      return translations['difficulties'][difficulty] ?? difficulty;
    }
    return difficulty;
  }

  // Traduire une question (pour les questions dynamiques)
  static Map<String, dynamic> translateQuestion(Map<String, dynamic> question) {
    final currentLanguage = TranslationService.getCurrentLanguage();
    final translations = _questionTranslations[currentLanguage];

    if (translations == null || translations['questions'] == null) {
      return question; // Retourner la question originale si pas de traduction
    }

    final questionId = question['id'] ?? question['question'];
    final translatedQuestion = translations['questions'][questionId];

    if (translatedQuestion != null) {
      return {
        ...question,
        'question': translatedQuestion['question'] ?? question['question'],
        'answers': translatedQuestion['answers'] ?? question['answers'],
        'explanation':
            translatedQuestion['explanation'] ?? question['explanation'],
      };
    }

    return question;
  }

  // Obtenir toutes les traductions pour une langue
  static Map<String, dynamic> getTranslationsForLanguage(String language) {
    return _questionTranslations[language] ?? {};
  }

  // Vérifier si une langue est supportée
  static bool isLanguageSupported(String language) {
    return _questionTranslations.containsKey(language);
  }

  // Obtenir les langues supportées
  static List<String> getSupportedLanguages() {
    return _questionTranslations.keys.toList();
  }
}
