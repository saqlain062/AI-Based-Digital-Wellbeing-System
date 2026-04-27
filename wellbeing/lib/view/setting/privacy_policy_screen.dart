import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Privacy First',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your data stays on your device. We never sell or share your personal information.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'Last updated: April 27, 2026',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Text(
              '1. Information We Collect',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Mindful collects the following data locally on your device:\n\n• Screen time and app usage statistics\n• Your wellbeing assessments and mood check-ins\n• Goals, habits, and progress data\n• Optional journal entries and reflections',
            ),
            SizedBox(height: 20),
            Text(
              '2. How We Use Your Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your data is processed locally to:\n\n• Generate personalized AI insights and recommendations\n• Track your progress toward wellbeing goals\n• Provide analytics and reports',
            ),
            SizedBox(height: 20),
            Text(
              '3. Data Storage & Security',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'All data is encrypted and stored only on your device. We do not transmit your personal usage data to external servers.',
            ),
            SizedBox(height: 20),
            Text(
              '4. Third-Party Services',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We do not share your data with third parties for advertising or marketing purposes.',
            ),
            SizedBox(height: 20),
            Text(
              '5. Your Rights',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You have the right to:\n\n• Export all your data at any time\n• Delete your account and all associated data\n• Opt out of optional analytics',
            ),
            SizedBox(height: 20),
            Text(
              '6. Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Questions about privacy? Contact us at privacy@mindfulapp.com',
            ),
          ],
        ),
      ),
    );
  }
}
