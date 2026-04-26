import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/constants/color.dart';
import '../../../util/constants/sizes.dart';
import '../../../util/device/device_utility.dart';
import '../../../util/helper/helper_functions.dart';

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.centerTitle = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    required this.backgroundColor,
  });

  final Widget? title;
  final bool showBackArrow;
  final bool centerTitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final dark = SHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SSizes.medium),
      child: AppBar(
        surfaceTintColor: dark ? Colors.black : Colors.white,
        backgroundColor: backgroundColor,
        leadingWidth: 30,
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: dark ? SColors.white : SColors.dark,
                ),
              )
            : leadingIcon != null
            ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
            : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(SDeviceUtils.getAppBarHeight());
}
