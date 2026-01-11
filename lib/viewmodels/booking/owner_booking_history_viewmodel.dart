
import 'package:flutter/material.dart';
import 'package:barbergofe/services/booking_service.dart';
import 'package:barbergofe/models/booking/booking_model.dart';

class OwnerBookingHistoryViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // State
  List<BookingModel> _allBookings = [];
  List<BookingModel> _filteredBookings = [];
  BookingModel? _selectedBooking;
  String _selectedFilter = 'all'; // all, confirmed, completed, cancelled
  bool _isLoading = false;
  String? _error;
  String? _currentBarberId;

  // Getters
  List<BookingModel> get allBookings => _allBookings;
  List<BookingModel> get filteredBookings => _filteredBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBookings => _allBookings.isNotEmpty;

  int get totalBookings => _allBookings.length;
  int get activeBookings => _allBookings.where((b) => b.status == 'confirmed').length;
  int get completedBookings => _allBookings.where((b) => b.status == 'completed').length;
  int get cancelledBookings => _allBookings.where((b) => b.status == 'cancelled').length;

  int get totalRevenue {
    return _allBookings
        .where((booking) => booking.status == 'completed')
        .fold(0, (sum, booking) => sum + booking.totalPrice);
  }

  // ==================== FETCH METHODS ====================

  Future<void> fetchBarberBookings(String barberId) async {
    _currentBarberId = barberId;
    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.getBarberBookings(barberId);
      _allBookings = _bookingService.sortByDate(response.bookings);
      _applyFilter(_selectedFilter);
      print('✅ Fetched barber bookings: ${_allBookings.length}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetching barber bookings: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    if (_currentBarberId != null) {
      await fetchBarberBookings(_currentBarberId!);
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

  Future<bool> updateBookingStatus(String bookingId, String status) async {
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
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== SEARCH ====================

  void searchBookings(String query) {
    if (query.isEmpty) {
      _applyFilter(_selectedFilter);
    } else {
      _filteredBookings = _allBookings.where((booking) {
        final userName = booking.user?['full_name']?.toString().toLowerCase() ?? '';
        final servicesText = booking.servicesSummary.toLowerCase();
        final queryLower = query.toLowerCase();

        return userName.contains(queryLower) ||
            servicesText.contains(queryLower) ||
            booking.formattedPrice.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // ==================== STATISTICS ====================

  Map<String, dynamic> getStatistics() {
    return {
      'total': totalBookings,
      'active': activeBookings,
      'completed': completedBookings,
      'cancelled': cancelledBookings,
      'revenue': totalRevenue,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}