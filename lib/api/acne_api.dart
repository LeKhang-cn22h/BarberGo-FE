import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';

class AcneApi {

  // ==================== DETECT ACNE ====================

  /// Detect acne from single frontal image
  Future<String> detectAcne({required File image}) async {
    final url = ApiConfig.getUrl(ApiConfig.acneDetect);
    print('🌐 Gửi request tới: $url');

    final uri = Uri.parse(url);
    final request = http.MultipartRequest("POST", uri);

    // Add single image
    request.files.add(
      await http.MultipartFile.fromPath("image", image.path),
    );

    // Send request with timeout
    final streamedResponse = await request
        .send()
        .timeout(ApiConfig.timeout, onTimeout: () {
      throw Exception('⏱️ Timeout: Server không phản hồi');
    });

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('✅ Success: ${response.statusCode}');
      return response.body;
    } else {
      print('❌ Error: ${response.statusCode}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // ==================== GET HISTORY ====================

  /// Get acne detection history
  Future<String> getHistory({
    required String userId,
    int limit = 20,
  }) async {
    final url = ApiConfig.getUrl(
      '${ApiConfig.acneHistory}?user_id=$userId&limit=$limit',
    );

    print('🌐 GET: $url');

    final response = await http
        .get(Uri.parse(url))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get history: ${response.statusCode}');
    }
  }

  // ==================== GET STATISTICS ====================

  /// Get acne statistics
  Future<String> getStatistics({
    required String userId,
    String period = 'month', // 'week', 'month', 'year'
  }) async {
    final url = ApiConfig.getUrl(
      '${ApiConfig.acneStats}?user_id=$userId&period=$period',
    );

    print('🌐 GET: $url');

    final response = await http
        .get(Uri.parse(url))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get stats: ${response.statusCode}');
    }
  }
}