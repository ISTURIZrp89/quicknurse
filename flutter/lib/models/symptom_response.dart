class SymptomResponse {
  final String diagnosis;
  final double confidence;
  final String recommendation;
  final String source;
  final String priority;
  final bool redFlag;

  SymptomResponse({
    required this.diagnosis,
    required this.confidence,
    required this.recommendation,
    this.source = 'offline_rules',
    this.priority = 'observacion',
    this.redFlag = false,
  });

  factory SymptomResponse.fromJson(Map<String, dynamic> json) {
    return SymptomResponse(
      diagnosis: json['diagnosis'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendation: json['recommendation'] as String? ?? '',
      source: json['source'] as String? ?? 'offline_rules',
      priority: json['priority'] as String? ?? 'observacion',
      redFlag: json['red_flag'] as bool? ?? false,
    );
  }
}
