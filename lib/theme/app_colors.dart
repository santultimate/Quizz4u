import 'package:flutter/material.dart';

/// Palette de couleurs unifiée pour toute l'application
///
/// Utilisation :
/// ```dart
/// Container(color: AppColors.primary)
/// Text(style: TextStyle(color: AppColors.textPrimary))
/// ```
class AppColors {
  // ==================== COULEURS PRINCIPALES ====================

  /// Violet foncé - Couleur principale de la marque
  static const Color primary = Color(0xFF6A1B9A);

  /// Violet moyen - Variations de la couleur principale
  static const Color primaryLight = Color(0xFF9C27B0);

  /// Violet très foncé - Pour contraste élevé
  static const Color primaryDark = Color(0xFF4A148C);

  // ==================== COULEURS SECONDAIRES ====================

  /// Orange - Couleur d'accent
  static const Color secondary = Color(0xFFFF9800);

  /// Orange clair - Variations
  static const Color secondaryLight = Color(0xFFFFA726);

  /// Orange foncé
  static const Color secondaryDark = Color(0xFFF57C00);

  /// Alias: accent = secondary (pour compatibilité)
  static const Color accent = secondary;

  // ==================== COULEURS D'ÉTAT ====================

  /// Vert - Succès, bonnes réponses
  static const Color success = Color(0xFF4CAF50);

  /// Vert clair
  static const Color successLight = Color(0xFF81C784);

  /// Rouge - Erreur, mauvaises réponses
  static const Color error = Color(0xFFF44336);

  /// Rouge clair
  static const Color errorLight = Color(0xFFEF5350);

  /// Orange - Avertissements
  static const Color warning = Color(0xFFFF9800);

  /// Bleu - Information
  static const Color info = Color(0xFF2196F3);

  // ==================== BACKGROUNDS ====================

  /// Fond clair principal
  static const Color background = Color(0xFFF5F5F5);

  /// Surface blanche
  static const Color surface = Colors.white;

  /// Fond sombre (dark mode)
  static const Color backgroundDark = Color(0xFF121212);

  /// Surface sombre (dark mode)
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Surface élevée (dark mode)
  static const Color surfaceElevated = Color(0xFF2C2C2C);

  // ==================== TEXTES ====================

  /// Texte principal (mode clair)
  static const Color textPrimary = Color(0xFF212121);

  /// Texte secondaire (mode clair)
  static const Color textSecondary = Color(0xFF757575);

  /// Texte désactivé (mode clair)
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Texte principal (dark mode)
  static const Color textDark = Colors.white;

  /// Texte secondaire (dark mode)
  static const Color textDarkSecondary = Color(0xFFBDBDBD);

  /// Texte désactivé (dark mode)
  static const Color textDarkDisabled = Color(0xFF757575);

  /// Alias pour compatibilité: textPrimaryDark = textDark
  static const Color textPrimaryDark = textDark;

  /// Alias pour compatibilité: textSecondaryDark = textDarkSecondary
  static const Color textSecondaryDark = textDarkSecondary;

  // ==================== CARTES ====================

  /// Couleur de carte (dark mode)
  static const Color cardDark = Color(0xFF242424);

  /// Couleur de carte (light mode)
  static const Color card = Colors.white;

  // ==================== BORDURES ====================

  /// Bordure par défaut
  static const Color border = Color(0xFFE0E0E0);

  /// Bordure focus
  static const Color borderFocus = primary;

  /// Bordure dark mode
  static const Color borderDark = Color(0xFF424242);

  // ==================== GRADIENTS ====================

  /// Gradient principal (violet)
  static const List<Color> primaryGradient = [
    Color(0xFF6A1B9A),
    Color(0xFF9C27B0),
  ];

  /// Gradient secondaire (orange)
  static const List<Color> secondaryGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  /// Gradient succès (vert)
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  /// Gradient erreur (rouge)
  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFEF5350),
  ];

  /// Gradient info (bleu)
  static const List<Color> infoGradient = [
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
  ];

  /// Gradient sombre (dark mode)
  static const List<Color> darkGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF2D2D2D),
  ];

  // ==================== COULEURS PAR CATÉGORIE ====================

  /// Couleur pour catégorie Sciences
  static const Color categoryScience = Color(0xFF2196F3);

  /// Couleur pour catégorie Histoire
  static const Color categoryHistory = Color(0xFFFF5722);

  /// Couleur pour catégorie Géographie
  static const Color categoryGeography = Color(0xFF4CAF50);

  /// Couleur pour catégorie Culture
  static const Color categoryCulture = Color(0xFF9C27B0);

  /// Couleur pour catégorie Sport
  static const Color categorySport = Color(0xFFFF9800);

  /// Couleur pour catégorie Arts
  static const Color categoryArts = Color(0xFFE91E63);

  /// Couleur pour catégorie Mathématiques
  static const Color categoryMath = Color(0xFF00BCD4);

  /// Couleur pour catégorie Divers
  static const Color categoryMisc = Color(0xFF607D8B);

  // ==================== OVERLAY & SHADOWS ====================

  /// Overlay sombre
  static Color overlay(double opacity) =>
      Colors.black.withValues(alpha: opacity);

  /// Overlay clair
  static Color overlayLight(double opacity) =>
      Colors.white.withValues(alpha: opacity);

  /// Shadow légère
  static BoxShadow get shadowLight => BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  /// Shadow moyenne
  static BoxShadow get shadowMedium => BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 15,
        offset: const Offset(0, 4),
      );

  /// Shadow forte
  static BoxShadow get shadowHeavy => BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Obtenir la couleur pour une catégorie donnée
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'sciences':
      case 'science':
        return categoryScience;
      case 'histoire':
      case 'history':
        return categoryHistory;
      case 'géographie':
      case 'geography':
        return categoryGeography;
      case 'culture générale':
      case 'culture':
        return categoryCulture;
      case 'sport':
      case 'sports':
        return categorySport;
      case 'arts':
      case 'art':
        return categoryArts;
      case 'mathématiques':
      case 'maths':
      case 'math':
        return categoryMath;
      default:
        return categoryMisc;
    }
  }

  /// Obtenir un gradient pour une catégorie donnée
  static List<Color> getCategoryGradient(String category) {
    final baseColor = getCategoryColor(category);
    return [
      baseColor,
      Color.lerp(baseColor, Colors.white, 0.2)!,
    ];
  }

  /// Vérifier si on est en dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Obtenir la couleur de texte appropriée selon le thème
  static Color getTextColor(BuildContext context, {bool secondary = false}) {
    final isDark = isDarkMode(context);
    if (secondary) {
      return isDark ? textDarkSecondary : textSecondary;
    }
    return isDark ? textDark : textPrimary;
  }

  /// Obtenir la couleur de fond appropriée selon le thème
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? backgroundDark : background;
  }

  /// Obtenir la couleur de surface appropriée selon le thème
  static Color getSurfaceColor(BuildContext context) {
    return isDarkMode(context) ? surfaceDark : surface;
  }
}
