import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Styles de texte unifiés pour toute l'application
///
/// Utilisation :
/// ```dart
/// Text('Hello', style: AppTextStyles.h1)
/// Text('World', style: AppTextStyles.body)
/// ```
class AppTextStyles {
  // ==================== TITRES ====================

  /// Titre très large (32px) - Pour splash screens, titres majeurs
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
    height: 1.2,
  );

  /// Titre large (28px) - Pour titres de sections
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
    height: 1.3,
  );

  /// Titre moyen (24px) - Pour sous-titres
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
    height: 1.3,
  );

  /// Titre petit (20px) - Pour titres de cartes
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  /// Titre très petit (18px) - Pour labels importants
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  // ==================== LOGO & BRANDING ====================

  /// Style logo principal (très grand)
  static const TextStyle logo = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.normal,
    fontFamily: 'Signatra',
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 10,
        color: Colors.black26,
      ),
    ],
  );

  /// Style logo petit
  static const TextStyle logoSmall = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.normal,
    fontFamily: 'Signatra',
    color: Colors.white,
  );

  // ==================== CORPS DE TEXTE ====================

  /// Texte principal (16px)
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Raleway',
    height: 1.5,
  );

  /// Texte principal en gras
  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    height: 1.5,
  );

  /// Texte secondaire plus petit (14px)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: 'Raleway',
    height: 1.5,
  );

  /// Caption (12px) - Pour annotations, légendes
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  /// Caption en gras
  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  /// Très petit texte (10px) - Pour labels minimaux
  static const TextStyle tiny = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  // ==================== BOUTONS ====================

  /// Texte de bouton principal
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    letterSpacing: 0.5,
  );

  /// Texte de bouton large
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
    letterSpacing: 0.5,
  );

  /// Texte de bouton petit
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    letterSpacing: 0.3,
  );

  // ==================== QUESTIONS & RÉPONSES ====================

  /// Style pour les questions du quiz
  static const TextStyle question = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    height: 1.4,
    color: Colors.white,
  );

  /// Style pour les réponses du quiz
  static const TextStyle answer = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  /// Style pour les réponses sélectionnées
  static const TextStyle answerSelected = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
    height: 1.4,
  );

  // ==================== SCORES & STATISTIQUES ====================

  /// Grand nombre (pour scores, XP)
  static const TextStyle scoreLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
  );

  /// Nombre moyen (pour stats)
  static const TextStyle scoreMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
  );

  /// Petit nombre (pour labels de stats)
  static const TextStyle scoreSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Raleway',
  );

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Appliquer une couleur à un style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Obtenir le style avec la couleur de texte appropriée selon le thème
  static TextStyle withThemeColor(
    BuildContext context,
    TextStyle style, {
    bool secondary = false,
  }) {
    return style.copyWith(
      color: AppColors.getTextColor(context, secondary: secondary),
    );
  }

  /// Appliquer la couleur primaire
  static TextStyle withPrimary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  /// Appliquer la couleur de succès
  static TextStyle withSuccess(TextStyle style) {
    return style.copyWith(color: AppColors.success);
  }

  /// Appliquer la couleur d'erreur
  static TextStyle withError(TextStyle style) {
    return style.copyWith(color: AppColors.error);
  }

  /// Appliquer la couleur d'avertissement
  static TextStyle withWarning(TextStyle style) {
    return style.copyWith(color: AppColors.warning);
  }

  /// Appliquer la couleur blanche
  static TextStyle withWhite(TextStyle style) {
    return style.copyWith(color: Colors.white);
  }

  /// Rendre un style en gras
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Rendre un style en semi-gras
  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  /// Rendre un style en italique
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }
}







