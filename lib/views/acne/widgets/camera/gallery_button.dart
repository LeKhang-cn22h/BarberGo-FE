import 'package:flutter/material.dart';

class GalleryButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onTap;

  const GalleryButton({
    super.key,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 40,
      child: GestureDetector(
        onTap: isProcessing ? null : onTap,
        child: const CircleAvatar(
          radius: 30,
          child: Icon(Icons.photo_library),
        ),
      ),
    );
  }
}
