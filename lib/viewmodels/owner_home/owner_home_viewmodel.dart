// lib/viewmodels/owner_home/owner_home_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/services/booking_service.dart';
import 'package:barbergofe/services/time_slot_service.dart';
import 'package:barbergofe/services/barber_service.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class OwnerHomeViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final TimeSlotService _timeSlotService = TimeSlotService();
  final BarberService _barberService = BarberService();

  // State
  bool _isLoading = false;
  bool _isStoreOpen = true;
  String? _error;
  String? _barberId;

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
      print('🔄 Starting initialization...');

      // ✅ 1. Lấy barberId từ owner
      _barberId = await _getBarberId();
      print('✅ Barber ID: $_barberId');

      // ✅ 2. Load data song song
      await Future.wait([
        _fetchTodayTimeSlots(_barberId!),
        _fetchTodayBookings(_barberId!),
      ]);

      // ✅ 3. Tính toán stats
      _calculateStats();
      _findUpcomingBooking();

      print('✅ Initialization complete');
      print('   - Time slots: ${_todayTimeSlots.length}');
      print('   - Bookings: ${_allBookings.length}');
      print('   - Total slots: $_totalSlots');
      print('   - Booked: $_bookedSlots');
      print('   - Available: $_availableSlots');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi tải dữ liệu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('❌ Error initializing: $e');
    }
  }

  /// ✅ SỬA: Fetch time slots hôm nay
  Future<void> _fetchTodayTimeSlots(String barberId) async {
    try {
      final today = DateTime.now();
      final dateStr = _formatDate(today);

      print('🔍 Fetching time slots for barber: $barberId, date: $dateStr');

      final response = await _timeSlotService.getTimeSlotsByBarber(
        barberId,
        date: dateStr,
      );

      _todayTimeSlots = _timeSlotService.sortByTime(response.timeSlots);
      print('✅ Loaded ${_todayTimeSlots.length} time slots');

      // Debug: In ra từng slot
      for (var slot in _todayTimeSlots) {
        print('   Slot #${slot.id}: ${slot.startTime} - ${slot.endTime}, available: ${slot.isAvailable}');
      }
    } catch (e) {
      print('❌ Error fetching time slots: $e');
      rethrow;
    }
  }

  /// ✅ SỬA: Fetch bookings của BARBER hôm nay (không phải user)
  Future<void> _fetchTodayBookings(String barberId) async {
    try {
      print('🔍 Fetching bookings for barber: $barberId');

      // ✅ QUAN TRỌNG: Dùng getBarberBookings thay vì getUserBookings
      final response = await _bookingService.getBarberBookings(barberId);

      print('📦 Raw bookings count: ${response.bookings.length}');

      // ✅ Filter bookings hôm nay
      final today = DateTime.now();
      _allBookings = response.bookings.where((booking) {
        if (booking.timeSlots == null) {
          print('⚠️ Booking #${booking.id} has no time_slots');
          return false;
        }

        final slotDateStr = booking.timeSlots!['slot_date']?.toString();
        if (slotDateStr == null) {
          print('⚠️ Booking #${booking.id} has no slot_date');
          return false;
        }

        try {
          final slotDate = DateTime.parse(slotDateStr);
          final isToday = slotDate.year == today.year &&
              slotDate.month == today.month &&
              slotDate.day == today.day;

          if (isToday) {
            print('✅ Booking #${booking.id} is today: ${booking.status}');
          }

          return isToday;
        } catch (e) {
          print('❌ Error parsing date for booking #${booking.id}: $e');
          return false;
        }
      }).toList();

      print('✅ Filtered ${_allBookings.length} bookings for today');

      // Debug: In ra từng booking
      for (var booking in _allBookings) {
        print('   Booking #${booking.id}: status=${booking.status}, slot_id=${booking.timeSlotId}');
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      rethrow;
    }
  }

  /// ✅ SỬA: Calculate statistics
  void _calculateStats() {
    _totalSlots = _todayTimeSlots.length;

    // ✅ Đếm slots đã đặt dựa trên bookings
    _bookedSlots = 0;
    for (var slot in _todayTimeSlots) {
      // Tìm booking cho slot này
      final hasBooking = _allBookings.any((booking) =>
      booking.timeSlotId == slot.id &&
          booking.status.toLowerCase() != 'cancelled'
      );

      if (hasBooking) {
        _bookedSlots++;
      }
    }

    _availableSlots = _totalSlots - _bookedSlots;

    print('📊 Stats calculated:');
    print('   Total: $_totalSlots');
    print('   Booked: $_bookedSlots');
    print('   Available: $_availableSlots');
    print('   Percentage: ${bookingPercentage.toStringAsFixed(1)}%');
  }

  /// ✅ SỬA: Find upcoming booking
  void _findUpcomingBooking() {
    final now = DateTime.now();

    print('🔍 Finding upcoming booking...');

    // Lọc bookings confirmed
    final confirmedBookings = _allBookings
        .where((b) => b.status.toLowerCase() == 'confirmed')
        .toList();

    print('   Found ${confirmedBookings.length} confirmed bookings');

    if (confirmedBookings.isEmpty) {
      _upcomingBooking = null;
      print('   No confirmed bookings');
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

      print('   Checking booking #${booking.id}: start=${startTime.hour}:${startTime.minute}');

      if (startTime.isAfter(now)) {
        _upcomingBooking = booking;
        print('✅ Upcoming booking found: #${booking.id}');
        return;
      }
    }

    // Nếu không có booking nào sau giờ hiện tại, lấy booking đầu tiên
    _upcomingBooking = confirmedBookings.first;
    print('✅ Using first booking as upcoming: #${_upcomingBooking!.id}');
  }

  /// Toggle store status
  Future<void> toggleStoreStatus() async {
    _isStoreOpen = !_isStoreOpen;
    notifyListeners();

    print('${_isStoreOpen ? "🟢 Store OPENED" : "🔴 Store CLOSED"}');

    // TODO: Call API to update store status
    // await _barberService.updateBarberStatus(_barberId!, _isStoreOpen);
  }

  /// Check-in customer
  Future<void> checkInCustomer(int bookingId) async {
    try {
      print('🔄 Checking in booking #$bookingId');

      await _bookingService.updateBookingStatus(
        bookingId.toString(),
        'in_progress',
      );

      print('✅ Customer checked in');
      await initialize(); // Refresh data
    } catch (e) {
      print('❌ Error checking in: $e');
      rethrow;
    }
  }

  /// Complete booking
  Future<void> completeBooking(int bookingId) async {
    try {
      print('🔄 Completing booking #$bookingId');

      await _bookingService.updateBookingStatus(
        bookingId.toString(),
        'completed',
      );

      print('✅ Booking completed');
      await initialize(); // Refresh data
    } catch (e) {
      print('❌ Error completing booking: $e');
      rethrow;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  // ==================== HELPER METHODS ====================

  /// ✅ SỬA: Lấy barberId từ user hiện tại
  Future<String> _getBarberId() async {
    try {
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // ✅ Lấy barber của owner này
      final barber = await _barberService.getBarberByOwnerId(userId);

      if (barber == null) {
        throw Exception('No barber found for this owner');
      }

      return barber.barbers.first.id.toString();
    } catch (e) {
      print('❌ Error getting barber ID: $e');
      rethrow;
    }
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

  /// ✅ SỬA: Get schedule item status
  String getScheduleItemStatus(TimeSlotModel timeSlot) {
    // Tìm booking cho slot này
    final booking = _allBookings.firstWhere(
          (b) => b.timeSlotId == timeSlot.id && b.status.toLowerCase() != 'cancelled',
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
        case 'confirmed':
          return 'booked';
        default:
          return 'booked';
      }
    }

    return 'available';
  }

  /// Get booking for time slot
  BookingModel? getBookingForSlot(TimeSlotModel timeSlot) {
    try {
      return _allBookings.firstWhere(
            (b) => b.timeSlotId == timeSlot.id && b.status.toLowerCase() != 'cancelled',
      );
    } catch (e) {
      return null;
    }
  }
}