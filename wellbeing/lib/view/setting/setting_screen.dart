import 'package:flutter/material.dart';

import '../../util/constants/sizes.dart';
import '../../util/constants/text_strings.dart';
import '../../util/helper/helper_functions.dart';
import '../../widget/appbar/appbar.dart';
import 'widget/settings_options.dart' show SGeneralSetting;

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isdark = SHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: SAppBar(
        backgroundColor: isdark ? Colors.black : Colors.white,
        title: Text(
          "Setting",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SSizes.defaultSpaces),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      STexts.settingTitle2,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isdark
                            ? Colors.white
                            : const Color.fromRGBO(141, 143, 148, 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SGeneralSetting(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
