import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../../controller/onboarding_controller.dart';
import 'basic_info_widget.dart';

class LifestyleWidget extends StatelessWidget {
  const LifestyleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your daily routine',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'A simple picture of your routine helps the app compare screen habits with the rest of your day.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          OnboardingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingSectionLabel(
                  icon: Icons.bedtime_rounded,
                  title: 'Sleep routine',
                ),
                const SizedBox(height: 10),
                Obx(
                  () => SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Set sleep manually'),
                    subtitle: Text(
                      c.showSleepIndicator.value
                          ? 'Use the slider if your sleep varies from day to day.'
                          : 'Use bedtime and wake time for a more natural estimate.',
                    ),
                    value: c.showSleepIndicator.value,
                    onChanged: c.toggleSleepIndicator,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => c.showSleepIndicator.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: WellbeingDecor.textSecondary(
                                        context,
                                      ),
                                    ),
                                children: [
                                  TextSpan(
                                    text: c.sleepHours.value.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: WellbeingTheme.indigo,
                                        ),
                                  ),
                                  const TextSpan(text: ' hours sleep'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: c.sleepHours.value,
                              min: 3,
                              max: 12,
                              divisions: 18,
                              label: c.sleepHours.value.toStringAsFixed(1),
                              onChanged: (value) => c.sleepHours.value = value,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _TimeButton(
                                label: 'Bedtime',
                                icon: Icons.nights_stay_rounded,
                                time: c.bedTime.value,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: c.bedTime.value,
                                  );
                                  if (picked != null) {
                                    c.bedTime.value = picked;
                                    c.sleepHours.value = c.calculatedSleepHours;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TimeButton(
                                label: 'Wake time',
                                icon: Icons.wb_sunny_outlined,
                                time: c.wakeTime.value,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: c.wakeTime.value,
                                  );
                                  if (picked != null) {
                                    c.wakeTime.value = picked;
                                    c.sleepHours.value = c.calculatedSleepHours;
                                  }
                                },
                              ),
                            ),
                          ],
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
                  title: 'Work hours',
                ),
                const SizedBox(height: 10),
                Text(
                  'About how much focused work or study time fits into a usual day?',
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
                          text: c.workHours.value.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: WellbeingTheme.cyan),
                        ),
                        const TextSpan(text: ' hours per day'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Slider(
                    value: c.workHours.value,
                    min: 0,
                    max: 12,
                    divisions: 24,
                    label: c.workHours.value.toStringAsFixed(1),
                    onChanged: (v) => c.workHours.value = v,
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

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WellbeingDecor.tintedSurface(context),
        borderRadius: WellbeingTheme.inputRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: WellbeingTheme.indigo),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(time.format(context)),
          ),
        ],
      ),
    );
  }
}
