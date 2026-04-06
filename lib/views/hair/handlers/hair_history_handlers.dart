import 'dart:io';
import 'package:barbergofe/services/hair_storage_service..dart';
import 'package:flutter/material.dart';

class HairHistoryHandlers {
  final BuildContext context;
  final VoidCallback onRefresh;

  HairHistoryHandlers({
    required this.context,
    required this.onRefresh,
  });

  /// Xem chi tiết kết quả
  void handleViewDetail(BuildContext context, Map<String, dynamic> result) {
    final originalPath = result['original_path'] as String?;
    final resultPath = result['result_path'] as String?;
    final styleName = result['style_name'] as String;

    if (originalPath == null || resultPath == null ||
        !File(originalPath).existsSync() || !File(resultPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy file ảnh'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                styleName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Before/After
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Trước', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Image.file(File(originalPath), height: 200, fit: BoxFit.cover),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Sau', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Image.file(File(resultPath), height: 200, fit: BoxFit.cover),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xóa kết quả
  Future<void> handleDelete(
      BuildContext context,
      Map<String, dynamic> result,
      int index,
      VoidCallback onDeleteSuccess,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(' Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa kết quả này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await HairStorageService.deleteResult(result);

      if (success && context.mounted) {
        onDeleteSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Đã xóa kết quả'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Xóa kết quả cũ (>30 ngày)
  Future<void> handleClearOld(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('️ Xóa kết quả cũ?'),
        content: const Text('Xóa các kết quả cũ hơn 30 ngày?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final count = await HairStorageService.deleteOldResults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Đã xóa $count kết quả cũ')),
        );
        onRefresh();
      }
    }
  }
}