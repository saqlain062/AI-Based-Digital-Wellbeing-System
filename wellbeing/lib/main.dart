import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:wellbeing/controller/ai_controller.dart';
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
  await SmartTrackingService.initialize();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialScreen});

  final Widget initialScreen;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellbeing App',
      theme: WellbeingTheme.lightTheme(),
      darkTheme: WellbeingTheme.darkTheme(),
      themeMode: ThemeMode.system,
      builder: EasyLoading.init(),
      home: initialScreen,
    );
  }
}
