/// API Configuration
class ApiConfig {
  // ==================== BASE URLS ====================

  /// Development URL (local/test)
  static const String devBaseUrl = "http://192.168.1.42:8000";

  // /// Production URL (deploy lên server thật)
  // static const String prodBaseUrl = "https://api.yourdomain.com";

  /// Current base URL (đổi khi deploy)
  static const String baseUrl = devBaseUrl; // ← Change to prodBaseUrl when deploying

  // ==================== ENDPOINTS ====================

  /// Acne detection
  static const String acneDetect = "/acne/detect";
  static const String acneHistory = "/acne/history";
  static const String acneStats = "/acne/statistics";

  static const String hairstyleGenerate = "/api/v1/hairstyle/generate";
  static const String hairstyleStyles = "/api/v1/hairstyle/styles";
  static const String hairstyleAdvanced = "/api/v1/hairstyle/generate-advanced";
  static const String hairstyleCreateMask = "/api/v1/hairstyle/create-mask";
  static const String hairstyleMultiple = "/api/v1/hairstyle/generate-multiple";
  static const String hairstyleHealth = "/api/v1/hairstyle/health";
  // ==================== HELPERS ====================

  /// Get full URL
  static String getUrl(String endpoint) => '$baseUrl$endpoint';

  /// Timeout durations
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}