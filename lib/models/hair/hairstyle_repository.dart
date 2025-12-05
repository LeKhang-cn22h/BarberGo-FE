import 'dart:async';  // ← Thêm import này
import 'dart:convert';
import 'dart:io';
import 'package:barbergofe/core/utils/api_config.dart';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';  // ← Thêm import này cho MediaType


class HairStyleRepository {
  // Sử dụng ApiConfig.baseUrl thay vì hardcode
  static String get _baseUrl => ApiConfig.getUrl("/api/v1/hairstyle");

  Future<HairStyleResponse> generateHairStyle({
    required File imageFile,
    required String style,
    int? seed,
    int steps = 30,
    double denoisingStrength = 0.35,
    bool returnMask = false,
  }) async {
    try {
      // Tạo URL với query parameters
      final uri = Uri.parse('$_baseUrl/generate').replace(
        queryParameters: {
          'style': style,
          'steps': steps.toString(),
          'denoising_strength': denoisingStrength.toString(),
          'return_mask': returnMask.toString(),
          if (seed != null) 'seed': seed.toString(),
        },
      );

      // Tạo multipart request với timeout
      var request = http.MultipartRequest('POST', uri);

      // Set timeout
      request.followRedirects = true;
      request.maxRedirects = 5;

      // Thêm file ảnh - SỬA MediaType
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),  // ← Đã sửa
        ),
      );

      // Gửi request với timeout - SỬA timeout
      var streamedResponse = await request.send().timeout(ApiConfig.timeout);
      var response = await http.Response.fromStream(streamedResponse);

      // Xử lý response
      if (response.statusCode == 200) {
        if (returnMask) {
          // Parse JSON response khi returnMask = true
          final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
          return HairStyleResponse.fromJson(jsonResponse);
        } else {
          // Nhận binary image khi returnMask = false
          final imageBytes = response.bodyBytes;
          final imageBase64 = base64Encode(imageBytes);

          // Extract metadata từ headers
          final seedHeader = response.headers['x-seed'];
          final styleHeader = response.headers['x-style-name'];
          final strengthHeader = response.headers['x-denoising-strength'];

          return HairStyleResponse(
            imageBase64: imageBase64,
            style: styleHeader ?? style,
            seed: seedHeader != null ? int.tryParse(seedHeader) : null,
            faceDetected: true, // Mặc định true nếu thành công
            prompts: {
              'positive': 'Generated hair style',
              'negative': '',
            },
          );
        }
      } else {
        // Xử lý lỗi HTTP
        return Future.error(_handleHttpError(response));
      }
    } on http.ClientException catch (e) {
      return Future.error('Network connection failed: ${e.message}');
    } on SocketException catch (e) {
      return Future.error('No internet connection: ${e.message}');
    } on TimeoutException catch (e) {  // ← TimeoutException từ dart:async
      return Future.error('Request timeout: $e');
    } catch (e) {
      return Future.error('Unexpected error: $e');
    }
  }

  Future<List<HairStyleInfo>> getAvailableStyles() async {
    try {
      final uri = Uri.parse('$_baseUrl/styles');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> stylesJson = jsonResponse['styles'];

        return stylesJson.map((styleJson) =>
            HairStyleInfo.fromJson(styleJson)
        ).toList();
      } else {
        throw _handleHttpError(response);
      }
    } on http.ClientException catch (e) {
      throw 'Network connection failed: ${e.message}';
    } on SocketException catch (e) {
      throw 'No internet connection: ${e.message}';
    } on TimeoutException catch (e) {  // ← TimeoutException từ dart:async
      throw 'Request timeout: $e';
    } catch (e) {
      throw 'Failed to load styles: $e';
    }
  }

  Future<HairStyleInfo?> getStyleInfo(String styleId) async {
    try {
      final styles = await getAvailableStyles();
      return styles.firstWhere(
            (style) => style.id == styleId,
        orElse: () => throw 'Style $styleId not found',
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method để xử lý lỗi HTTP
  String _handleHttpError(http.Response response) {
    String errorMessage;

    switch (response.statusCode) {
      case 400:
        errorMessage = 'Bad request. Please check your input.';
        break;
      case 401:
        errorMessage = 'Unauthorized. Please login again.';
        break;
      case 403:
        errorMessage = 'Forbidden. You don\'t have permission.';
        break;
      case 404:
        errorMessage = 'API endpoint not found.';
        break;
      case 500:
        errorMessage = 'Server error. Please try again later.';
        break;
      case 503:
        errorMessage = 'Service unavailable. Server is under maintenance.';
        break;
      default:
        errorMessage = 'HTTP Error ${response.statusCode}';
    }

    // Cố gắng parse error từ response body
    try {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      if (errorJson['detail'] != null) {
        errorMessage = errorJson['detail'].toString();
      }
    } catch (_) {
      // Nếu không parse được JSON, dùng raw body
      if (response.body.isNotEmpty) {
        errorMessage += '\n${response.body}';
      }
    }

    return errorMessage;
  }

  // Optional: Health check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }

      return {'status': 'unhealthy', 'error': 'HTTP ${response.statusCode}'};
    } on TimeoutException catch (e) {
      return {'status': 'unhealthy', 'error': 'Timeout: $e'};
    } catch (e) {
      return {'status': 'unhealthy', 'error': e.toString()};
    }
  }
}