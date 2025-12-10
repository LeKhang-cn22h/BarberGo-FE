class ServiceEndpoint{
  /// GET /services/ - Lấy danh sách tất cả dịch vụ
  static const String serviceGetAll = "/services/";

  /// GET /services/{service_id} - Lấy thông tin chi tiết 1 dịch vụ
  static const String serviceGetById = "/services";

  /// GET /services/barber/{barber_id} - Lấy danh sách dịch vụ của 1 barber
  static const String serviceGetByBarber = "/services/barber";

}