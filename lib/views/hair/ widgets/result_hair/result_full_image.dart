import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultFullImage extends StatelessWidget {
  final Uint8List imageBytes;

  const ResultFullImage({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Kết quả đầy đủ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.memory(imageBytes, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}