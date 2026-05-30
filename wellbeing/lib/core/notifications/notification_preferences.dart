import '../../services/hive_service.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.notificationsEnabled,
    required this.dailyReminderEnabled,
    required this.dailyReminderHour,
    required this.dailyReminderMinute,
    required this.smartTrackingEnabled,
    required this.smartTrackingHour,
    required this.smartTrackingFrequency,
    required this.smartTrackingReminderEnabled,
  });

  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool smartTrackingEnabled;
  final int smartTrackingHour;
  final String smartTrackingFrequency;
  final bool smartTrackingReminderEnabled;

  factory NotificationPreferences.fromHive(HiveService hive) {
    final reminderTime = hive.getReminderTime();
    return NotificationPreferences(
      notificationsEnabled: hive.getNotificationsEnabled(),
      dailyReminderEnabled: hive.getReminderEnabled(),
      dailyReminderHour: reminderTime.hour,
      dailyReminderMinute: reminderTime.minute,
      smartTrackingEnabled: hive.getBool(
        'smartTrackingEnabled',
        defaultValue: false,
      ),
      smartTrackingHour: (hive.getUser('smartTrackingHour') ?? 8) as int,
      smartTrackingFrequency:
          (hive.getUser('smartTrackingFrequency') ?? 'daily') as String,
      smartTrackingReminderEnabled: hive.getBool(
        'smartTrackingNotificationsEnabled',
        defaultValue: true,
      ),
    );
  }
}
