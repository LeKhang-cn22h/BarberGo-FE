import 'dart:convert';

import 'package:barbergofe/api/barber_api.dart';
import 'package:barbergofe/core/utils/api_config.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:http/http.dart' as http;

class BarberService {
  final BarberApi _barberApi = BarberApi();

  Future<GetAllBarbersResponse> getTopBarbers({int limit = 2}) async {
    try {
      return await _barberApi.getTopBarbers(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAreas() async {
    try {
      return await _barberApi.getAreas();
    } catch (e) {
      rethrow;
    }
  }

  Future<GetAllBarbersResponse> getBarbersByArea(String area) async {
    try {
      return await _barberApi.getBarbersByArea(area);
    } catch (e) {
      rethrow;
    }
  }

  Future<BarberGetResponse> getBarberById(String id) async { // ĐỔI THÀNH BarberGetResponse
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

        // Xử lý response cho BarberGetResponse (single barber)
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
          } else if (jsonResponse['barber'] != null) {
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

        // Trả về BarberGetResponse
        return BarberGetResponse(
          success: success,
          message: message,
          barber: barber,
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
}