import 'package:flutter/material.dart';

import '../services/translation_service.dart';

/// Dialog pause extrait du quiz (réduit le monolithe quiz_screen).
class QuizPauseDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onContinue,
    required VoidCallback onRestart,
    required VoidCallback onQuit,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('game_paused')),
        content: Text(TranslationService.translate('continue_game_question')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: Text(TranslationService.translate('continue')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRestart();
            },
            child: Text(TranslationService.translate('restart')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onQuit();
            },
            child: Text(TranslationService.translate('quit')),
          ),
        ],
      ),
    );
  }
}
