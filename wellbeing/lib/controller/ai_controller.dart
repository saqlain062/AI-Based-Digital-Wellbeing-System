import 'dart:async';
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
  // ==========================
  // 🔹 STATE
  // ==========================
  var riskScore = 0.0.obs;
  var isModelLoaded = false.obs;
  var isProcessing = false.obs;
  var recommendation = "Waiting for data...".obs;
  var cameFromManualEstimation = false.obs;
  var cameFromSmartTracking = false.obs;

  OrtSession? _session;
  final Completer<void> _modelReady = Completer<void>();

  // ==========================
  // 🔹 FEATURE STORAGE
  // ==========================

  /// Full 12 features (MODEL INPUT)
  var features = List<double>.filled(12, 0.0).obs;

  /// Feature Index Map (VERY IMPORTANT)
  final featureIndex = {
    "age": 0,
    "sleep_hours": 1,
    "social_media_hours": 2,
    "gaming_hours": 3,
    "daily_screen_time": 4,
    "work_study_hours": 5,
    "notifications": 6,
    "app_opens": 7,
    "weekend_screen": 8,
    "stress_level": 9,
    "academic_impact": 10,
    "gender": 11,
  };

  // ==========================
  // 🔹 INIT MODEL
  // ==========================
  @override
  void onReady() {
    super.onReady();
    _initModel();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    try {
      final profile = HiveService.instance.getUserProfile();
      final onboardingInputs = HiveService.instance.getOnboardingInputs();

      setFeature("age", profile['age'] ?? 20.0);
      setFeature("gender", profile['gender'] ?? 1.0);
      setFeature("sleep_hours", onboardingInputs['sleep_hours'] ?? 7.0);
      setFeature(
        "work_study_hours",
        onboardingInputs['work_study_hours'] ?? 4.0,
      );
      setFeature("stress_level", onboardingInputs['stress_level'] ?? 5.0);
      setFeature("academic_impact", onboardingInputs['academic_impact'] ?? 5.0);

      if (kDebugMode) {
        log("✅ Loaded saved profile into AI features");
      }
    } catch (e) {
      if (kDebugMode) {
        log("⚠️ Could not load saved profile: $e");
      }
    }
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
        log("✅ Model Loaded");
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Model load error: $e");
      }
    }
  }

  // ==========================
  // 🔹 SET FEATURES (KEY PART)
  // ==========================

  void setFeature(String key, double value) {
    if (!featureIndex.containsKey(key)) return;

    int index = featureIndex[key]!;
    features[index] = value;
    if (kDebugMode) {
      log("📥 Feature Set → $key ($index) = $value");
    }
  }

  // ==========================
  // 🔹 AUTO DATA (FROM DEVICE)
  // ==========================

  void setCameFromManualEstimation() {
    cameFromManualEstimation.value = true;
  }

  void setCameFromSmartTracking() {
    cameFromSmartTracking.value = true;
  }

  void setUsageData({
    required double total,
    required double social,
    required double gaming,
    double? notifications,
    double? appOpens,
    double? weekendScreen,
  }) {
    setFeature("daily_screen_time", total);
    setFeature("social_media_hours", social);
    setFeature("gaming_hours", gaming);

    if (notifications != null) {
      setFeature("notifications", notifications);
    }
    if (appOpens != null) {
      setFeature("app_opens", appOpens);
    }
    if (weekendScreen != null) {
      setFeature("weekend_screen", weekendScreen);
    }
  }

  final usageService = UsageFeatureService(CategoryService());

  Future<void> loadUsage() async {
    final data = await usageService.getUsageFeatures();

    setUsageData(
      total: data["daily_screen_time_hours"] ?? 0.0,
      social: data["social_media_hours"] ?? 0.0,
      gaming: data["gaming_hours"] ?? 0.0,
      notifications: data["notifications_per_day"],
      appOpens: data["app_opens_per_day"],
      weekendScreen: data["weekend_screen_hours"],
    );
  }

  // ==========================
  // 🔹 RUN INFERENCE
  // ==========================

  Future<void> runInference() async {
    if (!isModelLoaded.value) {
      if (kDebugMode) {
        log("⚠️ Model not loaded");
      }
      return;
    }

    await EasyLoading.show(
      status: 'Analyzing your data...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      // await loadUsage();
      final inputData = Float32List.fromList(features);
      if (kDebugMode) {
        log("📊 Input: $features");
      }

      final shape = [1, 12];

      final inputTensor = OrtValueTensor.createTensorWithDataList(
        inputData,
        shape,
      );

      final inputs = {'float_input': inputTensor};
      final runOptions = OrtRunOptions();

      final outputs = await _session?.runAsync(runOptions, inputs);

      if (outputs != null && outputs.length > 1) {
        final probTensor = outputs[1];

        if (probTensor is OrtValueTensor) {
          final List outer = probTensor.value as List;
          final List row = outer[0];

          riskScore.value = (row[1] as num).toDouble();
          if (kDebugMode) {
            log("🎯 Prediction: ${riskScore.value}");
          }
        }
      }

      // Cleanup
      inputTensor.release();
      runOptions.release();
      outputs?.forEach((e) => e?.release());

      _generateNudge();
    } catch (e) {
      if (kDebugMode) {
        log("❌ Inference error: $e");
      }
      EasyLoading.showError('Analysis failed. Please try again.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // ==========================
  // 🔹 SMART RECOMMENDATION
  // ==========================

  void _generateNudge() {
    double score = riskScore.value;

    double social = features[featureIndex["social_media_hours"]!];
    double sleep = features[featureIndex["sleep_hours"]!];

    if (score > 0.7) {
      if (social > 3.5) {
        recommendation.value = "🚨 High Risk: Social media overuse detected.";
      } else if (sleep < 6) {
        recommendation.value =
            "🚨 High Risk: Poor sleep is affecting behavior.";
      } else {
        recommendation.value = "🚨 High Risk: Reduce overall screen time.";
      }
    } else if (score > 0.3) {
      recommendation.value = "⚠️ Moderate Risk: Try reducing usage gradually.";
    } else {
      recommendation.value = "✅ Low Risk: Keep maintaining balance.";
    }
  }

  // ==========================
  // 🔹 CLEANUP
  // ==========================

  @override
  void onClose() {
    _session?.release();
    OrtEnv.instance.release();
    super.onClose();
  }
}
