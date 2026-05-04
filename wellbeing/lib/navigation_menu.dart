import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/constants/image_strings.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';
import 'package:wellbeing/view/contact_screen.dart';
import 'package:wellbeing/view/dashboard/analytics_screen.dart';
import 'package:wellbeing/view/setting/setting_upgrade_screen.dart';
import 'package:wellbeing/view/wellbeing_view.dart';
import 'package:wellbeing/widget/dialogbox.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late int currentIndex;

  final List<Widget> screens = const [
    ResultScreen(),
    AnalyticsScreen(),
    ContactScreen(),
    UpgradedSettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _handleBack(bool isDark) {
    if (currentIndex != 0) {
      setState(() => currentIndex = 0);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SCustomDialog(
        textHeading: 'Exit App',
        textBody: 'Are you sure you want to close this application?',
        textButton1: 'No',
        textButton2: 'Yes',
        pressed: () => Get.back(),
        image: isDark ? SImages.exitDark : SImages.exit,
        pressed2: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            SystemNavigator.pop();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBack(isDark);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: isDark
                  ? WellbeingTheme.darkSurface.withAlpha(245)
                  : WellbeingTheme.lightSurface.withAlpha(245),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(18)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: WellbeingTheme.softShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(SImages.home, 'Result', 0),
                _buildNavItem(SImages.history, 'Dashboard', 1),
                _buildNavItem(SImages.contact, 'Support', 2),
                _buildNavItem(SImages.setting, 'Settings', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String asset, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = index == currentIndex;
    final color = isSelected
        ? Colors.white
        : (isDark
              ? WellbeingTheme.darkTextSecondary
              : WellbeingTheme.lightTextSecondary);

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isSelected ? WellbeingTheme.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withAlpha(8) : const Color(0xFFF8FAFC)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              asset,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
