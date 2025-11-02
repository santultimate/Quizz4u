import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Bouton avec retour haptique et animations fluides
///
/// Utilisation :
/// ```dart
/// HapticButton(
///   text: 'Commencer',
///   onPressed: () { ... },
/// )
/// ```
class HapticButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool fullWidth;
  final IconData? icon;
  final bool isLoading;
  final double? height;
  final double? width;

  const HapticButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.fullWidth = false,
    this.icon,
    this.isLoading = false,
    this.height,
    this.width,
  });

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.mediumImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height ?? AppSpacing.buttonHeightM,
          width: widget.fullWidth ? double.infinity : widget.width,
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: AppSpacing.borderRadiusM,
            boxShadow: widget.onPressed != null && !widget.isLoading
                ? [AppColors.shadowMedium]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: AppSpacing.paddingHL,
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: widget.fullWidth
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: _getTextColor(),
                            size: AppSpacing.iconS,
                          ),
                          AppSpacing.hSpaceM,
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: AppTextStyles.button.copyWith(
                              color: _getTextColor(),
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    if (widget.onPressed == null || widget.isLoading) {
      return const LinearGradient(
        colors: [AppColors.textDisabled, AppColors.textDisabled],
      );
    }

    switch (widget.type) {
      case ButtonType.primary:
        return const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ButtonType.secondary:
        return const LinearGradient(
          colors: AppColors.secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ButtonType.success:
        return const LinearGradient(
          colors: AppColors.successGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ButtonType.error:
        return const LinearGradient(
          colors: AppColors.errorGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ButtonType.info:
        return const LinearGradient(
          colors: AppColors.infoGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return AppColors.textDarkDisabled;
    }
    return Colors.white;
  }
}

/// Types de bouton disponibles
enum ButtonType {
  primary,
  secondary,
  success,
  error,
  info,
}
