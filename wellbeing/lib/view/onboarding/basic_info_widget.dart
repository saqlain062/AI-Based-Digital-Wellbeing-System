import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../../controller/onboarding_controller.dart';

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A little about you',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'These details help Wellbeing AI tailor your insights while keeping everything on your device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          OnboardingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingSectionLabel(
                  icon: Icons.cake_rounded,
                  title: 'Age',
                ),
                const SizedBox(height: 14),
                Obx(
                  () => RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: WellbeingDecor.textSecondary(context),
                      ),
                      children: [
                        TextSpan(
                          text: c.age.value.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: WellbeingTheme.indigo,
                          ),
                        ),
                        const TextSpan(text: ' years old'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Slider(
                    value: c.age.value,
                    min: 10,
                    max: 60,
                    divisions: 50,
                    label: c.age.value.toStringAsFixed(0),
                    onChanged: (v) => c.age.value = v,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OnboardingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingSectionLabel(
                  icon: Icons.person_rounded,
                  title: 'Gender',
                ),
                const SizedBox(height: 14),
                Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _GenderChip(
                        label: 'Female',
                        icon: Icons.female_rounded,
                        selected: c.gender.value == 0,
                        onTap: () => c.gender.value = 0,
                      ),
                      _GenderChip(
                        label: 'Male',
                        icon: Icons.male_rounded,
                        selected: c.gender.value == 1,
                        onTap: () => c.gender.value = 1,
                      ),
                      _GenderChip(
                        label: 'Other',
                        icon: Icons.person_outline_rounded,
                        selected: c.gender.value == 2,
                        onTap: () => c.gender.value = 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: WellbeingTheme.primaryGradient,
              borderRadius: WellbeingTheme.buttonRadius,
              boxShadow: WellbeingTheme.softShadow,
            ),
            child: ElevatedButton(
              onPressed: c.next,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingCard extends StatelessWidget {
  const OnboardingCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WellbeingDecor.surface(context),
        borderRadius: WellbeingTheme.cardRadius,
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: WellbeingTheme.softShadow,
      ),
      child: child,
    );
  }
}

class OnboardingSectionLabel extends StatelessWidget {
  const OnboardingSectionLabel({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: WellbeingTheme.primaryGradient,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 18,
        color: selected
            ? WellbeingTheme.indigo
            : WellbeingDecor.textSecondary(context),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFE0E7FF),
      backgroundColor: WellbeingDecor.tintedSurface(context),
      side: BorderSide(color: Theme.of(context).dividerColor),
      labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: WellbeingDecor.textPrimary(context),
        fontSize: 13,
      ),
    );
  }
}
