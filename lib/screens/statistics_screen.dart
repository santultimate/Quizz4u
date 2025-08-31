import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';
import '../services/leaderboard_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, dynamic> stats = {};
  List<Record> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Charger les statistiques de progression
      final progressStats = await ProgressService.getStats();

      // Charger les records
      final loadedRecords = await LeaderboardService.getRecords();

      setState(() {
        stats = progressStats;
        records = loadedRecords;
        isLoading = false;
      });
    } catch (e) {
      print('[StatisticsScreen] ❌ Erreur chargement statistiques: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.purple[100],
          title: const Text(
            '⚠️ Réinitialisation Complète',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir réinitialiser TOUTES les données ?\n\n'
            'Cette action supprimera :\n'
            '• Tous les records\n'
            '• Toute la progression\n'
            '• Tous les badges\n'
            '• Toutes les statistiques\n\n'
            'Cette action est IRREVERSIBLE !',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _performReset();
    }
  }

  Future<void> _resetRecordsOnly() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.purple[100],
          title: const Text(
            '🏆 Réinitialiser Records',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer tous les records ?\n\n'
            'Cette action supprimera :\n'
            '• Tous les meilleurs scores\n'
            '• Tous les noms des joueurs\n\n'
            'Cette action est IRREVERSIBLE !',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer Records'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await LeaderboardService.clearAllRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Tous les records ont été supprimés'),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadStatistics();
    }
  }

  Future<void> _resetProgressOnly() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.purple[100],
          title: const Text(
            '📊 Réinitialiser Progression',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir réinitialiser toute la progression ?\n\n'
            'Cette action supprimera :\n'
            '• Tous les niveaux et XP\n'
            '• Tous les badges\n'
            '• Toutes les statistiques de jeu\n\n'
            'Cette action est IRREVERSIBLE !',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réinitialiser Progression'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ProgressService.resetProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Toute la progression a été réinitialisée'),
          backgroundColor: Colors.blue,
        ),
      );
      await _loadStatistics();
    }
  }

  Future<void> _performReset() async {
    try {
      // Réinitialiser les records
      await LeaderboardService.clearAllRecords();

      // Réinitialiser la progression
      await ProgressService.resetProgress();

      // Réinitialiser les paramètres
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Toutes les données ont été réinitialisées'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadStatistics();
    } catch (e) {
      print('[StatisticsScreen] ❌ Erreur réinitialisation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de la réinitialisation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        title: const Text('📊 Statistiques'),
        backgroundColor: Colors.purple[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre principal
                  const Text(
                    '📈 Statistiques de Jeu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistiques de progression
                  if (stats.isNotEmpty) ...[
                    const Text(
                      '🎯 Progression',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Niveau Actuel',
                      '${stats['level'] ?? 1}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Points d\'Expérience',
                      '${stats['xp'] ?? 0}',
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildStatCard(
                      'Parties Jouées',
                      '${stats['gamesPlayed'] ?? 0}',
                      Icons.games,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Questions Répondues',
                      '${stats['questionsAnswered'] ?? 0}',
                      Icons.quiz,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Réponses Correctes',
                      '${stats['correctAnswers'] ?? 0}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Précision Moyenne',
                      '${stats['accuracy'] != null ? (stats['accuracy'] * 100).toStringAsFixed(1) : '0.0'}%',
                      Icons.analytics,
                      Colors.orange,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Statistiques des records
                  const Text(
                    '🏆 Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildStatCard(
                    'Total Records',
                    '${records.length}',
                    Icons.emoji_events,
                    Colors.amber,
                  ),

                  if (records.isNotEmpty) ...[
                    _buildStatCard(
                      'Meilleur Score',
                      '${records.first.score}/${records.first.totalQuestions}',
                      Icons.workspace_premium,
                      Colors.amber,
                    ),
                    _buildStatCard(
                      'Joueur le Plus Actif',
                      records.first.playerName,
                      Icons.person,
                      Colors.cyan,
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Boutons de réinitialisation
                  const Text(
                    '⚙️ Gestion des Données',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton réinitialiser records seulement
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: _resetRecordsOnly,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Supprimer Tous les Records'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  // Bouton réinitialiser progression seulement
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: _resetProgressOnly,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réinitialiser Progression'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  // Bouton réinitialisation complète
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: _resetAllData,
                      icon: const Icon(Icons.warning),
                      label: const Text('Réinitialisation Complète'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  // Avertissement
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ Attention',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'La réinitialisation des données est IRREVERSIBLE. '
                          'Assurez-vous de sauvegarder vos données importantes avant de procéder.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
