import 'dart:developer';

import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime_v2/onnxruntime_v2.dart';

class AIController extends GetxController {
  // Reactive variables (.obs)
  var riskScore = 0.0.obs;
  var isModelLoaded = false.obs;
  var isProcessing = false.obs;
  // 1. Storage for the 12 User Inputs (Initialized to 0.0)
  var liveInputs = List<double>.filled(12, 0.0).obs;
  var recommendation = "Waiting for data...".obs;
  OrtSession? _session;

  // 2. Updated inference to use the liveInputs
  Future<void> runRealInference() async {
    await runInference(liveInputs.toList());
    _generateNudge();
  }

  void _generateNudge() {
    double score = riskScore.value;
    double socialMedia = liveInputs[2]; // Index 2 from your feature map
    double sleep = liveInputs[1]; // Index 1

    if (score > 0.7) {
      if (socialMedia > 4)
        recommendation.value =
            "🚨 High Risk: Social media is your main trigger.";
      else if (sleep < 6)
        recommendation.value =
            "🚨 High Risk: Lack of sleep is driving dependency.";
      else
        recommendation.value = "🚨 High Risk: General habit correction needed.";
    } else {
      recommendation.value = "✅ Low/Moderate Risk: Your habits are stable.";
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initModel();
  }

  // Inside AIController

  // Load model once when controller starts
  Future<void> _initModel() async {
    try {
      OrtEnv.instance.init();
      final sessionOptions = OrtSessionOptions();
      sessionOptions.appendDefaultProviders(); // Uses GPU/NPU if possible

      final rawAssetFile = await rootBundle.load('assets/wellbeing_model.onnx');
      final bytes = rawAssetFile.buffer.asUint8List();
      _session = OrtSession.fromBuffer(bytes, sessionOptions);

      isModelLoaded.value = true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load AI Brain: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // The 12-feature prediction method
  Future<void> runInference(List<double> userData) async {
    if (!isModelLoaded.value) return;

    isProcessing.value = true;
    try {
      final inputData = Float32List.fromList(userData);
      log("Input Data: $inputData");
      final shape = [1, 12];

      final inputOrt = OrtValueTensor.createTensorWithDataList(
        inputData,
        shape,
      );
      final inputs = {'float_input': inputOrt};
      final runOptions = OrtRunOptions();

      final outputs = await _session?.runAsync(runOptions, inputs);

      if (outputs != null && outputs.length >= 2) {
        final probOutput = outputs[1]; // Index 1 is the probability tensor

        if (probOutput is OrtValueTensor) {
          // With ZipMap disabled, output is a nested list: [ [prob_class_0, prob_class_1] ]
          final List<dynamic> outerList = probOutput.value as List<dynamic>;
          final List<dynamic> firstRow = outerList[0] as List<dynamic>;

          // index 1 is usually the 'Addicted' probability (Class 1)
          riskScore.value = (firstRow[1] as num).toDouble();
          log("Final Prediction: ${riskScore.value}");
        }
      }

      // Cleanup
      inputOrt.release();
      runOptions.release();
      outputs?.forEach((e) => e?.release());
    } finally {
      isProcessing.value = false;
    }
  }

  void generateNudge(List<double> userData, double score) {
    if (score < 0.3) {
      recommendation.value =
          "Habits look healthy! Your risk of addiction is very low.";
    } else if (score >= 0.3 && score < 0.7) {
      recommendation.value =
          "Moderate risk detected. Consider setting a 30-minute timer for your next social media session.";
    } else {
      // HIGH RISK LOGIC (SHAP-Informed)
      // Based on your feature_map.json indices:
      double socialMediaHrs = userData[2];
      double sleepHrs = userData[1];

      if (socialMediaHrs > 3.5) {
        recommendation.value =
            "⚠️ High Risk! Our AI identifies your $socialMediaHrs hrs of social media as the main driver. Try 'Focus Mode'.";
      } else if (sleepHrs < 6.0) {
        recommendation.value =
            "⚠️ High Risk! Your lack of sleep is making your phone use more impulsive. Try an early night.";
      } else {
        recommendation.value =
            "⚠️ High Risk! We recommend reducing overall screen time by 20% today.";
      }
    }
  }

  @override
  void onClose() {
    _session?.release();
    OrtEnv.instance.release();
    super.onClose();
  }
}
