// ================== StringExtensions ==================
// Extension này giúp mở rộng class String để kiểm tra email và số điện thoại hợp lệ.
extension StringExtensions on String {

  // Kiểm tra xem chuỗi có phải là email hợp lệ không
  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  // Kiểm tra xem chuỗi có phải là số điện thoại hợp lệ không
  // (từ 9 đến 11 chữ số, chỉ chấp nhận ký tự số)
  bool get isValidPhone {
    final regex = RegExp(r'^\d{9,11}$');
    return regex.hasMatch(this);
  }
}


