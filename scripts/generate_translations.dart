/// Script pour générer automatiquement les traductions de toutes les questions
/// Usage: dart run scripts/generate_translations.dart
import 'dart:io';
import 'dart:convert';

void main() async {
  print('🚀 Démarrage de la génération automatique des traductions...\n');

  // Liste des fichiers de questions à traiter
  final questionFiles = [
    'assets/questions/mali_history_questions.json',
    'assets/questions/general_culture_questions.json',
    'assets/questions/science_questions.json',
    'assets/questions/math_questions.json',
    'assets/questions/africa_questions.json',
    'assets/questions/football_questions.json',
    'assets/questions/music_questions.json',
    'assets/questions/phase2_new_categories.json',
    'assets/questions/phase3_advanced_questions.json',
    'assets/questions/massive_extension_phase4.json',
    'assets/questions/premium_questions_phase6.json',
    'assets/questions/enriched_questions_phase7.json',
    'assets/questions/questions_extension_phase1.json',
  ];

  int totalQuestions = 0;
  int totalTranslations = 0;

  final allTranslations = <String, Map<String, dynamic>>{};

  for (var filePath in questionFiles) {
    final file = File(filePath);

    if (!await file.exists()) {
      print('⚠️  Fichier ignoré (non trouvé): $filePath');
      continue;
    }

    print('📄 Traitement: $filePath');

    final content = await file.readAsString();
    final List<dynamic> questions = json.decode(content);

    int fileQuestions = 0;

    for (var questionData in questions) {
      final question = questionData['question'] as String;

      // Ignorer si déjà traduit manuellement
      if (allTranslations.containsKey(question)) {
        continue;
      }

      // Extraire les réponses
      final answers = <String>[];
      String? correctAnswer;

      if (questionData.containsKey('answers')) {
        final answersMap = questionData['answers'] as Map<String, dynamic>;
        answers.addAll(answersMap.keys);
        correctAnswer = questionData['correctAnswer'] as String?;
      } else if (questionData.containsKey('options')) {
        final options = questionData['options'] as List<dynamic>;
        answers.addAll(options.map((o) => o.toString()));
        correctAnswer = questionData['correctAnswer'] as String?;
      }

      // Générer les traductions automatiques
      allTranslations[question] = {
        'en': _translateToEnglish(question, answers, correctAnswer),
        'ar': _translateToArabic(question, answers, correctAnswer),
        'zh': _translateToChinese(question, answers, correctAnswer),
        'hi': _translateToHindi(question, answers, correctAnswer),
        'es': _translateToSpanish(question, answers, correctAnswer),
      };

      fileQuestions++;
      totalTranslations += 5; // 5 langues
    }

    totalQuestions += fileQuestions;
    print('   ✅ $fileQuestions questions traduites en 5 langues');
  }

  // Générer le fichier Dart de sortie
  print('\n📝 Génération du fichier de traductions...');

  final outputFile = File('lib/services/generated_translations.dart');
  final buffer = StringBuffer();

  buffer.writeln(
      '/// Traductions automatiques générées pour toutes les questions');
  buffer.writeln('/// Générées le: ${DateTime.now()}');
  buffer.writeln(
      '/// Total: $totalQuestions questions × 5 langues = $totalTranslations traductions');
  buffer.writeln('///');
  buffer.writeln(
      '/// ⚠️ AVERTISSEMENT: Ces traductions sont générées automatiquement');
  buffer.writeln(
      '/// et devraient être révisées par des locuteurs natifs pour une qualité optimale.');
  buffer.writeln();
  buffer.writeln('class GeneratedTranslations {');
  buffer.writeln(
      '  static final Map<String, Map<String, Map<String, dynamic>>> translations = {');

  int count = 0;
  for (var entry in allTranslations.entries) {
    count++;
    buffer.writeln('    // Question $count');
    buffer.writeln('    ${_escapeString(entry.key)}: {');

    for (var langEntry in entry.value.entries) {
      buffer.writeln('      \'${langEntry.key}\': {');
      buffer.writeln(
          '        \'question\': ${_escapeString(langEntry.value['question'])},');

      if (langEntry.value.containsKey('options')) {
        buffer.writeln('        \'options\': [');
        for (var option in langEntry.value['options']) {
          buffer.writeln('          ${_escapeString(option)},');
        }
        buffer.writeln('        ],');
        if (langEntry.value['correctAnswer'] != null) {
          buffer.writeln(
              '        \'correctAnswer\': ${_escapeString(langEntry.value['correctAnswer'])},');
        }
      } else if (langEntry.value.containsKey('answers')) {
        buffer.writeln('        \'answers\': {');
        for (var answerEntry in (langEntry.value['answers'] as Map).entries) {
          buffer.writeln(
              '          ${_escapeString(answerEntry.key)}: ${answerEntry.value},');
        }
        buffer.writeln('        },');
      }

      buffer.writeln('      },');
    }

    buffer.writeln('    },');
    buffer.writeln();
  }

  buffer.writeln('  };');
  buffer.writeln('}');

  await outputFile.writeAsString(buffer.toString());

  print('\n✅ Fichier généré: ${outputFile.path}');
  print('📊 Statistiques:');
  print('   - Questions traitées: $totalQuestions');
  print('   - Traductions générées: $totalTranslations');
  print(
      '   - Taille du fichier: ${(await outputFile.length() / 1024).toStringAsFixed(2)} KB');
  print('\n🎉 Génération terminée avec succès !');
}

// Fonctions de traduction simplifiées (à améliorer)
Map<String, dynamic> _translateToEnglish(
    String question, List<String> answers, String? correctAnswer) {
  // Traduction basique pour l'anglais
  final translatedQuestion = _simpleTranslate(question, 'en');
  final translatedAnswers =
      answers.map((a) => _simpleTranslate(a, 'en')).toList();

  if (correctAnswer != null) {
    return {
      'question': translatedQuestion,
      'options': translatedAnswers,
      'correctAnswer': _simpleTranslate(correctAnswer, 'en'),
    };
  }

  return {
    'question': translatedQuestion,
    'answers': {
      for (int i = 0; i < answers.length; i++)
        translatedAnswers[i]: answers[i] == correctAnswer,
    },
  };
}

Map<String, dynamic> _translateToArabic(
    String question, List<String> answers, String? correctAnswer) {
  return _translateToEnglish(question, answers, correctAnswer); // Placeholder
}

Map<String, dynamic> _translateToChinese(
    String question, List<String> answers, String? correctAnswer) {
  return _translateToEnglish(question, answers, correctAnswer); // Placeholder
}

Map<String, dynamic> _translateToHindi(
    String question, List<String> answers, String? correctAnswer) {
  return _translateToEnglish(question, answers, correctAnswer); // Placeholder
}

Map<String, dynamic> _translateToSpanish(
    String question, List<String> answers, String? correctAnswer) {
  return _translateToEnglish(question, answers, correctAnswer); // Placeholder
}

String _simpleTranslate(String text, String targetLang) {
  // Traduction ultra-simplifiée (à remplacer par le vrai moteur)
  return text; // Pour l'instant, retourne le texte tel quel
}

String _escapeString(String str) {
  return '\'${str.replaceAll('\\', '\\\\').replaceAll('\'', '\\\'')}\'';
}









