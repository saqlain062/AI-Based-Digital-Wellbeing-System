import '../core/notifications/notification_permission_service.dart';
import '../core/notifications/notification_scheduler.dart';
import '../core/notifications/notification_service.dart';

class ReminderNotificationService {
  ReminderNotificationService._();

  static final NotificationScheduler _scheduler = NotificationScheduler();
  static final NotificationPermissionService _permissionService =
      NotificationPermissionService();

  static Future<void> initialize() async {
    await NotificationService.instance.initialize();
  }

  static Future<bool> requestPermission() {
    return _permissionService.requestNotificationPermission();
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _scheduler.scheduleDailyCheckInReminder(hour: hour, minute: minute);
    await _scheduler.scheduleCoachReminder(hour: hour, minute: minute);
  }

  static Future<void> cancelDailyReminder() async {
    await _scheduler.cancelDailyCheckInReminder();
    await _scheduler.cancelCoachReminder();
  }

  static Future<void> restoreSavedReminder() async {
    await _scheduler.restoreFromSettings();
  }
}
