import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:onnxruntime_v2/onnxruntime_v2.dart';

import '../services/category_service.dart';
import '../services/hive_service.dart';
import '../services/usage_feature_service.dart';

class AIController extends GetxController {
  static const String waitingRecommendation = 'Waiting for data...';
  static const String smartTrackingSource = 'smart_tracking';
  static const String manualSource = 'manual_assessment';

  var riskScore = 0.0.obs;
  var isModelLoaded = false.obs;
  var isProcessing = false.obs;
  var recommendation = waitingRecommendation.obs;
  var cameFromManualEstimation = false.obs;
  var cameFromSmartTracking = false.obs;
  var analysisSource = ''.obs;
  var lastAnalyzedAt = Rxn<DateTime>();

  final usageService = UsageFeatureService(CategoryService());
  final features = List<double>.filled(12, 0.0).obs;

  final featureIndex = {
    'age': 0,
    'sleep_hours': 1,
    'social_media_hours': 2,
    'gaming_hours': 3,
    'daily_screen_time': 4,
    'work_study_hours': 5,
    'notifications': 6,
    'app_opens': 7,
    'weekend_screen': 8,
    'stress_level': 9,
    'academic_impact': 10,
    'gender': 11,
  };

  OrtSession? _session;

  @override
  void onReady() {
    super.onReady();
    _initModel();
    _loadSavedProfile();
    _loadSavedAnalysis();
  }

  Future<void> _initModel() async {
    try {
      OrtEnv.instance.init();

      final sessionOptions = OrtSessionOptions();
      sessionOptions.appendDefaultProviders();

      final rawAsset = await rootBundle.load('assets/wellbeing_model.onnx');
      final bytes = rawAsset.buffer.asUint8List();

      _session = OrtSession.fromBuffer(bytes, sessionOptions);
      isModelLoaded.value = true;

      if (kDebugMode) {
        log('Model loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Model load error: $e');
      }
    }
  }

  void _loadSavedProfile() {
    try {
      final profile = HiveService.instance.getUserProfile();
      final onboardingInputs = HiveService.instance.getOnboardingInputs();

      setFeature('age', profile['age'] ?? 20.0);
      setFeature('gender', profile['gender'] ?? 1.0);
      setFeature('sleep_hours', onboardingInputs['sleep_hours'] ?? 7.0);
      setFeature(
        'work_study_hours',
        onboardingInputs['work_study_hours'] ?? 4.0,
      );
      setFeature('stress_level', onboardingInputs['stress_level'] ?? 5.0);
      setFeature('academic_impact', onboardingInputs['academic_impact'] ?? 5.0);
    } catch (e) {
      if (kDebugMode) {
        log('Could not load saved profile: $e');
      }
    }
  }

  void _loadSavedAnalysis() {
    try {
      final lastAnalysis = HiveService.instance.getUser('lastAnalysis');
      final savedSource = HiveService.instance.getUser('analysisSource');

      if (savedSource is String && savedSource.isNotEmpty) {
        analysisSource.value = savedSource;
        cameFromSmartTracking.value = savedSource == smartTrackingSource;
        cameFromManualEstimation.value = savedSource == manualSource;
      }

      if (lastAnalysis is! Map) return;

      final rawScore = lastAnalysis['score'];
      if (rawScore is num) {
        riskScore.value = rawScore.toDouble();
      }

      final rawRecommendation = lastAnalysis['recommendation'];
      if (rawRecommendation is String && rawRecommendation.trim().isNotEmpty) {
        recommendation.value = rawRecommendation;
      }

      final rawTimestamp = lastAnalysis['timestamp'];
      if (rawTimestamp is String) {
        lastAnalyzedAt.value = DateTime.tryParse(rawTimestamp);
      }
    } catch (e) {
      if (kDebugMode) {
        log('Could not load saved analysis: $e');
      }
    }
  }

  void setFeature(String key, double value) {
    final index = featureIndex[key];
    if (index == null) return;

    features[index] = value;
  }

  double featureValue(String key) {
    final index = featureIndex[key];
    if (index == null || index >= features.length) {
      return 0.0;
    }
    return features[index];
  }

  void setCameFromManualEstimation() {
    analysisSource.value = manualSource;
    cameFromManualEstimation.value = true;
    cameFromSmartTracking.value = false;
    HiveService.instance.saveUser('analysisSource', manualSource);
  }

  void setCameFromSmartTracking() {
    analysisSource.value = smartTrackingSource;
    cameFromSmartTracking.value = true;
    cameFromManualEstimation.value = false;
    HiveService.instance.saveUser('analysisSource', smartTrackingSource);
  }

  void setUsageData({
    required double total,
    required double social,
    required double gaming,
    double? notifications,
    double? appOpens,
    double? weekendScreen,
  }) {
    setFeature('daily_screen_time', total);
    setFeature('social_media_hours', social);
    setFeature('gaming_hours', gaming);

    if (notifications != null) {
      setFeature('notifications', notifications);
    }
    if (appOpens != null) {
      setFeature('app_opens', appOpens);
    }
    if (weekendScreen != null) {
      setFeature('weekend_screen', weekendScreen);
    }
  }

  Future<void> loadUsage() async {
    final data = await usageService.getUsageFeatures();

    setUsageData(
      total: data['daily_screen_time_hours'] ?? 0.0,
      social: data['social_media_hours'] ?? 0.0,
      gaming: data['gaming_hours'] ?? 0.0,
      notifications: data['notifications_per_day'],
      appOpens: data['app_opens_per_day'],
      weekendScreen: data['weekend_screen_hours'],
    );
  }

  Future<void> runInference() async {
    if (!isModelLoaded.value) {
      if (kDebugMode) {
        log('Model not loaded');
      }
      return;
    }

    isProcessing.value = true;
    await EasyLoading.show(
      status: 'Building your wellbeing insight...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final inputData = Float32List.fromList(features);
      final inputTensor = OrtValueTensor.createTensorWithDataList(
        inputData,
        [1, 12],
      );

      final outputs = await _session?.runAsync(
        OrtRunOptions(),
        {'float_input': inputTensor},
      );

      if (outputs != null && outputs.length > 1) {
        final probTensor = outputs[1];

        if (probTensor is OrtValueTensor) {
          final List outer = probTensor.value as List;
          final List row = outer[0];
          riskScore.value = (row[1] as num).toDouble();
        }
      }

      inputTensor.release();
      outputs?.forEach((value) => value?.release());

      _generateNudge();
      _saveAnalysis();
    } catch (e) {
      if (kDebugMode) {
        log('Inference error: $e');
      }
      EasyLoading.showError(
        'We could not finish that just now. Please try again in a moment.',
      );
    } finally {
      isProcessing.value = false;
      EasyLoading.dismiss();
    }
  }

  void _generateNudge() {
    final score = riskScore.value;
    final social = featureValue('social_media_hours');
    final sleep = featureValue('sleep_hours');
    final totalUsage = featureValue('daily_screen_time');
    final stress = featureValue('stress_level');

    if (score > 0.7) {
      if (social >= 3.5) {
        recommendation.value =
            'Long social media sessions seem to be playing the biggest role right now. Even a small cutback there could help you feel more in control.';
      } else if (sleep < 6) {
        recommendation.value =
            'Your sleep pattern may be making digital habits harder to manage. A steadier wind-down routine could make a real difference.';
      } else if (totalUsage >= 6) {
        recommendation.value =
            'Your screen time is on the heavier side right now. Short offline breaks through the day could help ease that load.';
      } else {
        recommendation.value =
            'Your habits could use a little extra support right now. One small boundary you can keep this week is a good place to begin.';
      }
      return;
    }

    if (score > 0.3) {
      if (stress >= 7) {
        recommendation.value =
            'Your habits look manageable overall, though stress may be making them harder to regulate. Gentle boundaries during stressful moments could help most.';
      } else {
        recommendation.value =
            'Your habits are fairly steady, with a few signs of drift. Easing back on one repetitive behaviour could improve balance quite quickly.';
      }
      return;
    }

    recommendation.value =
        'Your current pattern looks balanced. Keeping your sleep and screen routines steady should help you stay comfortable and in control.';
  }

  void _saveAnalysis() {
    final timestamp = DateTime.now();
    lastAnalyzedAt.value = timestamp;

    final snapshot = {
      'timestamp': timestamp.toIso8601String(),
      'dateKey': timestamp.toIso8601String().substring(0, 10),
      'score': riskScore.value,
      'recommendation': recommendation.value,
      'source': analysisSource.value,
      'screenTimeHours': featureValue('daily_screen_time'),
      'socialHours': featureValue('social_media_hours'),
      'gamingHours': featureValue('gaming_hours'),
      'notifications': featureValue('notifications'),
      'appOpens': featureValue('app_opens'),
      'weekendScreenHours': featureValue('weekend_screen'),
    };

    HiveService.instance.saveUser('lastAnalysis', snapshot);
    HiveService.instance.saveAnalysisSnapshot(snapshot);
  }

  void resetLocalState() {
    riskScore.value = 0.0;
    recommendation.value = waitingRecommendation;
    analysisSource.value = '';
    cameFromManualEstimation.value = false;
    cameFromSmartTracking.value = false;
    lastAnalyzedAt.value = null;
    for (var i = 0; i < features.length; i++) {
      features[i] = 0.0;
    }
  }

  bool get hasSmartTrackingData => analysisSource.value == smartTrackingSource;

  bool get hasManualAssessmentData => analysisSource.value == manualSource;

  bool get hasRecommendation =>
      recommendation.value.trim().isNotEmpty &&
      recommendation.value != waitingRecommendation;

  String get riskCategory {
    if (riskScore.value >= 0.7) return 'High';
    if (riskScore.value >= 0.3) return 'Moderate';
    return 'Low';
  }

  String get supportiveMessage {
    if (riskScore.value >= 0.7) {
      return 'Your current habits show signs of overuse. Small changes can help you feel more in control.';
    }
    if (riskScore.value >= 0.3) {
      return 'There is some room to rebalance your habits, and a few thoughtful adjustments could go a long way.';
    }
    return 'Your habits suggest a healthy balance right now. Staying consistent matters more than being perfect.';
  }

  double get confidenceScore {
    final usageSignals = [
      featureValue('daily_screen_time'),
      featureValue('social_media_hours'),
      featureValue('gaming_hours'),
      featureValue('notifications'),
      featureValue('app_opens'),
      featureValue('weekend_screen'),
    ].where((value) => value > 0).length;

    final personalSignals = [
      featureValue('age'),
      featureValue('sleep_hours'),
      featureValue('work_study_hours'),
      featureValue('stress_level'),
      featureValue('academic_impact'),
    ].where((value) => value > 0).length;

    final signalCoverage = ((usageSignals + personalSignals) / 11).clamp(
      0.0,
      1.0,
    );

    return (0.72 + (signalCoverage * 0.18) + (hasSmartTrackingData ? 0.08 : 0))
        .clamp(0.0, 0.98);
  }

  int get sessionDurationMinutes {
    final dailyHours = featureValue('daily_screen_time');
    final appOpens = featureValue('app_opens');
    if (dailyHours <= 0 || appOpens <= 0) {
      return 0;
    }
    return ((dailyHours * 60) / appOpens).round();
  }

  String get usageTrendLabel {
    final daily = featureValue('daily_screen_time');
    final weekend = featureValue('weekend_screen');
    if (daily <= 0 || weekend <= 0) return 'Stable';
    if (weekend > daily * 1.15) return 'Up';
    if (weekend < daily * 0.85) return 'Down';
    return 'Stable';
  }

  String get mostUsedCategory {
    final social = featureValue('social_media_hours');
    final gaming = featureValue('gaming_hours');
    final total = featureValue('daily_screen_time');
    final other = (total - social - gaming).clamp(0.0, double.infinity);

    final ranked = [
      ('Social', social),
      ('Gaming', gaming),
      ('Other', other),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    return ranked.first.$2 <= 0 ? 'Unavailable' : ranked.first.$1;
  }

  @override
  void onClose() {
    _session?.release();
    OrtEnv.instance.release();
    super.onClose();
  }
}
