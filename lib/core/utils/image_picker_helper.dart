import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'permission_helper.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // ==================== PICK FROM GALLERY ====================

  static Future<File?> pickFromGallery(BuildContext context) async {
    print('[IMAGE PICKER] Pick from gallery');

    // Request permission first
    final hasPermission = await PermissionHelper.requestPhotoLibraryPermission(context);

    if (!hasPermission) {
      print(' [IMAGE PICKER] Permission denied');
      return null;
    }

    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        print('ℹ [IMAGE PICKER] No image selected');
        return null;
      }

      print(' [IMAGE PICKER] Image selected: ${image.path}');

      // Return file directly (no crop)
      return File(image.path);

    } catch (e) {
      print(' [IMAGE PICKER] Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  // ==================== PICK FROM CAMERA (Optional) ====================

  static Future<File?> pickFromCamera(BuildContext context) async {
    print(' [IMAGE PICKER] Pick from camera');

    // Request permission
    final hasPermission = await PermissionHelper.requestCameraPermission(context);

    if (!hasPermission) {
      print(' [IMAGE PICKER] Camera permission denied');
      return null;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        print(' [IMAGE PICKER] No image captured');
        return null;
      }

      print(' [IMAGE PICKER] Image captured: ${image.path}');

      // Return file directly (no crop)
      return File(image.path);

    } catch (e) {
      print('[IMAGE PICKER] Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chụp ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  // ==================== GET IMAGE SIZE ====================

  static Future<Map<String, int>?> getImageSize(File imageFile) async {
    try {
      final decodedImage = await decodeImageFromList(
        await imageFile.readAsBytes(),
      );

      return {
        'width': decodedImage.width,
        'height': decodedImage.height,
      };
    } catch (e) {
      print(' [IMAGE PICKER] Get size error: $e');
      return null;
    }
  }
}