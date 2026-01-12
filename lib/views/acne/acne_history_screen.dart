// ✅ FIX acne_history_screen.dart - THÊM HANDLERS

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../services/acne_storage_service.dart';
import '../../models/acne/acne_response.dart';
import 'package:open_file/open_file.dart';
import 'acne_result_screen.dart';  // ✅ THÊM import

class AcneHistoryScreen extends StatefulWidget {
  const AcneHistoryScreen({super.key});

  @override
  State<AcneHistoryScreen> createState() => _AcneHistoryScreenState();
}

class _AcneHistoryScreenState extends State<AcneHistoryScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      final results = await AcneStorageService.getAllResults();
      final stats = await AcneStorageService.getStorageStats();

      setState(() {
        _results = results;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử phân tích'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResults,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_old',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Xóa kết quả cũ'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear_old') {
                _handleClearOld();
              }
            },
          ),
        ],
      ),

      // ✅ THÊM FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('acne');  // Navigate đến camera
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Phân tích mới'),
        backgroundColor: Colors.green,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // List
          Expanded(
            child: _results.isEmpty ? _buildEmpty() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Chưa có kết quả nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bắt đầu phân tích mụn để xem lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.pushNamed('acne');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Phân tích ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultCard(result, index);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, int index) {
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
        onTap: () => _handleViewDetail(result),  // ✅ Tap để xem chi tiết
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ✅ Avatar với ảnh preview
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: overall != null
                      ? Color(overall.severityColor).withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: overall != null
                        ? Color(overall.severityColor)
                        : Colors.grey,
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
                  color: overall != null
                      ? Color(overall.severityColor)
                      : Colors.grey,
                  size: 32,
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overall?.severityText ?? 'Không rõ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: overall != null
                            ? Color(overall.severityColor)
                            : Colors.grey,
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
                ),
              ),

              // ✅ PopupMenu với HANDLERS
              PopupMenuButton(
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
                // ✅ FIX: THÊM HANDLER
                onSelected: (value) {
                  print('🔵 Menu selected: $value');

                  if (value == 'view') {
                    _handleViewDetail(result);
                  } else if (value == 'delete') {
                    _handleDelete(result, index);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HANDLERS ====================

  /// ✅ XEM CHI TIẾT
  void _handleViewDetail(Map<String, dynamic> result) {
    print('🔵 Opening detail view...');

    try {
      final resultData = AcneResponse.fromJson(result['result']);
      final imagePath = result['image_path'] as String?;

      print('   Result data: ${resultData.data?.overall?.severityText}');
      print('   Image path: $imagePath');

      if (imagePath == null) {
        print('❌ No image path in result');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Không tìm thấy đường dẫn ảnh'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        print('❌ Image file does not exist: $imagePath');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ File ảnh không tồn tại'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('✅ Navigating to AcneResultScreen...');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AcneResultScreen(
            response: resultData,
            capturedImage: imageFile,
          ),
        ),
      ).then((_) {
        print('✅ Returned from detail view, refreshing...');
        _loadResults();
      });

    } catch (e) {
      print('❌ Error viewing detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  /// ✅ XÓA KẾT QUẢ
  void _handleDelete(Map<String, dynamic> result, int index) async {
    print('🔵 Delete requested for index: $index');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận xóa'),
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
      print('✅ Deleting result...');

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

        // Xóa file JSON (nếu có)
        final jsonPath = result['json_path'] as String?;
        if (jsonPath != null) {
          final jsonFile = File(jsonPath);
          if (jsonFile.existsSync()) {
            await jsonFile.delete();
            print('   Deleted JSON: $jsonPath');
          }
        }

        // Xóa khỏi danh sách
        setState(() {
          _results.removeAt(index);
        });

        print('✅ Delete successful');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa kết quả'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh stats
        _loadResults();

      } catch (e) {
        print('❌ Error deleting: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi khi xóa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleClearOld() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $count kết quả cũ')),
        );
        _loadResults();
      }
    }
  }
}