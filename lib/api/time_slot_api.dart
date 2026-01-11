
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
          headers:await ApiConfig.getHeaders(
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
          headers:await ApiConfig.getHeaders(
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
          headers:await ApiConfig.getHeaders(
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
    //  Update time slot
    Future<TimeSlotModel> updateTimeSlot(
        int timeSlotId,
        TimeSlotUpdateRequest request,
        ) async {
      final url = Uri.parse(
        ApiConfig.getUrlWithId(TimeSlotEndpoint.timeSlotUpdate, timeSlotId),
      );
      print('PUT: $url');
      print('Request body: ${json.encode(request.toJson())}');

      try {
        final response = await http.put(
          url,
          headers: await ApiConfig.getHeaders(
            token: await AuthStorage.getAccessToken(),
          ),
          body: json.encode(request.toJson()),
        ).timeout(ApiConfig.timeout);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          // Backend trả về {message, time_slot}
          if (jsonResponse['time_slot'] != null) {
            return TimeSlotModel.fromJson(jsonResponse['time_slot']);
          } else if (jsonResponse['data'] != null) {
            return TimeSlotModel.fromJson(jsonResponse['data']);
          } else {
            return TimeSlotModel.fromJson(jsonResponse);
          }
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Failed to update time slot');
        }
      } catch (e) {
        print('Update time slot error: $e');
        rethrow;
      }
    }

    // Toggle availability
    Future<TimeSlotModel> toggleTimeSlotAvailability(int timeSlotId) async {
      final url = Uri.parse(
        '${ApiConfig.getUrlWithId(TimeSlotEndpoint.timeSlotToggle, timeSlotId)}/toggle',
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

          if (jsonResponse['time_slot'] != null) {
            return TimeSlotModel.fromJson(jsonResponse['time_slot']);
          } else if (jsonResponse['data'] != null) {
            return TimeSlotModel.fromJson(jsonResponse['data']);
          } else {
            return TimeSlotModel.fromJson(jsonResponse);
          }
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Failed to toggle availability');
        }
      } catch (e) {
        print('Toggle availability error: $e');
        rethrow;
      }
    }

    //  Delete time slot
    Future<void> deleteTimeSlot(int timeSlotId) async {
      final url = Uri.parse(
        ApiConfig.getUrlWithId(TimeSlotEndpoint.timeSlotDelete, timeSlotId),
      );
      print('DELETE: $url');

      try {
        final response = await http.delete(
          url,
          headers: await ApiConfig.getHeaders(
            token: await AuthStorage.getAccessToken(),
          ),
        ).timeout(ApiConfig.timeout);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode != 200) {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Failed to delete time slot');
        }
      } catch (e) {
        print('Delete time slot error: $e');
        rethrow;
      }
    }

    Future<List<TimeSlotModel>> bulkCreateTimeSlots(
        TimeSlotBulkCreateRequest request,
        ) async {
      final url = Uri.parse(ApiConfig.getUrl(TimeSlotEndpoint.timeSlotCreateBulk));
      print('POST: $url');
      print('Request body: ${json.encode(request.toJson())}');

      try {
        final response = await http.post(
          url,
          headers: await ApiConfig.getHeaders(
            token: await AuthStorage.getAccessToken(),
          ),
          body: json.encode(request.toJson()),
        ).timeout(ApiConfig.timeout);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = json.decode(response.body);

          List<TimeSlotModel> slots = [];

          // Backend trả về {message, time_slots}
          if (jsonResponse['time_slots'] != null) {
            slots = (jsonResponse['time_slots'] as List)
                .map((slot) => TimeSlotModel.fromJson(slot))
                .toList();
          } else if (jsonResponse['data'] != null) {
            slots = (jsonResponse['data'] as List)
                .map((slot) => TimeSlotModel.fromJson(slot))
                .toList();
          }

          return slots;
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Failed to bulk create time slots');
        }
      } catch (e) {
        print('Bulk create time slots error: $e');
        rethrow;
      }
    }
  }
