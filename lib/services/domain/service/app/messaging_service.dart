
part of 'app_service_imports.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  debugPrint("Handling a background message: ${message.messageId}");
}

void onDidReceiveLocalNotificationResponse(NotificationResponse response) {
  if(response.payload != null) {
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
  Future<MessagingService> init() async {
    try {
      await initializeLocalNotifications();

      manageNotificationChannel();

      // Request runtime permission (iOS + Android 13+)
      await requestPermission();

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get FCM token (after permission ideally)
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM token: $token');

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('notification_icon'),
          iOS: DarwinInitializationSettings(), // if you want inline iOS settings override, set here
        ),
        onDidReceiveNotificationResponse: onDidReceiveLocalNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveLocalNotificationResponse,
      );
    } catch (e, st) {
      debugPrint('MessagingService.init error: $e\n$st');
    }
    debugPrint('Messaging service is initialized');
    return this;
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Request permission for notifications (handles Android 13+ and iOS)
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


  // void requestPermission() async {
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //   debugPrint('User granted permission: ${settings.authorizationStatus}');
  // }

  void _onForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notification_icon');
    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'foreground_notifications',
            'App Foreground Notification',
            icon: 'notification_icon',
            // color: Color(0xff4F545C)
          ),
        ),
        // payload: FirebaseNotificationModel.fromJson(message.data).toRawJson()
      );
    }
  }

  Future<void> initializeLocalNotifications() async {
    // DON'T redeclare flutterLocalNotificationsPlugin here — use the class field
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('notification_icon');
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
        onDidReceiveNotificationResponse: onDidReceiveLocalNotificationResponse
    );
  }



  void manageNotificationChannel() async {

      // Channel to show notification when app is in foreground
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