import 'dart:async';
import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../services/unified_audio_service_optimized.dart'; // ⚡ OPTIMISÉ
import '../services/multilingual_tts_service.dart';
import '../services/question_service_optimized.dart'; // ⚡ OPTIMISÉ
import '../services/cached_preferences_service.dart'; // ⚡ NOUVEAU
import '../services/progress_service.dart';
import '../services/question_translation_service.dart';
import '../services/ad_service.dart';
import '../services/purchase_service.dart';
import '../services/dynamic_question_service.dart';
import '../services/community_question_service.dart';
import '../services/payment_verification_service.dart';
import '../services/notification_service.dart';
import '../home.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart'; // ✅ Pour le logo "Quizz4U"
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quizz4u/firebase_options.dart';

/// Écran de chargement qui initialise tous les services
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  String _loadingText = 'Initialisation...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Animation de pulsation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Démarrer l'initialisation
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      print('[Loading] ⚡ DÉMARRAGE OPTIMISÉ - Fix ANR v2.0.5');

      // Étape 1: TranslationService (CRITIQUE!)
      if (mounted) {
        setState(() {
          _loadingText =
              'Chargement des traductions...'; // Texte par défaut avant init
          _progress = 0.1;
        });
      }
      await TranslationService.initialize();
      // Mettre à jour avec la traduction après init
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('loading_translations');
        });
      }
      print('[Loading] ✅ Traductions chargées');

      // ⚡ NOUVEAU: Étape 1.5: Cache SharedPreferences
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('initializing_cache');
          _progress = 0.15;
        });
      }
      await CachedPreferencesService.initialize().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('[Loading] ⏰ Timeout CachedPrefs');
        },
      );
      print('[Loading] ✅ CachedPreferencesService OK');

      // Étape 2: Firebase
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('connecting_firebase');
          _progress = 0.2;
        });
      }
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('[Loading] ⏰ Timeout Firebase');
            throw TimeoutException('Firebase timeout');
          },
        );
        print('[Loading] ✅ Firebase OK');
      } catch (e) {
        print('[Loading] ⚠️ Firebase désactivé: $e');
      }

      // Étape 3: MobileAds
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('initializing_ads');
          _progress = 0.3;
        });
      }
      try {
        await MobileAds.instance.initialize().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('[Loading] ⏰ Timeout MobileAds');
            throw TimeoutException('MobileAds timeout');
          },
        );
        print('[Loading] ✅ MobileAds OK');
      } catch (e) {
        print('[Loading] ⚠️ MobileAds skip: $e');
      }

      // ⚡ OPTIMISÉ: Étape 4: Audio (NON-BLOQUANT)
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('initializing_audio');
          _progress = 0.4;
        });
      }
      try {
        await UnifiedAudioServiceOptimized.instance.initialize().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('[Loading] ⏰ Timeout AudioServiceOpt');
          },
        );
        print('[Loading] ✅ AudioServiceOpt OK');
      } catch (e) {
        print('[Loading] ⚠️ Audio skip (non bloquant): $e');
      }

      // Étape 5: TTS
      // ⚠️ DÉSACTIVÉ TEMPORAIREMENT - Cause des crashs "Reply already submitted"
      // setState(() {
      //   _loadingText = 'Initialisation synthèse vocale...';
      //   _progress = 0.5;
      // });
      // try {
      //   await MultilingualTTSService.initialize().timeout(
      //     const Duration(seconds: 3),
      //     onTimeout: () {
      //       print('[Loading] ⏰ Timeout TTS');
      //     },
      //   );
      //   print('[Loading] ✅ TTS OK');
      // } catch (e) {
      //   print('[Loading] ⚠️ TTS skip: $e');
      // }
      print('[Loading] ⚠️ TTS désactivé temporairement (crashs détectés)');

      // ⚡ OPTIMISÉ: Étape 6: Questions (RAPIDE: 2-3s au lieu de 10-15s!)
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('loading_questions');
          _progress = 0.6;
        });
      }
      await QuestionServiceOptimized.loadEssentialQuestions().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('[Loading] ⏰ Timeout Questions - Continuer quand même');
        },
      );
      print('[Loading] ✅ QuestionServiceOpt OK (catégories essentielles)');

      // Étape 7: Progression (avec cache)
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('loading_progress');
          _progress = 0.8;
        });
      }
      await ProgressService.loadProgress().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('[Loading] ⏰ Timeout ProgressService');
        },
      );
      print('[Loading] ✅ Progression chargée');

      // Étape 6: Services secondaires (rapide)
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('finalizing');
          _progress = 0.9;
        });
      }
      _initializeSecondaryServices();

      // Attendre un peu pour l'animation
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigation vers HomeScreen
      if (mounted) {
        setState(() {
          _loadingText = TranslationService.translate('ready');
          _progress = 1.0;
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e, stack) {
      print('[Loading] ❌ Erreur fatale: $e');
      print(stack);

      // Afficher un message d'erreur
      if (mounted) {
        setState(() {
          _loadingText = 'Erreur de chargement';
        });
      }
    }
  }

  void _initializeSecondaryServices() async {
    try {
      await QuestionTranslationService.initialize();
      await AdService.initialize();
      await PurchaseService.initialize();
      await DynamicQuestionService.initialize();
      await CommunityQuestionService.initialize();
      await PaymentVerificationService.performPeriodicVerification();
      await PaymentVerificationService.cleanupExpiredVerifications();
      await NotificationService.instance.initialize();
      print('[Loading] ✅ Services secondaires OK');
    } catch (e) {
      print('[Loading] ⚠️ Erreur services secondaires: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo avec animation (identique à HomeScreen)
              ScaleTransition(
                scale: _pulseAnimation,
                child: Text(
                  'Quizz4U',
                  style: AppTextStyles.logo,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),

              // Texte de chargement
              Text(
                _loadingText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Barre de progression
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              // Version
              Text(
                'Quiz4U v2.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
