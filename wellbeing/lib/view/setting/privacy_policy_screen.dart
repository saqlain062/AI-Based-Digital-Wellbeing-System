import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/constants/app_links.dart';
import '../dashboard/ai_module_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Privacy Policy',
      subtitle:
          'A clear explanation of how Wellbeing AI handles your data, optional permissions, and local storage.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AiFadeSlideIn(child: _PrivacyHeroCard()),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 100,
              child: _PolicySectionCard(
                title: 'What Stays On Your Device',
                icon: Icons.phone_android_rounded,
                lines: [
                  'Your screen time and app usage data',
                  'Your manual assessments and wellbeing inputs',
                  'Your saved results, reports, and app preferences',
                  'Your local trend history unless you choose to clear it',
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 180,
              child: _PolicySectionCard(
                title: 'How The App Uses It',
                icon: Icons.psychology_alt_rounded,
                lines: [
                  'To generate your AI-based wellbeing insights',
                  'To show app activity, reports, and usage patterns',
                  'To keep your experience personalized across visits',
                  'To estimate digital balance signals from the data available on this phone',
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 260,
              child: _PolicySectionCard(
                title: 'What We Do Not Do',
                icon: Icons.shield_outlined,
                lines: [
                  'We do not require an account',
                  'We do not sell your personal data',
                  'We do not upload your private usage history to a cloud service as part of the core experience',
                  'We do not read messages, photos, passwords, or typed content',
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 340,
              child: _PolicySectionCard(
                title: 'Android Usage Access',
                icon: Icons.admin_panel_settings_rounded,
                lines: [
                  'Smart Tracking uses Android Usage Access only when you choose to enable it',
                  'This helps estimate app usage time, app opens, and digital habit patterns',
                  'Manual Input works without granting Usage Access',
                  'You can turn Usage Access off again from Android Settings',
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 420,
              child: _PolicySectionCard(
                title: 'Wellbeing Disclaimer',
                icon: Icons.health_and_safety_outlined,
                lines: [
                  'Wellbeing AI is not a medical, mental health, or diagnostic tool',
                  'Insights are estimates based on available usage and self-reported inputs',
                  'For serious wellbeing concerns, speak with a qualified professional',
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 500,
              child: _PolicySectionCard(
                title: 'Delete Your Local Data',
                icon: Icons.delete_outline_rounded,
                lines: [
                  'Open Settings, then Data Management, to clear saved insights and trend history',
                  'Reset Local Insights removes saved results, profile inputs, feature values, and local history',
                  'Clearing local data does not require an account request because the core app data is stored on this device',
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 580,
              child: _PolicyFooterCard(
                title: 'Your Choices',
                text:
                    'Smart Tracking is optional. You can use Manual Input instead, review your settings later, clear saved local insights, and decide how much information the app can access on this device.',
              ),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 660,
              child: _HostedPolicyCard(
                onOpen: () => _openHostedPolicy(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openHostedPolicy(BuildContext context) async {
    final uri = Uri.parse(AppLinks.privacyPolicyUrl);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not open the hosted privacy policy right now.'),
        ),
      );
    }
  }
}

class _PrivacyHeroCard extends StatelessWidget {
  const _PrivacyHeroCard();

  @override
  Widget build(BuildContext context) {
    return AiGlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AiModulePalette.blue,
          AiModulePalette.purple,
          AiModulePalette.teal,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AiSectionTitle(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy first by design',
            color: Colors.white,
          ),
          SizedBox(height: 14),
          Text(
            'Wellbeing AI is designed to keep your information close to you. The core experience uses local data on your device to create digital balance insights without asking you to create an account.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  const _PolicySectionCard({
    required this.title,
    required this.icon,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AiSectionTitle(
            icon: icon,
            title: title,
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AiModulePalette.teal,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: AiModulePalette.textPrimary(context),
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyFooterCard extends StatelessWidget {
  const _PolicyFooterCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HostedPolicyCard extends StatelessWidget {
  const _HostedPolicyCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.public_rounded,
            title: 'Hosted Version',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 12),
          Text(
            'You can also open the official hosted copy of this same policy if you need to share or review it outside the app.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AiSecondaryButton(
            label: 'Open Hosted Privacy Policy',
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}
