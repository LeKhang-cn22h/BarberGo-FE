// ================== Logger.dart ==================
// Class Logger dùng để quản lý việc ghi log (in thông tin ra console).
// Giúp theo dõi trạng thái hoạt động, debug lỗi hoặc theo dõi luồng xử lý trong ứng dụng.

class Logger {
  // Ghi log thông thường
  static void log(String tag, String message) {
    print("[$tag] $message");
  }

  // Ghi log khi có lỗi (error)
  static void error(String tag, String message) {
    print("[$tag] ERROR: $message");
  }
}