import 'package:get/get.dart';

import '../../services/hive_service.dart';
import '../../services/reminder_notification_service.dart';
import '../../services/smart_tracking_service.dart';
import 'notification_debug_helper.dart';
import 'notification_permission_service.dart';

class NotificationSettingsController extends GetxController {
  NotificationSettingsController({
    HiveService? hiveService,
    NotificationPermissionService? permissionService,
    NotificationDebugHelper? debugHelper,
  }) : _hive = hiveService ?? HiveService.instance,
       _permissionService = permissionService ?? NotificationPermissionService(),
       _debugHelper = debugHelper ?? NotificationDebugHelper();

  final HiveService _hive;
  final NotificationPermissionService _permissionService;
  final NotificationDebugHelper _debugHelper;

  final notificationsEnabled = true.obs;
  final dailyReminderEnabled = false.obs;
  final reminderHour = 20.obs;
  final reminderMinute = 30.obs;
  final smartTrackingReminderEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    notificationsEnabled.value = _hive.getNotificationsEnabled();
    dailyReminderEnabled.value = _hive.getReminderEnabled();
    final time = _hive.getReminderTime();
    reminderHour.value = time.hour;
    reminderMinute.value = time.minute;
    smartTrackingReminderEnabled.value = _hive.getBool(
      'smartTrackingNotificationsEnabled',
      defaultValue: true,
    );
  }

  Future<bool> requestPermission() {
    return _permissionService.requestNotificationPermission();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await requestPermission();
      if (!granted) return;
      _hive.saveNotificationsEnabled(true);
      notificationsEnabled.value = true;
      await ReminderNotificationService.restoreSavedReminder();
      await SmartTrackingService.updateSettings(
        hour: (_hive.getUser('smartTrackingHour') ?? 8) as int,
        frequency: (_hive.getUser('smartTrackingFrequency') ?? 'daily') as String,
        notificationsEnabled: smartTrackingReminderEnabled.value,
      );
      return;
    }

    _hive.saveNotificationsEnabled(false);
    notificationsEnabled.value = false;
    await ReminderNotificationService.cancelDailyReminder();
    await SmartTrackingService.updateSettings(
      hour: (_hive.getUser('smartTrackingHour') ?? 8) as int,
      frequency: (_hive.getUser('smartTrackingFrequency') ?? 'daily') as String,
      notificationsEnabled: false,
    );
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    if (!notificationsEnabled.value) return;
    if (enabled) {
      final granted = await requestPermission();
      if (!granted) return;
      await ReminderNotificationService.scheduleDailyReminder(
        hour: reminderHour.value,
        minute: reminderMinute.value,
      );
    } else {
      await ReminderNotificationService.cancelDailyReminder();
    }

    _hive.saveReminderEnabled(enabled);
    dailyReminderEnabled.value = enabled;
  }

  Future<void> updateReminderTime({
    required int hour,
    required int minute,
  }) async {
    reminderHour.value = hour;
    reminderMinute.value = minute;
    _hive.saveReminderTime(hour: hour, minute: minute);

    if (dailyReminderEnabled.value) {
      await ReminderNotificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> setSmartTrackingReminderEnabled(bool enabled) async {
    if (!notificationsEnabled.value && enabled) return;
    if (enabled) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    smartTrackingReminderEnabled.value = enabled;
    await SmartTrackingService.updateSettings(
      hour: (_hive.getUser('smartTrackingHour') ?? 8) as int,
      frequency: (_hive.getUser('smartTrackingFrequency') ?? 'daily') as String,
      notificationsEnabled: enabled,
    );
  }

  Future<void> sendTestNotification() {
    return _debugHelper.showInstantTestNotification();
  }
}
