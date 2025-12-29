import 'package:barbergofe/api/rating_api.dart';
import 'package:barbergofe/models/rating/rating_model.dart';

class RatingService {
  final RatingApi _api = RatingApi();

  /// Tạo đánh giá mới
  Future<RatingResponse> createRating(RatingCreate request) async {
    return await _api.createRating(request);
  }

  /// Lấy tất cả đánh giá
  Future<List<RatingWithDetails>> getAllRatings() async {
    return await _api.getAllRatings();
  }

  /// Lấy đánh giá theo ID
  Future<RatingWithDetails> getRatingById(int ratingId) async {
    return await _api.getRatingById(ratingId);
  }

  /// Lấy đánh giá của barber
  Future<List<RatingWithUser>> getRatingsByBarberId(String barberId) async {
    return await _api.getRatingsByBarberId(barberId);
  }

  /// Lấy điểm trung bình của barber
  Future<BarberAverageRating> getBarberAverage(String barberId) async {
    return await _api.getBarberAverage(barberId);
  }

  /// Lấy đánh giá của user
  Future<List<RatingWithBarber>> getRatingsByUserId(String userId) async {
    return await _api.getRatingsByUserId(userId);
  }

  /// Cập nhật đánh giá
  Future<RatingResponse> updateRating(int ratingId, RatingUpdate request) async {
    return await _api.updateRating(ratingId, request);
  }

  /// Xóa đánh giá
  Future<DeleteRatingResponse> deleteRating(int ratingId) async {
    return await _api.deleteRating(ratingId);
  }

  /// Kiểm tra user đã đánh giá barber này chưa
  Future<RatingWithUser?> checkUserRatingForBarber(String userId, String barberId) async {
    try {
      final userRatings = await getRatingsByUserId(userId);

      // Tìm rating của user cho barber này
      for (var rating in userRatings) {
        if (rating.barberId == barberId) {
          // Convert RatingWithBarber to RatingWithUser
          return RatingWithUser(
            id: rating.id,
            barberId: rating.barberId,
            userId: rating.userId,
            score: rating.score,
            createdAt: rating.createdAt,
            user: null,
          );
        }
      }

      return null;
    } catch (e) {
      print(' Error checking user rating: $e');
      return null;
    }
  }
}