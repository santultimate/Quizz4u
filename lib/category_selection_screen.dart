import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/question_service_optimized.dart'; // ⚡ OPTIMISÉ
import 'services/question_translation_service.dart';
import 'services/translation_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_spacing.dart';
import 'widgets/ad_banner_widget.dart';

class CategorySelectionScreen extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategorySelectionScreen({required this.onCategorySelected, super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  late AnimationController _fadeController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initializeCategories();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeCategories() async {
    // ⚡ Les questions sont déjà chargées dans LoadingScreen
    if (!QuestionServiceOptimized.isLoaded) {
      await QuestionServiceOptimized.loadEssentialQuestions();
    }

    setState(() {
      categories = [
        {
          "title": "Histoire du Mali",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Histoire du Mali"),
          "icon": Icons.history_edu_rounded,
          "color": AppColors.info,
          "description": TranslationService.translate('history_description'),
          "difficulty": TranslationService.translate('medium'),
        },
        {
          "title": "Culture générale",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Culture générale"),
          "icon": Icons.public_rounded,
          "color": AppColors.secondary,
          "description": TranslationService.translate('culture_description'),
          "difficulty": TranslationService.translate('easy'),
        },
        {
          "title": "Sciences",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Sciences"),
          "icon": Icons.science_rounded,
          "color": AppColors.success,
          "description": TranslationService.translate('science_description'),
          "difficulty": TranslationService.translate('medium'),
        },
        {
          "title": "Mathématiques",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Mathématiques"),
          "icon": Icons.functions_rounded,
          "color": AppColors.warning,
          "description": TranslationService.translate('math_description'),
          "difficulty": TranslationService.translate('hard'),
        },
        {
          "title": "Afrique",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Afrique"),
          "icon": Icons.map_rounded,
          "color": AppColors.accent,
          "description": TranslationService.translate('africa_description'),
          "difficulty": TranslationService.translate('easy'),
        },
        {
          "title": "Arts et Culture",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Arts et Culture"),
          "icon": Icons.palette_rounded,
          "color": AppColors.secondary,
          "description":
              TranslationService.translate('arts_culture_description'),
          "difficulty": TranslationService.translate('medium'),
        },
        {
          "title": "Politique et Économie",
          "translatedTitle": QuestionTranslationService.translateCategory(
              "Politique et Économie"),
          "icon": Icons.account_balance_rounded,
          "color": AppColors.info,
          "description":
              TranslationService.translate('politics_economy_description'),
          "difficulty": TranslationService.translate('medium'),
        },
        {
          "title": "Football",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Football"),
          "icon": Icons.sports_soccer_rounded,
          "color": AppColors.success,
          "description": TranslationService.translate('football_description'),
          "difficulty": TranslationService.translate('medium'),
        },
        {
          "title": "Musique",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Musique"),
          "icon": Icons.music_note_rounded,
          "color": AppColors.accent,
          "description": TranslationService.translate('music_description'),
          "difficulty": TranslationService.translate('easy'),
        },
        {
          "title": "Technologie et Innovation",
          "translatedTitle": QuestionTranslationService.translateCategory(
              "Technologie et Innovation"),
          "icon": Icons.computer_rounded,
          "color": AppColors.info,
          "description": TranslationService.translate('technology_description'),
          "difficulty": TranslationService.translate('hard'),
        },
        {
          "title": "Santé et Médecine",
          "translatedTitle":
              QuestionTranslationService.translateCategory("Santé et Médecine"),
          "icon": Icons.medical_services_rounded,
          "color": AppColors.error,
          "description":
              TranslationService.translate('health_medicine_description'),
          "difficulty": TranslationService.translate('medium'),
        },
        {
          "title": "Environnement et Écologie",
          "translatedTitle": QuestionTranslationService.translateCategory(
              "Environnement et Écologie"),
          "icon": Icons.eco_rounded,
          "color": AppColors.success,
          "description":
              TranslationService.translate('environment_description'),
          "difficulty": TranslationService.translate('medium'),
        },
      ];
    });

    _fadeController.forward();
  }

  void _selectCategory(String category) {
    HapticFeedback.mediumImpact();
    widget.onCategorySelected(category);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredCategories = categories
        .where((cat) =>
            cat['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 28),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          TranslationService.translate('choose_your_challenge'),
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(AppSpacing.md),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    return FadeSlideTransition(
                      controller: _fadeController,
                      delay: index * 50,
                      offset: const Offset(0, 30),
                      child: _buildCategoryCard(
                        filteredCategories[index],
                        index,
                        isDark,
                      ),
                    );
                  },
                ),
              ),
              const AdBannerWidget(
                placement: 'category_selection',
                height: 50,
                margin: EdgeInsets.all(AppSpacing.md),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    int index,
    bool isDark,
  ) {
    final color = category['color'] as Color;

    return Hero(
      tag: 'category_${category['title']}',
      child: GestureDetector(
        onTap: () => _selectCategory(category['title']),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Stack(
              children: [
                // Background gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.1),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon avec effet glassmorphism
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.8)],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          category['icon'],
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      SizedBox(height: AppSpacing.md),

                      // Title
                      Text(
                        category['translatedTitle'],
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Difficulty badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(
                            color: color.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category['difficulty'],
                          style: AppTextStyles.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hover effect indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget d'animation combinée (Fade + Slide)
class FadeSlideTransition extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final Offset offset;
  final int delay;

  const FadeSlideTransition({
    super.key,
    required this.controller,
    required this.child,
    this.offset = const Offset(0, 20),
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay / 1000,
        1.0,
        curve: Curves.easeInOut,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: Transform.translate(
        offset: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(animation).value,
        child: child,
      ),
    );
  }
}
