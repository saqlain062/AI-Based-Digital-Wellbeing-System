import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Agreement to Terms',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'By using Mindful, you agree to these terms and conditions.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'Last updated: April 27, 2026',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Text(
              '1. Acceptance of Terms',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'By accessing and using Mindful, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            SizedBox(height: 20),
            Text(
              '2. Use License',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Permission is granted to use this app for personal, non-commercial purposes. You may not:\n\n• Modify or copy the app materials\n• Use the materials for commercial purposes\n• Attempt to reverse engineer any software\n• Remove any copyright or proprietary notations',
            ),
            SizedBox(height: 20),
            Text(
              '3. Disclaimer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This app provides general wellbeing information and is not a substitute for professional medical advice, diagnosis, or treatment.',
            ),
            SizedBox(height: 20),
            Text(
              '4. Account Responsibilities',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You are responsible for maintaining the confidentiality of your account credentials.',
            ),
            SizedBox(height: 20),
            Text(
              '5. Limitation of Liability',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'In no event shall Mindful or its creators be liable for any damages arising out of the use or inability to use this app.',
            ),
            SizedBox(height: 20),
            Text(
              '6. Changes to Terms',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.',
            ),
            SizedBox(height: 20),
            Text(
              '7. Contact Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Questions about these terms? Contact us at legal@mindfulapp.com',
            ),
          ],
        ),
      ),
    );
  }
}
