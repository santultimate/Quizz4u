import 'dart:io';
import 'dart:convert';

/// Script de génération automatique de questions pour les catégories sous-représentées
/// Usage: dart run scripts/generate_missing_questions.dart

void main() async {
  print('🚀 Générateur de Questions - Enrichissement des Catégories');
  print('=' * 60);

  // Générer les questions manquantes
  await generateTechnologyQuestions();
  await generateEnvironmentQuestions();
  await generateArtsQuestions();
  await generatePoliticsQuestions();
  await generateHealthQuestions();

  print('\n✅ Génération terminée !');
  print('📊 Vérifiez les nouveaux fichiers dans assets/questions/');
}

/// Génère 30 questions sur la Technologie et l'Innovation
Future<void> generateTechnologyQuestions() async {
  print('\n📱 Génération: Technologie et Innovation...');

  final questions = {
    "Technologie et Innovation": {
      "Informatique et Programmation": [
        {
          "question":
              "Quel langage de programmation est principalement utilisé pour développer des applications Android ?",
          "options": ["Java", "Python", "Ruby", "PHP"],
          "correctAnswer": "Java",
          "explanation":
              "Java est le langage principal pour le développement Android, bien que Kotlin soit de plus en plus utilisé.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Informatique et Programmation"
        },
        {
          "question": "Qui a créé le World Wide Web (WWW) ?",
          "options": [
            "Tim Berners-Lee",
            "Bill Gates",
            "Steve Jobs",
            "Larry Page"
          ],
          "correctAnswer": "Tim Berners-Lee",
          "explanation":
              "Tim Berners-Lee a inventé le World Wide Web au CERN en 1989.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Informatique et Programmation"
        },
        {
          "question":
              "Quel est le langage de programmation le plus populaire en 2025 ?",
          "options": ["Python", "JavaScript", "Java", "C++"],
          "correctAnswer": "Python",
          "explanation":
              "Python est le langage le plus populaire grâce à son utilisation en IA, data science et développement web.",
          "difficulty": "easy",
          "category": "Technologie et Innovation",
          "subcategory": "Informatique et Programmation"
        },
        {
          "question": "Qu'est-ce que HTML ?",
          "options": [
            "HyperText Markup Language",
            "High Tech Modern Language",
            "Home Tool Markup Language",
            "Hyperlinks and Text Markup Language"
          ],
          "correctAnswer": "HyperText Markup Language",
          "explanation":
              "HTML est le langage de balisage standard pour créer des pages web.",
          "difficulty": "easy",
          "category": "Technologie et Innovation",
          "subcategory": "Informatique et Programmation"
        },
        {
          "question":
              "Quel système d'exploitation mobile a été développé par Google ?",
          "options": ["Android", "iOS", "Windows Phone", "BlackBerry OS"],
          "correctAnswer": "Android",
          "explanation":
              "Android est le système d'exploitation mobile open-source développé par Google.",
          "difficulty": "easy",
          "category": "Technologie et Innovation",
          "subcategory": "Informatique et Programmation"
        }
      ],
      "Intelligence Artificielle": [
        {
          "question":
              "Quel est le nom de l'IA conversationnelle développée par OpenAI ?",
          "options": ["ChatGPT", "Bard", "Alexa", "Siri"],
          "correctAnswer": "ChatGPT",
          "explanation":
              "ChatGPT est l'assistant IA conversationnel développé par OpenAI, lancé en novembre 2022.",
          "difficulty": "easy",
          "category": "Technologie et Innovation",
          "subcategory": "Intelligence Artificielle"
        },
        {
          "question": "Qu'est-ce que le Machine Learning ?",
          "options": [
            "Apprentissage automatique des machines",
            "Réparation de machines",
            "Construction de machines",
            "Programmation de machines"
          ],
          "correctAnswer": "Apprentissage automatique des machines",
          "explanation":
              "Le Machine Learning permet aux ordinateurs d'apprendre à partir de données sans être explicitement programmés.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Intelligence Artificielle"
        },
        {
          "question":
              "Quel test mesure la capacité d'une machine à exhiber un comportement intelligent ?",
          "options": [
            "Test de Turing",
            "Test IQ",
            "Test algorithmique",
            "Test de données"
          ],
          "correctAnswer": "Test de Turing",
          "explanation":
              "Le Test de Turing, proposé par Alan Turing en 1950, évalue l'intelligence d'une machine.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Intelligence Artificielle"
        }
      ],
      "Innovations Tech Africaines": [
        {
          "question":
              "Quel pays africain a créé M-Pesa, le système de paiement mobile ?",
          "options": ["Kenya", "Nigeria", "Afrique du Sud", "Ghana"],
          "correctAnswer": "Kenya",
          "explanation":
              "M-Pesa a été lancé au Kenya en 2007 et a révolutionné les services financiers mobiles en Afrique.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Innovations Tech Africaines"
        },
        {
          "question": "Quelle ville est surnommée 'Silicon Savannah' ?",
          "options": ["Nairobi", "Lagos", "Cape Town", "Accra"],
          "correctAnswer": "Nairobi",
          "explanation":
              "Nairobi, au Kenya, est surnommée 'Silicon Savannah' en raison de son écosystème tech florissant.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Innovations Tech Africaines"
        },
        {
          "question":
              "Quel pays africain a le plus grand nombre de licornes tech (startups valorisées à +1 milliard USD) ?",
          "options": ["Nigeria", "Afrique du Sud", "Kenya", "Égypte"],
          "correctAnswer": "Nigeria",
          "explanation":
              "Le Nigeria possède plusieurs licornes tech comme Flutterwave, Interswitch, et OPay.",
          "difficulty": "hard",
          "category": "Technologie et Innovation",
          "subcategory": "Innovations Tech Africaines"
        },
        {
          "question":
              "Qu'est-ce que Zipline, l'innovation tech utilisée au Rwanda ?",
          "options": [
            "Livraison de médicaments par drones",
            "Application de transport",
            "Plateforme e-commerce",
            "Réseau social"
          ],
          "correctAnswer": "Livraison de médicaments par drones",
          "explanation":
              "Zipline utilise des drones pour livrer du sang et des médicaments dans les zones reculées du Rwanda.",
          "difficulty": "hard",
          "category": "Technologie et Innovation",
          "subcategory": "Innovations Tech Africaines"
        }
      ],
      "Cybersécurité": [
        {
          "question": "Qu'est-ce qu'un pare-feu (firewall) ?",
          "options": [
            "Un système de sécurité réseau",
            "Un anti-virus",
            "Un logiciel de sauvegarde",
            "Un système d'exploitation"
          ],
          "correctAnswer": "Un système de sécurité réseau",
          "explanation":
              "Un pare-feu protège un réseau en contrôlant le trafic entrant et sortant selon des règles de sécurité.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Cybersécurité"
        },
        {
          "question": "Qu'est-ce que le phishing ?",
          "options": [
            "Une technique d'hameçonnage pour voler des informations",
            "Un jeu vidéo",
            "Un réseau social",
            "Un type de virus informatique"
          ],
          "correctAnswer":
              "Une technique d'hameçonnage pour voler des informations",
          "explanation":
              "Le phishing est une technique frauduleuse qui vise à obtenir des informations confidentielles.",
          "difficulty": "easy",
          "category": "Technologie et Innovation",
          "subcategory": "Cybersécurité"
        }
      ],
      "Histoire de la Tech": [
        {
          "question": "En quelle année a été fondée Apple ?",
          "options": ["1976", "1980", "1984", "1990"],
          "correctAnswer": "1976",
          "explanation":
              "Apple a été fondée le 1er avril 1976 par Steve Jobs, Steve Wozniak et Ronald Wayne.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Histoire de la Tech"
        },
        {
          "question": "Qui est considéré comme le père de l'informatique ?",
          "options": [
            "Alan Turing",
            "Bill Gates",
            "Steve Jobs",
            "Mark Zuckerberg"
          ],
          "correctAnswer": "Alan Turing",
          "explanation":
              "Alan Turing est considéré comme le père de l'informatique théorique et de l'intelligence artificielle.",
          "difficulty": "medium",
          "category": "Technologie et Innovation",
          "subcategory": "Histoire de la Tech"
        },
        {
          "question":
              "Quel fut le premier réseau social à atteindre 1 milliard d'utilisateurs ?",
          "options": ["Facebook", "Twitter", "MySpace", "LinkedIn"],
          "correctAnswer": "Facebook",
          "explanation":
              "Facebook a atteint 1 milliard d'utilisateurs actifs mensuels en octobre 2012.",
          "difficulty": "easy",
          "category": "Technologie et Innovation",
          "subcategory": "Histoire de la Tech"
        }
      ]
    }
  };

  await _saveQuestions('technology_questions_expansion.json', questions);
  print('  ✅ ${_countQuestions(questions)} questions générées');
}

/// Génère 30 questions sur l'Environnement et l'Écologie
Future<void> generateEnvironmentQuestions() async {
  print('\n🌍 Génération: Environnement et Écologie...');

  final questions = {
    "Environnement et Écologie": {
      "Changement Climatique": [
        {
          "question":
              "Quel est l'objectif principal de l'Accord de Paris (2015) ?",
          "options": [
            "Limiter le réchauffement à 1,5°C",
            "Éliminer tous les combustibles fossiles",
            "Planter 1 milliard d'arbres",
            "Interdire les plastiques"
          ],
          "correctAnswer": "Limiter le réchauffement à 1,5°C",
          "explanation":
              "L'Accord de Paris vise à maintenir l'augmentation de la température mondiale en dessous de 2°C, idéalement à 1,5°C.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Changement Climatique"
        },
        {
          "question":
              "Quel gaz à effet de serre est le plus abondant dans l'atmosphère ?",
          "options": [
            "Dioxyde de carbone (CO2)",
            "Méthane (CH4)",
            "Protoxyde d'azote (N2O)",
            "Ozone (O3)"
          ],
          "correctAnswer": "Dioxyde de carbone (CO2)",
          "explanation":
              "Le CO2 représente environ 76% des émissions de gaz à effet de serre d'origine humaine.",
          "difficulty": "easy",
          "category": "Environnement et Écologie",
          "subcategory": "Changement Climatique"
        },
        {
          "question":
              "Quelle activité humaine contribue le plus au changement climatique ?",
          "options": [
            "Combustion de combustibles fossiles",
            "Agriculture",
            "Déforestation",
            "Transport aérien"
          ],
          "correctAnswer": "Combustion de combustibles fossiles",
          "explanation":
              "La combustion de charbon, pétrole et gaz naturel est responsable de 73% des émissions mondiales de GES.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Changement Climatique"
        },
        {
          "question":
              "Quel continent est le plus affecté par la désertification ?",
          "options": ["Afrique", "Asie", "Amérique du Sud", "Australie"],
          "correctAnswer": "Afrique",
          "explanation":
              "L'Afrique est particulièrement vulnérable à la désertification, notamment dans la région du Sahel.",
          "difficulty": "easy",
          "category": "Environnement et Écologie",
          "subcategory": "Changement Climatique"
        }
      ],
      "Biodiversité Africaine": [
        {
          "question": "Quel est le plus grand parc national d'Afrique ?",
          "options": [
            "Parc National de Namib-Naukluft (Namibie)",
            "Parc Kruger (Afrique du Sud)",
            "Parc Serengeti (Tanzanie)",
            "Parc Etosha (Namibie)"
          ],
          "correctAnswer": "Parc National de Namib-Naukluft (Namibie)",
          "explanation":
              "Le Parc de Namib-Naukluft couvre 49 768 km², ce qui en fait le plus grand parc d'Afrique.",
          "difficulty": "hard",
          "category": "Environnement et Écologie",
          "subcategory": "Biodiversité Africaine"
        },
        {
          "question": "Combien d'espèces d'éléphants existe-t-il en Afrique ?",
          "options": ["2", "1", "3", "4"],
          "correctAnswer": "2",
          "explanation":
              "Il existe deux espèces d'éléphants africains : l'éléphant de savane et l'éléphant de forêt.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Biodiversité Africaine"
        },
        {
          "question":
              "Quel animal africain peut vivre plus longtemps sans eau ?",
          "options": ["La girafe", "Le chameau", "L'oryx", "Le dromadaire"],
          "correctAnswer": "L'oryx",
          "explanation":
              "L'oryx peut survivre plusieurs mois sans boire, en tirant l'eau de sa nourriture.",
          "difficulty": "hard",
          "category": "Environnement et Écologie",
          "subcategory": "Biodiversité Africaine"
        },
        {
          "question": "Quel est l'oiseau national du Kenya ?",
          "options": [
            "Le coq de roche",
            "L'aigle martial",
            "Le calao terrestre",
            "Le flamant rose"
          ],
          "correctAnswer": "Le coq de roche",
          "explanation":
              "Le coq de roche (lilac-breasted roller) est l'oiseau national du Kenya, connu pour ses couleurs vives.",
          "difficulty": "hard",
          "category": "Environnement et Écologie",
          "subcategory": "Biodiversité Africaine"
        }
      ],
      "Énergies Renouvelables": [
        {
          "question": "Quel pays africain produit le plus d'énergie solaire ?",
          "options": ["Maroc", "Afrique du Sud", "Égypte", "Algérie"],
          "correctAnswer": "Maroc",
          "explanation":
              "Le Maroc abrite le complexe solaire de Noor Ouarzazate, l'une des plus grandes centrales solaires au monde.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Énergies Renouvelables"
        },
        {
          "question": "Qu'est-ce que l'énergie géothermique ?",
          "options": [
            "Énergie provenant de la chaleur de la Terre",
            "Énergie du vent",
            "Énergie du soleil",
            "Énergie des vagues"
          ],
          "correctAnswer": "Énergie provenant de la chaleur de la Terre",
          "explanation":
              "L'énergie géothermique utilise la chaleur stockée sous la surface terrestre.",
          "difficulty": "easy",
          "category": "Environnement et Écologie",
          "subcategory": "Énergies Renouvelables"
        },
        {
          "question":
              "Quel pays africain a le plus grand potentiel hydroélectrique ?",
          "options": [
            "République Démocratique du Congo",
            "Éthiopie",
            "Égypte",
            "Nigeria"
          ],
          "correctAnswer": "République Démocratique du Congo",
          "explanation":
              "La RDC possède le plus grand potentiel hydroélectrique d'Afrique grâce au fleuve Congo.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Énergies Renouvelables"
        }
      ],
      "Pollution et Déchets": [
        {
          "question":
              "Combien de temps met un sac plastique à se décomposer dans la nature ?",
          "options": ["100-400 ans", "10-50 ans", "500-1000 ans", "1-10 ans"],
          "correctAnswer": "100-400 ans",
          "explanation":
              "Un sac plastique met entre 100 et 400 ans à se décomposer complètement dans la nature.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Pollution et Déchets"
        },
        {
          "question":
              "Quel pays africain a été le premier à interdire les sacs plastiques ?",
          "options": ["Rwanda", "Kenya", "Afrique du Sud", "Maroc"],
          "correctAnswer": "Rwanda",
          "explanation":
              "Le Rwanda a interdit les sacs plastiques en 2008, devenant un leader africain dans ce domaine.",
          "difficulty": "medium",
          "category": "Environnement et Écologie",
          "subcategory": "Pollution et Déchets"
        },
        {
          "question":
              "Qu'est-ce que le 'continent de plastique' dans l'océan Pacifique ?",
          "options": [
            "Une zone de concentration de déchets plastiques",
            "Une île artificielle",
            "Un nouveau continent découvert",
            "Une plateforme pétrolière"
          ],
          "correctAnswer": "Une zone de concentration de déchets plastiques",
          "explanation":
              "Le 'Great Pacific Garbage Patch' est une zone de plusieurs millions de km² de déchets plastiques flottants.",
          "difficulty": "easy",
          "category": "Environnement et Écologie",
          "subcategory": "Pollution et Déchets"
        }
      ]
    }
  };

  await _saveQuestions('environment_questions_expansion.json', questions);
  print('  ✅ ${_countQuestions(questions)} questions générées');
}

/// Génère 15 questions sur les Arts et la Culture
Future<void> generateArtsQuestions() async {
  print('\n🎨 Génération: Arts et Culture...');

  final questions = {
    "Arts et Culture": {
      "Littérature Africaine": [
        {
          "question":
              "Quel écrivain nigérian a remporté le Prix Nobel de Littérature en 1986 ?",
          "options": [
            "Wole Soyinka",
            "Chinua Achebe",
            "Ben Okri",
            "Chimamanda Ngozi Adichie"
          ],
          "correctAnswer": "Wole Soyinka",
          "explanation":
              "Wole Soyinka est le premier Africain à avoir reçu le Prix Nobel de Littérature.",
          "difficulty": "medium",
          "category": "Arts et Culture",
          "subcategory": "Littérature Africaine"
        },
        {
          "question": "Qui a écrit 'L'Aventure ambiguë' ?",
          "options": [
            "Cheikh Hamidou Kane",
            "Léopold Sédar Senghor",
            "Birago Diop",
            "Amadou Hampâté Bâ"
          ],
          "correctAnswer": "Cheikh Hamidou Kane",
          "explanation":
              "'L'Aventure ambiguë' (1961) est un roman de Cheikh Hamidou Kane sur l'identité africaine.",
          "difficulty": "medium",
          "category": "Arts et Culture",
          "subcategory": "Littérature Africaine"
        },
        {
          "question":
              "Quelle écrivaine malienne est connue pour 'Une si longue lettre' ?",
          "options": [
            "Mariama Bâ",
            "Aminata Sow Fall",
            "Nafissatou Diallo",
            "Ken Bugul"
          ],
          "correctAnswer": "Mariama Bâ",
          "explanation":
              "Mariama Bâ (Sénégalaise) a écrit ce roman épistolaire sur la condition féminine en Afrique.",
          "difficulty": "medium",
          "category": "Arts et Culture",
          "subcategory": "Littérature Africaine"
        }
      ],
      "Cinéma Africain": [
        {
          "question":
              "Quel est le nom du plus grand festival de cinéma africain ?",
          "options": [
            "FESPACO",
            "Festival de Cannes",
            "Festival de Carthage",
            "Festival de Durban"
          ],
          "correctAnswer": "FESPACO",
          "explanation":
              "Le FESPACO (Festival Panafricain du Cinéma de Ouagadougou) se tient tous les deux ans au Burkina Faso.",
          "difficulty": "easy",
          "category": "Arts et Culture",
          "subcategory": "Cinéma Africain"
        },
        {
          "question":
              "Quel réalisateur sénégalais est considéré comme le père du cinéma africain ?",
          "options": [
            "Ousmane Sembène",
            "Djibril Diop Mambéty",
            "Idrissa Ouedraogo",
            "Souleymane Cissé"
          ],
          "correctAnswer": "Ousmane Sembène",
          "explanation":
              "Ousmane Sembène (1923-2007) est considéré comme le père du cinéma africain.",
          "difficulty": "medium",
          "category": "Arts et Culture",
          "subcategory": "Cinéma Africain"
        }
      ],
      "Art Contemporain": [
        {
          "question":
              "Quel artiste malien est célèbre pour ses photographies ?",
          "options": [
            "Malick Sidibé",
            "Seydou Keïta",
            "Omar Victor Diop",
            "Hassan Hajjaj"
          ],
          "correctAnswer": "Malick Sidibé",
          "explanation":
              "Malick Sidibé a immortalisé la jeunesse malienne des années 60-70 à Bamako.",
          "difficulty": "medium",
          "category": "Arts et Culture",
          "subcategory": "Art Contemporain"
        }
      ]
    }
  };

  await _saveQuestions('arts_culture_questions_expansion.json', questions);
  print('  ✅ ${_countQuestions(questions)} questions générées');
}

/// Génère 15 questions sur la Politique et l'Économie
Future<void> generatePoliticsQuestions() async {
  print('\n🏛️ Génération: Politique et Économie...');

  final questions = {
    "Politique et Économie": {
      "Leaders Africains Contemporains": [
        {
          "question":
              "Qui est l'actuel Secrétaire Général des Nations Unies (depuis 2017) ?",
          "options": [
            "António Guterres",
            "Ban Ki-moon",
            "Kofi Annan",
            "Boutros Boutros-Ghali"
          ],
          "correctAnswer": "António Guterres",
          "explanation":
              "António Guterres, ancien Premier ministre portugais, est SG de l'ONU depuis 2017.",
          "difficulty": "medium",
          "category": "Politique et Économie",
          "subcategory": "Leaders Contemporains"
        },
        {
          "question": "Quel président sud-africain a mis fin à l'apartheid ?",
          "options": [
            "Nelson Mandela",
            "Frederik de Klerk",
            "Thabo Mbeki",
            "Desmond Tutu"
          ],
          "correctAnswer": "Nelson Mandela",
          "explanation":
              "Nelson Mandela est devenu le premier président noir d'Afrique du Sud en 1994, après 27 ans de prison.",
          "difficulty": "easy",
          "category": "Politique et Économie",
          "subcategory": "Leaders Africains Contemporains"
        }
      ],
      "Économie Numérique Africaine": [
        {
          "question":
              "Quelle startup nigériane est devenue une licorne en 2020 ?",
          "options": ["Flutterwave", "Jumia", "Paystack", "Andela"],
          "correctAnswer": "Flutterwave",
          "explanation":
              "Flutterwave, plateforme de paiements, a atteint une valorisation de +1 milliard USD en 2020.",
          "difficulty": "hard",
          "category": "Politique et Économie",
          "subcategory": "Économie Numérique Africaine"
        },
        {
          "question": "Quel est le plus grand marché e-commerce africain ?",
          "options": ["Jumia", "Takealot", "Konga", "Kilimall"],
          "correctAnswer": "Jumia",
          "explanation":
              "Jumia, surnommée 'l'Amazon africain', opère dans plus de 11 pays africains.",
          "difficulty": "medium",
          "category": "Politique et Économie",
          "subcategory": "Économie Numérique Africaine"
        }
      ],
      "Organisations Africaines": [
        {
          "question": "Quand a été créée l'Union Africaine (UA) ?",
          "options": ["2002", "1963", "1990", "2010"],
          "correctAnswer": "2002",
          "explanation":
              "L'UA a été créée en 2002 pour remplacer l'Organisation de l'Unité Africaine (OUA, 1963).",
          "difficulty": "medium",
          "category": "Politique et Économie",
          "subcategory": "Organisations Africaines"
        },
        {
          "question": "Où se trouve le siège de l'Union Africaine ?",
          "options": [
            "Addis-Abeba (Éthiopie)",
            "Abuja (Nigeria)",
            "Le Caire (Égypte)",
            "Nairobi (Kenya)"
          ],
          "correctAnswer": "Addis-Abeba (Éthiopie)",
          "explanation":
              "Le siège de l'UA est situé à Addis-Abeba, en Éthiopie.",
          "difficulty": "easy",
          "category": "Politique et Économie",
          "subcategory": "Organisations Africaines"
        },
        {
          "question": "Que signifie CEDEAO ?",
          "options": [
            "Communauté Économique Des États de l'Afrique de l'Ouest",
            "Centre d'Études et de Développement de l'Afrique de l'Ouest",
            "Conseil Économique de Développement Africain de l'Ouest",
            "Commission Économique pour le Développement de l'Afrique de l'Ouest"
          ],
          "correctAnswer":
              "Communauté Économique Des États de l'Afrique de l'Ouest",
          "explanation":
              "La CEDEAO (ECOWAS en anglais) regroupe 15 pays d'Afrique de l'Ouest.",
          "difficulty": "medium",
          "category": "Politique et Économie",
          "subcategory": "Organisations Africaines"
        }
      ]
    }
  };

  await _saveQuestions('politics_economy_questions_expansion.json', questions);
  print('  ✅ ${_countQuestions(questions)} questions générées');
}

/// Génère 15 questions sur la Santé et la Médecine
Future<void> generateHealthQuestions() async {
  print('\n⚕️ Génération: Santé et Médecine...');

  final questions = {
    "Santé et Médecine": {
      "Maladies Tropicales": [
        {
          "question": "Quel moustique transmet le paludisme (malaria) ?",
          "options": ["Anophèle", "Aedes", "Culex", "Tigre"],
          "correctAnswer": "Anophèle",
          "explanation":
              "Le moustique anophèle femelle transmet le parasite Plasmodium responsable du paludisme.",
          "difficulty": "medium",
          "category": "Santé et Médecine",
          "subcategory": "Maladies Tropicales"
        },
        {
          "question": "Quelle maladie est causée par le virus Ebola ?",
          "options": [
            "Fièvre hémorragique",
            "Paludisme",
            "Tuberculose",
            "Choléra"
          ],
          "correctAnswer": "Fièvre hémorragique",
          "explanation":
              "Le virus Ebola cause une fièvre hémorragique grave avec un taux de mortalité élevé.",
          "difficulty": "easy",
          "category": "Santé et Médecine",
          "subcategory": "Maladies Tropicales"
        },
        {
          "question":
              "Quel pays africain a été déclaré exempt de polio en 2020 ?",
          "options": ["Nigeria", "Kenya", "Afrique du Sud", "Égypte"],
          "correctAnswer": "Nigeria",
          "explanation":
              "Le Nigeria a été déclaré exempt de polio sauvage en août 2020, marquant une grande victoire.",
          "difficulty": "hard",
          "category": "Santé et Médecine",
          "subcategory": "Maladies Tropicales"
        }
      ],
      "Médecine Traditionnelle Africaine": [
        {
          "question":
              "Quel arbre africain est utilisé pour traiter la fièvre et les douleurs ?",
          "options": ["Quinquina", "Baobab", "Moringa", "Karité"],
          "correctAnswer": "Quinquina",
          "explanation":
              "L'écorce du quinquina contient de la quinine, utilisée contre le paludisme.",
          "difficulty": "medium",
          "category": "Santé et Médecine",
          "subcategory": "Médecine Traditionnelle Africaine"
        },
        {
          "question": "Quel fruit du baobab est riche en vitamine C ?",
          "options": ["Le pain de singe", "La datte", "La mangue", "La papaye"],
          "correctAnswer": "Le pain de singe",
          "explanation":
              "Le fruit du baobab (pain de singe) contient 6 fois plus de vitamine C qu'une orange.",
          "difficulty": "medium",
          "category": "Santé et Médecine",
          "subcategory": "Médecine Traditionnelle Africaine"
        }
      ],
      "Nutrition et Santé": [
        {
          "question":
              "Quelle céréale africaine est naturellement sans gluten ?",
          "options": ["Le fonio", "Le blé", "L'orge", "Le seigle"],
          "correctAnswer": "Le fonio",
          "explanation":
              "Le fonio est une céréale ancestrale africaine, nutritive et sans gluten.",
          "difficulty": "medium",
          "category": "Santé et Médecine",
          "subcategory": "Nutrition et Santé"
        },
        {
          "question":
              "Combien de litres d'eau doit-on boire par jour en moyenne ?",
          "options": [
            "1,5 à 2 litres",
            "3 à 4 litres",
            "0,5 à 1 litre",
            "5 litres"
          ],
          "correctAnswer": "1,5 à 2 litres",
          "explanation":
              "Il est recommandé de boire environ 1,5 à 2 litres d'eau par jour pour rester hydraté.",
          "difficulty": "easy",
          "category": "Santé et Médecine",
          "subcategory": "Nutrition et Santé"
        }
      ]
    }
  };

  await _saveQuestions('health_medicine_questions_expansion.json', questions);
  print('  ✅ ${_countQuestions(questions)} questions générées');
}

/// Sauvegarde les questions dans un fichier JSON
Future<void> _saveQuestions(
    String filename, Map<String, dynamic> questions) async {
  final file = File('assets/questions/$filename');
  final encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(questions));
}

/// Compte le nombre total de questions dans une structure
int _countQuestions(Map<String, dynamic> data) {
  int count = 0;
  for (var category in data.values) {
    if (category is Map) {
      for (var subcategory in category.values) {
        if (subcategory is List) {
          count += subcategory.length;
        }
      }
    }
  }
  return count;
}







