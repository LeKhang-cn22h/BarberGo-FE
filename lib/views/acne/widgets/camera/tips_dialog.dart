import 'package:flutter/material.dart';

void showTipsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Hướng dẫn chụp ảnh'),
      content: const Text('Rửa mặt sạch – ánh sáng tốt'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
