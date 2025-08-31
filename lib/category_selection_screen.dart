import 'package:flutter/material.dart';
import 'services/question_service.dart';
import 'services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/learning_mode_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategorySelectionScreen({required this.onCategorySelected, Key? key})
      : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _initializeCategories();
    _controller.forward();
    _loadBannerAd();
  }

  Future<void> _initializeCategories() async {
    await QuestionService.loadQuestions();

    setState(() {
      categories = [
        {
          "title": "Histoire du Mali",
          "icon": Icons.history_edu,
          "description": "Découvrez l'histoire riche et fascinante du Mali.",
          "difficulty": "Moyen",
        },
        {
          "title": "Culture générale",
          "icon": Icons.public,
          "description":
              "Testez vos connaissances sur le monde qui vous entoure.",
          "difficulty": "Facile",
        },
        {
          "title": "Sciences",
          "icon": Icons.science,
          "description": "Explore les mystères de la nature et de l'univers.",
          "difficulty": "Moyen",
        },
        {
          "title": "Mathématiques",
          "icon": Icons.functions,
          "description": "Résous des énigmes et des calculs ludiques.",
          "difficulty": "Difficile",
        },
        {
          "title": "Afrique",
          "icon": Icons.map,
          "description":
              "Découvrez la géographie et l'histoire du continent africain.",
          "difficulty": "Facile",
        },
        {
          "title": "Arts et Culture",
          "icon": Icons.palette,
          "description":
              "Explorez l'art, la musique, le cinéma et la littérature.",
          "difficulty": "Moyen",
        },
        {
          "title": "Politique et Économie",
          "icon": Icons.account_balance,
          "description": "Découvrez les institutions et l'économie mondiale.",
          "difficulty": "Moyen",
        },
        {
          "title": "Technologie et Innovation",
          "icon": Icons.computer,
          "description": "Plongez dans le monde de la technologie et de l'IA.",
          "difficulty": "Difficile",
        },
        {
          "title": "Santé et Médecine",
          "icon": Icons.medical_services,
          "description": "Apprenez sur le corps humain et la médecine.",
          "difficulty": "Moyen",
        },
        {
          "title": "Environnement et Écologie",
          "icon": Icons.eco,
          "description": "Découvrez la nature et les enjeux environnementaux.",
          "difficulty": "Moyen",
        },
        {
          "title": "Questions Expert",
          "icon": Icons.psychology,
          "description":
              "Défiez-vous avec des questions avancées et spécialisées.",
          "difficulty": "Très Difficile",
        },
        {
          "title": "Questions Spécialisées",
          "icon": Icons.star,
          "description": "Questions pointues sur des sujets spécifiques.",
          "difficulty": "Expert",
        },
      ];
    });
  }

  late AnimationController _controller;
  String searchQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() async {
    _bannerAd = await AdService.createBannerAd();
    if (_bannerAd != null) {
      setState(() {
        _bannerAd!.load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories
        .where(
          (cat) => cat['title'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choisir une catégorie',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredCategories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return CategoryCard(
                    title: category['title'],
                    icon: category['icon'],
                    description: category['description'],
                    difficulty: category['difficulty'],
                    onTap: () => widget.onCategorySelected(category['title']),
                  );
                },
              ),
            ),
          ),
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String difficulty;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryCard({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  Color _getDifficultyColor(String level) {
    switch (level.toLowerCase()) {
      case 'facile':
        return Colors.lightGreenAccent;
      case 'moyen':
        return Colors.yellowAccent;
      case 'difficile':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(difficulty),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      difficulty,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Afficher une publicité interstitielle avant de commencer le quiz
                        try {
                          await AdService.showCategoryChangeInterstitial();
                        } catch (e) {
                          print('[CategorySelection] ❌ Erreur publicité: $e');
                        }
                        // Lancer le quiz
                        onTap();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Jouer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LearningModeScreen(category: title),
                          ),
                        );
                      },
                      icon: const Icon(Icons.school),
                      label: const Text('Apprendre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
