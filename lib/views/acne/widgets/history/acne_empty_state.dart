import 'package:flutter/material.dart';

class AcneEmptyState extends StatelessWidget {
  final VoidCallback onAnalyze;

  const AcneEmptyState({
    super.key,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Chưa có kết quả nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bắt đầu phân tích mụn để xem lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAnalyze,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Phân tích ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}