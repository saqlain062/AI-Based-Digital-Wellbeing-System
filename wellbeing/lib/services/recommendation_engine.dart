import 'dart:convert';

import 'package:flutter/services.dart';

class RecommendationResult {
  const RecommendationResult({
    required this.label,
    required this.message,
    required this.ruleId,
  });

  final String label;
  final String message;
  final String ruleId;
}

class RecommendationEngine {
  List<_RecommendationRule> _rules = const [];
  Map<String, dynamic> _fallbacks = const {};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString('assets/shap_recommendation_map.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;

    _rules = (decoded['rules'] as List<dynamic>)
        .whereType<Map>()
        .map((item) => _RecommendationRule.fromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    _fallbacks = Map<String, dynamic>.from(decoded['fallbacks'] as Map);
    _loaded = true;
  }

  RecommendationResult build({
    required double riskScore,
    required Map<String, double> features,
  }) {
    final matchingRules = _rules
        .where((rule) => rule.matches(riskScore: riskScore, features: features))
        .toList()
      ..sort((a, b) => b.score(features).compareTo(a.score(features)));

    if (matchingRules.isNotEmpty) {
      final selected = matchingRules.first;
      return RecommendationResult(
        label: selected.label,
        message: selected.message,
        ruleId: selected.id,
      );
    }

    if (riskScore > 0.7) {
      return _fallbackResult('high');
    }
    if (riskScore > 0.3 && (features['stress_level'] ?? 0) >= 7) {
      return _fallbackResult('moderate_stress');
    }
    if (riskScore > 0.3) {
      return _fallbackResult('moderate');
    }
    return _fallbackResult('low');
  }

  RecommendationResult _fallbackResult(String key) {
    final fallback = Map<String, dynamic>.from(
      _fallbacks[key] as Map<String, dynamic>? ??
          const {'label': 'Current balance', 'message': ''},
    );

    return RecommendationResult(
      label: fallback['label']?.toString() ?? 'Current balance',
      message: fallback['message']?.toString() ?? '',
      ruleId: 'fallback_$key',
    );
  }
}

class _RecommendationRule {
  const _RecommendationRule({
    required this.id,
    required this.feature,
    required this.label,
    required this.condition,
    required this.threshold,
    required this.minRiskScore,
    required this.priority,
    required this.message,
  });

  factory _RecommendationRule.fromJson(Map<String, dynamic> json) {
    return _RecommendationRule(
      id: json['id']?.toString() ?? '',
      feature: json['feature']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Current signals',
      condition: json['condition']?.toString() ?? 'gte',
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      minRiskScore: (json['min_risk_score'] as num?)?.toDouble() ?? 0.0,
      priority: (json['priority'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString() ?? '',
    );
  }

  final String id;
  final String feature;
  final String label;
  final String condition;
  final double threshold;
  final double minRiskScore;
  final double priority;
  final String message;

  bool matches({
    required double riskScore,
    required Map<String, double> features,
  }) {
    if (riskScore < minRiskScore) {
      return false;
    }

    final value = features[feature] ?? 0.0;
    if (condition == 'lte') {
      return value <= threshold;
    }
    return value >= threshold;
  }

  double score(Map<String, double> features) {
    final value = features[feature] ?? 0.0;
    final delta = condition == 'lte'
        ? (threshold - value).clamp(0.0, double.infinity)
        : (value - threshold).clamp(0.0, double.infinity);
    return priority + delta;
  }
}
