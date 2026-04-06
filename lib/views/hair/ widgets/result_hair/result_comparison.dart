import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultComparison extends StatelessWidget {
  final File originalImage;
  final Uint8List resultBytes;

  const ResultComparison({
    super.key,
    required this.originalImage,
    required this.resultBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text('Trước', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(originalImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              const Text('Sau', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: resultBytes.isNotEmpty
                      ? DecorationImage(
                    image: MemoryImage(resultBytes),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: Colors.grey[200],
                ),
                child: resultBytes.isEmpty
                    ? const Center(child: Icon(Icons.error, size: 50))
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}