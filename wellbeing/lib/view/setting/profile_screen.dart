import 'package:flutter/material.dart';
import 'package:wellbeing/services/hive_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = HiveService.instance.getUserProfile();
    final onboardingInputs = HiveService.instance.getOnboardingInputs();

    String formatGender(double genderValue) {
      if (genderValue == 0.0) return 'Female';
      if (genderValue == 1.0) return 'Male';
      return 'Other';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildField(
              'Age',
              profile['age']?.toStringAsFixed(0) ?? 'Not saved',
            ),
            _buildField('Gender', formatGender(profile['gender'] ?? 1.0)),
            const SizedBox(height: 24),
            const Text(
              'Latest Onboarding Inputs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildField(
              'Sleep Hours',
              onboardingInputs['sleep_hours']?.toStringAsFixed(1) ??
                  'Not saved',
            ),
            _buildField(
              'Work Hours',
              onboardingInputs['work_study_hours']?.toStringAsFixed(1) ??
                  'Not saved',
            ),
            _buildField(
              'Stress Level',
              onboardingInputs['stress_level']?.toStringAsFixed(0) ??
                  'Not saved',
            ),
            _buildField(
              'Academic Impact',
              onboardingInputs['academic_impact']?.toStringAsFixed(0) ??
                  'Not saved',
            ),
            const SizedBox(height: 24),
            const Text(
              'Note',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These values are saved from your onboarding flow. If you want to update them, re-run onboarding from the app settings.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
