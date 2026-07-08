import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../services/unified_audio_service_optimized.dart'; // ⚡ OPTIMISÉ
import '../services/localization_service.dart';
import '../services/translation_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
// import 'statistics_screen.dart'; // Temporairement désactivé

/// Widget d'animation combinée (Fade + Slide)
class FadeSlideTransition extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final Offset offset;
  final int delay;

  const FadeSlideTransition({
    super.key,
    required this.controller,
    required this.child,
    this.offset = const Offset(0, 20),
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay / 1000,
        1.0,
        curve: Curves.easeInOut,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: Transform.translate(
        offset: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(animation).value,
        child: child,
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  String _themeMode = 'système';
  bool _soundEnabled = true;
  bool _ttsEnabled = true;
  int _timerDuration = 15;
  bool _backgroundMusicEnabled = true;
  bool _animationsEnabled = true;
  double _masterVolume = 1.0;
  double _backgroundVolume = 0.3;
  double _effectVolume = 0.7;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _difficultyLevel = 'moyen';
  String _selectedLanguage = 'fr';
  bool _isLoading = true;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final themeMode = await SettingsService.getThemeMode();
    final soundEnabled = await SettingsService.isSoundEnabled();
    final ttsEnabled = await SettingsService.isTtsEnabled();
    final timerDuration = await SettingsService.getTimerDuration();
    final backgroundMusicEnabled =
        await SettingsService.isBackgroundMusicEnabled();
    final animationsEnabled = await SettingsService.areAnimationsEnabled();
    final vibrationEnabled = await SettingsService.isVibrationEnabled();
    final notificationsEnabled = await SettingsService.isNotificationsEnabled();
    final masterVolume = await SettingsService.getMasterVolume();
    final backgroundVolume = await SettingsService.getBackgroundVolume();
    final effectVolume = await SettingsService.getEffectVolume();
    final selectedLanguage = await LocalizationService.getCurrentLanguage();

    final validThemeModes = ['clair', 'sombre', 'système'];
    final validatedThemeMode =
        validThemeModes.contains(themeMode) ? themeMode : 'système';

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _themeMode = validatedThemeMode;
      _soundEnabled = soundEnabled;
      _ttsEnabled = ttsEnabled;
      _timerDuration = timerDuration;
      _backgroundMusicEnabled = backgroundMusicEnabled;
      _animationsEnabled = animationsEnabled;
      _vibrationEnabled = vibrationEnabled;
      _notificationsEnabled = notificationsEnabled;
      _masterVolume = masterVolume;
      _backgroundVolume = backgroundVolume;
      _effectVolume = effectVolume;
      _selectedLanguage = selectedLanguage;
      _isLoading = false;
    });

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationService.translate('settings_title'),
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Audio
                  FadeSlideTransition(
                    controller: _fadeController,
                    offset: const Offset(0, 20),
                    child: _buildSection(
                      title: TranslationService.translate('audio'),
                      icon: Icons.volume_up_rounded,
                      color: AppColors.info,
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: TranslationService.translate('effect_sounds'),
                          subtitle: TranslationService.translate(
                              'effect_sounds_desc'),
                          value: _soundEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _soundEnabled = value);
                            await SettingsService.setSoundEnabled(value);
                            await UnifiedAudioServiceOptimized.instance
                                .setSoundEnabled(value);
                          },
                          isDark: isDark,
                        ),
                        _buildSwitchTile(
                          title:
                              TranslationService.translate('background_music'),
                          subtitle: TranslationService.translate(
                              'background_music_desc'),
                          value: _backgroundMusicEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _backgroundMusicEnabled = value);
                            await SettingsService.setBackgroundMusicEnabled(
                                value);
                            await UnifiedAudioServiceOptimized.instance
                                .setBackgroundMusicEnabled(value);
                          },
                          isDark: isDark,
                        ),
                        _buildSwitchTile(
                          title: TranslationService.translate('text_to_speech'),
                          subtitle: TranslationService.translate(
                              'text_to_speech_desc'),
                          value: _ttsEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _ttsEnabled = value);
                            await SettingsService.setTtsEnabled(value);
                          },
                          isDark: isDark,
                        ),
                        _buildSlider(
                          label: TranslationService.translate('master_volume'),
                          value: _masterVolume,
                          onChanged: (value) async {
                            setState(() => _masterVolume = value);
                            await SettingsService.setMasterVolume(value);
                            await UnifiedAudioServiceOptimized.instance
                                .setMasterVolume(value);
                          },
                          isDark: isDark,
                        ),
                        _buildSlider(
                          label: TranslationService.translate('music_volume'),
                          value: _backgroundVolume,
                          onChanged: (value) async {
                            setState(() => _backgroundVolume = value);
                            await SettingsService.setBackgroundVolume(value);
                            await UnifiedAudioServiceOptimized.instance
                                .setBackgroundVolume(value);
                          },
                          isDark: isDark,
                        ),
                        _buildSlider(
                          label: TranslationService.translate('effect_volume'),
                          value: _effectVolume,
                          onChanged: (value) async {
                            setState(() => _effectVolume = value);
                            await SettingsService.setEffectVolume(value);
                            await UnifiedAudioServiceOptimized.instance
                                .setEffectVolume(value);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Section Langue
                  FadeSlideTransition(
                    controller: _fadeController,
                    delay: 50,
                    offset: const Offset(0, 20),
                    child: _buildSection(
                      title: TranslationService.translate('language'),
                      icon: Icons.language_rounded,
                      color: AppColors.secondary,
                      isDark: isDark,
                      children: [
                        _buildLanguageSelector(isDark),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Section Jeu
                  FadeSlideTransition(
                    controller: _fadeController,
                    delay: 100,
                    offset: const Offset(0, 20),
                    child: _buildSection(
                      title: TranslationService.translate('game'),
                      icon: Icons.games_rounded,
                      color: AppColors.success,
                      isDark: isDark,
                      children: [
                        _buildDropdownTile(
                          title: TranslationService.translate('timer_duration'),
                          subtitle: TranslationService.translate(
                              'timer_duration_desc'),
                          value: '$_timerDuration',
                          items: ['10', '15', '20', '30', '45', '60'],
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _timerDuration = int.parse(value));
                            await SettingsService.setTimerDuration(
                                int.parse(value));
                          },
                          isDark: isDark,
                        ),
                        _buildDropdownTile(
                          title:
                              TranslationService.translate('difficulty_level'),
                          subtitle: TranslationService.translate(
                              'difficulty_level_desc'),
                          value:
                              _getTranslatedDifficultyLevel(_difficultyLevel),
                          items: [
                            TranslationService.translate('easy'),
                            TranslationService.translate('medium'),
                            TranslationService.translate('hard'),
                            TranslationService.translate('expert'),
                          ],
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            String internalValue =
                                _getInternalDifficultyLevel(value);
                            setState(() => _difficultyLevel = internalValue);
                            await SettingsService.setDifficultyLevel(
                                internalValue);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Section Interface
                  FadeSlideTransition(
                    controller: _fadeController,
                    delay: 150,
                    offset: const Offset(0, 20),
                    child: _buildSection(
                      title: TranslationService.translate('interface'),
                      icon: Icons.palette_rounded,
                      color: AppColors.accent,
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: TranslationService.translate('animations'),
                          subtitle:
                              TranslationService.translate('animations_desc'),
                          value: _animationsEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _animationsEnabled = value);
                            await SettingsService.setAnimationsEnabled(value);
                          },
                          isDark: isDark,
                        ),
                        _buildSwitchTile(
                          title: TranslationService.translate('vibrations'),
                          subtitle:
                              TranslationService.translate('vibrations_desc'),
                          value: _vibrationEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _vibrationEnabled = value);
                            await SettingsService.setVibrationEnabled(value);
                          },
                          isDark: isDark,
                        ),
                        _buildDropdownTile(
                          title: TranslationService.translate('theme'),
                          subtitle: TranslationService.translate('theme_desc'),
                          value: _getTranslatedThemeMode(_themeMode),
                          items: [
                            TranslationService.translate('light_theme'),
                            TranslationService.translate('dark_theme'),
                            TranslationService.translate('system_theme'),
                          ],
                          onChanged: (value) async {
                            HapticFeedback.mediumImpact();
                            String internalValue = _getInternalThemeMode(value);
                            setState(() => _themeMode = internalValue);
                            await SettingsService.setThemeMode(internalValue);
                            widget.onThemeChanged?.call();
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Section Autres
                  FadeSlideTransition(
                    controller: _fadeController,
                    delay: 200,
                    offset: const Offset(0, 20),
                    child: _buildSection(
                      title: TranslationService.translate('other'),
                      icon: Icons.more_horiz_rounded,
                      color: AppColors.warning,
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: TranslationService.translate('notifications'),
                          subtitle: TranslationService.translate(
                              'notifications_desc'),
                          value: _notificationsEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            setState(() => _notificationsEnabled = value);
                            await SettingsService.setNotificationsEnabled(
                                value);
                          },
                          isDark: isDark,
                        ),
                        _buildActionTile(
                          title: TranslationService.translate(
                              'test_notifications'),
                          subtitle: TranslationService.translate(
                              'test_notifications_desc'),
                          icon: Icons.notifications_active_rounded,
                          onTap: _testNotifications,
                          isDark: isDark,
                        ),
                        _buildActionTile(
                          title: TranslationService.translate('statistics'),
                          subtitle: TranslationService.translate(
                              'view_performance_desc'),
                          icon: Icons.analytics_rounded,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            // TODO: Réactiver quand statistics_screen.dart sera corrigé
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(TranslationService.translate(
                                    'coming_soon')),
                                backgroundColor: AppColors.info,
                              ),
                            );
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const StatisticsScreen(),
                            //   ),
                            // );
                          },
                          isDark: isDark,
                        ),
                        _buildActionTile(
                          title:
                              TranslationService.translate('support_project'),
                          subtitle: TranslationService.translate('donate_desc'),
                          icon: Icons.favorite_rounded,
                          onTap: _showDonateDialog,
                          isDark: isDark,
                        ),
                        _buildActionTile(
                          title: TranslationService.translate('about'),
                          subtitle: '${TranslationService.translate('version')} 1.0.0',
                          icon: Icons.info_rounded,
                          onTap: _showAboutDialog,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.success,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Function(double) onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: AppTextStyles.caption),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          underline: const SizedBox.shrink(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSelector(bool isDark) {
    final languages = {
      'fr': '🇫🇷 Français',
      'en': '🇬🇧 English',
      'ar': '🇸🇦 العربية',
      'zh': '🇨🇳 中文',
      'hi': '🇮🇳 हिन्दी',
      'es': '🇪🇸 Español',
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: languages.entries.map((entry) {
          final isSelected = _selectedLanguage == entry.key;
          return GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              setState(() => _selectedLanguage = entry.key);
              await TranslationService.changeLanguage(entry.key);
              // Attendre un peu pour que les streams se propagent
              await Future.delayed(const Duration(milliseconds: 100));
              // Recharger l'écran
              if (mounted) {
                setState(() {});
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8)
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? AppColors.cardDark : Colors.grey[200]),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  width: 1,
                ),
              ),
              child: Text(
                entry.value,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTranslatedDifficultyLevel(String level) {
    switch (level) {
      case 'facile':
        return TranslationService.translate('easy');
      case 'moyen':
        return TranslationService.translate('medium');
      case 'difficile':
        return TranslationService.translate('hard');
      case 'expert':
        return TranslationService.translate('expert');
      default:
        return TranslationService.translate('medium');
    }
  }

  String _getInternalDifficultyLevel(String translated) {
    if (translated == TranslationService.translate('easy')) return 'facile';
    if (translated == TranslationService.translate('medium')) return 'moyen';
    if (translated == TranslationService.translate('hard')) return 'difficile';
    if (translated == TranslationService.translate('expert')) return 'expert';
    return 'moyen';
  }

  String _getTranslatedThemeMode(String mode) {
    switch (mode) {
      case 'clair':
        return TranslationService.translate('light_theme');
      case 'sombre':
        return TranslationService.translate('dark_theme');
      case 'système':
        return TranslationService.translate('system_theme');
      default:
        return TranslationService.translate('system_theme');
    }
  }

  String _getInternalThemeMode(String translated) {
    if (translated == TranslationService.translate('light_theme')) {
      return 'clair';
    }
    if (translated == TranslationService.translate('dark_theme')) {
      return 'sombre';
    }
    if (translated == TranslationService.translate('system_theme')) {
      return 'système';
    }
    return 'système';
  }

  void _testNotifications() async {
    HapticFeedback.mediumImpact();
    try {
      await NotificationService.instance.sendTestNotification();
      _showSuccessSnackbar(
          TranslationService.translate('test_notification_sent'));
    } catch (e) {
      _showErrorSnackbar('❌ Erreur: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _showDonateDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppColors.error),
              SizedBox(width: AppSpacing.sm),
              Text(
                TranslationService.translate('support_project'),
                style: AppTextStyles.h3.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Merci de soutenir le développement de Quizz4U !',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  '${TranslationService.translate('orange_money')}:',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '+223 76 03 91 92',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Développeur : YACOUBA SANTARA',
                  style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                TranslationService.translate('cancel'),
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    HapticFeedback.mediumImpact();
    showAboutDialog(
      context: context,
      applicationName: 'Quiz4U',
      applicationVersion: '1.0.0',
      applicationIcon:
          Icon(Icons.quiz_rounded, size: 48, color: AppColors.primary),
      children: [
        Text(
          TranslationService.translate('app_tagline'),
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
