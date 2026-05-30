import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_scheduler.dart';

class NotificationDebugHelper {
  NotificationDebugHelper({
    FlutterLocalNotificationsPlugin? plugin,
    NotificationScheduler? scheduler,
  }) : scheduler = scheduler ?? NotificationScheduler(plugin: plugin);

  final NotificationScheduler scheduler;

  Future<void> showInstantTestNotification() {
    return scheduler.showInstantTestNotification();
  }

  Future<void> scheduleTestNotification(Duration delay) {
    return scheduler.scheduleTestNotification(delay: delay);
  }

  Future<List<PendingNotificationRequest>> listPendingNotifications() {
    return scheduler.pendingRequests();
  }

  Future<void> cancelAllTestNotifications() async {
    await scheduler.cancelTestNotifications();
  }
}
