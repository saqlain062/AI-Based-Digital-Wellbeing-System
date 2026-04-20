import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/view/onboarding_screen.dart';
import 'package:wellbeing/view/wellbeing_view.dart';

import 'view/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellbeing App',
      home: OnboardingScreen(), // stays splash first
    );
  }
}
