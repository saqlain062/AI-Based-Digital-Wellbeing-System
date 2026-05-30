import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_constants.dart';
import 'notification_payload_handler.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _initialPayload;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        NotificationPayloadHandler.handle(response.payload);
      },
    );

    await _createAndroidChannels();
    final launchDetails = await plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _initialPayload = launchDetails?.notificationResponse?.payload;
    }

    _initialized = true;
    if (kDebugMode) {
      log('AI Wellbeing notifications initialized');
    }
  }

  Future<void> handleInitialPayloadIfAny() async {
    final payload = _initialPayload;
    _initialPayload = null;
    if (payload == null || payload.isEmpty) {
      return;
    }
    NotificationPayloadHandler.handle(payload);
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (error) {
      if (kDebugMode) {
        log('Could not configure notification timezone: $error');
      }
      tz.setLocalLocation(tz.local);
    }
  }

  Future<void> _createAndroidChannels() async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return;
    }

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationConstants.dailyReminderChannelId,
        NotificationConstants.dailyReminderChannelName,
        description: NotificationConstants.dailyReminderChannelDescription,
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationConstants.smartTrackingChannelId,
        NotificationConstants.smartTrackingChannelName,
        description: NotificationConstants.smartTrackingChannelDescription,
        importance: Importance.defaultImportance,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationConstants.testChannelId,
        NotificationConstants.testChannelName,
        description: NotificationConstants.testChannelDescription,
        importance: Importance.high,
      ),
    );
  }
}
