import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/premium_benefits_controller.dart';
import '../services/progress_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'enhanced_premium_screen.dart';

/// 📊 Écran Statistiques Avancées (Premium uniquement)
class AdvancedStatisticsScreen extends StatefulWidget {
  const AdvancedStatisticsScreen({super.key});

  @override
  State<AdvancedStatisticsScreen> createState() =>
      _AdvancedStatisticsScreenState();
}

class _AdvancedStatisticsScreenState extends State<AdvancedStatisticsScreen>
    with TickerProviderStateMixin {
  bool _isPremium = false;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _advancedStats = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _advancedStats = await PremiumBenefitsController.getAdvancedStatistics();
    _isPremium = !(_advancedStats['locked'] ?? true);

    if (_isPremium) {
      _stats = _advancedStats['basicStats'] ?? {};
    } else {
      _stats = await ProgressService.getStats();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade700,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '📊 Statistiques Avancées',
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        actions: [
          if (_isPremium)
            IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white),
              onPressed: _exportData,
              tooltip: 'Exporter les données',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : FadeTransition(
              opacity: _fadeAnimation,
              child:
                  _isPremium ? _buildAdvancedContent() : _buildLockedContent(),
            ),
    );
  }

  Widget _buildAdvancedContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bannière Premium
          _buildPremiumBanner(),
          SizedBox(height: AppSpacing.lg),

          // Vue d'ensemble
          _buildOverviewSection(),
          SizedBox(height: AppSpacing.lg),

          // Analyses de performance
          _buildPerformanceSection(),
          SizedBox(height: AppSpacing.lg),

          // Historique détaillé
          _buildHistorySection(),
          SizedBox(height: AppSpacing.lg),

          // Comparaison temporelle
          _buildComparisonSection(),
          SizedBox(height: AppSpacing.lg),

          // Insights et recommandations
          _buildInsightsSection(),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.black, size: 30),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👑 Analyses Premium',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Historique de 365 jours',
                  style: AppTextStyles.caption.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Vue d\'ensemble',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Questions',
                  (_stats['totalQuestions'] ?? 0).toString(),
                  Icons.quiz,
                  Colors.blue,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  'Précision',
                  '${(_stats['accuracyRate'] ?? 0).toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Score Total',
                  (_stats['totalScore'] ?? 0).toString(),
                  Icons.stars,
                  Colors.amber,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  'Parties',
                  (_stats['totalGames'] ?? 0).toString(),
                  Icons.sports_esports,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    final accuracyRate = _stats['accuracyRate'] ?? 0.0;
    final performance = accuracyRate >= 80
        ? {
            'label': 'Excellent',
            'color': Colors.green,
            'icon': Icons.emoji_events
          }
        : accuracyRate >= 60
            ? {'label': 'Bien', 'color': Colors.orange, 'icon': Icons.thumb_up}
            : {
                'label': 'À améliorer',
                'color': Colors.red,
                'icon': Icons.trending_up
              };

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Analyse de Performance',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                performance['icon'] as IconData,
                color: performance['color'] as Color,
                size: 50,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau : ${performance['label']}',
                      style: AppTextStyles.h3.copyWith(
                        color: performance['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: accuracyRate / 100,
                      backgroundColor: Colors.white24,
                      valueColor:
                          AlwaysStoppedAnimation(performance['color'] as Color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Historique Détaillé',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '✅ Historique de 365 jours disponible',
            style: AppTextStyles.body.copyWith(color: Colors.green),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Suivez votre progression jour par jour et identifiez vos tendances.',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Comparaison Temporelle',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildComparisonRow('Ce mois', '+15%', Colors.green),
          _buildComparisonRow('Ce trimestre', '+28%', Colors.green),
          _buildComparisonRow('Cette année', '+42%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String period, String change, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              period,
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ),
          Text(
            change,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Icon(Icons.trending_up, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 30),
              SizedBox(width: AppSpacing.sm),
              Text(
                '💡 Recommandations',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildInsightItem(
            '✓ Excellente régularité cette semaine',
            Colors.green,
          ),
          _buildInsightItem(
            '✓ Meilleure catégorie : Sciences (92%)',
            Colors.blue,
          ),
          _buildInsightItem(
            '⚠ À améliorer : Histoire (68%)',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 100,
              color: Colors.white54,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              '🔒 Statistiques Avancées',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _advancedStats['message'] ?? 'Fonctionnalité Premium',
              style: AppTextStyles.body.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedPremiumScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.diamond),
              label: const Text('Passer en Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Retour',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final result = await PremiumBenefitsController.exportUserData();

    if (!mounted) return;
    Navigator.pop(context); // Fermer le loader

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }
}
