import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? const Color(0xFF111A31)
          : const Color(0xFFF1F5F9),
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: WellbeingDecor.background(context),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                WellbeingDecor.background(context),
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF111A31)
                    : const Color(0xFFF1F5F9),
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 6),
            child: Obx(() {
              return Column(
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal setup',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        progressBar(controller.progress),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: IndexedStack(
                      index: controller.currentStep.value,
                      children: [
                        const BasicInfoWidget(),
                        const LifestyleWidget(),
                        const BehaviorWidget(),
                        const PermissionScreen(),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget progressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: const Color(0x1A64748B),
        valueColor: const AlwaysStoppedAnimation<Color>(WellbeingTheme.indigo),
      ),
    );
  }
}
