class TimeSlotEndpoint{
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
}