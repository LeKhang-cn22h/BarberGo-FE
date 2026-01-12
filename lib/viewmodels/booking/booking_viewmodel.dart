import 'package:barbergofe/services/simple_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/services/service_service.dart';
import 'package:barbergofe/services/time_slot_service.dart';
import 'package:barbergofe/services/booking_service.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class BookingViewModel extends ChangeNotifier {
  final ServiceService _serviceService = ServiceService();
  final TimeSlotService _timeSlotService = TimeSlotService();
  final BookingService _bookingService = BookingService();

  // ==================== STATE ====================
  BarberModel? _selectedBarber;
  List<ServiceModel> _selectedServices = [];
  List<TimeSlotModel> _availableTimeSlots = [];
  TimeSlotModel? _selectedTimeSlot;
  DateTime? _selectedDate;

  bool _isLoading = false;
  String? _error;
  BookingCreateResponse? _lastBookingResponse;

  // ==================== GETTERS ====================
  BarberModel? get selectedBarber => _selectedBarber;
  List<ServiceModel> get selectedServices => _selectedServices;
  List<TimeSlotModel> get availableTimeSlots => _availableTimeSlots;
  TimeSlotModel? get selectedTimeSlot => _selectedTimeSlot;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  BookingCreateResponse? get lastBookingResponse => _lastBookingResponse;

  // Tổng giá dịch vụ
  int get totalPrice {
    return _selectedServices.fold(0, (sum, service) => sum + service.price);
  }

  // Tổng thời gian
  int get totalDuration {
    return _selectedServices.fold(0, (sum, service) => sum + service.durationMin);
  }

  // Có đủ thông tin để đặt lịch
  bool get canBook {
    return _selectedBarber != null &&
        _selectedServices.isNotEmpty &&
        _selectedTimeSlot != null;
  }

  // ==================== BARBER SELECTION ====================
  void selectBarber(BarberModel barber) {
    _selectedBarber = barber;
    _clearTimeSlots();
    notifyListeners();
  }

  void clearBarber() {
    _selectedBarber = null;
    _clearTimeSlots();
    notifyListeners();
  }

  // ==================== SERVICE SELECTION ====================
  void addService(ServiceModel service) {
    if (!_selectedServices.any((s) => s.id == service.id)) {
      _selectedServices.add(service);
      notifyListeners();
    }
  }

  void removeService(ServiceModel service) {
    _selectedServices.removeWhere((s) => s.id == service.id);
    notifyListeners();
  }

  void toggleService(ServiceModel service) {
    if (_selectedServices.any((s) => s.id == service.id)) {
      removeService(service);
    } else {
      addService(service);
    }
  }

  void clearServices() {
    _selectedServices.clear();
    notifyListeners();
  }

  bool isServiceSelected(ServiceModel service) {
    return _selectedServices.any((s) => s.id == service.id);
  }

  void selectServices(List<ServiceModel> services) {
    _selectedServices.clear();
    _selectedServices.addAll(services);
    notifyListeners();
  }

  // ==================== TIME SLOT MANAGEMENT ====================
  Future<void> fetchAvailableTimeSlots({String? date}) async {
    if (_selectedBarber == null) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await _timeSlotService.getTimeSlotsByBarber(
        _selectedBarber!.id,
        date: date,
        isAvailable: true,
      );

      _availableTimeSlots = _timeSlotService.sortByTime(response.timeSlots);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void selectTimeSlot(TimeSlotModel timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    fetchAvailableTimeSlots(date: _formatDate(date));
  }

  void clearTimeSlot() {
    _selectedTimeSlot = null;
    notifyListeners();
  }

  // ==================== BOOKING CREATION ====================
  Future<BookingCreateResponse> createBooking() async {
    if (!canBook) {
      throw Exception('Vui lòng chọn đầy đủ thông tin');
    }

    _setLoading(true);
    _error = null;
    _lastBookingResponse = null;

    try {
      print(' Creating booking...');
      print('   Barber: ${_selectedBarber!.name}');
      print('   Services: ${_selectedServices.length}');
      print('   Time slot: ${_selectedTimeSlot!.displayText}');
      print('   Total price: $totalPrice');
      print('   Total duration: $totalDuration');

      // Lấy user ID từ AuthStorage
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        throw Exception('Vui lòng đăng nhập để đặt lịch');
      }

      // Tạo request cho API theo đúng model
      final request = BookingCreateRequest(
        userId: userId,
        timeSlotId: _selectedTimeSlot!.id,
        serviceIds: _selectedServices.map((s) => s.id).toList(),
        totalDurationMin: totalDuration,
        totalPrice: totalPrice,
        status: 'confirmed',
      );

      print(' Booking request: ${request.toJson()}');

      // Gọi API tạo booking thực tế
      final response = await _bookingService.createBooking(request);

      print('Booking created successfully!');
      print('   Booking ID: ${response.booking.id}');
      print('   Status: ${response.booking.status}');
      print('   Message: ${response.message}');

      // Lưu response
      _lastBookingResponse = response;

      // Reset form sau khi đặt lịch thành công
      _reset();
      try {
        final bookingTime = _parseBookingTime(response.booking);
        if (bookingTime != null) {
          await SimpleNotificationService.scheduleReminder(
            id: response.booking.id,
            time: bookingTime,
            title: '⏰ Nhắc lịch đặt',
            message: 'Còn 30 phút nữa đến lịch của bạn tại ${_selectedBarber?.name ?? "barber"}',
            minutesBefore: 30,
          );
        }
      } catch (e) {
        print('⚠️ Notification error: $e');
      }

      return response;

    } catch (e) {
      print(' Error creating booking: $e');
      _error = 'Không thể đặt lịch: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  Map<String, dynamic>? getRebookInfo(BookingModel booking) {
    try {
      // Lấy barber ID
      final barberId = booking.barberId;

      // Lấy service IDs từ booking.services
      final serviceIds = booking.services?.map((s) => s['id'] as int).toList() ?? [];

      if (barberId == null || serviceIds.isEmpty) {
        print(' Cannot rebook: missing barber or services');
        return null;
      }

      print(' Rebook info prepared:');
      print('   Barber ID: $barberId');
      print('   Service IDs: $serviceIds');

      return {
        'barberId': barberId,
        'serviceIds': serviceIds,
      };
    } catch (e) {
      print('❌ Error preparing rebook info: $e');
      return null;
    }
  }

  // ==================== HELPER METHODS ====================
  void _clearTimeSlots() {
    _availableTimeSlots.clear();
    _selectedTimeSlot = null;
    _selectedDate = null;
  }

  void _reset() {
    _selectedBarber = null;
    _selectedServices.clear();
    _availableTimeSlots.clear();
    _selectedTimeSlot = null;
    _selectedDate = null;
    _error = null;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Format giá tiền
  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  // Format thời gian
  String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $remainingMinutes phút';
      }
    }
  }
  void cancelBooking() {
    print(' Canceling booking...');
    _reset();
    print(' Booking canceled and form reset');
  }
  // Reset lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear last booking response
  void clearLastBooking() {
    _lastBookingResponse = null;
  }

  DateTime? _parseBookingTime(BookingModel booking) {
    try {
      if (booking.timeSlots != null) {
        final slotDate = booking.timeSlots!['slot_date'] as String?;
        final startTime = booking.timeSlots!['start_time'] as String?;

        if (slotDate != null && startTime != null) {
          final date = DateTime.parse(slotDate);
          final timeParts = startTime.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          return DateTime(date.year, date.month, date.day, hour, minute);
        }
      }
    } catch (e) {
      print('❌ Parse time error: $e');
    }
    return null;
  }
}