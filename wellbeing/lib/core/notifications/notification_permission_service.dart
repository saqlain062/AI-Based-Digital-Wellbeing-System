import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

class NotificationPermissionService {
  NotificationPermissionService({FlutterLocalNotificationsPlugin? plugin})
    : plugin = plugin ?? NotificationService.instance.plugin;

  final FlutterLocalNotificationsPlugin plugin;

  Future<bool> requestNotificationPermission() async {
    await NotificationService.instance.initialize();

    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    final granted = androidGranted && iosGranted;

    if (kDebugMode) {
      log('Notification permission granted=$granted');
    }
    return granted;
  }
}
