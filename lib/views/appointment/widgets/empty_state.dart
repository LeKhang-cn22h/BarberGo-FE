import 'package:flutter/material.dart';

class EmptyAppointmentState extends StatelessWidget {
  final VoidCallback onRegisterNow;

  const EmptyAppointmentState({
    super.key,
    required this.onRegisterNow,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Chưa có yêu cầu đăng ký',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Bạn chưa gửi yêu cầu đăng ký đối tác nào. Hãy tạo yêu cầu để bắt đầu hợp tác với Barber GO.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRegisterNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4B8A),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'ĐĂNG KÝ NGAY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}