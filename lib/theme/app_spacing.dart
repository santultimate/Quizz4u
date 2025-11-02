import 'package:flutter/material.dart';

/// Espacements cohérents pour toute l'application
/// Tous les espacements sont des multiples de 4px pour maintenir une grille cohérente
///
/// Utilisation :
/// ```dart
/// Padding(padding: AppSpacing.paddingM)
/// SizedBox(height: AppSpacing.spaceL)
/// ```
class AppSpacing {
  // ==================== ESPACEMENTS DE BASE ====================

  /// Très petit (4px)
  static const double xs = 4.0;

  /// Petit (8px)
  static const double s = 8.0;

  /// Moyen (12px)
  static const double m = 12.0;

  /// Large (16px)
  static const double l = 16.0;

  /// Très large (24px)
  static const double xl = 24.0;

  /// Extra large (32px)
  static const double xxl = 32.0;

  /// Énorme (48px)
  static const double xxxl = 48.0;

  // ==================== ALIASES POUR COMPATIBILITÉ ====================

  /// Alias: sm = s (8px)
  static const double sm = s;

  /// Alias: md = m (12px)
  static const double md = m;

  /// Alias: lg = l (16px)
  static const double lg = l;

  /// Radius aliases
  static const double radiusXs = radiusXS;
  static const double radiusSm = radiusS;
  static const double radiusMd = radiusM;
  static const double radiusLg = radiusL;

  // ==================== SIZEBOX PRÉFABRIQUÉS ====================

  /// SizedBox vertical très petit (4px)
  static const Widget spaceXS = SizedBox(height: xs);

  /// SizedBox vertical petit (8px)
  static const Widget spaceS = SizedBox(height: s);

  /// SizedBox vertical moyen (12px)
  static const Widget spaceM = SizedBox(height: m);

  /// SizedBox vertical large (16px)
  static const Widget spaceL = SizedBox(height: l);

  /// SizedBox vertical très large (24px)
  static const Widget spaceXL = SizedBox(height: xl);

  /// SizedBox vertical extra large (32px)
  static const Widget spaceXXL = SizedBox(height: xxl);

  /// SizedBox vertical énorme (48px)
  static const Widget spaceXXXL = SizedBox(height: xxxl);

  // Espacements horizontaux

  /// SizedBox horizontal très petit (4px)
  static const Widget hSpaceXS = SizedBox(width: xs);

  /// SizedBox horizontal petit (8px)
  static const Widget hSpaceS = SizedBox(width: s);

  /// SizedBox horizontal moyen (12px)
  static const Widget hSpaceM = SizedBox(width: m);

  /// SizedBox horizontal large (16px)
  static const Widget hSpaceL = SizedBox(width: l);

  /// SizedBox horizontal très large (24px)
  static const Widget hSpaceXL = SizedBox(width: xl);

  /// SizedBox horizontal extra large (32px)
  static const Widget hSpaceXXL = SizedBox(width: xxl);

  // ==================== PADDING PRÉFABRIQUÉS ====================

  /// Padding uniforme très petit (4px)
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// Padding uniforme petit (8px)
  static const EdgeInsets paddingS = EdgeInsets.all(s);

  /// Padding uniforme moyen (12px)
  static const EdgeInsets paddingM = EdgeInsets.all(m);

  /// Padding uniforme large (16px)
  static const EdgeInsets paddingL = EdgeInsets.all(l);

  /// Padding uniforme très large (24px)
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// Padding uniforme extra large (32px)
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Padding horizontal

  /// Padding horizontal très petit (4px)
  static const EdgeInsets paddingHXS = EdgeInsets.symmetric(horizontal: xs);

  /// Padding horizontal petit (8px)
  static const EdgeInsets paddingHS = EdgeInsets.symmetric(horizontal: s);

  /// Padding horizontal moyen (12px)
  static const EdgeInsets paddingHM = EdgeInsets.symmetric(horizontal: m);

  /// Padding horizontal large (16px)
  static const EdgeInsets paddingHL = EdgeInsets.symmetric(horizontal: l);

  /// Padding horizontal très large (24px)
  static const EdgeInsets paddingHXL = EdgeInsets.symmetric(horizontal: xl);

  /// Padding horizontal extra large (32px)
  static const EdgeInsets paddingHXXL = EdgeInsets.symmetric(horizontal: xxl);

  // Padding vertical

  /// Padding vertical très petit (4px)
  static const EdgeInsets paddingVXS = EdgeInsets.symmetric(vertical: xs);

  /// Padding vertical petit (8px)
  static const EdgeInsets paddingVS = EdgeInsets.symmetric(vertical: s);

  /// Padding vertical moyen (12px)
  static const EdgeInsets paddingVM = EdgeInsets.symmetric(vertical: m);

  /// Padding vertical large (16px)
  static const EdgeInsets paddingVL = EdgeInsets.symmetric(vertical: l);

  /// Padding vertical très large (24px)
  static const EdgeInsets paddingVXL = EdgeInsets.symmetric(vertical: xl);

  /// Padding vertical extra large (32px)
  static const EdgeInsets paddingVXXL = EdgeInsets.symmetric(vertical: xxl);

  // ==================== BORDURES ARRONDIES ====================

  /// Coins arrondis très petits (4px)
  static const double radiusXS = xs;

  /// Coins arrondis petits (8px)
  static const double radiusS = s;

  /// Coins arrondis moyens (12px)
  static const double radiusM = m;

  /// Coins arrondis larges (16px)
  static const double radiusL = l;

  /// Coins arrondis très larges (24px)
  static const double radiusXL = xl;

  /// Coins arrondis extra larges (32px)
  static const double radiusXXL = xxl;

  /// BorderRadius préfabriqués

  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusS => BorderRadius.circular(radiusS);
  static BorderRadius get borderRadiusM => BorderRadius.circular(radiusM);
  static BorderRadius get borderRadiusL => BorderRadius.circular(radiusL);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);

  /// Coins complètement arrondis (cercle)
  static BorderRadius get borderRadiusCircle => BorderRadius.circular(9999);

  // ==================== ELEVATIONS (OMBRES) ====================

  /// Pas d'ombre
  static const double elevationNone = 0;

  /// Ombre légère
  static const double elevationLight = 2;

  /// Ombre moyenne
  static const double elevationMedium = 4;

  /// Ombre forte
  static const double elevationHigh = 8;

  /// Ombre très forte
  static const double elevationVeryHigh = 16;

  // ==================== ICON SIZES ====================

  /// Icône très petite (16px)
  static const double iconXS = 16.0;

  /// Icône petite (20px)
  static const double iconS = 20.0;

  /// Icône moyenne (24px)
  static const double iconM = 24.0;

  /// Icône large (32px)
  static const double iconL = 32.0;

  /// Icône très large (48px)
  static const double iconXL = 48.0;

  /// Icône extra large (64px)
  static const double iconXXL = 64.0;

  // ==================== BUTTON HEIGHTS ====================

  /// Bouton petit
  static const double buttonHeightS = 40.0;

  /// Bouton moyen
  static const double buttonHeightM = 48.0;

  /// Bouton large
  static const double buttonHeightL = 56.0;

  /// Bouton extra large
  static const double buttonHeightXL = 64.0;

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Créer un EdgeInsets personnalisé en multiples de 4
  static EdgeInsets custom({
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(all * 4);
    }

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: (horizontal ?? 0) * 4,
        vertical: (vertical ?? 0) * 4,
      );
    }

    return EdgeInsets.only(
      top: (top ?? 0) * 4,
      right: (right ?? 0) * 4,
      bottom: (bottom ?? 0) * 4,
      left: (left ?? 0) * 4,
    );
  }

  /// Créer un SizedBox vertical avec hauteur personnalisée (en multiples de 4)
  static Widget vSpace(double multiple) {
    return SizedBox(height: multiple * 4);
  }

  /// Créer un SizedBox horizontal avec largeur personnalisée (en multiples de 4)
  static Widget hSpace(double multiple) {
    return SizedBox(width: multiple * 4);
  }

  /// Créer un BorderRadius personnalisé (en multiples de 4)
  static BorderRadius borderRadius(double multiple) {
    return BorderRadius.circular(multiple * 4);
  }
}
