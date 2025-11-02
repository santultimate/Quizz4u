/// Moteur de traduction automatique pour les questions du quiz
/// Utilise des règles linguistiques et des dictionnaires pour traduire automatiquement
///
/// AVERTISSEMENT : Les traductions générées sont de qualité acceptable mais
/// devraient être révisées par des locuteurs natifs pour une qualité optimale.
class AutoTranslationEngine {
  // Dictionnaires de traduction par langue
  static final Map<String, Map<String, String>> _dictionaries = {
    'en': _englishDictionary,
    'ar': _arabicDictionary,
    'zh': _chineseDictionary,
    'hi': _hindiDictionary,
    'es': _spanishDictionary,
  };

  // Structures de questions communes
  static final Map<String, Map<String, String>> _questionPatterns = {
    'en': {
      'Quel est': 'What is',
      'Quelle est': 'What is',
      'Qui est': 'Who is',
      'Qui était': 'Who was',
      'En quelle année': 'In what year',
      'Combien': 'How many',
      'Comment': 'How',
      'Pourquoi': 'Why',
      'Où': 'Where',
      'Quand': 'When',
    },
    'ar': {
      'Quel est': 'ما هو',
      'Quelle est': 'ما هي',
      'Qui est': 'من هو',
      'Qui était': 'من كان',
      'En quelle année': 'في أي عام',
      'Combien': 'كم',
      'Comment': 'كيف',
      'Pourquoi': 'لماذا',
      'Où': 'أين',
      'Quand': 'متى',
    },
    'zh': {
      'Quel est': '什么是',
      'Quelle est': '什么是',
      'Qui est': '谁是',
      'Qui était': '谁是',
      'En quelle année': '在哪一年',
      'Combien': '多少',
      'Comment': '怎么',
      'Pourquoi': '为什么',
      'Où': '在哪里',
      'Quand': '什么时候',
    },
    'hi': {
      'Quel est': 'क्या है',
      'Quelle est': 'क्या है',
      'Qui est': 'कौन है',
      'Qui était': 'कौन था',
      'En quelle année': 'किस वर्ष में',
      'Combien': 'कितने',
      'Comment': 'कैसे',
      'Pourquoi': 'क्यों',
      'Où': 'कहाँ',
      'Quand': 'कब',
    },
    'es': {
      'Quel est': 'Cuál es',
      'Quelle est': 'Cuál es',
      'Qui est': 'Quién es',
      'Qui était': 'Quién era',
      'En quelle année': 'En qué año',
      'Combien': 'Cuántos',
      'Comment': 'Cómo',
      'Pourquoi': 'Por qué',
      'Où': 'Dónde',
      'Quand': 'Cuándo',
    },
  };

  /// Traduit une question automatiquement
  static String translateQuestion(String question, String targetLanguage) {
    if (targetLanguage == 'fr') return question;

    String translated = question;

    // 1. Traduire les patterns de questions
    final patterns = _questionPatterns[targetLanguage] ?? {};
    for (var entry in patterns.entries) {
      translated = translated.replaceFirst(entry.key, entry.value);
    }

    // 2. Traduire les mots du dictionnaire
    final dictionary = _dictionaries[targetLanguage] ?? {};
    for (var entry in dictionary.entries) {
      // Remplacer les mots entiers uniquement
      translated = translated.replaceAll(
          RegExp('\\b${RegExp.escape(entry.key)}\\b', caseSensitive: false),
          entry.value);
    }

    return translated;
  }

  /// Traduit une liste de réponses
  static List<String> translateAnswers(
      List<String> answers, String targetLanguage) {
    if (targetLanguage == 'fr') return answers;

    return answers.map((answer) {
      String translated = answer;
      final dictionary = _dictionaries[targetLanguage] ?? {};

      for (var entry in dictionary.entries) {
        translated = translated.replaceAll(
            RegExp('\\b${RegExp.escape(entry.key)}\\b', caseSensitive: false),
            entry.value);
      }

      return translated;
    }).toList();
  }

  // ==========================================
  // DICTIONNAIRES PAR LANGUE
  // ==========================================

  static final Map<String, String> _englishDictionary = {
    // Mots interrogatifs et conjonctions
    'le': 'the',
    'la': 'the',
    'les': 'the',
    'un': 'a',
    'une': 'a',
    'de': 'of',
    'du': 'of the',
    'des': 'of the',
    'et': 'and',
    'ou': 'or',
    'mais': 'but',
    'dans': 'in',
    'pour': 'for',
    'avec': 'with',
    'sans': 'without',
    'sur': 'on',
    'sous': 'under',
    'entre': 'between',

    // Verbes courants
    'est': 'is',
    'était': 'was',
    'sont': 'are',
    'étaient': 'were',
    'a': 'has',
    'ont': 'have',
    'avait': 'had',
    'fait': 'made',
    'fonde': 'founded',
    'fondé': 'founded',
    'créé': 'created',
    'obtenu': 'obtained',
    'gagné': 'won',
    'perdu': 'lost',

    // Géographie
    'pays': 'country',
    'capitale': 'capital',
    'ville': 'city',
    'région': 'region',
    'fleuve': 'river',
    'montagne': 'mountain',
    'continent': 'continent',
    'océan': 'ocean',
    'mer': 'sea',

    // Histoire
    'empire': 'empire',
    'empereur': 'emperor',
    'roi': 'king',
    'reine': 'queen',
    'président': 'president',
    'guerre': 'war',
    'bataille': 'battle',
    'victoire': 'victory',
    'défaite': 'defeat',
    'indépendance': 'independence',
    'colonie': 'colony',
    'colonial': 'colonial',
    'dynastie': 'dynasty',
    'siècle': 'century',
    'année': 'year',

    // Sciences
    'planète': 'planet',
    'étoile': 'star',
    'soleil': 'sun',
    'lune': 'moon',
    'terre': 'earth',
    'eau': 'water',
    'air': 'air',
    'feu': 'fire',
    'lumière': 'light',
    'chaleur': 'heat',
    'énergie': 'energy',
    'force': 'force',
    'vitesse': 'speed',

    // Mathématiques
    'nombre': 'number',
    'chiffre': 'digit',
    'plus': 'plus',
    'moins': 'minus',
    'fois': 'times',
    'divisé': 'divided',
    'égal': 'equal',
    'résultat': 'result',
    'somme': 'sum',
    'différence': 'difference',
    'produit': 'product',
    'quotient': 'quotient',

    // Culture
    'musique': 'music',
    'chanson': 'song',
    'instrument': 'instrument',
    'artiste': 'artist',
    'peinture': 'painting',
    'sculpture': 'sculpture',
    'livre': 'book',
    'écrivain': 'writer',
    'poète': 'poet',

    // Sports
    'football': 'football',
    'joueur': 'player',
    'équipe': 'team',
    'match': 'match',
    'coupe': 'cup',
    'champion': 'champion',
    'victoire': 'victory',
    'but': 'goal',

    // Nombres
    'premier': 'first',
    'deuxième': 'second',
    'troisième': 'third',
    'dernier': 'last',
  };

  static final Map<String, String> _arabicDictionary = {
    // Mots interrogatifs de base
    'le': 'ال',
    'la': 'ال',
    'les': 'ال',
    'de': 'من',
    'du': 'من ال',
    'et': 'و',
    'ou': 'أو',

    // Verbes courants
    'est': 'هو',
    'était': 'كان',
    'sont': 'هم',
    'a': 'لديه',
    'ont': 'لديهم',

    // Géographie
    'pays': 'بلد',
    'capitale': 'عاصمة',
    'ville': 'مدينة',
    'région': 'منطقة',
    'fleuve': 'نهر',
    'montagne': 'جبل',
    'continent': 'قارة',

    // Histoire
    'empire': 'إمبراطورية',
    'empereur': 'إمبراطور',
    'roi': 'ملك',
    'reine': 'ملكة',
    'président': 'رئيس',
    'guerre': 'حرب',
    'bataille': 'معركة',
    'indépendance': 'استقلال',
    'siècle': 'قرن',
    'année': 'عام',

    // Sciences
    'planète': 'كوكب',
    'soleil': 'شمس',
    'lune': 'قمر',
    'terre': 'أرض',
    'eau': 'ماء',
    'air': 'هواء',
    'lumière': 'ضوء',

    // Culture
    'musique': 'موسيقى',
    'instrument': 'آلة موسيقية',
    'artiste': 'فنان',
    'livre': 'كتاب',

    // Sports
    'football': 'كرة القدم',
    'joueur': 'لاعب',
    'équipe': 'فريق',
    'coupe': 'كأس',
  };

  static final Map<String, String> _chineseDictionary = {
    // Mots de base
    'le': '',
    'la': '',
    'les': '',
    'de': '的',
    'et': '和',
    'ou': '或',

    // Verbes
    'est': '是',
    'était': '是',
    'a': '有',

    // Géographie
    'pays': '国家',
    'capitale': '首都',
    'ville': '城市',
    'région': '地区',
    'fleuve': '河流',
    'montagne': '山',
    'continent': '大陆',

    // Histoire
    'empire': '帝国',
    'empereur': '皇帝',
    'roi': '国王',
    'reine': '女王',
    'président': '总统',
    'guerre': '战争',
    'bataille': '战役',
    'indépendance': '独立',
    'siècle': '世纪',
    'année': '年',

    // Sciences
    'planète': '行星',
    'soleil': '太阳',
    'lune': '月亮',
    'terre': '地球',
    'eau': '水',
    'air': '空气',
    'lumière': '光',

    // Culture
    'musique': '音乐',
    'instrument': '乐器',
    'artiste': '艺术家',
    'livre': '书',

    // Sports
    'football': '足球',
    'joueur': '球员',
    'équipe': '队',
    'coupe': '杯',
  };

  static final Map<String, String> _hindiDictionary = {
    // Mots de base
    'le': '',
    'la': '',
    'les': '',
    'de': 'का',
    'et': 'और',
    'ou': 'या',

    // Verbes
    'est': 'है',
    'était': 'था',
    'a': 'है',

    // Géographie
    'pays': 'देश',
    'capitale': 'राजधानी',
    'ville': 'शहर',
    'région': 'क्षेत्र',
    'fleuve': 'नदी',
    'montagne': 'पहाड़',
    'continent': 'महाद्वीप',

    // Histoire
    'empire': 'साम्राज्य',
    'empereur': 'सम्राट',
    'roi': 'राजा',
    'reine': 'रानी',
    'président': 'राष्ट्रपति',
    'guerre': 'युद्ध',
    'bataille': 'लड़ाई',
    'indépendance': 'स्वतंत्रता',
    'siècle': 'सदी',
    'année': 'वर्ष',

    // Sciences
    'planète': 'ग्रह',
    'soleil': 'सूर्य',
    'lune': 'चंद्रमा',
    'terre': 'पृथ्वी',
    'eau': 'पानी',
    'air': 'हवा',
    'lumière': 'प्रकाश',

    // Culture
    'musique': 'संगीत',
    'instrument': 'वाद्य यंत्र',
    'artiste': 'कलाकार',
    'livre': 'किताब',

    // Sports
    'football': 'फुटबॉल',
    'joueur': 'खिलाड़ी',
    'équipe': 'टीम',
    'coupe': 'कप',
  };

  static final Map<String, String> _spanishDictionary = {
    // Mots de base
    'le': 'el',
    'la': 'la',
    'les': 'los',
    'de': 'de',
    'du': 'del',
    'et': 'y',
    'ou': 'o',

    // Verbes
    'est': 'es',
    'était': 'era',
    'sont': 'son',
    'a': 'tiene',
    'ont': 'tienen',

    // Géographie
    'pays': 'país',
    'capitale': 'capital',
    'ville': 'ciudad',
    'région': 'región',
    'fleuve': 'río',
    'montagne': 'montaña',
    'continent': 'continente',

    // Histoire
    'empire': 'imperio',
    'empereur': 'emperador',
    'roi': 'rey',
    'reine': 'reina',
    'président': 'presidente',
    'guerre': 'guerra',
    'bataille': 'batalla',
    'indépendance': 'independencia',
    'siècle': 'siglo',
    'année': 'año',

    // Sciences
    'planète': 'planeta',
    'soleil': 'sol',
    'lune': 'luna',
    'terre': 'tierra',
    'eau': 'agua',
    'air': 'aire',
    'lumière': 'luz',

    // Culture
    'musique': 'música',
    'instrument': 'instrumento',
    'artiste': 'artista',
    'livre': 'libro',

    // Sports
    'football': 'fútbol',
    'joueur': 'jugador',
    'équipe': 'equipo',
    'coupe': 'copa',
  };
}









