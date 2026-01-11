import 'package:flutter/material.dart';

// ==================== Booking Base Model ====================
class BookingModel {
  final int id;
  final String userId;
  final String status;
  final int timeSlotId;
  final int totalDurationMin;
  final int totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ⚠️ SỬA: Nested objects - KHỚP VỚI API
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? timeSlots;  // ← SỬA: time_slots (có s)
  final List<Map<String, dynamic>>? services;

  BookingModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.timeSlotId,
    required this.totalDurationMin,
    required this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.timeSlots,  // ← SỬA
    this.services,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      userId: json['user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'confirmed',
      timeSlotId: json['time_slot_id'] ?? 0,
      totalDurationMin: json['total_duration_min'] ?? 0,
      totalPrice: json['total_price'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['users'] is Map
          ? Map<String, dynamic>.from(json['users'])
          : null,

      // ⚠️ SỬA: Parse time_slots (có s)
      timeSlots: json['time_slots'] is Map
          ? Map<String, dynamic>.from(json['time_slots'])
          : null,

      services: json['services'] is List
          ? List<Map<String, dynamic>>.from(
          json['services'].map((x) => Map<String, dynamic>.from(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'time_slot_id': timeSlotId,
      'total_duration_min': totalDurationMin,
      'total_price': totalPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user,
      'time_slots': timeSlots,  // ← SỬA
      'services': services,
    };
  }

  // ==================== HELPER METHODS - SỬA LẠI ====================

  String get formattedPrice {
    return '${totalPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    )}đ';
  }

  String get formattedDuration {
    if (totalDurationMin < 60) {
      return '$totalDurationMin phút';
    } else {
      final hours = totalDurationMin ~/ 60;
      final minutes = totalDurationMin % 60;
      if (minutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $minutes phút';
      }
    }
  }

  String get formattedDate {
    // ⚠️ SỬA: Lấy từ time_slots.slot_date
    if (timeSlots != null && timeSlots!['slot_date'] != null) {
      try {
        final date = DateTime.parse(timeSlots!['slot_date']);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String get formattedTime {
    // ⚠️ SỬA: Lấy từ time_slots
    if (timeSlots != null) {
      final startTime = timeSlots!['start_time']?.toString() ?? '';
      final endTime = timeSlots!['end_time']?.toString() ?? '';
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        // Format từ "09:00:00" → "09:00"
        final start = startTime.substring(0, 5);
        final end = endTime.substring(0, 5);
        return '$start - $end';
      }
    }
    return '';
  }

  // ⚠️ SỬA: Lấy barber từ time_slots.barbers
  String get barberName {
    if (timeSlots != null && timeSlots!['barbers'] is Map) {
      return timeSlots!['barbers']['name']?.toString() ?? 'Chưa xác định';
    }
    return 'Chưa xác định';
  }

  // ⚠️ SỬA: Lấy barber ID
  String? get barberId {
    if (timeSlots != null && timeSlots!['barbers'] is Map) {
      return timeSlots!['barbers']['id']?.toString();
    }
    return null;
  }

  // ⚠️ SỬA: Lấy barber address
  String get barberAddress {
    if (timeSlots != null && timeSlots!['barbers'] is Map) {
      return timeSlots!['barbers']['address']?.toString() ?? '';
    }
    return '';
  }

  List<String> get serviceNames {
    if (services != null && services!.isNotEmpty) {
      return services!.map((s) => s['service_name']?.toString() ?? '').toList();
    }
    return [];
  }

  String get servicesSummary {
    final names = serviceNames;
    if (names.isEmpty) return 'Không có dịch vụ';
    if (names.length == 1) return names.first;
    return '${names.first} + ${names.length - 1} dịch vụ khác';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  bool get canCancel {
    return status.toLowerCase() == 'confirmed';
  }

  BookingModel copyWith({
    int? id,
    String? userId,
    String? status,
    int? timeSlotId,
    int? totalDurationMin,
    int? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
    Map<String, dynamic>? timeSlots,  // ← SỬA
    List<Map<String, dynamic>>? services,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      totalDurationMin: totalDurationMin ?? this.totalDurationMin,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      timeSlots: timeSlots ?? this.timeSlots,  // ← SỬA
      services: services ?? this.services,
    );
  }
}

// ==================== Booking Create Request ====================
class BookingCreateRequest {
  final String userId;
  final int timeSlotId;
  final List<int> serviceIds;
  final int totalDurationMin;
  final int totalPrice;
  final String status;

  BookingCreateRequest({
    required this.userId,
    required this.timeSlotId,
    required this.serviceIds,
    required this.totalDurationMin,
    required this.totalPrice,
    this.status = 'confirmed',
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'time_slot_id': timeSlotId,
      'service_ids': serviceIds,
      'total_duration_min': totalDurationMin,
      'total_price': totalPrice,
      'status': status,
    };
  }
}

// ==================== Get All Bookings Response ====================
class GetAllBookingsResponse {
  final List<BookingModel> bookings;

  GetAllBookingsResponse({
    required this.bookings,
  });

  factory GetAllBookingsResponse.fromJson(dynamic jsonResponse) {
    List<BookingModel> bookingsList = [];

    if (jsonResponse is List) {
      bookingsList = jsonResponse
          .map<BookingModel>((item) => BookingModel.fromJson(item))
          .toList();
    } else if (jsonResponse is Map<String, dynamic>) {
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        bookingsList = (jsonResponse['data'] as List)
            .map<BookingModel>((item) => BookingModel.fromJson(item))
            .toList();
      }
    }

    return GetAllBookingsResponse(bookings: bookingsList);
  }
}

// ==================== Booking Create Response ====================
class BookingCreateResponse {
  final BookingModel booking;
  final String message;

  BookingCreateResponse({
    required this.booking,
    required this.message,
  });

  factory BookingCreateResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreateResponse(
      booking: BookingModel.fromJson(json['data'] ?? json),
      message: json['message'] ?? 'Đặt lịch thành công',
    );
  }
}

// ==================== Booking Status Update Response ====================
class BookingStatusUpdateResponse {
  final BookingModel booking;
  final String message;

  BookingStatusUpdateResponse({
    required this.booking,
    required this.message,
  });

  factory BookingStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return BookingStatusUpdateResponse(
      booking: BookingModel.fromJson(json['data'] ?? json),
      message: json['message'] ?? 'Cập nhật trạng thái thành công',
    );
  }
}