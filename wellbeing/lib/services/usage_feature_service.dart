import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:wellbeing/services/notification_service.dart';

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

      // 6️⃣ Calculate weekend usage (simplified - last 2 days)
      int weekendTime = 0;
      final weekendStart = end.subtract(const Duration(days: 2));
      final weekendStats = await UsageStats.queryUsageStats(weekendStart, end);

      for (var stat in weekendStats) {
        final package = stat.packageName;
        final rawTime = stat.totalTimeInForeground;

        if (package == null || rawTime == null) continue;

        int usageTime = 0;
        if (rawTime is int) {
          usageTime = rawTime as int;
        } else if (rawTime is String) {
          usageTime = int.tryParse(rawTime) ?? 0;
        }

        if (usageTime <= 0) continue;
        if (package.startsWith('com.android') ||
            package.startsWith('com.google.android') ||
            package.contains('mediatek')) {
          continue;
        }

        weekendTime += usageTime;
      }

      // 7️⃣ Get notifications and app opens from native code
      final notifications = await NotificationService.getDailyNotificationCount();
      final appOpens = await NotificationService.getDailyAppOpens();

      // 8️⃣ Result
      final result = {
        "daily_screen_time_hours": _toHours(totalTime),
        "social_media_hours": _toHours(socialTime),
        "gaming_hours": _toHours(gamingTime),
        "weekend_screen_hours": _toHours(weekendTime),
        "notifications_per_day": notifications.toDouble(),
        "app_opens_per_day": appOpens.toDouble(),
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

  Future<List<Map<String, dynamic>>> getTopApps({int limit = 5}) async {
    try {
      final apps = await FlutterDeviceApps.listApps(
        includeSystem: false,
        onlyLaunchable: true,
      );

      bool granted = await UsageStats.checkUsagePermission() ?? false;
      if (!granted) {
        await UsageStats.grantUsagePermission();
        return [];
      }

      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 1));
      final stats = await UsageStats.queryUsageStats(start, end);

      final Map<String, int> usageMap = {};
      for (var stat in stats) {
        final package = stat.packageName;
        final rawTime = stat.totalTimeInForeground;
        if (package == null || rawTime == null) continue;

        int usageTime = 0;
        if (rawTime is int) {
          usageTime = rawTime as int;
        } else if (rawTime is String) {
          usageTime = int.tryParse(rawTime) ?? 0;
        }

        if (usageTime <= 0) continue;
        if (package.startsWith('com.android') ||
            package.startsWith('com.google.android') ||
            package.contains('mediatek')) {
          continue;
        }

        usageMap[package] = usageTime;
      }

      final List<Map<String, dynamic>> appList = [];

      for (var app in apps) {
        final package = app.packageName;
        if (package == null || !usageMap.containsKey(package)) continue;

        final hours = _toHours(usageMap[package]!);
        final category = categoryService.getCategory(package);

        appList.add({
          'appName': app.appName,
          'packageName': package,
          'usageHours': hours,
          'category': category,
        });
      }

      appList.sort(
        (a, b) =>
            (b['usageHours'] as double).compareTo(a['usageHours'] as double),
      );
      return appList.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        log('❌ getTopApps error: $e');
      }
      return [];
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
