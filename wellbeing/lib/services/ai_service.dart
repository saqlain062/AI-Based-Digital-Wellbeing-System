import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime_v2/onnxruntime_v2.dart';

class AIService {
  OrtSession? _session;

  // 1. Load the model from assets
  Future<void> initModel() async {
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();

    // 2026 Pro Tip: Automatically use GPU/NPU if available
    sessionOptions.appendDefaultProviders();

    final rawAssetFile = await rootBundle.load('assets/wellbeing_model.onnx');
    final bytes = rawAssetFile.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
    if (kDebugMode) {
      print("✅ AI Model Loaded Successfully");
    }
  }

  // 2. Run Prediction
  Future<double> predictRisk(List<double> userInputs) async {
    if (_session == null) await initModel();

    // Convert List<double> to Float32List (Matching your Python .astype(np.float32))
    final inputData = Float32List.fromList(userInputs);
    final shape = [1, 12]; // 1 batch, 12 features

    final inputOrt = OrtValueTensor.createTensorWithDataList(inputData, shape);
    final inputs = {'float_input': inputOrt}; // Must match Python name

    final runOptions = OrtRunOptions();
    final outputs = await _session?.runAsync(runOptions, inputs);

    // Index 1 contains the probabilities for Random Forest
    // [0][1] corresponds to the 0.3500 we saw in Python
    // 1. Get the raw output value (it is likely List<dynamic>)
    final dynamic rawValue = outputs?[1]?.value;

    // 2. Perform a deep cast to List<List<double>>
    final List<List<double>>? probabilities = (rawValue as List?)?.map((outer) {
      return (outer as List).map((inner) => (inner as num).toDouble()).toList();
    }).toList();
    final double addictionProb = probabilities![0][1];

    // Cleanup to prevent memory leaks (Gap 6: Efficiency)
    inputOrt.release();
    runOptions.release();
    outputs?.forEach((e) => e?.release());

    return addictionProb;
  }
}
