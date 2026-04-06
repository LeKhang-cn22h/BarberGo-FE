import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioClient {
  static DioClient? _instance;
  late Dio dio;

  // Singleton
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(_RateLimitInterceptor());
  }
}

// ==================== RATE LIMIT INTERCEPTOR ====================

class _RateLimitInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    //  Kiểm tra status 429
    if (err.response?.statusCode == 429) {
      final retryAfter = _getRetryAfter(err.response);

      //  Hiển thị SnackBar TOÀN CỤC
      _showGlobalRateLimitSnackBar(retryAfter);

      //  Return error message đẹp
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: 'Quá nhiều yêu cầu. Vui lòng chờ $retryAfter giây.',
        ),
      );
    }

    // Pass other errors
    handler.next(err);
  }

  int _getRetryAfter(Response? response) {
    try {
      if (response?.data is Map) {
        final retryAfter = response?.data['retry_after'];
        if (retryAfter != null) {
          return int.parse(retryAfter.toString());
        }
      }
    } catch (_) {}
    return 60; // Default 60s
  }

  void _showGlobalRateLimitSnackBar(int seconds) {
    // Sử dụng GlobalKey để show SnackBar từ bất kỳ đâu
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quá nhiều yêu cầu. Vui lòng chờ $seconds giây.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: Duration(seconds: seconds),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}

// ==================== NAVIGATION SERVICE ====================
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}