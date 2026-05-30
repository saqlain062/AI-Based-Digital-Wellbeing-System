import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../services/hive_service.dart';
import '../../services/reminder_notification_service.dart';
import '../../util/time_formatter.dart';
import '../dashboard/ai_module_widgets.dart';
import '../insights/insights_screen.dart';
import '../setting/goal_preferences_screen.dart';
import '../setting/reminder_settings_screen.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  late String selectedChallenge;
  final AIController controller = Get.find<AIController>();

  @override
  void initState() {
    super.initState();
    selectedChallenge = HiveService.instance.getSelectedCoachChallenge();
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Coach',
      subtitle: 'Small actions for better phone habits',
      child: Obx(() {
        final suggestions = _buildChallengeSuggestions();
        final activeChallenge = _resolveSelectedChallenge(suggestions);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AiFadeSlideIn(
                child: _buildCurrentGoalCard(context, activeChallenge, suggestions),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(delayMs: 80, child: _buildProgressCard(context)),
              const SizedBox(height: 18),
              AiFadeSlideIn(delayMs: 160, child: _buildGuidanceCard(context)),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 240,
                child: _buildChallengeCard(context, suggestions, activeChallenge),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(delayMs: 320, child: _buildCoachToolsCard(context)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentGoalCard(
    BuildContext context,
    _CoachChallenge activeChallenge,
    List<_CoachChallenge> suggestions,
  ) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.flag_rounded,
            title: 'Today\'s Challenge',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            activeChallenge.title,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activeChallenge.description,
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiMetricPill(
                label: 'Goal preference',
                value: controller.wellbeingGoalLabel,
              ),
              AiMetricPill(
                label: 'Today',
                value: activeChallenge.progressHint,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AiPrimaryButton(
                  label: _completedToday ? 'Done for today' : 'Mark as done',
                  onPressed: _completedToday
                      ? null
                      : () => _markChallengeDone(activeChallenge),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openChallengePicker(suggestions),
                  child: const Text('Change challenge'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final streak = HiveService.instance.getCoachCurrentStreak();
    final completedThisWeek = HiveService.instance.getCoachCompletedThisWeek();

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.local_fire_department_outlined,
            title: 'Progress',
            color: AiModulePalette.warning,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProgressTile(
                  label: 'Current streak',
                  value: streak == 1 ? '1 day' : '$streak days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressTile(
                  label: 'This week',
                  value: '$completedThisWeek/7 done',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _completedToday
                ? 'Nice work. Small progress matters.'
                : streak > 0
                    ? 'You can keep the rhythm going with one small action today.'
                    : 'You can restart today with one small step.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceCard(BuildContext context) {
    final message = controller.hasRecommendation
        ? controller.recommendation.value.split('\n').first.trim()
        : controller.supportiveMessage;

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Today\'s Guidance',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    List<_CoachChallenge> suggestions,
    _CoachChallenge activeChallenge,
  ) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.track_changes_rounded,
            title: 'Choose today\'s challenge',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 14),
          ...suggestions.take(5).map(
            (challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChallengeTile(
                challenge: challenge,
                selected: activeChallenge.id == challenge.id,
                onTap: () => _selectChallenge(challenge.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachToolsCard(BuildContext context) {
    final reminderEnabled = HiveService.instance.getReminderEnabled();
    final reminderTime = HiveService.instance.getReminderTime();
    final reminderLabel = reminderEnabled
        ? '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}'
        : 'Off';

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.tune_rounded,
            title: 'Coach tools',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          _CoachRow(
            icon: Icons.notifications_active_outlined,
            title: 'Reminder settings',
            subtitle: 'Daily reminder: $reminderLabel',
            onTap: () => Get.to(() => const ReminderSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _CoachRow(
            icon: Icons.flag_outlined,
            title: 'Goal preferences',
            subtitle: 'Choose the goal style that shapes your challenges',
            onTap: () => Get.to(() => const GoalPreferencesScreen()),
          ),
          const SizedBox(height: 12),
          _CoachRow(
            icon: Icons.insights_rounded,
            title: 'Detailed insights',
            subtitle: 'Open the deeper views behind today\'s phone habit result',
            onTap: () => Get.to(() => const InsightsScreen()),
          ),
        ],
      ),
    );
  }

  List<_CoachChallenge> _buildChallengeSuggestions() {
    final socialHours = controller.featureValue('social_media_hours');
    final gamingHours = controller.featureValue('gaming_hours');
    final sleepHours = controller.featureValue('sleep_hours');
    final pickups = controller.featureValue('app_opens_per_day');
    final suggestions = <_CoachChallenge>[];

    if (socialHours >= 1.5 || controller.mostUsedCategory == 'Social') {
      suggestions.add(
        _CoachChallenge(
          id: 'reduce_social_media',
          title: 'Reduce social media by 20 minutes',
          description: 'Try one calmer block away from social apps today.',
          progressHint: 'Social ${_hoursLabel(socialHours)}',
        ),
      );
    }

    if (gamingHours >= 1 || controller.mostUsedCategory == 'Gaming') {
      suggestions.add(
        _CoachChallenge(
          id: 'reduce_gaming',
          title: 'Set a shorter gaming window',
          description: 'Pause once before opening a game and keep one session shorter.',
          progressHint: 'Gaming ${_hoursLabel(gamingHours)}',
        ),
      );
    }

    if (sleepHours < 7 || HiveService.instance.getReduceNightUsageGoal()) {
      suggestions.add(
        _CoachChallenge(
          id: 'phone_free_bedtime',
          title: 'No phone 30 minutes before sleep',
          description: 'Protect the end of the day with a calmer phone routine.',
          progressHint: '${sleepHours.toStringAsFixed(1)} h sleep input',
        ),
      );
    }

    if (pickups >= 35 || controller.wellbeingGoal == 'focus_work_study') {
      suggestions.add(
        _CoachChallenge(
          id: 'focus_session',
          title: 'Start a 45-minute focus block',
          description: 'Choose one quieter block with fewer quick checks.',
          progressHint: '${pickups > 0 ? pickups.round() : 'No'} pickups',
        ),
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        const _CoachChallenge(
          id: 'build_balance',
          title: 'Keep a balanced phone routine',
          description: 'Pick one intentional phone-free moment and keep the rest steady.',
          progressHint: 'Steady day',
        ),
      );
    }

    return suggestions;
  }

  _CoachChallenge _resolveSelectedChallenge(List<_CoachChallenge> suggestions) {
    return suggestions.firstWhere(
      (challenge) => challenge.id == selectedChallenge,
      orElse: () => suggestions.first,
    );
  }

  String _hoursLabel(double hours) {
    return hours > 0 ? TimeFormatter.formatHoursShort(hours) : 'not available';
  }

  bool get _completedToday {
    return HiveService.instance.hasCompletedCoachChallengeOn(_todayKey);
  }

  String get _todayKey {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.toIso8601String().substring(0, 10);
  }

  Future<void> _markChallengeDone(_CoachChallenge activeChallenge) async {
    final added = HiveService.instance.markCoachChallengeCompletedOn(_todayKey);
    if (!added) {
      Get.snackbar(
        'Already counted today',
        'Your challenge is already marked as done for today.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      setState(() {});
      return;
    }

    Get.snackbar(
      'Nice work',
      'Small progress matters. "${activeChallenge.title}" has been counted for today.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    setState(() {});
  }

  Future<void> _openChallengePicker(List<_CoachChallenge> suggestions) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose today\'s challenge',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                ...suggestions.take(5).map(
                  (challenge) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChallengeTile(
                      challenge: challenge,
                      selected: challenge.id == selectedChallenge,
                      onTap: () {
                        _selectChallenge(challenge.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectChallenge(String challengeId) async {
    HiveService.instance.saveSelectedCoachChallenge(challengeId);
    setState(() => selectedChallenge = challengeId);

    if (HiveService.instance.getReminderEnabled()) {
      final time = HiveService.instance.getReminderTime();
      await ReminderNotificationService.scheduleDailyReminder(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }
}

class _CoachChallenge {
  const _CoachChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.progressHint,
  });

  final String id;
  final String title;
  final String description;
  final String progressHint;
}

class _CoachRow extends StatelessWidget {
  const _CoachRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withAlpha(
            Theme.of(context).brightness == Brightness.dark ? 14 : 120,
          ),
          border: Border.all(color: Colors.white.withAlpha(24)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AiModulePalette.teal.withAlpha(18),
              ),
              child: Icon(icon, color: AiModulePalette.teal, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AiModulePalette.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AiModulePalette.textSecondary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AiModulePalette.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({
    required this.challenge,
    required this.selected,
    required this.onTap,
  });

  final _CoachChallenge challenge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? AiModulePalette.teal.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 28 : 16,
                )
              : Colors.white.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 14 : 120,
                ),
          border: Border.all(
            color: selected
                ? AiModulePalette.teal.withAlpha(100)
                : Colors.white.withAlpha(24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AiModulePalette.teal : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AiModulePalette.teal
                      : AiModulePalette.textSecondary(context),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: TextStyle(
                      color: AiModulePalette.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: AiModulePalette.textSecondary(context),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 14 : 120,
        ),
        border: Border.all(color: Colors.white.withAlpha(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
