import 'package:flutter/material.dart';
import 'package:barbergofe/core/constants/color.dart';

class ConfirmButton extends StatelessWidget {
  final bool canConfirm;
  final bool isLoading;
  final String? error;
  final VoidCallback onConfirm;

  const ConfirmButton({
    super.key,
    required this.canConfirm,
    required this.isLoading,
    this.error,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canConfirm && !isLoading ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canConfirm ? AppColors.primary : Colors.grey,
              foregroundColor: AppColors.textPrimaryLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Xác nhận đặt lịch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}