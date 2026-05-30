import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/notifications/notification_settings_controller.dart';
import '../dashboard/ai_module_widgets.dart';

class NotificationSettingsScreen extends StatelessWidget {
  NotificationSettingsScreen({super.key});

  final NotificationSettingsController controller =
      Get.put(NotificationSettingsController(), tag: 'notification_settings');

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Notifications',
      subtitle: 'Manage local reminders for check-ins, smart tracking, and daily habits.',
      showBack: true,
      child: Obx(() {
        final reminderTime = TimeOfDay(
          hour: controller.reminderHour.value,
          minute: controller.reminderMinute.value,
        ).format(context);

        return SingleChildScrollView(
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
                        title: 'Notification preferences',
                        color: AiModulePalette.teal,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: controller.notificationsEnabled.value,
                        activeColor: AiModulePalette.teal,
                        title: const Text('Enable notifications'),
                        subtitle: const Text(
                          'Turn local reminders on or off across the app.',
                        ),
                        onChanged: controller.setNotificationsEnabled,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: controller.dailyReminderEnabled.value,
                        activeColor: AiModulePalette.teal,
                        title: const Text('Daily reminder'),
                        subtitle: Text(
                          controller.dailyReminderEnabled.value
                              ? 'Scheduled for $reminderTime'
                              : 'Get one daily reminder for your phone habit check-in.',
                        ),
                        onChanged: controller.notificationsEnabled.value
                            ? controller.setDailyReminderEnabled
                            : null,
                      ),
                      if (controller.notificationsEnabled.value) ...[
                        const SizedBox(height: 12),
                        AiSecondaryButton(
                          label: 'Reminder time',
                          onPressed: () => _pickReminderTime(context),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: controller.smartTrackingReminderEnabled.value,
                        activeColor: AiModulePalette.teal,
                        title: const Text('Smart tracking reminder'),
                        subtitle: const Text(
                          'Remind me when a scheduled smart tracking refresh is due.',
                        ),
                        onChanged: controller.notificationsEnabled.value
                            ? controller.setSmartTrackingReminderEnabled
                            : null,
                      ),
                      if (controller.notificationsEnabled.value) ...[
                        const SizedBox(height: 12),
                        AiSecondaryButton(
                          label: 'Test notification',
                          onPressed: _sendTestNotification,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 80,
                child: AiGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AiSectionTitle(
                        icon: Icons.info_outline_rounded,
                        title: 'Local-only reminders',
                        color: AiModulePalette.blue,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'These reminders are scheduled on your device. No account or cloud service is used.',
                        style: TextStyle(
                          color: AiModulePalette.textSecondary(context),
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.reminderHour.value,
        minute: controller.reminderMinute.value,
      ),
    );
    if (picked == null) return;

    await controller.updateReminderTime(
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  Future<void> _sendTestNotification() async {
    final granted = await controller.requestPermission();
    if (!granted) return;

    await controller.sendTestNotification();
    Get.snackbar(
      'Notification sent',
      'Check your notification tray for the test reminder.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
