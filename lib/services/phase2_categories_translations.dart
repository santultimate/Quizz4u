/// 🎨 PHASE 2: Traductions des 5 nouvelles catégories
///
/// Catégories:
/// - 🎨 Arts et Culture (4 questions)
/// - 🌍 Politique et Économie (3 questions)
/// - 💻 Technologie et Innovation (3 questions)
/// - 🏥 Santé et Médecine (2 questions)
/// - 🌱 Environnement et Écologie (2 questions)
///
/// Total: 14 questions × 6 langues = 84 traductions
///
/// Format: Traductions hardcodées professionnelles pour:
/// - 🇫🇷 Français
/// - 🇬🇧 English
/// - 🇸🇦 العربية (Arabe)
/// - 🇨🇳 中文 (Chinois)
/// - 🇮🇳 हिन्दी (Hindi)
/// - 🇪🇸 Español (Espagnol)

class Phase2CategoriesTranslations {
  static final Map<String, Map<String, Map<String, dynamic>>> translations = {
    // ════════════════════════════════════════════════════════════
    // 🎨 ARTS ET CULTURE (4 questions)
    // ════════════════════════════════════════════════════════════

    // Q1: La Joconde
    "Quel peintre a créé 'La Joconde' ?": {
      'en': {
        'question': "Which painter created 'The Mona Lisa'?",
        'answers': {
          'Leonardo da Vinci': true,
          'Michelangelo': false,
          'Raphael': false,
          'Botticelli': false
        }
      },
      'ar': {
        'question': "من هو الرسام الذي رسم 'الموناليزا'؟",
        'answers': {
          'ليوناردو دا فينشي': true,
          'مايكل أنجلو': false,
          'رافائيل': false,
          'بوتيتشيلي': false
        }
      },
      'zh': {
        'question': "哪位画家创作了《蒙娜丽莎》？",
        'answers': {
          '列奥纳多·达·芬奇': true,
          '米开朗基罗': false,
          '拉斐尔': false,
          '波提切利': false
        }
      },
      'hi': {
        'question': "'मोना लिसा' किस चित्रकार ने बनाई?",
        'answers': {
          'लियोनार्डो दा विंची': true,
          'माइकलएंजेलो': false,
          'राफेल': false,
          'बोतीचेल्ली': false
        }
      },
      'es': {
        'question': "¿Qué pintor creó 'La Mona Lisa'?",
        'answers': {
          'Leonardo da Vinci': true,
          'Miguel Ángel': false,
          'Rafael': false,
          'Botticelli': false
        }
      }
    },

    // Q2: David sculpture
    "Quel sculpteur a créé 'David' ?": {
      'en': {
        'question': "Which sculptor created 'David'?",
        'answers': {
          'Leonardo da Vinci': false,
          'Michelangelo': true,
          'Donatello': false,
          'Bernini': false
        }
      },
      'ar': {
        'question': "من هو النحات الذي نحت تمثال 'داود'؟",
        'answers': {
          'ليوناردو دا فينشي': false,
          'مايكل أنجلو': true,
          'دوناتيلو': false,
          'بيرنيني': false
        }
      },
      'zh': {
        'question': "哪位雕塑家创作了《大卫》？",
        'answers': {
          '列奥纳多·达·芬奇': false,
          '米开朗基罗': true,
          '多纳泰罗': false,
          '贝尼尼': false
        }
      },
      'hi': {
        'question': "'डेविड' मूर्ति किस मूर्तिकार ने बनाई?",
        'answers': {
          'लियोनार्डो दा विंची': false,
          'माइकलएंजेलो': true,
          'डोनाटेलो': false,
          'बेर्निनी': false
        }
      },
      'es': {
        'question': "¿Qué escultor creó 'David'?",
        'answers': {
          'Leonardo da Vinci': false,
          'Miguel Ángel': true,
          'Donatello': false,
          'Bernini': false
        }
      }
    },

    // Q3: 9ème Symphonie
    "Quel compositeur a écrit 'La 9ème Symphonie' ?": {
      'en': {
        'question': "Which composer wrote the '9th Symphony'?",
        'answers': {
          'Mozart': false,
          'Beethoven': true,
          'Bach': false,
          'Haydn': false
        }
      },
      'ar': {
        'question': "من هو الملحن الذي كتب 'السيمفونية التاسعة'؟",
        'answers': {
          'موتسارت': false,
          'بيتهوفن': true,
          'باخ': false,
          'هايدن': false
        }
      },
      'zh': {
        'question': "哪位作曲家创作了《第九交响曲》？",
        'answers': {'莫扎特': false, '贝多芬': true, '巴赫': false, '海顿': false}
      },
      'hi': {
        'question': "'9वीं सिम्फनी' किस संगीतकार ने लिखी?",
        'answers': {
          'मोजार्ट': false,
          'बीथोवेन': true,
          'बाख': false,
          'हायडन': false
        }
      },
      'es': {
        'question': "¿Qué compositor escribió la '9ª Sinfonía'?",
        'answers': {
          'Mozart': false,
          'Beethoven': true,
          'Bach': false,
          'Haydn': false
        }
      }
    },

    // Q4: Citizen Kane
    "Quel réalisateur a dirigé 'Citizen Kane' ?": {
      'en': {
        'question': "Which director directed 'Citizen Kane'?",
        'answers': {
          'Alfred Hitchcock': false,
          'Orson Welles': true,
          'Charlie Chaplin': false,
          'John Ford': false
        }
      },
      'ar': {
        'question': "من هو المخرج الذي أخرج 'المواطن كين'؟",
        'answers': {
          'ألفريد هيتشكوك': false,
          'أورسون ويلز': true,
          'تشارلي شابلن': false,
          'جون فورد': false
        }
      },
      'zh': {
        'question': "哪位导演执导了《公民凯恩》？",
        'answers': {
          '阿尔弗雷德·希区柯克': false,
          '奥逊·威尔斯': true,
          '查理·卓别林': false,
          '约翰·福特': false
        }
      },
      'hi': {
        'question': "'सिटिज़न केन' किस निर्देशक ने बनाई?",
        'answers': {
          'अल्फ्रेड हिचकॉक': false,
          'ऑर्सन वेल्स': true,
          'चार्ली चैप्लिन': false,
          'जॉन फोर्ड': false
        }
      },
      'es': {
        'question': "¿Qué director dirigió 'Ciudadano Kane'?",
        'answers': {
          'Alfred Hitchcock': false,
          'Orson Welles': true,
          'Charlie Chaplin': false,
          'John Ford': false
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🌍 POLITIQUE ET ÉCONOMIE (3 questions)
    // ════════════════════════════════════════════════════════════

    // Q5: Plus grand PIB
    "Quel pays a le plus grand PIB au monde ?": {
      'en': {
        'question': "Which country has the largest GDP in the world?",
        'answers': {
          'United States': true,
          'China': false,
          'Japan': false,
          'Germany': false
        }
      },
      'ar': {
        'question': "ما هي الدولة التي لديها أكبر ناتج محلي إجمالي في العالم؟",
        'answers': {
          'الولايات المتحدة': true,
          'الصين': false,
          'اليابان': false,
          'ألمانيا': false
        }
      },
      'zh': {
        'question': "哪个国家的GDP最大？",
        'answers': {'美国': true, '中国': false, '日本': false, '德国': false}
      },
      'hi': {
        'question': "दुनिया में सबसे बड़ी GDP किस देश की है?",
        'answers': {
          'संयुक्त राज्य अमेरिका': true,
          'चीन': false,
          'जापान': false,
          'जर्मनी': false
        }
      },
      'es': {
        'question': "¿Qué país tiene el PIB más grande del mundo?",
        'answers': {
          'Estados Unidos': true,
          'China': false,
          'Japón': false,
          'Alemania': false
        }
      }
    },

    // Q6: Siège de l'ONU
    "Quel est le siège de l'ONU ?": {
      'en': {
        'question': "Where is the UN headquarters?",
        'answers': {
          'Paris': false,
          'New York': true,
          'Geneva': false,
          'Vienna': false
        }
      },
      'ar': {
        'question': "أين يقع مقر الأمم المتحدة؟",
        'answers': {
          'باريس': false,
          'نيويورك': true,
          'جنيف': false,
          'فيينا': false
        }
      },
      'zh': {
        'question': "联合国总部在哪里？",
        'answers': {'巴黎': false, '纽约': true, '日内瓦': false, '维也纳': false}
      },
      'hi': {
        'question': "संयुक्त राष्ट्र का मुख्यालय कहाँ है?",
        'answers': {
          'पेरिस': false,
          'न्यूयॉर्क': true,
          'जिनेवा': false,
          'वियना': false
        }
      },
      'es': {
        'question': "¿Dónde está la sede de la ONU?",
        'answers': {
          'París': false,
          'Nueva York': true,
          'Ginebra': false,
          'Viena': false
        }
      }
    },

    // Q7: Plus grand producteur de cacao
    "Quel est le plus grand producteur de cacao au monde ?": {
      'en': {
        'question': "Which is the largest cocoa producer in the world?",
        'answers': {
          'Ghana': false,
          'Côte d\'Ivoire': true,
          'Nigeria': false,
          'Cameroon': false
        }
      },
      'ar': {
        'question': "ما هو أكبر منتج للكاكاو في العالم؟",
        'answers': {
          'غانا': false,
          'ساحل العاج': true,
          'نيجيريا': false,
          'الكاميرون': false
        }
      },
      'zh': {
        'question': "世界上最大的可可生产国是哪个？",
        'answers': {'加纳': false, '科特迪瓦': true, '尼日利亚': false, '喀麦隆': false}
      },
      'hi': {
        'question': "दुनिया में सबसे बड़ा कोको उत्पादक कौन है?",
        'answers': {
          'घाना': false,
          'कोट डी आइवर': true,
          'नाइजीरिया': false,
          'कैमरून': false
        }
      },
      'es': {
        'question': "¿Cuál es el mayor productor de cacao del mundo?",
        'answers': {
          'Ghana': false,
          'Costa de Marfil': true,
          'Nigeria': false,
          'Camerún': false
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 💻 TECHNOLOGIE ET INNOVATION (3 questions)
    // ════════════════════════════════════════════════════════════

    // Q8: Langage de programmation Google
    "Quel langage de programmation a été créé par Google ?": {
      'en': {
        'question': "Which programming language was created by Google?",
        'answers': {'Python': false, 'Java': false, 'Go': true, 'C++': false}
      },
      'ar': {
        'question': "ما هي لغة البرمجة التي أنشأتها جوجل؟",
        'answers': {'بايثون': false, 'جافا': false, 'غو': true, 'سي++': false}
      },
      'zh': {
        'question': "谷歌创建了哪种编程语言？",
        'answers': {'Python': false, 'Java': false, 'Go': true, 'C++': false}
      },
      'hi': {
        'question': "Google ने कौन सी प्रोग्रामिंग भाषा बनाई?",
        'answers': {'Python': false, 'Java': false, 'Go': true, 'C++': false}
      },
      'es': {
        'question': "¿Qué lenguaje de programación fue creado por Google?",
        'answers': {'Python': false, 'Java': false, 'Go': true, 'C++': false}
      }
    },

    // Q9: Premier ordinateur Apple
    "Quel est le nom du premier ordinateur personnel d'Apple ?": {
      'en': {
        'question': "What is the name of Apple's first personal computer?",
        'answers': {
          'Macintosh': false,
          'Apple I': true,
          'Apple II': false,
          'Lisa': false
        }
      },
      'ar': {
        'question': "ما هو اسم أول كمبيوتر شخصي من أبل؟",
        'answers': {
          'ماكنتوش': false,
          'أبل 1': true,
          'أبل 2': false,
          'ليزا': false
        }
      },
      'zh': {
        'question': "苹果公司的第一台个人电脑叫什么名字？",
        'answers': {
          'Macintosh': false,
          'Apple I': true,
          'Apple II': false,
          'Lisa': false
        }
      },
      'hi': {
        'question': "Apple का पहला पर्सनल कंप्यूटर क्या था?",
        'answers': {
          'Macintosh': false,
          'Apple I': true,
          'Apple II': false,
          'Lisa': false
        }
      },
      'es': {
        'question':
            "¿Cuál es el nombre de la primera computadora personal de Apple?",
        'answers': {
          'Macintosh': false,
          'Apple I': true,
          'Apple II': false,
          'Lisa': false
        }
      }
    },

    // Q10: IA de Google
    "Quel est le nom de l'IA de Google ?": {
      'en': {
        'question': "What is the name of Google's AI?",
        'answers': {
          'Siri': false,
          'Alexa': false,
          'Bard': true,
          'Cortana': false
        }
      },
      'ar': {
        'question': "ما هو اسم الذكاء الاصطناعي من جوجل؟",
        'answers': {
          'سيري': false,
          'أليكسا': false,
          'بارد': true,
          'كورتانا': false
        }
      },
      'zh': {
        'question': "谷歌的人工智能叫什么名字？",
        'answers': {
          'Siri': false,
          'Alexa': false,
          'Bard': true,
          'Cortana': false
        }
      },
      'hi': {
        'question': "Google के AI का नाम क्या है?",
        'answers': {
          'Siri': false,
          'Alexa': false,
          'Bard': true,
          'Cortana': false
        }
      },
      'es': {
        'question': "¿Cuál es el nombre de la IA de Google?",
        'answers': {
          'Siri': false,
          'Alexa': false,
          'Bard': true,
          'Cortana': false
        }
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🏥 SANTÉ ET MÉDECINE (2 questions)
    // ════════════════════════════════════════════════════════════

    // Q11: Litres de sang
    "Combien de litres de sang contient le corps humain ?": {
      'en': {
        'question': "How many liters of blood does the human body contain?",
        'answers': {
          '3-4 liters': false,
          '4-5 liters': false,
          '5-6 liters': true,
          '6-7 liters': false
        }
      },
      'ar': {
        'question': "كم لترًا من الدم يحتوي جسم الإنسان؟",
        'answers': {
          '3-4 لتر': false,
          '4-5 لتر': false,
          '5-6 لتر': true,
          '6-7 لتر': false
        }
      },
      'zh': {
        'question': "人体含有多少升血液？",
        'answers': {'3-4升': false, '4-5升': false, '5-6升': true, '6-7升': false}
      },
      'hi': {
        'question': "मानव शरीर में कितने लीटर रक्त होता है?",
        'answers': {
          '3-4 लीटर': false,
          '4-5 लीटर': false,
          '5-6 लीटर': true,
          '6-7 लीटर': false
        }
      },
      'es': {
        'question': "¿Cuántos litros de sangre contiene el cuerpo humano?",
        'answers': {
          '3-4 litros': false,
          '4-5 litros': false,
          '5-6 litros': true,
          '6-7 litros': false
        }
      }
    },

    // Q12: Virus SIDA
    "Quel virus cause le SIDA ?": {
      'en': {
        'question': "Which virus causes AIDS?",
        'answers': {'HIV': true, 'HCV': false, 'HBV': false, 'HAV': false}
      },
      'ar': {
        'question': "ما هو الفيروس المسبب للإيدز؟",
        'answers': {
          'فيروس نقص المناعة البشرية': true,
          'فيروس الكبد الوبائي سي': false,
          'فيروس الكبد الوبائي بي': false,
          'فيروس الكبد الوبائي أيه': false
        }
      },
      'zh': {
        'question': "哪种病毒会导致艾滋病？",
        'answers': {
          'HIV（人类免疫缺陷病毒）': true,
          'HCV（丙型肝炎病毒）': false,
          'HBV（乙型肝炎病毒）': false,
          'HAV（甲型肝炎病毒）': false
        }
      },
      'hi': {
        'question': "कौन सा वायरस एड्स का कारण बनता है?",
        'answers': {'HIV': true, 'HCV': false, 'HBV': false, 'HAV': false}
      },
      'es': {
        'question': "¿Qué virus causa el SIDA?",
        'answers': {'VIH': true, 'VHC': false, 'VHB': false, 'VHA': false}
      }
    },

    // ════════════════════════════════════════════════════════════
    // 🌱 ENVIRONNEMENT ET ÉCOLOGIE (2 questions)
    // ════════════════════════════════════════════════════════════

    // Q13: Gaz effet de serre
    "Quel gaz est principalement responsable de l'effet de serre ?": {
      'en': {
        'question':
            "Which gas is mainly responsible for the greenhouse effect?",
        'answers': {
          'Oxygen': false,
          'Nitrogen': false,
          'Carbon dioxide': true,
          'Hydrogen': false
        }
      },
      'ar': {
        'question': "ما هو الغاز المسؤول بشكل أساسي عن الاحتباس الحراري؟",
        'answers': {
          'الأكسجين': false,
          'النيتروجين': false,
          'ثاني أكسيد الكربون': true,
          'الهيدروجين': false
        }
      },
      'zh': {
        'question': "哪种气体主要导致温室效应？",
        'answers': {'氧气': false, '氮气': false, '二氧化碳': true, '氢气': false}
      },
      'hi': {
        'question':
            "ग्रीनहाउस प्रभाव के लिए मुख्य रूप से कौन सी गैस जिम्मेदार है?",
        'answers': {
          'ऑक्सीजन': false,
          'नाइट्रोजन': false,
          'कार्बन डाइऑक्साइड': true,
          'हाइड्रोजन': false
        }
      },
      'es': {
        'question':
            "¿Qué gas es principalmente responsable del efecto invernadero?",
        'answers': {
          'Oxígeno': false,
          'Nitrógeno': false,
          'Dióxido de carbono': true,
          'Hidrógeno': false
        }
      }
    },

    // Q14: Espèces dans les océans
    "Quel pourcentage d'espèces animales vivent dans les océans ?": {
      'en': {
        'question': "What percentage of animal species live in the oceans?",
        'answers': {'50%': false, '70%': false, '80%': true, '90%': false}
      },
      'ar': {
        'question':
            "ما هي النسبة المئوية للأنواع الحيوانية التي تعيش في المحيطات؟",
        'answers': {'50%': false, '70%': false, '80%': true, '90%': false}
      },
      'zh': {
        'question': "海洋中生活着多少百分比的动物物种？",
        'answers': {'50%': false, '70%': false, '80%': true, '90%': false}
      },
      'hi': {
        'question':
            "समुद्रों में कितने प्रतिशत जानवरों की प्रजातियाँ रहती हैं?",
        'answers': {'50%': false, '70%': false, '80%': true, '90%': false}
      },
      'es': {
        'question':
            "¿Qué porcentaje de especies animales viven en los océanos?",
        'answers': {'50%': false, '70%': false, '80%': true, '90%': false}
      }
    },
  };
}








