import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/navigation_menu.dart';
import 'package:wellbeing/services/hive_service.dart';
import 'package:wellbeing/services/permission_lifecycle_service.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../services/permission_service.dart';

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

    return Obx(
      () => SingleChildScrollView(
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
                  _setCommonFeatures(c, ai);
                  c.saveProfile();

                  final isGranted = await permission.hasUsagePermission();

                  if (isGranted) {
                    // ✅ Already granted → skip settings
                    await ai.loadUsage();
                    await ai.runInference();
                    HiveService.instance.saveBool('onboardingCompleted', true);

                    Get.offAll(() => const NavigationMenu());
                  } else {
                    // ❗ Not granted → send to settings
                    await permission.requestUsagePermission();
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
                  c.showManualInputs.value = true;
                },
                child: const Text("Estimate Manually"),
              ),

              const SizedBox(height: 20),

              if (c.showManualInputs.value) ...[
                // 🔸 ADD MISSING 3 FEATURES HERE
                const Text("Daily Screen Time (hours)"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.manualScreenTime.value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Slider(
                  value: c.manualScreenTime.value,
                  min: 0,
                  max: 12,
                  onChanged: (v) => c.manualScreenTime.value = v,
                ),

                const Text("Social Media Usage (hours)"),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.manualSocial.value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Slider(
                  value: c.manualSocial.value,
                  min: 0,
                  max: 10,
                  onChanged: (v) => c.manualSocial.value = v,
                ),

                const Text("Gaming Hours"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.manualGaming.value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Slider(
                  value: c.manualGaming.value,
                  min: 0,
                  max: 10,
                  onChanged: (v) => c.manualGaming.value = v,
                ),

                const SizedBox(height: 20),

                const Text("Notifications per day"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.notifications.value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Slider(
                  value: c.notifications.value,
                  min: 0,
                  max: 200,
                  onChanged: (v) => c.notifications.value = v,
                ),

                const Text("App opens per day"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.appOpens.value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Slider(
                  value: c.appOpens.value,
                  min: 0,
                  max: 200,
                  onChanged: (v) => c.appOpens.value = v,
                ),

                const Text("Weekend screen time (hours)"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.weekendScreen.value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Slider(
                  value: c.weekendScreen.value,
                  min: 0,
                  max: 12,
                  onChanged: (v) => c.weekendScreen.value = v,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    // 1️⃣ Set all base features
                    _setCommonFeatures(c, ai);
                    c.saveProfile();

                    // 2️⃣ Set manual usage features
                    ai.setFeature(
                      "daily_screen_time",
                      c.manualScreenTime.value,
                    );
                    ai.setFeature("social_media_hours", c.manualSocial.value);
                    ai.setFeature("gaming_hours", c.manualGaming.value);

                    ai.setFeature("notifications", c.notifications.value);
                    ai.setFeature("app_opens", c.appOpens.value);
                    ai.setFeature("weekend_screen", c.weekendScreen.value);

                    // 3️⃣ Run AI
                    await ai.runInference();
                    HiveService.instance.saveBool('onboardingCompleted', true);

                    Get.offAll(() => const NavigationMenu());
                  },
                  child: const Text("Continue"),
                ),
              ],
            ],
          ),
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
