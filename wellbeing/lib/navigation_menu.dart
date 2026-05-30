import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/constants/image_strings.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';
import 'package:wellbeing/view/coach/coach_screen.dart';
import 'package:wellbeing/view/home/home_screen.dart';
import 'package:wellbeing/view/setting/setting_upgrade_screen.dart';
import 'package:wellbeing/widget/dialogbox.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  static const int _tabCount = 3;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = _normalizedIndex(widget.initialIndex);
  }

  int _normalizedIndex(int index) {
    if (index < 0 || index >= _tabCount) {
      return 0;
    }
    return index;
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

  void _openCoach() => setState(() => currentIndex = 1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeIndex = _normalizedIndex(currentIndex);

    if (safeIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => currentIndex = safeIndex);
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBack(isDark);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: safeIndex,
          children: [
            HomeScreen(
              onOpenCoach: _openCoach,
            ),
            const CoachScreen(),
            const UpgradedSettingScreen(),
          ],
        ),
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
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.self_improvement_rounded, 'Coach', 1),
                _buildNavItem(Icons.settings_rounded, 'Settings', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = index == _normalizedIndex(currentIndex);
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
            Icon(icon, color: color, size: 21),
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
