import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

    return "Unknown";
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
}
