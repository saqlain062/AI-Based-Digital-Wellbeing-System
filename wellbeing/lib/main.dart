import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:wellbeing/navigation_menu.dart';
import 'package:wellbeing/services/hive_service.dart';
import 'package:wellbeing/view/onboarding_screen.dart';
import 'package:wellbeing/view/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.instance.init();

  final bool hasSeenWelcome = HiveService.instance.getBool('hasSeenWelcome');
  final bool onboardingCompleted = HiveService.instance.getBool(
    'onboardingCompleted',
  );

  Widget initialScreen;
  if (onboardingCompleted) {
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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      builder: EasyLoading.init(),
      home: initialScreen,
    );
  }
}
