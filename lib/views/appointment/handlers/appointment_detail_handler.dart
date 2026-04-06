import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailHandler {
  final BuildContext context;
  final AppointmentViewModel viewModel;

  AppointmentDetailHandler({
    required this.context,
    required this.viewModel,
  });

  // ==================== DATA LOADING ====================

  Future<void> loadAppointments() async {
    await viewModel.loadAppointments();
  }

  // ==================== ACTIONS ====================

  Future<void> cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await _showCancelConfirmation();

    if (confirmed != true || !context.mounted) return;

    // TODO
    // final success = await viewModel.cancelAppointment(appointment.id);

    // if (context.mounted) {
    //   _showSnackBar(
    //     success ? ' Đã hủy yêu cầu thành công' : ' Hủy yêu cầu thất bại',
    //     success,
    //   );
    //
    //   if (success) await loadAppointments();
    // }
  }

  Future<bool?> _showCancelConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Xác nhận hủy'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn hủy yêu cầu này không?\n\n'
              'Sau khi hủy, bạn sẽ không thể khôi phục lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Có, hủy yêu cầu'),
          ),
        ],
      ),
    );
  }

  // ==================== CLIPBOARD ====================

  void copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Đã sao chép $label'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // ==================== NAVIGATION ====================

  void navigateToPartnerSignUpForm() {
    context.push('/PartnerSignUpForm');
  }

  void goBack() {
    context.pop();
  }

  // ==================== HELPERS ====================

  void _showSnackBar(String message, bool isSuccess) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}