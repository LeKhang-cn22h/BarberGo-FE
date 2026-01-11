class BarberEndpoint{
  // GET /barbers/{id} - Lấy thông tin barber theo ID
  static const String barberGetById = "/barbers";

  /// GET /barbers/areas - Lấy danh sách khu vực có barber
  static const String barberGetAreas = "/barbers/areas";

  /// GET /barbers/area - Lấy barbers theo khu vực
  static const String barberGetByArea = "/barbers/area";

  /// GET /barbers/top - Lấy danh sách top barbers
  static const String barberGetTop = "/barbers/top";

  ///Get /barbers/location/{id}
  static const String barberUpdateLocation="/barbers/location";

  ///Lấy danh sách barbers của một user /user/{user_id}"
 static const String barberGetofUser ="/barbers/user";

 //cập nhật thông tin barber theo ID /{barber_id}
 static const String barberUpdateId="/barbers";


  //soft delete barber theo ID /{barber_id}/deactivate
  static const String barberDeactivateId="/barbers";

//delete barber theo ID /{barber_id}
  static const String barberDeleteId="/barbers";
}