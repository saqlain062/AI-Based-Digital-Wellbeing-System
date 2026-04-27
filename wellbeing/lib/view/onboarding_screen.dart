import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';

import 'onboarding/basic_info_widget.dart';
import 'onboarding/lifestyle_widget.dart';
import 'onboarding/behavior_widget.dart';
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
                  const BasicInfoWidget(),
                  const LifestyleWidget(),
                  const BehaviorWidget(),
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
}
