import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../services/hive_service.dart';
import 'notification_constants.dart';
import 'notification_ids.dart';
import 'notification_payload_handler.dart';
import 'notification_preferences.dart';
import 'notification_service.dart';

class NotificationScheduler {
  NotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : plugin = plugin ?? NotificationService.instance.plugin;

  final FlutterLocalNotificationsPlugin plugin;

  Future<void> restoreFromSettings() async {
    await NotificationService.instance.initialize();
    final preferences = NotificationPreferences.fromHive(HiveService.instance);

    if (!preferences.notificationsEnabled) {
      await cancelAllManagedNotifications();
      return;
    }

    if (preferences.dailyReminderEnabled) {
      await scheduleDailyCheckInReminder(
        hour: preferences.dailyReminderHour,
        minute: preferences.dailyReminderMinute,
      );
    } else {
      await cancelDailyCheckInReminder();
      await cancelCoachReminder();
    }

    if (preferences.smartTrackingEnabled &&
        preferences.smartTrackingReminderEnabled) {
      await scheduleSmartTrackingReminder(
        hour: preferences.smartTrackingHour,
        frequency: preferences.smartTrackingFrequency,
      );
    } else {
      await cancelSmartTrackingReminder();
    }
  }

  Future<void> scheduleDailyCheckInReminder({
    required int hour,
    required int minute,
  }) async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.dailyCheckIn);

    await plugin.zonedSchedule(
      id: NotificationIds.dailyCheckIn,
      title: NotificationConstants.defaultDailyReminderTitle,
      body: NotificationConstants.defaultDailyReminderBody,
      scheduledDate: _nextInstanceOf(hour: hour, minute: minute),
      notificationDetails: _dailyReminderDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: NotificationPayloadHandler.home,
    );

    if (kDebugMode) {
      log('Scheduled daily wellbeing reminder at $hour:$minute');
    }
  }

  Future<void> scheduleCoachReminder({
    required int hour,
    required int minute,
  }) async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.coachChallenge);

    await plugin.zonedSchedule(
      id: NotificationIds.coachChallenge,
      title: NotificationConstants.defaultCoachTitle,
      body: _coachReminderBody(),
      scheduledDate: _nextInstanceOf(hour: hour, minute: minute),
      notificationDetails: _dailyReminderDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: NotificationPayloadHandler.coach,
    );

    if (kDebugMode) {
      log('Scheduled coach reminder at $hour:$minute');
    }
  }

  Future<void> scheduleSmartTrackingReminder({
    required int hour,
    required String frequency,
  }) async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.smartTracking);

    if (frequency == 'weekly') {
      await plugin.zonedSchedule(
        id: NotificationIds.smartTracking,
        title: NotificationConstants.defaultSmartTrackingTitle,
        body: NotificationConstants.defaultSmartTrackingWeeklyBody,
        scheduledDate: _nextWeekdayInstance(
          weekday: DateTime.monday,
          hour: hour,
          minute: 0,
        ),
        notificationDetails: _smartTrackingDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: NotificationPayloadHandler.home,
      );
    } else {
      await plugin.zonedSchedule(
        id: NotificationIds.smartTracking,
        title: NotificationConstants.defaultSmartTrackingTitle,
        body: NotificationConstants.defaultSmartTrackingDailyBody,
        scheduledDate: _nextInstanceOf(hour: hour, minute: 0),
        notificationDetails: _smartTrackingDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: NotificationPayloadHandler.home,
      );
    }

    if (kDebugMode) {
      log(
        'Scheduled smart tracking reminder at $hour:00 with $frequency frequency',
      );
    }
  }

  Future<void> showInstantTestNotification() async {
    await NotificationService.instance.initialize();
    await plugin.show(
      id: NotificationIds.testInstant,
      title: NotificationConstants.defaultTestTitle,
      body: NotificationConstants.defaultTestBody,
      notificationDetails: _testDetails(),
      payload: NotificationPayloadHandler.home,
    );
  }

  Future<void> scheduleTestNotification({
    Duration delay = const Duration(seconds: 10),
  }) async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.testScheduled);
    final when = DateTime.now().add(delay);
    await plugin.zonedSchedule(
      id: NotificationIds.testScheduled,
      title: NotificationConstants.defaultTestTitle,
      body: 'Scheduled test notification after ${delay.inSeconds} seconds.',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _testDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: NotificationPayloadHandler.home,
    );
  }

  Future<void> cancelDailyCheckInReminder() async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.dailyCheckIn);
  }

  Future<void> cancelCoachReminder() async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.coachChallenge);
  }

  Future<void> cancelSmartTrackingReminder() async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.smartTracking);
  }

  Future<void> cancelTestNotifications() async {
    await NotificationService.instance.initialize();
    await plugin.cancel(id: NotificationIds.testInstant);
    await plugin.cancel(id: NotificationIds.testScheduled);
  }

  Future<void> cancelAllManagedNotifications() async {
    await cancelDailyCheckInReminder();
    await cancelCoachReminder();
    await cancelSmartTrackingReminder();
    await cancelTestNotifications();
  }

  Future<List<PendingNotificationRequest>> pendingRequests() {
    return plugin.pendingNotificationRequests();
  }

  NotificationDetails _dailyReminderDetails() {
    const android = AndroidNotificationDetails(
      NotificationConstants.dailyReminderChannelId,
      NotificationConstants.dailyReminderChannelName,
      channelDescription: NotificationConstants.dailyReminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    return const NotificationDetails(android: android);
  }

  NotificationDetails _smartTrackingDetails() {
    const android = AndroidNotificationDetails(
      NotificationConstants.smartTrackingChannelId,
      NotificationConstants.smartTrackingChannelName,
      channelDescription:
          NotificationConstants.smartTrackingChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      category: AndroidNotificationCategory.reminder,
    );
    return const NotificationDetails(android: android);
  }

  NotificationDetails _testDetails() {
    const android = AndroidNotificationDetails(
      NotificationConstants.testChannelId,
      NotificationConstants.testChannelName,
      channelDescription: NotificationConstants.testChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    return const NotificationDetails(android: android);
  }

  String _coachReminderBody() {
    final selected = HiveService.instance.getSelectedCoachChallenge();
    switch (selected) {
      case 'reduce_social_media':
        return 'Try reducing social media by 20 minutes today.';
      case 'reduce_gaming':
        return 'Try keeping one gaming session shorter today.';
      case 'phone_free_bedtime':
        return 'Try a phone-free wind-down before sleep tonight.';
      case 'focus_session':
        return 'Try one quieter focus block with fewer phone checks.';
      default:
        return NotificationConstants.defaultCoachFallbackBody;
    }
  }

  tz.TZDateTime _nextInstanceOf({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekdayInstance({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    var scheduled = _nextInstanceOf(hour: hour, minute: minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
