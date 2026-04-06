import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/routes/app_router.dart';
import 'package:barbergofe/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConfig {
  static const String devBaseUrl = "http://192.168.1.13:8000";
  static const String baseUrl = devBaseUrl;

  // ==================== HELPER METHODS ====================

  static String getUrl(String endpoint) => '$baseUrl$endpoint';
  static String getUrlWithId(String endpoint, dynamic id) => '$baseUrl$endpoint/$id';
  static String getUrlWithIdAndAction(String endpoint, dynamic id, String action) =>
      '$baseUrl$endpoint/$id/$action';

  // ==================== AUTO-REFRESH TOKEN ====================

  /// Kiểm tra token có hết hạn không (dựa vào JWT payload)
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode JWT payload
      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Refresh trước 5 phút để tránh race condition
      return expiryDate.isBefore(now.add(Duration(minutes: 5)));
    } catch (e) {
      print(' Error checking token expiry: $e');
      return true; // Nếu decode lỗi → coi như expired
    }
  }

  /// Refresh access token tự động
  static Future<String?> _refreshAccessToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      print(' No refresh token found');
      return null;
    }

    try {
      print(' Refreshing access token...');

      final response = await http.post(
        Uri.parse('$baseUrl/users/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access_token'] ?? data['accessToken'];
        final newRefreshToken = data['refresh_token'] ?? data['refreshToken'];

        if (newAccessToken != null) {
          // Lưu token mới vào storage
          await AuthStorage.saveAuthData(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            userId: await AuthStorage.getUserId() ?? '',
            email: await AuthStorage.getUserEmail() ?? '',
            fullName: await AuthStorage.getUserName() ?? '',
            role: await AuthStorage.getUserRole() ?? '',
          );

          print(' Token refreshed successfully');
          return newAccessToken;
        }
      } else {
        print(' Refresh token failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print(' Error refreshing token: $e');
    }

    return null;
  }

  // ==================== GET HEADERS WITH AUTO-REFRESH ====================

  static Future<Map<String, String>> getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Lấy token (ưu tiên token được truyền vào, nếu không thì lấy từ storage)
    String? accessToken = token ?? await AuthStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      // KIỂM TRA VÀ TỰ ĐỘNG REFRESH NẾU HẾT HẠN
      if (_isTokenExpired(accessToken)) {
        print(' Token expired, auto-refreshing...');
        final newToken = await _refreshAccessToken();

        if (newToken != null) {
          accessToken = newToken;
        } else {
          print(' Failed to refresh token - user may need to re-login');
          final ctx = AppRouter.router.routerDelegate.navigatorKey.currentContext;
          await SessionManager.handleExpired(ctx);
          throw Exception('Failed to refresh token');
        }
      }

      headers['Authorization'] = 'Bearer $accessToken';
    } else {
      print(' No access token available');
    }

    return headers;
  }

  /// Headers cho multipart (upload file)
  static Future<Map<String, String>> getMultipartHeaders({String? token}) async {
    final headers = <String, String>{};

    String? accessToken = token ?? await AuthStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      //  KIỂM TRA VÀ TỰ ĐỘNG REFRESH
      if (_isTokenExpired(accessToken)) {
        print(' Token expired, auto-refreshing...');
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          accessToken = newToken;
        }
      }
      else{
        print('No access token available');
        final ctx = AppRouter.router.routerDelegate.navigatorKey.currentContext;
        await SessionManager.handleExpired(ctx);
      }

      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  // ==================== TIMEOUT CONFIGURATION ====================

  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 60);
}