import 'package:flutter/material.dart';
import 'package:barbergofe/services/rating_service.dart';
import 'package:barbergofe/models/rating/rating_model.dart';

class RatingViewModel extends ChangeNotifier {
  final RatingService _service = RatingService();

  // State
  bool _isLoading = false;
  String? _error;

  // Data
  List<RatingWithDetails> _allRatings = [];
  List<RatingWithUser> _barberRatings = [];
  List<RatingWithBarber> _userRatings = [];
  BarberAverageRating? _barberAverage;
  RatingWithUser? _currentUserRating; // Rating của user hiện tại cho barber đang xem

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RatingWithDetails> get allRatings => _allRatings;
  List<RatingWithUser> get barberRatings => _barberRatings;
  List<RatingWithBarber> get userRatings => _userRatings;
  BarberAverageRating? get barberAverage => _barberAverage;
  RatingWithUser? get currentUserRating => _currentUserRating;

  /// Tạo đánh giá mới
  Future<bool> createRating(String barberId, String userId, double score) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = RatingCreate(
        barberId: barberId,
        userId: userId,
        score: score,
      );

      final response = await _service.createRating(request);

      print('Rating created successfully: ${response.message}');
      print('New barber rank: ${response.barberNewRank}');

      // Refresh data sau khi tạo thành công
      await fetchBarberRatings(barberId);
      await fetchBarberAverage(barberId);
      await checkUserRating(userId, barberId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Create rating error: $e');
      return false;
    }
  }

  /// Lấy tất cả đánh giá
  Future<void> fetchAllRatings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allRatings = await _service.getAllRatings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Fetch all ratings error: $e');
    }
  }

  /// Lấy đánh giá của barber
  Future<void> fetchBarberRatings(String barberId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _barberRatings = await _service.getRatingsByBarberId(barberId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Fetch barber ratings error: $e');
    }
  }

  /// Lấy điểm trung bình của barber
  Future<void> fetchBarberAverage(String barberId) async {
    try {
      _barberAverage = await _service.getBarberAverage(barberId);
      notifyListeners();
    } catch (e) {
      print(' Fetch barber average error: $e');
    }
  }

  /// Lấy đánh giá của user
  Future<void> fetchUserRatings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userRatings = await _service.getRatingsByUserId(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Fetch user ratings error: $e');
    }
  }

  /// Kiểm tra user đã đánh giá barber này chưa
  Future<void> checkUserRating(String userId, String barberId) async {
    try {
      _currentUserRating = await _service.checkUserRatingForBarber(userId, barberId);
      notifyListeners();
    } catch (e) {
      print('Check user rating error: $e');
    }
  }

  /// Cập nhật đánh giá
  Future<bool> updateRating(String ratingId, double newScore, String barberId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = RatingUpdate(score: newScore);
      final response = await _service.updateRating(ratingId, request);

      print('Rating updated successfully: ${response.message}');
      print('New barber rank: ${response.barberNewRank}');

      // Refresh data
      await fetchBarberRatings(barberId);
      await fetchBarberAverage(barberId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Update rating error: $e');
      return false;
    }
  }

  /// Xóa đánh giá
  Future<bool> deleteRating(String ratingId, String barberId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _service.deleteRating(ratingId);

      print('Rating deleted: ${response.message}');

      // Refresh data
      await fetchBarberRatings(barberId);
      await fetchBarberAverage(barberId);
      _currentUserRating = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Delete rating error: $e');
      return false;
    }
  }

  /// Clear data
  void clearData() {
    _allRatings = [];
    _barberRatings = [];
    _userRatings = [];
    _barberAverage = null;
    _currentUserRating = null;
    _error = null;
    notifyListeners();
  }
}