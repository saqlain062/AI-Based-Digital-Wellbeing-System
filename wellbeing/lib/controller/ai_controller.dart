import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:onnxruntime_v2/onnxruntime_v2.dart';

import '../services/category_service.dart';
import '../services/hive_service.dart';
import '../services/recommendation_engine.dart';
import '../services/usage_feature_service.dart';

class AIController extends GetxController {
  static const String waitingRecommendation = 'Waiting for data...';
  static const String smartTrackingSource = 'smart_tracking';
  static const String manualSource = 'manual_assessment';

  var riskScore = 0.0.obs;
  var isModelLoaded = false.obs;
  var isProcessing = false.obs;
  var recommendation = waitingRecommendation.obs;
  var recommendationContext = ''.obs;
  var cameFromManualEstimation = false.obs;
  var cameFromSmartTracking = false.obs;
  var analysisSource = ''.obs;
  var lastAnalyzedAt = Rxn<DateTime>();

  final usageService = UsageFeatureService(CategoryService());
  final recommendationEngine = RecommendationEngine();
  final features = List<double>.filled(12, 0.0).obs;

  static const List<String> _featureOrder = [
    'age',
    'gender',
    'daily_screen_time_hours',
    'social_media_hours',
    'gaming_hours',
    'work_study_hours',
    'sleep_hours',
    'notifications_per_day',
    'app_opens_per_day',
    'weekend_screen_time',
    'stress_level',
    'academic_work_impact',
  ];

  static const Map<String, String> _featureAliases = {
    'daily_screen_time': 'daily_screen_time_hours',
    'notifications': 'notifications_per_day',
    'app_opens': 'app_opens_per_day',
    'weekend_screen': 'weekend_screen_time',
    'academic_impact': 'academic_work_impact',
  };

  late final Map<String, int> featureIndex = {
    for (var i = 0; i < _featureOrder.length; i++) _featureOrder[i]: i,
  };

  OrtSession? _session;
  Future<void>? _startupFuture;

  @override
  void onReady() {
    super.onReady();
    ensureReady();
  }

  Future<void> ensureReady() {
    return _startupFuture ??= _prepareController();
  }

  Future<void> _prepareController() async {
    await _initModel();
    _loadSavedProfile();
    _loadSavedAnalysis();
  }

  Future<void> _initModel() async {
    try {
      OrtEnv.instance.init();
      await _validateFeatureMap();
      await recommendationEngine.ensureLoaded();

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

  Future<void> _validateFeatureMap() async {
    try {
      final raw = await rootBundle.loadString('assets/feature_map.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final loadedFeatures = (decoded['features'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();

      if (!_matchesFeatureOrder(loadedFeatures)) {
        if (kDebugMode) {
          log('Feature map mismatch detected. Asset order: $loadedFeatures');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('Could not validate feature map: $e');
      }
    }
  }

  bool _matchesFeatureOrder(List<String> loadedFeatures) {
    if (loadedFeatures.length != _featureOrder.length) {
      return false;
    }

    for (var i = 0; i < loadedFeatures.length; i++) {
      if (loadedFeatures[i] != _featureOrder[i]) {
        return false;
      }
    }
    return true;
  }

  String _resolveFeatureKey(String key) {
    return _featureAliases[key] ?? key;
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
      setFeature('stress_level', onboardingInputs['stress_level'] ?? 1.0);
      setFeature(
        'academic_work_impact',
        onboardingInputs['academic_impact'] ?? 0.0,
      );
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
      final rawRecommendationContext = lastAnalysis['recommendationContext'];
      if (rawRecommendationContext is String &&
          rawRecommendationContext.trim().isNotEmpty) {
        recommendationContext.value = rawRecommendationContext;
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
    final resolvedKey = _resolveFeatureKey(key);
    final index = featureIndex[resolvedKey];
    if (index == null) return;

    features[index] = _normalizeFeatureValue(resolvedKey, value);
  }

  double _normalizeFeatureValue(String key, double value) {
    if (key == 'stress_level') {
      if (value >= 7) return 2.0;
      if (value >= 3) return 1.0;
      return value.round().clamp(0, 2).toDouble();
    }
    if (key == 'academic_work_impact') {
      if (value > 1) return 1.0;
      return value.round().clamp(0, 1).toDouble();
    }
    return value;
  }

  double featureValue(String key) {
    final index = featureIndex[_resolveFeatureKey(key)];
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
    setFeature('daily_screen_time_hours', total);
    setFeature('social_media_hours', social);
    setFeature('gaming_hours', gaming);

    if (notifications != null) {
      setFeature('notifications_per_day', notifications);
    }
    if (appOpens != null) {
      setFeature('app_opens_per_day', appOpens);
    }
    if (weekendScreen != null) {
      setFeature('weekend_screen_time', weekendScreen);
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

  Future<void> refreshSmartTrackingUsageSnapshot() async {
    if (!hasSmartTrackingData) return;

    await loadUsage();
    _saveAnalysis();
  }

  Future<void> runInference({bool showLoading = true}) async {
    await ensureReady();

    if (!isModelLoaded.value) {
      if (kDebugMode) {
        log('Model not loaded');
      }
      return;
    }

    isProcessing.value = true;
    if (showLoading) {
      await EasyLoading.show(
        status: 'Building your wellbeing insight...',
        maskType: EasyLoadingMaskType.black,
      );
    }

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

      _generateRecommendation();
      _saveAnalysis();
    } catch (e) {
      if (kDebugMode) {
        log('Inference error: $e');
      }
      if (showLoading) {
        EasyLoading.showError(
          'We could not finish that just now. Please try again in a moment.',
        );
      }
    } finally {
      isProcessing.value = false;
      if (showLoading) {
        EasyLoading.dismiss();
      }
    }
  }

  void _generateRecommendation() {
    final result = recommendationEngine.build(
      riskScore: riskScore.value,
      features: {
        for (final feature in _featureOrder) feature: featureValue(feature),
      },
    );

    recommendationContext.value = result.label;
    recommendation.value = _personalizedRecommendation(result.message);
  }

  String _personalizedRecommendation(String baseMessage) {
    final goal = HiveService.instance.getWellbeingGoal();
    final dailyHours = featureValue('daily_screen_time_hours');
    final socialHours = featureValue('social_media_hours');
    final gamingHours = featureValue('gaming_hours');
    final pickups = featureValue('app_opens_per_day');
    final notifications = featureValue('notifications_per_day');
    final sleepHours = featureValue('sleep_hours');
    final target = HiveService.instance.getDailyScreenTimeTarget();
    final focusTarget = HiveService.instance.getFocusHoursTarget();

    final goalMessage = switch (goal) {
      'sleep_better' => sleepHours < 7 || dailyHours > target
          ? 'For your sleep goal, try making the last 30 minutes before bed a lower-stimulation window.'
          : 'Your sleep goal looks supported today. Keep your evening routine calm and predictable.',
      'focus_work_study' => pickups >= 35 || notifications >= 35
          ? 'For focus, start with one protected study/work block and reduce notification checks during that time. Your current focus target is ${focusTarget.toStringAsFixed(1)} hours.'
          : 'Your focus signals look steady. Keep using intentional check-in moments instead of quick pickups toward your ${focusTarget.toStringAsFixed(1)} hour focus target.',
      'reduce_distractions' => socialHours + gamingHours >= 2
          ? 'For fewer distractions, choose one social or entertainment app to pause during your next focus block.'
          : 'Your distraction pattern looks lighter today. Keep your most attention-heavy apps away from your first work block.',
      'understand_habits' =>
        'For understanding your habits, check which app category is most active and compare it with how useful that time felt.',
      _ => dailyHours > target
          ? 'For healthier balance, try one short phone-free reset before your next long session.'
          : 'Your balance goal looks steady today. Keep the small routines that are already working.',
    };

    if (baseMessage.trim().isEmpty) {
      return goalMessage;
    }
    return '$baseMessage\n\n$goalMessage';
  }

  void _saveAnalysis() {
    final timestamp = DateTime.now();
    lastAnalyzedAt.value = timestamp;

    final snapshot = {
      'timestamp': timestamp.toIso8601String(),
      'dateKey': timestamp.toIso8601String().substring(0, 10),
      'score': riskScore.value,
      'recommendation': recommendation.value,
      'recommendationContext': recommendationContext.value,
      'source': analysisSource.value,
      'screenTimeHours': featureValue('daily_screen_time_hours'),
      'socialHours': featureValue('social_media_hours'),
      'gamingHours': featureValue('gaming_hours'),
      'notifications': featureValue('notifications_per_day'),
      'appOpens': featureValue('app_opens_per_day'),
      'weekendScreenHours': featureValue('weekend_screen_time'),
    };

    HiveService.instance.saveUser('lastAnalysis', snapshot);
    HiveService.instance.saveAnalysisSnapshot(snapshot);
  }

  void resetLocalState() {
    riskScore.value = 0.0;
    recommendation.value = waitingRecommendation;
    recommendationContext.value = '';
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

  String get balanceCategory {
    if (riskScore.value >= 0.7) return 'High usage pattern';
    if (riskScore.value >= 0.3) return 'Moderate pattern';
    return 'Balanced';
  }

  String get balanceSignalLabel {
    if (riskScore.value >= 0.7) return 'High usage pattern';
    if (riskScore.value >= 0.3) return 'Moderate digital balance';
    return 'Healthy digital balance';
  }

  String get wellbeingGoal {
    return HiveService.instance.getWellbeingGoal();
  }

  String get wellbeingGoalLabel {
    return switch (wellbeingGoal) {
      'reduce_distractions' => 'Reduce distractions',
      'sleep_better' => 'Sleep better',
      'focus_work_study' => 'Focus during study/work',
      'understand_habits' => 'Understand app habits',
      _ => 'Build healthier phone balance',
    };
  }

  String get supportiveMessage {
    if (riskScore.value >= 0.7) {
      return 'Your phone use looks higher than usual today. One small change can still make the day feel more manageable.';
    }
    if (riskScore.value >= 0.3) {
      return 'Your phone habits look manageable today, with a little room to rebalance one or two pressure points.';
    }
    return 'Your habits suggest a healthy balance today. Staying consistent matters more than being perfect.';
  }

  double get confidenceScore {
    final usageSignals = [
      featureValue('daily_screen_time_hours'),
      featureValue('social_media_hours'),
      featureValue('gaming_hours'),
      featureValue('notifications_per_day'),
      featureValue('app_opens_per_day'),
      featureValue('weekend_screen_time'),
    ].where((value) => value > 0).length;

    final personalSignals = [
      featureValue('age'),
      featureValue('sleep_hours'),
      featureValue('work_study_hours'),
      featureValue('stress_level'),
      featureValue('academic_work_impact'),
    ].where((value) => value > 0).length;

    final signalCoverage = ((usageSignals + personalSignals) / 11).clamp(
      0.0,
      1.0,
    );

    return (0.72 + (signalCoverage * 0.18) + (hasSmartTrackingData ? 0.08 : 0))
        .clamp(0.0, 0.98);
  }

  int get sessionDurationMinutes {
    final dailyHours = featureValue('daily_screen_time_hours');
    final appOpens = featureValue('app_opens_per_day');
    if (dailyHours <= 0 || appOpens <= 0) {
      return 0;
    }
    return ((dailyHours * 60) / appOpens).round();
  }

  String get usageTrendLabel {
    final daily = featureValue('daily_screen_time_hours');
    final weekend = featureValue('weekend_screen_time');
    if (daily <= 0 || weekend <= 0) return 'Stable';
    if (weekend > daily * 1.15) return 'Up';
    if (weekend < daily * 0.85) return 'Down';
    return 'Stable';
  }

  String get mostUsedCategory {
    final social = featureValue('social_media_hours');
    final gaming = featureValue('gaming_hours');
    final total = featureValue('daily_screen_time_hours');
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
