import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ai_controller.dart';
import '../services/usage_feature_service.dart';
import '../services/category_service.dart';
import '../util/time_formatter.dart';
import '../widget/appbar/appbar.dart';
import 'app_details_screen.dart';

class ResultScreen extends StatelessWidget {
  final AIController controller = Get.put(AIController());

  ResultScreen({super.key});

  Color getRiskColor(double score) {
    if (score > 0.7) return Colors.red;
    if (score > 0.3) return Colors.orange;
    return Colors.green;
  }

  String getRiskText(double score) {
    if (score > 0.7) return "High Risk";
    if (score > 0.3) return "Moderate Risk";
    return "Low Risk";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              // 🔥 RISK CARD
              Obx(() {
                final score = controller.riskScore.value;
                final color = getRiskColor(score);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text("Your Risk Score", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),

                      Text(
                        "${(score * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        getRiskText(score),
                        style: TextStyle(
                          fontSize: 18,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 30),

              // 💡 RECOMMENDATION
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    controller.recommendation.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 📊 INPUT DATA (only show if came from manual estimation or smart tracking)
              Obx(() {
                if (!controller.cameFromManualEstimation.value &&
                    !controller.cameFromSmartTracking.value) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.cameFromManualEstimation.value
                          ? Colors.blue.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            controller.cameFromManualEstimation.value
                                ? Icons.info_outline
                                : Icons.track_changes,
                            color: controller.cameFromManualEstimation.value
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.cameFromManualEstimation.value
                                ? 'Your Estimated Data'
                                : 'Your Tracked Usage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: controller.cameFromManualEstimation.value
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (controller.cameFromManualEstimation.value) ...[
                        // Show all manual inputs
                        _buildDataRow(
                          'Age',
                          '${controller.features[0].toInt()} years',
                        ),
                        _buildDataRow(
                          'Sleep Hours',
                          '${controller.features[1].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Social Media',
                          '${controller.features[2].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Gaming',
                          '${controller.features[3].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Daily Screen Time',
                          '${controller.features[4].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Work/Study Hours',
                          '${controller.features[5].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Notifications',
                          '${controller.features[6].toInt()} per day',
                        ),
                        _buildDataRow(
                          'App Opens',
                          '${controller.features[7].toInt()} per day',
                        ),
                        _buildDataRow(
                          'Weekend Screen Time',
                          '${controller.features[8].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Stress Level',
                          '${controller.features[9].toStringAsFixed(1)}/10',
                        ),
                        _buildDataRow(
                          'Academic Impact',
                          '${controller.features[10].toStringAsFixed(1)}/10',
                        ),
                        _buildDataRow(
                          'Gender',
                          controller.features[11] == 1.0 ? 'Male' : 'Female',
                        ),
                      ] else if (controller.cameFromSmartTracking.value) ...[
                        // Show manual inputs but with tracked values updated
                        _buildDataRow(
                          'Age',
                          '${controller.features[0].toInt()} years',
                        ),
                        _buildDataRow(
                          'Sleep Hours',
                          '${controller.features[1].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Social Media',
                          '${controller.features[2].toStringAsFixed(1)} hours',
                          subtitle: 'Tracked from device',
                        ),
                        _buildDataRow(
                          'Gaming',
                          '${controller.features[3].toStringAsFixed(1)} hours',
                          subtitle: 'Tracked from device',
                        ),
                        _buildDataRow(
                          'Daily Screen Time',
                          '${controller.features[4].toStringAsFixed(1)} hours',
                          subtitle: 'Tracked from device',
                        ),
                        _buildDataRow(
                          'Work/Study Hours',
                          '${controller.features[5].toStringAsFixed(1)} hours',
                        ),
                        _buildDataRow(
                          'Notifications',
                          '${controller.features[6].toInt()} per day',
                          subtitle: 'Estimated from usage',
                        ),
                        _buildDataRow(
                          'App Opens',
                          '${controller.features[7].toInt()} per day',
                          subtitle: 'Tracked from device',
                        ),
                        _buildDataRow(
                          'Weekend Screen Time',
                          '${controller.features[8].toStringAsFixed(1)} hours',
                          subtitle: 'Tracked from device',
                        ),
                        _buildDataRow(
                          'Stress Level',
                          '${controller.features[9].toStringAsFixed(1)}/10',
                        ),
                        _buildDataRow(
                          'Academic Impact',
                          '${controller.features[10].toStringAsFixed(1)}/10',
                        ),
                        _buildDataRow(
                          'Gender',
                          controller.features[11] == 1.0 ? 'Male' : 'Female',
                        ),
                      ],
                    ],
                  ),
                );
              }),
              SizedBox(height: 20),

              // � TOP APPS SECTION (only show for smart tracking)
              Obx(() {
                if (!controller.cameFromSmartTracking.value) {
                  return const SizedBox.shrink();
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: UsageFeatureService(
                    CategoryService(),
                  ).getTopApps(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final topApps = snapshot.data!;

                    return GestureDetector(
                      onTap: () => Get.to(() => const AppDetailsScreen()),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.apps, color: Colors.purple.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your Top Apps',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.purple.shade600,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...topApps.map(
                              (app) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        app['appName'] ??
                                            app['packageName'] ??
                                            'Unknown App',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.purple.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      TimeFormatter.formatHours(
                                        app['usageHours'] as double,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Tap to see all apps →',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

              SizedBox(height: 20),

              // 🚀 SMART BUTTON (context-aware based on user flow)
              Obx(() {
                String buttonText = "Analyze My Usage";
                Color buttonColor = Colors.blue;
                bool isEnabled = true;
                String? helpText;

                if (controller.cameFromSmartTracking.value) {
                  buttonText = "📱 Re-analyze Your Usage";
                  buttonColor = Colors.green;
                  helpText = "Update your analysis with latest device data";
                } else if (controller.cameFromManualEstimation.value) {
                  buttonText = "✨ Finalize Analysis";
                  buttonColor = Colors.orange;
                  helpText = "Calculate your digital wellbeing score";
                } else {
                  isEnabled = false;
                  helpText = "Please complete tracking or manual entry first";
                }

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isEnabled
                            ? () async {
                                await controller.runInference();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Obx(
                          () => Text(
                            controller.isProcessing.value
                                ? "Processing..."
                                : buttonText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: !isEnabled
                                  ? Colors.grey.shade600
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (helpText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        helpText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
