import 'package:flutter/material.dart';

class StyleSelectedInfo extends StatelessWidget {
  final String styleName;

  const StyleSelectedInfo({
    super.key,
    required this.styleName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
            'Chọn: $styleName',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}