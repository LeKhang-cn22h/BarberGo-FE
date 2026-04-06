import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/acne/acne_response.dart';
import '../../../services/acne_storage_service.dart';
import '../acne_result_screen.dart';

class AcneHistoryHandlers {
  final BuildContext context;
  final VoidCallback onRefresh;

  AcneHistoryHandlers({
    required this.context,
    required this.onRefresh,
  });

  /// Xem chi tiết kết quả
  void handleViewDetail(BuildContext context, Map<String, dynamic> result) {
    print('Opening detail view...');

    try {
      final resultData = AcneResponse.fromJson(result['result']);
      final imagePath = result['image_path'] as String?;

      print('   Result data: ${resultData.data?.overall?.severityText}');
      print('   Image path: $imagePath');

      if (imagePath == null) {
        print('️ No image path in result');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Không tìm thấy đường dẫn ảnh'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        print(' Image file does not exist: $imagePath');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' File ảnh không tồn tại'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print(' Navigating to AcneResultScreen...');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AcneResultScreen(
            response: resultData,
            capturedImage: imageFile,
          ),
        ),
      ).then((_) {
        print(' Returned from detail view, refreshing...');
        onRefresh();
      });
    } catch (e) {
      print(' Error viewing detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Xóa kết quả
  Future<void> handleDelete(
      BuildContext context,
      Map<String, dynamic> result,
      int index,
      VoidCallback onDeleteSuccess,
      ) async {
    print('Delete requested for index: $index');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑 Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa kết quả này?'),
        actions: [
          TextButton(
            onPressed: () {
              print('   User cancelled delete');
              Navigator.pop(context, false);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              print('   User confirmed delete');
              Navigator.pop(context, true);
            },
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
      print(' Deleting result...');

      try {
        // Xóa file ảnh
        final imagePath = result['image_path'] as String?;
        if (imagePath != null) {
          final imageFile = File(imagePath);
          if (imageFile.existsSync()) {
            await imageFile.delete();
            print('   Deleted image: $imagePath');
          }
        }

        // Xóa file JSON
        final jsonPath = result['json_path'] as String?;
        if (jsonPath != null) {
          final jsonFile = File(jsonPath);
          if (jsonFile.existsSync()) {
            await jsonFile.delete();
            print('   Deleted JSON: $jsonPath');
          }
        }

        // Callback để xóa khỏi danh sách
        onDeleteSuccess();

        print('Delete successful');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(' Đã xóa kết quả'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print(' Error deleting: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(' Lỗi khi xóa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Xóa kết quả cũ (>30 ngày)
  Future<void> handleClearOld(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa kết quả cũ?'),
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
      final count = await AcneStorageService.deleteOldResults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Đã xóa $count kết quả cũ')),
        );
        onRefresh();
      }
    }
  }
}