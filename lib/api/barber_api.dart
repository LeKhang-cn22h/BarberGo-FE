import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../core/utils/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/barber/barber_model.dart';
class BarberApi {

  // ==================== GET TOP BARBERS ====================
  Future<GetAllBarbersResponse> getTopBarbers({int limit = 2}) async {
    final url = Uri.parse(ApiConfig.getUrl(ApiConfig.barbertop)).replace(
      queryParameters: {'limit': limit.toString()},
    );

    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý khi API trả về List (mảng)
        if (jsonResponse is List) {
          print('API returned a List directly, converting to GetAllBarbersResponse');

          final List<BarberModel> barbersList = jsonResponse
              .map<BarberModel>((item) {
            print('Parsing barber item: $item');
            return BarberModel.fromJson(item);
          })
              .toList();

          print('Successfully parsed ${barbersList.length} barbers');

          return GetAllBarbersResponse(
            success: true,
            message: null,
            barbers: barbersList,
            statusCode: 200,
          );
        }
        // Xử lý khi API trả về Map (object)
        else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map, using fromJson');
          return GetAllBarbersResponse.fromJson(jsonResponse);
        }
        // Trường hợp khác
        else {
          print('Unknown response format: ${jsonResponse.runtimeType}');
          throw Exception('Invalid response format from server');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get top barbers');
      }
    } catch (e) {
      print('Get top barbers error: $e');
      rethrow;
    }
  }

  // ==================== GET ALL AREAS ====================
  Future<List<String>> getAreas() async {
    final url = ApiConfig.getUrl(ApiConfig.barberarea);
    print('GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse.cast<String>();
        }
        return [];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get areas');
      }
    } catch (e) {
      print('Get areas error: $e');
      rethrow;
    }
  }
  // api/barber_api.dart
  Future<BarberGetResponse> getBarberById(String id) async {
    final url = ApiConfig.getBarberUrlWithId(id);
    print('📞 GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý để lấy SINGLE barber
        BarberModel? barber;
        bool success = true;
        String? message;

        if (jsonResponse is List) {
          print('API returned a List for single barber');
          if (jsonResponse.isEmpty) {
            throw Exception('Barber not found');
          }
          barber = BarberModel.fromJson(jsonResponse.first);
        } else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map for single barber');

          // Kiểm tra cấu trúc response
          if (jsonResponse.containsKey('success')) {
            success = jsonResponse['success'] ?? true;
            message = jsonResponse['message'];
          }

          // Tìm barber trong response
          if (jsonResponse['data'] != null) {
            final data = jsonResponse['data'];
            if (data is Map<String, dynamic>) {
              barber = BarberModel.fromJson(data);
            } else if (data is List && data.isNotEmpty) {
              barber = BarberModel.fromJson(data.first);
            }
          } else if (jsonResponse['barber'] != null && jsonResponse['barber'] is Map<String, dynamic>) {
            barber = BarberModel.fromJson(jsonResponse['barber']);
          } else {
            // Nếu response là barber object trực tiếp
            try {
              barber = BarberModel.fromJson(jsonResponse);
            } catch (e) {
              print('Cannot parse as barber: $e');
            }
          }
        }

        if (barber == null) {
          throw Exception('Barber data not found in response');
        }

        print('✅ Successfully parsed barber: ${barber.name}');

        // TRẢ VỀ BarberGetResponse với SINGLE barber
        return BarberGetResponse(
          success: success,
          message: message,
          barber: barber, // SINGLE barber
          statusCode: 200,
        );

      } else if (response.statusCode == 404) {
        throw Exception('Barber not found (404)');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get barber details');
      }
    } catch (e) {
      print('❌ Get barber by ID error: $e');
      rethrow;
    }
  }

  // ==================== GET BARBERS BY AREA ====================
  Future<GetAllBarbersResponse> getBarbersByArea(String area) async {
    final url = '${ApiConfig.getUrl(ApiConfig.barberareafocus)}/$area';
    print('GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Thêm debug

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        // Debug: In ra kiểu dữ liệu của response
        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý khi API trả về List (mảng)
        if (jsonResponse is List) {
          print('API returned a List directly, converting to GetAllBarbersResponse');

          // Convert List to List<BarberModel>
          final List<BarberModel> barbersList = jsonResponse
              .map<BarberModel>((item) => BarberModel.fromJson(item))
              .toList();

          // Tạo GetAllBarbersResponse từ List
          return GetAllBarbersResponse(
            success: true,
            message: null,
            barbers: barbersList,
            statusCode: 200,
          );
        }
        // Xử lý khi API trả về Map (object)
        else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map, using fromJson');
          return GetAllBarbersResponse.fromJson(jsonResponse);
        }
        // Trường hợp khác
        else {
          print('Unknown response format: ${jsonResponse.runtimeType}');
          throw Exception('Invalid response format from server');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get barbers by area');
      }
    } catch (e) {
      print('Get barbers by area error: $e');
      rethrow;
    }
  }

}