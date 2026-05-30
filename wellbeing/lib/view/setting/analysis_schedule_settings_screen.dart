import 'package:flutter/material.dart';

import '../../core/notifications/notification_permission_service.dart';
import '../../services/hive_service.dart';
import '../../services/smart_tracking_service.dart';
import '../dashboard/ai_module_widgets.dart';

class AnalysisScheduleSettingsScreen extends StatefulWidget {
  const AnalysisScheduleSettingsScreen({super.key});

  @override
  State<AnalysisScheduleSettingsScreen> createState() =>
      _AnalysisScheduleSettingsScreenState();
}

class _AnalysisScheduleSettingsScreenState
    extends State<AnalysisScheduleSettingsScreen> {
  final NotificationPermissionService _permissionService =
      NotificationPermissionService();
  late int trackingHour;
  late String trackingFrequency;
  late bool notificationsEnabled;

  @override
  void initState() {
    super.initState();
    trackingHour = (HiveService.instance.getUser('smartTrackingHour') ?? 8) as int;
    trackingFrequency =
        (HiveService.instance.getUser('smartTrackingFrequency') ?? 'daily')
            as String;
    notificationsEnabled = HiveService.instance.getBool(
      'smartTrackingNotificationsEnabled',
      defaultValue: true,
    );
  }

  Future<void> _save() async {
    await SmartTrackingService.updateSettings(
      hour: trackingHour,
      frequency: trackingFrequency,
      notificationsEnabled: notificationsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Analysis Schedule',
      subtitle: 'Set when automatic analysis runs and how often it refreshes.',
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
                      icon: Icons.schedule_rounded,
                      title: 'Schedule',
                      color: AiModulePalette.teal,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: trackingHour,
                      decoration: const InputDecoration(
                        labelText: 'Daily analysis time',
                      ),
                      items: List.generate(
                        24,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text('${index.toString().padLeft(2, '0')}:00'),
                        ),
                      ),
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() => trackingHour = value);
                        await _save();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: trackingFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Refresh frequency',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() => trackingFrequency = value);
                        await _save();
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: notificationsEnabled,
                      activeColor: AiModulePalette.teal,
                      title: const Text('Smart tracking reminder'),
                      subtitle: const Text(
                        'Get a reminder when the scheduled smart tracking refresh is due.',
                      ),
                      onChanged: (value) async {
                        if (value) {
                          final granted = await _permissionService
                              .requestNotificationPermission();
                          if (!granted) {
                            return;
                          }
                        }
                        setState(() => notificationsEnabled = value);
                        await _save();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
