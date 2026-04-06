import 'package:flutter/material.dart';

class InstructionOverlay extends StatelessWidget {
  const InstructionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Text(
              'Đặt mặt vào khung hình',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Chụp chính diện - Ánh sáng đủ',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
