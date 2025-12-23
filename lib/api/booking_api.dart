import 'dart:convert';
import 'package:http/http.dart' as http;
import 'endpoints/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/booking/booking_model.dart';
import 'endpoints/booking_endpoint.dart';

class BookingApi {

  // ==================== CREATE BOOKING ====================
  Future<BookingCreateResponse> createBooking(BookingCreateRequest request) async {
    final url = Uri.parse(ApiConfig.getUrl(BookingEmdpoint.bookingCreate));
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
        return BookingCreateResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      print('Create booking error: $e');
      rethrow;
    }
  }

  // ==================== GET BOOKINGS BY USER ====================
  Future<GetAllBookingsResponse> getBookingsByUser(String userId) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(BookingEmdpoint.bookingGetByUser, userId));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        return GetAllBookingsResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get user bookings');
      }
    } catch (e) {
      print('Get user bookings error: $e');
      rethrow;
    }
  }

  // ==================== GET BOOKING BY ID ====================
  Future<BookingModel> getBookingById(String id) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(BookingEmdpoint.bookingGetById, id));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return BookingModel.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get booking');
      }
    } catch (e) {
      print('Get booking by id error: $e');
      rethrow;
    }
  }

  // ==================== UPDATE BOOKING STATUS ====================
  Future<BookingStatusUpdateResponse> updateBookingStatus(
      String bookingId,
      String status,
      ) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(BookingEmdpoint.bookingUpdateStatus, bookingId));
    final fullUrl = Uri.parse('$url?status=$status');
    print('PATCH: $fullUrl');

    try {
      final response = await http.patch(
        fullUrl,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return BookingStatusUpdateResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update booking status');
      }
    } catch (e) {
      print('Update booking status error: $e');
      rethrow;
    }
  }

  // ==================== CANCEL BOOKING ====================
  Future<BookingStatusUpdateResponse> cancelBooking(String bookingId) async {
    final url = Uri.parse(ApiConfig.getUrlWithIdAndAction(BookingEmdpoint.bookingCancel,bookingId, BookingEmdpoint.bookingCancelAction));
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
        return BookingStatusUpdateResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      print('Cancel booking error: $e');
      rethrow;
    }
  }
}