class AcneEndpoint{
  static const String acneDetect="/acne/detect";
  static const String acneHistory="/acne/history";
  static const String acneStats="/acne/statistics";
  static const String hairStyleGenerate = "/api/v1/hairstyle/styles";
  /// POST /api/v1/hairstyle/generate - Tạo kiểu tóc AI đơn giản
  static const String hairstyleGenerate = "/api/v1/hairstyle/generate";

  /// GET /api/v1/hairstyle/styles - Lấy danh sách các kiểu tóc có sẵn
  static const String hairstyleStyles = "/api/v1/hairstyle/styles";

  /// POST /api/v1/hairstyle/generate-advanced - Tạo kiểu tóc AI nâng cao
  static const String hairstyleAdvanced = "/api/v1/hairstyle/generate-advanced";

  /// POST /api/v1/hairstyle/create-mask - Tạo mask cho khuôn mặt
  static const String hairstyleCreateMask = "/api/v1/hairstyle/create-mask";

  /// POST /api/v1/hairstyle/generate-multiple - Tạo nhiều kiểu tóc cùng lúc
  static const String hairstyleMultiple = "/api/v1/hairstyle/generate-multiple";

  /// GET /api/v1/hairstyle/health - Kiểm tra trạng thái service
  static const String hairstyleHealth = "/api/v1/hairstyle/health";

}