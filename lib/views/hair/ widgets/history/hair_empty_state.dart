import 'package:flutter/material.dart';

class HairEmptyState extends StatelessWidget {
  final VoidCallback onAnalyze;

  const HairEmptyState({
    super.key,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_cut, size: 100, color: Colors.grey[300]),
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
            'Bắt đầu tạo kiểu tóc để xem lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
