import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:wellbeing/navigation_menu.dart';
import 'package:wellbeing/services/hive_service.dart';
import 'package:wellbeing/services/permission_lifecycle_service.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../services/permission_service.dart';
import 'manual_estimation_screen.dart';
import 'manual_estimation_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  late PermissionLifecycleService lifecycle;

  @override
  void initState() {
    super.initState();

    final permission = Get.put(PermissionService());
    final ai = Get.put(AIController());
    final c = Get.put(OnboardingController());

    lifecycle = PermissionLifecycleService(
      permissionService: permission,
      onGranted: () async {
        c.saveProfile();
        await ai.loadUsage();
        await ai.runInference();
        HiveService.instance.saveBool('onboardingCompleted', true);

        Get.offAll(() => const NavigationMenu()); // move forward
      },
    );

    lifecycle.start();
  }

  @override
  void dispose() {
    lifecycle.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());
    final ai = Get.put(AIController());
    final permission = Get.put(PermissionService());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insights, size: 80),

            const SizedBox(height: 20),

            const Text(
              "Improve Your Insights",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enable tracking for accurate results or estimate manually.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // ===============================
            // ✅ PERMISSION FLOW
            // ===============================
            ElevatedButton(
              onPressed: () async {
                await EasyLoading.show(
                  status: 'Setting up smart tracking...',
                  maskType: EasyLoadingMaskType.black,
                );

                try {
                  _setCommonFeatures(c, ai);
                  c.saveProfile();

                  final isGranted = await permission.hasUsagePermission();

                  if (isGranted) {
                    // ✅ Already granted → skip settings
                    ai.setCameFromSmartTracking();
                    await ai.loadUsage();
                    await ai.runInference();
                    HiveService.instance.saveBool('onboardingCompleted', true);

                    EasyLoading.dismiss();
                    Get.offAll(() => const NavigationMenu());
                  } else {
                    // ❗ Not granted → send to settings
                    await permission.requestUsagePermission();
                    EasyLoading.dismiss();
                  }
                } catch (e) {
                  EasyLoading.showError('Setup failed. Please try again.');
                }
              },
              child: const Text("Enable Smart Tracking"),
            ),

            const SizedBox(height: 20),

            // ===============================
            // 🔹 MANUAL OPTION
            // ===============================
            TextButton(
              onPressed: () {
                Get.to(() => const ManualEstimationScreen());
              },
              child: const Text("Estimate Manually"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _setCommonFeatures(OnboardingController c, AIController ai) {
    ai.setFeature("age", c.age.value);
    ai.setFeature("gender", c.gender.value.toDouble());
    ai.setFeature("sleep_hours", c.sleepHours.value);
    ai.setFeature("work_study_hours", c.workHours.value);
    ai.setFeature("stress_level", c.stressLevel.value);
    ai.setFeature("academic_impact", c.academicImpact.value);
  }
}
