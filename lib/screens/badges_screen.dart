import 'package:flutter/material.dart';
import '../services/badge_service.dart';
// import '../services/badge_notification_service.dart';
import '../models/user_progress.dart';

class BadgesScreen extends StatefulWidget {
  final UserProgress userProgress;

  const BadgesScreen({
    super.key,
    required this.userProgress,
  });

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<Map<String, dynamic>> allBadges = [];
  bool showUnlockedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  void _loadBadges() {
    allBadges = BadgeService.getAllAvailableBadges(widget.userProgress);
    setState(() {});
  }

  List<Map<String, dynamic>> get filteredBadges {
    if (showUnlockedOnly) {
      return allBadges.where((badge) => badge['isUnlocked'] == true).toList();
    }
    return allBadges;
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount =
        allBadges.where((badge) => badge['isUnlocked'] == true).length;
    final totalCount = allBadges.length;

    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        title: const Text('🏆 Badges'),
        backgroundColor: Colors.purple[700],
        actions: [
          // Bouton pour filtrer
          IconButton(
            icon: Icon(
              showUnlockedOnly ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showUnlockedOnly = !showUnlockedOnly;
              });
            },
            tooltip: showUnlockedOnly
                ? 'Voir tous les badges'
                : 'Voir uniquement les débloqués',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Progression des Badges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Débloqués',
                      '$unlockedCount',
                      Colors.green,
                      Icons.check_circle,
                    ),
                    _buildStatCard(
                      'Total',
                      '$totalCount',
                      Colors.blue,
                      Icons.emoji_events,
                    ),
                    _buildStatCard(
                      'Progression',
                      '${((unlockedCount / totalCount) * 100).round()}%',
                      Colors.orange,
                      Icons.trending_up,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Barre de progression
                LinearProgressIndicator(
                  value: unlockedCount / totalCount,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ],
            ),
          ),

          // Liste des badges
          Expanded(
            child: filteredBadges.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          showUnlockedOnly
                              ? 'Aucun badge débloqué'
                              : 'Aucun badge disponible',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showUnlockedOnly
                              ? 'Jouez pour débloquer vos premiers badges !'
                              : 'Les badges apparaîtront ici',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBadges.length,
                    itemBuilder: (context, index) {
                      final badge = filteredBadges[index];
                      return _buildBadgeCard(badge);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final isUnlocked = badge['isUnlocked'] == true;
    final badgeId = _getBadgeId(badge);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBadgeDetails(badge, badgeId),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked
                    ? Colors.amber.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Icône du badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isUnlocked ? Colors.amber : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      badge['icon'] ?? '🏆',
                      style: TextStyle(
                        fontSize: 28,
                        color: isUnlocked ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Informations du badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge['name'] ?? 'Badge Mystérieux',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge['description'] ?? 'Badge obtenu !',
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnlocked
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Condition: ${BadgeService.getBadgeRequirement(badgeId)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Indicateur de statut
                Column(
                  children: [
                    if (isUnlocked)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      )
                    else
                      Icon(
                        Icons.lock,
                        color: Colors.grey.withOpacity(0.6),
                        size: 24,
                      ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getBadgeId(Map<String, dynamic> badge) {
    // Reconstruire l'ID du badge basé sur les informations disponibles
    final category = badge['category'];
    final type = badge['type'];

    if (category != null && type != null) {
      if (type == 'perfect_score') {
        if (badge['description'].contains('10/10')) {
          return '${category}_perfect_10';
        } else if (badge['description'].contains('20/20')) {
          return '${category}_perfect_20';
        }
      } else if (type == 'accuracy') {
        return '${category}_expert_90';
      }
    }

    // Pour les badges spéciaux, utiliser le nom comme ID
    return badge['name']?.toString().toLowerCase().replaceAll(' ', '_') ??
        'unknown';
  }

  void _showBadgeDetails(Map<String, dynamic> badge, String badgeId) {
    final isUnlocked = badge['isUnlocked'] == true;
    final requirement = BadgeService.getBadgeRequirement(badgeId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[100],
        title: Row(
          children: [
            Text(
              badge['icon'] ?? '🏆',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge['name'] ?? 'Badge Mystérieux',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge['description'] ?? 'Badge obtenu !',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUnlocked ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnlocked ? '✅ Badge Débloqué' : '🔒 Badge Verrouillé',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Condition: $requirement',
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
