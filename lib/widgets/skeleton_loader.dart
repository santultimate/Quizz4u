import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Widget de chargement "skeleton" pour le contenu
/// Meilleure UX que le spinner pour le contenu qui charge
///
/// Utilisation :
/// ```dart
/// SkeletonLoader(width: 200, height: 20)
/// SkeletonCard()
/// SkeletonListTile()
/// ```
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final baseColor = isDark ? AppColors.surfaceElevated : AppColors.border;
    final highlightColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 16,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: widget.borderRadius ?? AppSpacing.borderRadiusS,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton d'une carte
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.paddingM,
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: AppSpacing.borderRadiusL,
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 150, height: 24),
          AppSpacing.spaceM,
          const SkeletonLoader(width: double.infinity, height: 16),
          AppSpacing.spaceS,
          const SkeletonLoader(width: double.infinity, height: 16),
          AppSpacing.spaceS,
          const SkeletonLoader(width: 200, height: 16),
          AppSpacing.spaceL,
          Row(
            children: [
              const Expanded(child: SkeletonLoader(height: 40)),
              AppSpacing.hSpaceM,
              const Expanded(child: SkeletonLoader(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton d'un ListTile
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingL,
      child: Row(
        children: [
          const SkeletonLoader(
            width: AppSpacing.iconXL,
            height: AppSpacing.iconXL,
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.iconXL)),
          ),
          AppSpacing.hSpaceL,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: double.infinity, height: 16),
                AppSpacing.spaceS,
                const SkeletonLoader(width: 150, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton d'une grille de catégories
class SkeletonCategoryGrid extends StatelessWidget {
  final int itemCount;

  const SkeletonCategoryGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppSpacing.paddingL,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
      ),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: AppSpacing.borderRadiusL,
            boxShadow: [AppColors.shadowLight],
          ),
          child: Padding(
            padding: AppSpacing.paddingL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkeletonLoader(
                  width: AppSpacing.iconL,
                  height: AppSpacing.iconL,
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppSpacing.iconL)),
                ),
                AppSpacing.spaceM,
                const SkeletonLoader(width: double.infinity, height: 16),
                AppSpacing.spaceS,
                const SkeletonLoader(width: 80, height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
