import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/app_theme.dart';

class ModernComponents {
  // Animated Gradient Button
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
    double? width,
    double height = 56,
    bool isLoading = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: color != null
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Animated Card
  static Widget animatedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double elevation = 8,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedContainer(
      duration: duration,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Shimmer Loading
  static Widget shimmerLoading({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  // Animated Text
  static Widget animatedText({
    required String text,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: style ??
              const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
          speed: const Duration(milliseconds: 100),
        ),
      ],
      totalRepeatCount: 1,
    );
  }

  // Progress Bar
  static Widget progressBar({
    required double progress,
    required double height,
    Color? backgroundColor,
    Color? progressColor,
    Duration duration = const Duration(milliseconds: 500),
    required BuildContext context,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: AnimatedContainer(
        duration: duration,
        width: MediaQuery.of(context).size.width * progress,
        decoration: BoxDecoration(
          gradient: progressColor != null
              ? LinearGradient(
                  colors: [progressColor, progressColor.withOpacity(0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }

  // Badge Widget
  static Widget badge({
    required String icon,
    required String title,
    required String description,
    bool isUnlocked = false,
    VoidCallback? onTap,
  }) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isUnlocked
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnlocked
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock,
                    color: isUnlocked ? Colors.white : Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Category Card
  static Widget categoryCard({
    required String title,
    required String icon,
    required String description,
    required int questionCount,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: isLocked ? null : onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isLocked
                    ? LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      )
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isLocked
                        ? Colors.grey.withOpacity(0.2)
                        : AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isLocked ? Colors.grey.shade700 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isLocked
                                ? Colors.grey.shade600
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.quiz,
                              size: 16,
                              color: isLocked
                                  ? Colors.grey.shade500
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$questionCount questions',
                              style: TextStyle(
                                fontSize: 12,
                                color: isLocked
                                    ? Colors.grey.shade500
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isLocked ? Icons.lock : Icons.arrow_forward_ios,
                    color: isLocked ? Colors.grey.shade500 : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Score Display
  static Widget scoreDisplay({
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    final percentage =
        totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: percentage >= 0.8
            ? AppTheme.successGradient
            : percentage >= 0.6
                ? AppTheme.primaryGradient
                : AppTheme.errorGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Score Final',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                '$score points',
                textStyle: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          const SizedBox(height: 16),
          Text(
            '$correctAnswers / $totalQuestions correctes',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) => progressBar(
              progress: percentage,
              height: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              progressColor: Colors.white,
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}
