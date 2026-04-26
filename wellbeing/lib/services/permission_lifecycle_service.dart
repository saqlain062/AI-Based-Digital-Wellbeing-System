import 'package:flutter/widgets.dart';
import 'permission_service.dart';

class PermissionLifecycleService with WidgetsBindingObserver {
  final PermissionService permissionService;
  final Function onGranted;

  PermissionLifecycleService({
    required this.permissionService,
    required this.onGranted,
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      bool granted = await permissionService.hasUsagePermission();

      if (granted) {
        onGranted(); // ✅ move forward
      }
    }
  }
}
