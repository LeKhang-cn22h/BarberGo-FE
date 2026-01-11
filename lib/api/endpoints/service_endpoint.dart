class ServiceEndpoint {
  // ==================== Create ====================

  /// POST /services/ - Tạo dịch vụ mới
  static const String serviceCreate = "/services/";

  // ==================== Read ====================

  /// GET /services/ - Lấy danh sách tất cả dịch vụ
  static const String serviceGetAll = "/services/";

  /// GET /services/{service_id} - Lấy thông tin chi tiết 1 dịch vụ
  static const String serviceGetById = "/services";

  /// GET /services/barber/{barber_id} - Lấy danh sách dịch vụ của 1 barber
  static const String serviceGetByBarber = "/services/barber";

  /// GET /services/pricerange/{barber_id} - Lấy khoảng giá của 1 barber
  static const String serviceGetPriceRange = "/services/pricerange";

  // ==================== Update ====================

  /// PUT /services/{service_id} - Cập nhật thông tin dịch vụ
  static const String serviceUpdate = "/services";

  // ==================== Delete / Restore ====================

  /// PATCH /services/{service_id}/delete - Xóa mềm dịch vụ
  static const String serviceDelete = "/services";

  /// PATCH /services/{service_id}/restore - Khôi phục dịch vụ
  static const String serviceRestore = "/services";

  /// PATCH /services/{service_id}/toggle-status - Bật/tắt trạng thái dịch vụ
  static const String serviceToggleStatus = "/services";
}
