import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:usage_stats/usage_stats.dart';

import 'category_service.dart';

class UsageFeatureService {
  final CategoryService categoryService;

  UsageFeatureService(this.categoryService);

  double _toHours(int millis) {
    return millis / (1000 * 60 * 60);
  }

  Future<Map<String, double>> getUsageFeatures() async {
    try {
      // 1️⃣ Installed apps
      final apps = await FlutterDeviceApps.listApps(
        includeSystem: false,
        onlyLaunchable: true,
      );

      if (kDebugMode) {
        log("📦 Apps: ${apps.length}");
      }

      // 2️⃣ Usage permission
      bool granted = await UsageStats.checkUsagePermission() ?? false;

      if (!granted) {
        await UsageStats.grantUsagePermission();
        return _emptyResult();
      }

      // 3️⃣ Time range (🔥 increased for better data)
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 3));

      if (kDebugMode) {
        log("📦 Start: $start");
        log("📦 End: $end");
      }

      final stats = await UsageStats.queryUsageStats(start, end);

      if (kDebugMode) {
        log("📦 Stats: ${stats.length}");
      }

      // 4️⃣ Build usage map
      final Map<String, int> usageMap = {};

      int debugCount = 0;

      for (var stat in stats) {
        final package = stat.packageName;
        final rawTime = stat.totalTimeInForeground;

        if (package == null || rawTime == null) continue;

        // 🔥 Parse safely
        int usageTime = 0;

        if (rawTime is int) {
          usageTime = rawTime as int;
        } else if (rawTime is String) {
          usageTime = int.tryParse(rawTime) ?? 0;
        }

        // 🔥 Ignore useless data
        if (usageTime <= 0) continue;

        // 🔥 Ignore system apps
        if (package.startsWith('com.android') ||
            package.startsWith('com.google.android') ||
            package.contains('mediatek')) {
          continue;
        }

        usageMap[package] = usageTime;

        // 🔍 Limited debug logs
        if (debugCount < 10) {
          if (kDebugMode) {
            log("🔥 $package → $usageTime");
          }

          debugCount++;
        }
      }

      // 5️⃣ Aggregate categories
      int totalTime = 0;
      int socialTime = 0;
      int gamingTime = 0;

      for (var app in apps) {
        final package = app.packageName;

        if (!usageMap.containsKey(package)) continue;

        final usageTime = usageMap[package]!;

        final category = categoryService.getCategory(package!);

        if (category == 'Ignore') continue;

        totalTime += usageTime;

        if (category == 'Social') {
          socialTime += usageTime;
        } else if (category == 'Game') {
          gamingTime += usageTime;
        }
      }

      // 6️⃣ Result
      final result = {
        "daily_screen_time_hours": _toHours(totalTime),
        "social_media_hours": _toHours(socialTime),
        "gaming_hours": _toHours(gamingTime),
      };
      if (kDebugMode) {
        log("✅ RESULT: $result");
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        log("❌ Error: $e");
      }

      return _emptyResult();
    }
  }

  Map<String, double> _emptyResult() {
    return {
      "daily_screen_time_hours": 0.0,
      "social_media_hours": 0.0,
      "gaming_hours": 0.0,
    };
  }
}
