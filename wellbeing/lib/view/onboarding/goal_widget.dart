import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../../controller/onboarding_controller.dart';
import 'basic_info_widget.dart';

class GoalWidget extends StatelessWidget {
  const GoalWidget({super.key});

  static const goals = [
    _GoalOption(
      id: 'reduce_distractions',
      title: 'Reduce distractions',
      subtitle: 'Spot the apps and moments that pull your attention away.',
      icon: Icons.center_focus_strong_rounded,
    ),
    _GoalOption(
      id: 'sleep_better',
      title: 'Sleep better',
      subtitle: 'Build calmer evening habits and reduce late-night scrolling.',
      icon: Icons.bedtime_rounded,
    ),
    _GoalOption(
      id: 'focus_work_study',
      title: 'Focus during study/work',
      subtitle: 'Use pickups and notifications to protect deep focus time.',
      icon: Icons.school_rounded,
    ),
    _GoalOption(
      id: 'understand_habits',
      title: 'Understand app habits',
      subtitle: 'See where your time goes with clearer usage patterns.',
      icon: Icons.query_stats_rounded,
    ),
    _GoalOption(
      id: 'build_balance',
      title: 'Build healthier phone balance',
      subtitle: 'Keep your phone useful without letting it run the day.',
      icon: Icons.spa_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your main goal',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'This helps Wellbeing AI make your daily insights and recommendations more useful.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Obx(
            () => Column(
              children: goals
                  .map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalTile(
                        goal: goal,
                        selected: c.wellbeingGoal.value == goal.id,
                        onTap: () => c.selectWellbeingGoal(goal.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
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

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final _GoalOption goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = WellbeingDecor.isDark(context);

    return InkWell(
      onTap: onTap,
      borderRadius: WellbeingTheme.cardRadius,
      child: OnboardingCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: selected ? WellbeingTheme.primaryGradient : null,
                color: selected ? null : WellbeingDecor.tintedSurface(context),
              ),
              child: Icon(
                goal.icon,
                color: selected ? Colors.white : WellbeingTheme.indigo,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: WellbeingDecor.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WellbeingDecor.textSecondary(context),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? (isDark ? Colors.white : WellbeingTheme.indigo)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? (isDark ? Colors.white : WellbeingTheme.indigo)
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.circle,
                      size: 9,
                      color: isDark ? WellbeingTheme.indigo : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption {
  const _GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
