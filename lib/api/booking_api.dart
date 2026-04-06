import 'dart:convert';
import 'package:http/http.dart' as http;
import 'endpoints/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/booking/booking_model.dart';
import 'endpoints/booking_endpoint.dart';

// ==================== CUSTOM EXCEPTION ====================
class BookingException implements Exception {
  final String message;

  BookingException(this.message);

  @override
  String toString() => message;
}

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
        // Parse error từ backend
        try {
          final errorData = json.decode(response.body);

          // Backend trả về {"detail": "message"}
          if (errorData is Map && errorData.containsKey('detail')) {
            throw BookingException(errorData['detail']);
          }

          // Fallback nếu có message
          if (errorData is Map && errorData.containsKey('message')) {
            throw BookingException(errorData['message']);
          }

          throw BookingException('Failed to create booking');
        } catch (e) {
          if (e is BookingException) rethrow;
          throw BookingException('Failed to create booking');
        }
      }
    } on BookingException {
      // Rethrow BookingException để giữ message
      rethrow;
    } catch (e) {
      print('Create booking error: $e');
      throw BookingException('Không thể kết nối đến server');
    }
  }

  // ==================== GET BOOKINGS BY USER ====================
  Future<GetAllBookingsResponse> getBookingsByUser(String userId) async {
    final token = await AuthStorage.getAccessToken();

    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        print(' JWT Payload: $payload');
      }
    }

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
      int bookingId,
      String status,
      ) async {
    final baseUrl = ApiConfig.getUrlWithIdAndAction(
        BookingEmdpoint.bookingUpdateStatus,
        bookingId,
        'status'
    );
    final url = Uri.parse('$baseUrl?status=$status');

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
        // Parse error từ backend
        try {
          final errorData = json.decode(response.body);

          if (errorData is Map && errorData.containsKey('detail')) {
            throw BookingException(errorData['detail']);
          }

          if (errorData is Map && errorData.containsKey('message')) {
            throw BookingException(errorData['message']);
          }

          throw BookingException('Không thể cập nhật trạng thái');
        } catch (e) {
          if (e is BookingException) rethrow;
          throw BookingException('Không thể cập nhật trạng thái');
        }
      }
    } on BookingException {
      rethrow;
    } catch (e) {
      print('Update booking status error: $e');
      throw BookingException('Không thể kết nối đến server');
    }
  }

  // ==================== CANCEL BOOKING ====================
  Future<BookingStatusUpdateResponse> cancelBooking(int bookingId) async {
    final url = Uri.parse(
        ApiConfig.getUrlWithIdAndAction(
            BookingEmdpoint.bookingCancel,
            bookingId,
            BookingEmdpoint.bookingCancelAction
        )
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

  // ==================== BOOM BOOKING ====================
  Future<BookingStatusUpdateResponse> boomBooking(int bookingId) async {
    final url = Uri.parse(
        ApiConfig.getUrlWithIdAndAction(
            BookingEmdpoint.boomBooking,
            bookingId,
            BookingEmdpoint.bookingBoomAction
        )
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
        return BookingStatusUpdateResponse.fromJson(jsonResponse);
      } else {
        // Parse error từ backend
        try {
          final errorData = json.decode(response.body);

          // Backend trả về {"detail": "message"}
          if (errorData is Map && errorData.containsKey('detail')) {
            throw BookingException(errorData['detail']);
          }

          if (errorData is Map && errorData.containsKey('message')) {
            throw BookingException(errorData['message']);
          }

          throw BookingException('Không thể đánh dấu khách không đến');
        } catch (e) {
          if (e is BookingException) rethrow;
          throw BookingException('Không thể đánh dấu khách không đến');
        }
      }
    } on BookingException {
      rethrow;
    } catch (e) {
      print('Boom booking error: $e');
      throw BookingException('Không thể kết nối đến server');
    }
  }

  // ==================== GET BOOKINGS BY BARBER ====================
  Future<GetAllBookingsResponse> getBookingsByBarber(String barberId) async {
    final url = Uri.parse(
      ApiConfig.getUrlWithId(BookingEmdpoint.bookingGetByBarber, barberId),
    );
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
        throw Exception(error['message'] ?? 'Failed to get barber bookings');
      }
    } catch (e) {
      print('Get barber bookings error: $e');
      rethrow;
    }
  }

}