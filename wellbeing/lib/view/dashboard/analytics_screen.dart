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

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIController>();

    return AiModuleScaffold(
      title: 'Dashboard',
      subtitle:
          'A steady view of your latest wellbeing patterns, using the most recent analysis available on your device.',
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
                              'Your current balance',
                              style: TextStyle(
                                color: AiModulePalette.textPrimary(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          AiStatusBadge(
                            label: '${controller.riskCategory} support need',
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
                            label: 'Latest result',
                            value:
                                '${(controller.riskScore.value * 100).round()}%',
                          ),
                          AiMetricPill(
                            label: 'Source',
                            value: controller.hasSmartTrackingData
                                ? 'Smart Tracking'
                                : 'Manual Assessment',
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
              if (controller.hasSmartTrackingData) ...[
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 60,
                  child: _buildWeeklyChartCard(context),
                ),
              ],
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 100,
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
                            ? 'See Detailed Analysis'
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
                  delayMs: 200,
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
