import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../util/time_formatter.dart';
import '../../util/theme/wellbeing_theme.dart';
import '../dashboard/ai_module_widgets.dart';
import '../insights/insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenCoach,
  });

  final VoidCallback onOpenCoach;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _refreshStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeHomeData());
  }

  Future<void> _primeHomeData() async {
    if (_refreshStarted) return;
    _refreshStarted = true;
    await _runRefresh(
      showLoader: true,
      loaderMessage: 'Refreshing today\'s check-in...',
    );
  }

  Future<void> _runRefresh({
    required bool showLoader,
    String loaderMessage = 'Refreshing your check-in...',
  }) async {
    final controller = Get.find<AIController>();

    try {
      await controller.ensureReady();
      if (showLoader) {
        await EasyLoading.show(
          status: loaderMessage,
          maskType: EasyLoadingMaskType.black,
        );
      }

      if (controller.hasSmartTrackingData) {
        await controller.loadUsage();
      }
      await controller.runInference(showLoading: false);
    } catch (_) {
      // Keep the last visible state if the refresh does not complete.
    } finally {
      if (showLoader) {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIController>();

    return AiModuleScaffold(
      title: 'Today',
      subtitle: 'Your phone habit check-in',
      child: Obx(() {
        final riskColor = AiModulePalette.riskColor(controller.riskCategory);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AiFadeSlideIn(child: _buildHeroCard(controller, riskColor)),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 60,
                child: _buildReasonCard(context, controller),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 120,
                child: _buildNextActionCard(context, controller),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 180,
                child: _buildPatternCard(context, controller),
              ),
              const SizedBox(height: 14),
              AiFadeSlideIn(
                delayMs: 240,
                child: _buildQuickActionsRow(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroCard(AIController controller, Color riskColor) {
    return AiGlassCard(
      padding: EdgeInsets.zero,
      gradient: WellbeingTheme.heroGradient,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 520;
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AiStatusBadge(
                      label: controller.balanceCategory,
                      color: riskColor,
                    ),
                    AiMetricPill(
                      label: 'Source',
                      value: controller.hasSmartTrackingData
                          ? 'Smart Tracking'
                          : 'Manual Check-in',
                    ),
                    AiMetricPill(
                      label: 'Confidence',
                      value: '${(controller.confidenceScore * 100).round()}%',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  controller.balanceSignalLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.supportiveMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );

            return wide
                ? Row(
                    children: [
                      AiAnimatedProgressRing(
                        progress: controller.riskScore.value,
                        color: riskColor,
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: details),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AiAnimatedProgressRing(
                        progress: controller.riskScore.value,
                        color: riskColor,
                      ),
                      const SizedBox(height: 20),
                      details,
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildReasonCard(BuildContext context, AIController controller) {
    final reasons = _buildReasons(controller);

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.psychology_alt_outlined,
            title: 'Why this result?',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            'Your result was mostly shaped by these patterns today.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReasonTile(reason: reason),
            ),
          ),
        ],
      ),
    );
  }

  List<_ReasonItem> _buildReasons(AIController controller) {
    final candidates = <_ReasonItem>[
      if (controller.featureValue('social_media_hours') >= 1.5)
        _ReasonItem(
          title: 'Social media time',
          description: 'You spent more time than usual in social apps today.',
          score: controller.featureValue('social_media_hours') + 0.8,
          icon: Icons.people_alt_rounded,
        ),
      if (controller.featureValue('sleep_hours') > 0 &&
          controller.featureValue('sleep_hours') < 7)
        _ReasonItem(
          title: 'Sleep duration',
          description: 'Lower sleep can make phone habits harder to keep steady.',
          score: 8 - controller.featureValue('sleep_hours'),
          icon: Icons.bedtime_rounded,
        ),
      if (controller.featureValue('daily_screen_time_hours') >= 4.5)
        _ReasonItem(
          title: 'Total screen time',
          description: 'Your overall screen time was one of the stronger signals today.',
          score: controller.featureValue('daily_screen_time_hours'),
          icon: Icons.phone_android_rounded,
        ),
      if (controller.featureValue('gaming_hours') >= 1)
        _ReasonItem(
          title: 'Gaming time',
          description: 'Entertainment use added to your phone habit load today.',
          score: controller.featureValue('gaming_hours') + 0.6,
          icon: Icons.sports_esports_rounded,
        ),
      if (controller.featureValue('stress_level') >= 1)
        _ReasonItem(
          title: 'Stress level',
          description: 'Higher stress can make quick phone checks more tempting.',
          score: controller.featureValue('stress_level') + 0.4,
          icon: Icons.self_improvement_rounded,
        ),
      if (controller.featureValue('app_opens_per_day') >= 35)
        _ReasonItem(
          title: 'Phone checking',
          description: 'Frequent app opens suggest more fragmented attention across the day.',
          score: controller.featureValue('app_opens_per_day') / 20,
          icon: Icons.touch_app_rounded,
        ),
    ]..sort((a, b) => b.score.compareTo(a.score));

    if (candidates.isEmpty) {
      return const [
        _ReasonItem(
          title: 'Steady routine',
          description: 'The current pattern looks relatively balanced across the main habit signals.',
          score: 0,
          icon: Icons.check_circle_outline_rounded,
        ),
      ];
    }

    return candidates.take(3).toList();
  }

  Widget _buildNextActionCard(BuildContext context, AIController controller) {
    final recommendationText = controller.hasRecommendation
        ? controller.recommendation.value.split('\n').first.trim()
        : 'The app will show one simple next step here after analysis is available.';

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Recommended action',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 14),
          if (controller.recommendationContext.value.isNotEmpty) ...[
            Text(
              'Based on ${controller.recommendationContext.value.toLowerCase()}',
              style: const TextStyle(
                color: AiModulePalette.teal,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            recommendationText,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AiPrimaryButton(
            label: 'Start today\'s challenge',
            onPressed: widget.onOpenCoach,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(BuildContext context, AIController controller) {
    final items = [
      _SummaryTileData(
        label: 'Screen Time',
        value: _hoursOrUnavailable(controller.featureValue('daily_screen_time')),
        icon: Icons.phone_android_rounded,
      ),
      _SummaryTileData(
        label: 'Social Media',
        value: _hoursOrUnavailable(controller.featureValue('social_media_hours')),
        icon: Icons.people_alt_rounded,
      ),
      _SummaryTileData(
        label: 'Gaming',
        value: _hoursOrUnavailable(controller.featureValue('gaming_hours')),
        icon: Icons.sports_esports_rounded,
      ),
      _SummaryTileData(
        label: 'Sleep',
        value: '${controller.featureValue('sleep_hours').toStringAsFixed(1)} h',
        icon: Icons.bedtime_rounded,
      ),
    ];

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.wb_sunny_outlined,
            title: 'Today\'s pattern',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.50,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: AiModulePalette.teal, size: 18),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: AiModulePalette.textSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: TextStyle(
                        color: AiModulePalette.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            onTap: () => _runRefresh(
              showLoader: true,
              loaderMessage: 'Refreshing your check-in...',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.insights_rounded,
            label: 'Detailed insights',
            onTap: () => Get.to(() => const InsightsScreen()),
          ),
        ),
      ],
    );
  }

  String _hoursOrUnavailable(double hours) {
    if (hours <= 0) return 'Not available';
    return TimeFormatter.formatHoursShort(hours);
  }
}

class _SummaryTileData {
  const _SummaryTileData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _ReasonItem {
  const _ReasonItem({
    required this.title,
    required this.description,
    required this.score,
    required this.icon,
  });

  final String title;
  final String description;
  final double score;
  final IconData icon;
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.reason});

  final _ReasonItem reason;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AiModulePalette.teal.withAlpha(18),
            ),
            child: Icon(reason.icon, color: AiModulePalette.teal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reason.title,
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason.description,
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
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withAlpha(
            Theme.of(context).brightness == Brightness.dark ? 14 : 120,
          ),
          border: Border.all(color: Colors.white.withAlpha(24)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AiModulePalette.teal),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AiModulePalette.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
