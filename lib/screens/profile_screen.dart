import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/progress_service.dart';
import '../services/badge_service.dart';
// import '../services/ad_service.dart';
import '../models/user_progress.dart';
import 'badges_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les stats quand l'écran devient visible
    _loadStats();
  }

  Future<void> _loadStats() async {
    print('[ProfileScreen] 🔄 Chargement des statistiques...');
    await ProgressService.loadProgress();
    final loadedStats = await ProgressService.getStats();
    setState(() {
      stats = loadedStats;
    });
    print('[ProfileScreen] 📊 Statistiques chargées: $stats');
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('[ProfileScreen] 🔄 Rafraîchissement manuel');
              _loadStats();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec niveau et XP
            _buildHeader(),
            const SizedBox(height: 20),

            // Statistiques principales
            _buildMainStats(),
            const SizedBox(height: 20),

            // Badges
            _buildBadges(),
            const SizedBox(height: 20),

            // Statistiques par catégorie
            _buildCategoryStats(),
            const SizedBox(height: 20),

            // Boutons d'action
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final level = stats['level'] ?? 1;
    final xp = stats['experiencePoints'] ?? 0;
    final xpForNext = stats['xpForNextLevel'] ?? 100;
    final progress = stats['levelProgress'] ?? 0.0;
    final title = ProgressService.getLevelTitle(level);
    final playerName = stats['playerName'] ?? 'Joueur';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar et niveau
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Lottie.asset(
                    'assets/animations/congrats.json',
                    controller: _animationController,
                    repeat: true,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Niveau $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Titre du niveau
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // Nom du joueur
          Text(
            playerName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          // Barre de progression XP
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$xp XP',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${xp + xpForNext} XP',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 8,
                ),
                const SizedBox(height: 5),
                Text(
                  '$xpForNext XP pour le niveau ${level + 1}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Questions',
              '${stats['totalQuestions'] ?? 0}',
              Icons.quiz,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              'Réussite',
              '${(stats['accuracyRate'] ?? 0).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              'Score Total',
              '${stats['totalScore'] ?? 0}',
              Icons.stars,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    final badges = List<String>.from(stats['badges'] ?? []);
    final userProgress = UserProgress.fromMap(stats);
    final badgeStats = BadgeService.getBadgeStats(userProgress);

    if (badges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(Icons.emoji_events, size: 50, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                'Aucun badge encore',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Continuez à jouer pour débloquer des badges !',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${badgeStats['total']} / ${BadgeService.getAllBadges().length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.emoji_events, color: Colors.blue),
                    onPressed: () {
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
          const SizedBox(height: 10),
          // Statistiques des badges
          Row(
            children: [
              _buildBadgeStat(
                  'Catégorie', badgeStats['category'], Colors.green),
              const SizedBox(width: 10),
              _buildBadgeStat(
                  'Difficulté', badgeStats['difficulty'], Colors.orange),
              const SizedBox(width: 10),
              _buildBadgeStat('Spécial', badgeStats['special'], Colors.purple),
            ],
          ),
          const SizedBox(height: 15),
          // Badges organisés par type
          _buildBadgeSection(
              'Badges par Catégorie',
              badges
                  .where(
                      (b) => b.contains('_perfect_') || b.contains('_expert_'))
                  .toList()),
          const SizedBox(height: 10),
          _buildBadgeSection('Badges de Difficulté',
              badges.where((b) => b.contains('_master')).toList()),
          const SizedBox(height: 10),
          _buildBadgeSection(
              'Badges Spéciaux',
              badges
                  .where((b) =>
                      !b.contains('_perfect_') &&
                      !b.contains('_expert_') &&
                      !b.contains('_master'))
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildBadgeStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeSection(String title, List<String> sectionBadges) {
    if (sectionBadges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sectionBadges.map((badge) => _buildBadge(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(String badge) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            ProgressService.getBadgeIcon(badge),
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 5),
          Text(
            ProgressService.getBadgeName(badge),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats() {
    final categoryStats = stats['categoryStats'] as Map<String, dynamic>? ?? {};

    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance par Catégorie',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ...categoryStats.entries.map((entry) => _buildCategoryStat(
              entry.key, entry.value as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildCategoryStat(String category, Map<String, dynamic> stats) {
    int correct = stats['correct'] ?? 0;
    int total = stats['total'] ?? 0;
    double accuracy = stats['accuracy'] ?? 0.0;
    int wrong = stats['wrong'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$correct bonnes réponses',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                '$wrong mauvaises réponses',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'Total: $total',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Badges'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Rafraîchir les statistiques
                    await _loadStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statistiques mises à jour'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Statistiques'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la Progression'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser toutes vos statistiques ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ProgressService.resetProgress();
      _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progression réinitialisée'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
