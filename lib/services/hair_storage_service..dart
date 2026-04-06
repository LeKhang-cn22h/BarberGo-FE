import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class HairStorageService {

  // ==================== LƯU KẾT QUẢ ====================

  /// Lưu kết quả tạo kiểu tóc
  static Future<String> saveHairResult({
    required File originalImage,
    required Uint8List resultImage,
    required String styleName,
  }) async {
    try {
      print(' [HAIR STORAGE] Starting save...');

      // Lấy thư mục Documents
      final directory = await getApplicationDocumentsDirectory();
      final hairFolder = Directory('${directory.path}/hair_results');

      // Tạo folder nếu chưa có
      if (!await hairFolder.exists()) {
        await hairFolder.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      //  1. LƯU ẢNH GỐC
      final originalPath = '${hairFolder.path}/original_$timestamp.jpg';
      await originalImage.copy(originalPath);
      print(' [HAIR STORAGE] Saved original: $originalPath');

      //  2. LƯU ẢNH KẾT QUẢ
      final resultPath = '${hairFolder.path}/result_$timestamp.jpg';
      final resultFile = File(resultPath);
      await resultFile.writeAsBytes(resultImage);
      print(' [HAIR STORAGE] Saved result: $resultPath');

      //  3. LƯU METADATA JSON
      final metadataPath = '${hairFolder.path}/metadata_$timestamp.json';
      final metadata = {
        'timestamp': DateTime.now().toIso8601String(),
        'style_name': styleName,
        'original_path': originalPath,
        'result_path': resultPath,
        'metadata_path': metadataPath,
      };

      final metadataFile = File(metadataPath);
      await metadataFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(metadata),
      );

      print('[HAIR STORAGE] Saved metadata: $metadataPath');
      print('   Style: $styleName');

      return resultPath;

    } catch (e) {
      print('[HAIR STORAGE] Error saving: $e');
      rethrow;
    }
  }

  // ==================== ĐỌC TẤT CẢ KẾT QUẢ ====================

  /// Lấy tất cả kết quả đã lưu
  static Future<List<Map<String, dynamic>>> getAllResults() async {
    try {
      print('💈 [HAIR STORAGE] Loading all results...');

      final directory = await getApplicationDocumentsDirectory();
      final hairFolder = Directory('${directory.path}/hair_results');

      if (!await hairFolder.exists()) {
        print('   No results folder found');
        return [];
      }

      // Lấy tất cả file metadata JSON
      final files = hairFolder.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('metadata_') && file.path.endsWith('.json'))
          .toList();

      print('   Found ${files.length} metadata files');

      // Sắp xếp theo thời gian (mới nhất trước)
      files.sort((a, b) => b.path.compareTo(a.path));

      // Đọc nội dung
      List<Map<String, dynamic>> results = [];
      for (var file in files) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;

          // Kiểm tra file còn tồn tại không
          final originalPath = data['original_path'] as String?;
          final resultPath = data['result_path'] as String?;

          if (originalPath != null && resultPath != null &&
              File(originalPath).existsSync() && File(resultPath).existsSync()) {
            results.add(data);
            print('   Loaded: ${data['style_name']}');
          } else {
            print('  Missing files for: ${file.path}');
          }
        } catch (e) {
          print(' Error reading file: ${file.path} - $e');
        }
      }

      print('[HAIR STORAGE] Loaded ${results.length} results');
      return results;

    } catch (e) {
      print(' [HAIR STORAGE] Error reading results: $e');
      return [];
    }
  }

  // ==================== XÓA KẾT QUẢ ====================

  /// Xóa một kết quả
  static Future<bool> deleteResult(Map<String, dynamic> result) async {
    try {
      print(' [HAIR STORAGE] Deleting result...');

      // Xóa ảnh gốc
      final originalPath = result['original_path'] as String?;
      if (originalPath != null && File(originalPath).existsSync()) {
        await File(originalPath).delete();
        print('   Deleted original: $originalPath');
      }

      // Xóa ảnh kết quả
      final resultPath = result['result_path'] as String?;
      if (resultPath != null && File(resultPath).existsSync()) {
        await File(resultPath).delete();
        print('   Deleted result: $resultPath');
      }

      // Xóa metadata
      final metadataPath = result['metadata_path'] as String?;
      if (metadataPath != null && File(metadataPath).existsSync()) {
        await File(metadataPath).delete();
        print('   Deleted metadata: $metadataPath');
      }

      print(' [HAIR STORAGE] Delete successful');
      return true;

    } catch (e) {
      print(' [HAIR STORAGE] Error deleting: $e');
      return false;
    }
  }

  /// Xóa kết quả cũ hơn X ngày
  static Future<int> deleteOldResults({int daysOld = 30}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final hairFolder = Directory('${directory.path}/hair_results');

      if (!await hairFolder.exists()) {
        return 0;
      }

      final files = hairFolder.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('metadata_'))
          .toList();

      int deletedCount = 0;
      final threshold = DateTime.now().subtract(Duration(days: daysOld));

      for (var file in files) {
        final modified = await file.lastModified();
        if (modified.isBefore(threshold)) {
          try {
            // Đọc metadata để xóa tất cả files liên quan
            final content = await file.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            await deleteResult(data);
            deletedCount++;
          } catch (e) {
            print(' Error deleting old file: ${file.path}');
          }
        }
      }

      print('[HAIR STORAGE] Deleted $deletedCount old results');
      return deletedCount;

    } catch (e) {
      print('[HAIR STORAGE] Error deleting old results: $e');
      return 0;
    }
  }

  // ==================== THỐNG KÊ ====================

  /// Lấy thống kê lưu trữ
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final hairFolder = Directory('${directory.path}/hair_results');

      if (!await hairFolder.exists()) {
        return {
          'total_results': 0,
          'total_size_mb': 0.0,
        };
      }

      final files = hairFolder.listSync().whereType<File>().toList();
      int totalSize = 0;
      int resultCount = 0;

      for (var file in files) {
        totalSize += await file.length();
        if (file.path.contains('metadata_')) {
          resultCount++;
        }
      }

      return {
        'total_results': resultCount,
        'total_size_mb': totalSize / (1024 * 1024),
      };

    } catch (e) {
      return {
        'total_results': 0,
        'total_size_mb': 0.0,
      };
    }
  }
}