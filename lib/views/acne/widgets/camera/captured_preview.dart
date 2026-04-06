import 'dart:io';
import 'package:flutter/material.dart';

class CapturedPreview extends StatelessWidget {
  final File? image;

  const CapturedPreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    if (image == null) return const SizedBox();

    return Positioned(
      top: 100,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          image!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
