import 'package:flutter/material.dart';
import 'package:barbergofe/services/booking_service.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class BookingHistoryViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // ==================== STATE ====================
  List<BookingModel> _allBookings = [];
  List<BookingModel> _filteredBookings = [];
  BookingModel? _selectedBooking;
  String _selectedFilter = 'all'; // all, confirmed, completed, cancelled
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // ==================== GETTERS ====================
  List<BookingModel> get allBookings => _allBookings;
  List<BookingModel> get filteredBookings => _filteredBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  int get totalBookings => _allBookings.length;
  int get activeBookings => _allBookings.where((b) => b.status == 'confirmed').length;
  int get completedBookings => _allBookings.where((b) => b.status == 'completed').length;
  int get cancelledBookings => _allBookings.where((b) => b.status == 'cancelled').length;

  int get totalSpent {
    return _allBookings
        .where((booking) => booking.status == 'completed')
        .fold(0, (sum, booking) => sum + booking.totalPrice);
  }

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    await _loadCurrentUserId();
    if (_currentUserId != null) {
      await fetchUserBookings(_currentUserId!);
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      // Lấy user ID từ AuthStorage hoặc từ token
      final user = await AuthStorage.getUserId();
      if (user != null && user.isNotEmpty) {
        _currentUserId = user;
      }
    } catch (e) {
      print('Error loading current user id: $e');
    }
  }

  // ==================== FETCH METHODS ====================

  Future<void> fetchUserBookings(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.getUserBookings(userId);
      _allBookings = _bookingService.sortByDate(response.bookings);
      _applyFilter(_selectedFilter);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUserBookings() async {
    if (_currentUserId != null) {
      await fetchUserBookings(_currentUserId!);
    }
  }

  // ==================== FILTER METHODS ====================

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter(filter);
    notifyListeners();
  }

  void _applyFilter(String filter) {
    switch (filter) {
      case 'all':
        _filteredBookings = List.from(_allBookings);
        break;
      case 'confirmed':
        _filteredBookings = _bookingService.getActiveBookings(_allBookings);
        break;
      case 'completed':
        _filteredBookings = _bookingService.getCompletedBookings(_allBookings);
        break;
      case 'cancelled':
        _filteredBookings = _bookingService.getCancelledBookings(_allBookings);
        break;
      case 'upcoming':
        _filteredBookings = _bookingService.getUpcomingBookings(_allBookings);
        break;
      default:
        _filteredBookings = List.from(_allBookings);
    }
  }

  // ==================== SELECTION METHODS ====================

  void selectBooking(BookingModel booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // ==================== BOOKING ACTIONS ====================

  Future<void> cancelBooking(String bookingId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.cancelBooking(bookingId);

      // Update local booking
      final index = _allBookings.indexWhere((b) => b.id.toString() == bookingId);
      if (index != -1) {
        _allBookings[index] = response.booking;
        _applyFilter(_selectedFilter);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.updateBookingStatus(bookingId, status);

      // Update local booking
      final index = _allBookings.indexWhere((b) => b.id.toString() == bookingId);
      if (index != -1) {
        _allBookings[index] = response.booking;
        _applyFilter(_selectedFilter);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Search bookings
  void searchBookings(String query) {
    if (query.isEmpty) {
      _applyFilter(_selectedFilter);
    } else {
      _filteredBookings = _allBookings.where((booking) {
        final barberName = booking.barberName.toLowerCase();
        final servicesText = booking.servicesSummary.toLowerCase();
        final queryLower = query.toLowerCase();

        return barberName.contains(queryLower) ||
            servicesText.contains(queryLower) ||
            booking.formattedPrice.contains(query) ||
            booking.statusText.toLowerCase().contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total': totalBookings,
      'active': activeBookings,
      'completed': completedBookings,
      'cancelled': cancelledBookings,
      'totalSpent': totalSpent,
      'averageValue': totalBookings > 0 ? totalSpent / completedBookings : 0,
    };
  }

  // Check if booking can be cancelled
  bool canCancel(BookingModel booking) {
    return _bookingService.canCancelBooking(booking);
  }
}