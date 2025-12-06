import 'package:barbergofe/api/appointment_api.dart';
import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class AppointmentService {
  final AppointmentApi _api = AppointmentApi();

  // Tạo appointment mới (yêu cầu tư vấn)
  Future<AppointmentModel> createAppointment({
    required String nameBarber,
    required String phone,
    required String email,
  }) async {
    try {
      // Lấy user ID từ AuthStorage
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy token
      final token = await AuthStorage.getAccessToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      return await _api.createAppointment(
        userId: userId,
        nameBarber: nameBarber,
        phone: phone,
        email: email,
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Lấy appointments của user hiện tại
  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final token = await AuthStorage.getAccessToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      return await _api.getUserAppointments(
        userId: userId,
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Lấy appointment theo ID
  Future<AppointmentModel> getAppointmentById(String appointmentId) async {
    try {
      final token = await AuthStorage.getAccessToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      return await _api.getAppointmentById();
    } catch (e) {
      rethrow;
    }
  }

  // Kiểm tra xem user đã có appointment đang chờ chưa
  Future<bool> hasPendingAppointment() async {
    try {
      final appointments = await getMyAppointments();
      return appointments.any((appointment) => appointment.status == 'pending');
    } catch (e) {
      return false;
    }
  }

  // Lấy số lượng appointments theo trạng thái
  Future<Map<String, int>> getAppointmentStats() async {
    try {
      final appointments = await getMyAppointments();
      final stats = {
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
        'total': appointments.length,
      };

      for (var appointment in appointments) {
        stats[appointment.status] = (stats[appointment.status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      return {
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
        'total': 0,
      };
    }
  }
}
