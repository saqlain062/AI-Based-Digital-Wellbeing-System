import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:usage_stats/usage_stats.dart';

class PermissionService {
  /// Check permission
  Future<bool> hasUsagePermission() async {
    return await UsageStats.checkUsagePermission() ?? false;
  }

  /// Open settings
  Future<void> requestUsagePermission() async {
    await UsageStats.grantUsagePermission();
  }

  /// Professional flow (IMPORTANT)
  Future<bool> ensureUsagePermission() async {
    bool granted = await hasUsagePermission();

    if (!granted) {
      if (kDebugMode) {
        log("🔐 Permission not granted → opening settings");
      }

      await requestUsagePermission();

      // Wait user to come back
      await Future.delayed(const Duration(seconds: 2));

      granted = await hasUsagePermission();
    }
    if (kDebugMode) {
      log("🔐 Final Permission: $granted");
    }

    return granted;
  }
}
