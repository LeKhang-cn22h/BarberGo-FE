class BookingEmdpoint{
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
}