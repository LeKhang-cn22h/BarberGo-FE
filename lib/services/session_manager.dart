import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionManager {
  static bool _isHandling = false;

  static Future<void> handleExpired(BuildContext? context) async {
    if (_isHandling) return;
    _isHandling = true;

    await AuthStorage.clearAll();

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      context.go(RouteNames.signin);
    }

    _isHandling = false;
  }
}