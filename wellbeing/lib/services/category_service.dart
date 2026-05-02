import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';

import 'hive_service.dart';

class CategoryService {
  Map<String, String> globalMap = {};

  /// ==========================
  /// INIT
  /// ==========================
  Future<void> init() async {
    try {
      final data = await rootBundle.loadString('assets/app_categories.json');
      globalMap = Map<String, String>.from(json.decode(data));

      // Migrate old "Unknown" values to "Other"
      await _migrateUnknownToOther();

      if (kDebugMode) {
        log("📦 Global categories loaded: ${globalMap.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Category init error: $e");
      }
    }
  }

  /// ==========================
  /// MIGRATE OLD DATA
  /// ==========================
  Future<void> _migrateUnknownToOther() async {
    try {
      final allCategories = HiveService.instance.getAllCategories();
      int migratedCount = 0;

      for (var entry in allCategories.entries) {
        if (entry.value == 'Unknown') {
          HiveService.instance.saveCategory(entry.key.toString(), 'Other');
          migratedCount++;
        }
      }

      if (migratedCount > 0 && kDebugMode) {
        log("🔄 Migrated $migratedCount apps from 'Unknown' to 'Other'");
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Migration error: $e");
      }
    }
  }

  /// ==========================
  /// CLEAR CACHE (for debugging)
  /// ==========================
  Future<void> clearCategoryCache() async {
    try {
      final hive = HiveService.instance;
      final allKeys = hive.getAllCategories().keys.toList();
      for (var key in allKeys) {
        hive.categoryBox.delete(key);
      }
      if (kDebugMode) {
        log("🗑 Cleared ${allKeys.length} cached categories");
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Clear cache error: $e");
      }
    }
  }

  /// ==========================
  /// GET CATEGORY
  /// ==========================
  String getCategory(String packageName) {
    final hive = HiveService.instance;

    // 1️⃣ User override (Hive)
    final userCategory = hive.getCategory(packageName);
    if (userCategory != null) {
      return userCategory;
    }

    // 2️⃣ Exact match
    if (globalMap.containsKey(packageName)) {
      return globalMap[packageName]!;
    }

    // 3️⃣ Partial match (fallback)
    for (var key in globalMap.keys) {
      if (packageName.contains(key)) {
        if (kDebugMode) {
          log("🔍 Partial match: $packageName → $key");
        }

        return globalMap[key]!;
      }
    }

    return "Other";
  }

  /// ==========================
  /// SAVE USER CATEGORY (Hive)
  /// ==========================
  Future<void> saveUserCategory(String package, String category) async {
    try {
      HiveService.instance.saveCategory(package, category);

      if (kDebugMode) {
        log("✅ SAVED (Hive): $package → $category");
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Save error: $e");
      }
    }
  }

  /// ==========================
  /// REMOVE USER CATEGORY
  /// ==========================
  Future<void> removeUserCategory(String package) async {
    try {
      HiveService.instance.categoryBox.delete(package);

      if (kDebugMode) {
        log("🗑 REMOVED: $package");
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Remove error: $e");
      }
    }
  }

  /// ==========================
  /// GET ALL USER CATEGORIES
  /// ==========================
  Map<dynamic, dynamic> getAllUserCategories() {
    return HiveService.instance.getAllCategories();
  }

  Future<List<Map<String, dynamic>>> scanInstalledApps({
    bool includeIcons = false,
  }) async {
    await init();

    final installedApps = await FlutterDeviceApps.listApps(
      includeSystem: false,
      onlyLaunchable: true,
      includeIcons: includeIcons,
    );

    final hive = HiveService.instance;
    final currentCached = hive.getAllCategories();
    final currentInstalledPackages = <String>{};
    final savedApps = <Map<String, dynamic>>[];

    // Process installed apps
    for (var app in installedApps) {
      final packageName = app.packageName;
      if (packageName == null) continue;

      currentInstalledPackages.add(packageName);

      // Check if already cached (user may have customized it)
      String category = currentCached[packageName]?.toString() ?? '';

      if (category.isEmpty) {
        // New app, categorize it for the first time
        category = getCategory(packageName);
        hive.saveCategory(packageName, category);
        if (kDebugMode) {
          log("📦 NEW APP: $packageName → $category");
        }
      } else {
        if (kDebugMode) {
          log("✅ EXISTING: $packageName → $category (preserved)");
        }
      }

      savedApps.add({
        'packageName': packageName,
        'appName': app.appName ?? 'Unknown App',
        'category': category,
        'iconBytes': app.iconBytes,
      });
    }

    // Remove apps that are no longer installed
    for (var cachedPackage in currentCached.keys) {
      if (!currentInstalledPackages.contains(cachedPackage)) {
        hive.categoryBox.delete(cachedPackage);
        if (kDebugMode) {
          log("🗑 REMOVED (uninstalled): $cachedPackage");
        }
      }
    }

    return savedApps;
  }
}
