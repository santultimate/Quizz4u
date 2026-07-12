import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Thèmes de l'application (clair et sombre)
/// Centralise toute la configuration visuelle
class AppTheme {
  // ==================== THÈME CLAIR ====================

  static ThemeData get lightTheme {
    return ThemeData(
      // Brightness
      brightness: Brightness.light,

      // Couleurs principales
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // Fond
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        // Ne pas fixer statusBarColor / navigationBarColor (APIs obsolètes Android 15+)
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppSpacing.elevationMedium,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusL,
        ),
        margin: AppSpacing.paddingM,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppSpacing.elevationMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.paddingL,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: AppSpacing.l,
      ),

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSpacing.iconM,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h4,
        headlineSmall: AppTextStyles.h5,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySmall,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusL,
        ),
        titleTextStyle: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusM,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppSpacing.elevationHigh,
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.xl),
          ),
        ),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        deleteIconColor: AppColors.primary,
        disabledColor: AppColors.border,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.secondary,
        labelPadding: AppSpacing.paddingHS,
        padding: AppSpacing.paddingS,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCircle,
        ),
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
        secondaryLabelStyle:
            AppTextStyles.caption.copyWith(color: Colors.white),
        brightness: Brightness.light,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.border.withValues(alpha: 0.5);
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            AppTextStyles.caption.copyWith(color: Colors.white),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevationHigh,
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        elevation: AppSpacing.elevationMedium,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      ),
    );
  }

  // ==================== THÈME SOMBRE ====================

  static ThemeData get darkTheme {
    return ThemeData(
      // Brightness
      brightness: Brightness.dark,

      // Couleurs principales
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),

      // Fond
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
          color: AppColors.textDark,
        ),
        iconTheme: IconThemeData(color: AppColors.textDark),
        // Ne pas fixer statusBarColor / navigationBarColor (APIs obsolètes Android 15+)
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: AppSpacing.elevationMedium,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusL,
        ),
        margin: AppSpacing.paddingM,
      ),

      // Buttons (identiques au thème clair)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppSpacing.elevationMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: AppSpacing.paddingL,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusM,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle:
            AppTextStyles.body.copyWith(color: AppColors.textDarkSecondary),
        hintStyle:
            AppTextStyles.body.copyWith(color: AppColors.textDarkDisabled),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: AppSpacing.l,
      ),

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.textDark,
        size: AppSpacing.iconM,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h4,
        headlineSmall: AppTextStyles.h5,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySmall,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
      ).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusL,
        ),
        titleTextStyle: AppTextStyles.h4.copyWith(color: AppColors.textDark),
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textDarkSecondary),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusM,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppSpacing.elevationHigh,
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.xl),
          ),
        ),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.borderDark,
        circularTrackColor: AppColors.borderDark,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        deleteIconColor: AppColors.primary,
        disabledColor: AppColors.borderDark,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.secondary,
        labelPadding: AppSpacing.paddingHS,
        padding: AppSpacing.paddingS,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCircle,
        ),
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
        secondaryLabelStyle:
            AppTextStyles.caption.copyWith(color: Colors.white),
        brightness: Brightness.dark,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.borderDark.withValues(alpha: 0.5);
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.borderDark,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            AppTextStyles.caption.copyWith(color: Colors.white),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevationHigh,
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        elevation: AppSpacing.elevationMedium,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.caption.copyWith(color: AppColors.textDarkSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textDarkSecondary);
        }),
      ),
    );
  }
}
