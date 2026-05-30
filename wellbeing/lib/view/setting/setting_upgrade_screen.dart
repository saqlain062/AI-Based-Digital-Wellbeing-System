import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/hive_service.dart';
import '../../services/smart_tracking_service.dart';
import '../category_screen.dart';
import '../contact_screen.dart';
import '../dashboard/ai_module_widgets.dart';
import '../manual_estimation_screen.dart';
import 'about_app_screen.dart';
import 'analysis_schedule_settings_screen.dart';
import 'data_management_screen.dart';
import 'goal_preferences_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_screen.dart';
import 'smart_tracking_settings_screen.dart';
import 'terms_of_service_screen.dart';
import 'widgets/setting_list_tile.dart';

class UpgradedSettingScreen extends StatelessWidget {
  const UpgradedSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingEnabled = SmartTrackingService.isSmartTrackingEnabled();
    final reminderEnabled = HiveService.instance.getReminderEnabled();
    final notificationsEnabled = HiveService.instance.getNotificationsEnabled();
    final historyEnabled = HiveService.instance.getBool(
      'localHistoryEnabled',
      defaultValue: true,
    );

    return AiModuleScaffold(
      title: 'Settings',
      subtitle: 'Manage your app, privacy, and tracking preferences',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(
              child: SettingsSection(
                title: 'TRACKING & ANALYSIS',
                children: [
                  SettingListTile(
                    icon: Icons.track_changes_rounded,
                    title: 'Smart Tracking',
                    subtitle: 'Manage usage access and automatic analysis',
                    status: trackingEnabled ? 'Enabled' : 'Disabled',
                    onTap: () => Get.to(() => const SmartTrackingSettingsScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.edit_note_rounded,
                    title: 'Manual Check-in',
                    subtitle: 'Enter today\'s habits yourself whenever you prefer',
                    onTap: () => Get.to(() => const ManualEstimationScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.schedule_rounded,
                    title: 'Analysis Schedule',
                    subtitle: 'Set daily analysis time and refresh frequency',
                    onTap: () =>
                        Get.to(() => const AnalysisScheduleSettingsScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.refresh_rounded,
                    title: 'Refresh Data',
                    subtitle: 'Run a new local check-in with your latest data',
                    onTap: () async {
                      await SmartTrackingService.performAnalysis();
                    },
                  ),
                  SettingListTile(
                    icon: Icons.category_outlined,
                    title: 'Usage Categories',
                    subtitle: 'Review how apps are grouped in reports',
                    onTap: () => Get.to(() => const CategoryScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 80,
              child: SettingsSection(
                title: 'GOALS & REMINDERS',
                children: [
                  SettingListTile(
                    icon: Icons.flag_outlined,
                    title: 'Daily Challenge',
                    subtitle: 'Choose how goals and challenges are suggested',
                    onTap: () => Get.to(() => const GoalPreferencesScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    subtitle: 'Daily reminder, smart tracking reminder, and test notification',
                    status: notificationsEnabled
                        ? (reminderEnabled ? 'On' : 'Ready')
                        : 'Off',
                    onTap: () => Get.to(() => NotificationSettingsScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.calendar_view_week_rounded,
                    title: 'Weekly Goal',
                    subtitle: 'Review your balance targets for the week',
                    onTap: () => Get.to(() => const GoalPreferencesScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 160,
              child: SettingsSection(
                title: 'PERSONALISATION',
                children: [
                  SettingListTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Details',
                    subtitle: 'Review your personal check-in values',
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.tune_rounded,
                    title: 'Recommendation Preferences',
                    subtitle: 'Adjust the goal style behind your suggestions',
                    onTap: () => Get.to(() => const GoalPreferencesScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 240,
              child: SettingsSection(
                title: 'PRIVACY & DATA',
                children: [
                  SettingListTile(
                    icon: Icons.storage_rounded,
                    title: 'Data Management',
                    subtitle: 'Export, clear, or reset local app data',
                    status: historyEnabled ? 'History on' : 'History off',
                    onTap: () => Get.to(() => const DataManagementScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Explanation',
                    subtitle: 'See how your data stays on this device',
                    onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.key_outlined,
                    title: 'Permissions',
                    subtitle: 'Review tracking access and local processing permissions',
                    onTap: () => Get.to(() => const SmartTrackingSettingsScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Review the basic terms for using the app',
                    onTap: () => Get.to(() => const TermsOfServiceScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 320,
              child: SettingsSection(
                title: 'SUPPORT',
                children: [
                  SettingListTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Feedback / Contact',
                    subtitle: 'Open help, share feedback, or contact support',
                    onTap: () => Get.to(() => const ContactScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About AI Wellbeing',
                    subtitle: 'Version details and local-first app overview',
                    onTap: () => Get.to(() => const AboutAppScreen()),
                  ),
                  SettingListTile(
                    icon: Icons.psychology_alt_outlined,
                    title: 'How the Score Works',
                    subtitle: 'Read a simple explanation of the digital balance score',
                    onTap: () => Get.to(() => const AboutAppScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
