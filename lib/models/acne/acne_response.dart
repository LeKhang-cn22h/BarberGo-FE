// models/acne/acne_response.dart

/// Main response wrapper
class AcneResponse {
  final bool success;
  final AcneResponseData? data;
  final String? error;

  AcneResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory AcneResponse.fromJson(Map<String, dynamic> json) {
    return AcneResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? AcneResponseData.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.toJson(),
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return 'AcneResponse(success: $success, hasData: ${data != null}, error: $error)';
  }
}

/// Response data (chứa regions, summary, advice, overall)
class AcneResponseData {
  final Map<String, RegionData>? regions;  // Chi tiết từng vùng
  final AcneSummary? summary;              // Tổng hợp thống kê
  final List<AdviceItem>? advice;          // Lời khuyên
  final OverallAssessment? overall;        // Đánh giá tổng thể

  AcneResponseData({
    this.regions,
    this.summary,
    this.advice,
    this.overall,
  });

  factory AcneResponseData.fromJson(Map<String, dynamic> json) {
    // Parse regions
    Map<String, RegionData>? regionsMap;
    if (json['regions'] != null && json['regions'] is Map) {
      regionsMap = {};
      (json['regions'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          regionsMap![key] = RegionData.fromJson(value);
        }
      });
    }

    // Parse summary
    AcneSummary? summaryData;
    if (json['summary'] != null && json['summary'] is Map) {
      summaryData = AcneSummary.fromJson(json['summary']);
    }

    // Parse advice
    List<AdviceItem>? adviceList;
    if (json['advice'] != null && json['advice'] is List) {
      adviceList = (json['advice'] as List)
          .map((item) => AdviceItem.fromJson(item))
          .toList();
    }

    // Parse overall
    OverallAssessment? overallData;
    if (json['overall'] != null && json['overall'] is Map) {
      overallData = OverallAssessment.fromJson(json['overall']);
    }

    return AcneResponseData(
      regions: regionsMap,
      summary: summaryData,
      advice: adviceList,
      overall: overallData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (regions != null)
        'regions': regions!.map((key, value) => MapEntry(key, value.toJson())),
      if (summary != null) 'summary': summary!.toJson(),
      if (advice != null) 'advice': advice!.map((e) => e.toJson()).toList(),
      if (overall != null) 'overall': overall!.toJson(),
    };
  }

  @override
  String toString() {
    return 'AcneResponseData(regions: ${regions?.length}, hasAdvice: ${advice != null})';
  }
}

/// Region data (Binary: có mụn/không mụn)
class RegionData {
  final bool hasAcne;        // Có mụn hay không
  final double confidence;   // Độ tin cậy (0-1)
  final String severity;     // none/mild/moderate/severe

  RegionData({
    required this.hasAcne,
    required this.confidence,
    required this.severity,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      hasAcne: json['has_acne'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      severity: json['severity'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_acne': hasAcne,
      'confidence': confidence,
      'severity': severity,
    };
  }

  /// Severity color (hex)
  int get severityColor {
    switch (severity) {
      case 'severe':
        return 0xFFD32F2F; // Red
      case 'moderate':
        return 0xFFF57C00; // Orange
      case 'mild':
        return 0xFFFBC02D; // Yellow
      case 'none':
      default:
        return 0xFF388E3C; // Green
    }
  }

  /// Severity text (Vietnamese)
  String get severityText {
    switch (severity) {
      case 'severe':
        return 'Nghiêm trọng';
      case 'moderate':
        return 'Trung bình';
      case 'mild':
        return 'Nhẹ';
      case 'none':
      default:
        return 'Sạch';
    }
  }

  /// Confidence percentage
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'RegionData(hasAcne: $hasAcne, confidence: $confidencePercent, severity: $severity)';
  }
}

/// Summary statistics
class AcneSummary {
  final int totalRegions;             // Tổng số vùng
  final int acneRegions;              // Số vùng có mụn
  final int clearRegions;             // Số vùng sạch
  final String overallSeverity;       // none/mild/moderate/severe
  final double averageConfidence;     // Confidence trung bình
  final Map<String, int>? severityCount; // {'mild': 2, 'moderate': 1, ...}

  AcneSummary({
    required this.totalRegions,
    required this.acneRegions,
    required this.clearRegions,
    required this.overallSeverity,
    required this.averageConfidence,
    this.severityCount,
  });

  factory AcneSummary.fromJson(Map<String, dynamic> json) {
    return AcneSummary(
      totalRegions: json['total_regions'] ?? 0,
      acneRegions: json['acne_regions'] ?? 0,
      clearRegions: json['clear_regions'] ?? 0,
      overallSeverity: json['overall_severity'] ?? 'none',
      averageConfidence: (json['average_confidence'] ?? 0.0).toDouble(),
      severityCount: json['severity_count'] != null
          ? Map<String, int>.from(json['severity_count'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_regions': totalRegions,
      'acne_regions': acneRegions,
      'clear_regions': clearRegions,
      'overall_severity': overallSeverity,
      'average_confidence': averageConfidence,
      if (severityCount != null) 'severity_count': severityCount,
    };
  }

  /// Acne percentage
  double get acnePercentage {
    if (totalRegions == 0) return 0.0;
    return (acneRegions / totalRegions) * 100;
  }

  /// Clear percentage
  double get clearPercentage {
    if (totalRegions == 0) return 0.0;
    return (clearRegions / totalRegions) * 100;
  }

  /// Overall severity text (Vietnamese)
  String get overallSeverityText {
    switch (overallSeverity) {
      case 'severe':
        return 'Nghiêm trọng';
      case 'moderate':
        return 'Trung bình';
      case 'mild':
        return 'Nhẹ';
      case 'none':
      default:
        return 'Sạch';
    }
  }

  /// Overall severity color
  int get overallSeverityColor {
    switch (overallSeverity) {
      case 'severe':
        return 0xFFD32F2F;
      case 'moderate':
        return 0xFFF57C00;
      case 'mild':
        return 0xFFFBC02D;
      case 'none':
      default:
        return 0xFF388E3C;
    }
  }

  @override
  String toString() {
    return 'AcneSummary(total: $totalRegions, acne: $acneRegions, overall: $overallSeverity)';
  }
}

/// Advice item (Binary version)
class AdviceItem {
  final String zone;              // Trán, Mũi, Má, Cằm
  final String severity;          // healthy/mild/moderate/severe
  final double? confidence;       // Optional confidence
  final List<String> tips;        // Danh sách lời khuyên

  AdviceItem({
    required this.zone,
    required this.severity,
    this.confidence,
    required this.tips,
  });

  factory AdviceItem.fromJson(Map<String, dynamic> json) {
    return AdviceItem(
      zone: json['zone'] ?? '',
      severity: json['severity'] ?? 'healthy',
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      tips: (json['tips'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
      'severity': severity,
      if (confidence != null) 'confidence': confidence,
      'tips': tips,
    };
  }

  /// Severity color
  int get severityColor {
    switch (severity) {
      case 'severe':
        return 0xFFD32F2F;
      case 'moderate':
        return 0xFFF57C00;
      case 'mild':
        return 0xFFFBC02D;
      case 'healthy':
      default:
        return 0xFF388E3C;
    }
  }

  /// Severity text
  String get severityText {
    switch (severity) {
      case 'severe':
        return 'Nghiêm trọng';
      case 'moderate':
        return 'Trung bình';
      case 'mild':
        return 'Nhẹ';
      case 'healthy':
      default:
        return 'Khỏe mạnh';
    }
  }

  @override
  String toString() {
    return 'AdviceItem(zone: $zone, severity: $severity, tips: ${tips.length})';
  }
}

/// Overall assessment
class OverallAssessment {
  final String severity;          // healthy/mild/moderate/severe
  final String recommendation;    // Khuyến nghị chung
  final bool needDoctor;          // Có cần gặp bác sĩ không
  final int affectedRegions;      // Số vùng bị ảnh hưởng

  OverallAssessment({
    required this.severity,
    required this.recommendation,
    required this.needDoctor,
    required this.affectedRegions,
  });

  factory OverallAssessment.fromJson(Map<String, dynamic> json) {
    return OverallAssessment(
      severity: json['severity'] ?? 'healthy',
      recommendation: json['recommendation'] ?? '',
      needDoctor: json['need_doctor'] ?? false,
      affectedRegions: json['affected_regions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'severity': severity,
      'recommendation': recommendation,
      'need_doctor': needDoctor,
      'affected_regions': affectedRegions,
    };
  }

  /// Severity text
  String get severityText {
    switch (severity) {
      case 'severe':
        return 'Nghiêm trọng';
      case 'moderate':
        return 'Trung bình';
      case 'mild':
        return 'Nhẹ';
      case 'healthy':
      default:
        return 'Khỏe mạnh';
    }
  }

  /// Severity color
  int get severityColor {
    switch (severity) {
      case 'severe':
        return 0xFFD32F2F;
      case 'moderate':
        return 0xFFF57C00;
      case 'mild':
        return 0xFFFBC02D;
      case 'healthy':
      default:
        return 0xFF388E3C;
    }
  }

  @override
  String toString() {
    return 'OverallAssessment(severity: $severity, needDoctor: $needDoctor)';
  }
}