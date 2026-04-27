import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../category_screen.dart';
import '../perimission/permission_screen.dart';
import 'profile_screen.dart';
import 'widget/settings_options.dart';
import '../../util/constants/image_strings.dart';
import '../../util/helper/helper_functions.dart';
import '../../widget/appbar/appbar.dart';

class UpgradedSettingScreen extends StatefulWidget {
  const UpgradedSettingScreen({super.key});

  @override
  State<UpgradedSettingScreen> createState() => _UpgradedSettingScreenState();
}

class _UpgradedSettingScreenState extends State<UpgradedSettingScreen> {
  bool notificationsEnabled = true;
  bool trackingEnabled = false;
  bool analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    final accentColor = isDark
        ? const Color(0xFF78C278)
        : const Color(0xFF1B7F2A);

    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            _buildHeader(context, accentColor),
            const SizedBox(height: 24),
            _buildSectionTitle('Account'),
            const SizedBox(height: 12),
            SettingTile(
              title: 'Profile',
              subtitle: 'View onboarding summary and personal details',
              leadingIcon: SImages.settingContact,
              trailingIcon: SImages.arrow,
              onTap: () => Get.to(() => const ProfileScreen()),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Preferences'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                activeColor: accentColor,
                title: const Text('Enable notifications'),
                subtitle: const Text('Receive reminders and wellbeing tips'),
                value: notificationsEnabled,
                onChanged: (value) =>
                    setState(() => notificationsEnabled = value),
              ),
            ),
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                activeColor: accentColor,
                title: const Text('Smart tracking'),
                subtitle: const Text(
                  'Allow app usage insights and smarter predictions',
                ),
                value: trackingEnabled,
                onChanged: (value) => setState(() => trackingEnabled = value),
              ),
            ),
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                activeColor: accentColor,
                title: const Text('Usage analytics'),
                subtitle: const Text(
                  'Share anonymous statistics to improve the app',
                ),
                value: analyticsEnabled,
                onChanged: (value) => setState(() => analyticsEnabled = value),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('App Access'),
            const SizedBox(height: 12),
            SettingTile(
              title: 'App Categories',
              subtitle: 'Manage how apps are grouped in your wellbeing report',
              trailingIcon: SImages.arrow,
              onTap: () => Get.to(() => CategoryScreen()),
            ),
            SettingTile(
              title: 'Permissions',
              subtitle: 'Review usage access and tracking permission',
              leadingIcon: SImages.settingPrivacy,
              trailingIcon: SImages.arrow,
              onTap: () => Get.to(() => const Permission()),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Support'),
            const SizedBox(height: 12),
            SettingTile(
              title: 'Give Feedback',
              subtitle: 'Help us improve with your comments',
              leadingIcon: SImages.feadback,
              trailingIcon: SImages.arrow,
              onTap: () {},
            ),
            SettingTile(
              title: 'Contact Us',
              leadingIcon: SImages.settingContact,
              trailingIcon: SImages.arrow,
              onTap: () {},
            ),
            SettingTile(
              title: 'Privacy Policy',
              leadingIcon: SImages.settingPrivacy,
              trailingIcon: SImages.arrow,
              onTap: () {},
            ),
            SettingTile(
              title: 'Terms of Service',
              leadingIcon: SImages.termofpolicy,
              trailingIcon: SImages.arrow,
              onTap: () {},
            ),
            const SizedBox(height: 30),
            _buildVersionInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
            ),
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              SImages.setting,
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellbeing Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your experience and keep your tracking preferences up to date.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }
}
