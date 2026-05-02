import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/hive_service.dart';
import '../util/theme/wellbeing_theme.dart';
import 'onboarding_screen.dart';

class FreshStartScreen extends StatelessWidget {
  const FreshStartScreen({super.key});

  void _continueToSetup() {
    HiveService.instance.saveBool('needsFreshStart', false);
    Get.offAll(() => OnboardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = WellbeingDecor.textSecondary(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WellbeingDecor.background(context),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF111A31)
                  : const Color(0xFFEFF6FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Start Fresh',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  'Your previous insight history has been cleared. A short setup will help us rebuild your wellbeing picture with fresh information.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double cardHeight = constraints.maxHeight.clamp(
                        320.0,
                        420.0,
                      );

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 620,
                            minHeight: cardHeight,
                            maxHeight: cardHeight,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: WellbeingTheme.heroGradient,
                              borderRadius: WellbeingTheme.cardRadius,
                              boxShadow: WellbeingTheme.softShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(50),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Let\'s rebuild your wellbeing profile with a calm, clean setup.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontSize: 28,
                                            height: 1.2,
                                          ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'You will re-enter your personal details first, then choose smart tracking or manual input for a fresh result.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.white.withAlpha(220),
                                            height: 1.45,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: WellbeingTheme.primaryGradient,
                    borderRadius: WellbeingTheme.buttonRadius,
                    boxShadow: WellbeingTheme.softShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _continueToSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Start Setup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
