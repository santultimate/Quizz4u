#!/usr/bin/env python3
"""Ajoute des questions récentes aux catégories expansion sous-représentées (cible: 25)."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "assets/questions"
TARGET = 25


def q(
    qid: str,
    question: str,
    options: list[str],
    correct: str,
    explanation: str,
    category: str,
    subcategory: str,
    difficulty: str = "medium",
) -> dict:
    return {
        "question": question,
        "options": options,
        "correctAnswer": correct,
        "explanation": explanation,
        "difficulty": difficulty,
        "category": category,
        "subcategory": subcategory,
        "id": qid,
    }


NEW_BY_FILE: dict[str, dict[str, list[dict]]] = {
    "arts_culture_questions_expansion.json": {
        "Littérature Africaine": [
            q(
                "arts_culture_0006",
                "Quelle auteure nigériane a popularisé le terme « Afro-féminisme » dans ses essais ?",
                ["Chimamanda Ngozi Adichie", "Buchi Emecheta", "Tsitsi Dangarembga", "Ngũgĩ wa Thiong'o"],
                "Chimamanda Ngozi Adichie",
                "Chimamanda Ngozi Adichie est une voix majeure de la littérature africaine contemporaine.",
                "Arts et Culture",
                "Littérature Africaine",
            ),
            q(
                "arts_culture_0007",
                "Quel roman de Chinua Achebe est considéré comme un classique de la littérature africaine ?",
                ["Le monde s'effondre", "Une si longue lettre", "Sahel", "L'Aventure ambiguë"],
                "Le monde s'effondre",
                "« Things Fall Apart » (1958) est traduit en français sous le titre « Le monde s'effondre ».",
                "Arts et Culture",
                "Littérature Africaine",
            ),
            q(
                "arts_culture_0008",
                "Quel prix littéraire international récompense chaque année un auteur de langue française ?",
                ["Prix Goncourt", "Prix Booker", "Prix Pulitzer", "Prix Nobel de la paix"],
                "Prix Goncourt",
                "Le Prix Goncourt est l'un des plus prestigieux prix littéraires francophones.",
                "Arts et Culture",
                "Littérature Africaine",
                "easy",
            ),
            q(
                "arts_culture_0009",
                "Quel poète sénégalais a cofondé le mouvement de la Négritude ?",
                ["Léopold Sédar Senghor", "David Diop", "Birago Diop", "Cheikh Hamidou Kane"],
                "Léopold Sédar Senghor",
                "Senghor, Césaire et Damas sont les figures fondatrices de la Négritude.",
                "Arts et Culture",
                "Littérature Africaine",
            ),
        ],
        "Cinéma Africain": [
            q(
                "arts_culture_0010",
                "Quel film rwandais de 2023 a été acclamé pour son portrait de la diaspora ?",
                ["Une famille", "Black Panther", "Tsotsi", "La vie est belle"],
                "Une famille",
                "Le cinéma africain contemporain explore de plus en plus les thèmes migratoires et identitaires.",
                "Arts et Culture",
                "Cinéma Africain",
                "hard",
            ),
            q(
                "arts_culture_0011",
                "Quelle industrie cinématographique africaine produit le plus de films par an ?",
                ["Nollywood (Nigeria)", "Cinéma sud-africain", "Cinéma égyptien", "Cinéma marocain"],
                "Nollywood (Nigeria)",
                "Nollywood est l'une des industries cinématographiques les plus prolifiques au monde.",
                "Arts et Culture",
                "Cinéma Africain",
            ),
            q(
                "arts_culture_0012",
                "Quel réalisateur malien a remporté le Grand Prix au Festival de Cannes en 1987 ?",
                ["Souleymane Cissé", "Ousmane Sembène", "Djibril Diop Mambéty", "Abderrahmane Sissako"],
                "Souleymane Cissé",
                "Souleymane Cissé a remporté le Grand Prix pour « Yeelen » en 1987.",
                "Arts et Culture",
                "Cinéma Africain",
                "hard",
            ),
            q(
                "arts_culture_0013",
                "Quelle plateforme de streaming a fortement développé les séries africaines depuis 2020 ?",
                ["Netflix", "MySpace", "Vimeo", "Dailymotion"],
                "Netflix",
                "Netflix a investi dans des productions originales africaines comme « Blood & Water » ou « Aníkúlápó ».",
                "Arts et Culture",
                "Cinéma Africain",
            ),
        ],
        "Art Contemporain": [
            q(
                "arts_culture_0014",
                "Quel artiste béninois a exposé au Musée du Quai Branly avec des sculptures emblématiques ?",
                ["Romuald Hazoumè", "El Anatsui", "Ibrahim El-Salahi", "William Kentridge"],
                "Romuald Hazoumè",
                "Romuald Hazoumè utilise des matériaux recyclés pour questionner la société contemporaine.",
                "Arts et Culture",
                "Art Contemporain",
            ),
            q(
                "arts_culture_0015",
                "Quelle biennale d'art africain se tient à Dakar ?",
                ["Dak'Art", "Venise", "Documenta", "Biennale de Lyon"],
                "Dak'Art",
                "Dak'Art est la Biennale de l'Art Africain Contemporain, créée en 1990.",
                "Arts et Culture",
                "Art Contemporain",
                "easy",
            ),
            q(
                "arts_culture_0016",
                "Quel photographe sénégalais est célèbre pour ses portraits en studio à Dakar ?",
                ["Omar Victor Diop", "Malick Sidibé", "Seydou Keïta", "James Barnor"],
                "Seydou Keïta",
                "Seydou Keïta est reconnu mondialement pour ses portraits en noir et blanc à Bamako et Dakar.",
                "Arts et Culture",
                "Art Contemporain",
            ),
        ],
        "Musique Africaine Moderne": [
            q(
                "arts_culture_0017",
                "Quel genre musical nigérian a connu une explosion mondiale dans les années 2020 ?",
                ["Afrobeats", "Reggae", "K-pop", "Flamenco"],
                "Afrobeats",
                "L'Afrobeats, porté par Burna Boy, Wizkid et Rema, est devenu un phénomène global.",
                "Arts et Culture",
                "Musique Africaine Moderne",
                "easy",
            ),
            q(
                "arts_culture_0018",
                "Quel artiste malien est surnommé « la Voix d'or de l'Afrique » ?",
                ["Salif Keita", "Ali Farka Touré", "Amadou & Mariam", "Oumou Sangaré"],
                "Salif Keita",
                "Salif Keita est une légende de la musique malienne et mondiale.",
                "Arts et Culture",
                "Musique Africaine Moderne",
            ),
            q(
                "arts_culture_0019",
                "Quel festival de musique se tient chaque année au Mali depuis 2005 ?",
                ["Festival sur le Niger", "Coachella", "Glastonbury", "Tomorrowland"],
                "Festival sur le Niger",
                "Le Festival sur le Niger à Ségou célèbre la culture et la musique du Mali.",
                "Arts et Culture",
                "Musique Africaine Moderne",
            ),
            q(
                "arts_culture_0020",
                "Quelle application a transformé la découverte musicale africaine en 2020-2025 ?",
                ["Spotify", "Fax", "Telex", "Minitel"],
                "Spotify",
                "Les plateformes de streaming ont amplifié la visibilité des artistes africains dans le monde.",
                "Arts et Culture",
                "Musique Africaine Moderne",
                "easy",
            ),
        ],
        "Patrimoine et UNESCO": [
            q(
                "arts_culture_0021",
                "Quelle ville malienne est classée au patrimoine mondial de l'UNESCO ?",
                ["Tombouctou", "Kayes", "Sikasso", "Mopti"],
                "Tombouctou",
                "Tombouctou, Djenné et la Boucle du Niger ont été inscrits au patrimoine UNESCO.",
                "Arts et Culture",
                "Patrimoine et UNESCO",
            ),
            q(
                "arts_culture_0022",
                "Quelle mosquée de terre du Mali est célèbre pour son architecture unique ?",
                ["Grande mosquée de Djenné", "Mosquée Al-Aqsa", "Mosquée Bleue", "Mosquée Hassan II"],
                "Grande mosquée de Djenné",
                "La mosquée de Djenné est la plus grande construction en terre crue du monde.",
                "Arts et Culture",
                "Patrimoine et UNESCO",
            ),
            q(
                "arts_culture_0023",
                "Quel musée de Dakar célèbre les civilisations noires ?",
                ["Musée des Civilisations Noires", "Musée du Louvre", "British Museum", "MoMA"],
                "Musée des Civilisations Noires",
                "Inauguré en 2018, ce musée met en valeur l'art et l'histoire des civilisations noires.",
                "Arts et Culture",
                "Patrimoine et UNESCO",
            ),
            q(
                "arts_culture_0024",
                "Quelle pratique culturelle malienne est inscrite à l'UNESCO comme patrimoine immatériel ?",
                ["Le maître du Kôrè dji wara", "Le football", "Le cinéma", "La photographie"],
                "Le maître du Kôrè dji wara",
                "De nombreuses traditions africaines sont protégées comme patrimoine immatériel de l'humanité.",
                "Arts et Culture",
                "Patrimoine et UNESCO",
                "hard",
            ),
        ],
    },
    "politics_economy_questions_expansion.json": {
        "Leaders Africains Contemporains": [
            q(
                "politics_economy_0007",
                "Quel pays africain a rejoint les BRICS en 2024 ?",
                ["Éthiopie", "Maroc", "Sénégal", "Ghana"],
                "Éthiopie",
                "L'Éthiopie, l'Égypte et d'autres pays africains ont rejoint ou été invités aux BRICS+ en 2024.",
                "Politique et Économie",
                "Leaders Africains Contemporains",
            ),
            q(
                "politics_economy_0008",
                "Qui préside l'Union africaine en 2024 ?",
                ["Mohamed Ould Ghazouani", "Cyril Ramaphosa", "Paul Kagame", "Emmanuel Macron"],
                "Mohamed Ould Ghazouani",
                "Le président mauritanien Mohamed Ould Ghazouani a présidé l'UA en 2024.",
                "Politique et Économie",
                "Leaders Africains Contemporains",
                "hard",
            ),
            q(
                "politics_economy_0009",
                "Quel dirigeant rwandais est en fonction depuis 2000 ?",
                ["Paul Kagame", "Nelson Mandela", "Uhuru Kenyatta", "Yoweri Museveni"],
                "Paul Kagame",
                "Paul Kagame dirige le Rwanda depuis 2000 et a transformé son économie.",
                "Politique et Économie",
                "Leaders Africains Contemporains",
            ),
        ],
        "Économie Numérique Africaine": [
            q(
                "politics_economy_0010",
                "Quel service de mobile money est le plus utilisé en Afrique de l'Est ?",
                ["M-Pesa", "PayPal", "Venmo", "Western Union"],
                "M-Pesa",
                "M-Pesa, lancé au Kenya, a révolutionné les paiements mobiles en Afrique.",
                "Politique et Économie",
                "Économie Numérique Africaine",
            ),
            q(
                "politics_economy_0011",
                "Quelle zone de libre-échange continentale africaine est entrée en vigueur en 2021 ?",
                ["ZLECAf (AfCFTA)", "CEDEAO", "UEMOA", "CEEAC"],
                "ZLECAf (AfCFTA)",
                "La ZLECAf vise à créer le plus grand marché unique au monde avec 1,3 milliard de personnes.",
                "Politique et Économie",
                "Économie Numérique Africaine",
            ),
            q(
                "politics_economy_0012",
                "Quel pays africain abrite le siège de la Banque africaine de développement ?",
                ["Côte d'Ivoire", "Nigeria", "Afrique du Sud", "Égypte"],
                "Côte d'Ivoire",
                "La BAD est installée à Abidjan, en Côte d'Ivoire.",
                "Politique et Économie",
                "Économie Numérique Africaine",
            ),
            q(
                "politics_economy_0013",
                "Quelle monnaie numérique de banque centrale a été testée par plusieurs pays africains ?",
                ["MNBC (monnaie numérique)", "Bitcoin uniquement", "Euro numérique", "Yen digital"],
                "MNBC (monnaie numérique)",
                "Plusieurs banques centrales africaines explorent les monnaies numériques de banque centrale.",
                "Politique et Économie",
                "Économie Numérique Africaine",
                "hard",
            ),
        ],
        "Organisations Africaines": [
            q(
                "politics_economy_0014",
                "Combien de pays composent la CEDEAO en 2025 ?",
                ["15 pays", "10 pays", "27 pays", "54 pays"],
                "15 pays",
                "La CEDEAO regroupe 15 États membres d'Afrique de l'Ouest.",
                "Politique et Économie",
                "Organisations Africaines",
            ),
            q(
                "politics_economy_0015",
                "Quelle organisation regroupe les pays de l'Afrique de l'Ouest utilisant le franc CFA ?",
                ["UEMOA", "UA", "OTAN", "ASEAN"],
                "UEMOA",
                "L'UEMOA (Union Économique et Monétaire Ouest-Africaine) comprend 8 pays.",
                "Politique et Économie",
                "Organisations Africaines",
            ),
            q(
                "politics_economy_0016",
                "L'Union africaine a été invitée en tant que membre permanent de quel groupe en 2023 ?",
                ["G20", "G7", "OTAN", "ASEAN"],
                "G20",
                "L'UA est devenue membre permanent du G20 lors du sommet de New Delhi en 2023.",
                "Politique et Économie",
                "Organisations Africaines",
            ),
        ],
        "Géopolitique Africaine 2020s": [
            q(
                "politics_economy_0017",
                "Quelle région africaine est particulièrement touchée par l'instabilité politique depuis 2020 ?",
                ["Le Sahel", "Les Caraïbes", "L'Antarctique", "L'Arctique"],
                "Le Sahel",
                "Le Sahel fait face à des défis sécuritaires et politiques majeurs depuis 2020.",
                "Politique et Économie",
                "Géopolitique Africaine 2020s",
            ),
            q(
                "politics_economy_0018",
                "Quel accord international vise à limiter le réchauffement climatique et concerne l'Afrique ?",
                ["Accord de Paris", "Traité de Versailles", "Accord de Kyoto uniquement", "Pacte de Varsovie"],
                "Accord de Paris",
                "L'Accord de Paris (2015) engage tous les pays, y compris africains, à réduire les émissions.",
                "Politique et Économie",
                "Géopolitique Africaine 2020s",
                "easy",
            ),
            q(
                "politics_economy_0019",
                "Quel objectif de l'Agenda 2063 de l'Union africaine vise l'autosuffisance alimentaire ?",
                ["Sécurité alimentaire", "Conquête spatiale", "Monnaie unique immédiate", "Suppression des frontières"],
                "Sécurité alimentaire",
                "L'Agenda 2063 fixe la vision de développement de l'Afrique à l'horizon 2063.",
                "Politique et Économie",
                "Géopolitique Africaine 2020s",
            ),
            q(
                "politics_economy_0020",
                "Quel partenariat Chine-Afrique se renforce régulièrement via un sommet triennal ?",
                ["FOCAC", "OTAN", "Mercosur", "NAFTA"],
                "FOCAC",
                "Le Forum sur la coopération sino-africaine (FOCAC) structure les relations économiques Chine-Afrique.",
                "Politique et Économie",
                "Géopolitique Africaine 2020s",
                "hard",
            ),
        ],
        "Intégration Régionale": [
            q(
                "politics_economy_0021",
                "Quel pays a quitté la CEDEAO en janvier 2024 avec le Mali et le Burkina Faso ?",
                ["Niger", "Ghana", "Sénégal", "Côte d'Ivoire"],
                "Niger",
                "Le Mali, le Burkina Faso et le Niger ont annoncé leur retrait de la CEDEAO en 2024.",
                "Politique et Économie",
                "Intégration Régionale",
            ),
            q(
                "politics_economy_0022",
                "Quelle alliance sahelienne a été formée entre le Mali, le Burkina Faso et le Niger en 2023 ?",
                ["Alliance des États du Sahel (AES)", "Union européenne", "Mercosur", "ASEAN"],
                "Alliance des États du Sahel (AES)",
                "L'AES a été créée en 2023 pour renforcer la coopération entre ces trois pays.",
                "Politique et Économie",
                "Intégration Régionale",
            ),
            q(
                "politics_economy_0023",
                "Quel organe de l'ONU siège à New York et accueille tous les États membres ?",
                ["Assemblée générale", "Conseil de sécurité uniquement", "Cour internationale de La Haye", "FMI"],
                "Assemblée générale",
                "L'Assemblée générale de l'ONU réunit les 193 États membres.",
                "Politique et Économie",
                "Intégration Régionale",
                "easy",
            ),
            q(
                "politics_economy_0024",
                "Quel indicateur mesure le développement humain d'un pays (ONU) ?",
                ["IDH (Indice de développement humain)", "PIB seul", "Taux de natalité", "Superficie du pays"],
                "IDH (Indice de développement humain)",
                "L'IDH combine espérance de vie, éducation et revenu pour mesurer le développement.",
                "Politique et Économie",
                "Intégration Régionale",
            ),
        ],
    },
    "health_medicine_questions_expansion.json": {
        "Maladies Tropicales": [
            q(
                "health_medicine_0007",
                "Quel vaccin contre le paludisme a été recommandé par l'OMS en 2021 ?",
                ["RTS,S (Mosquirix)", "BCG", "ROR", "HPV"],
                "RTS,S (Mosquirix)",
                "Le vaccin RTS,S est le premier vaccin antipaludique recommandé par l'OMS pour l'Afrique.",
                "Santé et Médecine",
                "Maladies Tropicales",
            ),
            q(
                "health_medicine_0008",
                "Quelle maladie virale a été déclarée urgence de santé publique en 2022-2023 (variole simienne) ?",
                ["Mpox (variole du singe)", "Grippe aviaire", "Rage", "Tétanos"],
                "Mpox (variole du singe)",
                "Le mpox a connu une recrudescence mondiale en 2022-2023.",
                "Santé et Médecine",
                "Maladies Tropicales",
            ),
            q(
                "health_medicine_0009",
                "Quelle organisation coordonne la réponse sanitaire mondiale ?",
                ["OMS (Organisation Mondiale de la Santé)", "OTAN", "FIFA", "UNESCO"],
                "OMS (Organisation Mondiale de la Santé)",
                "L'OMS, basée à Genève, dirige la coordination sanitaire internationale.",
                "Santé et Médecine",
                "Maladies Tropicales",
                "easy",
            ),
        ],
        "Médecine Traditionnelle Africaine": [
            q(
                "health_medicine_0010",
                "Quelle plante africaine est étudiée pour ses propriétés antipaludiques ?",
                ["Artémisia annua", "Cactus", "Bambou", "Lavande"],
                "Artémisia annua",
                "L'artémisia est utilisée dans plusieurs pays africains dans la lutte contre le paludisme.",
                "Santé et Médecine",
                "Médecine Traditionnelle Africaine",
            ),
            q(
                "health_medicine_0011",
                "Quel arbre produit le beurre de karité utilisé en cosmétique et nutrition ?",
                ["Vitellaria paradoxa (Karité)", "Baobab", "Acacia", "Eucalyptus"],
                "Vitellaria paradoxa (Karité)",
                "Le karité est un produit majeur d'exportation d'Afrique de l'Ouest.",
                "Santé et Médecine",
                "Médecine Traditionnelle Africaine",
            ),
            q(
                "health_medicine_0012",
                "Quelle plante est surnommée « arbre miracle » pour sa haute valeur nutritionnelle ?",
                ["Moringa oleifera", "Cactus", "Bambou", "Lierre"],
                "Moringa oleifera",
                "Le moringa est riche en vitamines, minéraux et protéines.",
                "Santé et Médecine",
                "Médecine Traditionnelle Africaine",
                "easy",
            ),
        ],
        "Nutrition et Santé": [
            q(
                "health_medicine_0013",
                "Quelle carence alimentaire est la plus répandue chez les enfants africains ?",
                ["Carence en fer (anémie)", "Excès de vitamine C", "Excès de protéines", "Carence en sel"],
                "Carence en fer (anémie)",
                "L'anémie par carence en fer touche des millions d'enfants en Afrique.",
                "Santé et Médecine",
                "Nutrition et Santé",
            ),
            q(
                "health_medicine_0014",
                "Combien de portions de fruits et légumes l'OMS recommande-t-elle par jour ?",
                ["Au moins 5 portions", "1 portion", "10 portions", "Aucune"],
                "Au moins 5 portions",
                "L'OMS recommande au moins 400 g de fruits et légumes par jour.",
                "Santé et Médecine",
                "Nutrition et Santé",
                "easy",
            ),
            q(
                "health_medicine_0015",
                "Quel nutriment est essentiel pour la santé osseuse et provient du soleil ?",
                ["Vitamine D", "Vitamine C", "Fer", "Iode"],
                "Vitamine D",
                "La vitamine D est synthétisée par la peau sous l'action du soleil.",
                "Santé et Médecine",
                "Nutrition et Santé",
            ),
        ],
        "Santé Publique Moderne": [
            q(
                "health_medicine_0016",
                "Quelle campagne mondiale a distribué des vaccins COVID-19 aux pays en développement ?",
                ["COVAX", "NATO", "UNESCO", "FIFA"],
                "COVAX",
                "COVAX a visé un accès équitable aux vaccins COVID-19 pour tous les pays.",
                "Santé et Médecine",
                "Santé Publique Moderne",
            ),
            q(
                "health_medicine_0017",
                "Quel bureau régional de l'OMS couvre l'Afrique ?",
                ["Brazzaville (Congo)", "Paris", "New York", "Tokyo"],
                "Brazzaville (Congo)",
                "Le bureau régional de l'OMS pour l'Afrique est à Brazzaville.",
                "Santé et Médecine",
                "Santé Publique Moderne",
            ),
            q(
                "health_medicine_0018",
                "Quelle pratique simple réduit de 50% le risque de transmission de maladies infectieuses ?",
                ["Se laver les mains", "Porter des chaussures", "Boire du café", "Regarder la télévision"],
                "Se laver les mains",
                "Le lavage des mains à l'eau et au savon est l'une des mesures préventives les plus efficaces.",
                "Santé et Médecine",
                "Santé Publique Moderne",
                "easy",
            ),
            q(
                "health_medicine_0019",
                "Quel problème mondial rend les antibiotiques moins efficaces ?",
                ["Résistance aux antibiotiques", "Excès de vitamines", "Manque de sel", "Trop de sommeil"],
                "Résistance aux antibiotiques",
                "La résistance aux antimicrobiens est une urgence sanitaire mondiale selon l'OMS.",
                "Santé et Médecine",
                "Santé Publique Moderne",
            ),
            q(
                "health_medicine_0020",
                "Quelle technologie permet des consultations médicales à distance ?",
                ["Télémédecine", "Télépathie", "Hologrammes uniquement", "Fax médical"],
                "Télémédecine",
                "La télémédecine s'est développée rapidement en Afrique depuis 2020.",
                "Santé et Médecine",
                "Santé Publique Moderne",
            ),
        ],
        "Prévention et Bien-être": [
            q(
                "health_medicine_0021",
                "Combien d'heures de sommeil l'OMS recommande-t-elle aux adultes par nuit ?",
                ["7 à 9 heures", "3 à 4 heures", "12 heures", "5 heures maximum"],
                "7 à 9 heures",
                "Un sommeil suffisant est essentiel pour la santé physique et mentale.",
                "Santé et Médecine",
                "Prévention et Bien-être",
                "easy",
            ),
            q(
                "health_medicine_0022",
                "Quelle activité physique l'OMS recommande-t-elle par semaine aux adultes ?",
                ["150 minutes d'activité modérée", "10 minutes", "500 minutes intenses", "Aucune"],
                "150 minutes d'activité modérée",
                "150 minutes d'activité modérée par semaine réduisent les risques de maladies chroniques.",
                "Santé et Médecine",
                "Prévention et Bien-être",
            ),
            q(
                "health_medicine_0023",
                "Quel organe filtre le sang et produit l'urine ?",
                ["Les reins", "Le foie", "La rate", "L'estomac"],
                "Les reins",
                "Les reins filtrent les déchets du sang et régulent l'équilibre hydrique.",
                "Santé et Médecine",
                "Prévention et Bien-être",
                "easy",
            ),
            q(
                "health_medicine_0024",
                "Quelle maladie chronique est liée à un taux de sucre élevé dans le sang ?",
                ["Diabète", "Migraine", "Rhume", "Allergie saisonnière"],
                "Diabète",
                "Le diabète touche de plus en plus de personnes en Afrique urbaine.",
                "Santé et Médecine",
                "Prévention et Bien-être",
            ),
        ],
    },
    "environment_questions_expansion.json": {
        "Changement Climatique": [
            q(
                "environment_0014",
                "Où s'est tenu la COP28 sur le climat en 2023 ?",
                ["Dubaï (Émirats arabes unis)", "Paris", "Bamako", "New York"],
                "Dubaï (Émirats arabes unis)",
                "La COP28 s'est tenue à Dubaï et a abordé la transition énergétique.",
                "Environnement et Écologie",
                "Changement Climatique",
            ),
            q(
                "environment_0015",
                "Quelle année a été la plus chaude jamais enregistrée selon les données récentes ?",
                ["2024", "1900", "1950", "1800"],
                "2024",
                "2024 a battu des records de température mondiale selon l'OMM et le Copernicus.",
                "Environnement et Écologie",
                "Changement Climatique",
            ),
            q(
                "environment_0016",
                "Quel phénomène extrême est amplifié par le réchauffement climatique en Afrique ?",
                ["Sécheresses et inondations", "Neige permanente au Sahel", "Glaciers tropicaux", "Jours polaires"],
                "Sécheresses et inondations",
                "L'Afrique sub-Saharienne est très vulnérable aux événements climatiques extrêmes.",
                "Environnement et Écologie",
                "Changement Climatique",
            ),
        ],
        "Biodiversité Africaine": [
            q(
                "environment_0017",
                "Quel grand mammifère africain est menacé par le braconnage ?",
                ["L'éléphant d'Afrique", "Le chat domestique", "Le lapin", "Le pigeon"],
                "L'éléphant d'Afrique",
                "Les éléphants d'Afrique sont menacés par le braconnage pour l'ivoire.",
                "Environnement et Écologie",
                "Biodiversité Africaine",
                "easy",
            ),
            q(
                "environment_0018",
                "Quelle forêt tropicale africaine est la deuxième plus grande au monde ?",
                ["Forêt du bassin du Congo", "Forêt amazonienne", "Forêt boréale", "Forêt scandinave"],
                "Forêt du bassin du Congo",
                "La forêt du Congo couvre six pays et abrite une biodiversité exceptionnelle.",
                "Environnement et Écologie",
                "Biodiversité Africaine",
            ),
            q(
                "environment_0019",
                "Quel animal est surnommé « roi de la savane » ?",
                ["Le lion", "Le zèbre", "L'antilope", "Le flamant rose"],
                "Le lion",
                "Le lion est un symbole de la faune africaine et un prédateur apex.",
                "Environnement et Écologie",
                "Biodiversité Africaine",
                "easy",
            ),
        ],
        "Énergies Vertes": [
            q(
                "environment_0020",
                "Quel pays africain possède la plus grande centrale solaire thermique d'Afrique (Noor) ?",
                ["Maroc", "Mali", "Islande", "Japon"],
                "Maroc",
                "Le complexe solaire Noor au Maroc est l'un des plus grands d'Afrique.",
                "Environnement et Écologie",
                "Énergies Vertes",
            ),
            q(
                "environment_0021",
                "Quelle énergie renouvelable utilise la chaleur du soleil pour produire de l'électricité ?",
                ["Énergie solaire photovoltaïque", "Charbon", "Pétrole", "Gaz naturel"],
                "Énergie solaire photovoltaïque",
                "L'Afrique a un immense potentiel solaire, le plus élevé au monde.",
                "Environnement et Écologie",
                "Énergies Vertes",
                "easy",
            ),
            q(
                "environment_0022",
                "Quel projet vise à planter une ceinture verte contre la désertification au Sahel ?",
                ["Grande Muraille Verte", "Projet Amazonie", "Mur de Berlin", "Route de la soie"],
                "Grande Muraille Verte",
                "La Grande Muraille Verte vise à restaurer 100 millions d'hectares au Sahel d'ici 2030.",
                "Environnement et Écologie",
                "Énergies Vertes",
            ),
        ],
        "Pollution et Déchets": [
            q(
                "environment_0023",
                "Quel pays africain a interdit les sacs plastiques à usage unique en 2017 ?",
                ["Kenya", "France", "Brésil", "Canada"],
                "Kenya",
                "Le Kenya a été l'un des premiers pays africains à bannir les sacs plastiques.",
                "Environnement et Écologie",
                "Pollution et Déchets",
            ),
            q(
                "environment_0024",
                "Quel océan reçoit le plus de déchets plastiques via les fleuves africains et asiatiques ?",
                ["Océan Indien", "Océan Arctique", "Mer Morte", "Mer Caspienne"],
                "Océan Indien",
                "La pollution plastique marine est un défi majeur pour les côtes africaines.",
                "Environnement et Écologie",
                "Pollution et Déchets",
                "hard",
            ),
        ],
    },
    "technology_questions_expansion.json": {
        "Intelligence Artificielle": [
            q(
                "technology_0017",
                "Quelle entreprise a lancé le modèle d'IA GPT-4 en 2023 ?",
                ["OpenAI", "Apple", "Nokia", "BlackBerry"],
                "OpenAI",
                "GPT-4 est l'un des modèles de langage les plus avancés d'OpenAI.",
                "Technologie et Innovation",
                "Intelligence Artificielle",
            ),
            q(
                "technology_0018",
                "Qu'est-ce qu'un « prompt » en intelligence artificielle ?",
                ["Une instruction textuelle donnée à l'IA", "Un virus informatique", "Un câble réseau", "Un écran"],
                "Une instruction textuelle donnée à l'IA",
                "Le prompt est la requête que l'utilisateur soumet à un modèle d'IA générative.",
                "Technologie et Innovation",
                "Intelligence Artificielle",
                "easy",
            ),
            q(
                "technology_0019",
                "Quel risque l'IA générative pose-t-elle si mal utilisée ?",
                ["Désinformation et deepfakes", "Amélioration automatique du climat", "Suppression de l'électricité", "Plus de livres papier"],
                "Désinformation et deepfakes",
                "Les deepfakes et la désinformation sont des défis éthiques majeurs de l'IA.",
                "Technologie et Innovation",
                "Intelligence Artificielle",
            ),
        ],
        "Informatique et Programmation": [
            q(
                "technology_0020",
                "Quel langage est utilisé pour développer des applications Flutter comme Quizz4U ?",
                ["Dart", "COBOL", "Fortran", "Assembly"],
                "Dart",
                "Flutter, framework de Google, utilise le langage Dart pour créer des apps multiplateformes.",
                "Technologie et Innovation",
                "Informatique et Programmation",
            ),
            q(
                "technology_0021",
                "Que signifie « API » en informatique ?",
                ["Interface de Programmation d'Application", "Accélérateur de Processeur Interne", "Analyse de Protocole Internet", "Application Privée Intégrée"],
                "Interface de Programmation d'Application",
                "Une API permet à des applications de communiquer entre elles.",
                "Technologie et Innovation",
                "Informatique et Programmation",
            ),
        ],
        "Afrique Digitale": [
            q(
                "technology_0022",
                "Quel service de connexion satellite d'Elon Musk est déployé en Afrique ?",
                ["Starlink", "Netflix", "Uber", "Airbnb"],
                "Starlink",
                "Starlink vise à connecter les zones rurales africaines via satellite.",
                "Technologie et Innovation",
                "Afrique Digitale",
            ),
            q(
                "technology_0023",
                "Quelle génération de réseau mobile succède à la 4G ?",
                ["5G", "2G", "3G uniquement", "Wi-Fi uniquement"],
                "5G",
                "La 5G offre des débits plus élevés et une latence réduite pour les applications mobiles.",
                "Technologie et Innovation",
                "Afrique Digitale",
                "easy",
            ),
            q(
                "technology_0024",
                "Quelle pratique protège vos comptes en ligne en plus du mot de passe ?",
                ["Authentification à deux facteurs (2FA)", "Partager son mot de passe", "Utiliser « 123456 »", "Désactiver le verrouillage"],
                "Authentification à deux facteurs (2FA)",
                "La 2FA ajoute une couche de sécurité essentielle aux comptes numériques.",
                "Technologie et Innovation",
                "Afrique Digitale",
                "easy",
            ),
        ],
    },
}


def count_questions(data: dict) -> int:
    total = 0
    for value in data.values():
        if isinstance(value, list):
            total += len(value)
        elif isinstance(value, dict):
            for sub in value.values():
                if isinstance(sub, list):
                    total += len(sub)
    return total


def merge_questions(filename: str, additions: dict[str, list[dict]]) -> int:
    path = QUESTIONS_DIR / filename
    data = json.loads(path.read_text(encoding="utf-8"))
    category = next(iter(data))
    bucket = data[category]
    if not isinstance(bucket, dict):
        raise ValueError(f"Format inattendu pour {filename}")

    existing_ids = set()

    def collect_ids(node):
        if isinstance(node, list):
            for item in node:
                if isinstance(item, dict) and item.get("id"):
                    existing_ids.add(item["id"])
        elif isinstance(node, dict):
            for v in node.values():
                collect_ids(v)

    collect_ids(bucket)

    added = 0
    for subcategory, questions in additions.items():
        if subcategory not in bucket:
            bucket[subcategory] = []
        for question in questions:
            if question["id"] in existing_ids:
                continue
            bucket[subcategory].append(question)
            existing_ids.add(question["id"])
            added += 1

    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    final = count_questions(data)
    print(f"[ok] {filename}: +{added} questions → total {final}")
    return added


def main() -> None:
    total_added = 0
    for filename, additions in NEW_BY_FILE.items():
        total_added += merge_questions(filename, additions)
    print(f"[done] {total_added} nouvelles questions FR ajoutées")


if __name__ == "__main__":
    main()
