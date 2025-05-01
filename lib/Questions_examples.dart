import 'models/QuestionModel.dart';

List<QuestionModel> scienceQuestions = [
  QuestionModel(
    question: 'Quel est l’élément chimique dont le symbole est O ?',
    answers: {'Oxygène': true, 'Or': false, 'Osmium': false},
    correctAnswer: 'Oxygène',
  ),
  QuestionModel(
    question: 'Quelle planète est la plus proche du Soleil ?',
    answers: {'Vénus': false, 'Mercure': true, 'Mars': false},
    correctAnswer: 'Mercure',
  ),
  QuestionModel(
    question: 'Combien de pattes a une araignée ?',
    answers: {'6': false, '8': true, '10': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Que mesure un thermomètre ?',
    answers: {'La température': true, 'Le volume': false, 'Le poids': false},
    correctAnswer: 'La température',
  ),
  QuestionModel(
    question: 'Combien de dents possède un humain adulte ?',
    answers: {'28': false, '32': true, '36': false},
    correctAnswer: '32',
  ),
  QuestionModel(
    question: 'Quel gaz est essentiel à la respiration des humains ?',
    answers: {'Hydrogène': false, 'Oxygène': true, 'Carbone': false},
    correctAnswer: 'Oxygène',
  ),
  QuestionModel(
    question: 'Quelle partie du corps contient le cerveau ?',
    answers: {'La tête': true, 'Le thorax': false, 'Le bras': false},
    correctAnswer: 'La tête',
  ),
  QuestionModel(
    question: 'Combien de planètes y a-t-il dans notre système solaire ?',
    answers: {'7': false, '8': true, '9': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Quel est l’état de l’eau à 100°C ?',
    answers: {'Solide': false, 'Liquide': false, 'Gazeux': true},
    correctAnswer: 'Gazeux',
  ),
  QuestionModel(
    question: 'Quel organe pompe le sang ?',
    answers: {'Le cerveau': false, 'Le foie': false, 'Le cœur': true},
    correctAnswer: 'Le cœur',
  ),
  QuestionModel(
    question: 'Quelle étoile éclaire notre planète ?',
    answers: {'La Lune': false, 'Le Soleil': true, 'Mars': false},
    correctAnswer: 'Le Soleil',
  ),
  QuestionModel(
    question: 'Quel est l’organe principal de la respiration ?',
    answers: {'Le nez': false, 'Les poumons': true, 'Le cœur': false},
    correctAnswer: 'Les poumons',
  ),
  QuestionModel(
    question: 'Quel est le plus grand organe du corps humain ?',
    answers: {'Le foie': false, 'La peau': true, 'Le cerveau': false},
    correctAnswer: 'La peau',
  ),
  QuestionModel(
    question: 'Que fait un microscope ?',
    answers: {'Agrandit des objets': true, 'Mesure le poids': false, 'Montre la météo': false},
    correctAnswer: 'Agrandit des objets',
  ),
  QuestionModel(
    question: 'Combien de phases a la Lune ?',
    answers: {'2': false, '4': true, '6': false},
    correctAnswer: '4',
  ),
  QuestionModel(
    question: 'Quel est le cycle de l’eau ?',
    answers: {
      'Évaporation, condensation, précipitation': true,
      'Fusion, sublimation, combustion': false,
      'Vent, nuage, pluie': false,
    },
    correctAnswer: 'Évaporation, condensation, précipitation',
  ),
  QuestionModel(
    question: 'Quelle force nous maintient sur Terre ?',
    answers: {'Magnétisme': false, 'Gravité': true, 'Électricité': false},
    correctAnswer: 'Gravité',
  ),
  QuestionModel(
    question: 'Quel liquide circule dans notre corps ?',
    answers: {'L’urine': false, 'Le sang': true, 'La sueur': false},
    correctAnswer: 'Le sang',
  ),
  QuestionModel(
    question: 'Quel est le symbole chimique de l’eau ?',
    answers: {'CO2': false, 'H2O': true, 'NaCl': false},
    correctAnswer: 'H2O',
  ),
  QuestionModel(
    question: 'Quel animal pond des œufs ?',
    answers: {'Le chien': false, 'Le serpent': true, 'Le chat': false},
    correctAnswer: 'Le serpent',
  ),
];

List<QuestionModel> cultureGeneralQuestions = [
  QuestionModel(
    question: 'Quel est le plus grand océan du monde ?',
    answers: {
      'Océan Atlantique': false,
      'Océan Indien': false,
      'Océan Pacifique': true,
    },
    correctAnswer: 'Océan Pacifique',
  ),
  QuestionModel(
    question: 'Quel pays a la forme d’une botte ?',
    answers: {'Espagne': false, 'Italie': true, 'Grèce': false},
    correctAnswer: 'Italie',
  ),
  QuestionModel(
    question: 'Quel est le plus long fleuve du monde ?',
    answers: {'Nil': true, 'Amazonie': false, 'Mississippi': false},
    correctAnswer: 'Nil',
  ),
  QuestionModel(
    question: 'Dans quel pays se trouve la tour Eiffel ?',
    answers: {'Italie': false, 'France': true, 'Allemagne': false},
    correctAnswer: 'France',
  ),
  QuestionModel(
    question: 'Qui a peint la Joconde ?',
    answers: {'Picasso': false, 'Leonardo da Vinci': true, 'Van Gogh': false},
    correctAnswer: 'Leonardo da Vinci',
  ),
  QuestionModel(
    question: 'Combien y a-t-il de continents ?',
    answers: {'5': false, '6': false, '7': true},
    correctAnswer: '7',
  ),
  QuestionModel(
    question: 'Quelle est la capitale de l’Allemagne ?',
    answers: {'Munich': false, 'Berlin': true, 'Francfort': false},
    correctAnswer: 'Berlin',
  ),
  QuestionModel(
    question: 'Quelle langue parle-t-on au Brésil ?',
    answers: {'Espagnol': false, 'Portugais': true, 'Français': false},
    correctAnswer: 'Portugais',
  ),
  QuestionModel(
    question: 'Quel monument est situé à New York ?',
    answers: {'Tour Eiffel': false, 'Statue de la Liberté': true, 'Big Ben': false},
    correctAnswer: 'Statue de la Liberté',
  ),
  QuestionModel(
    question: 'Quel est le plus grand désert du monde ?',
    answers: {'Sahara': true, 'Gobi': false, 'Kalahari': false},
    correctAnswer: 'Sahara',
  ),
  QuestionModel(
    question: 'Quel animal est le roi de la jungle ?',
    answers: {'Tigre': false, 'Lion': true, 'Éléphant': false},
    correctAnswer: 'Lion',
  ),
  QuestionModel(
    question: 'Quelle est la monnaie utilisée aux États-Unis ?',
    answers: {'Dollar': true, 'Euro': false, 'Livre': false},
    correctAnswer: 'Dollar',
  ),
  QuestionModel(
    question: 'Quel pays a une feuille d’érable sur son drapeau ?',
    answers: {'Canada': true, 'Japon': false, 'Brésil': false},
    correctAnswer: 'Canada',
  ),
  QuestionModel(
    question: 'Où se trouve la Grande Muraille ?',
    answers: {'Chine': true, 'Japon': false, 'Inde': false},
    correctAnswer: 'Chine',
  ),
  QuestionModel(
    question: 'Quel fruit est jaune et courbé ?',
    answers: {'Pomme': false, 'Banane': true, 'Orange': false},
    correctAnswer: 'Banane',
  ),
  QuestionModel(
    question: 'Quelle fête célèbre les morts au Mexique ?',
    answers: {'Halloween': false, 'Día de los Muertos': true, 'Pâques': false},
    correctAnswer: 'Día de los Muertos',
  ),
  QuestionModel(
    question: 'Quel est le plus grand mammifère marin ?',
    answers: {'Requin': false, 'Baleine bleue': true, 'Dauphin': false},
    correctAnswer: 'Baleine bleue',
  ),
  QuestionModel(
    question: 'Quel pays est surnommé le pays du Soleil Levant ?',
    answers: {'Chine': false, 'Japon': true, 'Corée': false},
    correctAnswer: 'Japon',
  ),
  QuestionModel(
    question: 'Dans quel pays est né le flamenco ?',
    answers: {'Italie': false, 'Espagne': true, 'Portugal': false},
    correctAnswer: 'Espagne',
  ),
  QuestionModel(
    question: 'Quel est le symbole de la paix ?',
    answers: {'Colombe': true, 'Épée': false, 'Fusil': false},
    correctAnswer: 'Colombe',
  ),
];

List<QuestionModel> mathQuestions = [
  QuestionModel(
    question: 'Combien font 7 x 8 ?',
    answers: {'54': false, '56': true, '58': false},
    correctAnswer: '56',
  ),
  QuestionModel(
    question: 'Combien font 10 + 5 ?',
    answers: {'14': false, '15': true, '16': false},
    correctAnswer: '15',
  ),
  QuestionModel(
    question: 'Quel est le double de 12 ?',
    answers: {'22': false, '24': true, '26': false},
    correctAnswer: '24',
  ),
  QuestionModel(
    question: 'Combien de côtés a un triangle ?',
    answers: {'3': true, '4': false, '5': false},
    correctAnswer: '3',
  ),
  QuestionModel(
    question: 'Combien font 100 ÷ 10 ?',
    answers: {'5': false, '10': true, '15': false},
    correctAnswer: '10',
  ),
  QuestionModel(
    question: 'Combien font 9 + 6 ?',
    answers: {'15': true, '16': false, '14': false},
    correctAnswer: '15',
  ),
  QuestionModel(
    question: 'Combien de zéros dans mille ?',
    answers: {'2': false, '3': true, '4': false},
    correctAnswer: '3',
  ),
  QuestionModel(
    question: 'Quel est le carré de 5 ?',
    answers: {'10': false, '25': true, '15': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Que signifie « moitié » ?',
    answers: {'Le quart': false, 'La moitié': true, 'Le double': false},
    correctAnswer: 'La moitié',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 3 x 4 ?',
    answers: {'12': true, '14': false, '16': false},
    correctAnswer: '12',
  ),
  QuestionModel(
    question: 'Combien fait 15 – 7 ?',
    answers: {'8': true, '7': false, '9': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Quel est le tiers de 30 ?',
    answers: {'10': true, '15': false, '5': false},
    correctAnswer: '10',
  ),
  QuestionModel(
    question: 'Combien de minutes dans une heure ?',
    answers: {'60': true, '100': false, '90': false},
    correctAnswer: '60',
  ),
  QuestionModel(
    question: 'Combien de centimètres dans un mètre ?',
    answers: {'10': false, '100': true, '1000': false},
    correctAnswer: '100',
  ),
  QuestionModel(
    question: 'Quel nombre vient après 99 ?',
    answers: {'100': true, '98': false, '101': false},
    correctAnswer: '100',
  ),
  QuestionModel(
    question: 'Quel est le plus petit nombre pair ?',
    answers: {'0': true, '1': false, '2': false},
    correctAnswer: '0',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 2 + 2 x 2 ?',
    answers: {'6': true, '8': false, '12': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Quel est le chiffre des unités dans 125 ?',
    answers: {'5': true, '2': false, '1': false},
    correctAnswer: '5',
  ),
  QuestionModel(
    question: 'Combien de faces a un cube ?',
    answers: {'6': true, '8': false, '4': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Combien font 20 – 17 ?',
    answers: {'3': true, '2': false, '5': false},
    correctAnswer: '3',
  ),
];
