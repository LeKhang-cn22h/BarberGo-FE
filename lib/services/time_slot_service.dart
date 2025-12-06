import 'package:barbergofe/api/time_slot_api.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class TimeSlotService {
  final TimeSlotApi _timeSlotApi = TimeSlotApi();

  Future<GetTimeSlotsByBarberResponse> getTimeSlotsByBarber(
      String barberId, {
        String? date,
        bool? isAvailable,
      }) async {
    try {
      return await _timeSlotApi.getTimeSlotsByBarber(
        barberId,
        date: date,
        isAvailable: isAvailable,
      );
    } catch (e) {
      print('TimeSlotService - getTimeSlotsByBarber error: $e');
      rethrow;
    }
  }

  Future<GetAllTimeSlotsResponse> getAvailableTimeSlots({
    String? barberId,
    String? date,
  }) async {
    try {
      return await _timeSlotApi.getAvailableTimeSlots(
        barberId: barberId,
        date: date,
      );
    } catch (e) {
      print('TimeSlotService - getAvailableTimeSlots error: $e');
      rethrow;
    }
  }

  Future<TimeSlotModel> createTimeSlot(TimeSlotCreateRequest request) async {
    try {
      return await _timeSlotApi.createTimeSlot(request);
    } catch (e) {
      print('TimeSlotService - createTimeSlot error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  List<TimeSlotModel> filterByDate(List<TimeSlotModel> timeSlots, DateTime date) {
    return timeSlots.where((slot) {
      return slot.slotDate.year == date.year &&
          slot.slotDate.month == date.month &&
          slot.slotDate.day == date.day;
    }).toList();
  }

  List<TimeSlotModel> filterAvailable(List<TimeSlotModel> timeSlots) {
    return timeSlots.where((slot) => slot.isAvailable).toList();
  }

  List<TimeSlotModel> sortByTime(List<TimeSlotModel> timeSlots) {
    final sorted = List<TimeSlotModel>.from(timeSlots);
    sorted.sort((a, b) {
      final aTime = a.parseTime(a.startTime);
      final bTime = b.parseTime(b.startTime);
      return aTime.compareTo(bTime);
    });
    return sorted;
  }

  List<TimeSlotModel> getTimeSlotsForToday(List<TimeSlotModel> timeSlots) {
    final today = DateTime.now();
    return filterByDate(timeSlots, today);
  }

  List<TimeSlotModel> getTimeSlotsForTomorrow(List<TimeSlotModel> timeSlots) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return filterByDate(timeSlots, tomorrow);
  }

  List<DateTime> getAvailableDates(List<TimeSlotModel> timeSlots) {
    final dates = <DateTime>{};
    for (var slot in timeSlots) {
      if (slot.isAvailable) {
        dates.add(DateTime(slot.slotDate.year, slot.slotDate.month, slot.slotDate.day));
      }
    }
    return dates.toList()..sort();
  }

  bool isSlotAvailable(TimeSlotModel slot, List<TimeSlotModel> bookedSlots) {
    for (var booked in bookedSlots) {
      if (slot.isOverlapping(booked)) {
        return false;
      }
    }
    return true;
  }
}