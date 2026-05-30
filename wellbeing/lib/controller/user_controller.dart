import 'package:get/get.dart';

class UserInputController extends GetxController {
  // ==========================
  // 🔹 USER INPUTS
  // ==========================

  var age = 20.0.obs;
  var gender = 1.0.obs; // 0=female, 1=male, 2=other

  var sleepHours = 7.0.obs;
  var workStudyHours = 4.0.obs;

  var notifications = 50.0.obs;
  var appOpens = 30.0.obs;
  var weekendScreen = 5.0.obs;

  var stressLevel = 1.0.obs; // 0=low, 1=medium, 2=high
  var academicImpact = 0.0.obs; // 0=no, 1=yes

  // ==========================
  // 🔹 CONVERT TO MODEL INPUT
  // ==========================

  Map<String, double> toFeatureMap() {
    return {
      "age": age.value,
      "gender": gender.value,
      "sleep_hours": sleepHours.value,
      "work_study_hours": workStudyHours.value,
      "notifications": notifications.value,
      "app_opens": appOpens.value,
      "weekend_screen": weekendScreen.value,
      "stress_level": stressLevel.value,
      "academic_impact": academicImpact.value,
    };
  }
}
