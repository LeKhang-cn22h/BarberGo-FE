import 'package:flutter/material.dart';

class ResultActionButtons extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const ResultActionButtons({
    super.key,
    required this.isSaved,
    required this.onSave,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaved ? null : onSave,
            icon: Icon(isSaved ? Icons.check : Icons.save),
            label: Text(isSaved ? 'Đã lưu' : 'Lưu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved ? Colors.green : Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home),
            label: const Text('Trang chủ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}