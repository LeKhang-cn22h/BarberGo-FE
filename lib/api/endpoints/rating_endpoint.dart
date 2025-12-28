class RatingEndpoint{

  static const String baseRating ='/ratings';

  //tạo đánh giá mới
  static const String createRating = '$baseRating/';
  //lấy danh sách đánh giá
  static const String getRating = '$baseRating/';
  //lấy đánh giá theo id /ratings/{rating_id}
  static const String getRatingById = baseRating;
  //lấy danh sách đánh giá của 1 shop /barber/{Barberid}
  static const String getRatingByBarberId = '$baseRating/barber';
  //Lấy điểm trung bình và tổng số đánh giá của barber "/barber/{barber_id}/average"
  static const String getBarberAverage='$baseRating/barber';
  //    Lấy danh sách đánh giá của 1 user /user/{user_id}
  static const String getUserRating='$baseRating/user';
  //    Cập nhật chỉnh sửa đánh giá /{Ratingid}
  static const String updateRating=baseRating;
  //xóa đánh giá /{rating_id}
  static const String deleteRating=baseRating;
}