// lib/models/appointment_model.dart
class AppointmentModel {
  final String id;
  final String userId;
  final String nameBarber;
  final String phone;
  final String email;
  final String status;
  final String? adminNote;
  final String? adminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.nameBarber,
    required this.phone,
    required this.email,
    required this.status,
    this.adminNote,
    this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      nameBarber: json['name_barber'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      adminNote: json['admin_note'],
      adminId: json['admin_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name_barber': nameBarber,
    'phone': phone,
    'email': email,
    'status': status,
    'admin_note': adminNote,
    'admin_id': adminId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

// ==================== Appointment Create Response ====================
class AppointmentCreateResponse {
  final bool success;
  final String message;
  final AppointmentModel? appointment;
  final int? statusCode;

  AppointmentCreateResponse({
    required this.success,
    required this.message,
    this.appointment,
    this.statusCode,
  });

  factory AppointmentCreateResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentCreateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      appointment: json['data'] != null ? AppointmentModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Appointment Get Response ====================
class AppointmentGetResponse {
  final bool success;
  final String? message;
  final List<AppointmentModel> appointments;
  final int? statusCode;

  AppointmentGetResponse({
    required this.success,
    this.message,
    required this.appointments,
    this.statusCode,
  });

  factory AppointmentGetResponse.fromJson(Map<String, dynamic> json) {
    List<AppointmentModel> list = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        list = (json['data'] as List)
            .map((e) => AppointmentModel.fromJson(e))
            .toList();
      }
    }

    return AppointmentGetResponse(
      success: json['success'] ?? false,
      message: json['message'],
      appointments: list,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Appointment Update Response ====================
class AppointmentUpdateResponse {
  final bool success;
  final String message;
  final AppointmentModel? appointment;
  final int? statusCode;

  AppointmentUpdateResponse({
    required this.success,
    required this.message,
    this.appointment,
    this.statusCode,
  });

  factory AppointmentUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      appointment: json['data'] != null ? AppointmentModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Appointment Delete Response ====================
class AppointmentDeleteResponse {
  final bool success;
  final String message;
  final int? statusCode;

  AppointmentDeleteResponse({
    required this.success,
    required this.message,
    this.statusCode,
  });

  factory AppointmentDeleteResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentDeleteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'],
    );
  }
}
