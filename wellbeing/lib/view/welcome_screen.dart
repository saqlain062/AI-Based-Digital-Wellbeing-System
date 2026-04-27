import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/navigation_menu.dart';
import 'package:wellbeing/services/hive_service.dart';
import 'package:wellbeing/view/onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _markWelcomeSeen() {
    HiveService.instance.saveBool('hasSeenWelcome', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Welcome to Wellbeing',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'A quick personal setup helps us give you better insights and recommendations.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.accessibility_new,
                      size: 120,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Track your habits, get AI-powered wellbeing tips, and take control of your digital health.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, height: 1.4),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _markWelcomeSeen();
                  Get.to(() => OnboardingScreen());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
