import 'dart:convert';
import 'dart:io';

// Script pour générer automatiquement des questions supplémentaires
void main() {
  print('🚀 Génération automatique de questions supplémentaires...');

  // Modèles de questions par catégorie
  Map<String, List<Map<String, dynamic>>> questionTemplates = {
    'Histoire du Mali': [
      {
        'template': 'Quel était le nom de {element} en {période} ?',
        'elements': [
          'la capitale',
          'le roi',
          'l\'empire',
          'la ville',
          'le fleuve'
        ],
        'periodes': [
          'l\'Empire du Mali',
          'l\'Empire Songhaï',
          'la période coloniale',
          'l\'indépendance'
        ],
        'answers': ['Gao', 'Tombouctou', 'Bamako', 'Ségou', 'Mopti'],
        'explanations': [
          'Gao était une ville importante de l\'Empire Songhaï.',
          'Tombouctou était un centre culturel et commercial majeur.',
          'Bamako est la capitale actuelle du Mali.',
          'Ségou était un royaume important au Mali.',
          'Mopti est une ville portuaire importante.'
        ]
      }
    ],
    'Sciences': [
      {
        'template': 'Quel est le nom de {concept} en {domaine} ?',
        'concepts': [
          'la force',
          'l\'énergie',
          'la matière',
          'la réaction',
          'l\'élément'
        ],
        'domaines': ['physique', 'chimie', 'biologie', 'astronomie'],
        'answers': [
          'La gravité',
          'L\'électricité',
          'L\'atome',
          'La photosynthèse',
          'L\'oxygène'
        ],
        'explanations': [
          'La gravité est une force fondamentale de la nature.',
          'L\'électricité est une forme d\'énergie.',
          'L\'atome est la plus petite unité de matière.',
          'La photosynthèse est le processus de production d\'énergie des plantes.',
          'L\'oxygène est un élément essentiel à la vie.'
        ]
      }
    ],
    'Mathématiques': [
      {
        'template': 'Quel est le résultat de {opération} ?',
        'operations': ['2 + 3', '5 × 4', '10 ÷ 2', '7 - 3', '3²'],
        'answers': ['5', '20', '5', '4', '9'],
        'explanations': [
          '2 + 3 = 5 est une addition simple.',
          '5 × 4 = 20 est une multiplication.',
          '10 ÷ 2 = 5 est une division.',
          '7 - 3 = 4 est une soustraction.',
          '3² = 9 est le carré de 3.'
        ]
      }
    ]
  };

  // Générer les questions
  Map<String, List<Map<String, dynamic>>> generatedQuestions = {};

  for (String category in questionTemplates.keys) {
    generatedQuestions[category] = [];

    for (Map<String, dynamic> template in questionTemplates[category]!) {
      for (int i = 0; i < 20; i++) {
        // Générer 20 questions par template
        Map<String, dynamic> question = generateQuestion(template, i);
        generatedQuestions[category]!.add(question);
      }
    }
  }

  // Sauvegarder dans un fichier JSON
  File outputFile = File('assets/questions/generated_questions_phase5.json');
  outputFile.writeAsStringSync(jsonEncode(generatedQuestions));

  print(
      '✅ ${generatedQuestions.values.expand((x) => x).length} questions générées !');
  print(
      '📁 Fichier sauvegardé: assets/questions/generated_questions_phase5.json');
}

Map<String, dynamic> generateQuestion(
    Map<String, dynamic> template, int index) {
  String questionText = template['template'];
  List<String> answers = List<String>.from(template['answers']);
  List<String> explanations = List<String>.from(template['explanations']);

  // Remplacer les placeholders
  if (template.containsKey('elements')) {
    String element = template['elements'][index % template['elements'].length];
    questionText = questionText.replaceAll('{element}', element);
  }

  if (template.containsKey('periodes')) {
    String periode = template['periodes'][index % template['periodes'].length];
    questionText = questionText.replaceAll('{période}', periode);
  }

  if (template.containsKey('concepts')) {
    String concept = template['concepts'][index % template['concepts'].length];
    questionText = questionText.replaceAll('{concept}', concept);
  }

  if (template.containsKey('domaines')) {
    String domaine = template['domaines'][index % template['domaines'].length];
    questionText = questionText.replaceAll('{domaine}', domaine);
  }

  if (template.containsKey('operations')) {
    String operation =
        template['operations'][index % template['operations'].length];
    questionText = questionText.replaceAll('{opération}', operation);
  }

  // Sélectionner la bonne réponse
  String correctAnswer = answers[index % answers.length];
  String explanation = explanations[index % explanations.length];

  // Générer les mauvaises réponses
  List<String> wrongAnswers = answers.where((a) => a != correctAnswer).toList();
  wrongAnswers.shuffle();
  wrongAnswers = wrongAnswers.take(3).toList();

  // Créer les options
  List<String> options = [correctAnswer, ...wrongAnswers];
  options.shuffle();

  // Créer la map des réponses
  Map<String, bool> answersMap = {};
  for (String option in options) {
    answersMap[option] = option == correctAnswer;
  }

  return {
    'question': questionText,
    'answers': answersMap,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'difficulty': 'medium',
    'subcategory': 'Généré automatiquement'
  };
}
