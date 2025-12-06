import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/service/service_model.dart';

class ServiceApi {

  // ==================== GET ALL SERVICES ====================
  Future<GetAllServicesResponse> getAllServices() async {
    final url = Uri.parse(ApiConfig.getUrl(ApiConfig.serviceGetAll));
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
        return GetAllServicesResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get all services');
      }
    } catch (e) {
      print('Get all services error: $e');
      rethrow;
    }
  }

  // ==================== GET SERVICE BY ID ====================
  Future<GetServiceByIdResponse> getServiceById(String serviceId) async {
    // Sửa: dùng getServiceUrlWithId thay vì getUrlWithId
    final url = Uri.parse(ApiConfig.getServiceUrlWithId(serviceId));
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
        return GetServiceByIdResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get service');
      }
    } catch (e) {
      print('Get service by id error: $e');
      rethrow;
    }
  }

  // ==================== GET SERVICES BY BARBER ====================
  Future<GetServicesByBarberResponse> getServicesByBarber(String barberId) async {
    // Sửa: dùng getServiceByBarberUrl
    final url = Uri.parse(ApiConfig.getServiceByBarberUrl(barberId));
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
        return GetServicesByBarberResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get services by barber');
      }
    } catch (e) {
      print('Get services by barber error: $e');
      rethrow;
    }
  }
}