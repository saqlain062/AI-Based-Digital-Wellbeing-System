import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/controller/permission_controller.dart';
import 'package:wellbeing/view/wellbeing_view.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../navigation_menu.dart';
import '../services/permission_service.dart';
import 'permission_screen.dart';

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
                  PermissionScreen(),
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
}
