/// 🎓 PHASE 3: Traductions des Questions Expert et Spécialisées
///
/// Catégories:
/// - 📚 Questions Expert (5 questions)
///   • Histoire Avancée (2Q)
///   • Sciences Avancées (2Q)
///   • Mathématiques Avancées (1Q)
/// - 🔬 Questions Spécialisées (2 questions)
///   • Astronomie (1Q)
///   • Géologie (1Q)
///
/// Total: 7 questions × 6 langues = 42 traductions
///
/// Format: Traductions hardcodées professionnelles pour:
/// - 🇫🇷 Français
/// - 🇬🇧 English
/// - 🇸🇦 العربية (Arabe)
/// - 🇨🇳 中文 (Chinois)
/// - 🇮🇳 हिन्दी (Hindi)
/// - 🇪🇸 Español (Espagnol)
library;

class Phase3ExpertTranslations {
  static final Map<String, Map<String, Map<String, dynamic>>> translations = {
    // ════════════════════════════════════════════════════════════
    // 📚 QUESTIONS EXPERT - HISTOIRE AVANCÉE (2 questions)
    // ════════════════════════════════════════════════════════════

    // Q1: Bataille de Waterloo
    "En quelle année a eu lieu la bataille de Waterloo ?": {
      'en': {
        'question': "In which year did the Battle of Waterloo take place?",
        'answers': {'1814': false, '1815': true, '1816': false, '1817': false}
      },
      'ar': {
        'question': "في أي عام وقعت معركة واترلو؟",
        'answers': {'1814': false, '1815': true, '1816': false, '1817': false}
      },
      'zh': {
        'question': "滑铁卢战役发生在哪一年？",
        'answers': {'1814': false, '1815': true, '1816': false, '1817': false}
      },
      'hi': {
        'question': "वाटरलू की लड़ाई किस वर्ष हुई थी?",
        'answers': {'1814': false, '1815': true, '1816': false, '1817': false}
      },
      'es': {
        'question': "¿En qué año tuvo lugar la batalla de Waterloo?",
        'answers': {'1814': false, '1815': true, '1816': false, '1817': false}
      }
    },

    // Q2: Traité de Versailles
    "Quel traité a mis fin à la Première Guerre mondiale ?": {
      'en': {
        'question': "Which treaty ended World War I?",
        'answers': {
          'Treaty of Versailles': true,
          'Treaty of Trianon': false,
          'Treaty of Saint-Germain': false,
          'Treaty of Sèvres': false
        }
      },
      'ar': {
        'question': "ما هي المعاهدة التي أنهت الحرب العالمية الأولى؟",
        'answers': {
          'معاهدة فرساي': true,
          'معاهدة تريانون': false,
          'معاهدة سان جيرمان': false,
          'معاهدة سيفر': false
        }
      },
      'zh': {
        'question': "哪个条约结束了第一次世界大战？",
        'answers': {
          '凡尔赛条约': true,
          '特里亚农条约': false,
          '圣日耳曼条约': false,
          '色佛尔条约': false
        }
      },
      'hi': {
        'question': "किस संधि ने प्रथम विश्व युद्ध समाप्त किया?",
        'answers': {
          'वर्साय की संधि': true,
          'ट्रियानॉन की संधि': false,
          'सेंट-जर्मेन की संधि': false,
          'सेवरेस की संधि': false
        }
      },
      'es': {
        'question': "¿Qué tratado puso fin a la Primera Guerra Mundial?",
        'answers': {
          'Tratado de Versalles': true,
          'Tratado de Trianon': false,
          'Tratado de Saint-Germain': false,
          'Tratado de Sèvres': false
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🔬 QUESTIONS EXPERT - SCIENCES AVANCÉES (2 questions)
    // ════════════════════════════════════════════════════════════

    // Q3: Vitesse de la lumière
    "Quelle est la vitesse de la lumière dans le vide ?": {
      'en': {
        'question': "What is the speed of light in a vacuum?",
        'answers': {
          '299 792 458 m/s': true,
          '300 000 000 m/s': false,
          '299 792 000 m/s': false,
          '300 792 458 m/s': false
        }
      },
      'ar': {
        'question': "ما هي سرعة الضوء في الفراغ؟",
        'answers': {
          '299 792 458 م/ث': true,
          '300 000 000 م/ث': false,
          '299 792 000 م/ث': false,
          '300 792 458 م/ث': false
        }
      },
      'zh': {
        'question': "真空中的光速是多少？",
        'answers': {
          '299 792 458 米/秒': true,
          '300 000 000 米/秒': false,
          '299 792 000 米/秒': false,
          '300 792 458 米/秒': false
        }
      },
      'hi': {
        'question': "निर्वात में प्रकाश की गति क्या है?",
        'answers': {
          '299 792 458 मी/से': true,
          '300 000 000 मी/से': false,
          '299 792 000 मी/से': false,
          '300 792 458 मी/से': false
        }
      },
      'es': {
        'question': "¿Cuál es la velocidad de la luz en el vacío?",
        'answers': {
          '299 792 458 m/s': true,
          '300 000 000 m/s': false,
          '299 792 000 m/s': false,
          '300 792 458 m/s': false
        }
      }
    },

    // Q4: Nombre d'Avogadro
    "Quel est le nombre d'Avogadro ?": {
      'en': {
        'question': "What is Avogadro's number?",
        'answers': {
          '6.02 × 10²³': true,
          '6.02 × 10²²': false,
          '6.02 × 10²⁴': false,
          '6.02 × 10²¹': false
        }
      },
      'ar': {
        'question': "ما هو عدد أفوجادرو؟",
        'answers': {
          '6.02 × 10²³': true,
          '6.02 × 10²²': false,
          '6.02 × 10²⁴': false,
          '6.02 × 10²¹': false
        }
      },
      'zh': {
        'question': "阿伏伽德罗常数是多少？",
        'answers': {
          '6.02 × 10²³': true,
          '6.02 × 10²²': false,
          '6.02 × 10²⁴': false,
          '6.02 × 10²¹': false
        }
      },
      'hi': {
        'question': "एवोगाड्रो संख्या क्या है?",
        'answers': {
          '6.02 × 10²³': true,
          '6.02 × 10²²': false,
          '6.02 × 10²⁴': false,
          '6.02 × 10²¹': false
        }
      },
      'es': {
        'question': "¿Cuál es el número de Avogadro?",
        'answers': {
          '6.02 × 10²³': true,
          '6.02 × 10²²': false,
          '6.02 × 10²⁴': false,
          '6.02 × 10²¹': false
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🔢 QUESTIONS EXPERT - MATHÉMATIQUES AVANCÉES (1 question)
    // ════════════════════════════════════════════════════════════

    // Q5: Valeur de π
    "Quelle est la valeur de π (pi) ?": {
      'en': {
        'question': "What is the value of π (pi)?",
        'answers': {
          '3.14159': false,
          '3.1416': false,
          '3.14159265359': false,
          '3.141592653589793': true
        }
      },
      'ar': {
        'question': "ما هي قيمة π (باي)؟",
        'answers': {
          '3.14159': false,
          '3.1416': false,
          '3.14159265359': false,
          '3.141592653589793': true
        }
      },
      'zh': {
        'question': "π（圆周率）的值是多少？",
        'answers': {
          '3.14159': false,
          '3.1416': false,
          '3.14159265359': false,
          '3.141592653589793': true
        }
      },
      'hi': {
        'question': "π (पाई) का मान क्या है?",
        'answers': {
          '3.14159': false,
          '3.1416': false,
          '3.14159265359': false,
          '3.141592653589793': true
        }
      },
      'es': {
        'question': "¿Cuál es el valor de π (pi)?",
        'answers': {
          '3.14159': false,
          '3.1416': false,
          '3.14159265359': false,
          '3.141592653589793': true
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🌌 QUESTIONS SPÉCIALISÉES - ASTRONOMIE (1 question)
    // ════════════════════════════════════════════════════════════

    // Q6: Distance Terre-Soleil
    "Quelle est la distance entre la Terre et le Soleil ?": {
      'en': {
        'question': "What is the distance between Earth and the Sun?",
        'answers': {
          '149.6 million km': true,
          '150 million km': false,
          '148 million km': false,
          '151 million km': false
        }
      },
      'ar': {
        'question': "ما هي المسافة بين الأرض والشمس؟",
        'answers': {
          '149.6 مليون كم': true,
          '150 مليون كم': false,
          '148 مليون كم': false,
          '151 مليون كم': false
        }
      },
      'zh': {
        'question': "地球到太阳的距离是多少？",
        'answers': {
          '149.6百万公里': true,
          '150百万公里': false,
          '148百万公里': false,
          '151百万公里': false
        }
      },
      'hi': {
        'question': "पृथ्वी और सूर्य के बीच की दूरी कितनी है?",
        'answers': {
          '149.6 मिलियन किमी': true,
          '150 मिलियन किमी': false,
          '148 मिलियन किमी': false,
          '151 मिलियन किमी': false
        }
      },
      'es': {
        'question': "¿Cuál es la distancia entre la Tierra y el Sol?",
        'answers': {
          '149.6 millones de km': true,
          '150 millones de km': false,
          '148 millones de km': false,
          '151 millones de km': false
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🪨 QUESTIONS SPÉCIALISÉES - GÉOLOGIE (1 question)
    // ════════════════════════════════════════════════════════════

    // Q7: Âge de la Terre
    "Quel est l'âge estimé de la Terre ?": {
      'en': {
        'question': "What is the estimated age of the Earth?",
        'answers': {
          '4.5 billion years': true,
          '4.6 billion years': false,
          '4.4 billion years': false,
          '4.7 billion years': false
        }
      },
      'ar': {
        'question': "ما هو العمر التقديري للأرض؟",
        'answers': {
          '4.5 مليار سنة': true,
          '4.6 مليار سنة': false,
          '4.4 مليار سنة': false,
          '4.7 مليار سنة': false
        }
      },
      'zh': {
        'question': "地球的估计年龄是多少？",
        'answers': {'45亿年': true, '46亿年': false, '44亿年': false, '47亿年': false}
      },
      'hi': {
        'question': "पृथ्वी की अनुमानित आयु कितनी है?",
        'answers': {
          '4.5 बिलियन वर्ष': true,
          '4.6 बिलियन वर्ष': false,
          '4.4 बिलियन वर्ष': false,
          '4.7 बिलियन वर्ष': false
        }
      },
      'es': {
        'question': "¿Cuál es la edad estimada de la Tierra?",
        'answers': {
          '4.5 mil millones de años': true,
          '4.6 mil millones de años': false,
          '4.4 mil millones de años': false,
          '4.7 mil millones de años': false
        }
      }
    },
  };
}









