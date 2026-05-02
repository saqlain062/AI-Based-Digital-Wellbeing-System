import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/hive_service.dart';

class OnboardingController extends GetxController {
  var currentStep = 0.obs;

  // ===== USER INPUTS =====
  var age = 20.0.obs;
  var gender = 1.obs; // 0 = Female, 1 = Male

  var bedTime = const TimeOfDay(hour: 22, minute: 30).obs;
  var wakeTime = const TimeOfDay(hour: 7, minute: 0).obs;
  var sleepHours = 7.0.obs;
  var useSleepWindow = true.obs;
  var showSleepIndicator = true.obs;
  var workHours = 4.0.obs;

  var selectedMood = 2.obs;
  final moodEmojis = ['😌', '🙂', '😐', '😟', '😰'];
  final moodLabels = [
    'Very calm',
    'Relaxed',
    'Neutral',
    'Stressed',
    'Very stressed',
  ];
  final moodValues = [1.0, 2.5, 5.0, 7.5, 10.0];

  var stressLevel = 5.0.obs;
  var academicImpact = 5.0.obs;

  var showManualInputs = false.obs;

  var notifications = 50.0.obs;
  var appOpens = 30.0.obs;
  var weekendScreen = 5.0.obs;

  var manualScreenTime = 4.0.obs;
  var manualSocial = 2.0.obs;
  var manualGaming = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedProfile();
    useSleepWindow.value = true;
    showSleepIndicator.value = true;
    sleepHours.value = calculatedSleepHours;
    stressLevel.value = moodValues[selectedMood.value];
  }

  void _loadSavedProfile() {
    try {
      final profile = HiveService.instance.getUserProfile();
      final inputs = HiveService.instance.getOnboardingInputs();

      age.value = profile['age'] ?? 20.0;
      gender.value = (profile['gender'] ?? 1.0).toInt();
      sleepHours.value = inputs['sleep_hours'] ?? 7.0;
      workHours.value = inputs['work_study_hours'] ?? 4.0;
      stressLevel.value = inputs['stress_level'] ?? 5.0;
      academicImpact.value = inputs['academic_impact'] ?? 5.0;
    } catch (e) {
      // Use defaults if loading fails
    }
  }

  void toggleSleepWindow(bool enabled) {
    useSleepWindow.value = enabled;
    if (enabled) {
      sleepHours.value = calculatedSleepHours;
    }
  }

  void toggleSleepIndicator(bool enabled) {
    showSleepIndicator.value = enabled;
  }

  double get calculatedSleepHours {
    final bed = DateTime(2024, 1, 1, bedTime.value.hour, bedTime.value.minute);
    final wake = DateTime(
      2024,
      1,
      2,
      wakeTime.value.hour,
      wakeTime.value.minute,
    );
    final diff = wake.difference(bed);
    return diff.inMinutes / 60.0;
  }

  void selectMood(int index) {
    if (index < 0 || index >= moodValues.length) return;
    selectedMood.value = index;
    stressLevel.value = moodValues[index];
  }

  // ===== NAVIGATION =====
  void next() {
    if (currentStep.value < 3) currentStep.value++;
  }

  void back() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void saveProfile() {
    HiveService.instance.saveUserProfile(
      age: age.value,
      gender: gender.value.toDouble(),
    );

    HiveService.instance.saveOnboardingInputs(
      sleepHours: sleepHours.value,
      workStudyHours: workHours.value,
      stressLevel: stressLevel.value,
      academicImpact: academicImpact.value,
    );
  }

  double get progress => (currentStep.value + 1) / 4;
}
