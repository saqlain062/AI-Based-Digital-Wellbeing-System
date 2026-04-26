import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wellbeing/view/perimission/permission_screen.dart';
import 'package:wellbeing/view/permission_screen.dart';

import '../../../../../util/constants/image_strings.dart';
import '../../../../../util/constants/text_strings.dart';
import '../../../../../util/helper/helper_functions.dart';
import '../../category_screen.dart';
// import '../../contact/contact_screentry.dart';
// import '../language/languageScreen.dart';

class SGeneralSetting extends StatelessWidget {
  const SGeneralSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final isdark = SHelperFunctions.isDarkMode(context);
    return Column(
      children: [
        SettingTile(
          title: "Permission",
          leadingIcon: SImages.settingPrivacy,
          trailingIcon: SImages.arrow,
          onTap: () => Get.to(() => Permission()),
        ),
        // const Divider(),
        SettingTile(
          title: "App Categories",
          // leadingIcon: SImages.category,
          trailingIcon: SImages.arrow,
          onTap: () => Get.to(() => CategoryScreen()),
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          // onTap: () => SHelperFunctions.shareApp(),
          leading: SvgPicture.asset(
            SImages.feadback,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
          title: const Text("Give Feedback"),
          trailing: SvgPicture.asset(
            SImages.arrow,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          // onTap: () => Get.to(() => const ContactScreen()),
          leading: SvgPicture.asset(
            SImages.settingContact,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
          title: const Text(STexts.contactUs),
          trailing: SvgPicture.asset(
            SImages.arrow,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          // onTap: () {
          //   SHelperFunctions.launchURL(
          //       "https://www.freeprivacypolicy.com/live/41d955ca-58d9-4e9e-8578-3b07050d8623 ");
          // },
          leading: SvgPicture.asset(
            SImages.settingPrivacy,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
          title: const Text("Privacy Policy"),
          trailing: SvgPicture.asset(
            SImages.arrow,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          // onTap: () {
          //   SHelperFunctions.launchURL(
          //       "https://www.freeprivacypolicy.com/live/41d955ca-58d9-4e9e-8578-3b07050d8623 ");
          // },
          leading: SvgPicture.asset(
            SImages.termofpolicy,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
          title: const Text("Terms of Service"),
          trailing: SvgPicture.asset(
            SImages.arrow,
            colorFilter: ColorFilter.mode(
              isdark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        SettingTile(title: "Version", subtitle: "1.0.0"),
      ],
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.subtitle,
    this.onTap,
    this.trailingWidget,
    this.isDark = false,
  });

  final String title;
  final String? leadingIcon;
  final String? trailingIcon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? Colors.white : Colors.black;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,

        // 🔹 Leading Icon
        leading: leadingIcon != null
            ? SvgPicture.asset(
                leadingIcon!,
                height: 22,
                width: 22,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              )
            : null,

        // 🔹 Title + Subtitle
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),

        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color.fromRGBO(141, 143, 148, 1),
                ),
              )
            : null,

        // 🔹 Trailing (Priority: custom widget > icon)
        trailing:
            trailingWidget ??
            (trailingIcon != null
                ? SvgPicture.asset(
                    trailingIcon!,
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  )
                : null),
      ),
    );
  }
}
