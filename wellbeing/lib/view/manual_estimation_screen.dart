import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../navigation_menu.dart';
import '../services/hive_service.dart';
import 'onboarding/basic_info_widget.dart';

class ManualEstimationScreen extends StatelessWidget {
  const ManualEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());
    final ai = Get.find<AIController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manual Input')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add your best estimate',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Use a rough estimate if smart tracking is not enabled yet. You can always turn it on later for more detailed insights.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Device Usage',
              icon: Icons.phone_android_rounded,
            ),
            const SizedBox(height: 14),
            _SliderCard(
              title: 'Daily Screen Time',
              subtitle: 'Total hours spent on your device',
              icon: Icons.fit_screen_outlined,
              value: c.manualScreenTime,
              min: 0,
              max: 12,
              unit: 'hours',
            ),
            const SizedBox(height: 12),
            _SliderCard(
              title: 'Weekend Screen Time',
              subtitle: 'How much higher weekends tend to feel',
              icon: Icons.weekend_rounded,
              value: c.weekendScreen,
              min: 0,
              max: 12,
              unit: 'hours',
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'App & Content Usage',
              icon: Icons.grid_view_rounded,
            ),
            const SizedBox(height: 14),
            _SliderCard(
              title: 'Social Media Hours',
              subtitle: 'Time spent on social apps',
              icon: Icons.people_alt_rounded,
              value: c.manualSocial,
              min: 0,
              max: 10,
              unit: 'hours',
            ),
            const SizedBox(height: 12),
            _SliderCard(
              title: 'Gaming Hours',
              subtitle: 'Average time spent gaming',
              icon: Icons.sports_esports_rounded,
              value: c.manualGaming,
              min: 0,
              max: 10,
              unit: 'hours',
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Interactions',
              icon: Icons.touch_app_rounded,
            ),
            const SizedBox(height: 14),
            _SliderCard(
              title: 'App Opens',
              subtitle: 'How often you open apps each day',
              icon: Icons.touch_app_rounded,
              value: c.appOpens,
              min: 0,
              max: 200,
              unit: 'opens',
            ),
            const SizedBox(height: 12),
            _SliderCard(
              title: 'Notifications',
              subtitle: 'Notifications received per day',
              icon: Icons.notifications_active_rounded,
              value: c.notifications,
              min: 0,
              max: 200,
              unit: 'notifications',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      c.showManualInputs.value = false;
                      Get.back();
                    },
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: WellbeingTheme.primaryGradient,
                      borderRadius: WellbeingTheme.buttonRadius,
                      boxShadow: WellbeingTheme.softShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        _setCommonFeatures(c, ai);
                        c.saveProfile();

                        ai.setFeature('daily_screen_time', c.manualScreenTime.value);
                        ai.setFeature('social_media_hours', c.manualSocial.value);
                        ai.setFeature('gaming_hours', c.manualGaming.value);
                        ai.setFeature('notifications', c.notifications.value);
                        ai.setFeature('app_opens', c.appOpens.value);
                        ai.setFeature('weekend_screen', c.weekendScreen.value);
                        ai.setCameFromManualEstimation();

                        await ai.runInference();
                        HiveService.instance.saveBool('onboardingCompleted', true);
                        Get.offAll(() => const NavigationMenu(initialIndex: 0));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text('See My Result'),
                    ),
                  ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: WellbeingDecor.tintedSurface(context),
        borderRadius: WellbeingTheme.cardRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: WellbeingTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final RxDouble value;
  final double min;
  final double max;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return OnboardingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: WellbeingDecor.tintedSurface(context),
                ),
                child: Icon(icon, color: WellbeingTheme.indigo, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(
            () => Text(
              '${value.value.toStringAsFixed(value.value % 1 == 0 ? 0 : 1)} $unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: WellbeingTheme.indigo,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Slider(
              value: value.value,
              min: min,
              max: max,
              divisions: ((max - min) / 0.5).toInt(),
              label: value.value.toStringAsFixed(1),
              onChanged: (v) => value.value = v,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(min.toStringAsFixed(0), style: Theme.of(context).textTheme.bodySmall),
              Text(max.toStringAsFixed(0), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
