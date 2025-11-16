// ---------- services/domain/service/app/app_service_imports.dart (part file) ----------
part of 'app_service_imports.dart';


// NOTE: keep the model import in your real file if not covered by the part.
// import '../../../models/firebase_notification_model.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  debugPrint("Handling a background message: ${message.messageId}");
}

void onDidReceiveLocalNotificationResponse(NotificationResponse response) {
  if (response.payload != null) {
    // var firebaseNotification = FirebaseNotificationModel.fromRawJson(response.payload!);

    // if (firebaseNotification.path != null) {
    //   // Get.toNamed(firebaseNotification.path!);
    // }
  }
}

void onMessageOpenedApp(RemoteMessage message) {
  // var firebaseNotification = FirebaseNotificationModel.fromJson(message.data);

  // if (firebaseNotification.path != null) {
  //   // Get.toNamed(firebaseNotification.path!);
  // }
}

class MessagingService {
  // SINGLETON GUARD: prevent double initialization of listeners / plugins
  bool _initialized = false;

  // FCM + Local notifications instances
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Deduplication cache to avoid duplicate shows when FCM delivers same message multiple times
  final Map<String, DateTime> _recentMessageCache = <String, DateTime>{};
  Timer? _cacheCleanupTimer;

  /// Initialize messaging service (idempotent)
  Future<MessagingService> init() async {
    if (_initialized) return this;
    _initialized = true;

    try {
      // Local plugin init (only place where plugin is initialized)
      await initializeLocalNotifications();

      // Create/manage channels
      await manageNotificationChannel();

      // Request runtime permission (iOS + Android 13+)
      await requestPermission();

      // Setup background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get FCM token (after permission ideally)
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM token: $token');

      // Foreground and opened-app listeners
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    } catch (e, st) {
      debugPrint('MessagingService.init error: $e\n$st');
    }

    debugPrint('Messaging service is initialized');
    return this;
  }

  /// Stop/cleanup resources if needed
  void dispose() {
    _stopCacheCleanup();
    // Currently no direct dispose for FirebaseMessaging listeners (they are StreamSubscriptions inside plugin).
    // If you store subscriptions manually, cancel them here.
  }

  // ===========================
  // Permissions
  // ===========================
  Future<void> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        // On Android use permission_handler to request POST_NOTIFICATIONS on API 33+
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final requested = await Permission.notification.request();
          debugPrint('Android notification permission: $requested');
        } else {
          debugPrint('Android notification permission already granted');
        }
      } else if (Platform.isIOS) {
        // Use Firebase Messaging's requestPermission on iOS
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        debugPrint('iOS notification authorizationStatus: ${settings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('requestPermission error: $e');
    }
  }

  Future<String?> getFirebaseToken() async => await messaging.getToken();
  Future<RemoteMessage?> getInitialMessage() async => await messaging.getInitialMessage();

  // ===========================
  // Foreground handling + de-duplication
  // ===========================
  void _onForegroundMessage(RemoteMessage message) {
    try {
      // Build deduplication key: prefer stable messageId, fallback to combination
      final String key = message.messageId ??
          '${message.notification?.title ?? ''}|${message.notification?.body ?? ''}|${message.data.hashCode}';

      final now = DateTime.now();
      final existing = _recentMessageCache[key];
      if (existing != null && now.difference(existing).inSeconds < 30) {
        debugPrint('MessagingService: skipping duplicate foreground message (key=$key)');
        return;
      }

      // Record show time
      _recentMessageCache[key] = now;

      // Ensure cleanup timer running
      _cacheCleanupTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
        final threshold = DateTime.now().subtract(const Duration(seconds: 60));
        _recentMessageCache.removeWhere((_, dt) => dt.isBefore(threshold));
      });

      // Determine title/body to show. Prefer notification payload, fallback to data fields.
      String? title = message.notification?.title?.toString();
      String? body = message.notification?.body?.toString();

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        // fallback to data fields if available
        title = message.data['title']?.toString();
        body = message.data['body']?.toString();
      }

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        debugPrint('MessagingService: foreground message has no title/body — nothing to show.');
        return;
      }

      String? payload;
      try {
        // If you have a model for payload, use it — otherwise fallback to raw map string
        payload = FirebaseNotificationModel.fromJson(message.data).toRawJson();
      } catch (_) {
        try {
          payload = message.data.isNotEmpty ? message.data.toString() : null;
        } catch (_) {
          payload = null;
        }
      }

      debugPrint('MessagingService: showing foreground notification (key=$key, title=$title)');

      flutterLocalNotificationsPlugin.show(
        key.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'foreground_notifications',
            'App Foreground Notification',
            icon: 'notification_icon',
            // color: Color(0xff4F545C)
          ),
        ),
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('MessagingService._onForegroundMessage error: $e\n$st');
    }
  }

  void _stopCacheCleanup() {
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = null;
  }

  // ===========================
  // Local notifications initialization
  // ===========================
  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notification_icon');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveLocalNotificationResponse,
    );
  }

  // ===========================
  // Notification channels (Android)
  // ===========================
  Future<void> manageNotificationChannel() async {
    const AndroidNotificationChannel foregroundNotificationChannel = AndroidNotificationChannel(
      'foreground_notifications',
      'App Foreground Notification',
      description: 'Show notifications when app is in foreground',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundNotificationChannel);
  }
}

// ---------------------------
// NOTE:
// - Keep FirebaseNotificationModel available in your project. The code above attempts to use it
//   for payload serialization but falls back to raw map string if model conversion fails.
// - This file is a PART file; ensure it is included correctly in your library (app_service_imports.dart).
// - Do not call flutterLocalNotificationsPlugin.initialize(...) elsewhere — initializeLocalNotifications()
//   above is the single place for initialization in this class.
// - If you also initialize local notifications outside this class, remove duplicate initialization to avoid duplicate handlers.
