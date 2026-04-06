import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {

  // ==================== CHECK & REQUEST PHOTO LIBRARY ====================

  static Future<bool> requestPhotoLibraryPermission(BuildContext context) async {
    print(' [PERMISSION] Checking photo library permission...');

    // Check current status
    PermissionStatus status = await Permission.photos.status;

    // If already granted
    if (status.isGranted) {
      print(' [PERMISSION] Photo library already granted');
      return true;
    }

    // If denied permanently
    if (status.isPermanentlyDenied) {
      print('️ [PERMISSION] Photo library permanently denied');
      _showSettingsDialog(
        context,
        title: 'Quyền truy cập thư viện ảnh',
        message: 'Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt để tiếp tục.',
      );
      return false;
    }

    // Request permission
    print('[PERMISSION] Requesting photo library permission...');
    status = await Permission.photos.request();

    if (status.isGranted) {
      print(' [PERMISSION] Photo library granted');
      return true;
    } else if (status.isDenied) {
      print(' [PERMISSION] Photo library denied');
      _showPermissionDeniedDialog(
        context,
        title: 'Quyền bị từ chối',
        message: 'Bạn cần cấp quyền truy cập thư viện ảnh để chọn ảnh đại diện.',
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      print(' [PERMISSION] Photo library permanently denied');
      _showSettingsDialog(
        context,
        title: 'Quyền truy cập thư viện ảnh',
        message: 'Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt.',
      );
      return false;
    }

    return false;
  }

  // ==================== CHECK & REQUEST CAMERA ====================

  static Future<bool> requestCameraPermission(BuildContext context) async {
    print(' [PERMISSION] Checking camera permission...');

    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      print(' [PERMISSION] Camera already granted');
      return true;
    }

    if (status.isPermanentlyDenied) {
      print(' [PERMISSION] Camera permanently denied');
      _showSettingsDialog(
        context,
        title: 'Quyền truy cập camera',
        message: 'Vui lòng cấp quyền truy cập camera trong Cài đặt.',
      );
      return false;
    }

    print('[PERMISSION] Requesting camera permission...');
    status = await Permission.camera.request();

    if (status.isGranted) {
      print(' [PERMISSION] Camera granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        title: 'Quyền truy cập camera',
        message: 'Vui lòng cấp quyền truy cập camera trong Cài đặt.',
      );
      return false;
    }

    return false;
  }

  // ==================== CHECK & REQUEST LOCATION ====================

  static Future<bool> requestLocationPermission(BuildContext context) async {
    print(' [PERMISSION] Checking location permission...');

    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      print(' [PERMISSION] Location already granted');
      return true;
    }

    if (status.isPermanentlyDenied) {
      print('️ [PERMISSION] Location permanently denied');
      _showSettingsDialog(
        context,
        title: 'Quyền truy cập vị trí',
        message: 'Vui lòng cấp quyền truy cập vị trí trong Cài đặt để tìm salon gần bạn.',
      );
      return false;
    }

    print(' [PERMISSION] Requesting location permission...');
    status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      print(' [PERMISSION] Location granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        title: 'Quyền truy cập vị trí',
        message: 'Vui lòng cấp quyền truy cập vị trí trong Cài đặt.',
      );
      return false;
    }

    return false;
  }

  // ==================== SHOW PERMISSION DENIED DIALOG ====================

  static void _showPermissionDeniedDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // ==================== SHOW SETTINGS DIALOG ====================

  static void _showSettingsDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF5B4B8A)),
            SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              openAppSettings(); // Mở Settings app
            },
            child: Text(
              'Mở Cài đặt',
              style: TextStyle(
                color: Color(0xFF5B4B8A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}