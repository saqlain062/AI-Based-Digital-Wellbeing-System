import 'package:flutter/material.dart';

import '../../services/hive_service.dart';
import '../dashboard/ai_module_widgets.dart';

class GoalPreferencesScreen extends StatefulWidget {
  const GoalPreferencesScreen({super.key});

  @override
  State<GoalPreferencesScreen> createState() => _GoalPreferencesScreenState();
}

class _GoalPreferencesScreenState extends State<GoalPreferencesScreen> {
  late String wellbeingGoal;
  late double dailyScreenTimeTarget;
  late double focusHoursTarget;
  late bool reduceNightUsage;

  @override
  void initState() {
    super.initState();
    wellbeingGoal = HiveService.instance.getWellbeingGoal();
    dailyScreenTimeTarget = HiveService.instance.getDailyScreenTimeTarget();
    focusHoursTarget = HiveService.instance.getFocusHoursTarget();
    reduceNightUsage = HiveService.instance.getReduceNightUsageGoal();
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Goal Preferences',
      subtitle: 'Choose the goal style that shapes coaching suggestions and reminders.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(
              child: AiGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionTitle(
                      icon: Icons.flag_outlined,
                      title: 'Preferences',
                      color: AiModulePalette.teal,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: wellbeingGoal,
                      decoration: const InputDecoration(
                        labelText: 'Main wellbeing goal',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'reduce_distractions',
                          child: Text('Reduce distractions'),
                        ),
                        DropdownMenuItem(
                          value: 'sleep_better',
                          child: Text('Sleep better'),
                        ),
                        DropdownMenuItem(
                          value: 'focus_work_study',
                          child: Text('Focus study/work'),
                        ),
                        DropdownMenuItem(
                          value: 'understand_habits',
                          child: Text('Understand habits'),
                        ),
                        DropdownMenuItem(
                          value: 'build_balance',
                          child: Text('Build balance'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => wellbeingGoal = value);
                        HiveService.instance.saveWellbeingGoal(value);
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Daily screen-time target',
                      style: TextStyle(
                        color: AiModulePalette.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Slider(
                      value: dailyScreenTimeTarget,
                      min: 1,
                      max: 10,
                      divisions: 18,
                      label: '${dailyScreenTimeTarget.toStringAsFixed(1)} h',
                      onChanged: (value) {
                        setState(() => dailyScreenTimeTarget = value);
                        HiveService.instance.saveDailyScreenTimeTarget(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Focus hours target',
                      style: TextStyle(
                        color: AiModulePalette.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Slider(
                      value: focusHoursTarget,
                      min: 0.5,
                      max: 8,
                      divisions: 15,
                      label: '${focusHoursTarget.toStringAsFixed(1)} h',
                      onChanged: (value) {
                        setState(() => focusHoursTarget = value);
                        HiveService.instance.saveFocusHoursTarget(value);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: reduceNightUsage,
                      activeColor: AiModulePalette.teal,
                      title: const Text('Reduce night usage'),
                      subtitle: const Text(
                        'Give more weight to calmer evening suggestions.',
                      ),
                      onChanged: (value) {
                        setState(() => reduceNightUsage = value);
                        HiveService.instance.saveReduceNightUsageGoal(value);
                      },
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
}
