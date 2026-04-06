import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onTap;

  const CaptureButton({
    super.key,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: isProcessing ? null : onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isProcessing ? Colors.grey : Colors.white,
            ),
            child: isProcessing
                ? const CircularProgressIndicator()
                : const Icon(Icons.camera_alt, size: 40),
          ),
        ),
      ),
    );
  }
}
