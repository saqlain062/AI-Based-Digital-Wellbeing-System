import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../util/secure_storage.dart';

class CategoryService {
  Map<String, String> globalMap = {};
  Map<String, String> userMap = {};

  static const String _userKey = "user_categories";

  /// ==========================
  /// INIT
  /// ==========================
  Future<void> init() async {
    try {
      // 🔹 Load global JSON
      final data = await rootBundle.loadString('assets/app_categories.json');

      globalMap = Map<String, String>.from(json.decode(data));

      log("📦 Global categories loaded: ${globalMap.length}");

      // 🔹 Load user data
      final userData = await SecureStorageService.instance.readJson(_userKey);

      if (userData != null) {
        userMap = Map<String, String>.from(userData);
        log("👤 User categories loaded: ${userMap.length}");
      } else {
        log("⚠️ No user categories found");
      }
    } catch (e) {
      log("❌ CategoryService init error: $e");
    }
  }

  /// ==========================
  /// GET CATEGORY
  /// ==========================
  String getCategory(String packageName) {
    // 1️⃣ User override
    if (userMap.containsKey(packageName)) {
      return userMap[packageName]!;
    }

    // 2️⃣ Exact match
    if (globalMap.containsKey(packageName)) {
      return globalMap[packageName]!;
    }

    // 3️⃣ 🔥 Partial match (IMPORTANT)
    for (var key in globalMap.keys) {
      if (packageName.contains(key)) {
        log("🔍 Partial match: $packageName → $key");
        return globalMap[key]!;
      }
    }

    return 'Unknown';
  }

  /// ==========================
  /// SAVE USER CATEGORY
  /// ==========================
  Future<void> saveUserCategory(String package, String category) async {
    try {
      userMap[package] = category;

      await SecureStorageService.instance.writeJson(_userKey, userMap);

      log("✅ SAVED: $package → $category");
    } catch (e) {
      log("❌ Save error: $package → $e");
    }
  }

  /// ==========================
  /// REMOVE USER CATEGORY
  /// ==========================
  Future<void> removeUserCategory(String package) async {
    try {
      userMap.remove(package);

      await SecureStorageService.instance.writeJson(_userKey, userMap);

      log("🗑 REMOVED: $package");
    } catch (e) {
      log("❌ Remove error: $package → $e");
    }
  }

  /// ==========================
  /// GET ALL USER CATEGORIES
  /// ==========================
  Map<String, String> getAllUserCategories() {
    return userMap;
  }

  /// ==========================
  /// DEBUG PRINT
  /// ==========================
  void printAllCategories() {
    log("📊 ===== USER CATEGORIES =====");
    userMap.forEach((key, value) {
      log("$key → $value");
    });

    log("📊 ===== GLOBAL SAMPLE =====");
    globalMap.entries.take(10).forEach((e) {
      log("${e.key} → ${e.value}");
    });
  }
}
