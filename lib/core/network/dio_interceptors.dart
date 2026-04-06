
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class RateLimitInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 429) {
      final retryAfter = _getRetryAfter(err.response);
      final message = _getRateLimitMessage(err.response);

      _showRateLimitSnackBar(message, retryAfter);

      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: message,
        ),
      );
    }

    handler.next(err);
  }

  /// Lấy retry_after từ nhiều nguồn
  int _getRetryAfter(Response? response) {
    try {
      if (response?.data is Map) {
        // 1. Thử lấy từ field "retry_after"
        final retryAfter = response?.data['retry_after'];
        if (retryAfter != null) {
          return int.parse(retryAfter.toString());
        }

        // 2. Thử parse từ error message
        // "Rate limit exceeded: 1 per 1 minute" → 60 seconds
        final error = response?.data['error']?.toString();
        if (error != null) {
          final seconds = _parseSecondsFromError(error);
          if (seconds != null) return seconds;
        }
      }

      // 3. Thử lấy từ response header
      final retryAfterHeader = response?.headers['retry-after']?.first;
      if (retryAfterHeader != null) {
        return int.tryParse(retryAfterHeader) ?? 60;
      }
    } catch (_) {}

    // Default: 60 seconds
    return 60;
  }

  ///  Parse seconds từ error message
  /// "Rate limit exceeded: 5 per 1 minute" → 60
  /// "Rate limit exceeded: 10 per 5 minutes" → 300
  /// "Rate limit exceeded: 3 per 1 hour" → 3600
  int? _parseSecondsFromError(String error) {
    try {
      // Pattern: "X per Y minute/hour"
      final regex = RegExp(r'(\d+)\s+per\s+(\d+)\s+(minute|hour)s?');
      final match = regex.firstMatch(error.toLowerCase());

      if (match != null) {
        final number = int.parse(match.group(2)!);
        final unit = match.group(3)!;

        if (unit == 'minute') {
          return number * 60; // minutes to seconds
        } else if (unit == 'hour') {
          return number * 3600; // hours to seconds
        }
      }

      // Pattern 2: "5/minute" → 60 seconds
      final regex2 = RegExp(r'\d+/(minute|hour)');
      final match2 = regex2.firstMatch(error.toLowerCase());

      if (match2 != null) {
        final unit = match2.group(1)!;
        return unit == 'minute' ? 60 : 3600;
      }
    } catch (_) {}

    return null;
  }

  /// Lấy message từ response
  String _getRateLimitMessage(Response? response) {
    try {
      if (response?.data is Map) {
        // Thử các field thường gặp
        final message = response?.data['message'] ??
            response?.data['error'] ??
            response?.data['detail'];

        if (message != null) {
          return message.toString();
        }
      }
    } catch (_) {}

    return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
  }

  void _showRateLimitSnackBar(String message, int seconds) {
    final context = NavigationService.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quá nhiều yêu cầu',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Vui lòng chờ $seconds giây',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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