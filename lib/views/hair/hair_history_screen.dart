import 'package:barbergofe/services/hair_storage_service..dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class HairHistoryScreen extends StatefulWidget {
  const HairHistoryScreen({super.key});
  @override
  State<HairHistoryScreen> createState() => _HairHistoryScreenState();
}

class _HairHistoryScreenState extends State<HairHistoryScreen> {
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
      final results = await HairStorageService.getAllResults();
      final stats = await HairStorageService.getStorageStats();

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
        title: const Text('Lịch sử tạo kiểu tóc'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('hair');
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Tạo mới'),
        backgroundColor: Colors.purple,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _results.isEmpty ? _buildEmpty() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_cut, size: 100, color: Colors.grey[300]),
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
            'Bắt đầu tạo kiểu tóc để xem lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
    final styleName = result['style_name'] as String;
    final resultPath = result['result_path'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleViewDetail(result),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Preview ảnh kết quả
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple,
                    width: 2,
                  ),
                ),
                child: resultPath != null && File(resultPath).existsSync()
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(resultPath),
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.content_cut, color: Colors.purple, size: 40),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      styleName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.purple,
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
                    const SizedBox(height: 4),
                    Text(
                      'Kiểu tóc AI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu
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
                onSelected: (value) {
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

  void _handleViewDetail(Map<String, dynamic> result) {
    final originalPath = result['original_path'] as String?;
    final resultPath = result['result_path'] as String?;
    final styleName = result['style_name'] as String;

    if (originalPath == null || resultPath == null ||
        !File(originalPath).existsSync() || !File(resultPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Không tìm thấy file ảnh'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog với ảnh trước/sau
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

  void _handleDelete(Map<String, dynamic> result, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận xóa'),
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

      if (success && mounted) {
        setState(() {
          _results.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã xóa kết quả'),
            backgroundColor: Colors.green,
          ),
        );

        _loadResults();
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
      final count = await HairStorageService.deleteOldResults();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $count kết quả cũ')),
        );
        _loadResults();
      }
    }
  }
}