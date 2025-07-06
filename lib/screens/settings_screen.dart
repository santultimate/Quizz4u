import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'system';
  String _difficulty = 'normal';
  bool _soundEnabled = true;
  bool _ttsEnabled = true;
  int _timerDuration = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await SettingsService.getThemeMode();
    final difficulty = await SettingsService.getDifficulty();
    final soundEnabled = await SettingsService.isSoundEnabled();
    final ttsEnabled = await SettingsService.isTtsEnabled();
    final timerDuration = await SettingsService.getTimerDuration();

    setState(() {
      _themeMode = themeMode;
      _difficulty = difficulty;
      _soundEnabled = soundEnabled;
      _ttsEnabled = ttsEnabled;
      _timerDuration = timerDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(fontFamily: 'Signatra', fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section Apparence
          _buildSection(
            title: 'Apparence',
            icon: Icons.palette,
            children: [
              _buildListTile(
                title: 'Thème',
                subtitle: _getThemeModeText(_themeMode),
                leading: const Icon(Icons.brightness_6),
                onTap: _showThemeDialog,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section Jeu
          _buildSection(
            title: 'Jeu',
            icon: Icons.games,
            children: [
              _buildListTile(
                title: 'Difficulté',
                subtitle: _getDifficultyText(_difficulty),
                leading: const Icon(Icons.trending_up),
                onTap: _showDifficultyDialog,
              ),
              _buildListTile(
                title: 'Durée du timer',
                subtitle: '$_timerDuration secondes',
                leading: const Icon(Icons.timer),
                onTap: _showTimerDialog,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section Audio
          _buildSection(
            title: 'Audio',
            icon: Icons.volume_up,
            children: [
              SwitchListTile(
                title: const Text('Sons'),
                subtitle: const Text('Activer les effets sonores'),
                secondary: const Icon(Icons.volume_up),
                value: _soundEnabled,
                onChanged: (value) async {
                  await SettingsService.setSoundEnabled(value);
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Lecture vocale'),
                subtitle: const Text('Lire les questions à voix haute'),
                secondary: const Icon(Icons.record_voice_over),
                value: _ttsEnabled,
                onChanged: (value) async {
                  await SettingsService.setTtsEnabled(value);
                  setState(() {
                    _ttsEnabled = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section À propos
          _buildSection(
            title: 'Application',
            icon: Icons.info,
            children: [
              _buildListTile(
                title: 'À propos',
                subtitle: 'Informations et support',
                leading: const Icon(Icons.info_outline),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              _buildListTile(
                title: 'Version',
                subtitle: '1.0.0',
                leading: const Icon(Icons.app_settings_alt),
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Icon leading,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: leading,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  String _getThemeModeText(String mode) {
    switch (mode) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      case 'system':
        return 'Système';
      default:
        return 'Système';
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'facile':
        return 'Facile (20s)';
      case 'normal':
        return 'Normal (15s)';
      case 'difficile':
        return 'Difficile (10s)';
      default:
        return 'Normal (15s)';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choisir le thème'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Clair'),
                  value: 'light',
                  groupValue: _themeMode,
                  onChanged: (value) async {
                    await SettingsService.setThemeMode(value!);
                    setState(() {
                      _themeMode = value;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Sombre'),
                  value: 'dark',
                  groupValue: _themeMode,
                  onChanged: (value) async {
                    await SettingsService.setThemeMode(value!);
                    setState(() {
                      _themeMode = value;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Système'),
                  value: 'system',
                  groupValue: _themeMode,
                  onChanged: (value) async {
                    await SettingsService.setThemeMode(value!);
                    setState(() {
                      _themeMode = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choisir la difficulté'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Facile'),
                  subtitle: const Text('20 secondes par question'),
                  value: 'facile',
                  groupValue: _difficulty,
                  onChanged: (value) async {
                    await SettingsService.setDifficulty(value!);
                    setState(() {
                      _difficulty = value;
                      _timerDuration =
                          SettingsService.getTimerDurationForDifficulty(value);
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Normal'),
                  subtitle: const Text('15 secondes par question'),
                  value: 'normal',
                  groupValue: _difficulty,
                  onChanged: (value) async {
                    await SettingsService.setDifficulty(value!);
                    setState(() {
                      _difficulty = value;
                      _timerDuration =
                          SettingsService.getTimerDurationForDifficulty(value);
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Difficile'),
                  subtitle: const Text('10 secondes par question'),
                  value: 'difficile',
                  groupValue: _difficulty,
                  onChanged: (value) async {
                    await SettingsService.setDifficulty(value!);
                    setState(() {
                      _difficulty = value;
                      _timerDuration =
                          SettingsService.getTimerDurationForDifficulty(value);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showTimerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Durée du timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choisissez la durée du timer en secondes :'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      [10, 15, 20, 30].map((seconds) {
                        return ElevatedButton(
                          onPressed: () async {
                            await SettingsService.setTimerDuration(seconds);
                            setState(() {
                              _timerDuration = seconds;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _timerDuration == seconds
                                    ? Colors.purple
                                    : Colors.grey,
                          ),
                          child: Text('${seconds}s'),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
    );
  }
}
