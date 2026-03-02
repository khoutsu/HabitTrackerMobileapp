import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:loop_habit_tracker/core/constants/notification_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");

  // If the message contains a notification object, Android system UI handles it
  // automatically when the app is in background.
  if (message.notification != null) {
    debugPrint(
      "Notification object present, letting system handle background display.",
    );
    return;
  }

  // Check for special data types or explicit title/body in data
  final data = message.data;
  if (data.containsKey(NotificationConstants.typeKey) ||
      (data.containsKey(NotificationConstants.titleKey) &&
          data.containsKey(NotificationConstants.bodyKey))) {
    final type = data[NotificationConstants.typeKey];
    String? title = data[NotificationConstants.titleKey];
    String? body = data[NotificationConstants.bodyKey];

    // Fallback to hardcoded strings if title/body not provided in data
    // This maintains backward compatibility while allowing dynamic content from server
    if (title == null || body == null) {
      if (type == NotificationConstants.typeMorning) {
        title ??= 'สวัสดีตอนเช้า! ☀️';
        body ??= 'ได้เวลาตรวจสอบกิจวัตร และเริ่มต้นวันใหม่อย่างสดใส';
      } else if (type == NotificationConstants.typeEvening) {
        title ??= 'แจ้งเตือน Habit Tracker';
        body ??= 'เหนื่อยไหมวันนี้? อย่าลืมบันทึกความสำเร็จของคุณก่อนนอนนะ 💤';
      }
    }

    if (title != null && body != null) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      // Need to normalize channel setup here as well for background isolate
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_stat_notification');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationConstants.channelId,
            NotificationConstants.channelName,
            channelDescription: NotificationConstants.channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// A stream that emits the payload string when a notification is selected
  final BehaviorSubject<String?> selectNotificationStream =
      BehaviorSubject<String?>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    // For Bangkok/Thailand
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_notification');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // General initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    await _createAndroidNotificationChannel();
    await _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    // 0. Set Background Handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 1. Request Permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2. Get Token (for testing)   -
    try {
      String? token = await messaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      // Logic mirrors background handler but runs in main isolate
      final data = message.data;
      if (data.containsKey(NotificationConstants.typeKey) ||
          (data.containsKey(NotificationConstants.titleKey) &&
              data.containsKey(NotificationConstants.bodyKey))) {
        final type = data[NotificationConstants.typeKey];
        String? title = data[NotificationConstants.titleKey];
        String? body = data[NotificationConstants.bodyKey];

        if (title == null || body == null) {
          if (type == NotificationConstants.typeMorning) {
            title ??= 'สวัสดีตอนเช้า! ☀️';
            body ??= 'ได้เวลาตรวจสอบกิจวัตร และเริ่มต้นวันใหม่อย่างสดใส';
          } else if (type == NotificationConstants.typeEvening) {
            title ??= 'แจ้งเตือน Habit Tracker';
            body ??=
                'เหนื่อยไหมวันนี้? อย่าลืมบันทึกความสำเร็จของคุณก่อนนอนนะ 💤';
          }
        }

        if (title != null && body != null) {
          flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecond,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                NotificationConstants.channelId,
                NotificationConstants.channelName,
                channelDescription: NotificationConstants.channelDescription,
                icon:
                    message.notification?.android?.smallIcon ??
                    '@drawable/ic_stat_notification',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            payload: message.data.isNotEmpty ? message.data.toString() : null,
          );
          return; // Handled as custom message
        }
      }

      // 4. Default Notification Handling (if NOT handled by 'type' logic above)
      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                NotificationConstants.channelId,
                NotificationConstants.channelName,
                channelDescription: NotificationConstants.channelDescription,
                icon: android.smallIcon,
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            payload: message.data.isNotEmpty ? message.data.toString() : null,
          );
        }
      }
    });

    // 4. Handle Background Message Tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      if (message.data.isNotEmpty) {
        selectNotificationStream.add(message.data.toString());
      } else {
        selectNotificationStream.add('firebase_background_click');
      }
    });
  }

  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    // Android 13+ permission request
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    // iOS permission request
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Handle notification tap when app is in foreground/background/terminated
  static void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    // Add to stream
    _instance.selectNotificationStream.add(payload);
  }

  // Handle background notification response (e.g., when app is terminated)
  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('background notification payload: $payload');
    }
    // Add to stream
    _instance.selectNotificationStream.add(payload);
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate, {
    String? payload,
    bool isDaily = false,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    // Ensure the scheduled date is in the correct timezone
    final tz.TZDateTime tzScheduledDate = scheduledDate is tz.TZDateTime
        ? scheduledDate
        : tz.TZDateTime.from(scheduledDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          fullScreenIntent: true,
          icon: '@drawable/ic_stat_notification',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: isDaily
          ? DateTimeComponents.time
          : matchDateTimeComponents,
      payload: payload,
    );
  }

  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(
      const Duration(seconds: 10),
    ); // 10 seconds delay

    await scheduleNotification(
      999,
      'Test Notification',
      'This is a test notification. If you see this, the system is working!',
      scheduledDate,
      payload: 'test_payload',
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Schedule daily reminders at specified times

  /// Subscribe to a topic for Firebase Cloud Messaging
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Cancel daily reminders (Local) - Keeping for cleanup if needed
  Future<void> cancelDailyReminders() async {
    await cancelNotification(800);
    await cancelNotification(2000);
  }
}
