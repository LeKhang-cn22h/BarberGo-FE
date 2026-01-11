import 'dart:convert';
import 'package:http/http.dart' as http;
import 'endpoints/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/service/service_model.dart';
import 'endpoints/service_endpoint.dart';
class ServiceApi {

  // ==================== GET ALL SERVICES ====================
  Future<GetAllServicesResponse> getAllServices() async {
    final url = Uri.parse(ApiConfig.getUrl(ServiceEndpoint.serviceGetAll));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers:await ApiConfig.getHeaders(
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
    final url = Uri.parse(ApiConfig.getUrlWithId(ServiceEndpoint.serviceGetById,serviceId));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers:await ApiConfig.getHeaders(
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
    final url = Uri.parse(ApiConfig.getUrlWithId(ServiceEndpoint.serviceGetByBarber,barberId));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers:await ApiConfig.getHeaders(
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

  Future<ServiceResponsePrice> getPriceRange(String barberId) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(ServiceEndpoint.serviceGetPriceRange,barberId));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers:await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        return ServiceResponsePrice.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get services by barber');
      }
    } catch (e) {
      print('Get services by barber error: $e');
      rethrow;
    }
  }
  // ==================== CREATE SERVICE ====================
  Future<ServiceCreateResponse> createService(
      ServiceCreateRequest request) async {
    final url = Uri.parse(ApiConfig.getUrl(ServiceEndpoint.serviceCreate));
    print('POST: $url');

    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ServiceCreateResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create service');
      }
    } catch (e) {
      print('Create service error: $e');
      rethrow;
    }
  }
// ==================== UPDATE SERVICE ====================
  Future<ServiceUpdateResponse> updateService(
      String serviceId,
      ServiceUpdateRequest request,
      ) async {
    final url = Uri.parse(
      ApiConfig.getUrlWithId(ServiceEndpoint.serviceUpdate, serviceId),
    );
    print('PUT: $url');

    try {
      final response = await http.put(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ServiceUpdateResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update service');
      }
    } catch (e) {
      print('Update service error: $e');
      rethrow;
    }
  }
// ==================== DELETE SERVICE (SOFT) ====================
  Future<ServiceStatusResponse> deleteService(String serviceId) async {
    final url = Uri.parse(
      '${ApiConfig.getUrlWithId(ServiceEndpoint.serviceDelete, serviceId)}/delete',
    );
    print('PATCH: $url');

    try {
      final response = await http.patch(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ServiceStatusResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete service');
      }
    } catch (e) {
      print('Delete service error: $e');
      rethrow;
    }
  }
// ==================== RESTORE SERVICE ====================
  Future<ServiceStatusResponse> restoreService(String serviceId) async {
    final url = Uri.parse(
      '${ApiConfig.getUrlWithId(ServiceEndpoint.serviceRestore, serviceId)}/restore',
    );
    print('PATCH: $url');

    try {
      final response = await http.patch(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ServiceStatusResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to restore service');
      }
    } catch (e) {
      print('Restore service error: $e');
      rethrow;
    }
  }
// ==================== TOGGLE SERVICE STATUS ====================
  Future<ServiceStatusResponse> toggleServiceStatus(String serviceId) async {
    final url = Uri.parse(
      '${ApiConfig.getUrlWithId(ServiceEndpoint.serviceToggleStatus, serviceId)}/toggle-status',
    );
    print('PATCH: $url');

    try {
      final response = await http.patch(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ServiceStatusResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to toggle service status');
      }
    } catch (e) {
      print('Toggle service status error: $e');
      rethrow;
    }
  }

}