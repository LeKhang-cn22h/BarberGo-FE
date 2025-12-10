class AppointmentEndpoint{
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
}