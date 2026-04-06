import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/acne/acne_response.dart';

class AcneResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const AcneResultCard({
    super.key,
    required this.result,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(result['timestamp']);
    final resultData = AcneResponse.fromJson(result['result']);
    final overall = resultData.data?.overall;
    final imagePath = result['image_path'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar với ảnh preview
              _buildAvatar(imagePath, overall),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: _buildInfo(overall, timestamp),
              ),

              // PopupMenu
              _buildPopupMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imagePath, dynamic overall) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: overall != null
            ? Color(overall.severityColor).withOpacity(0.2)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overall != null ? Color(overall.severityColor) : Colors.grey,
          width: 2,
        ),
      ),
      child: imagePath != null && File(imagePath).existsSync()
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      )
          : Icon(
        Icons.face,
        color: overall != null ? Color(overall.severityColor) : Colors.grey,
        size: 32,
      ),
    );
  }

  Widget _buildInfo(dynamic overall, DateTime timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overall?.severityText ?? 'Không rõ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: overall != null ? Color(overall.severityColor) : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        if (overall != null) ...[
          const SizedBox(height: 4),
          Text(
            overall.recommendation,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 20),
              SizedBox(width: 8),
              Text('Xem chi tiết'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        print('📱 Menu selected: $value');

        if (value == 'view') {
          onView();
        } else if (value == 'delete') {
          onDelete();
        }
      },
    );
  }
}