import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/premium_benefits_controller.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'enhanced_premium_screen.dart';

/// 👥 Écran Mode Multijoueur (Premium uniquement)
class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen>
    with TickerProviderStateMixin {
  bool _isPremium = false;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkPremiumStatus();
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

  Future<void> _checkPremiumStatus() async {
    final multiplayerAccess =
        await PremiumBenefitsController.getMultiplayerAccess();

    setState(() {
      _isPremium = multiplayerAccess['enabled'];
      _isLoading = false;
    });
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
          '👥 Mode Multijoueur',
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: _isPremium
                  ? _buildMultiplayerContent()
                  : _buildLockedContent(),
            ),
    );
  }

  Widget _buildMultiplayerContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bannière Premium
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.black, size: 30),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '👑 Mode Premium activé',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Options de jeu multijoueur
          _buildGameModeCard(
            title: '⚡ Défi Rapide',
            description: 'Affrontez un adversaire aléatoire en 10 questions',
            color: Colors.orange,
            onTap: () => _showComingSoon(),
          ),
          SizedBox(height: AppSpacing.md),

          _buildGameModeCard(
            title: '👫 Partie entre amis',
            description: 'Créez une partie privée et invitez vos amis',
            color: Colors.blue,
            onTap: () => _showComingSoon(),
          ),
          SizedBox(height: AppSpacing.md),

          _buildGameModeCard(
            title: '🏆 Tournoi',
            description: 'Participez aux tournois hebdomadaires',
            color: Colors.green,
            onTap: () => _showComingSoon(),
          ),
          SizedBox(height: AppSpacing.md),

          _buildGameModeCard(
            title: '🌍 Classement Mondial',
            description: 'Consultez le classement des meilleurs joueurs',
            color: Colors.purple,
            onTap: () => _showComingSoon(),
          ),
          SizedBox(height: AppSpacing.xl),

          // Statistiques multijoueur
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
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
            '📊 Vos Statistiques Multijoueur',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildStatRow('Parties jouées', '0', Icons.sports_esports),
          _buildStatRow('Victoires', '0', Icons.emoji_events),
          _buildStatRow('Taux de victoire', '0%', Icons.trending_up),
          _buildStatRow('Classement mondial', 'N/A', Icons.leaderboard),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
              '🔒 Mode Multijoueur',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Le mode multijoueur est réservé aux membres Premium',
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

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 Bientôt disponible'),
        content: const Text(
          'Cette fonctionnalité est en cours de développement et sera disponible très prochainement !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
