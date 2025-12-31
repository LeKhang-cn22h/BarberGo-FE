import 'package:flutter/material.dart';
import 'package:barbergofe/services/booking_service.dart';
import 'package:barbergofe/services/time_slot_service.dart';
import 'package:barbergofe/services/service_service.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class OwnerHomeViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final TimeSlotService _timeSlotService = TimeSlotService();
  final ServiceService _serviceService = ServiceService();

  // State
  bool _isLoading = false;
  bool _isStoreOpen = true;
  String? _error;

  // Data
  List<BookingModel> _allBookings = [];
  List<TimeSlotModel> _todayTimeSlots = [];
  BookingModel? _upcomingBooking;
  int _totalSlots = 0;
  int _bookedSlots = 0;
  int _availableSlots = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isStoreOpen => _isStoreOpen;
  String? get error => _error;
  List<BookingModel> get allBookings => _allBookings;
  List<TimeSlotModel> get todayTimeSlots => _todayTimeSlots;
  BookingModel? get upcomingBooking => _upcomingBooking;

  int get totalSlots => _totalSlots;
  int get bookedSlots => _bookedSlots;
  int get availableSlots => _availableSlots;
  double get bookingPercentage => _totalSlots > 0
      ? (_bookedSlots / _totalSlots * 100)
      : 0.0;

  /// Initialize - Load all data
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final barberId = await _getBarberId();

      await Future.wait([
        _fetchTodayTimeSlots(barberId),
        _fetchTodayBookings(barberId),
      ]);

      _calculateStats();
      _findUpcomingBooking();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print(' Error initializing: $e');
    }
  }

  /// Fetch time slots hôm nay
  Future<void> _fetchTodayTimeSlots(String barberId) async {
    try {
      final today = DateTime.now();
      final dateStr = _formatDate(today);

      final response = await _timeSlotService.getTimeSlotsByBarber(
        barberId,
        date: dateStr,
      );

      _todayTimeSlots = _timeSlotService.sortByTime(response.timeSlots);
      print(' Loaded ${_todayTimeSlots.length} time slots');
    } catch (e) {
      print(' Error fetching time slots: $e');
      rethrow;
    }
  }

  /// Fetch bookings hôm nay
  Future<void> _fetchTodayBookings(String barberId) async {
    try {
      // Get userId từ barber để lấy bookings
      final userId = await AuthStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await _bookingService.getUserBookings(userId);

      // Filter bookings hôm nay
      final today = DateTime.now();
      _allBookings = response.bookings.where((booking) {
        if (booking.timeSlots == null) return false;
        final slotDateStr = booking.timeSlots!['slot_date']?.toString();
        if (slotDateStr == null) return false;

        try {
          final slotDate = DateTime.parse(slotDateStr);
          return slotDate.year == today.year &&
              slotDate.month == today.month &&
              slotDate.day == today.day;
        } catch (e) {
          return false;
        }
      }).toList();

      print('Loaded ${_allBookings.length} bookings today');
    } catch (e) {
      print('Error fetching bookings: $e');
      rethrow;
    }
  }

  /// Calculate statistics
  void _calculateStats() {
    _totalSlots = _todayTimeSlots.length;
    _bookedSlots = _todayTimeSlots.where((slot) => !slot.isAvailable).length;
    _availableSlots = _totalSlots - _bookedSlots;

    print('Stats: Total=$_totalSlots, Booked=$_bookedSlots, Available=$_availableSlots');
  }

  /// Find upcoming booking (sắp diễn ra gần nhất)
  void _findUpcomingBooking() {
    final now = DateTime.now();

    // Lọc bookings confirmed
    final confirmedBookings = _allBookings
        .where((b) => b.status.toLowerCase() == 'confirmed')
        .toList();

    if (confirmedBookings.isEmpty) {
      _upcomingBooking = null;
      return;
    }

    // Sort theo thời gian bắt đầu
    confirmedBookings.sort((a, b) {
      final aTime = _parseTime(a.timeSlots?['start_time']?.toString() ?? '');
      final bTime = _parseTime(b.timeSlots?['start_time']?.toString() ?? '');
      return aTime.compareTo(bTime);
    });

    // Tìm booking đầu tiên sau thời điểm hiện tại
    for (var booking in confirmedBookings) {
      final startTime = _parseTime(booking.timeSlots?['start_time']?.toString() ?? '');
      if (startTime.isAfter(now)) {
        _upcomingBooking = booking;
        return;
      }
    }

    _upcomingBooking = null;
  }

  /// Toggle store status
  Future<void> toggleStoreStatus() async {
    _isStoreOpen = !_isStoreOpen;
    notifyListeners();

    // TODO: Call API to update store status
    print('${_isStoreOpen ? "Store OPENED" : " Store CLOSED"}');
  }

  /// Check-in customer
  Future<void> checkInCustomer(int bookingId) async {
    try {
      await _bookingService.updateBookingStatus(
        bookingId.toString(),
        'in_progress',
      );

      await initialize(); // Refresh data
      print(' Customer checked in');
    } catch (e) {
      print(' Error checking in: $e');
      rethrow;
    }
  }

  /// Complete booking
  Future<void> completeBooking(int bookingId) async {
    try {
      await _bookingService.updateBookingStatus(
        bookingId.toString(),
        'completed',
      );

      await initialize(); // Refresh data
      print('Booking completed');
    } catch (e) {
      print('Error completing booking: $e');
      rethrow;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  // ==================== HELPER METHODS ====================

  Future<String> _getBarberId() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) throw Exception('User not logged in');
    return userId;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Get minutes until booking starts
  int getMinutesUntil(BookingModel booking) {
    if (booking.timeSlots == null) return 0;

    final startTimeStr = booking.timeSlots!['start_time']?.toString() ?? '';
    final startTime = _parseTime(startTimeStr);
    final now = DateTime.now();

    return startTime.difference(now).inMinutes;
  }

  /// Get schedule item status
  String getScheduleItemStatus(TimeSlotModel timeSlot) {
    if (!timeSlot.isAvailable) {
      // Find booking for this time slot
      final booking = _allBookings.firstWhere(
            (b) => b.timeSlotId == timeSlot.id,
        orElse: () => BookingModel(
          id: 0,
          userId: '',
          status: '',
          timeSlotId: 0,
          totalDurationMin: 0,
          totalPrice: 0,
        ),
      );

      if (booking.id > 0) {
        switch (booking.status.toLowerCase()) {
          case 'completed':
            return 'completed';
          case 'in_progress':
            return 'in_progress';
          default:
            return 'booked';
        }
      }
    }
    return 'available';
  }

  /// Get booking for time slot
  BookingModel? getBookingForSlot(TimeSlotModel timeSlot) {
    try {
      return _allBookings.firstWhere(
            (b) => b.timeSlotId == timeSlot.id,
      );
    } catch (e) {
      return null;
    }
  }
}