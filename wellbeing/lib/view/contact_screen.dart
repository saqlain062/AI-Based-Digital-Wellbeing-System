import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard/ai_module_widgets.dart';
import 'setting/feedback_screen.dart';
import 'setting/privacy_policy_screen.dart';
import 'setting/terms_of_service_screen.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Support',
      subtitle:
          'A calm place to get help, share feedback, or review how Wellbeing AI handles privacy on your device.',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(child: _buildHeroCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 100,
              child: _buildPrimaryActionCard(context),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 180,
              child: _buildQuickLinksCard(context),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 260,
              child: _buildWhatToExpectCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
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
        children: [
          const AiSectionTitle(
            icon: Icons.support_agent_rounded,
            title: 'We keep support simple',
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'If something feels unclear, you can send feedback from here. For privacy and policy questions, the app already includes the key details locally.',
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
            children: const [
              _SupportPill(label: 'No account required'),
              _SupportPill(label: 'On-device by default'),
              _SupportPill(label: 'Calm feedback flow'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Main Support Path',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            'Right now, one clear feedback route is enough. It keeps the experience lighter and avoids offering support channels that are not fully connected yet.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AiPrimaryButton(
            label: 'Share Feedback',
            onPressed: () => Get.to(() => const FeedbackScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.shield_outlined,
            title: 'Helpful Links',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 16),
          _SupportLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'See how your data stays on your device',
            onTap: () => Get.to(() => const PrivacyPolicyScreen()),
          ),
          const SizedBox(height: 12),
          _SupportLinkTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Review the app terms and usage notes',
            onTap: () => Get.to(() => const TermsOfServiceScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatToExpectCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.favorite_border_rounded,
            title: 'What To Expect',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 14),
          _BulletLine(
            text:
                'Feedback is the fastest way to tell us what feels helpful, unclear, or missing.',
          ),
          const SizedBox(height: 10),
          _BulletLine(
            text:
                'Privacy and policy details are available here in the app whenever you want to review them.',
          ),
          const SizedBox(height: 10),
          _BulletLine(
            text:
                'You never need an account to read these pages or use the support section.',
          ),
        ],
      ),
    );
  }
}

class _SupportLinkTile extends StatelessWidget {
  const _SupportLinkTile({
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AiModulePalette.teal.withAlpha(20),
              ),
              child: Icon(icon, color: AiModulePalette.teal, size: 20),
            ),
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

class _SupportPill extends StatelessWidget {
  const _SupportPill({required this.label});

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

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            text,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
