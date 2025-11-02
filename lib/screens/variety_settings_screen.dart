import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/question_service.dart';
import '../services/translation_service.dart';

class VarietySettingsScreen extends StatefulWidget {
  const VarietySettingsScreen({super.key});

  @override
  State<VarietySettingsScreen> createState() => _VarietySettingsScreenState();
}

class _VarietySettingsScreenState extends State<VarietySettingsScreen> {
  String _selectedStrategy = 'smart';
  String _selectedDifficulty = 'mixed';
  Map<String, Map<String, dynamic>> _categoryStats = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCategoryStats();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedStrategy = prefs.getString('question_strategy') ?? 'smart';
      _selectedDifficulty = prefs.getString('question_difficulty') ?? 'mixed';
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('question_strategy', _selectedStrategy);
    await prefs.setString('question_difficulty', _selectedDifficulty);
  }

  void _loadCategoryStats() {
    List<String> categories = QuestionService.getAvailableCategories();
    Map<String, Map<String, dynamic>> stats = {};

    for (String category in categories) {
      stats[category] = QuestionService.getVarietyStats(category);
    }

    setState(() {
      _categoryStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('variety_of_questions')),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stratégie de sélection
            _buildStrategySection(),
            const SizedBox(height: 24),

            // Niveau de difficulté
            _buildDifficultySection(),
            const SizedBox(height: 24),

            // Statistiques par catégorie
            _buildCategoryStatsSection(),
            const SizedBox(height: 24),

            // Actions
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Stratégie de Sélection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Intelligente'),
              subtitle: const Text('Évite les répétitions récentes'),
              value: 'smart',
              groupValue: _selectedStrategy,
              onChanged: (value) {
                setState(() {
                  _selectedStrategy = value!;
                });
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Rotation Quotidienne'),
              subtitle: const Text('Questions différentes chaque jour'),
              value: 'rotating',
              groupValue: _selectedStrategy,
              onChanged: (value) {
                setState(() {
                  _selectedStrategy = value!;
                });
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Aléatoire'),
              subtitle: const Text('Sélection complètement aléatoire'),
              value: 'random',
              groupValue: _selectedStrategy,
              onChanged: (value) {
                setState(() {
                  _selectedStrategy = value!;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Niveau de Difficulté',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Mixte'),
              subtitle: const Text('Tous niveaux confondus'),
              value: 'mixed',
              groupValue: _selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Facile'),
              subtitle: const Text('Questions courtes et simples'),
              value: 'easy',
              groupValue: _selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Moyen'),
              subtitle: const Text('Questions de difficulté moyenne'),
              value: 'moyen',
              groupValue: _selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Difficile'),
              subtitle: const Text('Questions complexes et détaillées'),
              value: 'hard',
              groupValue: _selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Statistiques par Catégorie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._categoryStats.entries.map((entry) {
              String category = entry.key;
              Map<String, dynamic> stats = entry.value;

              if (stats.isEmpty) return const SizedBox.shrink();

              double varietyPercentage = stats['varietyPercentage'] ?? 0.0;
              int totalQuestions = stats['totalQuestions'] ?? 0;
              int availableQuestions = stats['available'] ?? 0;

              Color varietyColor = varietyPercentage > 70
                  ? Colors.green
                  : varietyPercentage > 40
                      ? Colors.orange
                      : Colors.red;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: varietyPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(varietyColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${varietyPercentage.round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: varietyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$availableQuestions/$totalQuestions questions disponibles',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔄 Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Réinitialiser l\'historique'),
              subtitle: const Text('Permettre toutes les questions'),
              onTap: () => _showResetDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.green),
              title: const Text('Actualiser les statistiques'),
              subtitle: const Text('Mettre à jour les données'),
              onTap: () {
                _loadCategoryStats();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Statistiques actualisées'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('reset_history')),
        content:
            Text(TranslationService.translate('reset_history_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(TranslationService.translate('reset')),
          ),
        ],
      ),
    );
  }

  void _resetAllHistory() {
    List<String> categories = QuestionService.getAvailableCategories();

    for (String category in categories) {
      QuestionService.resetHistoryForCategory(category);
    }

    _loadCategoryStats();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historique réinitialisé pour toutes les catégories'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
