import 'models/QuestionModel.dart';

// Liste de questions de culture générale

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

  QuestionModel(
    question: "Quel est l’élément chimique dont le symbole est 'Na' ?",
    answers: {
      "Le sodium": true,
      "Le néon": false,
      "Le nickel": false,
      "Le niobium": false,
    },
    correctAnswer: "Le sodium",
  ),

  QuestionModel(
    question: 'Quelle planète est surnommée la planète rouge ?',
    answers: {
      'Mars': true,
      'Jupiter': false,
      'Saturne': false,
      'Mercure': false,
    },
    correctAnswer: 'Mars',
  ),
  QuestionModel(
    question: 'Quel est le principal gaz responsable de l’effet de serre ?',
    answers: {
      'Dioxyde de carbone': true,
      'Oxygène': false,
      'Hydrogène': false,
      'Azote': false,
    },
    correctAnswer: 'Dioxyde de carbone',
  ),
  QuestionModel(
    question: 'Combien de paires de chromosomes possède l’humain ?',
    answers: {
      '23': true,
      '46': false,
      '22': false,
      '21': false,
    },
    correctAnswer: '23',
  ),
  QuestionModel(
    question: 'Quel est le rôle des racines d’une plante ?',
    answers: {
      'Absorber l’eau et les nutriments': true,
      'Produire des fleurs': false,
      'Faire des fruits': false,
      'Respirer': false,
    },
    correctAnswer: 'Absorber l’eau et les nutriments',
  ),

  QuestionModel(
  question: "Quel est l’animal terrestre le plus rapide ?",
  answers: {
    "Lion": false,
    "Gazelle": false,
    "Guépard": true,
    "Tigre": false,
  },
  correctAnswer: "Guépard",
),
QuestionModel(
  question: "Quel organe est responsable de la respiration ?",
  answers: {
    "Estomac": false,
    "Reins": false,
    "Poumons": true,
    "Pancréas": false,
  },
  correctAnswer: "Poumons",
),
QuestionModel(
  question: "Quel astre éclaire la Terre le jour ?",
  answers: {
    "La Lune": false,
    "Les étoiles": false,
    "Le Soleil": true,
    "Mars": false,
  },
  correctAnswer: "Le Soleil",
),
QuestionModel(
  question: "Quelle force nous maintient au sol ?",
  answers: {
    "L’électricité": false,
    "La pression": false,
    "La gravité": true,
    "La friction": false,
  },
  correctAnswer: "La gravité",
),
QuestionModel(
  question: "De quoi sont faites les étoiles ?",
  answers: {
    "Roches": false,
    "Gaz": true,
    "Glace": false,
    "Métaux": false,
  },
  correctAnswer: "Gaz",
),
QuestionModel(
  question: "Quel instrument utilise-t-on pour observer les étoiles ?",
  answers: {
    "Microscope": false,
    "Télescope": true,
    "Loupe": false,
    "Satellite": false,
  },
  correctAnswer: "Télescope",
),
QuestionModel(
  question: "Quelle est la planète la plus proche du Soleil ?",
  answers: {
    "Venus": false,
    "Terre": false,
    "Mars": false,
    "Mercure": true,
  },
  correctAnswer: "Mercure",
),
QuestionModel(
  question: "Qu’est-ce qu’une éclipse ?",
  answers: {
    "Une pluie de météorites": false,
    "Un tremblement de terre": false,
    "Une ombre projetée entre astres": true,
    "Une explosion solaire": false,
  },
  correctAnswer: "Une ombre projetée entre astres",
),
QuestionModel(
  question: "Quel est le cycle de l’eau ?",
  answers: {
    "Fusion, ruissellement, fonte": false,
    "Evaporation, condensation, précipitation": true,
    "Sublimation, solidification, combustion": false,
    "Chauffage, refroidissement, stagnation": false,
  },
  correctAnswer: "Evaporation, condensation, précipitation",
),
QuestionModel(
  question: "Que produit un volcan lorsqu’il entre en éruption ?",
  answers: {
    "Glace": false,
    "Lave": true,
    "Sable": false,
    "Argile": false,
  },
  correctAnswer: "Lave",
),
QuestionModel(
  question: "Quel métal attire l’aimant ?",
  answers: {
    "Aluminium": false,
    "Fer": true,
    "Cuivre": false,
    "Or": false,
  },
  correctAnswer: "Fer",
),

];

// Liste de questions de culture générale

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

  QuestionModel(
    question: 'Quel est le plus petit pays du monde ?',
    answers: {
      'Monaco': false,
      'Vatican': true,
      'Nauru': false,
    },
    correctAnswer: 'Vatican',
  ),
  QuestionModel(
    question: 'Quelle est la capitale du Canada ?',
    answers: {
      'Vancouver': false,
      'Ottawa': true,
      'Toronto': false,
    },
    correctAnswer: 'Ottawa',
  ),
  QuestionModel(
    question: 'Qui a écrit "Roméo et Juliette" ?',
    answers: {
      'Molière': false,
      'Shakespeare': true,
      'Victor Hugo': false,
    },
    correctAnswer: 'Shakespeare',
  ),
  QuestionModel(
    question: 'Quel est le plus haut sommet du monde ?',
    answers: {
      'K2': false,
      'Mont Everest': true,
      'Mont Kilimandjaro': false,
    },
    correctAnswer: 'Mont Everest',
  ),
  QuestionModel(
    question: 'Quel est le plus grand pays du monde ?',
    answers: {
      'États-Unis': false,
      'Chine': false,
      'Russie': true,
    },
    correctAnswer: 'Russie',
  ),
  QuestionModel(
    question: 'Qui a découvert l’Amérique ?',
    answers: {
      'Christophe Colomb': true,
      'Vasco de Gama': false,
      'Marco Polo': false,
    },
    correctAnswer: 'Christophe Colomb',
  ),
  QuestionModel(
    question: 'Quel est l’animal terrestre le plus rapide ?',
    answers: {
      'Guépard': true,
      'Léopard': false,
      'Lion': false,
    },
    correctAnswer: 'Guépard',
  ),
  QuestionModel(
    question: 'Qui a peint la "Cène" ?',
    answers: {
      'Vincent Van Gogh': false,
      'Leonardo da Vinci': true,
      'Pablo Picasso': false,
    },
    correctAnswer: 'Leonardo da Vinci',
  ),
  QuestionModel(
    question: 'Où se trouve le Machu Picchu ?',
    answers: {
      'Chili': false,
      'Brésil': false,
      'Pérou': true,
    },
    correctAnswer: 'Pérou',
  ),
  QuestionModel(
    question: 'Quel est l’organe qui permet de respirer ?',
    answers: {
      'Cœur': false,
      'Poumons': true,
      'Foie': false,
    },
    correctAnswer: 'Poumons',
  ),
  QuestionModel(
    question: 'Dans quel océan se trouve l’île de Madagascar ?',
    answers: {
      'Océan Atlantique': false,
      'Océan Indien': true,
      'Océan Pacifique': false,
    },
    correctAnswer: 'Océan Indien',
  ),
  QuestionModel(
    question: 'Qui a écrit "Les Misérables" ?',
    answers: {
      'Émile Zola': false,
      'Victor Hugo': true,
      'Gustave Flaubert': false,
    },
    correctAnswer: 'Victor Hugo',
  ),
  QuestionModel(
    question: 'Quel est l’élément chimique symbolisé par "O" ?',
    answers: {
      'Oxygène': true,
      'Or': false,
      'Ozone': false,
    },
    correctAnswer: 'Oxygène',
  ),
  QuestionModel(
    question: 'Quel est le nom du fleuve qui traverse Paris ?',
    answers: {
      'Seine': true,
      'Rhône': false,
      'Loire': false,
    },
    correctAnswer: 'Seine',
  ),
  QuestionModel(
    question: 'Quelle est la capitale de l’Italie ?',
    answers: {
      'Milan': false,
      'Venise': false,
      'Rome': true,
    },
    correctAnswer: 'Rome',
  ),
  QuestionModel(
    question: 'Quel est l’animal national de l’Australie ?',
    answers: {
      'Kangourou': true,
      'Koala': false,
      'Émeu': false,
    },
    correctAnswer: 'Kangourou',
  ),
  QuestionModel(
    question: 'Qui est le créateur de la théorie de la relativité ?',
    answers: {
      'Isaac Newton': false,
      'Albert Einstein': true,
      'Galilée': false,
    },
    correctAnswer: 'Albert Einstein',
  ),
  QuestionModel(
    question: 'Quelle est la monnaie utilisée au Royaume-Uni ?',
    answers: {
      'Euro': false,
      'Livre sterling': true,
      'Dollar': false,
    },
    correctAnswer: 'Livre sterling',
  ),
  QuestionModel(
    question: 'Quel est l’animal qui produit du lait ?',
    answers: {
      'Poulet': false,
      'Vache': true,
      'Mouton': false,
    },
    correctAnswer: 'Vache',
  ),
  QuestionModel(
    question: 'Quel est le plus grand oiseau du monde ?',
    answers: {
      'Autruche': true,
      'Aigle': false,
      'Cygne': false,
    },
    correctAnswer: 'Autruche',
  ),

  QuestionModel(
    question: 'Quel est le nom du célèbre détective créé par Arthur Conan Doyle ?',
    answers: {
      'Hercule Poirot': false,
      'Sherlock Holmes': true,
      'Miss Marple': false,
    },
    correctAnswer: 'Sherlock Holmes',
  ),
  QuestionModel(
    question: 'Quel est le nom de la première femme à avoir obtenu le prix Nobel ?',
    answers: {
      'Marie Curie': true,
      'Rosalind Franklin': false,
      'Ada Lovelace': false,
    },
    correctAnswer: 'Marie Curie',
  ),
  QuestionModel(
    question: 'Quel est le nom du célèbre volcan situé en Italie ?',
    answers: {
      'Vésuve': true,
      'Etna': false,
      'Kilimandjaro': false,
    },
    correctAnswer: 'Vésuve',
  ),

    QuestionModel(
    question: 'Quel pays a offert la Statue de la Liberté aux États-Unis ?',
    answers: {
      'Royaume-Uni': false,
      'France': true,
      'Italie': false,
    },
    correctAnswer: 'France',
  ),
  QuestionModel(
    question: 'Qui a inventé le téléphone ?',
    answers: {
      'Thomas Edison': false,
      'Alexander Graham Bell': true,
      'Nikola Tesla': false,
    },
    correctAnswer: 'Alexander Graham Bell',
  ),
  QuestionModel(
    question: 'Dans quel pays trouve-t-on les pyramides de Gizeh ?',
    answers: {
      'Mexique': false,
      'Égypte': true,
      'Pérou': false,
    },
    correctAnswer: 'Égypte',
  ),
  QuestionModel(
    question: 'Combien y a-t-il de continents sur Terre ?',
    answers: {
      '5': false,
      '6': false,
      '7': true,
    },
    correctAnswer: '7',
  ),
  QuestionModel(
    question: 'Quel est le plus grand désert du monde ?',
    answers: {
      'Sahara': false,
      'Antarctique': true,
      'Gobi': false,
    },
    correctAnswer: 'Antarctique',
  ),
  QuestionModel(
    question: 'Quelle est la langue la plus parlée dans le monde ?',
    answers: {
      'Anglais': false,
      'Chinois mandarin': true,
      'Espagnol': false,
    },
    correctAnswer: 'Chinois mandarin',
  ),
  QuestionModel(
    question: 'Quel est le symbole chimique du fer ?',
    answers: {
      'Fe': true,
      'Fr': false,
      'Ir': false,
    },
    correctAnswer: 'Fe',
  ),
  QuestionModel(
    question: 'Qui a composé la "Symphonie n°9" ?',
    answers: {
      'Mozart': false,
      'Beethoven': true,
      'Bach': false,
    },
    correctAnswer: 'Beethoven',
  ),
  QuestionModel(
    question: 'Dans quel pays se trouve la ville de Kyoto ?',
    answers: {
      'Chine': false,
      'Japon': true,
      'Corée du Sud': false,
    },
    correctAnswer: 'Japon',
  ),
  QuestionModel(
    question: 'Quel est le plus long fleuve du monde ?',
    answers: {
      'Nil': true,
      'Amazonie': false,
      'Mississippi': false,
    },
    correctAnswer: 'Nil',
  ),
  QuestionModel(
    question: 'Quelle est la planète la plus proche du Soleil ?',
    answers: {
      'Vénus': false,
      'Mercure': true,
      'Mars': false,
    },
    correctAnswer: 'Mercure',
  ),
  QuestionModel(
    question: 'Quelle ville est surnommée "la ville lumière" ?',
    answers: {
      'New York': false,
      'Paris': true,
      'Tokyo': false,
    },
    correctAnswer: 'Paris',
  ),
  QuestionModel(
    question: 'Quel est l’animal le plus grand du monde ?',
    answers: {
      'Girafe': false,
      'Baleine bleue': true,
      'Éléphant': false,
    },
    correctAnswer: 'Baleine bleue',
  ),
  QuestionModel(
    question: 'Quel scientifique a développé la loi de la gravité ?',
    answers: {
      'Einstein': false,
      'Newton': true,
      'Copernic': false,
    },
    correctAnswer: 'Newton',
  ),
  QuestionModel(
    question: 'Quel pays a gagné la première Coupe du Monde de football ?',
    answers: {
      'Argentine': false,
      'Uruguay': true,
      'Italie': false,
    },
    correctAnswer: 'Uruguay',
  ),
  QuestionModel(
    question: 'Quel est le plus long mur du monde ?',
    answers: {
      'Mur de Berlin': false,
      'Grande Muraille de Chine': true,
      'Mur d’Hadrien': false,
    },
    correctAnswer: 'Grande Muraille de Chine',
  ),
  QuestionModel(
    question: 'Quelle mer borde la côte sud de la France ?',
    answers: {
      'Mer du Nord': false,
      'Mer Méditerranée': true,
      'Mer Noire': false,
    },
    correctAnswer: 'Mer Méditerranée',
  ),
  QuestionModel(
    question: 'Combien y a-t-il de jours dans une année bissextile ?',
    answers: {
      '365': false,
      '366': true,
      '364': false,
    },
    correctAnswer: '366',
  ),
  QuestionModel(
    question: 'Quel est le métal le plus léger ?',
    answers: {
      'Aluminium': false,
      'Lithium': true,
      'Fer': false,
    },
    correctAnswer: 'Lithium',
  ),
  QuestionModel(
    question: 'Dans quel pays se trouve la tour de Pise ?',
    answers: {
      'Espagne': false,
      'Italie': true,
      'Grèce': false,
    },
    correctAnswer: 'Italie',
  ),
  QuestionModel(
    question: 'Quel est le pays le plus peuplé du monde ?',
    answers: {
      'Inde': true,
      'Chine': false,
      'États-Unis': false,
    },
    correctAnswer: 'Inde',
  ),
  QuestionModel(
    question: 'Quel peintre est célèbre pour avoir coupé une partie de son oreille ?',
    answers: {
      'Claude Monet': false,
      'Vincent van Gogh': true,
      'Pablo Picasso': false,
    },
    correctAnswer: 'Vincent van Gogh',
  ),
  QuestionModel(
    question: 'Quelle invention a révolutionné la diffusion des connaissances au XVe siècle ?',
    answers: {
      'Le téléphone': false,
      'L’imprimerie': true,
      'La radio': false,
    },
    correctAnswer: 'L’imprimerie',
  ),
  QuestionModel(
    question: 'Quel est l’organe principal de la photosynthèse chez les plantes ?',
    answers: {
      'Les racines': false,
      'Les feuilles': true,
      'La tige': false,
    },
    correctAnswer: 'Les feuilles',
  ),
  QuestionModel(
    question: 'Qui est l’auteur de "Roméo et Juliette" ?',
    answers: {
      'Victor Hugo': false,
      'William Shakespeare': true,
      'Molière': false,
    },
    correctAnswer: 'William Shakespeare',
  ),
  QuestionModel(
    question: 'Quelle est la capitale de l’Australie ?',
    answers: {
      'Sydney': false,
      'Melbourne': false,
      'Canberra': true,
    },
    correctAnswer: 'Canberra',
  ),
  QuestionModel(
    question: 'Que mesure l’échelle de Richter ?',
    answers: {
      'La température': false,
      'La magnitude des séismes': true,
      'La pression atmosphérique': false,
    },
    correctAnswer: 'La magnitude des séismes',
  ),
  QuestionModel(
    question: 'Quel est le métal précieux de symbole chimique "Au" ?',
    answers: {
      'Argent': false,
      'Or': true,
      'Cuivre': false,
    },
    correctAnswer: 'Or',
  ),
  QuestionModel(
    question: 'Quelle civilisation a construit les temples de Machu Picchu ?',
    answers: {
      'Les Aztèques': false,
      'Les Mayas': false,
      'Les Incas': true,
    },
    correctAnswer: 'Les Incas',
  ),
  QuestionModel(
    question: 'Quelle est la monnaie utilisée au Japon ?',
    answers: {
      'Yuan': false,
      'Yen': true,
      'Won': false,
    },
    correctAnswer: 'Yen',
  ),
  QuestionModel(
    question: 'Quel est le plus haut sommet du monde ?',
    answers: {
      'Mont Kilimandjaro': false,
      'Mont Everest': true,
      'Mont Elbrouz': false,
    },
    correctAnswer: 'Mont Everest',
  ),
  QuestionModel(
    question: 'Quel scientifique est célèbre pour sa théorie de la relativité ?',
    answers: {
      'Isaac Newton': false,
      'Albert Einstein': true,
      'Galilée': false,
    },
    correctAnswer: 'Albert Einstein',
  ),
  QuestionModel(
    question: 'Quelle est la capitale de l’Argentine ?',
    answers: {
      'Rio de Janeiro': false,
      'Buenos Aires': true,
      'Lima': false,
    },
    correctAnswer: 'Buenos Aires',
  ),
  QuestionModel(
    question: 'Qui a découvert l’Amérique en 1492 ?',
    answers: {
      'Marco Polo': false,
      'Christophe Colomb': true,
      'Vasco de Gama': false,
    },
    correctAnswer: 'Christophe Colomb',
  ),
  QuestionModel(
    question: 'Quel est le gaz le plus abondant dans l’atmosphère terrestre ?',
    answers: {
      'Oxygène': false,
      'Azote': true,
      'Dioxyde de carbone': false,
    },
    correctAnswer: 'Azote',
  ),
  QuestionModel(
    question: 'Quel pays a inventé les Jeux Olympiques ?',
    answers: {
      'Italie': false,
      'Grèce': true,
      'France': false,
    },
    correctAnswer: 'Grèce',
  ),
  QuestionModel(
    question: 'Quelle est la langue officielle du Brésil ?',
    answers: {
      'Espagnol': false,
      'Portugais': true,
      'Français': false,
    },
    correctAnswer: 'Portugais',
  ),
  QuestionModel(
    question: 'Quel est le tableau le plus célèbre de Léonard de Vinci ?',
    answers: {
      'La Cène': false,
      'La Joconde': true,
      'La Naissance de Vénus': false,
    },
    correctAnswer: 'La Joconde',
  ),
  QuestionModel(
    question: 'Quel est le continent le moins peuplé ?',
    answers: {
      'Océanie': false,
      'Antarctique': true,
      'Europe': false,
    },
    correctAnswer: 'Antarctique',
  ),
  QuestionModel(
    question: 'Quelle est la principale source d’énergie utilisée par les plantes ?',
    answers: {
      'L’eau': false,
      'La lumière du soleil': true,
      'Le vent': false,
    },
    correctAnswer: 'La lumière du soleil',
  ),

];



// Liste de questions de mathématiques


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
    QuestionModel(
    question: 'Quel est le triple de 4 ?',
    answers: {'8': false, '12': true, '16': false},
    correctAnswer: '12',
  ),
  QuestionModel(
    question: 'Quel est le nombre manquant ? 5, 10, __, 20',
    answers: {'15': true, '12': false, '18': false},
    correctAnswer: '15',
  ),
  QuestionModel(
    question: 'Quelle est la moitié de 50 ?',
    answers: {'25': true, '30': false, '20': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Combien d’angles droits a un rectangle ?',
    answers: {'4': true, '2': false, '3': false},
    correctAnswer: '4',
  ),
  QuestionModel(
    question: 'Quel est le successeur de 49 ?',
    answers: {'50': true, '48': false, '51': false},
    correctAnswer: '50',
  ),
  QuestionModel(
    question: 'Quel est le plus petit nombre premier ?',
    answers: {'1': false, '2': true, '3': false},
    correctAnswer: '2',
  ),
  QuestionModel(
    question: 'Combien font 6 x 6 ?',
    answers: {'36': true, '30': false, '42': false},
    correctAnswer: '36',
  ),
  QuestionModel(
    question: 'Quel est le quart de 100 ?',
    answers: {'25': true, '20': false, '50': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Quelle est la somme de 13 et 17 ?',
    answers: {'30': true, '29': false, '31': false},
    correctAnswer: '30',
  ),
  QuestionModel(
    question: 'Quel est le produit de 5 et 3 ?',
    answers: {'15': true, '8': false, '18': false},
    correctAnswer: '15',
  ),
  QuestionModel(
    question: 'Combien de pattes ont 3 araignées ?',
    answers: {'24': true, '18': false, '16': false},
    correctAnswer: '24',
  ),
  QuestionModel(
    question: 'Combien de jours dans une semaine ?',
    answers: {'7': true, '6': false, '8': false},
    correctAnswer: '7',
  ),
  QuestionModel(
    question: 'Quel est le dixième de 1000 ?',
    answers: {'100': true, '10': false, '200': false},
    correctAnswer: '100',
  ),
  QuestionModel(
    question: 'Quelle figure a tous ses côtés égaux ?',
    answers: {'Carré': true, 'Rectangle': false, 'Triangle': false},
    correctAnswer: 'Carré',
  ),
  QuestionModel(
    question: 'Quel est le double de 7 ?',
    answers: {'14': true, '12': false, '16': false},
    correctAnswer: '14',
  ),
  QuestionModel(
    question: 'Combien de chiffres dans le nombre 345 ?',
    answers: {'3': true, '2': false, '4': false},
    correctAnswer: '3',
  ),
  QuestionModel(
    question: 'Quel est le plus grand ? 48, 84, 18',
    answers: {'84': true, '48': false, '18': false},
    correctAnswer: '84',
  ),
  QuestionModel(
    question: 'Combien de côtés a un hexagone ?',
    answers: {'6': true, '5': false, '7': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Quel est le quart de 40 ?',
    answers: {'10': true, '20': false, '15': false},
    correctAnswer: '10',
  ),
  QuestionModel(
    question: 'Combien font 11 + 9 ?',
    answers: {'20': true, '21': false, '19': false},
    correctAnswer: '20',
  ),
    QuestionModel(
    question: 'Quel est le résultat de 18 ÷ 3 ?',
    answers: {'6': true, '9': false, '3': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Quelle est la somme de 22 et 11 ?',
    answers: {'33': true, '32': false, '34': false},
    correctAnswer: '33',
  ),
  QuestionModel(
    question: 'Combien de zéros dans un million ?',
    answers: {'6': true, '5': false, '7': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Quel est le carré de 9 ?',
    answers: {'81': true, '72': false, '99': false},
    correctAnswer: '81',
  ),
  QuestionModel(
    question: 'Combien font 14 – 9 ?',
    answers: {'5': true, '6': false, '4': false},
    correctAnswer: '5',
  ),
  QuestionModel(
    question: 'Quelle est la moitié de 36 ?',
    answers: {'18': true, '16': false, '20': false},
    correctAnswer: '18',
  ),
  QuestionModel(
    question: 'Quel nombre complète la suite ? 2, 4, 6, __',
    answers: {'8': true, '10': false, '7': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Combien d’heures dans une journée ?',
    answers: {'24': true, '12': false, '48': false},
    correctAnswer: '24',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 5² ?',
    answers: {'25': true, '10': false, '15': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Quel est le triple de 3 ?',
    answers: {'9': true, '6': false, '12': false},
    correctAnswer: '9',
  ),
  QuestionModel(
    question: 'Quelle est la différence entre 100 et 65 ?',
    answers: {'35': true, '45': false, '25': false},
    correctAnswer: '35',
  ),
  QuestionModel(
    question: 'Combien de côtés a un octogone ?',
    answers: {'8': true, '6': false, '7': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Combien font 3 x 3 x 3 ?',
    answers: {'27': true, '9': false, '18': false},
    correctAnswer: '27',
  ),
  QuestionModel(
    question: 'Combien font 45 + 55 ?',
    answers: {'100': true, '95': false, '105': false},
    correctAnswer: '100',
  ),
  QuestionModel(
    question: 'Quelle est la moitié de 80 ?',
    answers: {'40': true, '30': false, '20': false},
    correctAnswer: '40',
  ),
  QuestionModel(
    question: 'Combien de pattes ont deux chiens ?',
    answers: {'8': true, '6': false, '10': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Combien d’arêtes a un cube ?',
    answers: {'12': true, '6': false, '8': false},
    correctAnswer: '12',
  ),
  QuestionModel(
    question: 'Quel est le produit de 12 x 2 ?',
    answers: {'24': true, '22': false, '26': false},
    correctAnswer: '24',
  ),
  QuestionModel(
    question: 'Combien de doigts a un humain en tout ?',
    answers: {'10': true, '8': false, '12': false},
    correctAnswer: '10',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 50 ÷ 5 ?',
    answers: {'10': true, '5': false, '15': false},
    correctAnswer: '10',
  ),
    QuestionModel(
    question: 'Combien font 30 + 45 ?',
    answers: {'75': true, '70': false, '65': false},
    correctAnswer: '75',
  ),
  QuestionModel(
    question: 'Quel est le tiers de 60 ?',
    answers: {'20': true, '15': false, '30': false},
    correctAnswer: '20',
  ),
  QuestionModel(
    question: 'Combien de côtés a un carré ?',
    answers: {'4': true, '3': false, '5': false},
    correctAnswer: '4',
  ),
  QuestionModel(
    question: 'Combien font 11 x 11 ?',
    answers: {'121': true, '111': false, '101': false},
    correctAnswer: '121',
  ),
  QuestionModel(
    question: 'Combien de mois ont 31 jours ?',
    answers: {'7': true, '6': false, '8': false},
    correctAnswer: '7',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 90 – 45 ?',
    answers: {'45': true, '55': false, '40': false},
    correctAnswer: '45',
  ),
  QuestionModel(
    question: 'Combien de roues sur trois bicyclettes ?',
    answers: {'6': true, '4': false, '8': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Combien de dizaines dans 100 ?',
    answers: {'10': true, '20': false, '5': false},
    correctAnswer: '10',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 6² ?',
    answers: {'36': true, '12': false, '30': false},
    correctAnswer: '36',
  ),
  QuestionModel(
    question: 'Quel nombre est le plus petit ?',
    answers: {'1': true, '5': false, '10': false},
    correctAnswer: '1',
  ),
  QuestionModel(
    question: 'Quel est le nombre opposé de 7 ?',
    answers: {'-7': true, '7': false, '0': false},
    correctAnswer: '-7',
  ),
  QuestionModel(
    question: 'Combien de côtés a un hexagone ?',
    answers: {'6': true, '5': false, '7': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Combien de secondes dans une minute ?',
    answers: {'60': true, '100': false, '30': false},
    correctAnswer: '60',
  ),
  QuestionModel(
    question: 'Quel est le plus grand nombre impair < 20 ?',
    answers: {'19': true, '17': false, '18': false},
    correctAnswer: '19',
  ),
  QuestionModel(
    question: 'Combien font 2 + 3 + 4 ?',
    answers: {'9': true, '10': false, '8': false},
    correctAnswer: '9',
  ),
  QuestionModel(
    question: 'Quelle figure a trois côtés ?',
    answers: {'Triangle': true, 'Carré': false, 'Cercle': false},
    correctAnswer: 'Triangle',
  ),
  QuestionModel(
    question: 'Quel est le quart de 100 ?',
    answers: {'25': true, '20': false, '30': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Combien de mètres font 2 kilomètres ?',
    answers: {'2000': true, '1000': false, '1500': false},
    correctAnswer: '2000',
  ),
  QuestionModel(
    question: 'Combien de jours dans une semaine ?',
    answers: {'7': true, '5': false, '10': false},
    correctAnswer: '7',
  ),
  QuestionModel(
    question: 'Quel est le double de 15 ?',
    answers: {'30': true, '25': false, '20': false},
    correctAnswer: '30',
  ),

    QuestionModel(
    question: 'Combien de millimètres dans un centimètre ?',
    answers: {'10': true, '100': false, '1000': false},
    correctAnswer: '10',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 5 x 5 ?',
    answers: {'25': true, '20': false, '30': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Combien de zéros dans un million ?',
    answers: {'6': true, '5': false, '7': false},
    correctAnswer: '6',
  ),
  QuestionModel(
    question: 'Quel est le triple de 4 ?',
    answers: {'12': true, '8': false, '10': false},
    correctAnswer: '12',
  ),
  QuestionModel(
    question: 'Combien de pattes ont 3 chiens ?',
    answers: {'12': true, '8': false, '10': false},
    correctAnswer: '12',
  ),
  QuestionModel(
    question: 'Combien font 100 – 75 ?',
    answers: {'25': true, '20': false, '15': false},
    correctAnswer: '25',
  ),
  QuestionModel(
    question: 'Quel est le plus grand nombre ?',
    answers: {'999': true, '99': false, '9': false},
    correctAnswer: '999',
  ),
  QuestionModel(
    question: 'Combien de dizaines dans 70 ?',
    answers: {'7': true, '10': false, '5': false},
    correctAnswer: '7',
  ),
  QuestionModel(
    question: 'Combien de côtés a un rectangle ?',
    answers: {'4': true, '3': false, '5': false},
    correctAnswer: '4',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 2 x 0 ?',
    answers: {'0': true, '2': false, '1': false},
    correctAnswer: '0',
  ),
  QuestionModel(
    question: 'Combien d’heures dans une journée ?',
    answers: {'24': true, '12': false, '48': false},
    correctAnswer: '24',
  ),
  QuestionModel(
    question: 'Quel est le carré de 9 ?',
    answers: {'81': true, '72': false, '90': false},
    correctAnswer: '81',
  ),
  QuestionModel(
    question: 'Quel est le successeur de 49 ?',
    answers: {'50': true, '48': false, '51': false},
    correctAnswer: '50',
  ),
  QuestionModel(
    question: 'Quel est le plus petit nombre impair ?',
    answers: {'1': true, '3': false, '2': false},
    correctAnswer: '1',
  ),
  QuestionModel(
    question: 'Combien de doigts a une main ?',
    answers: {'5': true, '10': false, '4': false},
    correctAnswer: '5',
  ),
  QuestionModel(
    question: 'Quel est le quart de 80 ?',
    answers: {'20': true, '25': false, '30': false},
    correctAnswer: '20',
  ),
  QuestionModel(
    question: 'Combien font 6 + 7 ?',
    answers: {'13': true, '14': false, '12': false},
    correctAnswer: '13',
  ),
  QuestionModel(
    question: 'Combien de côtés a un octogone ?',
    answers: {'8': true, '6': false, '7': false},
    correctAnswer: '8',
  ),
  QuestionModel(
    question: 'Combien font 9 x 3 ?',
    answers: {'27': true, '21': false, '30': false},
    correctAnswer: '27',
  ),
  QuestionModel(
    question: 'Quel est le résultat de 50 ÷ 5 ?',
    answers: {'10': true, '5': false, '15': false},
    correctAnswer: '10',
  ),
];
