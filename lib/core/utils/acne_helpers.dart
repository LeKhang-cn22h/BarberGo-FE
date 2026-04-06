import 'package:flutter/material.dart';

/// Helper class chứa các hàm tiện ích cho acne analysis
class AcneHelpers {
  /// Chuyển đổi tên vùng sang tiếng Việt
  static String getVietnameseName(String key) {
    const map = {
      'forehead': 'Trán',
      'nose': 'Mũi',
      'cheek_left': 'Má trái',
      'cheek_right': 'Má phải',
      'chin': 'Cằm',
    };
    return map[key] ?? key;
  }

  /// Chuyển đổi severity sang tiếng Việt
  static String getSeverityText(String severity) {
    const map = {
      'severe': 'Nghiêm trọng',
      'moderate': 'Trung bình',
      'mild': 'Nhẹ',
      'none': 'Sạch',
      'healthy': 'Khỏe mạnh',
    };
    return map[severity] ?? severity;
  }

  /// Lấy màu theo severity
  static Color getSeverityColor(String severity) {
    const map = {
      'severe': Color(0xFFD32F2F),
      'moderate': Color(0xFFF57C00),
      'mild': Color(0xFFFBC02D),
      'none': Color(0xFF388E3C),
      'healthy': Color(0xFF388E3C),
    };
    return map[severity] ?? Colors.grey;
  }

  /// Lấy icon theo severity
  static IconData getSeverityIcon(String severity) {
    const map = {
      'severe': Icons.error,
      'moderate': Icons.warning,
      'mild': Icons.info,
      'none': Icons.check_circle,
      'healthy': Icons.check_circle,
    };
    return map[severity] ?? Icons.help;
  }
}