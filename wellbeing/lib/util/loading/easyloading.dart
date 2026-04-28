import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wellbeing/util/constants/color.dart';

class Loading {
  static void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: 2)
      ..indicatorType = EasyLoadingIndicatorType.threeBounce
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.white
      ..indicatorColor = SColors.primary
      ..textColor = SColors.textSecondary
      ..maskColor = SColors.sucess
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  static void showError(String message) {
    EasyLoading.dismiss();
    EasyLoading.showError(message);
  }

  static void showSuccess(String message) {
    EasyLoading.dismiss();
    EasyLoading.showSuccess(message);
  }

  static void showInfo(String message) {
    EasyLoading.dismiss();
    EasyLoading.showInfo(message);
  }
}
