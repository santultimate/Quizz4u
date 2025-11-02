import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Snackbar personnalisée avec icônes et animations
///
/// Utilisation :
/// ```dart
/// CustomSnackbar.show(
///   context,
///   message: 'Succès !',
///   type: SnackbarType.success,
/// );
/// ```
class CustomSnackbar {
  /// Afficher une snackbar
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // Enlever les anciennes

    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          message: message,
          type: type,
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: AppSpacing.paddingL,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Snackbar de succès
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context,
        message: message, type: SnackbarType.success, duration: duration);
  }

  /// Snackbar d'erreur
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context,
        message: message, type: SnackbarType.error, duration: duration);
  }

  /// Snackbar d'avertissement
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context,
        message: message, type: SnackbarType.warning, duration: duration);
  }

  /// Snackbar d'information
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context,
        message: message, type: SnackbarType.info, duration: duration);
  }
}

/// Contenu de la snackbar
class _SnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarType type;

  const _SnackbarContent({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusM,
        boxShadow: [AppColors.shadowMedium],
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingS,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              color: Colors.white,
              size: AppSpacing.iconM,
            ),
          ),
          AppSpacing.hSpaceM,
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradient() {
    switch (type) {
      case SnackbarType.success:
        return AppColors.successGradient;
      case SnackbarType.error:
        return AppColors.errorGradient;
      case SnackbarType.warning:
        return [AppColors.warning, AppColors.secondaryDark];
      case SnackbarType.info:
        return AppColors.infoGradient;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }
}

/// Types de snackbar
enum SnackbarType {
  success,
  error,
  warning,
  info,
}
