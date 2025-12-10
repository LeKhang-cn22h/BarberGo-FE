
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'endpoints/api_config.dart';
  import '../core/utils/auth_storage.dart';
  import '../models/time_slot/time_slot_model.dart';
  import 'endpoints/time_slot_endpoint.dart';
  class TimeSlotApi {

    // ==================== GET TIME SLOTS BY BARBER ====================
    static String getTimeSlotsByBarberUrl(String barberId, {String? date, bool? isAvailable}) {
      final baseUrl = ApiConfig.getUrlWithId(TimeSlotEndpoint.timeSlotGetByBarber, barberId);

      final params = <String, String>{};
      if (date != null) params['slot_date'] = date;
      if (isAvailable != null) params['is_available'] = isAvailable.toString();

      return Uri.parse(baseUrl).replace(queryParameters: params.isNotEmpty ? params : null).toString();
    }


    Future<GetTimeSlotsByBarberResponse> getTimeSlotsByBarber(
        String barberId, {
          String? date,
          bool? isAvailable,
        }) async {
      final url = Uri.parse(
          getTimeSlotsByBarberUrl(barberId, date: date, isAvailable: isAvailable)
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
    static String getAvailableTimeSlotsUrl({String? barberId, String? date}) {
      String url = ApiConfig.getUrl(TimeSlotEndpoint.timeSlotGetAvailable);

      final params = <String, String>{};
      if (barberId != null) params['barber_id'] = barberId;
      if (date != null) params['slot_date'] = date;

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      return url;
    }
    // ==================== GET AVAILABLE TIME SLOTS ====================
    Future<GetAllTimeSlotsResponse> getAvailableTimeSlots({
      String? barberId,
      String? date,
    }) async {
      final url = Uri.parse(
          getAvailableTimeSlotsUrl(barberId: barberId, date: date)
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
      final url = Uri.parse(ApiConfig.getUrl(TimeSlotEndpoint.timeSlotCreate));
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