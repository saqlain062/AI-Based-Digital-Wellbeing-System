import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ai_controller.dart';

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
      appBar: AppBar(title: const Text("Your Wellbeing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            const Spacer(),

            // 🚀 BUTTON
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isProcessing.value
                      ? null
                      : () async {
                          await controller.runInference();
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isProcessing.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Analyze My Usage",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
