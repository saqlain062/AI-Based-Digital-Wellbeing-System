import 'package:flutter/material.dart';

import '../../core/notifications/notification_debug_helper.dart';
import '../../services/hive_service.dart';
import '../../services/reminder_notification_service.dart';
import '../dashboard/ai_module_widgets.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late bool reminderEnabled;
  late int reminderHour;
  late int reminderMinute;
  final NotificationDebugHelper _debugHelper = NotificationDebugHelper();

  @override
  void initState() {
    super.initState();
    reminderEnabled = HiveService.instance.getReminderEnabled();
    final reminderTime = HiveService.instance.getReminderTime();
    reminderHour = reminderTime.hour;
    reminderMinute = reminderTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay(
      hour: reminderHour,
      minute: reminderMinute,
    ).format(context);

    return AiModuleScaffold(
      title: 'Reminder Settings',
      subtitle: 'Manage the daily reminder that supports your phone habit check-ins.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(
              child: AiGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionTitle(
                      icon: Icons.notifications_active_outlined,
                      title: 'Daily Reminder',
                      color: AiModulePalette.teal,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: reminderEnabled,
                      activeColor: AiModulePalette.teal,
                      title: const Text('Enable reminder'),
                      subtitle: Text(
                        reminderEnabled
                            ? 'Reminder scheduled for $timeLabel'
                            : 'Turn on a daily reminder for your check-in.',
                      ),
                      onChanged: _handleReminderToggle,
                    ),
                    if (reminderEnabled) ...[
                      const SizedBox(height: 12),
                      AiSecondaryButton(
                        label: 'Change reminder time',
                        onPressed: _pickReminderTime,
                      ),
                      const SizedBox(height: 12),
                      AiSecondaryButton(
                        label: 'Send test notification',
                        onPressed: _sendTestNotification,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReminderToggle(bool enabled) async {
    if (!enabled) {
      await ReminderNotificationService.cancelDailyReminder();
      HiveService.instance.saveReminderEnabled(false);
      setState(() => reminderEnabled = false);
      return;
    }

    final granted = await ReminderNotificationService.requestPermission();
    if (!granted) return;

    await ReminderNotificationService.scheduleDailyReminder(
      hour: reminderHour,
      minute: reminderMinute,
    );
    HiveService.instance.saveReminderEnabled(true);
    setState(() => reminderEnabled = true);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminderHour, minute: reminderMinute),
    );
    if (picked == null) return;

    setState(() {
      reminderHour = picked.hour;
      reminderMinute = picked.minute;
    });
    HiveService.instance.saveReminderTime(
      hour: reminderHour,
      minute: reminderMinute,
    );

    if (reminderEnabled) {
      await ReminderNotificationService.scheduleDailyReminder(
        hour: reminderHour,
        minute: reminderMinute,
      );
    }
  }

  Future<void> _sendTestNotification() async {
    final granted = await ReminderNotificationService.requestPermission();
    if (!granted) {
      return;
    }
    await _debugHelper.showInstantTestNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent. Check your notification tray.'),
      ),
    );
  }
}
