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
                      final isDark = WellbeingDecor.isDark(context);
                      return ChoiceChip(
                        label: Text(c.moodLabels[index]),
                        avatar: Text(
                          c.moodEmojis[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        selected: selected,
                        onSelected: (_) => c.selectMood(index),
                        showCheckmark: false,
                        selectedColor: isDark
                            ? const Color(0xFF312E81)
                            : const Color(0xFFEDE9FE),
                        backgroundColor: WellbeingDecor.tintedSurface(context),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        labelStyle: TextStyle(
                          color: selected && isDark
                              ? Colors.white
                              : WellbeingDecor.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
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
                  'Does phone use affect your studies, work, or ability to focus?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Obx(
                  () => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('No'),
                        selected: c.academicImpact.value == 0.0,
                        onSelected: (_) => c.academicImpact.value = 0.0,
                        showCheckmark: false,
                        selectedColor: WellbeingDecor.isDark(context)
                            ? const Color(0xFF312E81)
                            : const Color(0xFFEDE9FE),
                        backgroundColor: WellbeingDecor.tintedSurface(context),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        labelStyle: TextStyle(
                          color:
                              c.academicImpact.value == 0.0 &&
                                  WellbeingDecor.isDark(context)
                              ? Colors.white
                              : WellbeingDecor.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: c.academicImpact.value == 1.0,
                        onSelected: (_) => c.academicImpact.value = 1.0,
                        showCheckmark: false,
                        selectedColor: WellbeingDecor.isDark(context)
                            ? const Color(0xFF312E81)
                            : const Color(0xFFEDE9FE),
                        backgroundColor: WellbeingDecor.tintedSurface(context),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        labelStyle: TextStyle(
                          color:
                              c.academicImpact.value == 1.0 &&
                                  WellbeingDecor.isDark(context)
                              ? Colors.white
                              : WellbeingDecor.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                    child: const Text('Next'),
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
