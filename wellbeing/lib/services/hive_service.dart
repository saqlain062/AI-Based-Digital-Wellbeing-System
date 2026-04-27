import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService instance = HiveService._internal();

  HiveService._internal();

  late final Box userBox;
  late final Box categoryBox;
  late final Box featureBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    userBox = await Hive.openBox('user');
    categoryBox = await Hive.openBox('categories');
    featureBox = await Hive.openBox('features');

    _initialized = true;

    if (kDebugMode) {
      log('Hive initialized. Opened boxes: user, categories, features');
    }
  }

  void _ensureReady() {
    if (!_initialized) {
      throw StateError(
        'HiveService must be initialized before use. Call HiveService.instance.init() in main().',
      );
    }
  }

  void saveUser(String key, dynamic value) {
    _ensureReady();
    userBox.put(key, value);
    if (kDebugMode) {
      log("👤 Saved user: $key → $value");
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    _ensureReady();
    return userBox.get(key, defaultValue: defaultValue) as bool;
  }

  void saveBool(String key, bool value) {
    saveUser(key, value);
  }

  dynamic getUser(String key) {
    _ensureReady();
    return userBox.get(key);
  }

  void saveUserProfile({required double age, required double gender}) {
    _ensureReady();
    userBox.put('profile_age', age);
    userBox.put('profile_gender', gender);
    if (kDebugMode) {
      log('👤 Saved profile: age=$age, gender=$gender');
    }
  }

  Map<String, double> getUserProfile() {
    _ensureReady();
    return {
      'age': userBox.get('profile_age', defaultValue: 20.0) as double,
      'gender': userBox.get('profile_gender', defaultValue: 1.0) as double,
    };
  }

  void saveOnboardingInputs({
    required double sleepHours,
    required double workStudyHours,
    required double stressLevel,
    required double academicImpact,
  }) {
    _ensureReady();
    userBox.put('profile_sleep_hours', sleepHours);
    userBox.put('profile_work_study_hours', workStudyHours);
    userBox.put('profile_stress_level', stressLevel);
    userBox.put('profile_academic_impact', academicImpact);
    if (kDebugMode) {
      log(
        '📝 Saved onboarding inputs: sleep=$sleepHours, work=$workStudyHours, stress=$stressLevel, academic=$academicImpact',
      );
    }
  }

  Map<String, double> getOnboardingInputs() {
    _ensureReady();
    return {
      'sleep_hours':
          userBox.get('profile_sleep_hours', defaultValue: 7.0) as double,
      'work_study_hours':
          userBox.get('profile_work_study_hours', defaultValue: 4.0) as double,
      'stress_level':
          userBox.get('profile_stress_level', defaultValue: 5.0) as double,
      'academic_impact':
          userBox.get('profile_academic_impact', defaultValue: 5.0) as double,
    };
  }

  void saveCategory(String package, String category) {
    _ensureReady();
    categoryBox.put(package, category);
    if (kDebugMode) {
      log("📦 Saved category: $package → $category");
    }
  }

  String? getCategory(String package) {
    _ensureReady();
    return categoryBox.get(package);
  }

  Map getAllCategories() {
    _ensureReady();
    return categoryBox.toMap();
  }

  void saveFeature(String key, double value) {
    _ensureReady();
    featureBox.put(key, value);
    if (kDebugMode) {
      log("📊 Feature saved: $key → $value");
    }
  }

  double getFeature(String key) {
    _ensureReady();
    return featureBox.get(key, defaultValue: 0.0);
  }

  Map getAllFeatures() {
    _ensureReady();
    return featureBox.toMap();
  }
}
