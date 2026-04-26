import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveService {
  static final HiveService instance = HiveService._internal();

  HiveService._internal();

  // =========================
  // USER BOX
  // =========================
  final userBox = Hive.box('user');

  void saveUser(String key, dynamic value) {
    userBox.put(key, value);
    if (kDebugMode) {
      log("👤 Saved user: $key → $value");
    }
  }

  dynamic getUser(String key) {
    return userBox.get(key);
  }

  // =========================
  // CATEGORY BOX
  // =========================
  final categoryBox = Hive.box('categories');

  void saveCategory(String package, String category) {
    categoryBox.put(package, category);
    if (kDebugMode) {
      log("📦 Saved category: $package → $category");
    }
  }

  String? getCategory(String package) {
    return categoryBox.get(package);
  }

  Map getAllCategories() {
    return categoryBox.toMap();
  }

  // =========================
  // FEATURES BOX (AI INPUT)
  // =========================
  final featureBox = Hive.box('features');

  void saveFeature(String key, double value) {
    featureBox.put(key, value);
    if (kDebugMode) {
      log("📊 Feature saved: $key → $value");
    }
  }

  double getFeature(String key) {
    return featureBox.get(key, defaultValue: 0.0);
  }

  Map getAllFeatures() {
    return featureBox.toMap();
  }
}
