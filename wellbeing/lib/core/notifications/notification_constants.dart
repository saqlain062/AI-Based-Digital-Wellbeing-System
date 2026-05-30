class NotificationConstants {
  NotificationConstants._();

  static const String appName = 'AI Wellbeing';

  static const String dailyReminderChannelId = 'wellbeing_daily_reminder';
  static const String dailyReminderChannelName = 'Daily reminders';
  static const String dailyReminderChannelDescription =
      'Daily check-in and coach reminders for AI Wellbeing.';

  static const String smartTrackingChannelId = 'wellbeing_smart_tracking';
  static const String smartTrackingChannelName = 'Smart tracking reminders';
  static const String smartTrackingChannelDescription =
      'Smart tracking reminders and scheduled wellbeing refresh prompts.';

  static const String testChannelId = 'wellbeing_debug_test';
  static const String testChannelName = 'Notification tests';
  static const String testChannelDescription =
      'Test notifications for debugging reminder setup.';

  static const String defaultDailyReminderTitle = 'Daily reminder';
  static const String defaultDailyReminderBody =
      'Open AI Wellbeing for a quick phone habit check-in.';

  static const String defaultSmartTrackingTitle = 'Smart tracking check-in';
  static const String defaultSmartTrackingDailyBody =
      'Your daily smart tracking refresh is due. Open the app to review your latest pattern.';
  static const String defaultSmartTrackingWeeklyBody =
      'Your weekly smart tracking refresh is due. Open the app to review your latest pattern.';

  static const String defaultCoachTitle = 'Today\'s challenge';
  static const String defaultCoachFallbackBody =
      'Open Coach and choose one small action for today.';

  static const String defaultTestTitle = 'AI Wellbeing test';
  static const String defaultTestBody =
      'Notifications are working on this device.';
}
