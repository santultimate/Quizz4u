import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../services/progress_service.dart';
import '../services/badge_service.dart';
import '../services/translation_service.dart';
import '../services/question_translation_service.dart';
import '../models/user_progress.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/page_transitions.dart';
import 'badges_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  Map<String, dynamic> stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    print('[ProfileScreen] 🔄 Chargement des statistiques...');

    await ProgressService.loadProgress();
    final loadedStats = await ProgressService.getStats();

    await Future.delayed(const Duration(milliseconds: 300)); // Smooth loading

    setState(() {
      stats = loadedStats;
      _isLoading = false;
    });

    print('[ProfileScreen] 📊 Statistiques chargées: $stats');
    _animationController.forward();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationService.translate('profile'),
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _fadeController.reset();
              _slideController.reset();
              _loadStats();
            },
            tooltip: TranslationService.translate('refresh'),
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // En-tête avec niveau et XP
                    _buildHeader(isDark),
                    SizedBox(height: AppSpacing.lg),

                    // Statistiques principales
                    _buildMainStats(isDark),
                    SizedBox(height: AppSpacing.lg),

                    // Badges
                    _buildBadges(isDark),
                    SizedBox(height: AppSpacing.lg),

                    // Statistiques par catégorie
                    _buildCategoryStats(isDark),
                    SizedBox(height: AppSpacing.lg),

                    // Boutons d'action
                    _buildActionButtons(isDark),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLoader(
                    width: 120,
                    height: 120,
                    borderRadius: 60,
                  ),
                  SizedBox(height: AppSpacing.md),
                  SkeletonLoader(width: 150, height: 24),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonLoader(width: 100, height: 16),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Stats cards skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: SkeletonLoader(height: 120)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonLoader(height: 120)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonLoader(height: 120)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Badges section skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                SkeletonLoader(height: 30, width: double.infinity),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: index < 3 ? AppSpacing.sm : 0),
                        child: SkeletonLoader(height: 90),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final level = stats['level'] ?? 1;
    final xp = stats['experiencePoints'] ?? 0;
    final xpForNext = stats['xpForNextLevel'] ?? 100;
    final progress = stats['levelProgress'] ?? 0.0;
    final title = ProgressService.getLevelTitle(level);
    final playerName =
        stats['playerName'] ?? TranslationService.translate('player');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.lg),

          // Avatar et niveau avec effet pulsant
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Container(
                    width: 140 + (value * 10),
                    height: 140 + (value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent
                              .withValues(alpha: 0.3 * (1 - value)),
                          blurRadius: 30 * value,
                          spreadRadius: 10 * value,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Lottie.asset(
                    'assets/animations/congrats.json',
                    controller: _animationController,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accent.withValues(alpha: 0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '${TranslationService.translate('level')} $level',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Titre du niveau avec animation
          AnimatedCounter(
            value: level.toDouble(),
            prefix: '$title\n',
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xs),

          // Nom du joueur
          Text(
            playerName,
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Barre de progression XP avec glassmorphism
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedCounter(
                      value: xp.toDouble(),
                      suffix: ' XP',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    AnimatedCounter(
                      value: (xp + xpForNext).toDouble(),
                      suffix: ' XP',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accent.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                AnimatedCounter(
                  value: xpForNext.toDouble(),
                  suffix:
                      ' XP ${TranslationService.translate('for_level')} ${level + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildMainStats(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              TranslationService.translate('questions'),
              (stats['totalQuestions'] ?? 0).toDouble(),
              Icons.quiz_rounded,
              AppColors.info,
              isDark,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              TranslationService.translate('success_rate'),
              stats['accuracyRate'] ?? 0.0,
              Icons.trending_up_rounded,
              AppColors.success,
              isDark,
              suffix: '%',
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              TranslationService.translate('total_score'),
              (stats['totalScore'] ?? 0).toDouble(),
              Icons.stars_rounded,
              AppColors.accent,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    double value,
    IconData icon,
    Color color,
    bool isDark, {
    String suffix = '',
  }) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            AnimatedCounter(
              value: value,
              suffix: suffix,
              style: AppTextStyles.h2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(bool isDark) {
    final badges = List<String>.from(stats['badges'] ?? []);
    final userProgress = UserProgress.fromMap(stats);
    final badgeStats = BadgeService.getBadgeStats(userProgress);

    if (badges.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 60,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                TranslationService.translate('no_badges_yet'),
                style: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                TranslationService.translate(
                    'continue_playing_to_unlock_badges'),
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationService.translate('badges'),
                style: AppTextStyles.h2.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.info,
                          AppColors.info.withValues(alpha: 0.7)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      '${badgeStats['total']} / ${BadgeService.getAllBadges().length}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.emoji_events_rounded),
                    color: AppColors.info,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BadgesScreen(
                            userProgress: userProgress,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Statistiques des badges
          Row(
            children: [
              _buildBadgeStat(
                TranslationService.translate('category'),
                badgeStats['category'],
                AppColors.success,
                isDark,
              ),
              SizedBox(width: AppSpacing.sm),
              _buildBadgeStat(
                TranslationService.translate('difficulty'),
                badgeStats['difficulty'],
                AppColors.warning,
                isDark,
              ),
              SizedBox(width: AppSpacing.sm),
              _buildBadgeStat(
                TranslationService.translate('special'),
                badgeStats['special'],
                AppColors.secondary,
                isDark,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Badges organisés par type
          _buildBadgeSection(
            TranslationService.translate('badges_by_category'),
            badges
                .where((b) => b.contains('_perfect_') || b.contains('_expert_'))
                .toList(),
            isDark,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildBadgeSection(
            TranslationService.translate('difficulty_badges'),
            badges.where((b) => b.contains('_master')).toList(),
            isDark,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildBadgeSection(
            TranslationService.translate('special_badges'),
            badges
                .where((b) =>
                    !b.contains('_perfect_') &&
                    !b.contains('_expert_') &&
                    !b.contains('_master'))
                .toList(),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStat(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            AnimatedCounter(
              value: count.toDouble(),
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeSection(
      String title, List<String> sectionBadges, bool isDark) {
    if (sectionBadges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children:
              sectionBadges.map((badge) => _buildBadge(badge, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(String badge, bool isDark) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 90,
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    ProgressService.getBadgeIcon(badge),
                    style: const TextStyle(fontSize: 32),
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              ProgressService.getBadgeName(badge),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats(bool isDark) {
    final categoryStats = stats['categoryStats'] as Map<String, dynamic>? ?? {};

    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('performance_by_category'),
            style: AppTextStyles.h2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...categoryStats.entries.map((entry) => _buildCategoryStat(
              entry.key, entry.value as Map<String, dynamic>, isDark)),
        ],
      ),
    );
  }

  Widget _buildCategoryStat(
      String category, Map<String, dynamic> stats, bool isDark) {
    int correct = stats['correct'] ?? 0;
    int total = stats['total'] ?? 0;
    double accuracy = stats['accuracy'] ?? 0.0;
    int wrong = stats['wrong'] ?? 0;

    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    QuestionTranslationService.translateCategory(category),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withValues(alpha: 0.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedCounter(
                    value: accuracy,
                    suffix: '%',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildMiniStat(
                  '$correct',
                  TranslationService.translate('correct_answers_short'),
                  AppColors.success,
                ),
                SizedBox(width: AppSpacing.md),
                _buildMiniStat(
                  '$wrong',
                  TranslationService.translate('wrong_answers'),
                  AppColors.error,
                ),
                const Spacer(),
                Text(
                  '${TranslationService.translate('total')}: $total',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          '$value $label',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: TranslationService.translate('badges'),
              icon: Icons.emoji_events_rounded,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.8)
                ],
              ),
              onTap: () async {
                HapticFeedback.mediumImpact();
                await ProgressService.loadProgress();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BadgesScreen(
                      userProgress: ProgressService.currentProgress,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildActionButton(
              label: TranslationService.translate('statistics'),
              icon: Icons.analytics_rounded,
              gradient: LinearGradient(
                colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
              ),
              onTap: () async {
                HapticFeedback.mediumImpact();
                await _loadStats();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(TranslationService.translate('stats_updated')),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget AnimatedCounter pour animer les chiffres
class AnimatedCounter extends StatefulWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.textAlign,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final displayValue = value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(1);

        return Text(
          '${widget.prefix}$displayValue${widget.suffix}',
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

// Widget SkeletonLoader pour le chargement
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 + _controller.value * 2, 0.0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}
