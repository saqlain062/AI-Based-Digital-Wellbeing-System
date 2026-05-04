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
          'A simple explanation of how Wellbeing AI handles your data, permissions, and local storage.',
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
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AiFadeSlideIn(
              delayMs: 340,
              child: _PolicyFooterCard(
                title: 'Your Choices',
                text:
                    'Smart Tracking is optional. You can use manual input instead, review your settings later, and decide how much information the app can access on this device.',
              ),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 420,
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
            'Wellbeing AI is designed to keep your information close to you. The app uses local data on your device to create insights without asking you to create an account.',
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
            'You can also open the official web copy of this policy if you need to share or review it outside the app.',
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
