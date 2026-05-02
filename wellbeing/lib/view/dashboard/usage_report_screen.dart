import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../services/category_service.dart';
import '../../services/usage_feature_service.dart';
import '../../util/time_formatter.dart';
import 'ai_module_widgets.dart';

class UsageReportScreen extends StatefulWidget {
  const UsageReportScreen({super.key});

  @override
  State<UsageReportScreen> createState() => _UsageReportScreenState();
}

class _UsageReportScreenState extends State<UsageReportScreen> {
  final AIController controller = Get.find<AIController>();
  late Future<List<Map<String, dynamic>>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = UsageFeatureService(
      CategoryService(),
    ).getTopApps(limit: 1000, includeIcons: false);
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Full Usage Report',
      subtitle:
          'A fuller view of the signals behind your result, built from the device activity currently available on this phone.',
      showBack: true,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appsFuture,
        builder: (context, snapshot) {
          final apps = snapshot.data ?? const <Map<String, dynamic>>[];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiFadeSlideIn(child: _buildOverviewCard(context, apps)),
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 100,
                  child: _buildUsageSignalsCard(context),
                ),
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 180,
                  child: _buildPersonalSignalsCard(context),
                ),
                if (apps.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  AiFadeSlideIn(
                    delayMs: 260,
                    child: _buildCategoryBreakdownCard(context, apps),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    List<Map<String, dynamic>> apps,
  ) {
    final totalUsage = controller.featureValue('daily_screen_time');
    final topCategory = controller.mostUsedCategory == 'Unavailable'
        ? 'Not available yet'
        : controller.mostUsedCategory;

    return AiGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AiModulePalette.blue.withAlpha(210),
          AiModulePalette.purple.withAlpha(190),
          AiModulePalette.teal.withAlpha(170),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.summarize_rounded,
            title: 'Usage Overview',
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ReportMetricPill(
                label: 'Daily screen time',
                value: TimeFormatter.formatHoursShort(totalUsage),
              ),
              _ReportMetricPill(
                label: 'App opens',
                value: controller.featureValue('app_opens') > 0
                    ? '${controller.featureValue('app_opens').round()}/day'
                    : 'Not available yet',
              ),
              _ReportMetricPill(
                label: 'Notifications',
                value: controller.featureValue('notifications') > 0
                    ? '${controller.featureValue('notifications').round()}/day'
                    : 'Not available yet',
              ),
              _ReportMetricPill(
                label: 'Tracked apps',
                value: apps.isEmpty ? 'Not available yet' : '${apps.length}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your most active category right now is $topCategory. This report stays on-device and only reflects the signals currently available to the app.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSignalsCard(BuildContext context) {
    final signals = [
      _ReportSignal(
        label: 'Daily Screen Time',
        value: TimeFormatter.formatHoursShort(
          controller.featureValue('daily_screen_time'),
        ),
        helper: _impactForUsage(controller.featureValue('daily_screen_time')),
        icon: Icons.phone_android_rounded,
      ),
      _ReportSignal(
        label: 'Session Duration',
        value: controller.sessionDurationMinutes > 0
            ? '${controller.sessionDurationMinutes} min'
            : 'Not available yet',
        helper: controller.usageTrendLabel == 'Up'
            ? 'Longer than your weekday pattern'
            : controller.usageTrendLabel == 'Down'
            ? 'Lighter than your weekday pattern'
            : 'Steady lately',
        icon: Icons.timelapse_rounded,
      ),
      _ReportSignal(
        label: 'Pickup Frequency',
        value: controller.featureValue('app_opens') > 0
            ? '${controller.featureValue('app_opens').round()}/day'
            : 'Not available yet',
        helper: _impactForPickups(controller.featureValue('app_opens')),
        icon: Icons.touch_app_rounded,
      ),
      _ReportSignal(
        label: 'Notifications',
        value: controller.featureValue('notifications') > 0
            ? '${controller.featureValue('notifications').round()}/day'
            : 'Not available yet',
        helper: controller.featureValue('notifications') >= 80
            ? 'High interruption level'
            : controller.featureValue('notifications') >= 35
            ? 'Moderate interruption level'
            : 'Low interruption level',
        icon: Icons.notifications_active_rounded,
      ),
      _ReportSignal(
        label: 'Weekend Pattern',
        value: controller.featureValue('weekend_screen') > 0
            ? TimeFormatter.formatHoursShort(
                controller.featureValue('weekend_screen'),
              )
            : 'Not available yet',
        helper: controller.usageTrendLabel == 'Up'
            ? 'Higher on weekends'
            : controller.usageTrendLabel == 'Down'
            ? 'Lower on weekends'
            : 'Close to your usual pattern',
        icon: Icons.event_rounded,
      ),
      _ReportSignal(
        label: 'Most Used Category',
        value: controller.mostUsedCategory == 'Unavailable'
            ? 'Not available yet'
            : controller.mostUsedCategory,
        helper: 'Used in your latest analysis',
        icon: Icons.category_rounded,
      ),
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.network_check_rounded,
            title: 'Usage Signals',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          ...signals.map((signal) => _UsageSignalTile(signal: signal)),
        ],
      ),
    );
  }

  Widget _buildPersonalSignalsCard(BuildContext context) {
    final signals = [
      _ReportSignal(
        label: 'Age',
        value: '${controller.featureValue('age').round()} yrs',
        helper: 'Included in the prediction',
        icon: Icons.cake_rounded,
      ),
      _ReportSignal(
        label: 'Sleep Hours',
        value: '${controller.featureValue('sleep_hours').toStringAsFixed(1)} h',
        helper: _impactForSleep(controller.featureValue('sleep_hours')),
        icon: Icons.bedtime_rounded,
      ),
      _ReportSignal(
        label: 'Stress Level',
        value:
            '${controller.featureValue('stress_level').toStringAsFixed(1)}/10',
        helper: _impactForStress(controller.featureValue('stress_level')),
        icon: Icons.spa_rounded,
      ),
      _ReportSignal(
        label: 'Work or Study Hours',
        value:
            '${controller.featureValue('work_study_hours').toStringAsFixed(1)} h',
        helper: 'Part of your balance profile',
        icon: Icons.school_rounded,
      ),
      _ReportSignal(
        label: 'Academic Impact',
        value:
            '${controller.featureValue('academic_impact').toStringAsFixed(1)}/10',
        helper: _impactForStress(controller.featureValue('academic_impact')),
        icon: Icons.trending_up_rounded,
      ),
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.person_search_rounded,
            title: 'Personal Signals',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 16),
          ...signals.map((signal) => _UsageSignalTile(signal: signal)),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context,
    List<Map<String, dynamic>> apps,
  ) {
    final Map<String, _CategorySummary> categories = {};
    double totalHours = 0;

    for (final app in apps) {
      final category = (app['category'] as String?) ?? 'Other';
      final hours = (app['usageHours'] as double?) ?? 0;
      totalHours += hours;

      categories.update(
        category,
        (current) => current.copyWith(
          hours: current.hours + hours,
          apps: current.apps + 1,
        ),
        ifAbsent: () => _CategorySummary(
          category: category,
          hours: hours,
          apps: 1,
        ),
      );
    }

    final ranked = categories.values.toList()
      ..sort((a, b) => b.hours.compareTo(a.hours));

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Category Breakdown',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 16),
          ...ranked.map((category) {
            final share = totalHours <= 0 ? 0.0 : category.hours / totalHours;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.category,
                          style: TextStyle(
                            color: AiModulePalette.textPrimary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${TimeFormatter.formatHoursShort(category.hours)}  |  ${category.apps} apps',
                        style: TextStyle(
                          color: AiModulePalette.textSecondary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: share,
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha(24),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _categoryColor(category.category),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _impactForUsage(double hours) {
    if (hours >= 6) return 'Higher usage signal';
    if (hours >= 4) return 'Moderate usage signal';
    return 'Lighter usage signal';
  }

  String _impactForSleep(double hours) {
    if (hours < 6) return 'Sleep may be under pressure';
    if (hours < 7) return 'Sleep is slightly below ideal';
    return 'Sleep looks steady';
  }

  String _impactForStress(double value) {
    if (value >= 7) return 'Higher stress signal';
    if (value >= 4) return 'Moderate stress signal';
    return 'Lighter stress signal';
  }

  String _impactForPickups(double value) {
    if (value >= 80) return 'Frequent pickups';
    if (value >= 35) return 'Moderate pickup rate';
    return 'Lighter pickup rate';
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Social':
        return AiModulePalette.blue;
      case 'Communication':
        return AiModulePalette.teal;
      case 'Entertainment':
        return const Color(0xFFF59E0B);
      case 'Productivity':
        return const Color(0xFF6366F1);
      case 'Finance':
        return const Color(0xFF0F766E);
      case 'Education':
        return const Color(0xFF7C3AED);
      case 'Shopping':
        return const Color(0xFFDB2777);
      case 'Travel':
        return const Color(0xFF0891B2);
      case 'News':
        return const Color(0xFFDC2626);
      case 'Game':
        return AiModulePalette.purple;
      default:
        return const Color(0xFF64748B);
    }
  }
}

class _ReportMetricPill extends StatelessWidget {
  const _ReportMetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
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

class _ReportSignal {
  const _ReportSignal({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
}

class _UsageSignalTile extends StatelessWidget {
  const _UsageSignalTile({required this.signal});

  final _ReportSignal signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AiModulePalette.teal.withAlpha(22),
            ),
            child: Icon(signal.icon, color: AiModulePalette.teal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.label,
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  signal.helper,
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            signal.value,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySummary {
  const _CategorySummary({
    required this.category,
    required this.hours,
    required this.apps,
  });

  final String category;
  final double hours;
  final int apps;

  _CategorySummary copyWith({
    String? category,
    double? hours,
    int? apps,
  }) {
    return _CategorySummary(
      category: category ?? this.category,
      hours: hours ?? this.hours,
      apps: apps ?? this.apps,
    );
  }
}
