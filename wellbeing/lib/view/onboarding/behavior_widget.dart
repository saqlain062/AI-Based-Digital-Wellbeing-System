import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../../controller/onboarding_controller.dart';
import 'basic_info_widget.dart';

class BehaviorWidget extends StatelessWidget {
  const BehaviorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How you have been feeling',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'These answers add context, so your insights feel more human than a simple score.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          OnboardingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingSectionLabel(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  title: 'Stress level',
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the option that feels closest to today.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(c.moodLabels.length, (index) {
                      final selected = c.selectedMood.value == index;
                      return ChoiceChip(
                        label: Text(c.moodLabels[index]),
                        avatar: Text(
                          c.moodEmojis[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        selected: selected,
                        onSelected: (_) => c.selectMood(index),
                        selectedColor: const Color(0xFFEDE9FE),
                        backgroundColor: WellbeingDecor.tintedSurface(context),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      );
                    }),
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
                  icon: Icons.school_rounded,
                  title: 'Academic impact',
                ),
                const SizedBox(height: 8),
                Text(
                  'How much does phone use affect your studies or ability to focus?',
                  style: Theme.of(context).textTheme.bodyMedium,
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
                          text: c.academicImpact.value.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: WellbeingTheme.purple,
                          ),
                        ),
                        const TextSpan(text: ' / 10'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Slider(
                    value: c.academicImpact.value,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: c.academicImpact.value.toStringAsFixed(0),
                    onChanged: (v) => c.academicImpact.value = v,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: c.back,
                  child: const Text('Back'),
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
                    onPressed: c.next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Finish Setup'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
