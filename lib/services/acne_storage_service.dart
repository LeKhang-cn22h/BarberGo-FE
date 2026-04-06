
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/acne/acne_response.dart';

class AcneStorageService {

  // ==================== LƯU KẾT QUẢ JSON ====================

  /// Lưu kết quả phân tích dưới dạng JSON
  static Future<String> saveResultAsJson({
    required AcneResponse response,
    required File image,
  }) async {
    try {
      print(' [STORAGE] Starting save...');

      // Lấy thư mục Documents
      final directory = await getApplicationDocumentsDirectory();
      final acneFolder = Directory('${directory.path}/acne_results');

      // Tạo folder nếu chưa có
      if (!await acneFolder.exists()) {
        await acneFolder.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      //  1. LƯU ẢNH
      final imageFolder = Directory('${directory.path}/acne_images');
      if (!await imageFolder.exists()) {
        await imageFolder.create(recursive: true);
      }

      final imagePath = '${imageFolder.path}/acne_$timestamp.jpg';
      await image.copy(imagePath);
      print(' [STORAGE] Saved image: $imagePath');

      // 2. LƯU JSON
      final jsonPath = '${acneFolder.path}/acne_result_$timestamp.json';

      //  Tạo dữ liệu để lưu (BAO GỒM json_path)
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'image_path': imagePath,     // Path đến ảnh
        'json_path': jsonPath,        // Path đến chính file JSON này
        'result': response.toJson(),  // Kết quả phân tích
      };

      // Lưu file JSON
      final file = File(jsonPath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );

      print(' [STORAGE] Saved JSON: $jsonPath');
      print('   - Image: $imagePath');
      print('   - JSON: $jsonPath');

      return jsonPath;

    } catch (e) {
      print(' [STORAGE] Error saving JSON: $e');
      rethrow;
    }
  }

  // ==================== LƯU ẢNH ====================

  /// Lưu ảnh kèm theo kết quả
  static Future<String> saveImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageFolder = Directory('${directory.path}/acne_images');

      if (!await imageFolder.exists()) {
        await imageFolder.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final imagePath = '${imageFolder.path}/acne_$timestamp.jpg';

      // Copy ảnh
      await image.copy(imagePath);

      print(' [STORAGE] Saved image: $imagePath');
      return imagePath;

    } catch (e) {
      print(' [STORAGE] Error saving image: $e');
      rethrow;
    }
  }

  // ==================== ĐỌC KẾT QUẢ ====================

  /// Đọc tất cả kết quả đã lưu
  static Future<List<Map<String, dynamic>>> getAllResults() async {
    try {
      print(' [STORAGE] Loading all results...');

      final directory = await getApplicationDocumentsDirectory();
      final acneFolder = Directory('${directory.path}/acne_results');

      if (!await acneFolder.exists()) {
        print('   No results folder found');
        return [];
      }

      // Lấy tất cả file JSON
      final files = acneFolder.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      print('   Found ${files.length} JSON files');

      // Sắp xếp theo thời gian (mới nhất trước)
      files.sort((a, b) => b.path.compareTo(a.path));

      // Đọc nội dung
      List<Map<String, dynamic>> results = [];
      for (var file in files) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;

          //  Đảm bảo có json_path
          if (!data.containsKey('json_path')) {
            data['json_path'] = file.path;
          }

          results.add(data);
          print('   Loaded: ${file.path}');
        } catch (e) {
          print(' Error reading file: ${file.path} - $e');
        }
      }

      print('[STORAGE] Loaded ${results.length} results');
      return results;

    } catch (e) {
      print(' [STORAGE] Error reading results: $e');
      return [];
    }
  }

  // ==================== XÓA KẾT QUẢ ====================

  /// Xóa một kết quả cụ thể
  static Future<bool> deleteResult(String jsonPath) async {
    try {
      final file = File(jsonPath);
      if (await file.exists()) {
        await file.delete();
        print(' [STORAGE] Deleted: $jsonPath');
        return true;
      }
      return false;
    } catch (e) {
      print(' [STORAGE] Error deleting: $e');
      return false;
    }
  }

  /// Xóa tất cả kết quả cũ hơn X ngày
  static Future<int> deleteOldResults({int daysOld = 30}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final acneFolder = Directory('${directory.path}/acne_results');

      if (!await acneFolder.exists()) {
        return 0;
      }

      final files = acneFolder.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      int deletedCount = 0;
      final threshold = DateTime.now().subtract(Duration(days: daysOld));

      for (var file in files) {
        final modified = await file.lastModified();
        if (modified.isBefore(threshold)) {
          await file.delete();
          deletedCount++;
        }
      }

      print('[STORAGE] Deleted $deletedCount old results');
      return deletedCount;

    } catch (e) {
      print(' [STORAGE] Error deleting old results: $e');
      return 0;
    }
  }

  // ==================== XUẤT FILE TEXT ====================

  /// Xuất kết quả dưới dạng text report
  static Future<String> exportAsTextReport({
    required AcneResponse response,
    required File image,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportFolder = Directory('${directory.path}/acne_reports');

      if (!await reportFolder.exists()) {
        await reportFolder.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final reportPath = '${reportFolder.path}/acne_report_$timestamp.txt';

      // Tạo nội dung report
      final buffer = StringBuffer();
      buffer.writeln('═══════════════════════════════════════════');
      buffer.writeln('        KẾT QUẢ PHÂN TÍCH MỤN');
      buffer.writeln('═══════════════════════════════════════════');
      buffer.writeln();
      buffer.writeln('Ngày phân tích: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln();

      if (response.data?.overall != null) {
        final overall = response.data!.overall!;
        buffer.writeln('ĐÁNH GIÁ TỔNG QUÁT:');
        buffer.writeln('  Mức độ: ${overall.severityText}');
        buffer.writeln('  Khuyến nghị: ${overall.recommendation}');
        if (overall.needDoctor) {
          buffer.writeln('   Nên gặp bác sĩ da liễu');
        }
        buffer.writeln();
      }

      if (response.data?.summary != null) {
        final summary = response.data!.summary!;
        buffer.writeln('THỐNG KÊ:');
        buffer.writeln('  Tổng số vùng: ${summary.totalRegions}');
        buffer.writeln('  Vùng có mụn: ${summary.acneRegions}');
        buffer.writeln('  Vùng sạch: ${summary.clearRegions}');
        buffer.writeln('  Tỷ lệ có mụn: ${summary.acnePercentage.toStringAsFixed(1)}%');
        buffer.writeln('  Độ tin cậy TB: ${(summary.averageConfidence * 100).toStringAsFixed(1)}%');
        buffer.writeln();
      }

      if (response.data?.regions != null) {
        buffer.writeln('CHI TIẾT THEO VÙNG:');
        response.data!.regions!.forEach((key, region) {
          buffer.writeln('  ${_getVietnameseName(key)}:');
          buffer.writeln('    - Trạng thái: ${region.severityText}');
          buffer.writeln('    - Độ tin cậy: ${region.confidencePercent}');
        });
        buffer.writeln();
      }

      if (response.data?.advice != null && response.data!.advice!.isNotEmpty) {
        buffer.writeln('LỜI KHUYÊN CHĂM SÓC:');
        for (var advice in response.data!.advice!) {
          buffer.writeln('  ${advice.zone} (${advice.severityText}):');
          for (var tip in advice.tips) {
            buffer.writeln('    • $tip');
          }
          buffer.writeln();
        }
      }

      buffer.writeln('═══════════════════════════════════════════');

      // Lưu file
      final file = File(reportPath);
      await file.writeAsString(buffer.toString());

      print('[STORAGE] Saved text report: $reportPath');
      return reportPath;

    } catch (e) {
      print(' [STORAGE] Error saving text report: $e');
      rethrow;
    }
  }

  // ==================== HELPER ====================

  static String _getVietnameseName(String key) {
    const map = {
      'forehead': 'Trán',
      'nose': 'Mũi',
      'cheek_left': 'Má trái',
      'cheek_right': 'Má phải',
      'chin': 'Cằm',
    };
    return map[key] ?? key;
  }

  // ==================== THỐNG KÊ ====================

  /// Lấy thống kê lưu trữ
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final acneFolder = Directory('${directory.path}/acne_results');

      if (!await acneFolder.exists()) {
        return {
          'total_results': 0,
          'total_size_mb': 0.0,
        };
      }

      final files = acneFolder.listSync().whereType<File>().toList();
      int totalSize = 0;

      for (var file in files) {
        totalSize += await file.length();
      }

      return {
        'total_results': files.length,
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