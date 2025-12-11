class ApiConfig {
  /// Development URL (local/test environment)
  static const String devBaseUrl = "http://192.168.1.101:8000";

  /// Production URL (deploy environment)
  static const String prodBaseUrl = "https://your-production-url.com";

  /// Current active base URL (change this when deploying)
  static const String baseUrl = devBaseUrl;
  // ==================== HELPER METHODS ====================

  /// Tạo full URL từ endpoint
  ///
  /// Example: getUrl("/users/") → "http://192.168.1.183:8000/users/"
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Tạo URL với ID
  ///
  /// Example: getUrlWithId("/users", "123")
  ///          → "http://192.168.1.183:8000/users/123"
  static String getUrlWithId(String endpoint, String id) {
    return '$baseUrl$endpoint/$id';
  }

  /// Tạo URL với ID và action
  ///
  /// Example: getUrlWithIdAndAction("/appointments", "123", "confirm")
  ///          → "http://192.168.1.183:8000/appointments/123/confirm"
  static String getUrlWithIdAndAction(String endpoint, String id, String action) {
    return '$baseUrl$endpoint/$id/$action';
  }
  // ==================== HTTP HEADERS ====================

  /// Tạo headers cho HTTP request
  ///
  /// Trả về headers mặc định với Content-Type: application/json
  /// Nếu có token, thêm Authorization: Bearer {token}
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Tạo headers cho upload file (multipart/form-data)
  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==================== TIMEOUT CONFIGURATION ====================

  /// Timeout cho request thông thường (30 giây)
  static const Duration timeout = Duration(seconds: 30);

  /// Timeout cho kết nối (15 giây)
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Timeout cho upload file (60 giây)
  static const Duration uploadTimeout = Duration(seconds: 60);
}