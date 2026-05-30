import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:wellbeing/controller/ai_controller.dart';
import 'package:wellbeing/core/notifications/local_notification_service.dart';
import 'package:wellbeing/core/notifications/notification_scheduler.dart';
import 'package:wellbeing/navigation_menu.dart';
import 'package:wellbeing/services/hive_service.dart';
import 'package:wellbeing/services/smart_tracking_service.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';
import 'package:wellbeing/view/fresh_start_screen.dart';
import 'package:wellbeing/view/onboarding_screen.dart';
import 'package:wellbeing/view/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.instance.init();
  await LocalNotificationService.instance.initialize();
  await SmartTrackingService.initialize();
  await NotificationScheduler().restoreFromSettings();
  Get.put(AIController(), permanent: true);

  final bool hasSeenWelcome = HiveService.instance.getBool('hasSeenWelcome');
  final bool onboardingCompleted = HiveService.instance.getBool(
    'onboardingCompleted',
  );
  final bool needsFreshStart = HiveService.instance.getBool('needsFreshStart');

  Widget initialScreen;
  if (needsFreshStart) {
    initialScreen = const FreshStartScreen();
  } else if (onboardingCompleted) {
    initialScreen = const NavigationMenu();
  } else if (hasSeenWelcome) {
    initialScreen = OnboardingScreen();
  } else {
    initialScreen = const WelcomeScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialScreen});

  final Widget initialScreen;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocalNotificationService.instance.handleInitialPayloadIfAny();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Wellbeing',
      theme: WellbeingTheme.lightTheme(),
      darkTheme: WellbeingTheme.darkTheme(),
      themeMode: ThemeMode.system,
      builder: EasyLoading.init(),
      home: widget.initialScreen,
    );
  }
}
