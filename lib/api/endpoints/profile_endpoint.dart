class ProfileEndpoint{
  /// GET /users/ - Lấy danh sách tất cả users
  static const String userGetAll = "/users/";

  /// GET /users/{id} - Lấy thông tin user theo ID
  static const String userGetById = "/users";

  /// PUT /users/{id} - Cập nhật thông tin user
  static const String userUpdate = "/users";

  /// DELETE /users/{id} - Xóa user
  static const String userDelete = "/users";
}