import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/controller/permission_controller.dart';
import 'package:wellbeing/view/wellbeing_view.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../services/permission_service.dart';

class OnboardingScreen extends StatelessWidget {
  final controller = Get.put(OnboardingController());

  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Column(
          children: [
            const SizedBox(height: 50),
            progressBar(controller.progress),

            Expanded(
              child: IndexedStack(
                index: controller.currentStep.value,
                children: [
                  _basicInfo(),
                  _lifestyle(),
                  _behavior(),
                  _permission(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget progressBar(double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LinearProgressIndicator(value: value),
    );
  }

  Widget _basicInfo() {
    final c = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tell us about you", style: TextStyle(fontSize: 22)),

          const SizedBox(height: 30),

          const Text("Age"),
          Row(
            children: [
              Obx(
                () => Text(
                  c.age.value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Slider(
              value: c.age.value,
              min: 10,
              max: 60,
              divisions: 50,
              label: c.age.value.toStringAsFixed(0),
              onChanged: (v) => c.age.value = v,
            ),
          ),

          const SizedBox(height: 20),

          const Text("Gender"),
          Obx(
            () => Row(
              children: [
                ChoiceChip(
                  label: const Text("Male"),
                  selected: c.gender.value == 1,
                  onSelected: (_) => c.gender.value = 1,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Female"),
                  selected: c.gender.value == 0,
                  onSelected: (_) => c.gender.value = 0,
                ),
              ],
            ),
          ),

          const Spacer(),

          ElevatedButton(onPressed: c.next, child: const Text("Next")),
        ],
      ),
    );
  }

  Widget _lifestyle() {
    final c = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your daily routine", style: TextStyle(fontSize: 22)),

          const SizedBox(height: 30),

          const Text("Sleep Hours"),
          Row(
            children: [
              Text(
                c.sleepHours.value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          Obx(
            () => Slider(
              value: c.sleepHours.value,
              min: 3,
              max: 10,
              divisions: 14,
              label: c.sleepHours.value.toStringAsFixed(1),
              onChanged: (v) => c.sleepHours.value = v,
            ),
          ),

          const SizedBox(height: 20),

          const Text("Work / Study Hours"),
          Row(
            children: [
              Text(
                c.workHours.value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          Obx(
            () => Slider(
              value: c.workHours.value,
              min: 0,
              max: 12,
              divisions: 24,
              label: c.workHours.value.toStringAsFixed(1),
              onChanged: (v) => c.workHours.value = v,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              TextButton(onPressed: c.back, child: const Text("Back")),
              const Spacer(),
              ElevatedButton(onPressed: c.next, child: const Text("Next")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _behavior() {
    final c = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your mindset", style: TextStyle(fontSize: 22)),

          const SizedBox(height: 30),

          const Text("Stress Level (1-10)"),
          Row(
            children: [
              Text(
                c.stressLevel.value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          Obx(
            () => Slider(
              value: c.stressLevel.value,
              min: 1,
              max: 10,
              divisions: 9,
              label: c.stressLevel.value.toStringAsFixed(0),
              onChanged: (v) => c.stressLevel.value = v,
            ),
          ),

          const SizedBox(height: 20),

          const Text("Academic Impact (1-10)"),
          Row(
            children: [
              Text(
                c.academicImpact.value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          Obx(
            () => Slider(
              value: c.academicImpact.value,
              min: 1,
              max: 10,
              divisions: 9,
              label: c.academicImpact.value.toStringAsFixed(0),
              onChanged: (v) => c.academicImpact.value = v,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              TextButton(onPressed: c.back, child: const Text("Back")),
              const Spacer(),
              ElevatedButton(onPressed: c.next, child: const Text("Next")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permission() {
    final c = Get.find<OnboardingController>();
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
                  // 1️⃣ Set manual inputs first
                  _setCommonFeatures(c, ai);

                  // 2️⃣ Request permission
                  await permission.requestUsagePermission();

                  if (await permission.hasUsagePermission()) {
                    // 3️⃣ Load usage data FIRST
                    await ai.loadUsage();

                    // 4️⃣ Then run inference
                    await ai.runInference();

                    Get.to(() => ResultScreen());
                  } else {
                    Get.snackbar("Permission", "Permission not granted");
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

                    Get.to(() => ResultScreen());
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
