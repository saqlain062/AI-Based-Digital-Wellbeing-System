import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../services/hive_service.dart';
import '../navigation_menu.dart';

class ManualEstimationScreen extends StatelessWidget {
  const ManualEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());
    final ai = Get.put(AIController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            c.showManualInputs.value = false;
            Get.back();
          },
        ),
        title: const Text(
          'Estimate Your Usage',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Tell us about your daily habits',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adjust the sliders to match your typical usage patterns.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // ===== SECTION 1: DEVICE USAGE =====
              _buildSectionHeader('📱 Device Usage', Colors.blue),
              const SizedBox(height: 16),
              _buildSliderCard(
                context,
                title: 'Daily Screen Time',
                subtitle: 'Total hours spent on your device',
                icon: Icons.fit_screen_outlined,
                value: c.manualScreenTime,
                min: 0,
                max: 12,
                unit: 'hours',
              ),
              const SizedBox(height: 12),
              _buildSliderCard(
                context,
                title: 'Weekend Screen Time',
                subtitle: 'Hours spent on weekends',
                icon: Icons.weekend,
                value: c.weekendScreen,
                min: 0,
                max: 12,
                unit: 'hours',
              ),

              const SizedBox(height: 28),

              // ===== SECTION 2: APP USAGE =====
              _buildSectionHeader('🎮 App & Content Usage', Colors.orange),
              const SizedBox(height: 16),
              _buildSliderCard(
                context,
                title: 'Social Media Hours',
                subtitle: 'Time on social platforms',
                icon: Icons.people,
                value: c.manualSocial,
                min: 0,
                max: 10,
                unit: 'hours',
              ),
              const SizedBox(height: 12),
              _buildSliderCard(
                context,
                title: 'Gaming Hours',
                subtitle: 'Time spent gaming',
                icon: Icons.gamepad,
                value: c.manualGaming,
                min: 0,
                max: 10,
                unit: 'hours',
              ),

              const SizedBox(height: 28),

              // ===== SECTION 3: INTERACTIONS =====
              _buildSectionHeader('⚡ Daily Interactions', Colors.purple),
              const SizedBox(height: 16),
              _buildSliderCard(
                context,
                title: 'App Opens',
                subtitle: 'Times you open apps per day',
                icon: Icons.touch_app,
                value: c.appOpens,
                min: 0,
                max: 200,
                unit: 'opens',
              ),
              const SizedBox(height: 12),
              _buildSliderCard(
                context,
                title: 'Notifications',
                subtitle: 'Notifications received daily',
                icon: Icons.notifications,
                value: c.notifications,
                min: 0,
                max: 200,
                unit: 'notifications',
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.green, width: 2),
                      ),
                      onPressed: () {
                        c.showManualInputs.value = false;
                        Get.back();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        _setCommonFeatures(c, ai);
                        c.saveProfile();

                        // Set manual usage features
                        ai.setFeature(
                          'daily_screen_time',
                          c.manualScreenTime.value,
                        );
                        ai.setFeature(
                          'social_media_hours',
                          c.manualSocial.value,
                        );
                        ai.setFeature('gaming_hours', c.manualGaming.value);
                        ai.setFeature('notifications', c.notifications.value);
                        ai.setFeature('app_opens', c.appOpens.value);
                        ai.setFeature('weekend_screen', c.weekendScreen.value);

                        // Mark that user came from manual estimation
                        ai.setCameFromManualEstimation();

                        // Run AI
                        await ai.runInference();
                        HiveService.instance.saveBool(
                          'onboardingCompleted',
                          true,
                        );

                        Get.offAll(() => const NavigationMenu());
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSliderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required RxDouble value,
    required double min,
    required double max,
    required String unit,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    '${value.value.toStringAsFixed(value.value % 1 == 0 ? 0 : 1)} $unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Obx(
              () => Slider(
                value: value.value,
                min: min,
                max: max,
                divisions: ((max - min) / 0.5).toInt(),
                label: value.value.toStringAsFixed(1),
                activeColor: Colors.green,
                inactiveColor: Colors.green.shade100,
                onChanged: (v) => value.value = v,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  min.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  max.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setCommonFeatures(OnboardingController c, AIController ai) {
    ai.setFeature('age', c.age.value);
    ai.setFeature('gender', c.gender.value.toDouble());
    ai.setFeature('sleep_hours', c.sleepHours.value);
    ai.setFeature('work_study_hours', c.workHours.value);
    ai.setFeature('stress_level', c.stressLevel.value);
    ai.setFeature('academic_impact', c.academicImpact.value);
  }
}
