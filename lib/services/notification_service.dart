import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[NotificationService] 🔄 Initialisation des notifications...');

      // Vérifier si Firebase est disponible
      try {
        await Firebase.initializeApp();
        print('[NotificationService] ✅ Firebase initialisé');
      } catch (e) {
        print('[NotificationService] ⚠️ Firebase non disponible: $e');
        // Continuer sans Firebase pour les notifications locales
      }

      // Demander les permissions
      await _requestPermissions();

      // Configurer les notifications locales
      await _setupLocalNotifications();

      // Configurer les handlers FCM seulement si Firebase est disponible
      try {
        await _setupFCMHandlers();
        await _getFCMToken();
      } catch (e) {
        print('[NotificationService] ⚠️ FCM non disponible: $e');
      }

      _isInitialized = true;
      print('[NotificationService] ✅ Service de notifications initialisé');
    } catch (e) {
      print('[NotificationService] ❌ Erreur initialisation: $e');
      _isInitialized = true; // Marquer comme initialisé même en cas d'erreur
    }
  }

  /// Demander les permissions de notification
  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print(
          '[NotificationService] 📱 Permissions: ${settings.authorizationStatus}');
    } catch (e) {
      print('[NotificationService] ⚠️ Erreur permissions FCM: $e');
      // Continuer sans FCM, les notifications locales fonctionneront
    }
  }

  /// Configurer les notifications locales
  Future<void> _setupLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('[NotificationService] ✅ Notifications locales configurées');
    } catch (e) {
      print('[NotificationService] ❌ Erreur notifications locales: $e');
    }
  }

  /// Configurer les handlers FCM
  Future<void> _setupFCMHandlers() async {
    try {
      // Notification reçue quand l'app est en premier plan
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Notification reçue quand l'app est en arrière-plan
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Notification reçue quand l'app est fermée
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      print('[NotificationService] ✅ Handlers FCM configurés');
    } catch (e) {
      print('[NotificationService] ⚠️ Erreur configuration FCM: $e');
      throw e; // Relancer l'erreur pour la gestion dans initialize()
    }
  }

  /// Obtenir le token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('[NotificationService] 🔑 Token FCM: $_fcmToken');

      // Sauvegarder le token
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('[NotificationService] 🔄 Nouveau token FCM: $newToken');
        _saveFCMToken(newToken);
      });
    } catch (e) {
      print('[NotificationService] ⚠️ Erreur token FCM: $e');
      throw e; // Relancer l'erreur pour la gestion dans initialize()
    }
  }

  /// Sauvegarder le token FCM
  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('[NotificationService] 💾 Token FCM sauvegardé');
    } catch (e) {
      print('[NotificationService] ❌ Erreur sauvegarde token: $e');
    }
  }

  /// Gérer les notifications en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    print(
        '[NotificationService] 📨 Notification reçue (premier plan): ${message.notification?.title}');

    _showLocalNotification(
      title: message.notification?.title ?? 'Quizz4U',
      body: message.notification?.body ?? 'Nouvelle notification',
      payload: message.data.toString(),
    );
  }

  /// Gérer les notifications en arrière-plan
  static void _handleBackgroundMessage(RemoteMessage message) {
    print(
        '[NotificationService] 📨 Notification reçue (arrière-plan): ${message.notification?.title}');
  }

  /// Gérer le tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    print('[NotificationService] 👆 Notification tapée: ${response.payload}');

    // Ici vous pouvez naviguer vers une page spécifique
    // selon le payload de la notification
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'quizz4u_channel',
        'Quizz4U Notifications',
        channelDescription: 'Notifications de l\'application Quizz4U',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('[NotificationService] ✅ Notification locale affichée');
    } catch (e) {
      print('[NotificationService] ❌ Erreur notification locale: $e');
    }
  }

  /// Envoyer une notification de test
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Quizz4U',
      body: 'Ceci est une notification de test !',
      payload: 'test',
    );
  }

  /// Envoyer une notification de rappel
  Future<void> sendReminderNotification() async {
    await _showLocalNotification(
      title: '🎯 Rappel Quizz4U',
      body: 'Il est temps de tester vos connaissances ! Revenez jouer.',
      payload: 'reminder',
    );
  }

  /// Envoyer une notification de nouveauté
  Future<void> sendNewFeatureNotification(String feature) async {
    await _showLocalNotification(
      title: '🆕 Nouvelle fonctionnalité',
      body: 'Découvrez : $feature',
      payload: 'new_feature',
    );
  }

  /// Obtenir le token FCM
  String? get fcmToken => _fcmToken;

  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Nettoyer les ressources
  Future<void> dispose() async {
    try {
      await _localNotifications.cancelAll();
      _isInitialized = false;
      print('[NotificationService] 🧹 Ressources libérées');
    } catch (e) {
      print('[NotificationService] ❌ Erreur nettoyage: $e');
    }
  }
}

// Handler pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
      '[NotificationService] 📨 Background message: ${message.notification?.title}');
}
