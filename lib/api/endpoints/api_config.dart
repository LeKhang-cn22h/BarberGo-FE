class ApiConfig {
  /// Development URL (local/test environment)
  static const String devBaseUrl = "http://192.168.1.70:8000";

  /// Production URL (deploy environment)
  static const String prodBaseUrl = "https://your-production-url.com";

  /// Current active base URL (change this when deploying)
  static const String baseUrl = devBaseUrl;

//endpoint auth
  /// POST /users/register - Đăng ký tài khoản mới
  static const String authRegister = "/users/register";

  /// POST /users/resend-confirmation - Gửi lại email xác nhận
  static const String authResendConfirmation = "/users/resend-confirmation";

  /// POST /users/login - Đăng nhập
  static const String authLogin = "/users/login";

  /// POST /users/forgot-password - Quên mật khẩu
  static const String authForgotPassword = "/users/forgot-password";

  /// POST /users/reset-password - Đặt lại mật khẩu
  static const String authResetPassword = "/users/reset-password";

  // ==================== USER ENDPOINTS ====================

  /// GET /users/ - Lấy danh sách tất cả users
  static const String userGetAll = "/users/";

  /// GET /users/{id} - Lấy thông tin user theo ID
  static const String userGetById = "/users";

  /// PUT /users/{id} - Cập nhật thông tin user
  static const String userUpdate = "/users";

  /// DELETE /users/{id} - Xóa user
  static const String userDelete = "/users";

  // ==================== BARBER ENDPOINTS ====================

  /// GET /barbers/{id} - Lấy thông tin barber theo ID
  static const String barberGetById = "/barbers";

  /// GET /barbers/areas - Lấy danh sách khu vực có barber
  static const String barberGetAreas = "/barbers/areas";

  /// GET /barbers/area - Lấy barbers theo khu vực
  static const String barberGetByArea = "/barbers/area";

  /// GET /barbers/top - Lấy danh sách top barbers
  static const String barberGetTop = "/barbers/top";

  // ==================== SERVICE ENDPOINTS ====================

  /// GET /services/ - Lấy danh sách tất cả dịch vụ
  static const String serviceGetAll = "/services/";

  /// GET /services/{service_id} - Lấy thông tin chi tiết 1 dịch vụ
  static const String serviceGetById = "/services";

  /// GET /services/barber/{barber_id} - Lấy danh sách dịch vụ của 1 barber
  static const String serviceGetByBarber = "/services/barber";

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

  /// POST /time-slots/bulk - Tạo nhiều time slots cùng lúc
  static const String timeSlotCreateBulk = "/time-slots/bulk";

  /// PUT /time-slots/{time_slot_id} - Cập nhật time slot
  static const String timeSlotUpdate = "/time-slots";

  /// PATCH /time-slots/{time_slot_id}/toggle - Bật/tắt trạng thái time slot
  static const String timeSlotToggle = "/time-slots";

  /// DELETE /time-slots/{time_slot_id} - Xóa time slot
  static const String timeSlotDelete = "/time-slots";

  // ==================== BOOKING ENDPOINTS ====================

  /// POST /bookings/ - Tạo booking mới
  static const String bookingCreate = "/bookings/";

  /// GET /bookings/ - Lấy tất cả bookings (admin only)
  static const String bookingGetAll = "/bookings/";

  /// GET /bookings/{booking_id} - Lấy chi tiết booking
  static const String bookingGetById = "/bookings";

  /// GET /bookings/user/{user_id} - Lấy bookings của user
  static const String bookingGetByUser = "/bookings/user";

  /// GET /bookings/barber/{barber_id} - Lấy bookings của barber
  static const String bookingGetByBarber = "/bookings/barber";

  /// GET /bookings/status/{status} - Lấy bookings theo trạng thái
  static const String bookingGetByStatus = "/bookings/status";

  /// PATCH /bookings/{booking_id}/status - Cập nhật trạng thái booking
  static const String bookingUpdateStatus = "/bookings";

  /// PATCH /bookings/{booking_id}/cancel - Hủy booking
  static const String bookingCancel = "/bookings";

  // ==================== APPOINTMENT ENDPOINTS ====================

  /// POST /appointments/ - Tạo appointment mới
  static const String appointmentCreate = "/appointments/";

  /// GET /appointments/ - Lấy tất cả appointments
  static const String appointmentGetAll = "/appointments/";

  /// GET /appointments/pending - Lấy appointments đang chờ
  static const String appointmentGetPending = "/appointments/pending";

  /// GET /appointments/{id} - Lấy chi tiết appointment
  static const String appointmentGetById = "/appointments";

  /// GET /appointments/user/{user_id} - Lấy appointments của user
  static const String appointmentGetByUser = "/appointments/user";

  /// GET /appointments/status/{status} - Lấy appointments theo trạng thái
  static const String appointmentGetByStatus = "/appointments/status";

  /// PUT /appointments/{id} - Cập nhật appointment
  static const String appointmentUpdate = "/appointments";

  /// PATCH /appointments/{id}/status - Cập nhật trạng thái appointment
  static const String appointmentUpdateStatus = "/appointments";

  /// PATCH /appointments/{id}/confirm - Xác nhận appointment
  static const String appointmentConfirm = "/appointments";

  /// PATCH /appointments/{id}/cancel - Hủy appointment
  static const String appointmentCancel = "/appointments";

  /// DELETE /appointments/{id} - Xóa appointment
  static const String appointmentDelete = "/appointments";

  // ==================== ACNE DETECTION ENDPOINTS ====================

  /// POST /acne/detect - Phát hiện mụn từ ảnh
  static const String acneDetect = "/acne/detect";

  /// GET /acne/history - Lấy lịch sử phát hiện mụn
  static const String acneHistory = "/acne/history";

  /// GET /acne/statistics - Lấy thống kê về mụn
  static const String acneStats = "/acne/statistics";

  // ==================== HAIRSTYLE AI ENDPOINTS ====================

  /// POST /api/v1/hairstyle/generate - Tạo kiểu tóc AI đơn giản
  static const String hairstyleGenerate = "/api/v1/hairstyle/generate";

  /// GET /api/v1/hairstyle/styles - Lấy danh sách các kiểu tóc có sẵn
  static const String hairstyleStyles = "/api/v1/hairstyle/styles";

  /// POST /api/v1/hairstyle/generate-advanced - Tạo kiểu tóc AI nâng cao
  static const String hairstyleAdvanced = "/api/v1/hairstyle/generate-advanced";

  /// POST /api/v1/hairstyle/create-mask - Tạo mask cho khuôn mặt
  static const String hairstyleCreateMask = "/api/v1/hairstyle/create-mask";

  /// POST /api/v1/hairstyle/generate-multiple - Tạo nhiều kiểu tóc cùng lúc
  static const String hairstyleMultiple = "/api/v1/hairstyle/generate-multiple";

  /// GET /api/v1/hairstyle/health - Kiểm tra trạng thái service
  static const String hairstyleHealth = "/api/v1/hairstyle/health";

  // ==================== HELPER METHODS ====================

  /// Tạo full URL từ endpoint
  ///
  /// Example: getUrl("/users/") → "http://192.168.1.183:8000/users/"
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Tạo URL với ID
  ///
  /// Example: getUrlWithId("/users", "123")
  ///          → "http://192.168.1.183:8000/users/123"
  static String getUrlWithId(String endpoint, String id) {
    return '$baseUrl$endpoint/$id';
  }

  /// Tạo URL với ID và action
  ///
  /// Example: getUrlWithIdAndAction("/appointments", "123", "confirm")
  ///          → "http://192.168.1.183:8000/appointments/123/confirm"
  static String getUrlWithIdAndAction(String endpoint, String id, String action) {
    return '$baseUrl$endpoint/$id/$action';
  }

  // ==================== USER HELPERS ====================

  /// GET /users/{id}
  static String getUserByIdUrl(String userId) {
    return getUrlWithId(userGetById, userId);
  }

  // ==================== BARBER HELPERS ====================

  /// GET /barbers/{id}
  static String getBarberByIdUrl(String barberId) {
    return getUrlWithId(barberGetById, barberId);
  }

  // ==================== SERVICE HELPERS ====================

  /// GET /services/{service_id}
  static String getServiceByIdUrl(String serviceId) {
    return getUrlWithId(serviceGetById, serviceId);
  }

  /// GET /services/barber/{barber_id}
  static String getServicesByBarberUrl(String barberId) {
    return getUrlWithId(serviceGetByBarber, barberId);
  }

  // ==================== TIME SLOT HELPERS ====================

  /// GET /time-slots/{time_slot_id}
  static String getTimeSlotByIdUrl(String timeSlotId) {
    return getUrlWithId(timeSlotGetById, timeSlotId);
  }

  /// GET /time-slots/barber/{barber_id}?slot_date=2024-01-01&is_available=true
  static String getTimeSlotsByBarberUrl(
      String barberId, {
        String? date,
        bool? isAvailable,
      }) {
    String url = getUrlWithId(timeSlotGetByBarber, barberId);

    final params = <String, String>{};
    if (date != null) params['slot_date'] = date;
    if (isAvailable != null) params['is_available'] = isAvailable.toString();

    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    return url;
  }

  /// GET /time-slots/available/list?barber_id=1&slot_date=2024-01-01
  static String getAvailableTimeSlotsUrl({
    String? barberId,
    String? date,
  }) {
    String url = getUrl(timeSlotGetAvailable);

    final params = <String, String>{};
    if (barberId != null) params['barber_id'] = barberId;
    if (date != null) params['slot_date'] = date;

    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    return url;
  }

  /// PUT /time-slots/{time_slot_id}
  static String getTimeSlotUpdateUrl(String timeSlotId) {
    return getUrlWithId(timeSlotUpdate, timeSlotId);
  }

  /// PATCH /time-slots/{time_slot_id}/toggle
  static String getTimeSlotToggleUrl(String timeSlotId) {
    return getUrlWithIdAndAction(timeSlotToggle, timeSlotId, 'toggle');
  }

  /// DELETE /time-slots/{time_slot_id}
  static String getTimeSlotDeleteUrl(String timeSlotId) {
    return getUrlWithId(timeSlotDelete, timeSlotId);
  }

  // ==================== BOOKING HELPERS ====================

  /// GET /bookings/{booking_id}
  static String getBookingByIdUrl(String bookingId) {
    return getUrlWithId(bookingGetById, bookingId);
  }

  /// GET /bookings/user/{user_id}
  static String getBookingsByUserUrl(String userId) {
    return getUrlWithId(bookingGetByUser, userId);
  }

  /// GET /bookings/barber/{barber_id}
  static String getBookingsByBarberUrl(String barberId) {
    return getUrlWithId(bookingGetByBarber, barberId);
  }

  /// GET /bookings/status/{status}
  static String getBookingsByStatusUrl(String status) {
    return getUrlWithId(bookingGetByStatus, status);
  }

  /// PATCH /bookings/{booking_id}/status
  static String getBookingStatusUpdateUrl(String bookingId) {
    return getUrlWithIdAndAction(bookingUpdateStatus, bookingId, 'status');
  }

  /// PATCH /bookings/{booking_id}/cancel
  static String getBookingCancelUrl(String bookingId) {
    return getUrlWithIdAndAction(bookingCancel, bookingId, 'cancel');
  }

  // ==================== APPOINTMENT HELPERS ====================

  /// GET /appointments/{id}
  static String getAppointmentByIdUrl(String appointmentId) {
    return getUrlWithId(appointmentGetById, appointmentId);
  }

  /// GET /appointments/user/{user_id}
  static String getAppointmentsByUserUrl(String userId) {
    return getUrlWithId(appointmentGetByUser, userId);
  }

  /// GET /appointments/status/{status}
  static String getAppointmentsByStatusUrl(String status) {
    return getUrlWithId(appointmentGetByStatus, status);
  }

  /// PUT /appointments/{id}
  static String getAppointmentUpdateUrl(String appointmentId) {
    return getUrlWithId(appointmentUpdate, appointmentId);
  }

  /// PATCH /appointments/{id}/status
  static String getAppointmentStatusUpdateUrl(String appointmentId) {
    return getUrlWithIdAndAction(appointmentUpdateStatus, appointmentId, 'status');
  }

  /// PATCH /appointments/{id}/confirm
  static String getAppointmentConfirmUrl(String appointmentId) {
    return getUrlWithIdAndAction(appointmentConfirm, appointmentId, 'confirm');
  }

  /// PATCH /appointments/{id}/cancel
  static String getAppointmentCancelUrl(String appointmentId) {
    return getUrlWithIdAndAction(appointmentCancel, appointmentId, 'cancel');
  }

  /// DELETE /appointments/{id}
  static String getAppointmentDeleteUrl(String appointmentId) {
    return getUrlWithId(appointmentDelete, appointmentId);
  }

  // ==================== HTTP HEADERS ====================

  /// Tạo headers cho HTTP request
  ///
  /// Trả về headers mặc định với Content-Type: application/json
  /// Nếu có token, thêm Authorization: Bearer {token}
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Tạo headers cho upload file (multipart/form-data)
  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==================== TIMEOUT CONFIGURATION ====================

  /// Timeout cho request thông thường (30 giây)
  static const Duration timeout = Duration(seconds: 30);

  /// Timeout cho kết nối (15 giây)
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Timeout cho upload file (60 giây)
  static const Duration uploadTimeout = Duration(seconds: 60);
}