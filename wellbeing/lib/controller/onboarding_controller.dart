import 'package:get/get.dart';

import 'ai_controller.dart';

class OnboardingController extends GetxController {
  var currentStep = 0.obs;

  // ===== USER INPUTS =====
  var age = 20.0.obs;
  var gender = 1.obs; // 0 = Female, 1 = Male

  var sleepHours = 7.0.obs;
  var workHours = 4.0.obs;

  var stressLevel = 5.0.obs;
  var academicImpact = 5.0.obs;

  var showManualInputs = false.obs;

  var notifications = 50.0.obs;
  var appOpens = 30.0.obs;
  var weekendScreen = 5.0.obs;

  var manualScreenTime = 4.0.obs;
  var manualSocial = 2.0.obs;
  var manualGaming = 1.0.obs;

  final ai = Get.put(AIController);

  // ===== NAVIGATION =====
  void next() {
    if (currentStep.value < 3) currentStep.value++;
  }

  void back() {
    if (currentStep.value > 0) currentStep.value--;
  }

  double get progress => (currentStep.value + 1) / 4;
}
