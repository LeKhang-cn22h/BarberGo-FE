import 'dart:convert';

// ==================== TimeSlot Base Model ====================
class TimeSlotModel {
  final int id;
  final String barberId;
  final DateTime slotDate;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlotModel({
    required this.id,
    required this.barberId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] ?? 0,
      barberId: json['barber_id']?.toString() ?? '',
      slotDate: json['slot_date'] != null
          ? DateTime.parse(json['slot_date'])
          : DateTime.now(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'slot_date': slotDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
    };
  }

  // ✅ THÊM METHOD FORMAT THỜI GIAN
  String _formatTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  // Helper methods
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay = DateTime(slotDate.year, slotDate.month, slotDate.day);

    if (slotDay == today) {
      return 'Hôm nay';
    } else if (slotDay == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else {
      return '${slotDate.day}/${slotDate.month}';
    }
  }

  // ✅ SỬA: Format thời gian chỉ lấy giờ:phút (bỏ giây)
  String get formattedTime {
    final start = _formatTimeString(startTime);
    final end = _formatTimeString(endTime);
    return '$start - $end';
  }

  String get displayText {
    return '$formattedDate, $formattedTime';
  }

  Duration get duration {
    final start = parseTime(startTime);
    final end = parseTime(endTime);
    return end.difference(start);
  }

  DateTime parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return DateTime(slotDate.year, slotDate.month, slotDate.day, hour, minute);
    }
    return DateTime(slotDate.year, slotDate.month, slotDate.day);
  }

  bool isOverlapping(TimeSlotModel other) {
    final thisStart = parseTime(startTime);
    final thisEnd = parseTime(endTime);
    final otherStart = parseTime(other.startTime);
    final otherEnd = parseTime(other.endTime);

    return thisStart.isBefore(otherEnd) && otherStart.isBefore(thisEnd);
  }

  TimeSlotModel copyWith({
    int? id,
    String? barberId,
    DateTime? slotDate,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  }) {
    return TimeSlotModel(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      slotDate: slotDate ?? this.slotDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

// ==================== TimeSlot Create Request ====================
class TimeSlotCreateRequest {
  final String barberId;
  final DateTime slotDate;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlotCreateRequest({
    required this.barberId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'barber_id': barberId,
      'slot_date': slotDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
    };
  }
}

// ==================== TimeSlot Bulk Create Request ====================
class TimeSlotBulkCreateRequest {
  final String barberId;
  final DateTime slotDate;
  final List<Map<String, String>> timeRanges;

  TimeSlotBulkCreateRequest({
    required this.barberId,
    required this.slotDate,
    required this.timeRanges,
  });

  Map<String, dynamic> toJson() {
    return {
      'barber_id': barberId,
      'slot_date': slotDate.toIso8601String().split('T')[0],
      'time_ranges': timeRanges,
    };
  }
}

// ==================== Get All TimeSlots Response ====================
class GetAllTimeSlotsResponse {
  final List<TimeSlotModel> timeSlots;

  GetAllTimeSlotsResponse({
    required this.timeSlots,
  });

  factory GetAllTimeSlotsResponse.fromJson(dynamic jsonResponse) {
    List<TimeSlotModel> timeSlotsList = [];

    if (jsonResponse is List) {
      timeSlotsList = jsonResponse
          .map<TimeSlotModel>((item) => TimeSlotModel.fromJson(item))
          .toList();
    } else if (jsonResponse is Map<String, dynamic>) {
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        timeSlotsList = (jsonResponse['data'] as List)
            .map<TimeSlotModel>((item) => TimeSlotModel.fromJson(item))
            .toList();
      }
    }

    return GetAllTimeSlotsResponse(timeSlots: timeSlotsList);
  }
}

// ==================== Get TimeSlots By Barber Response ====================
class GetTimeSlotsByBarberResponse {
  final List<TimeSlotModel> timeSlots;

  GetTimeSlotsByBarberResponse({
    required this.timeSlots,
  });

  factory GetTimeSlotsByBarberResponse.fromJson(dynamic jsonResponse) {
    List<TimeSlotModel> timeSlotsList = [];

    if (jsonResponse is List) {
      timeSlotsList = jsonResponse
          .map<TimeSlotModel>((item) => TimeSlotModel.fromJson(item))
          .toList();
    } else if (jsonResponse is Map<String, dynamic>) {
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        timeSlotsList = (jsonResponse['data'] as List)
            .map<TimeSlotModel>((item) => TimeSlotModel.fromJson(item))
            .toList();
      }
    }

    return GetTimeSlotsByBarberResponse(timeSlots: timeSlotsList);
  }
}