// lib/viewmodels/appointment/appointment_viewmodel.dart
import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:barbergofe/services/appointment_service.dart';
import 'package:flutter/material.dart';

class AppointmentViewModel with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointments => _appointments;

  AppointmentModel? _currentAppointment;
  AppointmentModel? get currentAppointment => _currentAppointment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, int> _stats = {};
  Map<String, int> get stats => _stats;

  // Load appointments của user
  Future<void> loadAppointments() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _appointments = await _service.getMyAppointments();
      _stats = await _service.getAppointmentStats();
    } catch (e) {
      _errorMessage = 'Không tải được danh sách yêu cầu';
      print('Error loading appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo appointment mới - FIXED: return AppointmentModel thay vì bool
  Future<AppointmentModel?> createAppointment({
    required String nameBarber,
    required String phone,
    required String email,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Tạo appointment mới
      final appointment = await _service.createAppointment(
        nameBarber: nameBarber,
        phone: phone,
        email: email,
      );

      // Refresh danh sách appointments
      await loadAppointments();

      return appointment;
    } catch (e) {
      _errorMessage = 'Không thể tạo yêu cầu: $e';
      print('Error creating appointment: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load appointment detail theo ID
  Future<AppointmentModel?> loadAppointmentDetail(String appointmentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentAppointment = await _service.getAppointmentById(appointmentId);
      return _currentAppointment;
    } catch (e) {
      _errorMessage = 'Không tải được chi tiết yêu cầu: $e';
      print('Error loading appointment detail: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear current appointment
  void clearCurrentAppointment() {
    _currentAppointment = null;
    notifyListeners();
  }

  // Lọc appointments theo status
  List<AppointmentModel> getAppointmentsByStatus(String status) {
    return _appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }

  // Kiểm tra có appointment pending không
  Future<bool> hasPendingAppointment() async {
    try {
      return await _service.hasPendingAppointment();
    } catch (e) {
      print('Error checking pending appointment: $e');
      return false;
    }
  }

  // Lấy appointment theo ID (từ cache)
  AppointmentModel? getAppointmentById(String appointmentId) {
    return _appointments.firstWhere(
          (appointment) => appointment.id == appointmentId,
      orElse: () => _currentAppointment!,
    );
  }
}