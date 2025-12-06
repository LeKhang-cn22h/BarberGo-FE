import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/time_slot/time_slot_model.dart';

class TimeSlotApi {

  // ==================== GET TIME SLOTS BY BARBER ====================
  Future<GetTimeSlotsByBarberResponse> getTimeSlotsByBarber(
      String barberId, {
        String? date,
        bool? isAvailable,
      }) async {
    final url = Uri.parse(
        ApiConfig.getTimeSlotsByBarberUrl(barberId, date: date, isAvailable: isAvailable)
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
        return GetTimeSlotsByBarberResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get time slots');
      }
    } catch (e) {
      print('Get time slots by barber error: $e');
      rethrow;
    }
  }

  // ==================== GET AVAILABLE TIME SLOTS ====================
  Future<GetAllTimeSlotsResponse> getAvailableTimeSlots({
    String? barberId,
    String? date,
  }) async {
    final url = Uri.parse(
        ApiConfig.getAvailableTimeSlotsUrl(barberId: barberId, date: date)
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
        return GetAllTimeSlotsResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get available time slots');
      }
    } catch (e) {
      print('Get available time slots error: $e');
      rethrow;
    }
  }

  // ==================== CREATE TIME SLOT ====================
  Future<TimeSlotModel> createTimeSlot(TimeSlotCreateRequest request) async {
    final url = Uri.parse(ApiConfig.getUrl(ApiConfig.timeSlotCreate));
    print('POST: $url');
    print('Request body: ${json.encode(request.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode(request.toJson()),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return TimeSlotModel.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create time slot');
      }
    } catch (e) {
      print('Create time slot error: $e');
      rethrow;
    }
  }
}