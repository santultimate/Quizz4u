import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../services/translation_service.dart';
import '../services/question_translation_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final int? currentScore;
  final int? totalQuestions;
  final String? category;
  final double? accuracy;

  const LeaderboardScreen({
    super.key,
    this.currentScore,
    this.totalQuestions,
    this.category,
    this.accuracy,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Record> records = [];
  bool isLoading = true;
  String? playerName;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      isLoading = true;
    });

    final loadedRecords = await LeaderboardService.getRecords();

    setState(() {
      records = loadedRecords;
      isLoading = false;
    });
  }

  Future<void> _saveRecord() async {
    if (widget.currentScore == null ||
        widget.totalQuestions == null ||
        widget.category == null ||
        widget.accuracy == null) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre nom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await LeaderboardService.saveRecord(
      playerName: name,
      score: widget.currentScore!,
      totalQuestions: widget.totalQuestions!,
      category: widget.category!,
      accuracy: widget.accuracy!,
    );

    if (success) {
      setState(() {
        playerName = name;
      });

      await _loadRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('record_saved_success')),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareScore() async {
    if (widget.currentScore == null ||
        widget.totalQuestions == null ||
        widget.category == null ||
        widget.accuracy == null) {
      return;
    }

    await LeaderboardService.shareScore(
      playerName: playerName ?? 'Joueur',
      score: widget.currentScore!,
      totalQuestions: widget.totalQuestions!,
      category: widget.category!,
      accuracy: widget.accuracy!,
    );
  }

  Future<void> _shareTop3() async {
    await LeaderboardService.shareTop3Records();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        title: Text('🏆 ${TranslationService.translate('records')}'),
        backgroundColor: Colors.purple[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTop3,
            tooltip: TranslationService.translate('share_top_3'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section pour sauvegarder le score actuel
            if (widget.currentScore != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎯 ${TranslationService.translate('your_score')}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.currentScore} pts',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    if (widget.accuracy != null &&
                        widget.totalQuestions != null)
                      Text(
                        '${(widget.accuracy! * widget.totalQuestions!).round()}/${widget.totalQuestions} (${(widget.accuracy! * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${TranslationService.translate('category')}: ${widget.category != null ? QuestionTranslationService.translateCategory(widget.category!) : ""}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ pour entrer le nom
                    if (playerName == null) ...[
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                              TranslationService.translate('enter_your_name'),
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveRecord,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                TranslationService.translate('save'),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _shareScore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                TranslationService.translate('share'),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '${TranslationService.translate('saved_by')}: $playerName',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _shareScore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          TranslationService.translate('share_my_score'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Titre des records
            Text(
              '🏆 ${TranslationService.translate('best_records')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Liste des records
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : records.isEmpty
                      ? Center(
                          child: Text(
                            TranslationService.translate('no_records_yet'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            // ✅ Calcul correct : accuracy est déjà le pourcentage de bonnes réponses
                            final accuracyPercentage =
                                (record.accuracy * 100).toStringAsFixed(1);
                            final correctAnswers =
                                (record.accuracy * record.totalQuestions)
                                    .round();
                            final date = record.date.toString().split(' ')[0];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getMedalColor(index).withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Médaille
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getMedalColor(index),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Informations du record
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.playerName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${record.score} pts • $correctAnswers/${record.totalQuestions} ($accuracyPercentage%)',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${record.category} • $date',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bouton partager
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      LeaderboardService.shareScore(
                                        playerName: record.playerName,
                                        score: record.score,
                                        totalQuestions: record.totalQuestions,
                                        category: record.category,
                                        accuracy: record.accuracy,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Or
      case 1:
        return Colors.grey[400]!; // Argent
      case 2:
        return Colors.orange[700]!; // Bronze
      default:
        return Colors.purple[300]!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
