import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../controller/ai_controller.dart';
import '../navigation_menu.dart';
import '../services/category_service.dart';
import '../services/usage_feature_service.dart';
import 'dashboard/ai_analysis_screen.dart';
import 'dashboard/ai_module_widgets.dart';
import 'permission_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIController>();

    return AiModuleScaffold(
      title: 'Prediction Result',
      subtitle:
          'A calm snapshot of your current digital wellbeing, based on the information you chose to share with the app.',
      showBack: false,
      child: Obx(() {
        final riskColor = AiModulePalette.riskColor(controller.riskCategory);
        final primaryLabel = controller.hasSmartTrackingData
            ? 'View Detailed Analysis'
            : 'Enable Smart Tracking';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AiFadeSlideIn(
                child: AiGlassCard(
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
                            AiStatusBadge(
                              label: '${controller.riskCategory} support need',
                              color: riskColor,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              controller.supportiveMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                AiMetricPill(
                                  label: 'Confidence',
                                  value:
                                      '${(controller.confidenceScore * 100).round()}%',
                                ),
                                AiMetricPill(
                                  label: 'Source',
                                  value: controller.hasSmartTrackingData
                                      ? 'Smart Tracking'
                                      : 'Manual Assessment',
                                ),
                              ],
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
                ),
              ),
              const SizedBox(height: 18),
              AiFadeSlideIn(
                delayMs: 100,
                child: AiGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AiSectionTitle(
                        icon: Icons.psychology_alt_rounded,
                        title: 'Prediction Snapshot',
                        color: AiModulePalette.teal,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AiMetricPill(
                            label: 'Current risk estimate',
                            value:
                                '${(controller.riskScore.value * 100).round()}%',
                          ),
                          AiMetricPill(
                            label: 'Current level',
                            value: controller.riskCategory,
                          ),
                          if (controller.lastAnalyzedAt.value != null)
                            AiMetricPill(
                              label: 'Last analyzed',
                              value: _formatDate(
                                controller.lastAnalyzedAt.value!,
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
                delayMs: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AiPrimaryButton(
                      label: primaryLabel,
                      onPressed: () async {
                        if (controller.hasSmartTrackingData) {
                          await _openDetailedAnalysis();
                        } else {
                          Get.to(() => const PermissionScreen());
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    AiSecondaryButton(
                      label: 'Go to Dashboard',
                      onPressed: () {
                        Get.offAll(() => const NavigationMenu(initialIndex: 1));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final meridiem = timestamp.hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour == 0 ? 12 : hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$normalizedHour:$minute $meridiem';
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
}
