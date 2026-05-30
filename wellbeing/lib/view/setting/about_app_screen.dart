import 'package:flutter/material.dart';

import '../dashboard/ai_module_widgets.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'About AI Wellbeing',
      subtitle: 'A short overview of the app, the score, and the local-first design.',
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
                  children: const [
                    AiSectionTitle(
                      icon: Icons.info_outline_rounded,
                      title: 'AI Wellbeing',
                      color: AiModulePalette.teal,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'AI Wellbeing estimates your digital balance using phone habit signals such as screen time, social media use, gaming time, sleep, stress, and work or study impact.',
                      style: TextStyle(height: 1.45, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'The score is a personal wellbeing guide. It is not a medical diagnosis, and it is designed to support reflection and small daily improvements.',
                      style: TextStyle(height: 1.45, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Inference, recommendations, and stored history stay on the device.',
                      style: TextStyle(height: 1.45, fontWeight: FontWeight.w600),
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
