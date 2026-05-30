import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';
import '../util/theme/wellbeing_theme.dart';
import 'manual_estimation_screen.dart';
import 'permission_screen.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = Get.put(OnboardingController());
  final pageController = PageController();
  int currentPage = 0;

  final List<_OnboardingPage> pages = const [
    _OnboardingPage(
      icon: Icons.favorite_outline_rounded,
      title: 'Understand your phone habits',
      description:
          'AI Wellbeing helps you understand your screen-time pattern and gives simple daily actions to improve your digital balance.',
    ),
    _OnboardingPage(
      icon: Icons.lock_outline_rounded,
      title: 'Your data stays on your phone',
      description:
          'The app works locally. Your habit data is stored on your device and is not sent to a cloud server.',
    ),
    _OnboardingPage(
      icon: Icons.swap_horiz_rounded,
      title: 'Manual or Smart Tracking',
      description:
          'You can enter your habits manually or allow Android usage access so the app can estimate your daily phone pattern.',
    ),
    _OnboardingPage(
      icon: Icons.play_circle_outline_rounded,
      title: 'Choose how you want to begin',
      description:
          'Start with Smart Tracking for a fuller picture, or use Manual Check-in if you prefer a quicker setup.',
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'AI Wellbeing',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (currentPage + 1) / pages.length,
                      minHeight: 10,
                      backgroundColor: const Color(0x1A64748B),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        WellbeingTheme.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() => currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return _OnboardingCard(page: page);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (currentPage < pages.length - 1) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: WellbeingTheme.primaryGradient,
                        borderRadius: WellbeingTheme.buttonRadius,
                        boxShadow: WellbeingTheme.softShadow,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          pageController.animateToPage(
                            pages.length - 1,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: const Text('Skip to setup'),
                      ),
                    ),
                  ] else ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: WellbeingTheme.primaryGradient,
                        borderRadius: WellbeingTheme.buttonRadius,
                        boxShadow: WellbeingTheme.softShadow,
                      ),
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const PermissionScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Use Smart Tracking'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Get.to(() => const ManualEstimationScreen()),
                      child: const Text('Use Manual Check-in'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: WellbeingDecor.surface(context),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: WellbeingTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: WellbeingTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(page.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 28),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
