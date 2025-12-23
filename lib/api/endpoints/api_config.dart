import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiConfig {
  static const String devBaseUrl = "http://192.168.1.65:8000";
  static const String prodBaseUrl = "https://your-production-url.com";
  static const String baseUrl = devBaseUrl;

  // ==================== HELPER METHODS ====================

  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static String getUrlWithId(String endpoint, String id) {
    return '$baseUrl$endpoint/$id';
  }

  static String getUrlWithIdAndAction(String endpoint, String id, String action) {
    return '$baseUrl$endpoint/$id/$action';
  }

  // ==================== HTTP HEADERS (ĐÃ CẬP NHẬT) ====================

  /// Tạo headers với token tự động refresh
  static Future<Map<String, String>> getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    //  Tự động lấy token mới nhất từ Supabase
    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Kiểm tra token sắp hết hạn (trước 5 phút)
        final expiresAt = session.expiresAt;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        if (expiresAt != null && expiresAt - now < 300) {
          print(' Token sắp hết hạn, đang refresh...');
          final refreshResponse = await Supabase.instance.client.auth.refreshSession();

          if (refreshResponse.session != null) {
            // Lưu token mới
            await AuthStorage.saveAuthData(
              accessToken: refreshResponse.session!.accessToken,
              refreshToken: refreshResponse.session!.refreshToken ?? '',
              userId: refreshResponse.session!.user.id,
              email: refreshResponse.session!.user.email ?? '',
              fullName: refreshResponse.session!.user.userMetadata?['full_name'] ?? '',
            );
            headers['Authorization'] = 'Bearer ${refreshResponse.session!.accessToken}';
            print('Token đã được refresh');
          }
        } else {
          // Token còn hạn, dùng luôn
          headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
      } else if (token != null && token.isNotEmpty) {
        // Fallback: dùng token được truyền vào
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('⚠Error getting token: $e');
      // Nếu có lỗi, dùng token được truyền vào
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Tạo headers cho upload file
  static Future<Map<String, String>> getMultipartHeaders({String? token}) async {
    final headers = <String, String>{};

    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        final expiresAt = session.expiresAt;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        if (expiresAt != null && expiresAt - now < 300) {
          final refreshResponse = await Supabase.instance.client.auth.refreshSession();
          if (refreshResponse.session != null) {
            await AuthStorage.saveAuthData(
              accessToken: refreshResponse.session!.accessToken,
              refreshToken: refreshResponse.session!.refreshToken ?? '',
              userId: refreshResponse.session!.user.id,
              email: refreshResponse.session!.user.email ?? '',
              fullName: refreshResponse.session!.user.userMetadata?['full_name'] ?? '',
            );
            headers['Authorization'] = 'Bearer ${refreshResponse.session!.accessToken}';
          }
        } else {
          headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
      } else if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print(' Error getting token: $e');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ==================== TIMEOUT CONFIGURATION ====================

  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 60);
}