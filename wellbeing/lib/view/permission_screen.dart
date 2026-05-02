import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

import '../controller/ai_controller.dart';
import '../controller/onboarding_controller.dart';
import '../services/hive_service.dart';
import '../services/permission_lifecycle_service.dart';
import '../services/permission_service.dart';
import '../services/smart_tracking_service.dart';
import '../navigation_menu.dart';
import 'manual_estimation_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late PermissionLifecycleService lifecycle;
  bool useSmartTracking = true;
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
            'Smart Tracking is still off',
            'You can continue with manual input or try enabling usage access again when you are ready.',
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How would you like to begin?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Choose the path that feels right for you. You can always change this later, and everything stays on your device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _ChoiceCard(
                selected: useSmartTracking,
                highlighted: true,
                badge: 'Recommended',
                icon: Icons.insights_rounded,
                title: 'Use Smart Tracking',
                subtitle:
                    'Get more complete insights with optional usage access. Your data stays private and on-device.',
                bullets: const [
                  'Automatic screen and app usage insights',
                  'A more confident result',
                  'Suggestions based on real device patterns',
                ],
                onTap: () => setState(() => useSmartTracking = true),
              ),
              const SizedBox(height: 14),
              _ChoiceCard(
                selected: !useSmartTracking,
                highlighted: false,
                badge: 'Private by default',
                icon: Icons.edit_note_rounded,
                title: 'Start with Manual Input',
                subtitle:
                    'Keep setup simple for now and enter your habits yourself. You can enable smart tracking later.',
                bullets: const [
                  'No extra permission needed',
                  'Faster setup',
                  'Usage-based sections stay hidden until you choose tracking',
                ],
                onTap: () => setState(() => useSmartTracking = false),
              ),
              const SizedBox(height: 24),
              Text(
                useSmartTracking
                    ? 'You can continue right away and still receive a personalized result.'
                    : 'You will be asked for optional usage access on the next step.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: WellbeingTheme.primaryGradient,
                  borderRadius: WellbeingTheme.buttonRadius,
                  boxShadow: WellbeingTheme.softShadow,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (!useSmartTracking) {
                      Get.to(() => const ManualEstimationScreen());
                      return;
                    }

                    await EasyLoading.show(
                      status: 'Preparing smarter insights...',
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
                  child: Text(
                    useSmartTracking
                        ? 'Continue with Smart Tracking'
                        : 'Continue with Manual Input',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() => useSmartTracking = !useSmartTracking);
                  },
                  child: Text(
                    useSmartTracking
                        ? 'Prefer to enter things manually instead?'
                        : 'Want more accurate insights instead?',
                  ),
                ),
              ),
            ],
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.highlighted,
    required this.badge,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.onTap,
  });

  final bool selected;
  final bool highlighted;
  final String badge;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? WellbeingTheme.indigo
        : Theme.of(context).dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: WellbeingTheme.cardRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: selected && highlighted
              ? WellbeingTheme.heroGradient
              : null,
          color: selected && !highlighted
              ? const Color(0xFFEDE9FE)
              : selected
              ? null
              : WellbeingDecor.surface(context),
          borderRadius: WellbeingTheme.cardRadius,
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          boxShadow: WellbeingTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected && highlighted
                        ? Colors.white.withAlpha(28)
                        : WellbeingDecor.tintedSurface(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: selected && highlighted
                        ? Colors.white
                        : WellbeingTheme.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: selected && highlighted ? Colors.white : null,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: selected && highlighted
                        ? Colors.white
                        : WellbeingTheme.indigo,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected && highlighted
                    ? Colors.white.withAlpha(24)
                    : WellbeingDecor.tintedSurface(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected && highlighted
                      ? Colors.white
                      : WellbeingDecor.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected && highlighted
                    ? Colors.white.withAlpha(220)
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            ...bullets.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: selected && highlighted
                          ? Colors.white
                          : WellbeingTheme.cyan,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        line,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected && highlighted
                              ? Colors.white.withAlpha(220)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
