import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../services/category_service.dart';
import '../../services/usage_feature_service.dart';
import '../../util/time_formatter.dart';
import '../app_details_screen.dart';
import '../permission_screen.dart';
import 'ai_module_widgets.dart';
import 'usage_report_screen.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key, this.initialTopApps});

  final List<Map<String, dynamic>>? initialTopApps;

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  final AIController controller = Get.find<AIController>();
  late Future<List<Map<String, dynamic>>> _topAppsFuture;

  @override
  void initState() {
    super.initState();
    _topAppsFuture = widget.initialTopApps != null
        ? Future.value(widget.initialTopApps)
        : _loadTopApps();
  }

  Future<List<Map<String, dynamic>>> _loadTopApps() {
    if (!controller.hasSmartTrackingData) {
      return Future.value(const []);
    }

    return UsageFeatureService(CategoryService()).getTopApps(limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Detailed AI Analysis',
      subtitle:
          'A closer look at what influenced your result, using only the information currently available on your device.',
      showBack: true,
      child: Obx(() {
        final riskColor = AiModulePalette.riskColor(controller.riskCategory);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AiFadeSlideIn(child: _buildPredictionSummary(context, riskColor)),
              const SizedBox(height: 18),
              if (controller.hasSmartTrackingData) ...[
                AiFadeSlideIn(delayMs: 100, child: _buildTopAppsCard(context)),
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 180,
                  child: _buildSmartTrackingFactors(context),
                ),
                if (controller.hasRecommendation) ...[
                  const SizedBox(height: 18),
                  AiFadeSlideIn(
                    delayMs: 260,
                    child: _buildRecommendationCard(context),
                  ),
                ],
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 340,
                  child: AiPrimaryButton(
                    label: 'Open Full Usage Report',
                    onPressed: () => Get.to(() => const UsageReportScreen()),
                  ),
                ),
              ] else ...[
                AiFadeSlideIn(
                  delayMs: 100,
                  child: _buildManualFactors(context),
                ),
                const SizedBox(height: 18),
                AiFadeSlideIn(delayMs: 180, child: _buildUpgradeCard(context)),
                if (controller.hasRecommendation) ...[
                  const SizedBox(height: 18),
                  AiFadeSlideIn(
                    delayMs: 260,
                    child: _buildRecommendationCard(context),
                  ),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPredictionSummary(BuildContext context, Color riskColor) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.insights_rounded,
            title: 'Prediction Summary',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiMetricPill(
                label: 'Current score',
                value: '${(controller.riskScore.value * 100).round()}%',
              ),
              AiMetricPill(
                label: 'Current level',
                value: controller.riskCategory,
              ),
              AiMetricPill(
                label: 'Confidence',
                value: '${(controller.confidenceScore * 100).round()}%',
              ),
              AiMetricPill(
                label: 'Analysis source',
                value: controller.hasSmartTrackingData
                    ? 'Smart Tracking'
                    : 'Manual Assessment',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            controller.supportiveMessage,
            style: TextStyle(
              color: riskColor,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartTrackingFactors(BuildContext context) {
    final deviceFactors = [
      _FactorTileData(
        label: 'Daily Screen Time',
        value: TimeFormatter.formatHoursShort(
          controller.featureValue('daily_screen_time'),
        ),
        impact: _impactForUsage(controller.featureValue('daily_screen_time')),
        trend: controller.usageTrendLabel,
        icon: Icons.phone_android_rounded,
      ),
      _FactorTileData(
        label: 'Session Duration',
        value: controller.sessionDurationMinutes > 0
            ? '${controller.sessionDurationMinutes} min'
            : 'Not available yet',
        impact: controller.sessionDurationMinutes >= 8 ? 'Moderate' : 'Low',
        trend: 'Stable',
        icon: Icons.timelapse_rounded,
      ),
      _FactorTileData(
        label: 'Pickup Frequency',
        value: controller.featureValue('app_opens') > 0
            ? '${controller.featureValue('app_opens').round()}/day'
            : 'Not available yet',
        impact: _impactForPickups(controller.featureValue('app_opens')),
        trend: controller.usageTrendLabel,
        icon: Icons.touch_app_rounded,
      ),
      _FactorTileData(
        label: 'Most Used Category',
        value: controller.mostUsedCategory == 'Unavailable'
            ? 'Not available yet'
            : controller.mostUsedCategory,
        impact: controller.mostUsedCategory == 'Social' ? 'High' : 'Low',
        trend: 'Stable',
        icon: Icons.category_rounded,
      ),
    ];

    final personalFactors = [
      _FactorTileData(
        label: 'Age',
        value: '${controller.featureValue('age').round()} yrs',
        impact: 'Low',
        trend: 'Stable',
        icon: Icons.cake_rounded,
      ),
      _FactorTileData(
        label: 'Sleep Hours',
        value: '${controller.featureValue('sleep_hours').toStringAsFixed(1)} h',
        impact: _impactForSleep(controller.featureValue('sleep_hours')),
        trend: 'Stable',
        icon: Icons.bedtime_rounded,
      ),
      _FactorTileData(
        label: 'Stress Level',
        value:
            '${controller.featureValue('stress_level').toStringAsFixed(1)}/10',
        impact: _impactForStress(controller.featureValue('stress_level')),
        trend: 'Stable',
        icon: Icons.spa_rounded,
      ),
      _FactorTileData(
        label: 'Work Hours',
        value:
            '${controller.featureValue('work_study_hours').toStringAsFixed(1)} h',
        impact: 'Moderate',
        trend: 'Stable',
        icon: Icons.school_rounded,
      ),
      _FactorTileData(
        label: 'Academic Impact',
        value:
            '${controller.featureValue('academic_impact').toStringAsFixed(1)}/10',
        impact: _impactForStress(controller.featureValue('academic_impact')),
        trend: 'Stable',
        icon: Icons.trending_up_rounded,
      ),
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.tune_rounded,
            title: 'Key Factors',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          Text(
            'Device Usage Signals',
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...deviceFactors.map((factor) => _FactorTile(data: factor)),
          const SizedBox(height: 16),
          Text(
            'Personal Check-In Signals',
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...personalFactors.map((factor) => _FactorTile(data: factor)),
        ],
      ),
    );
  }

  Widget _buildTopAppsCard(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _topAppsFuture,
      builder: (context, snapshot) {
        final apps = snapshot.data ?? const <Map<String, dynamic>>[];

        if (apps.isEmpty) {
          return const SizedBox.shrink();
        }

        final maxUsage = apps
            .map((app) => (app['usageHours'] as double?) ?? 0)
            .fold<double>(
              0.0,
              (current, next) => next > current ? next : current,
            );

        return AiGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AiSectionTitle(
                icon: Icons.apps_rounded,
                title: 'Most Active Apps',
                color: AiModulePalette.purple,
              ),
              const SizedBox(height: 16),
              ...apps.map((app) {
                final hours = (app['usageHours'] as double?) ?? 0;
                final progress = maxUsage == 0 ? 0.0 : hours / maxUsage;
                final name = (app['appName'] as String?) ?? 'Unknown App';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      AiAppIcon(
                        name: name,
                        iconBytes: app['iconBytes'] as Uint8List?,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AiModulePalette.textPrimary(
                                        context,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  TimeFormatter.formatHoursShort(hours),
                                  style: TextStyle(
                                    color: AiModulePalette.textSecondary(
                                      context,
                                    ),
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
                                value: progress,
                                minHeight: 7,
                                backgroundColor: Colors.white.withAlpha(25),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AiModulePalette.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              AiSecondaryButton(
                label: 'Open App Activity',
                onPressed: () => Get.to(() => const AppDetailsScreen()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManualFactors(BuildContext context) {
    final factors = [
      _FactorTileData(
        label: 'Age',
        value: '${controller.featureValue('age').round()} yrs',
        impact: 'Low',
        trend: 'Stable',
        icon: Icons.cake_rounded,
      ),
      _FactorTileData(
        label: 'Sleep Hours',
        value: '${controller.featureValue('sleep_hours').toStringAsFixed(1)} h',
        impact: _impactForSleep(controller.featureValue('sleep_hours')),
        trend: 'Stable',
        icon: Icons.bedtime_rounded,
      ),
      _FactorTileData(
        label: 'Stress Level',
        value:
            '${controller.featureValue('stress_level').toStringAsFixed(1)}/10',
        impact: _impactForStress(controller.featureValue('stress_level')),
        trend: 'Stable',
        icon: Icons.spa_rounded,
      ),
      _FactorTileData(
        label: 'Work Hours',
        value:
            '${controller.featureValue('work_study_hours').toStringAsFixed(1)} h',
        impact: 'Moderate',
        trend: 'Stable',
        icon: Icons.school_rounded,
      ),
      _FactorTileData(
        label: 'Academic Impact',
        value:
            '${controller.featureValue('academic_impact').toStringAsFixed(1)}/10',
        impact: _impactForStress(controller.featureValue('academic_impact')),
        trend: 'Stable',
        icon: Icons.trending_up_rounded,
      ),
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Personal Check-In',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 16),
          ...factors.map((factor) => _FactorTile(data: factor)),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context) {
    final benefits = [
      'Automatic screen time tracking',
      'App-level usage insights',
      'A more confident result',
      'Recommendations shaped by real patterns',
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.lock_open_rounded,
            title: 'Unlock Smarter Insights',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            'Enable smart tracking if you want the app to include real device behaviour alongside your manual input.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AiModulePalette.teal,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        color: AiModulePalette.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AiPrimaryButton(
            label: 'Enable Smart Tracking',
            onPressed: () => Get.to(() => const PermissionScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Suggested Next Steps',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
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
    );
  }

  String _impactForUsage(double hours) {
    if (hours >= 6) return 'High';
    if (hours >= 4) return 'Moderate';
    return 'Low';
  }

  String _impactForSleep(double hours) {
    if (hours < 6) return 'High';
    if (hours < 7) return 'Moderate';
    return 'Low';
  }

  String _impactForStress(double value) {
    if (value >= 7) return 'High';
    if (value >= 4) return 'Moderate';
    return 'Low';
  }

  String _impactForPickups(double value) {
    if (value >= 80) return 'High';
    if (value >= 35) return 'Moderate';
    return 'Low';
  }
}

class _FactorTileData {
  const _FactorTileData({
    required this.label,
    required this.value,
    required this.impact,
    required this.trend,
    required this.icon,
  });

  final String label;
  final String value;
  final String impact;
  final String trend;
  final IconData icon;
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.data});

  final _FactorTileData data;

  @override
  Widget build(BuildContext context) {
    final impactColor = AiModulePalette.riskColor(
      data.impact == 'High'
          ? 'High'
          : data.impact == 'Moderate'
          ? 'Moderate'
          : 'Low',
    );

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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: impactColor.withAlpha(28),
            ),
            child: Icon(data.icon, color: impactColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.value,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AiStatusBadge(label: '${data.impact} impact', color: impactColor),
              const SizedBox(height: 6),
              Text(
                _trendLabel(data.trend),
                style: TextStyle(
                  color: AiModulePalette.textSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _trendLabel(String trend) {
    switch (trend) {
      case 'Up':
        return 'Slightly increasing';
      case 'Down':
        return 'Slightly easing';
      default:
        return 'Steady lately';
    }
  }
}
