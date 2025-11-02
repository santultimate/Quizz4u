import 'dart:io';
import 'dart:convert';
import '../lib/services/bulk_auto_translator.dart';

/// Script pour traduire automatiquement les nouvelles questions d'expansion
/// Utilise le BulkAutoTranslator enrichi pour traduire en AR, EN, ZH, HI, ES
void main() async {
  print('🌍 Démarrage de la traduction des questions d\'expansion...\n');

  final languages = ['ar', 'en', 'zh', 'hi', 'es'];
  final expansionFiles = [
    'technology_questions_expansion.json',
    'environment_questions_expansion.json',
    'arts_culture_questions_expansion.json',
    'politics_economy_questions_expansion.json',
    'health_medicine_questions_expansion.json',
  ];

  final baseDir = 'assets/questions';

  for (final file in expansionFiles) {
    print('📄 Traitement de $file...');
    final filePath = '$baseDir/$file';

    try {
      // Lire le fichier source (français)
      final sourceFile = File(filePath);
      if (!sourceFile.existsSync()) {
        print('   ⚠️  Fichier non trouvé: $file');
        continue;
      }

      final sourceContent = sourceFile.readAsStringSync();
      final sourceData = json.decode(sourceContent) as Map<String, dynamic>;

      // Traduire pour chaque langue
      for (final lang in languages) {
        print('   🔄 Traduction en ${_getLanguageName(lang)}...');

        final translatedData = <String, dynamic>{};

        // Pour chaque catégorie
        for (final categoryEntry in sourceData.entries) {
          final category = categoryEntry.key;
          final translatedCategory = _translateCategory(category, lang);
          translatedData[translatedCategory] = <String, dynamic>{};

          final subcategories = categoryEntry.value as Map<String, dynamic>;

          // Pour chaque sous-catégorie
          for (final subcatEntry in subcategories.entries) {
            final subcat = subcatEntry.key;
            final translatedSubcat = BulkAutoTranslator.translateQuestion(
                subcat, lang,
                category: category);
            translatedData[translatedCategory][translatedSubcat] = [];

            final questions = subcatEntry.value as List;

            // Pour chaque question
            for (final q in questions) {
              final question = q as Map<String, dynamic>;

              final questionOptions = (question['options'] as List)
                  .map((e) => e.toString())
                  .toList();

              final translatedOptions = BulkAutoTranslator.translateAnswers(
                questionOptions,
                lang,
                category: category,
              );

              final translatedQuestion = <String, dynamic>{
                'question': BulkAutoTranslator.translateQuestion(
                  question['question'],
                  lang,
                  category: category,
                ),
                'options': translatedOptions,
                'correctAnswer': BulkAutoTranslator.translateQuestion(
                  question['correctAnswer'],
                  lang,
                  category: category,
                ),
                'explanation': BulkAutoTranslator.translateQuestion(
                  question['explanation'],
                  lang,
                  category: category,
                ),
                'difficulty':
                    _translateDifficulty(question['difficulty'], lang),
                'category': translatedCategory,
                'subcategory': translatedSubcat,
              };

              (translatedData[translatedCategory][translatedSubcat] as List)
                  .add(translatedQuestion);
            }
          }
        }

        // Sauvegarder le fichier traduit
        final outputFileName = file.replaceAll('.json', '_$lang.json');
        final outputFile = File('$baseDir/$outputFileName');

        final encoder = JsonEncoder.withIndent('  ');
        outputFile.writeAsStringSync(encoder.convert(translatedData));

        print('   ✅ Fichier créé: $outputFileName');
      }

      print('   ✅ Traduction de $file terminée!\n');
    } catch (e) {
      print('   ❌ Erreur lors du traitement de $file: $e\n');
    }
  }

  print('\n🎉 Traduction terminée avec succès!');
  print('📊 Statistiques:');
  print('   - Fichiers source: ${expansionFiles.length}');
  print('   - Langues cibles: ${languages.length}');
  print('   - Fichiers créés: ${expansionFiles.length * languages.length}');
}

String _translateCategory(String category, String targetLang) {
  final categoryMap = {
    'Technologie et Innovation': {
      'ar': 'التكنولوجيا والابتكار',
      'en': 'Technology and Innovation',
      'zh': '科技与创新',
      'hi': 'प्रौद्योगिकी और नवाचार',
      'es': 'Tecnología e Innovación',
    },
    'Environnement et Écologie': {
      'ar': 'البيئة والإيكولوجيا',
      'en': 'Environment and Ecology',
      'zh': '环境与生态',
      'hi': 'पर्यावरण और पारिस्थितिकी',
      'es': 'Medio Ambiente y Ecología',
    },
    'Arts et Culture': {
      'ar': 'الفنون والثقافة',
      'en': 'Arts and Culture',
      'zh': '艺术与文化',
      'hi': 'कला और संस्कृति',
      'es': 'Artes y Cultura',
    },
    'Politique et Économie': {
      'ar': 'السياسة والاقتصاد',
      'en': 'Politics and Economics',
      'zh': '政治与经济',
      'hi': 'राजनीति और अर्थशास्त्र',
      'es': 'Política y Economía',
    },
    'Santé et Médecine': {
      'ar': 'الصحة والطب',
      'en': 'Health and Medicine',
      'zh': '健康与医学',
      'hi': 'स्वास्थ्य और चिकित्सा',
      'es': 'Salud y Medicina',
    },
  };

  return categoryMap[category]?[targetLang] ?? category;
}

String _getLanguageName(String code) {
  switch (code) {
    case 'ar':
      return 'Arabe';
    case 'en':
      return 'Anglais';
    case 'zh':
      return 'Chinois';
    case 'hi':
      return 'Hindi';
    case 'es':
      return 'Espagnol';
    default:
      return code;
  }
}

String _translateDifficulty(String difficulty, String targetLang) {
  final diffMap = {
    'easy': {
      'ar': 'سهل',
      'en': 'Easy',
      'zh': '简单',
      'hi': 'आसान',
      'es': 'Fácil',
    },
    'medium': {
      'ar': 'متوسط',
      'en': 'Medium',
      'zh': '中等',
      'hi': 'मध्यम',
      'es': 'Medio',
    },
    'hard': {
      'ar': 'صعب',
      'en': 'Hard',
      'zh': '困难',
      'hi': 'कठिन',
      'es': 'Difícil',
    },
    'expert': {
      'ar': 'خبير',
      'en': 'Expert',
      'zh': '专家',
      'hi': 'विशेषज्ञ',
      'es': 'Experto',
    },
  };

  return diffMap[difficulty.toLowerCase()]?[targetLang] ?? difficulty;
}
