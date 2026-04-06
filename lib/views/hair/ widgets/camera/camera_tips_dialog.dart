import 'package:flutter/material.dart';

void showCameraTipsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber),
          SizedBox(width: 8),
          Text('💡 Hướng dẫn chụp ảnh'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipItem(icon: '✓', text: 'Gương mặt chiếm 70% khung hình'),
          _TipItem(icon: '✓', text: 'Chụp ở nơi có ánh sáng tốt'),
          _TipItem(icon: '✓', text: 'Nhìn thẳng vào camera'),
          _TipItem(icon: '✓', text: 'Tóc gọn gàng để thấy rõ đường viền'),
          _TipItem(icon: '✓', text: 'Không đội mũ hoặc che mặt'),
          _TipItem(icon: '✓', text: 'Khoảng cách 30-50cm'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Đã hiểu'),
        ),
      ],
    ),
  );
}

class _TipItem extends StatelessWidget {
  final String icon;
  final String text;

  const _TipItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}