import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerSignupHandler {
  final BuildContext context;
  final AppointmentViewModel viewModel;
  final GlobalKey<FormState> formKey;

  // Controllers
  final TextEditingController shopNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController openTimeController;
  final TextEditingController closeTimeController;
  final TextEditingController addressController;
  final TextEditingController detailAddressController;

  PartnerSignupHandler({
    required this.context,
    required this.viewModel,
    required this.formKey,
    required this.shopNameController,
    required this.phoneController,
    required this.emailController,
    required this.openTimeController,
    required this.closeTimeController,
    required this.addressController,
    required this.detailAddressController,
  });

  // ==================== INITIALIZATION ====================

  Future<void> prefillUserInfo() async {
    final email = await AuthStorage.getUserEmail();
    final phone = "0000000000000"; // TODO: Get from user profile

    emailController.text = email ?? '';
    phoneController.text = phone;
  }

  Future<bool> checkExistingAppointment() async {
    return await viewModel.hasPendingAppointment();
  }

  // ==================== TIME PICKER ====================

  Future<void> selectTime({
    required TextEditingController controller,
    required bool isOpenTime,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5B4B8A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      controller.text =
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  // ==================== FORM SUBMISSION ====================

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      _showErrorSnackBar('Vui lòng điền đầy đủ thông tin');
      return;
    }

    await _createAppointmentRequest();
  }

  Future<void> _createAppointmentRequest() async {
    final success = await viewModel.createAppointment(
      nameBarber: shopNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
    );

    if (success != null && context.mounted) {
      _showSuccessDialog();
    }
    // Lỗi đã được hiển thị trong ViewModel
  }

  // ==================== DIALOGS ====================

  void showExistingAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Yêu cầu đang chờ xử lý')),
          ],
        ),
        content: const Text(
          'Bạn đã có một yêu cầu đăng ký đối tác đang chờ xử lý.\n\n'
              'Vui lòng đợi đội ngũ Barber GO liên hệ với bạn trước khi gửi yêu cầu mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/AppointmentDetail');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4B8A),
            ),
            child: const Text('Xem yêu cầu'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'Đã gửi yêu cầu thành công!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Yêu cầu đăng ký đối tác của bạn đã được ghi nhận.\n\n'
                    'Đội ngũ Barber GO sẽ liên hệ tư vấn trong 24-48 giờ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.push('/AppointmentDetail');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF5B4B8A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xem yêu cầu',
                        style: TextStyle(
                          color: Color(0xFF5B4B8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4B8A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hoàn tất',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== VALIDATION ====================

  String? validateShopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên tiệm';
    }
    if (value.trim().length < 3) {
      return 'Tên tiệm phải có ít nhất 3 ký tự';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }
    return null;
  }

  String? validateDetailAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ cụ thể';
    }
    if (value.trim().length < 10) {
      return 'Địa chỉ cụ thể quá ngắn';
    }
    return null;
  }

  // ==================== HELPERS ====================

  void clearError() {
    viewModel.clearError();
  }

  void goBack() {
    context.pop();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}