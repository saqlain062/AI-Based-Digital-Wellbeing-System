# Notification Module

This folder contains the local notification layer used by AI Wellbeing. It is designed to stay local-first and reusable for future Flutter apps.

## Required dependencies

Add these packages to `pubspec.yaml`:

- `flutter_local_notifications`
- `timezone`
- `flutter_timezone`

If your app also needs scheduled background refresh logic, keep `workmanager` in the app-level dependencies.

## Android permissions and setup

Add these permissions to `AndroidManifest.xml`:

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`

For `flutter_local_notifications`, also register:

- `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver`
- `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver`

## Main initialization

Initialize notifications at app startup:

```dart
await NotificationService.instance.initialize();
await NotificationScheduler().restoreFromSettings();
```

After `runApp`, handle notification-tap payloads:

```dart
await NotificationService.instance.handleInitialPayloadIfAny();
```

## Core files

- `local_notification_service.dart`
  - thin reusable entry point for initialization and plugin access
- `notification_service.dart`
  - plugin initialization, channels, timezone setup, tap callback wiring
- `notification_scheduler.dart`
  - schedules, cancels, restores, and test notifications
- `notification_permission_service.dart`
  - runtime notification permission request handling
- `notification_preferences.dart`
  - reads notification-related settings from the app storage layer
- `notification_constants.dart`
  - channel IDs, default titles, and default message strings
- `notification_payload_handler.dart`
  - app-specific navigation/callback handling for notification taps
- `notification_settings_controller.dart`
  - optional GetX controller for settings screens

## Scheduling a notification

Example daily reminder:

```dart
await NotificationScheduler().scheduleDailyCheckInReminder(
  hour: 20,
  minute: 30,
);
```

Example smart tracking reminder:

```dart
await NotificationScheduler().scheduleSmartTrackingReminder(
  hour: 8,
  frequency: 'daily',
);
```

## Cancelling notifications

```dart
await NotificationScheduler().cancelDailyCheckInReminder();
await NotificationScheduler().cancelSmartTrackingReminder();
await NotificationScheduler().cancelCoachReminder();
```

## Test notifications

```dart
await NotificationDebugHelper().showInstantTestNotification();
```

## App-specific integration points

When copying this folder to a future app, these are the parts most likely to need changes:

1. `notification_constants.dart`
   - app name
   - channel IDs
   - default reminder titles/bodies

2. `notification_payload_handler.dart`
   - where the app should navigate when a notification is tapped

3. `notification_preferences.dart`
   - how the app reads reminder settings from local storage

4. `notification_scheduler.dart`
   - any app-specific reminder text, such as challenge-based messages

## Privacy model

This module is local-first:

- no Firebase
- no cloud messaging
- no account system
- no server-side behaviour tracking

All scheduling and preference storage happen on-device.
