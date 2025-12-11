import 'package:barbergofe/api/booking_api.dart';
import 'package:barbergofe/models/booking/booking_model.dart';

class BookingService {
  final BookingApi _bookingApi = BookingApi();

  // ==================== CREATE BOOKING ====================
  Future<BookingCreateResponse> createBooking(BookingCreateRequest request) async {
    try {
      return await _bookingApi.createBooking(request);
    } catch (e) {
      print('BookingService - createBooking error: $e');
      rethrow;
    }
  }

  // ==================== GET USER BOOKINGS ====================
  Future<GetAllBookingsResponse> getUserBookings(String userId) async {
    try {
      return await _bookingApi.getBookingsByUser(userId);
    } catch (e) {
      print('BookingService - getUserBookings error: $e');
      rethrow;
    }
  }

  // ==================== GET BOOKING BY ID ====================
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      return await _bookingApi.getBookingById(bookingId);
    } catch (e) {
      print('BookingService - getBookingById error: $e');
      rethrow;
    }
  }

  // ==================== UPDATE STATUS ====================
  Future<BookingStatusUpdateResponse> updateBookingStatus(
      String bookingId,
      String status,
      ) async {
    try {
      return await _bookingApi.updateBookingStatus(bookingId, status);
    } catch (e) {
      print('BookingService - updateBookingStatus error: $e');
      rethrow;
    }
  }

  // ==================== CANCEL BOOKING ====================
  Future<BookingStatusUpdateResponse> cancelBooking(String bookingId) async {
    try {
      return await _bookingApi.cancelBooking(bookingId);
    } catch (e) {
      print('BookingService - cancelBooking error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  List<BookingModel> filterByStatus(List<BookingModel> bookings, String status) {
    return bookings.where((booking) =>
    booking.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }

  List<BookingModel> sortByDate(List<BookingModel> bookings, {bool descending = true}) {
    final sorted = List<BookingModel>.from(bookings);
    sorted.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(0);
      final bDate = b.createdAt ?? DateTime(0);
      return descending
          ? bDate.compareTo(aDate)
          : aDate.compareTo(bDate);
    });
    return sorted;
  }

  List<BookingModel> getActiveBookings(List<BookingModel> bookings) {
    return bookings.where((booking) =>
    booking.status.toLowerCase() == 'confirmed'
    ).toList();
  }

  List<BookingModel> getCompletedBookings(List<BookingModel> bookings) {
    return bookings.where((booking) =>
    booking.status.toLowerCase() == 'completed'
    ).toList();
  }

  List<BookingModel> getCancelledBookings(List<BookingModel> bookings) {
    return bookings.where((booking) =>
    booking.status.toLowerCase() == 'cancelled'
    ).toList();
  }

  // Calculate total spent
  int calculateTotalSpent(List<BookingModel> bookings) {
    return bookings
        .where((booking) => booking.status.toLowerCase() == 'completed')
        .fold(0, (sum, booking) => sum + booking.totalPrice);
  }

  // Calculate average booking value
  double calculateAverageBookingValue(List<BookingModel> bookings) {
    final completedBookings = getCompletedBookings(bookings);
    if (completedBookings.isEmpty) return 0.0;

    final total = calculateTotalSpent(completedBookings);
    return total / completedBookings.length;
  }

  // Get upcoming bookings
  List<BookingModel> getUpcomingBookings(List<BookingModel> bookings) {
    final now = DateTime.now();
    return bookings.where((booking) {
      if (booking.status.toLowerCase() != 'confirmed') return false;
      if (booking.timeSlots == null) return false;

      final slotDateStr = booking.timeSlots!['slot_date']?.toString();
      if (slotDateStr == null) return false;

      try {
        final slotDate = DateTime.parse(slotDateStr);
        return slotDate.isAfter(now) ||
            slotDate.year == now.year &&
                slotDate.month == now.month &&
                slotDate.day == now.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Check if booking can be cancelled
  bool canCancelBooking(BookingModel booking) {
    if (booking.status.toLowerCase() != 'confirmed') return false;

    if (booking.timeSlots == null) return true;

    final slotDateStr = booking.timeSlots!['slot_date']?.toString();
    if (slotDateStr == null) return true;

    try {
      final slotDate = DateTime.parse(slotDateStr);
      final now = DateTime.now();
      final difference = slotDate.difference(now);
      return difference.inHours > 2; // Cho phép hủy trước 2 giờ
    } catch (e) {
      return true;
    }
  }
}