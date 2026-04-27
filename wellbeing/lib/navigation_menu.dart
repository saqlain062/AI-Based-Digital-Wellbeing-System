import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wellbeing/util/constants/image_strings.dart';
import 'package:wellbeing/view/category_screen.dart';
import 'package:wellbeing/view/contact_screen.dart';
import 'package:wellbeing/view/dashboard/ai_analysis_screen.dart';
import 'package:wellbeing/view/setting/setting_upgrade_screen.dart';
import 'package:wellbeing/view/wellbeing_view.dart';
import 'package:wellbeing/widget/dialogbox.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _LawyerNavigationMenuState();
}

class _LawyerNavigationMenuState extends State<NavigationMenu> {
  int currentIndex = 0;
  final List<Widget> screens = [
    ResultScreen(),
    AIAnalysisScreen(),
    const ContactScreen(),
    const UpgradedSettingScreen(),
  ];

  onPopInvoked(bool isdark) {
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      return false;
    }
    showDialog(
      context: context,
      builder: (context) => SCustomDialog(
        textHeading: 'Exit App',
        textBody: "Are you sure you want to close this application?",
        textButton1: 'No',
        textButton2: "Yes",
        pressed: () => Get.back(),
        image: isdark ? SImages.exitDark : SImages.exit,
        pressed2: () => {
          Future.delayed(const Duration(milliseconds: 100), () {
            SystemNavigator.pop();
          }),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        onPopInvoked(isdark);
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                blurRadius: 12,
                offset: Offset(
                  0,
                  -2,
                ), // This sets the shadow above the container
              ),
            ],
          ),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  offset: Offset(0, -2.0),
                  blurRadius: 12,
                ),
              ],
              color: isdark
                  ? const Color.fromRGBO(27, 27, 26, 1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                sbuildNavItem(SImages.home, 'Home', 0),
                sbuildNavItem(SImages.history, 'Saved', 1),
                sbuildNavItem(SImages.contact, 'Contact', 2),
                sbuildNavItem(SImages.setting, 'Setting', 3),
              ],
            ),
          ),
        ),
      ),
    );
    //  BottomNavigationBar(
    //   type: BottomNavigationBarType.fixed,
    //   backgroundColor: SColors.lightNav,
    //   iconSize: 28,
    //   selectedItemColor: const Color.fromRGBO(16, 16, 16, 1),
    //   unselectedItemColor: const Color.fromRGBO(141, 143, 148, 1),
    //   showUnselectedLabels: false,
    //   showSelectedLabels: true,
    //   currentIndex: currentIndex,
    //   onTap: (value) {
    //     setState(() {
    //       currentIndex = value;
    //     });
    //   },
    //   items: const [
    //     BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
    //     BottomNavigationBarItem(icon: Icon(Iconsax.timer), label: "History"),
    //     BottomNavigationBarItem(icon: Icon(Iconsax.direct_inbox), label: 'Contant'),
    //     BottomNavigationBarItem(
    //         icon: Icon(Iconsax.setting), label: "Setting")
    //   ],
    // ));
  }

  Widget sbuildNavItem(String asset, String label, int index) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = index == currentIndex;
    final color = isdark
        ? (isSelected ? Colors.white : const Color.fromRGBO(141, 143, 148, 1))
        : (isSelected
              ? const Color.fromRGBO(16, 16, 16, 1)
              : const Color.fromRGBO(141, 143, 148, 1));

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Row(
        children: [
          SvgPicture.asset(
            asset,
            colorFilter: ColorFilter.mode(
              isdark
                  ? (currentIndex == index
                        ? Colors.white
                        : const Color.fromRGBO(141, 143, 148, 1))
                  : (currentIndex == index
                        ? const Color.fromRGBO(16, 16, 16, 1)
                        : const Color.fromRGBO(141, 143, 148, 1)),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          if (isSelected)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
