import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wellbeing/services/hive_service.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';
import 'package:wellbeing/view/onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _markWelcomeSeen() {
    HiveService.instance.saveBool('hasSeenWelcome', true);
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = WellbeingDecor.textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111A31)
          : const Color(0xFFEFF6FF),
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
                    : const Color(0xFFEFF6FF),
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to Wellbeing',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'A short setup helps Wellbeing AI understand your habits and offer more helpful guidance, right on your device.',
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
                                      Icons.spa_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Understand your phone habits with calm, private support that helps you feel more in control.',
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
                                        'No account, no cloud sync, and no pressure. Just thoughtful insights, optional smart tracking, and small next steps that fit real life.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.white.withAlpha(
                                                220,
                                              ),
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
                      onPressed: () {
                        _markWelcomeSeen();
                        Get.to(() => OnboardingScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text('Begin Setup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
