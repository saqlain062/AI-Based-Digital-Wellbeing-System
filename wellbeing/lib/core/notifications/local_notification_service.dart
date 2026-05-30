import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  FlutterLocalNotificationsPlugin get plugin => NotificationService.instance.plugin;

  Future<void> initialize() => NotificationService.instance.initialize();

  Future<void> handleInitialPayloadIfAny() {
    return NotificationService.instance.handleInitialPayloadIfAny();
  }
}
