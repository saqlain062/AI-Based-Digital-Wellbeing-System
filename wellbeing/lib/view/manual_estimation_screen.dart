import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../navigation_menu.dart';
import '../services/hive_service.dart';
import '../util/theme/wellbeing_theme.dart';

class ManualEstimationScreen extends StatelessWidget {
  const ManualEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());
    final ai = Get.find<AIController>();

    return Scaffold(
      backgroundColor: WellbeingDecor.background(context),
      appBar: AppBar(title: const Text('Manual Check-in')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimate today\'s phone habits',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Use a rough estimate if Smart Tracking is not enabled yet. You can switch to Smart Tracking later from Settings.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(
                title: 'Phone use',
                icon: Icons.phone_android_rounded,
              ),
              const SizedBox(height: 14),
              _SliderCard(
                title: 'Daily screen time',
                subtitle: 'Total hours spent on your phone today',
                icon: Icons.fit_screen_outlined,
                value: c.manualScreenTime,
                min: 0,
                max: 12,
                unit: 'hours',
              ),
              const SizedBox(height: 12),
              _SliderCard(
                title: 'Social media time',
                subtitle: 'Time spent on social apps',
                icon: Icons.people_alt_rounded,
                value: c.manualSocial,
                min: 0,
                max: 8,
                unit: 'hours',
              ),
              const SizedBox(height: 12),
              _SliderCard(
                title: 'Gaming time',
                subtitle: 'Time spent gaming or in entertainment apps',
                icon: Icons.sports_esports_rounded,
                value: c.manualGaming,
                min: 0,
                max: 8,
                unit: 'hours',
              ),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'Daily routine',
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(height: 14),
              _SliderCard(
                title: 'Sleep hours',
                subtitle: 'How much sleep you expect to get',
                icon: Icons.bedtime_rounded,
                value: c.sleepHours,
                min: 3,
                max: 10,
                unit: 'hours',
              ),
              const SizedBox(height: 12),
              _SliderCard(
                title: 'Work or study hours',
                subtitle: 'Focused work, class, or study time',
                icon: Icons.school_outlined,
                value: c.workHours,
                min: 0,
                max: 12,
                unit: 'hours',
              ),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'How you feel',
                icon: Icons.self_improvement_rounded,
              ),
              const SizedBox(height: 14),
              _ChoiceCard(
                title: 'Stress level',
                subtitle: 'Choose the option that feels closest today',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(c.moodLabels.length, (index) {
                    return ChoiceChip(
                      label: Text(c.moodLabels[index]),
                      selected: c.selectedMood.value == index,
                      onSelected: (_) => c.selectMood(index),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              _ChoiceCard(
                title: 'Impact on work or study',
                subtitle: 'Has your phone been affecting your routine today?',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('Not much'),
                      selected: c.academicImpact.value == 0,
                      onSelected: (_) => c.academicImpact.value = 0,
                    ),
                    ChoiceChip(
                      label: const Text('Noticeable'),
                      selected: c.academicImpact.value == 1,
                      onSelected: (_) => c.academicImpact.value = 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'Profile',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _SliderCard(
                title: 'Age',
                subtitle: 'Use your current age',
                icon: Icons.cake_outlined,
                value: c.age,
                min: 16,
                max: 60,
                unit: 'years',
              ),
              const SizedBox(height: 12),
              _ChoiceCard(
                title: 'Gender',
                subtitle: 'Select the option you prefer to use',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('Female'),
                      selected: c.gender.value == 0,
                      onSelected: (_) => c.gender.value = 0,
                    ),
                    ChoiceChip(
                      label: const Text('Male'),
                      selected: c.gender.value == 1,
                      onSelected: (_) => c.gender.value = 1,
                    ),
                    ChoiceChip(
                      label: const Text('Prefer not to say'),
                      selected: c.gender.value == 2,
                      onSelected: (_) => c.gender.value = 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
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
                          _setManualFeatures(c, ai);
                          c.saveProfile();
                          ai.setCameFromManualEstimation();

                          await ai.runInference();
                          HiveService.instance.saveBool('onboardingCompleted', true);
                          Get.offAll(() => const NavigationMenu(initialIndex: 0));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Analyse my digital balance'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setManualFeatures(OnboardingController c, AIController ai) {
    final dailyScreen = c.manualScreenTime.value;
    final social = c.manualSocial.value;
    final gaming = c.manualGaming.value;
    final estimatedNotifications = (social * 14) + (dailyScreen * 6);
    final estimatedAppOpens = (dailyScreen * 8) + (social * 6) + (gaming * 4);
    final weekendScreen = math.max(dailyScreen, dailyScreen * 1.15);

    ai.setFeature('age', c.age.value);
    ai.setFeature('gender', c.gender.value.toDouble());
    ai.setFeature('sleep_hours', c.sleepHours.value);
    ai.setFeature('work_study_hours', c.workHours.value);
    ai.setFeature('stress_level', c.stressLevel.value);
    ai.setFeature('academic_impact', c.academicImpact.value);
    ai.setFeature('daily_screen_time', dailyScreen);
    ai.setFeature('social_media_hours', social);
    ai.setFeature('gaming_hours', gaming);
    ai.setFeature('notifications', estimatedNotifications);
    ai.setFeature('app_opens', estimatedAppOpens);
    ai.setFeature('weekend_screen', weekendScreen);
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WellbeingDecor.surface(context),
        borderRadius: WellbeingTheme.cardRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: WellbeingTheme.softShadow,
      ),
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
          Text(
            '${value.value.toStringAsFixed(value.value % 1 == 0 ? 0 : 1)} $unit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: WellbeingTheme.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value.value,
            min: min,
            max: max,
            divisions: ((max - min) / 0.5).round(),
            label: value.value.toStringAsFixed(value.value % 1 == 0 ? 0 : 1),
            onChanged: (v) => value.value = v,
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WellbeingDecor.surface(context),
        borderRadius: WellbeingTheme.cardRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: WellbeingTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
