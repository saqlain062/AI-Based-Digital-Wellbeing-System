import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../services/category_service.dart';
import '../../services/hive_service.dart';
import '../../services/usage_feature_service.dart';
import '../../util/time_formatter.dart';
import '../app_details_screen.dart';
import 'ai_analysis_screen.dart';
import 'ai_module_widgets.dart';
import '../permission_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    this.title = 'Insights',
    this.subtitle =
        'A closer look at the patterns behind your current digital balance, including weekly trends and device activity.',
  });

  final String title;
  final String subtitle;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _refreshStarted = false;
  bool _isRefreshingTodayUsage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTodayUsage());
  }

  Future<void> _refreshTodayUsage() async {
    if (_refreshStarted) return;
    _refreshStarted = true;

    if (mounted) {
      setState(() {
        _isRefreshingTodayUsage = true;
      });
    }

    try {
      final controller = Get.find<AIController>();
      await controller.ensureReady();

      if (controller.hasSmartTrackingData) {
        await EasyLoading.show(
          status: 'Refreshing today\'s insights...',
          maskType: EasyLoadingMaskType.black,
        );
      }

      await controller.refreshSmartTrackingUsageSnapshot();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Keep the insights view usable with the last saved snapshot.
    } finally {
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {
          _isRefreshingTodayUsage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIController>();

    return AiModuleScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      child: Obx(() {
        final riskColor = AiModulePalette.riskColor(controller.riskCategory);

        return SingleChildScrollView(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Your current pattern',
                              style: TextStyle(
                                color: AiModulePalette.textPrimary(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          AiStatusBadge(
                            label: controller.balanceSignalLabel,
                            color: riskColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        controller.supportiveMessage,
                        style: TextStyle(
                          color: AiModulePalette.textSecondary(context),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AiMetricPill(
                            label: 'Digital balance score',
                            value:
                                '${(controller.riskScore.value * 100).round()}%',
                          ),
                          AiMetricPill(
                            label: 'Source',
                            value: controller.hasSmartTrackingData
                                ? 'Smart Tracking'
                                : 'Manual Check-in',
                          ),
                          if (controller.hasSmartTrackingData)
                            AiMetricPill(
                              label: 'Screen time',
                              value: TimeFormatter.formatHoursShort(
                                controller.featureValue('daily_screen_time'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 40,
                child: _buildDailyInsightCard(context, controller),
              ),
              if (controller.hasSmartTrackingData) ...[
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 80,
                  child: _isRefreshingTodayUsage
          ? _buildInsightsLoadingCard(context)
                      : _buildWeeklyChartCard(context),
                ),
                const SizedBox(height: 18),
                if (!_isRefreshingTodayUsage)
                  AiFadeSlideIn(
                    delayMs: 120,
                    child: _buildWeeklyReportCard(context, controller),
                  ),
              ],
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 160,
                child: AiGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AiSectionTitle(
                        icon: Icons.bolt_rounded,
                        title: 'Quick Actions',
                        color: AiModulePalette.teal,
                      ),
                      const SizedBox(height: 16),
                      AiPrimaryButton(
                        label: controller.hasSmartTrackingData
                            ? 'Open Detailed Analysis'
                            : 'Enable Smart Tracking',
                        onPressed: controller.hasSmartTrackingData
                            ? _openDetailedAnalysis
                            : () => Get.to(() => const PermissionScreen()),
                      ),
                      if (controller.hasSmartTrackingData) ...[
                        const SizedBox(height: 12),
                        AiSecondaryButton(
                          label: 'View App Usage Details',
                          onPressed: () => Get.to(() => const AppDetailsScreen()),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (controller.hasRecommendation) ...[
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 220,
                  child: AiGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AiSectionTitle(
                          icon: Icons.favorite_border_rounded,
                          title: 'A Gentle Next Step',
                          color: AiModulePalette.purple,
                        ),
                        const SizedBox(height: 14),
                        if (controller.recommendationContext.value.isNotEmpty) ...[
                          Text(
                            'Based on ${controller.recommendationContext.value.toLowerCase()}',
                            style: TextStyle(
                              color: AiModulePalette.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          controller.recommendation.value,
                          style: TextStyle(
                            color: AiModulePalette.textPrimary(context),
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openDetailedAnalysis() async {
    await EasyLoading.show(
      status: 'Opening detailed analysis...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final controller = Get.find<AIController>();
      await controller.loadUsage();

      final topApps = await UsageFeatureService(
        CategoryService(),
      ).getTopApps(limit: 5);

      EasyLoading.dismiss();
      Get.to(() => AIAnalysisScreen(initialTopApps: topApps));
    } catch (_) {
      EasyLoading.dismiss();
      Get.to(() => const AIAnalysisScreen());
    }
  }

  Widget _buildDailyInsightCard(
    BuildContext context,
    AIController controller,
  ) {
    final screenTime = controller.featureValue('daily_screen_time');
    final pickups = controller.featureValue('app_opens');
    final target = HiveService.instance.getDailyScreenTimeTarget();
    final goal = controller.wellbeingGoalLabel;
    final category = controller.mostUsedCategory == 'Unavailable'
        ? 'your current apps'
        : controller.mostUsedCategory.toLowerCase();
    final message = _dailyInsightMessage(
      controller: controller,
      screenTime: screenTime,
      pickups: pickups,
      target: target,
    );

    return AiGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AiModulePalette.teal.withAlpha(210),
          AiModulePalette.blue.withAlpha(190),
          AiModulePalette.purple.withAlpha(160),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.wb_sunny_outlined,
            title: 'Today\'s Insight',
            color: Colors.white,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Goal: $goal. Today we are looking at screen time, pickups, and $category activity.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DailyPill(
                label: 'Today',
                value: screenTime > 0
                    ? TimeFormatter.formatHoursShort(screenTime)
                    : 'Not available',
              ),
              _DailyPill(
                label: 'Target',
                value: TimeFormatter.formatHoursShort(target),
              ),
              _DailyPill(
                label: 'Pickups',
                value: pickups > 0 ? '${pickups.round()}/day' : 'Not available',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dailyInsightMessage({
    required AIController controller,
    required double screenTime,
    required double pickups,
    required double target,
  }) {
    switch (controller.wellbeingGoal) {
      case 'sleep_better':
        if (screenTime > target) {
          return 'A calmer evening reset could support your sleep goal today.';
        }
        return 'Your phone balance looks steady for your sleep goal today.';
      case 'focus_work_study':
        final focusTarget = HiveService.instance.getFocusHoursTarget();
        if (pickups >= 35) {
          return 'Your focus goal may benefit from one pickup-light work block toward your ${focusTarget.toStringAsFixed(1)} hour target.';
        }
        return 'Your focus signals look steady for your ${focusTarget.toStringAsFixed(1)} hour target today.';
      case 'reduce_distractions':
        if (controller.featureValue('social_media_hours') +
                controller.featureValue('gaming_hours') >=
            2) {
          return 'One attention-heavy app category is worth watching today.';
        }
        return 'Your distraction pattern looks lighter today.';
      case 'understand_habits':
        return 'Today is a good day to notice which app category feels useful.';
      default:
        if (screenTime > target) {
          return 'Your phone balance may need a small reset today.';
        }
        return 'Your phone balance looks steady today.';
    }
  }

  Widget _buildWeeklyChartCard(BuildContext context) {
    final entries = _lastSevenDays();
    final maxHours = entries.fold<double>(
      0.0,
      (current, entry) => entry.hours > current ? entry.hours : current,
    );
    final weeklyAverage = entries.isEmpty
        ? 0.0
        : entries.fold<double>(0.0, (sum, entry) => sum + entry.hours) /
            entries.length;

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.bar_chart_rounded,
            title: 'Screen Time This Week',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 14),
          Text(
            'A simple view of your recent daily screen time.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((entry) {
                final ratio = maxHours <= 0 ? 0.0 : entry.hours / maxHours;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _DayBar(
                      label: entry.label,
                      valueLabel: entry.hours > 0
                          ? TimeFormatter.formatHoursShort(entry.hours)
                          : '0m',
                      ratio: ratio,
                      isToday: entry.isToday,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiMetricPill(
                label: 'Weekly average',
                value: TimeFormatter.formatHoursShort(weeklyAverage),
              ),
              AiMetricPill(
                label: 'Highest day',
                value: TimeFormatter.formatHoursShort(maxHours),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsLoadingCard(BuildContext context) {
    return AiGlassCard(
      child: SizedBox(
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AiModulePalette.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Refreshing your weekly screen time...',
              style: TextStyle(
                color: AiModulePalette.textPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The insights view is updating with the latest usage snapshot from your device.',
              textAlign: TextAlign.center,
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
    );
  }

  Widget _buildWeeklyReportCard(
    BuildContext context,
    AIController controller,
  ) {
    final entries = _lastSevenDays();
    final average = entries.isEmpty
        ? 0.0
        : entries.fold<double>(0.0, (sum, entry) => sum + entry.hours) /
            entries.length;
    final highest = entries.fold<_DailyChartPoint?>(
      null,
      (current, entry) =>
          current == null || entry.hours > current.hours ? entry : current,
    );
    final previousEntries = entries.where((entry) => !entry.isToday).toList();
    final previousAverage = previousEntries.isEmpty
        ? 0.0
        : previousEntries.fold<double>(0.0, (sum, entry) => sum + entry.hours) /
            previousEntries.length;
    final today = entries.isEmpty ? 0.0 : entries.last.hours;
    final progressLabel = _weeklyProgressLabel(today, previousAverage);
    final recommendation = _weeklyRecommendation(controller, average);

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.summarize_rounded,
            title: 'Weekly Report',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 14),
          Text(
            recommendation,
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiMetricPill(
                label: 'Average',
                value: TimeFormatter.formatHoursShort(average),
              ),
              AiMetricPill(
                label: 'Highest day',
                value: highest == null
                    ? 'Not available'
                    : '${highest.label} ${TimeFormatter.formatHoursShort(highest.hours)}',
              ),
              AiMetricPill(
                label: 'Most active',
                value: controller.mostUsedCategory == 'Unavailable'
                    ? 'Not available'
                    : controller.mostUsedCategory,
              ),
              AiMetricPill(label: 'Progress', value: progressLabel),
            ],
          ),
        ],
      ),
    );
  }

  String _weeklyProgressLabel(double today, double previousAverage) {
    if (today <= 0 || previousAverage <= 0) return 'Building baseline';
    if (today < previousAverage * 0.9) return 'Lighter today';
    if (today > previousAverage * 1.1) return 'Higher today';
    return 'Steady today';
  }

  String _weeklyRecommendation(AIController controller, double average) {
    final target = HiveService.instance.getDailyScreenTimeTarget();
    switch (controller.wellbeingGoal) {
      case 'sleep_better':
        return HiveService.instance.getReduceNightUsageGoal()
            ? 'This week, protect your evening wind-down by moving one high-use app away from bedtime.'
            : 'This week, keep your sleep routine visible and compare it with your phone use.';
      case 'focus_work_study':
        return 'This week, pair your focus target with one notification-light work or study block.';
      case 'reduce_distractions':
        return 'This week, watch social and entertainment time first, then choose one small limit that feels realistic.';
      case 'understand_habits':
        return 'This week, compare your most active category with whether that time felt intentional.';
      default:
        return average > target
            ? 'This week, aim for one lighter day rather than a perfect streak.'
            : 'This week, keep the routines that are already supporting your balance.';
    }
  }

  List<_DailyChartPoint> _lastSevenDays() {
    final history = HiveService.instance.getAnalysisHistory();
    final controller = Get.find<AIController>();
    final lastAnalysisRaw = HiveService.instance.getUser('lastAnalysis');
    final byDate = <String, Map<String, dynamic>>{
      for (final entry in history)
        if (entry['dateKey'] != null) entry['dateKey'].toString(): entry,
    };

    final now = DateTime.now();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: 6 - index),
      );
      final dateKey = _dateKey(date);
      final entry = byDate[dateKey];
      final weekdayLabel = labels[date.weekday - 1];
      final hours = _historyHoursForDate(
        dateKey: dateKey,
        entry: entry,
        lastAnalysisRaw: lastAnalysisRaw,
        controller: controller,
      );

      return _DailyChartPoint(
        label: weekdayLabel,
        hours: hours,
        isToday: _dateKey(now) == dateKey,
      );
    });
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  double _historyHoursForDate({
    required String dateKey,
    required Map<String, dynamic>? entry,
    required dynamic lastAnalysisRaw,
    required AIController controller,
  }) {
    final entryHours = entry?['screenTimeHours'];
    if (entryHours is num) {
      return entryHours.toDouble();
    }

    if (lastAnalysisRaw is Map) {
      final snapshot = Map<String, dynamic>.from(lastAnalysisRaw);
      final snapshotDateKey =
          snapshot['dateKey']?.toString() ??
          snapshot['timestamp']?.toString().substring(0, 10);
      final snapshotHours = snapshot['screenTimeHours'];

      if (snapshotDateKey == dateKey && snapshotHours is num) {
        return snapshotHours.toDouble();
      }
    }

    final todayKey = _dateKey(DateTime.now());
    if (dateKey == todayKey && controller.hasSmartTrackingData) {
      return controller.featureValue('daily_screen_time');
    }

    return 0.0;
  }
}

class _DailyChartPoint {
  const _DailyChartPoint({
    required this.label,
    required this.hours,
    required this.isToday,
  });

  final String label;
  final double hours;
  final bool isToday;
}

class _DailyPill extends StatelessWidget {
  const _DailyPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.valueLabel,
    required this.ratio,
    required this.isToday,
  });

  final String label;
  final String valueLabel;
  final double ratio;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final barHeight = 24 + (ratio.clamp(0.0, 1.0) * 108);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          valueLabel,
          style: TextStyle(
            color: AiModulePalette.textSecondary(context),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isToday
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AiModulePalette.teal,
                      AiModulePalette.blue,
                      AiModulePalette.purple,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AiModulePalette.blue.withAlpha(170),
                      AiModulePalette.purple.withAlpha(120),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: isToday
                ? AiModulePalette.textPrimary(context)
                : AiModulePalette.textSecondary(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
