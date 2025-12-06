// lib/viewmodels/time_slot/time_slot_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:barbergofe/services/time_slot_service.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class TimeSlotViewModel extends ChangeNotifier {
  final TimeSlotService _timeSlotService = TimeSlotService();

  List<TimeSlotModel> _timeSlots = [];
  bool _isLoading = false;
  String? _error;

  List<TimeSlotModel> get timeSlots => _timeSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTimeSlotsByBarber(String barberId, {String? date}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _timeSlotService.getTimeSlotsByBarber(
        barberId,
        date: date,
        isAvailable: true,
      );
      _timeSlots = response.timeSlots;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}