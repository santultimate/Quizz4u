import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'category_selection_screen.dart';
import 'quiz_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_spacing.dart';
import 'widgets/haptic_button.dart';
import 'widgets/page_transitions.dart';
import 'services/translation_service.dart';
import 'services/review_service.dart';
import 'services/question_service_optimized.dart';
import 'widgets/ad_banner_widget.dart';

/// Écran d'accueil refondé avec animations et design moderne
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _questionCount = 0;
  int _categoryCount = 12;

  @override
  void initState() {
    super.initState();
    _loadContentStats();

    // Animation de fade in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Animation de slide up
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Animation de pulsation pour le logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadContentStats() async {
    try {
      if (!QuestionServiceOptimized.isLoaded) {
        await QuestionServiceOptimized.loadEssentialQuestions();
      }
      await QuestionServiceOptimized.waitForAllCategories(
        timeout: const Duration(seconds: 8),
      );
      if (!mounted) return;
      setState(() {
        _questionCount = QuestionServiceOptimized.getTotalQuestionCount();
        _categoryCount = QuestionServiceOptimized.categoryFiles.length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _questionCount = 500;
        _categoryCount = 12;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? AppColors.darkGradient : AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barre supérieure avec icônes
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Icône trophée (Records)
                    IconButton(
                      icon: Icon(Icons.emoji_events, color: Colors.amber),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushNamed(context, '/statistics');
                      },
                    ),

                    // Titre central
                    Expanded(
                      child: Text(
                        TranslationService.translate('welcome_quiz'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Icônes à droite
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Premium/Étoile
                        IconButton(
                          icon: Icon(Icons.star, color: Colors.white),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushNamed(context, '/premium');
                          },
                        ),
                        // Profil
                        IconButton(
                          icon: Icon(Icons.person, color: Colors.white),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        // Paramètres
                        IconButton(
                          icon: Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: AppSpacing.paddingXL,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),

                          // Logo animé
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Text(
                              'Quizz4U',
                              style: AppTextStyles.logo,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const Spacer(flex: 3),

                          // Bouton principal
                          HapticButton(
                            text: TranslationService.translate('start'),
                            fullWidth: true,
                            height: AppSpacing.buttonHeightL,
                            icon: Icons.play_arrow_rounded,
                            type: ButtonType.secondary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransitions.slideFade(
                                  builder: (context) => CategorySelectionScreen(
                                    onCategorySelected: (category) {
                                      // Navigation vers QuizScreen avec la catégorie sélectionnée
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QuizScreen(category: category),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          AppSpacing.spaceM,

                          // Bouton Défi Quotidien
                          HapticButton(
                            text:
                                TranslationService.translate('daily_challenge'),
                            fullWidth: true,
                            height: AppSpacing.buttonHeightL,
                            icon: Icons.calendar_today_rounded,
                            type: ButtonType.primary,
                            onPressed: () {
                              Navigator.pushNamed(context, '/daily_challenge');
                            },
                          ),

                          AppSpacing.spaceM,

                          // Mode révision
                          HapticButton(
                            text: TranslationService.translate('review_mode'),
                            fullWidth: true,
                            height: AppSpacing.buttonHeightL,
                            icon: Icons.replay_rounded,
                            type: ButtonType.info,
                            onPressed: () async {
                              final count = await ReviewService.getWrongCount();
                              if (!context.mounted) return;
                              if (count == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      TranslationService.translate(
                                          'no_review_questions'),
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuizScreen(
                                    category: 'Révision',
                                    isReviewMode: true,
                                  ),
                                ),
                              );
                            },
                          ),

                          AppSpacing.spaceXL,

                          // Stats rapides
                          Container(
                            padding: AppSpacing.paddingL,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: AppSpacing.borderRadiusL,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: _buildStat(
                                      icon: Icons.quiz,
                                      label: TranslationService.translate(
                                          'questions'),
                                      value: TranslationService
                                          .translateWithParams(
                                              'questions_count_display',
                                              {
                                                'count':
                                                    '$_questionCount'
                                              }),
                                    ),
                                  ),
                                  _buildVerticalDivider(),
                                  Expanded(
                                    child: _buildStat(
                                      icon: Icons.category,
                                      label: TranslationService.translate(
                                          'categories'),
                                      value: TranslationService
                                          .translateWithParams(
                                              'categories_count',
                                              {'count': '$_categoryCount'}),
                                    ),
                                  ),
                                  _buildVerticalDivider(),
                                  Expanded(
                                    child: _buildStat(
                                      icon: Icons.language,
                                      label: TranslationService.translate(
                                          'languages'),
                                      value: TranslationService
                                          .translateWithParams(
                                              'languages_count',
                                              {'count': '6'}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          AppSpacing.spaceL,

                          // 💰 Bannière publicitaire (seulement pour non-premium)
                          const AdBannerWidget(
                            placement: 'home_bottom',
                            height: 50,
                          ),

                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: AppSpacing.iconL,
        ),
        AppSpacing.spaceS,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.scoreMedium.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}
