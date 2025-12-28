import 'dart:convert';
import 'package:barbergofe/api/endpoints/api_config.dart';
import 'package:barbergofe/api/endpoints/rating_endpoint.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/rating/rating_model.dart';
import 'package:http/http.dart' as http;

class RatingApi {
  // ==================== CREATE ====================

  /// Tạo đánh giá mới
  /// Yêu cầu: Đăng nhập
  Future<RatingResponse> createRating(RatingCreate req) async {
    final url = Uri.parse(ApiConfig.getUrl(RatingEndpoint.createRating));
    print('POST: $url');

    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode(req.toJson()),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return RatingResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Tạo đánh giá thất bại');
      }
    } catch (e) {
      print('Create rating error: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Lấy danh sách tất cả đánh giá
  /// Không yêu cầu đăng nhập
  Future<List<RatingWithDetails>> getAllRatings() async {
    final url = Uri.parse(ApiConfig.getUrl(RatingEndpoint.getRating));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RatingWithDetails.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Lấy danh sách đánh giá thất bại');
      }
    } catch (e) {
      print('Get all ratings error: $e');
      rethrow;
    }
  }

  /// Lấy thông tin chi tiết 1 đánh giá theo ID
  /// Không yêu cầu đăng nhập
  Future<RatingWithDetails> getRatingById(String ratingId) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(RatingEndpoint.getRatingById,ratingId));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return RatingWithDetails.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Không tìm thấy đánh giá');
      }
    } catch (e) {
      print('Get rating by id error: $e');
      rethrow;
    }
  }

  /// Lấy danh sách đánh giá của 1 barber
  /// Không yêu cầu đăng nhập
  Future<List<RatingWithUser>> getRatingsByBarberId(String barberId) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(RatingEndpoint.getRatingByBarberId,barberId));
    print(' GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RatingWithUser.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Lấy đánh giá của barber thất bại');
      }
    } catch (e) {
      print('Get ratings by barber error: $e');
      rethrow;
    }
  }

  /// Lấy điểm trung bình và tổng số đánh giá của barber
  /// Không yêu cầu đăng nhập
  Future<BarberAverageRating> getBarberAverage(String barberId) async {
    final url = Uri.parse(ApiConfig.getUrlWithIdAndAction(RatingEndpoint.getBarberAverage,barberId,'average'));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return BarberAverageRating.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Lấy điểm trung bình thất bại');
      }
    } catch (e) {
      print('Get barber average error: $e');
      rethrow;
    }
  }

  /// Lấy danh sách đánh giá của 1 user
  /// Yêu cầu: Đăng nhập
  Future<List<RatingWithBarber>> getRatingsByUserId(String userId) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(RatingEndpoint.getUserRating,userId));
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RatingWithBarber.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Lấy đánh giá của user thất bại');
      }
    } catch (e) {
      print('Get ratings by user error: $e');
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Cập nhật đánh giá
  /// Yêu cầu: Đăng nhập
  Future<RatingResponse> updateRating(String ratingId, RatingUpdate req) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(RatingEndpoint.updateRating,ratingId));
    print('PUT: $url');

    try {
      final response = await http.put(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode(req.toJson()),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return RatingResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Cập nhật đánh giá thất bại');
      }
    } catch (e) {
      print('Update rating error: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Xóa đánh giá
  /// Yêu cầu: Đăng nhập
  Future<DeleteRatingResponse> deleteRating(String ratingId) async {
    final url = Uri.parse(ApiConfig.getUrlWithId(RatingEndpoint.deleteRating,ratingId));
    print(' DELETE: $url');

    try {
      final response = await http.delete(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DeleteRatingResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Xóa đánh giá thất bại');
      }
    } catch (e) {
      print('Delete rating error: $e');
      rethrow;
    }
  }
}