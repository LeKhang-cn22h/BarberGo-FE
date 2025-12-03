import 'dart:convert';
import 'dart:io';
import '../api/acne_api.dart';
import '../models/acne/acne_response.dart';

class AcneService {
  final AcneApi api = AcneApi();

  /// Detect acne from single frontal image
  Future<AcneResponse> detectAcne(File image) async {
    // ✅ LOG - TRƯỚC KHI GỌI API
    print('🔵 [SERVICE] Bắt đầu phân tích mụn...');
    print('📂 Image: ${image.path}');
    print('📏 File size: ${await image.length()} bytes');

    try {
      // Gọi API (gửi 1 ảnh)
      final jsonString = await api.detectAcne(image: image);

      print('✅ [SERVICE] Nhận được response từ server');
      print('📦 [SERVICE] Response length: ${jsonString.length} characters');

      // Parse JSON
      final data = jsonDecode(jsonString);
      print('📊 [SERVICE] Data đã parse thành công');

      // Debug: In ra structure
      if (data is Map) {
        print('🔍 [SERVICE] Response keys: ${data.keys}');
        if (data.containsKey('success')) {
          print('   success: ${data['success']}');
        }
        if (data.containsKey('data')) {
          print('   data: ${data['data'].runtimeType}');
        }
      }

      // Convert to model
      final response = AcneResponse.fromJson(data);
      print('✅ [SERVICE] Converted to AcneResponse model');
      // print('   Total acne zones: ${response.data.totalAcneZones}');

      return response;

    } catch (e, stackTrace) {
      print('❌ [SERVICE] Lỗi khi gọi API: $e');
      print('📍 [SERVICE] Stack trace: $stackTrace');
      rethrow; // Ném lỗi lên ViewModel
    }
  }


}