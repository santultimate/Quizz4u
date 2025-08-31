import 'package:flutter/material.dart';
import 'badge_service.dart';

class BadgeNotificationService {
  static final BadgeNotificationService _instance =
      BadgeNotificationService._internal();
  factory BadgeNotificationService() => _instance;
  BadgeNotificationService._internal();

  // Afficher une notification de badge avec animation
  static Future<void> showBadgeNotification(
      BuildContext context, String badgeId,
      {bool showDialog = true}) async {
    final badgeInfo = BadgeService.getBadgeInfo(badgeId);
    if (badgeInfo == null) return;

    print(
        '[BadgeNotificationService] 🏆 Notification badge: ${badgeInfo['name']}');

    if (showDialog) {
      await _showBadgeDialog(context, badgeInfo);
    }
  }

  // Afficher plusieurs badges avec animation séquentielle
  static Future<void> showMultipleBadgeNotifications(
    BuildContext context,
    List<String> badgeIds,
  ) async {
    if (badgeIds.isEmpty) return;

    print(
        '[BadgeNotificationService] 🏆 Notifications multiples: ${badgeIds.length} badges');

    // Afficher le premier badge immédiatement
    await showBadgeNotification(context, badgeIds.first);

    // Afficher les autres badges avec un délai
    for (int i = 1; i < badgeIds.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      await showBadgeNotification(context, badgeIds[i]);
    }
  }

  // Dialog de notification de badge avec animation
  static Future<void> _showBadgeDialog(
    BuildContext context,
    Map<String, dynamic> badgeInfo,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BadgeNotificationDialog(badgeInfo: badgeInfo);
      },
    );
  }

  // Widget de notification de badge avec animation
  static Widget buildBadgeNotificationWidget(Map<String, dynamic> badgeInfo,
      {bool isUnlocked = true}) {
    return BadgeNotificationWidget(
      badgeInfo: badgeInfo,
      isUnlocked: isUnlocked,
    );
  }
}

// Dialog de notification de badge
class BadgeNotificationDialog extends StatefulWidget {
  final Map<String, dynamic> badgeInfo;

  const BadgeNotificationDialog({
    super.key,
    required this.badgeInfo,
  });

  @override
  State<BadgeNotificationDialog> createState() =>
      _BadgeNotificationDialogState();
}

class _BadgeNotificationDialogState extends State<BadgeNotificationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _rotateController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade600,
                    Colors.red.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône du badge avec rotation
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.badgeInfo['icon'] ?? '🏆',
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Titre du badge
                  Text(
                    '🏆 NOUVEAU BADGE !',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nom du badge
                  Text(
                    widget.badgeInfo['name'] ?? 'Badge Mystérieux',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Description du badge
                  Text(
                    widget.badgeInfo['description'] ?? 'Badge obtenu !',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Bouton de fermeture
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget de badge pour l'affichage dans les listes
class BadgeNotificationWidget extends StatelessWidget {
  final Map<String, dynamic> badgeInfo;
  final bool isUnlocked;

  const BadgeNotificationWidget({
    super.key,
    required this.badgeInfo,
    this.isUnlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isUnlocked ? Colors.amber : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                badgeInfo['icon'] ?? '🏆',
                style: TextStyle(
                  fontSize: 24,
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
                  badgeInfo['name'] ?? 'Badge Mystérieux',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badgeInfo['description'] ?? 'Badge obtenu !',
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
                    'Condition: ${badgeInfo['requirement'] ?? 'Non spécifiée'}',
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
          if (isUnlocked)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
        ],
      ),
    );
  }
}
