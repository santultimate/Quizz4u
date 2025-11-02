// lib/services/multilingual_tts_service.dart
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'translation_service.dart';
import 'localization_service.dart';

class MultilingualTTSService {
  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;
  static bool _isInitializing =
      false; // ✅ Lock pour éviter double initialisation
  static String _currentLanguage = 'fr';

  // Configuration optimisée des langues TTS avec paramètres de fluidité
  static final Map<String, Map<String, dynamic>> _languageConfig = {
    'fr': {
      'language': 'fr-FR',
      'name': 'Français',
      'voice': 'fr-FR',
      'speechRate': 0.5, // Vitesse optimale pour le français
      'pitch': 1.0,
      'volume': 1.0,
    },
    'en': {
      'language': 'en-US',
      'name': 'English',
      'voice': 'en-US',
      'speechRate': 0.5, // Légèrement plus rapide pour l'anglais
      'pitch': 1.0,
      'volume': 1.0,
    },
    'ar': {
      'language': 'ar-SA',
      'name': 'العربية',
      'voice': 'ar-SA',
      'speechRate': 0.45, // Plus lent pour l'arabe (lecture RTL)
      'pitch': 1.0,
      'volume': 1.0,
    },
    'zh': {
      'language': 'zh-CN',
      'name': '中文',
      'voice': 'zh-CN',
      'speechRate': 0.48, // Chinois mandarin nécessite une lecture plus mesurée
      'pitch': 1.1, // Pitch légèrement plus élevé pour le chinois
      'volume': 1.0,
    },
    'hi': {
      'language': 'hi-IN',
      'name': 'हिन्दी',
      'voice': 'hi-IN',
      'speechRate': 0.48, // Hindi nécessite une lecture claire
      'pitch': 1.0,
      'volume': 1.0,
    },
    'es': {
      'language': 'es-ES',
      'name': 'Español',
      'voice': 'es-ES',
      'speechRate': 0.52, // Espagnol peut être légèrement plus rapide
      'pitch': 1.0,
      'volume': 1.0,
    },
  };

  // Initialiser le service TTS multilingue
  static Future<void> initialize() async {
    // ✅ Éviter double initialisation et appels concurrents
    if (_isInitialized) {
      print('[MultilingualTTS] ⚠️ Déjà initialisé');
      return;
    }

    if (_isInitializing) {
      print('[MultilingualTTS] ⚠️ Initialisation déjà en cours...');
      // Attendre que l'initialisation en cours se termine
      int retries = 0;
      while (_isInitializing && retries < 30) {
        // Max 3 secondes
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
      return;
    }

    _isInitializing = true; // ✅ Lock activé
    try {
      print('[MultilingualTTS] 🚀 Début initialisation...');
      _flutterTts = FlutterTts();
      _currentLanguage = await LocalizationService.getCurrentLanguage();

      // Configuration optimisée selon la langue
      await _applyLanguageConfiguration(_currentLanguage);

      // Configuration spécifique à la plateforme pour une meilleure qualité
      if (Platform.isAndroid) {
        await _flutterTts!.setEngine('com.google.android.tts');
        await _flutterTts!.setSilence(100); // Pause courte entre les phrases
      } else if (Platform.isIOS) {
        await _flutterTts!.setSharedInstance(true);
        await _flutterTts!.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      // Événements TTS
      _flutterTts!.setStartHandler(() {
        print('[MultilingualTTS] 🎤 Début de la lecture');
      });

      _flutterTts!.setCompletionHandler(() {
        print('[MultilingualTTS] ✅ Lecture terminée');
      });

      _flutterTts!.setErrorHandler((msg) {
        print('[MultilingualTTS] ❌ Erreur: $msg');
      });

      _flutterTts!.setCancelHandler(() {
        print('[MultilingualTTS] ⏹️ Lecture annulée');
      });

      _flutterTts!.setPauseHandler(() {
        print('[MultilingualTTS] ⏸️ Lecture en pause');
      });

      _flutterTts!.setContinueHandler(() {
        print('[MultilingualTTS] ▶️ Lecture reprise');
      });

      // Écouter les changements de langue
      _setupLanguageListener();

      _isInitialized = true;
      print(
          '[MultilingualTTS] 🎤 Service TTS initialisé avec configuration optimisée pour $_currentLanguage');
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur initialisation: $e');
      _isInitialized = false; // Reset en cas d'erreur
    } finally {
      _isInitializing = false; // ✅ Toujours libérer le lock
      print('[MultilingualTTS] 🔓 Lock d\'initialisation libéré');
    }
  }

  // Appliquer la configuration optimisée pour une langue
  static Future<void> _applyLanguageConfiguration(String languageCode) async {
    if (!_languageConfig.containsKey(languageCode)) {
      languageCode = 'fr'; // Fallback vers français
    }

    final config = _languageConfig[languageCode]!;

    try {
      await _flutterTts!.setLanguage(config['language'] as String);
      await _flutterTts!.setSpeechRate(config['speechRate'] as double);
      await _flutterTts!.setPitch(config['pitch'] as double);
      await _flutterTts!.setVolume(config['volume'] as double);

      print(
          '[MultilingualTTS] ⚙️ Configuration appliquée: ${config['name']} (rate: ${config['speechRate']}, pitch: ${config['pitch']})');
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur configuration langue: $e');
    }
  }

  // Écouter les changements de langue de l'application
  static void _setupLanguageListener() {
    LocalizationService.languageChangeStream.listen((newLanguage) async {
      if (newLanguage != _currentLanguage) {
        print(
            '[MultilingualTTS] 🔄 Changement de langue détecté: $_currentLanguage → $newLanguage');
        await changeLanguage(newLanguage);
      }
    });
  }

  // Changer la langue TTS avec configuration optimisée
  static Future<void> changeLanguage(String languageCode) async {
    if (!_isInitialized) await initialize();

    if (_languageConfig.containsKey(languageCode)) {
      _currentLanguage = languageCode;

      try {
        // Arrêter toute lecture en cours avant de changer de langue
        await stop();

        // Appliquer la configuration optimisée pour la nouvelle langue
        await _applyLanguageConfiguration(languageCode);

        print(
            '[MultilingualTTS] 🌍 Langue TTS changée vers: ${_languageConfig[languageCode]!['name']} avec configuration optimisée');
      } catch (e) {
        print('[MultilingualTTS] ❌ Erreur changement langue: $e');
      }
    }
  }

  // Lire un texte avec la langue actuelle (optimisé pour la fluidité)
  static Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();

    if (text.isEmpty) return;

    try {
      // ✅ TOUJOURS vérifier et mettre à jour la langue avant de parler
      final currentSystemLanguage =
          await LocalizationService.getCurrentLanguage();
      if (currentSystemLanguage != _currentLanguage) {
        print(
            '[MultilingualTTS] 🔄 Changement de langue détecté: $_currentLanguage → $currentSystemLanguage');
        await changeLanguage(currentSystemLanguage);
      }

      // Nettoyer et normaliser le texte pour une meilleure lecture
      final cleanedText = _cleanTextForSpeech(text);

      // Pour les textes longs, découper en phrases pour une lecture plus naturelle
      if (cleanedText.length > 200) {
        await _speakLongText(cleanedText);
      } else {
        await _flutterTts!.speak(cleanedText);
        print(
            '[MultilingualTTS] 🎤 Lecture: "${cleanedText.length > 50 ? cleanedText.substring(0, 50) + '...' : cleanedText}" en $_currentLanguage');
      }
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur lecture: $e');
    }
  }

  // Nettoyer le texte pour une meilleure lecture TTS
  static String _cleanTextForSpeech(String text) {
    // Remplacer les caractères spéciaux qui peuvent perturber le TTS
    String cleaned = text
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliser les espaces
        .replaceAll(RegExp(r'[*_~`]'), '') // Supprimer markdown
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1') // Liens markdown
        .trim();

    // Remplacer les abréviations courantes pour une meilleure prononciation
    if (_currentLanguage == 'fr') {
      cleaned = cleaned
          .replaceAll('M.', 'Monsieur')
          .replaceAll('Mme', 'Madame')
          .replaceAll('Dr', 'Docteur')
          .replaceAll('etc.', 'et cetera');
    } else if (_currentLanguage == 'en') {
      cleaned = cleaned
          .replaceAll('Mr.', 'Mister')
          .replaceAll('Mrs.', 'Misses')
          .replaceAll('Dr.', 'Doctor');
    }

    return cleaned;
  }

  // Lire un texte long en le découpant en phrases
  static Future<void> _speakLongText(String text) async {
    // Découper en phrases selon les points, points d'interrogation et d'exclamation
    final sentences = text.split(RegExp(r'[.!?]+\s+'));

    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;

      await _flutterTts!.speak(sentence);
      print(
          '[MultilingualTTS] 🎤 Phrase ${i + 1}/${sentences.length}: "${sentence.substring(0, sentence.length > 30 ? 30 : sentence.length)}..."');

      // Petite pause entre les phrases pour une lecture plus naturelle
      if (i < sentences.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  // Lire une traduction
  static Future<void> speakTranslation(String translationKey,
      {Map<String, String>? params}) async {
    final text = params != null
        ? TranslationService.translateWithParams(translationKey, params)
        : TranslationService.translate(translationKey);

    await speak(text);
  }

  // Lire une question de quiz
  static Future<void> speakQuestion(String question) async {
    // ✅ TOUJOURS synchroniser la langue avec le système avant de lire
    final currentSystemLanguage =
        await LocalizationService.getCurrentLanguage();
    if (currentSystemLanguage != _currentLanguage) {
      print(
          '[MultilingualTTS] 🔄 Synchronisation langue pour question: $_currentLanguage → $currentSystemLanguage');
      await changeLanguage(currentSystemLanguage);
    }
    await speak(question);
  }

  // Lire les options de réponse avec fluidité
  static Future<void> speakAnswerOptions(List<String> options) async {
    // Adapter le délai selon la langue (certaines langues nécessitent plus de temps)
    final pauseDuration = _currentLanguage == 'ar' || _currentLanguage == 'zh'
        ? const Duration(milliseconds: 700)
        : const Duration(milliseconds: 500);

    for (int i = 0; i < options.length; i++) {
      // Introduire l'option de manière plus naturelle
      final optionLetter = String.fromCharCode(65 + i);
      final prefix = _currentLanguage == 'fr'
          ? 'Option $optionLetter:'
          : _currentLanguage == 'en'
              ? 'Option $optionLetter:'
              : _currentLanguage == 'ar'
                  ? 'الخيار $optionLetter:'
                  : _currentLanguage == 'zh'
                      ? '选项 $optionLetter:'
                      : _currentLanguage == 'hi'
                          ? 'विकल्प $optionLetter:'
                          : _currentLanguage == 'es'
                              ? 'Opción $optionLetter:'
                              : 'Option $optionLetter:';

      await speak('$prefix ${options[i]}');

      // Pause adaptative entre les options
      if (i < options.length - 1) {
        await Future.delayed(pauseDuration);
      }
    }
  }

  // Lire le feedback (correct/incorrect)
  static Future<void> speakFeedback(bool isCorrect) async {
    final message = isCorrect
        ? TranslationService.translate('tts_correct_answer')
        : TranslationService.translate('tts_wrong_answer');
    await speak(message);
  }

  // Lire le score
  static Future<void> speakScore(int score) async {
    final message = TranslationService.translateWithParams(
        'tts_score_announcement', {'score': score.toString()});
    await speak(message);
  }

  // Lire le temps restant
  static Future<void> speakTimeRemaining(int seconds) async {
    if (seconds <= 10) {
      final message = TranslationService.translateWithParams(
          'tts_time_warning', {'seconds': seconds.toString()});
      await speak(message);
    }
  }

  // Arrêter la lecture
  static Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.stop();
      print('[MultilingualTTS] ⏹️ Lecture arrêtée');
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur arrêt: $e');
    }
  }

  // Vérifier si TTS est disponible
  static Future<bool> isLanguageAvailable(String languageCode) async {
    if (!_isInitialized) await initialize();

    try {
      final languages = await _flutterTts!.getLanguages;
      final targetLanguage = _languageConfig[languageCode]?['language'];

      if (targetLanguage != null && languages.contains(targetLanguage)) {
        return true;
      }

      // Fallback: vérifier si une langue similaire est disponible
      for (final lang in languages) {
        if (lang.startsWith(languageCode)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur vérification langue: $e');
      return false;
    }
  }

  // Obtenir les langues disponibles
  static Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) await initialize();

    try {
      final languages = await _flutterTts!.getLanguages;
      final availableLanguages = <String>[];

      for (final config in _languageConfig.entries) {
        final languageCode = config.value['language']!;
        if (languages.contains(languageCode)) {
          availableLanguages.add(config.key);
        }
      }

      return availableLanguages;
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur récupération langues: $e');
      return ['fr']; // Fallback vers français
    }
  }

  // Configuration avancée TTS (avec préservation des paramètres de langue)
  static Future<void> configureVoice({
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      if (speechRate != null) {
        await _flutterTts!.setSpeechRate(speechRate);
        // Mettre à jour la configuration pour cette langue
        _languageConfig[_currentLanguage]!['speechRate'] = speechRate;
      }
      if (volume != null) {
        await _flutterTts!.setVolume(volume);
        _languageConfig[_currentLanguage]!['volume'] = volume;
      }
      if (pitch != null) {
        await _flutterTts!.setPitch(pitch);
        _languageConfig[_currentLanguage]!['pitch'] = pitch;
      }

      print(
          '[MultilingualTTS] ⚙️ Configuration TTS mise à jour (rate: ${speechRate ?? 'inchangé'}, volume: ${volume ?? 'inchangé'}, pitch: ${pitch ?? 'inchangé'})');
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur configuration: $e');
    }
  }

  // Obtenir les voix disponibles pour la langue actuelle
  static Future<List<Map<String, String>>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();

    try {
      final voices = await _flutterTts!.getVoices;
      final currentLangCode = _languageConfig[_currentLanguage]!['language'];

      // Filtrer les voix pour la langue actuelle
      final filteredVoices = <Map<String, String>>[];
      for (var voice in voices) {
        if (voice['locale']?.startsWith(_currentLanguage) == true ||
            voice['locale']?.startsWith(currentLangCode.substring(0, 2)) ==
                true) {
          filteredVoices.add({
            'name': voice['name'] ?? 'Unknown',
            'locale': voice['locale'] ?? 'Unknown',
          });
        }
      }

      print(
          '[MultilingualTTS] 🎙️ ${filteredVoices.length} voix disponibles pour $_currentLanguage');
      return filteredVoices;
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur récupération voix: $e');
      return [];
    }
  }

  // Définir une voix spécifique
  static Future<void> setVoice(Map<String, String> voice) async {
    if (!_isInitialized) await initialize();

    try {
      await _flutterTts!.setVoice(voice);
      print('[MultilingualTTS] 🎙️ Voix définie: ${voice['name']}');
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur définition voix: $e');
    }
  }

  // Obtenir des statistiques sur la configuration TTS actuelle
  static Map<String, dynamic> getConfiguration() {
    final config = _languageConfig[_currentLanguage] ?? _languageConfig['fr']!;
    return {
      'language': _currentLanguage,
      'languageName': config['name'],
      'languageCode': config['language'],
      'speechRate': config['speechRate'],
      'pitch': config['pitch'],
      'volume': config['volume'],
      'isInitialized': _isInitialized,
    };
  }

  // Obtenir la langue actuelle
  static String getCurrentLanguage() => _currentLanguage;

  // Vérifier si TTS est initialisé
  static bool get isInitialized => _isInitialized;

  // Nettoyer les ressources
  /// ✅ Dispose robuste avec gestion d'erreurs
  static Future<void> dispose() async {
    if (!_isInitialized && _flutterTts == null) {
      print('[MultilingualTTS] ⚠️ Déjà disposé');
      return;
    }

    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
        _flutterTts = null;
      }
      _isInitialized = false;
      _isInitializing = false; // Reset le lock aussi
      print('[MultilingualTTS] 🧹 Service TTS nettoyé avec succès');
    } catch (e) {
      print('[MultilingualTTS] ❌ Erreur lors du dispose: $e');
      // Force reset même en cas d'erreur
      _flutterTts = null;
      _isInitialized = false;
      _isInitializing = false;
    }
  }
}
