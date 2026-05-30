import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../navigation_menu.dart';
import '../services/hive_service.dart';
import '../services/permission_lifecycle_service.dart';
import '../services/permission_service.dart';
import '../services/smart_tracking_service.dart';
import '../util/theme/wellbeing_theme.dart';
import 'manual_estimation_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late PermissionLifecycleService lifecycle;
  bool _waitingForPermissionResult = false;

  @override
  void initState() {
    super.initState();

    final permission = Get.put(PermissionService());
    final ai = Get.find<AIController>();
    final onboarding = Get.put(OnboardingController());

    lifecycle = PermissionLifecycleService(
      permissionService: permission,
      onResolved: (granted) async {
        if (!_waitingForPermissionResult) {
          return;
        }

        _waitingForPermissionResult = false;
        EasyLoading.dismiss();

        if (!granted && mounted) {
          Get.snackbar(
            'Usage access is still off',
            'No problem. Manual Check-in still works, and you can enable Smart Tracking later from Settings.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF111827),
            colorText: Colors.white,
          );
        }
      },
      onGranted: () async {
        onboarding.saveProfile();
        ai.setCameFromSmartTracking();
        await SmartTrackingService.enableSmartTracking();
        await ai.loadUsage();
        await ai.runInference();
        HiveService.instance.saveBool('onboardingCompleted', true);
        _openMainFlow();
      },
    );

    lifecycle.start();
  }

  @override
  void dispose() {
    lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = Get.put(OnboardingController());
    final ai = Get.find<AIController>();
    final permission = Get.put(PermissionService());

    return Scaffold(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow usage access',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'To estimate your screen time and app category activity, AI Wellbeing needs Android usage access. This data is processed locally on your device.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: WellbeingDecor.surface(context),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    boxShadow: WellbeingTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BulletLine(
                        text:
                            'Used to estimate screen time, social media activity, gaming time, and app-checking patterns.',
                      ),
                      SizedBox(height: 12),
                      _BulletLine(
                        text:
                            'Cannot read messages, photos, passwords, or typed content.',
                      ),
                      SizedBox(height: 12),
                      _BulletLine(
                        text:
                            'Stored locally for your digital balance insights and coach suggestions.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: WellbeingTheme.primaryGradient,
                    borderRadius: WellbeingTheme.buttonRadius,
                    boxShadow: WellbeingTheme.softShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await EasyLoading.show(
                        status: 'Preparing Smart Tracking...',
                        maskType: EasyLoadingMaskType.black,
                      );

                      try {
                        _waitingForPermissionResult = false;
                        _setCommonFeatures(onboarding, ai);
                        onboarding.saveProfile();

                        final isGranted = await permission.hasUsagePermission();
                        if (isGranted) {
                          ai.setCameFromSmartTracking();
                          await SmartTrackingService.enableSmartTracking();
                          await ai.loadUsage();
                          await ai.runInference();
                          HiveService.instance.saveBool(
                            'onboardingCompleted',
                            true,
                          );
                          EasyLoading.dismiss();
                          _openMainFlow();
                        } else {
                          _waitingForPermissionResult = true;
                          await permission.requestUsagePermission();
                        }
                      } catch (_) {
                        _waitingForPermissionResult = false;
                        EasyLoading.showError(
                          'Something got in the way. Please try again in a moment.',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Open Settings'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Get.to(() => const ManualEstimationScreen()),
                  child: const Text('Use Manual Check-in Instead'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setCommonFeatures(OnboardingController c, AIController ai) {
    ai.setFeature('age', c.age.value);
    ai.setFeature('gender', c.gender.value.toDouble());
    ai.setFeature('sleep_hours', c.sleepHours.value);
    ai.setFeature('work_study_hours', c.workHours.value);
    ai.setFeature('stress_level', c.stressLevel.value);
    ai.setFeature('academic_impact', c.academicImpact.value);
  }

  void _openMainFlow() {
    Get.offAll(() => const NavigationMenu(initialIndex: 0));
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: WellbeingTheme.indigo.withAlpha(18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: WellbeingTheme.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}
