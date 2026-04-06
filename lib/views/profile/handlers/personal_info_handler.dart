import 'dart:io';
import 'package:barbergofe/core/utils/image_picker_helper.dart';
import 'package:barbergofe/viewmodels/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoHandler {
  final BuildContext context;
  final ProfileViewModel viewModel;

  PersonalInfoHandler({
    required this.context,
    required this.viewModel,
  });

  // ==================== DATA LOADING ====================

  Future<void> loadProfile() async {
    await viewModel.loadProfile();
  }

  // ==================== UPDATE NAME ====================

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) {
      _showErrorSnackBar('Tên không được để trống');
      return;
    }

    final success = await viewModel.updateName(newName);

    if (context.mounted) {
      if (success) {
        _showSuccessSnackBar(' Cập nhật tên thành công');
      } else {
        _showErrorSnackBar(viewModel.errorMessage ?? ' Cập nhật thất bại');
      }
    }
  }

  // ==================== UPDATE PHONE ====================

  Future<void> updatePhone(String newPhone) async {
    if (newPhone.trim().isEmpty) {
      _showErrorSnackBar('Số điện thoại không được để trống');
      return;
    }

    // Validate phone format
    if (!_isValidPhone(newPhone)) {
      _showErrorSnackBar('Số điện thoại không hợp lệ');
      return;
    }

    final success = await viewModel.updatePhone(newPhone);

    if (context.mounted) {
      if (success) {
        _showSuccessSnackBar(' Cập nhật số điện thoại thành công');
      } else {
        _showErrorSnackBar(viewModel.errorMessage ?? ' Cập nhật thất bại');
      }
    }
  }

  // ==================== UPDATE AVATAR ====================

  Future<void> updateAvatar() async {
    try {
      print(' [HANDLER] Pick image requested');

      final File? imageFile = await ImagePickerHelper.pickFromGallery(context);

      if (imageFile == null) {
        print(' [HANDLER] No image selected');
        return;
      }

      print('[HANDLER] Image selected: ${imageFile.path}');

      if (!context.mounted) return;

      final success = await viewModel.updateAvatar(imageFile);

      if (!context.mounted) return;

      if (success) {
        _showSuccessSnackBar(' Cập nhật ảnh đại diện thành công');
      } else {
        _showErrorSnackBar(
          viewModel.errorMessage ?? ' Cập nhật ảnh đại diện thất bại',
        );
      }
    } catch (e) {
      print(' [HANDLER] Error: $e');

      if (context.mounted) {
        _showErrorSnackBar('Lỗi: ${e.toString()}');
      }
    }
  }

  // ==================== DIALOGS ====================

  void showEditDialog({
    required String title,
    required String currentValue,
    required Future<void> Function(String) onSave,
    TextInputType? keyboardType,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Nhập $title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                Navigator.pop(dialogContext);
                await onSave(newValue);
              }
            },
            child: const Text(
              'Lưu',
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

  // ==================== NAVIGATION ====================

  void goBack() {
    context.pop();
  }

  // ==================== VALIDATION ====================

  bool _isValidPhone(String phone) {
    // Vietnamese phone number regex
    final phoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  // ==================== SNACKBAR HELPERS ====================

  void _showSuccessSnackBar(String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}