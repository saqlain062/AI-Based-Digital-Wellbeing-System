import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../services/hive_service.dart';
import '../../services/permission_service.dart';
import '../../services/smart_tracking_service.dart';
import '../../util/theme/wellbeing_theme.dart';
import '../category_screen.dart';
import '../contact_screen.dart';
import '../dashboard/ai_module_widgets.dart';
import '../permission_screen.dart';
import 'data_management_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_screen.dart';
import 'terms_of_service_screen.dart';

class UpgradedSettingScreen extends StatefulWidget {
  const UpgradedSettingScreen({super.key});

  @override
  State<UpgradedSettingScreen> createState() => _UpgradedSettingScreenState();
}

class _UpgradedSettingScreenState extends State<UpgradedSettingScreen>
    with WidgetsBindingObserver {
  bool notificationsEnabled = true;
  bool trackingEnabled = false;
  bool localHistoryEnabled = true;
  int trackingHour = 8;
  String trackingFrequency = 'daily';

  final AIController controller = Get.find<AIController>();
  final PermissionService permissionService = Get.put(PermissionService());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadSettings();
    }
  }

  void _loadSettings() {
    setState(() {
      notificationsEnabled = HiveService.instance.getBool(
        'smartTrackingNotificationsEnabled',
        defaultValue: true,
      );
      trackingEnabled = SmartTrackingService.isSmartTrackingEnabled();
      localHistoryEnabled = HiveService.instance.getBool(
        'localHistoryEnabled',
        defaultValue: true,
      );
      trackingHour =
          (HiveService.instance.getUser('smartTrackingHour') ?? 8) as int;
      trackingFrequency =
          (HiveService.instance.getUser('smartTrackingFrequency') ?? 'daily')
              as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Settings',
      subtitle:
          'Adjust how Wellbeing AI works for you, from optional tracking to privacy, reports, and support.',
      child: Obx(() {
        final sourceLabel = controller.hasSmartTrackingData
            ? 'Smart Tracking'
            : 'Manual Assessment';
        final keepHistory = HiveService.instance.getBool(
          'localHistoryEnabled',
          defaultValue: true,
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AiFadeSlideIn(
                child: _buildHeroCard(context, sourceLabel),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 80,
                child: _buildTrackingCard(context),
              ),
              if (trackingEnabled && keepHistory) ...[
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 110,
                  child: _buildHistoryNoteCard(context),
                ),
              ],
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 140,
                child: _buildPreferencesCard(context),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 200,
                child: _buildAccountCard(context),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 260,
                child: _buildOrganizationCard(context),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 320,
                child: _buildSupportCard(context),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 380,
                child: _buildAboutCard(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroCard(BuildContext context, String sourceLabel) {
    return AiGlassCard(
      gradient: WellbeingTheme.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.tune_rounded,
            title: 'Your App Setup',
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            trackingEnabled
                ? 'Smart Tracking is on, so the app can build a fuller picture from your device activity.'
                : 'The app is currently using a lighter setup. You can keep it manual or enable smarter tracking any time.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(
                label: trackingEnabled
                    ? 'Tracking enabled'
                    : 'Tracking optional',
              ),
              _HeroPill(label: sourceLabel),
              _HeroPill(
                label: localHistoryEnabled
                    ? 'Weekly history on-device'
                    : 'History paused',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.insights_rounded,
            title: 'Smart Tracking',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            'Usage access is optional. Turning it on gives you richer trends, app activity summaries, and more confident analysis.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SettingSwitchTile(
            icon: Icons.track_changes_rounded,
            title: 'Enable Smart Tracking',
            subtitle: 'Use device activity for more complete insights',
            value: trackingEnabled,
            onChanged: _handleTrackingToggle,
          ),
          if (trackingEnabled) ...[
            const SizedBox(height: 12),
            _DropdownTile<int>(
              icon: Icons.schedule_rounded,
              title: 'Daily analysis time',
              subtitle: 'Choose when your background insight is prepared',
              value: trackingHour,
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
                await _saveTrackingSchedule();
              },
            ),
            const SizedBox(height: 12),
            _DropdownTile<String>(
              icon: Icons.event_repeat_rounded,
              title: 'Refresh frequency',
              subtitle: 'How often the app should prepare a new background insight',
              value: trackingFrequency,
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (value) async {
                if (value == null) return;
                setState(() => trackingFrequency = value);
                await _saveTrackingSchedule();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.tune_rounded,
            title: 'Preferences',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 16),
          _SettingSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Gentle reminders',
            subtitle: 'Keep reminder settings ready for future nudges and prompts',
            value: notificationsEnabled,
            onChanged: (value) async {
              setState(() => notificationsEnabled = value);
              HiveService.instance.saveBool(
                'smartTrackingNotificationsEnabled',
                value,
              );
              if (trackingEnabled) {
                await _saveTrackingSchedule();
              }
            },
          ),
          const SizedBox(height: 12),
          _SettingSwitchTile(
            icon: Icons.bar_chart_rounded,
            title: 'Keep daily history',
            subtitle: 'Store recent daily snapshots on this device for weekly and monthly trends',
            value: localHistoryEnabled,
            onChanged: (value) {
              setState(() => localHistoryEnabled = value);
              HiveService.instance.saveBool('localHistoryEnabled', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryNoteCard(BuildContext context) {
    return AiGlassCard(
      child: Row(
        children: [
          PositionedIcon(icon: Icons.bar_chart_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily history is active',
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recent daily snapshots are being kept on this device for weekly charts and trend summaries.',
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Account & Profile',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 16),
          _NavigationTile(
            icon: Icons.badge_outlined,
            title: 'Profile',
            subtitle: 'Review the personal details used in your wellbeing analysis',
            onTap: () => Get.to(() => const ProfileScreen()),
          ),
          const SizedBox(height: 12),
          _NavigationTile(
            icon: Icons.storage_rounded,
            title: 'Data Management',
            subtitle: 'Review storage, local history, and reset options',
            onTap: () => Get.to(() => const DataManagementScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.apps_rounded,
            title: 'App Organization',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          _NavigationTile(
            icon: Icons.category_outlined,
            title: 'App Categories',
            subtitle: 'Decide how your apps are grouped across activity and reports',
            onTap: () => Get.to(() => const CategoryScreen()),
          ),
          const SizedBox(height: 12),
          _NavigationTile(
            icon: Icons.lock_open_rounded,
            title: 'Permissions',
            subtitle: 'Review or update optional device access for smarter insights',
            onTap: () => Get.to(() => const PermissionScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.support_agent_rounded,
            title: 'Support & Privacy',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 16),
          _NavigationTile(
            icon: Icons.help_outline_rounded,
            title: 'Support Center',
            subtitle: 'Open help, feedback, and privacy support in one place',
            onTap: () => Get.to(() => const ContactScreen()),
          ),
          const SizedBox(height: 12),
          _NavigationTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'See how your data stays on your device',
            onTap: () => Get.to(() => const PrivacyPolicyScreen()),
          ),
          const SizedBox(height: 12),
          _NavigationTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Review the basic terms for using the app',
            onTap: () => Get.to(() => const TermsOfServiceScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return AiGlassCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: WellbeingTheme.primaryGradient,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellbeing AI',
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTrackingToggle(bool enabled) async {
    if (!enabled) {
      await SmartTrackingService.disableSmartTracking();
      setState(() => trackingEnabled = false);
      return;
    }

    final hasPermission = await permissionService.hasUsagePermission();
    if (hasPermission) {
      await SmartTrackingService.enableSmartTracking();
      setState(() => trackingEnabled = true);
      await _saveTrackingSchedule();
      return;
    }

    if (!mounted) return;
    Get.to(() => const PermissionScreen());
  }

  Future<void> _saveTrackingSchedule() async {
    await SmartTrackingService.updateSettings(
      hour: trackingHour,
      frequency: trackingFrequency,
      notificationsEnabled: notificationsEnabled,
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withAlpha(
            Theme.of(context).brightness == Brightness.dark ? 14 : 120,
          ),
          border: Border.all(color: Colors.white.withAlpha(24)),
        ),
        child: Row(
          children: [
            PositionedIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AiModulePalette.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AiModulePalette.textSecondary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AiModulePalette.textSecondary(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class PositionedIcon extends StatelessWidget {
  const PositionedIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AiModulePalette.teal.withAlpha(18),
      ),
      child: Icon(icon, color: AiModulePalette.teal, size: 20),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 14 : 120,
        ),
        border: Border.all(color: Colors.white.withAlpha(24)),
      ),
      child: Row(
        children: [
          PositionedIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeColor: AiModulePalette.teal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 14 : 120,
        ),
        border: Border.all(color: Colors.white.withAlpha(24)),
      ),
      child: Row(
        children: [
          PositionedIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<T>(
            value: value,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(18),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
