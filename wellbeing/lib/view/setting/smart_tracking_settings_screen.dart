import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/permission_service.dart';
import '../../services/smart_tracking_service.dart';
import '../dashboard/ai_module_widgets.dart';
import '../permission_screen.dart';

class SmartTrackingSettingsScreen extends StatefulWidget {
  const SmartTrackingSettingsScreen({super.key});

  @override
  State<SmartTrackingSettingsScreen> createState() =>
      _SmartTrackingSettingsScreenState();
}

class _SmartTrackingSettingsScreenState
    extends State<SmartTrackingSettingsScreen> {
  final PermissionService permissionService = Get.put(PermissionService());
  bool trackingEnabled = false;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final granted = await permissionService.hasUsagePermission();
    if (!mounted) return;
    setState(() {
      trackingEnabled = SmartTrackingService.isSmartTrackingEnabled();
      hasPermission = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Smart Tracking',
      subtitle: 'Manage usage access and automatic analysis on this device.',
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
                      icon: Icons.track_changes_rounded,
                      title: 'Tracking Status',
                      color: AiModulePalette.teal,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      trackingEnabled
                          ? 'Smart tracking is enabled. The app can use device activity to build a fuller picture of your phone habits.'
                          : 'Smart tracking is optional. You can keep using manual check-ins or enable device-based tracking here.',
                      style: TextStyle(
                        color: AiModulePalette.textSecondary(context),
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        AiMetricPill(
                          label: 'Tracking',
                          value: trackingEnabled ? 'Enabled' : 'Disabled',
                        ),
                        AiMetricPill(
                          label: 'Usage access',
                          value: hasPermission ? 'Granted' : 'Not granted',
                        ),
                      ],
                    ),
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
                      icon: Icons.settings_rounded,
                      title: 'Controls',
                      color: AiModulePalette.blue,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: trackingEnabled,
                      activeColor: AiModulePalette.teal,
                      title: const Text('Enable smart tracking'),
                      subtitle: const Text(
                        'Use device usage signals for richer insights and app activity summaries.',
                      ),
                      onChanged: (value) async {
                        if (!value) {
                          await SmartTrackingService.disableSmartTracking();
                        } else if (hasPermission) {
                          await SmartTrackingService.enableSmartTracking();
                        } else {
                          if (!mounted) return;
                          Get.to(() => const PermissionScreen());
                          return;
                        }
                        await _loadState();
                      },
                    ),
                    const SizedBox(height: 8),
                    AiSecondaryButton(
                      label: hasPermission
                          ? 'Manage Usage Permission'
                          : 'Grant Usage Permission',
                      onPressed: () async {
                        await Get.to(() => const PermissionScreen());
                        await _loadState();
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
