import 'package:flutter/material.dart';
import 'package:barbergofe/services/time_slot_service.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class TimeSlotViewModel extends ChangeNotifier {
  final TimeSlotService _timeSlotService = TimeSlotService();

  // State
  List<TimeSlotModel> _timeSlots = [];
  List<TimeSlotModel> _availableTimeSlots = [];
  TimeSlotModel? _selectedTimeSlot;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TimeSlotModel> get timeSlots => _timeSlots;
  List<TimeSlotModel> get availableTimeSlots => _availableTimeSlots;
  TimeSlotModel? get selectedTimeSlot => _selectedTimeSlot;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTimeSlots => _timeSlots.isNotEmpty;
  bool get hasAvailableTimeSlots => _availableTimeSlots.isNotEmpty;

  // ==================== FETCH TIME SLOTS ====================

  /// Lấy time slots của barber theo ngày
  Future<void> fetchTimeSlotsByBarber(
      String barberId, {
        String? date,
        bool? isAvailable,
      }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _timeSlotService.getTimeSlotsByBarber(
        barberId,
        date: date,
        isAvailable: isAvailable,
      );

      _timeSlots = response.timeSlots;
      print(' Loaded ${_timeSlots.length} time slots for barber $barberId');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print(' Error fetching time slots: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy available time slots (có thể filter theo barber và ngày)
  Future<void> fetchAvailableTimeSlots({
    String? barberId,
    String? date,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _timeSlotService.getAvailableTimeSlots(
        barberId: barberId,
        date: date,
      );

      _availableTimeSlots = response.timeSlots;
      print(' Loaded ${_availableTimeSlots.length} available time slots');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error fetching available time slots: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== CREATE TIME SLOT ====================

  Future<bool> createTimeSlot(TimeSlotCreateRequest request) async {
    _setLoading(true);
    _error = null;

    try {
      final newSlot = await _timeSlotService.createTimeSlot(request);
      _timeSlots.add(newSlot);

      // Sort lại theo thời gian
      _timeSlots = _timeSlotService.sortByTime(_timeSlots);

      print(' Created time slot: ${newSlot.formattedTime}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(' Error creating time slot: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> updateTimeSlot(int timeSlotId, TimeSlotUpdateRequest request) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedSlot = await _timeSlotService.updateTimeSlot(timeSlotId, request);

      // Tìm và cập nhật trong danh sách
      final index = _timeSlots.indexWhere((slot) => slot.id == timeSlotId);
      if (index != -1) {
        _timeSlots[index] = updatedSlot;

        // Sort lại nếu thời gian thay đổi
        _timeSlots = _timeSlotService.sortByTime(_timeSlots);
      }

      print(' Updated time slot #$timeSlotId');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(' Error updating time slot: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> bulkCreateTimeSlots(TimeSlotBulkCreateRequest request) async {
    _setLoading(true);
    _error = null;

    try {
      final newSlots = await _timeSlotService.bulkCreateTimeSlots(request);

      // Thêm tất cả slots mới vào danh sách
      _timeSlots.addAll(newSlots);

      // Sort lại theo thời gian
      _timeSlots = _timeSlotService.sortByTime(_timeSlots);

      print('✅ Created ${newSlots.length} time slots');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error bulk creating time slots: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  //  Toggle availability
  Future<bool> toggleTimeSlotAvailability(int timeSlotId) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedSlot = await _timeSlotService.toggleTimeSlotAvailability(timeSlotId);

      // Cập nhật trong danh sách
      final index = _timeSlots.indexWhere((slot) => slot.id == timeSlotId);
      if (index != -1) {
        _timeSlots[index] = updatedSlot;
      }

      print(' Toggled availability for time slot #$timeSlotId');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(' Error toggling availability: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  //  Delete time slot
  Future<bool> deleteTimeSlot(int timeSlotId) async {
    _setLoading(true);
    _error = null;

    try {
      await _timeSlotService.deleteTimeSlot(timeSlotId);

      // Xóa khỏi danh sách
      _timeSlots.removeWhere((slot) => slot.id == timeSlotId);

      print(' Deleted time slot #$timeSlotId');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(' Error deleting time slot: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  // ==================== FILTER & HELPER METHODS ====================

  /// Filter time slots theo ngày
  List<TimeSlotModel> getTimeSlotsByDate(DateTime date) {
    return _timeSlotService.filterByDate(_timeSlots, date);
  }

  /// Lấy time slots cho hôm nay
  List<TimeSlotModel> getTodayTimeSlots() {
    return _timeSlotService.getTimeSlotsForToday(_timeSlots);
  }

  /// Lấy time slots cho ngày mai
  List<TimeSlotModel> getTomorrowTimeSlots() {
    return _timeSlotService.getTimeSlotsForTomorrow(_timeSlots);
  }

  /// Lấy danh sách ngày có time slots available
  List<DateTime> getAvailableDates() {
    return _timeSlotService.getAvailableDates(_timeSlots);
  }

  /// Chọn time slot
  void selectTimeSlot(TimeSlotModel? slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  /// Chọn ngày
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Clear selected time slot
  void clearSelection() {
    _selectedTimeSlot = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh(String barberId) async {
    await fetchTimeSlotsByBarber(barberId, isAvailable: true);
  }

  // ==================== PRIVATE METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _timeSlots.clear();
    _availableTimeSlots.clear();
    super.dispose();
  }
}