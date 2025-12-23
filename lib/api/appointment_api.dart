// lib/services/api/appointment_api.dart
import 'dart:convert';
import 'package:barbergofe/api/endpoints/appointment_endpoint.dart';

import 'endpoints/api_config.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:http/http.dart' as http;


class AppointmentApi {
  final String baseUrl;

  AppointmentApi({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  // Tạo appointment mới
  Future<AppointmentModel> createAppointment({
    required String userId,
    required String nameBarber,
    required String phone,
    required String email,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(AppointmentEndpoint.appointmentCreate);
    final headers = await ApiConfig.getHeaders(token: token);

    final body = jsonEncode({
      'user_id': userId,
      'name_barber': nameBarber,
      'phone': phone,
      'email': email,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AppointmentModel.fromJson(data);
      } else {
        throw Exception('Failed to create appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating appointment: $e');
    }
  }

  // Lấy tất cả appointments của user
  Future<List<AppointmentModel>> getUserAppointments({
    required String userId,
    required String token,
  }) async {
    final url = ApiConfig.getUrlWithId(AppointmentEndpoint.appointmentGetByUser, userId);
    final headers = await ApiConfig.getHeaders(token: token);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => AppointmentModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get appointments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting appointments: $e');
    }
  }

  // Lấy appointment theo ID
  Future<AppointmentModel> getAppointmentById(
) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }
    final url = ApiConfig.getUrlWithId(AppointmentEndpoint.appointmentGetByUser, userId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers:await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppointmentModel.fromJson(data);
      } else {
        throw Exception('Failed to get appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting appointment: $e');
    }
  }
}