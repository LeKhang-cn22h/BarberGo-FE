/// API Configuration
class ApiConfig {
  // ==================== BASE URLS ====================

  /// Development URL (local/test)
  static const String devBaseUrl = "http://10.197.139.243:8000";

  // /// Production URL (deploy lên server thật)
  // static const String prodBaseUrl = "https://api.yourdomain.com";

  /// Current base URL (đổi khi deploy)
  static const String baseUrl = devBaseUrl; // ← Change to prodBaseUrl when deploying

  // ==================== ENDPOINTS ====================

  /// Acne detection
  static const String acneDetect = "/acne/detect";
  static const String acneHistory = "/acne/history";
  static const String acneStats = "/acne/statistics";

  ///auth
  static const String authRegister= "/users/register";
  static const String authResent= "/users/resend-confirmation";
  static const String authLogin = "/users/login";
  static const String authForgot ="/users/forgot-password";
  static const String authReset = "/users/reset-password";

  /// GET /users/
  static const String usersList = "/users/";

  /// GET /users/{id}
  static const String usersGetById = "/users";

  /// PUT /users/{id}
  static const String usersUpdate = "/users";

  /// DELETE /users/{id}
  static const String usersDelete = "/users";

  static const String appointmentCreate = "/appointments/";
  static const String appointmentGetAll = "/appointments/";
  static const String appointmentGetPending = "/appointments/pending";
  static const String appointmentGetById = "/appointments"; // + /{id}
  static const String appointmentGetByUser = "/appointments/user"; // + /{user_id}
  static const String appointmentGetByStatus = "/appointments/status"; // + /{status}
  static const String appointmentUpdate = "/appointments"; // + /{id}
  static const String appointmentUpdateStatus = "/appointments"; // + /{id}/status
  static const String appointmentConfirm = "/appointments"; // + /{id}/confirm
  static const String appointmentCancel = "/appointments"; // + /{id}/cancel
  static const String appointmentDelete = "/appointments"; // + /{id}

  static const String barberarea="/barbers/areas";
  static const String barberareafocus="/barbers/area";
  static const String barbertop="/barbers/top";

// ==================== SERVICE ENDPOINTS ====================

  /// GET /services/ - Lấy danh sách tất cả dịch vụ
  static const String serviceGetAll = "/services/";

  /// GET /services/{service_id} - Lấy thông tin chi tiết 1 dịch vụ
  static const String serviceGetById = "/services";

  /// GET /services/barber/{barber_id} - Lấy danh sách dịch vụ của 1 barber
  static const String serviceGetByBarber = "/services/barber";
  static const String barberGetById = "/barbers";

  // ==================== TIME SLOT ENDPOINTS ====================

  /// GET /time-slots/ - Lấy tất cả time slots
  static const String timeSlotGetAll = "/time-slots/";

  /// GET /time-slots/{time_slot_id} - Lấy thông tin chi tiết 1 time slot
  static const String timeSlotGetById = "/time-slots";

  /// GET /time-slots/barber/{barber_id} - Lấy time slots của barber
  static const String timeSlotGetByBarber = "/time-slots/barber";

  /// GET /time-slots/available/list - Lấy các time slots còn trống
  static const String timeSlotGetAvailable = "/time-slots/available/list";

  /// POST /time-slots/ - Tạo time slot mới
  static const String timeSlotCreate = "/time-slots/";

  /// POST /time-slots/bulk - Tạo nhiều time slots
  static const String timeSlotCreateBulk = "/time-slots/bulk";

  /// PUT /time-slots/{time_slot_id} - Cập nhật time slot
  static const String timeSlotUpdate = "/time-slots";

  /// PATCH /time-slots/{time_slot_id}/toggle - Chuyển đổi trạng thái
  static const String timeSlotToggle = "/time-slots";

  /// DELETE /time-slots/{time_slot_id} - Xóa time slot
  static const String timeSlotDelete = "/time-slots";

  // ... (các endpoints khác giữ nguyên) ...

  // ==================== HELPERS ====================

  /// Get time slot URL với ID
  static String getTimeSlotUrlWithId(String timeSlotId) {
    return '$baseUrl$timeSlotGetById/$timeSlotId';
  }

  /// Get time slots by barber URL
  static String getTimeSlotsByBarberUrl(String barberId, {String? date, bool? isAvailable}) {
    String url = '$baseUrl$timeSlotGetByBarber/$barberId';

    final params = <String, String>{};
    if (date != null) params['slot_date'] = date;
    if (isAvailable != null) params['is_available'] = isAvailable.toString();

    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    return url;
  }
  static String getBarberUrlWithId(String barberId) {
    return getUrlWithId(barberGetById, barberId);
  }
  /// Get available time slots URL
  static String getAvailableTimeSlotsUrl({String? barberId, String? date}) {
    String url = '$baseUrl$timeSlotGetAvailable';

    final params = <String, String>{};
    if (barberId != null) params['barber_id'] = barberId;
    if (date != null) params['slot_date'] = date;

    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    return url;
  }
  // ==================== BOOKING ENDPOINTS ====================

  /// POST /bookings/ - Tạo booking mới
  static const String bookingCreate = "/bookings/";

  /// GET /bookings/ - Lấy tất cả bookings (admin)
  static const String bookingGetAll = "/bookings/";

  /// GET /bookings/status/{status} - Lấy bookings theo status
  static const String bookingGetByStatus = "/bookings/status";

  /// GET /bookings/user/{user_id} - Lấy bookings của user
  static const String bookingGetByUser = "/bookings/user";

  /// GET /bookings/barber/{barber_id} - Lấy bookings của barber
  static const String bookingGetByBarber = "/bookings/barber";

  /// GET /bookings/{booking_id} - Lấy chi tiết booking
  static const String bookingGetById = "/bookings";

  /// PATCH /bookings/{booking_id}/status - Cập nhật status
  static const String bookingUpdateStatus = "/bookings";

  /// PATCH /bookings/{booking_id}/cancel - Hủy booking
  static const String bookingCancel = "/bookings";

  // ... (các endpoints khác giữ nguyên) ...

  // ==================== BOOKING HELPERS ====================

  /// Get booking by ID URL
  static String getBookingUrlWithId(String bookingId) {
    return '$baseUrl$bookingGetById/$bookingId';
  }

  /// Get bookings by user URL
  static String getBookingsByUserUrl(String userId) {
    return '$baseUrl$bookingGetByUser/$userId';
  }

  /// Get bookings by status URL
  static String getBookingsByStatusUrl(String status) {
    return '$baseUrl$bookingGetByStatus/$status';
  }

  /// Get bookings by barber URL
  static String getBookingsByBarberUrl(String barberId) {
    return '$baseUrl$bookingGetByBarber/$barberId';
  }

  /// Update booking status URL
  static String getBookingStatusUpdateUrl(String bookingId) {
    return '$baseUrl$bookingUpdateStatus/$bookingId/status';
  }

  /// Cancel booking URL
  static String getBookingCancelUrl(String bookingId) {
    return '$baseUrl$bookingCancel/$bookingId/cancel';
  }

  // ==================== HELPERS ====================

  /// Get full URL
  static String getUrl(String endpoint) => '$baseUrl$endpoint';

  static String getUrlWithId(String endpoint, String id) {
    return '$baseUrl$endpoint/$id';
  }
  /// Get service URL with service ID
  static String getServiceUrlWithId(String serviceId) {
    return getUrlWithId(serviceGetById, serviceId);
  }

  /// Get services by barber URL
  static String getServiceByBarberUrl(String barberId) {
    return getUrlWithId(serviceGetByBarber, barberId);
  }

  //     getUrlWithId("/users/profile", "123")
  //     → "http://192.168.1.11:8000/users/profile/123"

  static Map<String, String> getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  /// Timeout durations
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}