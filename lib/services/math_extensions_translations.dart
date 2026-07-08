/// 📐 MATH EXTENSIONS: Traductions manuelles des 9 questions supplémentaires
/// 
/// Questions de Mathématiques provenant de:
/// - questions_extension_phase1.json (3 questions)
/// - massive_extension_phase4.json (2 questions)
/// - premium_questions_phase6.json (4 questions)
/// 
/// Traductions professionnelles pour 6 langues:
/// - 🇫🇷 Français
/// - 🇬🇧 English
/// - 🇸🇦 العربية (Arabe)
/// - 🇨🇳 中文 (Chinois Mandarin)
/// - 🇮🇳 हिन्दी (Hindi)
/// - 🇪🇸 Español (Espagnol)
library;

class MathExtensionsTranslations {
  static const Map<String, Map<String, dynamic>> translations = {
    // Question 1: "Quel est le résultat de 15 × 7 ?"
    "Quel est le résultat de 15 × 7 ?": {
      'fr': {
        'question': 'Quel est le résultat de 15 × 7 ?',
        'options': ['95', '105', '115', '125']
      },
      'en': {
        'question': 'What is the result of 15 × 7?',
        'options': ['95', '105', '115', '125']
      },
      'ar': {
        'question': 'ما هي نتيجة 15 × 7؟',
        'options': ['95', '105', '115', '125']
      },
      'zh': {
        'question': '15 × 7 的结果是多少？',
        'options': ['95', '105', '115', '125']
      },
      'hi': {
        'question': '15 × 7 का परिणाम क्या है?',
        'options': ['95', '105', '115', '125']
      },
      'es': {
        'question': '¿Cuál es el resultado de 15 × 7?',
        'options': ['95', '105', '115', '125']
      }
    },

    // Question 2: "Quel est le pourcentage de 25 sur 100 ?"
    "Quel est le pourcentage de 25 sur 100 ?": {
      'fr': {
        'question': 'Quel est le pourcentage de 25 sur 100 ?',
        'options': ['15%', '20%', '25%', '30%']
      },
      'en': {
        'question': 'What is the percentage of 25 out of 100?',
        'options': ['15%', '20%', '25%', '30%']
      },
      'ar': {
        'question': 'ما هي النسبة المئوية لـ 25 من 100؟',
        'options': ['15%', '20%', '25%', '30%']
      },
      'zh': {
        'question': '25 占 100 的百分比是多少？',
        'options': ['15%', '20%', '25%', '30%']
      },
      'hi': {
        'question': '100 में से 25 का प्रतिशत क्या है?',
        'options': ['15%', '20%', '25%', '30%']
      },
      'es': {
        'question': '¿Cuál es el porcentaje de 25 sobre 100?',
        'options': ['15%', '20%', '25%', '30%']
      }
    },

    // Question 3: "Combien de côtés a un hexagone ?"
    "Combien de côtés a un hexagone ?": {
      'fr': {
        'question': 'Combien de côtés a un hexagone ?',
        'options': ['4', '5', '6', '7']
      },
      'en': {
        'question': 'How many sides does a hexagon have?',
        'options': ['4', '5', '6', '7']
      },
      'ar': {
        'question': 'كم عدد أضلاع المسدس؟',
        'options': ['4', '5', '6', '7']
      },
      'zh': {
        'question': '六边形有多少条边？',
        'options': ['4', '5', '6', '7']
      },
      'hi': {
        'question': 'षट्भुज में कितनी भुजाएँ होती हैं?',
        'options': ['4', '5', '6', '7']
      },
      'es': {
        'question': '¿Cuántos lados tiene un hexágono?',
        'options': ['4', '5', '6', '7']
      }
    },

    // Question 4: "Quel est le résultat de (a + b)² ?"
    "Quel est le résultat de (a + b)² ?": {
      'fr': {
        'question': 'Quel est le résultat de (a + b)² ?',
        'options': ['a² + b²', 'a² + 2ab + b²', 'a² - 2ab + b²', 'a² + ab + b²']
      },
      'en': {
        'question': 'What is the result of (a + b)²?',
        'options': ['a² + b²', 'a² + 2ab + b²', 'a² - 2ab + b²', 'a² + ab + b²']
      },
      'ar': {
        'question': 'ما هي نتيجة (a + b)²؟',
        'options': ['a² + b²', 'a² + 2ab + b²', 'a² - 2ab + b²', 'a² + ab + b²']
      },
      'zh': {
        'question': '(a + b)² 的结果是什么？',
        'options': ['a² + b²', 'a² + 2ab + b²', 'a² - 2ab + b²', 'a² + ab + b²']
      },
      'hi': {
        'question': '(a + b)² का परिणाम क्या है?',
        'options': ['a² + b²', 'a² + 2ab + b²', 'a² - 2ab + b²', 'a² + ab + b²']
      },
      'es': {
        'question': '¿Cuál es el resultado de (a + b)²?',
        'options': ['a² + b²', 'a² + 2ab + b²', 'a² - 2ab + b²', 'a² + ab + b²']
      }
    },

    // Question 5: "Quel est le nom de l'équation ax² + bx + c = 0 ?"
    "Quel est le nom de l'équation ax² + bx + c = 0 ?": {
      'fr': {
        'question': 'Quel est le nom de l\'équation ax² + bx + c = 0 ?',
        'options': [
          'Équation du premier degré',
          'Équation du second degré',
          'Équation du troisième degré',
          'Équation polynomiale'
        ]
      },
      'en': {
        'question': 'What is the name of the equation ax² + bx + c = 0?',
        'options': [
          'First degree equation',
          'Second degree equation',
          'Third degree equation',
          'Polynomial equation'
        ]
      },
      'ar': {
        'question': 'ما اسم المعادلة ax² + bx + c = 0؟',
        'options': [
          'معادلة من الدرجة الأولى',
          'معادلة من الدرجة الثانية',
          'معادلة من الدرجة الثالثة',
          'معادلة متعددة الحدود'
        ]
      },
      'zh': {
        'question': '方程 ax² + bx + c = 0 叫什么名字？',
        'options': ['一次方程', '二次方程', '三次方程', '多项式方程']
      },
      'hi': {
        'question': 'ax² + bx + c = 0 समीकरण का नाम क्या है?',
        'options': [
          'प्रथम घात समीकरण',
          'द्वितीय घात समीकरण',
          'तृतीय घात समीकरण',
          'बहुपद समीकरण'
        ]
      },
      'es': {
        'question': '¿Cuál es el nombre de la ecuación ax² + bx + c = 0?',
        'options': [
          'Ecuación de primer grado',
          'Ecuación de segundo grado',
          'Ecuación de tercer grado',
          'Ecuación polinomial'
        ]
      }
    },

    // Question 6: "Quel est le nom du théorème qui dit que dans un triangle rectangle, a² + b² = c² ?"
    "Quel est le nom du théorème qui dit que dans un triangle rectangle, a² + b² = c² ?":
        {
      'fr': {
        'question':
            'Quel est le nom du théorème qui dit que dans un triangle rectangle, a² + b² = c² ?',
        'options': [
          'Le théorème de Pythagore',
          'Le théorème de Thalès',
          'Le théorème de l\'angle droit',
          'Le théorème des milieux'
        ]
      },
      'en': {
        'question':
            'What is the name of the theorem that says in a right triangle, a² + b² = c²?',
        'options': [
          'Pythagorean theorem',
          'Thales\' theorem',
          'Right angle theorem',
          'Midpoint theorem'
        ]
      },
      'ar': {
        'question':
            'ما اسم النظرية التي تقول في المثلث القائم الزاوية a² + b² = c²؟',
        'options': [
          'نظرية فيثاغورس',
          'نظرية طاليس',
          'نظرية الزاوية القائمة',
          'نظرية منتصفات الأضلاع'
        ]
      },
      'zh': {
        'question': '直角三角形中 a² + b² = c² 这个定理叫什么名字？',
        'options': ['毕达哥拉斯定理', '泰勒斯定理', '直角定理', '中点定理']
      },
      'hi': {
        'question':
            'समकोण त्रिभुज में a² + b² = c² कहने वाले प्रमेय का नाम क्या है?',
        'options': [
          'पाइथागोरस प्रमेय',
          'थेल्स प्रमेय',
          'समकोण प्रमेय',
          'मध्य बिंदु प्रमेय'
        ]
      },
      'es': {
        'question':
            '¿Cuál es el nombre del teorema que dice que en un triángulo rectángulo, a² + b² = c²?',
        'options': [
          'Teorema de Pitágoras',
          'Teorema de Tales',
          'Teorema del ángulo recto',
          'Teorema de los puntos medios'
        ]
      }
    },

    // Question 7: "Quel est le nom du nombre π (pi) ?"
    "Quel est le nom du nombre π (pi) ?": {
      'fr': {
        'question': 'Quel est le nom du nombre π (pi) ?',
        'options': [
          'Le nombre d\'or',
          'Le nombre d\'Euler',
          'Le nombre de Pythagore',
          'Le nombre d\'Archimède'
        ]
      },
      'en': {
        'question': 'What is the name of the number π (pi)?',
        'options': [
          'Golden ratio',
          'Euler\'s number',
          'Pythagoras\' number',
          'Archimedes\' number'
        ]
      },
      'ar': {
        'question': 'ما اسم العدد π (باي)؟',
        'options': [
          'العدد الذهبي',
          'عدد أويلر',
          'عدد فيثاغورس',
          'عدد أرخميدس'
        ]
      },
      'zh': {
        'question': '数字 π (圆周率) 叫什么名字？',
        'options': ['黄金比率', '欧拉数', '毕达哥拉斯数', '阿基米德数']
      },
      'hi': {
        'question': 'संख्या π (पाई) का नाम क्या है?',
        'options': [
          'स्वर्ण अनुपात',
          'ऑयलर की संख्या',
          'पाइथागोरस की संख्या',
          'आर्किमिडीज़ की संख्या'
        ]
      },
      'es': {
        'question': '¿Cuál es el nombre del número π (pi)?',
        'options': [
          'Número de oro',
          'Número de Euler',
          'Número de Pitágoras',
          'Número de Arquímedes'
        ]
      }
    },

    // Question 8: "Quel est le nom du nombre 1,618033988749... ?"
    "Quel est le nom du nombre 1,618033988749... ?": {
      'fr': {
        'question': 'Quel est le nom du nombre 1,618033988749... ?',
        'options': [
          'Le nombre d\'or',
          'Le nombre d\'Euler',
          'Le nombre π',
          'Le nombre e'
        ]
      },
      'en': {
        'question': 'What is the name of the number 1.618033988749...?',
        'options': ['Golden ratio', 'Euler\'s number', 'Pi', 'e']
      },
      'ar': {
        'question': 'ما اسم العدد 1,618033988749...؟',
        'options': ['العدد الذهبي', 'عدد أويلر', 'العدد π', 'العدد e']
      },
      'zh': {
        'question': '数字 1.618033988749... 叫什么名字？',
        'options': ['黄金比率', '欧拉数', '圆周率', '自然常数 e']
      },
      'hi': {
        'question': 'संख्या 1.618033988749... का नाम क्या है?',
        'options': ['स्वर्ण अनुपात', 'ऑयलर की संख्या', 'पाई', 'e']
      },
      'es': {
        'question': '¿Cuál es el nombre del número 1.618033988749...?',
        'options': ['Número de oro', 'Número de Euler', 'Pi', 'e']
      }
    },

    // Question 9: "Quel est le nom du nombre 2,718281828459... ?"
    "Quel est le nom du nombre 2,718281828459... ?": {
      'fr': {
        'question': 'Quel est le nom du nombre 2,718281828459... ?',
        'options': [
          'Le nombre d\'or',
          'Le nombre d\'Euler',
          'Le nombre π',
          'Le nombre de Neper'
        ]
      },
      'en': {
        'question': 'What is the name of the number 2.718281828459...?',
        'options': ['Golden ratio', 'Euler\'s number', 'Pi', 'Napier\'s number']
      },
      'ar': {
        'question': 'ما اسم العدد 2,718281828459...؟',
        'options': ['العدد الذهبي', 'عدد أويلر', 'العدد π', 'عدد نيبير']
      },
      'zh': {
        'question': '数字 2.718281828459... 叫什么名字？',
        'options': ['黄金比率', '欧拉数', '圆周率', '纳皮尔常数']
      },
      'hi': {
        'question': 'संख्या 2.718281828459... का नाम क्या है?',
        'options': [
          'स्वर्ण अनुपात',
          'ऑयलर की संख्या',
          'पाई',
          'नेपियर की संख्या'
        ]
      },
      'es': {
        'question': '¿Cuál es el nombre del número 2.718281828459...?',
        'options': [
          'Número de oro',
          'Número de Euler',
          'Pi',
          'Número de Neper'
        ]
      }
    },
  };
}











