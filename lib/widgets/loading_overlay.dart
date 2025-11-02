import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Overlay de chargement réutilisable
///
/// Utilisation :
/// ```dart
/// LoadingOverlay.show(context, message: 'Chargement...');
/// LoadingOverlay.hide(context);
/// ```
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Afficher l'overlay de chargement
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    if (_overlayEntry != null) {
      hide(context);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingOverlayWidget(
        message: message,
        barrierDismissible: barrierDismissible,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Masquer l'overlay de chargement
  static void hide(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Widget de l'overlay de chargement
class LoadingOverlayWidget extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;

  const LoadingOverlayWidget({
    super.key,
    this.message,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: barrierDismissible ? () => LoadingOverlay.hide(context) : null,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: AppSpacing.paddingXL,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: AppSpacing.borderRadiusL,
                boxShadow: [AppColors.shadowHeavy],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  if (message != null) ...[
                    AppSpacing.spaceL,
                    Text(
                      message!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de chargement inline (non-modal)
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            AppSpacing.spaceM,
            Text(
              message!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.getTextColor(context, secondary: true),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}






