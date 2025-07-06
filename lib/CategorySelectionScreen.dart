import 'package:flutter/material.dart';
import 'services/question_service.dart';
import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _initializeCategories();
    _controller.forward();
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
      ];
    });
  }

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String searchQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _launchRandomCategory() {
    final random = Random();
    final filtered = categories
        .where(
          (cat) => cat['title'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();
    if (filtered.isNotEmpty) {
      final randomCategory = filtered[random.nextInt(filtered.length)];
      widget.onCategorySelected(randomCategory['title']);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Choisissez une catégorie',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Signatra',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _launchRandomCategory,
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    label: const Text(
                      "Catégorie surprise",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return CategoryCard(
                          title: category['title'],
                          icon: category['icon'],
                          description: category['description'],
                          difficulty: category['difficulty'],
                          onTap: () =>
                              widget.onCategorySelected(category['title']),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          child: Row(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ),
      ),
    );
  }
}
