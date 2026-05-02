import 'package:flutter/widgets.dart';

import 'permission_service.dart';

class PermissionLifecycleService with WidgetsBindingObserver {
  PermissionLifecycleService({
    required this.permissionService,
    required this.onGranted,
    this.onResolved,
  });

  final PermissionService permissionService;
  final Future<void> Function() onGranted;
  final Future<void> Function(bool granted)? onResolved;

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    final granted = await permissionService.hasUsagePermission();

    if (onResolved != null) {
      await onResolved!(granted);
    }

    if (granted) {
      await onGranted();
    }
  }
}
