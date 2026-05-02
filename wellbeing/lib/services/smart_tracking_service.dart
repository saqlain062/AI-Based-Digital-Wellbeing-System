import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

import '../controller/ai_controller.dart';
import '../services/hive_service.dart';

class SmartTrackingService {
  static const String _dailyAnalysisTask = 'dailyWellbeingAnalysis';

  static Future<void> initialize() async {
    // Initialize WorkManager
    await Workmanager().initialize(callbackDispatcher);

    // Schedule daily analysis if smart tracking is enabled
    if (HiveService.instance.getBool(
      'smartTrackingEnabled',
      defaultValue: false,
    )) {
      await scheduleDailyAnalysis();
    }
  }

  static Future<void> scheduleDailyAnalysis() async {
    final hour =
        (HiveService.instance.getUser('smartTrackingHour') ?? 8) as int;
    final frequency =
        (HiveService.instance.getUser('smartTrackingFrequency') ?? 'daily')
            as String;

    if (frequency == 'daily') {
      await Workmanager().registerPeriodicTask(
        _dailyAnalysisTask,
        _dailyAnalysisTask,
        frequency: const Duration(hours: 24),
        initialDelay: _calculateInitialDelay(hour),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      if (kDebugMode) {
        log('📅 Scheduled daily analysis at $hour:00');
      }
    }
  }

  static Duration _calculateInitialDelay(int targetHour) {
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, targetHour);

    if (now.isBefore(targetTime)) {
      return targetTime.difference(now);
    } else {
      // Schedule for tomorrow
      return targetTime.add(const Duration(days: 1)).difference(now);
    }
  }

  static Future<void> cancelDailyAnalysis() async {
    await Workmanager().cancelByUniqueName(_dailyAnalysisTask);
    if (kDebugMode) {
      log('❌ Cancelled daily analysis');
    }
  }

  static Future<void> enableSmartTracking() async {
    HiveService.instance.saveBool('smartTrackingEnabled', true);
    await scheduleDailyAnalysis();
    if (kDebugMode) {
      log('✅ Smart tracking enabled');
    }
  }

  static Future<void> disableSmartTracking() async {
    HiveService.instance.saveBool('smartTrackingEnabled', false);
    await cancelDailyAnalysis();
    if (kDebugMode) {
      log('❌ Smart tracking disabled');
    }
  }

  static bool isSmartTrackingEnabled() {
    return HiveService.instance.getBool(
      'smartTrackingEnabled',
      defaultValue: false,
    );
  }

  static Future<void> updateSettings({
    required int hour,
    required String frequency,
    required bool notificationsEnabled,
  }) async {
    HiveService.instance.saveUser('smartTrackingHour', hour);
    HiveService.instance.saveUser('smartTrackingFrequency', frequency);
    HiveService.instance.saveBool(
      'smartTrackingNotificationsEnabled',
      notificationsEnabled,
    );

    if (isSmartTrackingEnabled()) {
      await cancelDailyAnalysis();
      await scheduleDailyAnalysis();
    }

    if (kDebugMode) {
      log(
        '⚙️ Updated smart tracking settings: hour=$hour, frequency=$frequency, notifications=$notificationsEnabled',
      );
    }
  }

  static Future<void> performAnalysis() async {
    try {
      if (kDebugMode) {
        log('🔄 Starting daily wellbeing analysis...');
      }

      final aiController = Get.find<AIController>();

      // Load fresh usage data
      await aiController.loadUsage();

      // Run inference with new data
      await aiController.runInference();

      if (kDebugMode) {
        log(
          '✅ Daily analysis completed: Score ${aiController.riskScore.value.toStringAsFixed(1)}%',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('❌ Daily analysis failed: $e');
      }
    }
  }

  static bool _getNotificationsEnabled() {
    return HiveService.instance.getBool(
      'smartTrackingNotificationsEnabled',
      defaultValue: true,
    );
  }

  static int _getTrackingHour() {
    return (HiveService.instance.getUser('smartTrackingHour') ?? 8) as int;
  }

  static String _getTrackingFrequency() {
    return (HiveService.instance.getUser('smartTrackingFrequency') ?? 'daily')
        as String;
  }
}

// WorkManager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == SmartTrackingService._dailyAnalysisTask) {
      await SmartTrackingService.performAnalysis();
      return true;
    }
    return false;
  });
}
