import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/acne/acne_response.dart';
import '../../services/acne_service.dart';

class AcneViewModel extends ChangeNotifier {
  final AcneService _service = AcneService();

  // ==================== STATE ====================

  /// Captured image (single frontal image)
  File? capturedImage;

  /// Detection response
  AcneResponse? response;

  /// Loading state
  bool isLoading = false;

  /// Error message
  String? errorMessage;

  // ==================== GETTERS ====================

  /// Check if image is captured
  bool get hasImage => capturedImage != null;

  /// Check if analysis is done
  bool get hasResult => response != null;

  /// Get overall severity
  String get overallSeverity => response?.data?.summary?.overallSeverity ?? 'none';

  /// Get total acne regions
  int get acneRegions => response?.data?.summary?.acneRegions ?? 0;

  /// Get total regions analyzed
  int get totalRegions => response?.data?.summary?.totalRegions ?? 0;

  // ==================== METHODS ====================

  /// Capture image (set from camera view)
  void setCapturedImage(File image) {
    capturedImage = image;
    response = null;
    errorMessage = null;
    notifyListeners();

    print('Ảnh đã được chụp: ${image.path}');
  }

  /// Clear captured image
  void clearImage() {
    capturedImage = null;
    response = null;
    errorMessage = null;
    notifyListeners();

    print(' Đã xóa ảnh');
  }

  /// Detect acne from captured image
  Future<void> detect() async {
    if (capturedImage == null) {
      errorMessage = 'Chưa có ảnh để phân tích';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    response = null;
    notifyListeners();

    try {
      print('Bắt đầu phân tích mụn...');
      print('   Image path: ${capturedImage!.path}');

      // Call API
      response = await _service.detectAcne(capturedImage!);

      print('Phân tích hoàn tất!');
      print('   Regions analyzed: ${response?.data?.summary?.totalRegions}');
      print('   Acne regions: ${response?.data?.summary?.acneRegions}');
      print('   Overall severity: ${response?.data?.summary?.overallSeverity}');

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Lỗi phân tích: $e');

      errorMessage = _parseError(e);
      isLoading = false;
      notifyListeners();

      rethrow;
    }
  }

  /// Parse error message
  String _parseError(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Timeout') || errorStr.contains('timeout')) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra mạng.';
    } else if (errorStr.contains('SocketException')) {
      return 'Không có kết nối internet.';
    } else if (errorStr.contains('No face detected') || errorStr.contains('Không phát hiện được khuôn mặt')) {
      return 'Không phát hiện được khuôn mặt. Vui lòng chụp rõ hơn.';
    } else if (errorStr.contains('FormatException')) {
      return 'Lỗi xử lý dữ liệu từ server.';
    } else if (errorStr.contains('HttpException')) {
      return 'Lỗi kết nối với server.';
    } else {
      return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  /// Reset all state
  void reset() {
    capturedImage = null;
    response = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();

    print('ViewModel đã được reset');
  }

  /// Retry detection
  Future<void> retry() async {
    if (capturedImage != null) {
      await detect();
    }
  }
}