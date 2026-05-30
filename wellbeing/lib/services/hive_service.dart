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
          userBox.get('profile_stress_level', defaultValue: 1.0) as double,
      'academic_impact':
          userBox.get('profile_academic_impact', defaultValue: 0.0) as double,
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

  List<Map<String, dynamic>> getAnalysisHistory() {
    _ensureReady();
    final raw = userBox.get('analysis_history', defaultValue: const []);
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  void saveAnalysisSnapshot(Map<String, dynamic> snapshot) {
    _ensureReady();

    if (!getBool('localHistoryEnabled', defaultValue: true)) {
      return;
    }

    final timestamp = snapshot['timestamp']?.toString();
    final dateKey =
        snapshot['dateKey']?.toString() ??
        (timestamp != null && timestamp.length >= 10
            ? timestamp.substring(0, 10)
            : null);

    if (dateKey == null || dateKey.isEmpty) {
      return;
    }

    final history = getAnalysisHistory()
      ..removeWhere((entry) => entry['dateKey']?.toString() == dateKey)
      ..add({...snapshot, 'dateKey': dateKey});

    history.sort((a, b) {
      final left = a['timestamp']?.toString() ?? '';
      final right = b['timestamp']?.toString() ?? '';
      return left.compareTo(right);
    });

    final trimmed = history.length > 120
        ? history.sublist(history.length - 120)
        : history;

    userBox.put('analysis_history', trimmed);

    if (kDebugMode) {
      log('Saved analysis snapshot for $dateKey');
    }
  }

  void clearAnalysisHistory() {
    _ensureReady();
    userBox.delete('analysis_history');
    if (kDebugMode) {
      log('Cleared local analysis history');
    }
  }

  void clearLatestAnalysis() {
    _ensureReady();
    userBox.delete('lastAnalysis');
    if (kDebugMode) {
      log('Cleared latest analysis snapshot');
    }
  }

  void clearStoredFeatures() {
    _ensureReady();
    featureBox.clear();
    if (kDebugMode) {
      log('Cleared stored feature values');
    }
  }

  void clearCategoryOverrides() {
    _ensureReady();
    categoryBox.clear();
    if (kDebugMode) {
      log('Cleared custom app categories');
    }
  }

  void clearLocalInsights() {
    _ensureReady();
    clearLatestAnalysis();
    clearAnalysisHistory();
    clearStoredFeatures();
    userBox.delete('analysisSource');
    if (kDebugMode) {
      log('Cleared local insights data');
    }
  }

  void clearProfileData() {
    _ensureReady();
    userBox.delete('profile_age');
    userBox.delete('profile_gender');
    userBox.delete('profile_sleep_hours');
    userBox.delete('profile_work_study_hours');
    userBox.delete('profile_stress_level');
    userBox.delete('profile_academic_impact');
    if (kDebugMode) {
      log('Cleared stored profile data');
    }
  }

  String getWellbeingGoal() {
    _ensureReady();
    return userBox.get(
      'wellbeingGoal',
      defaultValue: 'build_balance',
    ) as String;
  }

  void saveWellbeingGoal(String value) {
    saveUser('wellbeingGoal', value);
  }

  double getDailyScreenTimeTarget() {
    _ensureReady();
    return (userBox.get('dailyScreenTimeTarget', defaultValue: 4.0) as num)
        .toDouble();
  }

  void saveDailyScreenTimeTarget(double value) {
    saveUser('dailyScreenTimeTarget', value);
  }

  double getFocusHoursTarget() {
    _ensureReady();
    return (userBox.get('focusHoursTarget', defaultValue: 3.0) as num)
        .toDouble();
  }

  void saveFocusHoursTarget(double value) {
    saveUser('focusHoursTarget', value);
  }

  bool getReduceNightUsageGoal() {
    return getBool('reduceNightUsageGoal', defaultValue: true);
  }

  void saveReduceNightUsageGoal(bool value) {
    saveBool('reduceNightUsageGoal', value);
  }

  bool getReminderEnabled() {
    return getBool('wellbeingReminderEnabled', defaultValue: false);
  }

  void saveReminderEnabled(bool value) {
    saveBool('wellbeingReminderEnabled', value);
  }

  bool getNotificationsEnabled() {
    return getBool('notificationsEnabled', defaultValue: true);
  }

  void saveNotificationsEnabled(bool value) {
    saveBool('notificationsEnabled', value);
  }

  TimeOfDayValue getReminderTime() {
    _ensureReady();
    return TimeOfDayValue(
      hour: (userBox.get('wellbeingReminderHour', defaultValue: 20) as num)
          .toInt(),
      minute: (userBox.get('wellbeingReminderMinute', defaultValue: 30) as num)
          .toInt(),
    );
  }

  void saveReminderTime({required int hour, required int minute}) {
    saveUser('wellbeingReminderHour', hour);
    saveUser('wellbeingReminderMinute', minute);
  }

  String getSelectedCoachChallenge() {
    _ensureReady();
    return userBox.get('selectedCoachChallenge', defaultValue: '') as String;
  }

  void saveSelectedCoachChallenge(String value) {
    saveUser('selectedCoachChallenge', value);
  }

  List<String> getCompletedCoachDates() {
    _ensureReady();
    final raw = userBox.get('completedCoachDates', defaultValue: const []);
    if (raw is! List) {
      return const [];
    }
    return raw.map((entry) => entry.toString()).toList()..sort();
  }

  void saveCompletedCoachDates(List<String> dates) {
    _ensureReady();
    final normalized = dates.toSet().toList()..sort();
    userBox.put('completedCoachDates', normalized);
    if (kDebugMode) {
      log('Saved coach completion dates: $normalized');
    }
  }

  bool hasCompletedCoachChallengeOn(String dateKey) {
    _ensureReady();
    return getCompletedCoachDates().contains(dateKey);
  }

  bool markCoachChallengeCompletedOn(String dateKey) {
    _ensureReady();
    final dates = getCompletedCoachDates();
    if (dates.contains(dateKey)) {
      return false;
    }
    dates.add(dateKey);
    saveCompletedCoachDates(dates);
    return true;
  }

  int getCoachCurrentStreak() {
    _ensureReady();
    final dates = getCompletedCoachDates();
    if (dates.isEmpty) {
      return 0;
    }

    final completed = dates
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (completed.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;

    if (!completed.contains(cursor)) {
      final yesterday = cursor.subtract(const Duration(days: 1));
      if (!completed.contains(yesterday)) {
        return 0;
      }
      cursor = yesterday;
    }

    while (completed.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int getCoachCompletedThisWeek() {
    _ensureReady();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekdayOffset = today.weekday - DateTime.monday;
    final weekStart = today.subtract(Duration(days: weekdayOffset));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return getCompletedCoachDates()
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd))
        .length;
  }
}

class TimeOfDayValue {
  const TimeOfDayValue({required this.hour, required this.minute});

  final int hour;
  final int minute;
}
