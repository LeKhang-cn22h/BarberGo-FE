//chứa các hàm trợ giúp cho ứng dụng
class Logger {
  static void log(String tag, String message) {
    print("[$tag] $message");
  }

  static void error(String tag, String message) {
    print("[$tag] ERROR: $message");
  }
}
