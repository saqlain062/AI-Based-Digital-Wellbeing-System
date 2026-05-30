import 'package:get/get.dart';

import '../../navigation_menu.dart';
import '../../view/insights/insights_screen.dart';

class NotificationPayloadHandler {
  NotificationPayloadHandler._();

  static const String home = 'open:home';
  static const String coach = 'open:coach';
  static const String settings = 'open:settings';
  static const String insights = 'open:insights';

  static void handle(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    switch (payload) {
      case coach:
        Get.offAll(() => const NavigationMenu(initialIndex: 1));
        break;
      case settings:
        Get.offAll(() => const NavigationMenu(initialIndex: 2));
        break;
      case insights:
        Get.offAll(() => const NavigationMenu(initialIndex: 0));
        Future.microtask(() => Get.to(() => const InsightsScreen()));
        break;
      case home:
      default:
        Get.offAll(() => const NavigationMenu(initialIndex: 0));
        break;
    }
  }
}
