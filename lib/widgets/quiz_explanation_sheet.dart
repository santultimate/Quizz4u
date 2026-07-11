import 'package:flutter/material.dart';

import '../services/translation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet d'explication après une réponse (extrait du quiz).
class QuizExplanationSheet {
  static Future<void> show({
    required BuildContext context,
    required bool isCorrect,
    required String correctAnswer,
    String? explanation,
  }) async {
    final text = (explanation ?? '').trim();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(ctx).brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isCorrect
                            ? TranslationService.translate('correct_answer')
                            : TranslationService.translate('wrong_answer'),
                        style: AppTextStyles.h3.copyWith(
                          color: isCorrect ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  '${TranslationService.translate('correct_answer')}: $correctAnswer',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                if (text.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    text,
                    style: AppTextStyles.body,
                  ),
                ],
                SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(TranslationService.translate('continue')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
