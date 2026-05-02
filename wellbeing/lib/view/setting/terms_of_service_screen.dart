import 'package:flutter/material.dart';

import '../dashboard/ai_module_widgets.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Terms of Service',
      subtitle:
          'A clearer summary of the basic terms for using Wellbeing AI on your device.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AiFadeSlideIn(child: _TermsHeroCard()),
            SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 100,
              child: _TermsSectionCard(
                title: 'Using The App',
                icon: Icons.mobile_friendly_rounded,
                lines: [
                  'The app is intended for personal wellbeing use',
                  'You may use it to understand habits, reports, and AI-based insights',
                  'Please use the app in a lawful and respectful way',
                ],
              ),
            ),
            SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 180,
              child: _TermsSectionCard(
                title: 'Important Limits',
                icon: Icons.info_outline_rounded,
                lines: [
                  'The app offers general wellbeing guidance',
                  'It is not a replacement for professional medical or mental health care',
                  'Predictions and recommendations are meant to support reflection, not make decisions for you',
                ],
              ),
            ),
            SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 260,
              child: _TermsSectionCard(
                title: 'App Changes',
                icon: Icons.update_rounded,
                lines: [
                  'Features and wording may improve over time',
                  'Some experiences may change as tracking, reports, or support tools evolve',
                  'Continued use means you accept those reasonable updates',
                ],
              ),
            ),
            SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 340,
              child: _TermsFooterCard(
                text:
                    'Wellbeing AI is offered to help you notice patterns and make small, healthier adjustments. Using the app remains your choice, and your data stays tied to this device unless you decide otherwise in the future.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsHeroCard extends StatelessWidget {
  const _TermsHeroCard();

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
            icon: Icons.description_outlined,
            title: 'Simple, human terms',
            color: Colors.white,
          ),
          SizedBox(height: 14),
          Text(
            'These terms are here to set clear expectations. The short version is that the app is meant to support healthy reflection and should be used as a personal wellbeing tool.',
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

class _TermsSectionCard extends StatelessWidget {
  const _TermsSectionCard({
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
            color: AiModulePalette.purple,
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
                      color: AiModulePalette.purple,
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

class _TermsFooterCard extends StatelessWidget {
  const _TermsFooterCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AiGlassCard(
      child: Text(
        text,
        style: TextStyle(
          color: AiModulePalette.textSecondary(context),
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
