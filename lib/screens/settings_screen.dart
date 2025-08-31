import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';
import '../services/unified_audio_service.dart';
// import '../services/ad_service.dart';
import '../services/notification_service.dart';
import 'statistics_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'système';
  bool _soundEnabled = true;
  bool _ttsEnabled = true;
  int _timerDuration = 15;
  bool _backgroundMusicEnabled = true;
  bool _animationsEnabled = true;
  bool _adsEnabled = true;
  double _masterVolume = 1.0;
  double _backgroundVolume = 0.3;
  double _effectVolume = 0.7;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _difficultyLevel = 'moyen';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await SettingsService.getThemeMode();
    final soundEnabled = await SettingsService.isSoundEnabled();
    final ttsEnabled = await SettingsService.isTtsEnabled();
    final timerDuration = await SettingsService.getTimerDuration();
    final backgroundMusicEnabled =
        await SettingsService.isBackgroundMusicEnabled();
    final animationsEnabled = await SettingsService.areAnimationsEnabled();
    final vibrationEnabled = await SettingsService.isVibrationEnabled();
    final adsEnabled = await SettingsService.isAdsEnabled();
    final notificationsEnabled = await SettingsService.isNotificationsEnabled();
    final masterVolume = await SettingsService.getMasterVolume();
    final backgroundVolume = await SettingsService.getBackgroundVolume();
    final effectVolume = await SettingsService.getEffectVolume();

    print('[Settings] Chargement des paramètres:');
    print('[Settings] - Sons: $soundEnabled');
    print('[Settings] - TTS: $ttsEnabled');
    print('[Settings] - Musique de fond: $backgroundMusicEnabled');
    print('[Settings] - Animations: $animationsEnabled');
    print('[Settings] - Vibrations: $vibrationEnabled');
    print('[Settings] - Publicités: $adsEnabled');
    print('[Settings] - Notifications: $notificationsEnabled');
    print('[Settings] - Volume principal: $masterVolume');
    print('[Settings] - Volume musique: $backgroundVolume');
    print('[Settings] - Volume effets: $effectVolume');

    setState(() {
      _themeMode = themeMode;
      _soundEnabled = soundEnabled;
      _ttsEnabled = ttsEnabled;
      _timerDuration = timerDuration;
      _backgroundMusicEnabled = backgroundMusicEnabled;
      _animationsEnabled = animationsEnabled;
      _vibrationEnabled = vibrationEnabled;
      _adsEnabled = adsEnabled;
      _notificationsEnabled = notificationsEnabled;
      _masterVolume = masterVolume;
      _backgroundVolume = backgroundVolume;
      _effectVolume = effectVolume;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.purple[700],
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Audio
            _buildSectionHeader('🎵 Audio', Icons.volume_up),
            _buildSwitchTile(
              'Sons d\'effet',
              'Activer les sons de réponse',
              _soundEnabled,
              (value) async {
                setState(() => _soundEnabled = value);
                await SettingsService.setSoundEnabled(value);
                await UnifiedAudioService.instance
                    .setSoundEffectsEnabled(value);
              },
            ),
            _buildSwitchTile(
              'Musique de fond',
              'Activer la musique d\'ambiance',
              _backgroundMusicEnabled,
              (value) async {
                setState(() => _backgroundMusicEnabled = value);
                await SettingsService.setBackgroundMusicEnabled(value);
                await UnifiedAudioService.instance
                    .setBackgroundMusicEnabled(value);
              },
            ),
            _buildSwitchTile(
              'Synthèse vocale (TTS)',
              'Lire les questions à voix haute',
              _ttsEnabled,
              (value) async {
                setState(() => _ttsEnabled = value);
                await SettingsService.setTtsEnabled(value);
              },
            ),

            const SizedBox(height: 20),

            // Contrôles de volume
            _buildVolumeSlider(
              'Volume principal',
              _masterVolume,
              (value) async {
                setState(() => _masterVolume = value);
                await SettingsService.setMasterVolume(value);
                await UnifiedAudioService.instance.setMasterVolume(value);
              },
            ),
            _buildVolumeSlider(
              'Volume musique',
              _backgroundVolume,
              (value) async {
                setState(() => _backgroundVolume = value);
                await SettingsService.setBackgroundVolume(value);
                await UnifiedAudioService.instance.setBackgroundVolume(value);
              },
            ),
            _buildVolumeSlider(
              'Volume effets',
              _effectVolume,
              (value) async {
                setState(() => _effectVolume = value);
                await SettingsService.setEffectVolume(value);
                await UnifiedAudioService.instance.setEffectsVolume(value);
              },
            ),

            const SizedBox(height: 30),

            // Section Jeu
            _buildSectionHeader('🎮 Jeu', Icons.games),
            _buildDropdownTile(
              'Durée du timer',
              'Temps pour répondre aux questions',
              _timerDuration.toString(),
              ['10', '15', '20', '30', '45', '60'],
              (value) async {
                setState(() => _timerDuration = int.parse(value));
                await SettingsService.setTimerDuration(int.parse(value));
              },
            ),
            _buildDropdownTile(
              'Niveau de difficulté',
              'Complexité des questions',
              _difficultyLevel,
              ['facile', 'moyen', 'difficile', 'expert'],
              (value) async {
                setState(() => _difficultyLevel = value);
                await SettingsService.setDifficultyLevel(value);
              },
            ),

            const SizedBox(height: 30),

            // Section Interface
            _buildSectionHeader('🎨 Interface', Icons.palette),
            _buildSwitchTile(
              'Animations',
              'Activer les animations et effets visuels',
              _animationsEnabled,
              (value) async {
                setState(() => _animationsEnabled = value);
                await SettingsService.setAnimationsEnabled(value);
              },
            ),
            _buildSwitchTile(
              'Vibrations',
              'Vibrations lors des interactions',
              _vibrationEnabled,
              (value) async {
                setState(() => _vibrationEnabled = value);
                await SettingsService.setVibrationEnabled(value);
              },
            ),
            _buildDropdownTile(
              'Thème',
              'Apparence de l\'application',
              _themeMode,
              ['clair', 'sombre', 'système'],
              (value) async {
                setState(() => _themeMode = value);
                await SettingsService.setThemeMode(value);
                widget.onThemeChanged?.call();
              },
            ),

            const SizedBox(height: 30),

            // Section Publicités
            _buildSectionHeader('📺 Publicités', Icons.ads_click),
            _buildSwitchTile(
              'Publicités',
              'Afficher les publicités (aide au développement)',
              _adsEnabled,
              (value) async {
                setState(() => _adsEnabled = value);
                await SettingsService.setAdsEnabled(value);
              },
            ),

            const SizedBox(height: 30),

            // Section Notifications
            _buildSectionHeader('🔔 Notifications', Icons.notifications),
            _buildSwitchTile(
              'Notifications',
              'Recevoir des rappels et nouveautés',
              _notificationsEnabled,
              (value) async {
                setState(() => _notificationsEnabled = value);
                await SettingsService.setNotificationsEnabled(value);
              },
            ),
            _buildActionTile(
              'Test Notifications',
              'Tester les notifications push',
              Icons.notification_add,
              () => _testNotifications(),
            ),

            const SizedBox(height: 30),

            // Section Statistiques
            _buildSectionHeader('📊 Statistiques', Icons.analytics),
            _buildActionTile(
              'Voir mes performances',
              'Statistiques détaillées et progression',
              Icons.analytics,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Section À propos
            _buildSectionHeader('ℹ️ À propos', Icons.info),
            _buildStaticInfoTile(
              'Version',
              '2.0.5',
              Icons.app_settings_alt,
            ),
            _buildStaticInfoTile(
              'Développeur',
              'YACOUBA SANTARA',
              Icons.person,
            ),
            _buildStaticInfoTile(
              'Contact',
              'support@quizz4u.com',
              Icons.email,
            ),
            _buildStaticInfoTile(
              'Orange Money',
              '+223 76 03 91 92',
              Icons.payment,
            ),
            _buildActionTile(
              'Politique de confidentialité',
              'Lire notre politique de confidentialité',
              Icons.privacy_tip,
              () => _showPrivacyPolicy(),
            ),
            _buildActionTile(
              'Conditions d\'utilisation',
              'Lire nos conditions d\'utilisation',
              Icons.description,
              () => _showTermsOfService(),
            ),

            const SizedBox(height: 30),

            // Section Soutien
            _buildSectionHeader('💝 Soutenir le Projet', Icons.favorite),
            _buildActionTile(
              'Faire un don',
              'Soutenez le développement avec Orange Money',
              Icons.payment,
              () => _showDonationDialog(),
              color: Colors.orange,
            ),
            _buildStaticInfoTile(
              'Numéro Orange Money',
              '+223 76 03 91 92',
              Icons.phone_android,
            ),

            const SizedBox(height: 30),

            // Section Réinitialisation
            _buildSectionHeader('🔄 Réinitialisation', Icons.refresh),
            _buildActionTile(
              'Réinitialiser les paramètres',
              'Remettre tous les paramètres par défaut',
              Icons.restore,
              () => _showResetDialog(),
              color: Colors.orange,
            ),
            _buildActionTile(
              'Effacer les données',
              'Supprimer toutes les données sauvegardées',
              Icons.delete_forever,
              () => _showClearDataDialog(),
              color: Colors.red,
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.2)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'Raleway',
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green[300],
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[600],
      ),
    );
  }

  Widget _buildVolumeSlider(
      String title, double value, Function(double) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green[300],
            inactiveColor: Colors.grey[600],
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(value * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value,
      List<String> options, Function(String) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'Raleway',
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String subtitle, String buttonText, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'Raleway',
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'Raleway',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les paramètres'),
        content: const Text(
            'Êtes-vous sûr de vouloir remettre tous les paramètres par défaut ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer les données'),
        content: const Text(
            'Cette action supprimera définitivement toutes vos données (scores, progression, paramètres). Êtes-vous sûr ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    // Réinitialiser tous les paramètres
    await SettingsService.resetAllSettings();
    await UnifiedAudioService.instance.resetSettings();

    // Recharger les paramètres
    await _loadSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres réinitialisés avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearAllData() async {
    // Effacer toutes les données
    await SettingsService.clearAllData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les données ont été effacées'),
        backgroundColor: Colors.red,
      ),
    );

    // Redémarrer l'app
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _buildStaticInfoTile(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'Raleway',
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() async {
    final Uri url = Uri.parse('https://quizz4u.site/');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Politique de confidentialité'),
          content: const SingleChildScrollView(
            child: Text(
              'Cette application collecte et utilise vos données personnelles pour :\n\n'
              '• Améliorer votre expérience de jeu\n'
              '• Sauvegarder vos scores et progression\n'
              '• Personnaliser le contenu\n'
              '• Afficher des publicités pertinentes\n\n'
              'Vos données sont protégées et ne sont jamais vendues à des tiers.\n\n'
              'Pour plus d\'informations, visitez :\n'
              'https://quizz4u.site/\n\n'
              'Ou contactez-nous à support@quizz4u.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'En utilisant cette application, vous acceptez :\n\n'
            '• D\'utiliser l\'application de manière responsable\n'
            '• De ne pas tricher ou utiliser des outils tiers\n'
            '• De respecter les autres utilisateurs\n'
            '• Que nous pouvez modifier ces conditions\n\n'
            'L\'application est fournie "en l\'état" sans garantie.\n\n'
            'Soutenez le projet :\n'
            'Orange Money : +223 76 03 91 92\n\n'
            'Pour toute question, contactez-nous à support@quizz4u.com\n'
            'Plus d\'infos : quizz4u.site',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDonationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💝 Soutenir le Projet'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Merci de soutenir le développement de Quizz4U !\n',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Votre don nous aide à :\n'
                '• Améliorer l\'application\n'
                '• Ajouter de nouvelles fonctionnalités\n'
                '• Maintenir les serveurs\n'
                '• Développer de nouveaux quiz\n\n',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '📱 Orange Money :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                '+223 76 03 91 92\n\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              const Text(
                'Développeur : YACOUBA SANTARA\n\n',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://quizz4u.site/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  '🌐 Plus d\'informations : quizz4u.site',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _testNotifications() async {
    try {
      await NotificationService.instance.sendTestNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notification de test envoyée !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
