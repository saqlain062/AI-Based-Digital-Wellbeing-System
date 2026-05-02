import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../services/hive_service.dart';
import '../../navigation_menu.dart';
import '../dashboard/ai_module_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late double age;
  late double gender;
  late double sleepHours;
  late double workStudyHours;
  late double stressLevel;
  late double academicImpact;

  final AIController controller = Get.find<AIController>();

  @override
  void initState() {
    super.initState();
    final profile = HiveService.instance.getUserProfile();
    final onboardingInputs = HiveService.instance.getOnboardingInputs();

    age = profile['age'] ?? 20.0;
    gender = profile['gender'] ?? 2.0;
    sleepHours = onboardingInputs['sleep_hours'] ?? 7.0;
    workStudyHours = onboardingInputs['work_study_hours'] ?? 4.0;
    stressLevel = onboardingInputs['stress_level'] ?? 5.0;
    academicImpact = onboardingInputs['academic_impact'] ?? 5.0;
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Profile',
      subtitle:
          'Update the personal details and check-in values that shape your current wellbeing insight.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(
              child: _buildHeroCard(context),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 100,
              child: _buildPersonalDetailsCard(context),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 180,
              child: _buildCheckInCard(context),
            ),
            const SizedBox(height: 18),
            AiFadeSlideIn(
              delayMs: 260,
              child: AiGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep, work or study time, stress, and academic impact often change over time. If you update them here, the app can recalculate your result using your latest device data and personal inputs.',
                      style: TextStyle(
                        color: AiModulePalette.textSecondary(context),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AiPrimaryButton(
                      label: 'Update and Recalculate',
                      onPressed: _handleSaveAndRecalculate,
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
            icon: Icons.person_outline_rounded,
            title: 'Profile Snapshot',
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroMetric(label: 'Age', value: age.toStringAsFixed(0)),
              _HeroMetric(label: 'Gender', value: _formatGender(gender)),
              _HeroMetric(
                label: 'Sleep',
                value: '${sleepHours.toStringAsFixed(1)}h',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'These values help the app interpret your current habits in a more personal and balanced way.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.badge_outlined,
            title: 'Personal Details',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          _LabeledSlider(
            label: 'Age',
            valueLabel: age.toStringAsFixed(0),
            value: age,
            min: 10,
            max: 80,
            divisions: 70,
            onChanged: (value) => setState(() => age = value),
          ),
          const SizedBox(height: 16),
          Text(
            'Gender',
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _GenderChip(
                label: 'Female',
                selected: gender == 0.0,
                onTap: () => setState(() => gender = 0.0),
              ),
              _GenderChip(
                label: 'Male',
                selected: gender == 1.0,
                onTap: () => setState(() => gender = 1.0),
              ),
              _GenderChip(
                label: 'Other',
                selected: gender == 2.0,
                onTap: () => setState(() => gender = 2.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.insights_rounded,
            title: 'Adjustable Check-In Values',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 16),
          _LabeledSlider(
            label: 'Sleep Hours',
            valueLabel: '${sleepHours.toStringAsFixed(1)} h',
            value: sleepHours,
            min: 3,
            max: 12,
            divisions: 18,
            onChanged: (value) => setState(() => sleepHours = value),
          ),
          const SizedBox(height: 16),
          _LabeledSlider(
            label: 'Work or Study Hours',
            valueLabel: '${workStudyHours.toStringAsFixed(1)} h',
            value: workStudyHours,
            min: 0,
            max: 14,
            divisions: 28,
            onChanged: (value) => setState(() => workStudyHours = value),
          ),
          const SizedBox(height: 16),
          _LabeledSlider(
            label: 'Stress Level',
            valueLabel: '${stressLevel.toStringAsFixed(0)}/10',
            value: stressLevel,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) => setState(() => stressLevel = value),
          ),
          const SizedBox(height: 16),
          _LabeledSlider(
            label: 'Academic Impact',
            valueLabel: '${academicImpact.toStringAsFixed(0)}/10',
            value: academicImpact,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) => setState(() => academicImpact = value),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveAndRecalculate() async {
    HiveService.instance.saveUserProfile(age: age, gender: gender);
    HiveService.instance.saveOnboardingInputs(
      sleepHours: sleepHours,
      workStudyHours: workStudyHours,
      stressLevel: stressLevel,
      academicImpact: academicImpact,
    );

    controller.setFeature('age', age);
    controller.setFeature('gender', gender);
    controller.setFeature('sleep_hours', sleepHours);
    controller.setFeature('work_study_hours', workStudyHours);
    controller.setFeature('stress_level', stressLevel);
    controller.setFeature('academic_impact', academicImpact);

    await controller.runInference();

    if (!mounted) return;

    Get.offAll(() => const NavigationMenu(initialIndex: 0));
  }

  String _formatGender(double value) {
    if (value == 0.0) return 'Female';
    if (value == 1.0) return 'Male';
    return 'Other';
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AiModulePalette.textPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              valueLabel,
              style: TextStyle(
                color: AiModulePalette.textSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    AiModulePalette.blue,
                    AiModulePalette.purple,
                  ],
                )
              : null,
          color: selected
              ? null
              : Colors.white.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 12 : 110,
                ),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white.withAlpha(24),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AiModulePalette.textPrimary(context),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
