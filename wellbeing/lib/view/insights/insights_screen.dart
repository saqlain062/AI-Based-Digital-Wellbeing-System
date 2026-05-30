import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_details_screen.dart';
import '../dashboard/ai_analysis_screen.dart';
import '../dashboard/ai_module_widgets.dart';
import '../dashboard/analytics_screen.dart';
import '../dashboard/usage_report_screen.dart';

enum InsightsSection { overview, usageReport, appActivity }

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    this.initialSection = InsightsSection.overview,
  });

  final InsightsSection initialSection;

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Insights',
      subtitle: 'Detailed views for the patterns behind today\'s phone habit check-in.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(child: _buildSectionList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionList(BuildContext context) {
    final tiles = [
      _InsightNavTile(
        icon: Icons.psychology_alt_rounded,
        title: 'Detailed Analysis',
        subtitle: 'See the main factors, confidence, and explanation behind today\'s result.',
        emphasized: initialSection == InsightsSection.overview,
        onTap: () => Get.to(() => const AIAnalysisScreen()),
      ),
      _InsightNavTile(
        icon: Icons.timeline_rounded,
        title: 'Weekly Trends',
        subtitle: 'Review weekly screen-time patterns and the saved daily report.',
        emphasized: initialSection == InsightsSection.overview,
        onTap: () => Get.to(
          () => const AnalyticsScreen(
            title: 'Weekly Trends',
            subtitle:
                'A detailed view of your recent screen-time pattern and stored daily summaries.',
          ),
        ),
      ),
      _InsightNavTile(
        icon: Icons.bar_chart_rounded,
        title: 'Usage Report',
        subtitle: 'Open the fuller device usage report and category-level breakdown.',
        emphasized: initialSection == InsightsSection.usageReport,
        onTap: () => Get.to(() => const UsageReportScreen()),
      ),
      _InsightNavTile(
        icon: Icons.apps_rounded,
        title: 'App Activity',
        subtitle: 'Review the most active apps and category patterns from recent usage.',
        emphasized: initialSection == InsightsSection.appActivity,
        onTap: () => Get.to(() => const AppDetailsScreen()),
      ),
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.insights_rounded,
            title: 'Detail Views',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          ...tiles.expand((tile) => [tile, const SizedBox(height: 12)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

class _InsightNavTile extends StatelessWidget {
  const _InsightNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: emphasized
              ? AiModulePalette.teal.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 28 : 18,
                )
              : Colors.white.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 14 : 120,
                ),
          border: Border.all(
            color: emphasized
                ? AiModulePalette.teal.withAlpha(100)
                : Colors.white.withAlpha(24),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AiModulePalette.teal.withAlpha(18),
              ),
              child: Icon(icon, color: AiModulePalette.teal, size: 20),
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
                      height: 1.4,
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
