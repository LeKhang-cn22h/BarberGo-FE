// lib/views/profile/widgets/edit_avatar_bottom_sheet.dart

import 'package:flutter/material.dart';

class EditAvatarBottomSheet extends StatelessWidget {
  final VoidCallback onPickFromGallery;

  const EditAvatarBottomSheet({
    super.key,
    required this.onPickFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Chọn ảnh đại diện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Gallery option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B4B8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_library,
                color: Color(0xFF5B4B8A),
              ),
            ),
            title: const Text('Chọn từ thư viện'),
            onTap: () {
              Navigator.pop(context);
              onPickFromGallery();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Future<void> show(
      BuildContext context, {
        required VoidCallback onPickFromGallery,
      }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EditAvatarBottomSheet(
        onPickFromGallery: onPickFromGallery,
      ),
    );
  }
}