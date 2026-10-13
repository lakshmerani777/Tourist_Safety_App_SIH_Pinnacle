import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper around flutter_local_notifications for local push notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification plugin. Call once in main().
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Request notification permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('[NotificationService] Initialized');
  }

  /// Show a location anomaly notification.
  Future<void> showAnomalyNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'safety_alerts',
      'Safety Alerts',
      channelDescription: 'Notifications for unusual location activity',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFEF4444),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      1001, // Notification ID for anomaly alerts
      '⚠️ Location Update Stopped',
      'Your GPS location has stopped updating. Are you safe? Open the app to resume sharing.',
      details,
    );
  }

  /// Cancel the anomaly notification (e.g., when location resumes).
  Future<void> cancelAnomalyNotification() async {
    await _plugin.cancel(1001);
  }

  /// Show a police-issued safety alert notification.
  Future<void> showAlertNotification({
    required String title,
    required String body,
    required String severity,
  }) async {
    final color = severity == 'HIGH'
        ? const Color(0xFFEF4444)
        : severity == 'MEDIUM'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF3B82F6);

    final androidDetails = AndroidNotificationDetails(
      'police_alerts',
      'Police Alerts',
      channelDescription: 'Safety alerts issued by police via the dashboard',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: color,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use hashCode of title + timestamp for unique ID
    final notifId = title.hashCode.abs() % 100000 + 2000;

    await _plugin.show(
      notifId,
      '🚨 $title',
      body,
      details,
    );
  }
}
