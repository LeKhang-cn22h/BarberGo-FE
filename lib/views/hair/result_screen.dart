
import 'dart:io';
import 'dart:typed_data';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:barbergofe/services/hair_storage_service..dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  final File originalImage;
  final HairStyleResponse resultImage;
  final String styleName;

  ResultScreen({
    required this.originalImage,
    required this.resultImage,
    this.styleName = 'Unknown Style',
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final bytes = widget.resultImage.imageBase64 != null
        ? base64.decode(widget.resultImage.imageBase64!)
        : Uint8List(0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả'),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => _handleSave(bytes),
            tooltip: _isSaved ? 'Đã lưu' : 'Lưu kết quả',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Before/After comparison
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Trước', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(widget.originalImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Sau', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: bytes.isNotEmpty
                                ? DecorationImage(
                              image: MemoryImage(bytes),
                              fit: BoxFit.cover,
                            )
                                : null,
                            color: Colors.grey[200],
                          ),
                          child: bytes.isEmpty
                              ? Center(child: Icon(Icons.error, size: 50))
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Quay lại camera
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // ✅ NÚT LƯU (BOTTOM)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaved ? null : () => _handleSave(bytes),
                      icon: Icon(_isSaved ? Icons.check : Icons.save),
                      label: Text(_isSaved ? 'Đã lưu' : 'Lưu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.green : Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      icon: Icon(Icons.home),
                      label: Text('Trang chủ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Full result image
              if (bytes.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Kết quả đầy đủ', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Image.memory(bytes, fit: BoxFit.contain),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // HANDLER LƯU
  Future<void> _handleSave(Uint8List resultBytes) async {
    if (resultBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có ảnh để lưu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Lưu kết quả
      await HairStorageService.saveHairResult(
        originalImage: widget.originalImage,
        resultImage: resultBytes,
        styleName: widget.styleName,
      );

      // Đóng loading
      if (mounted) {
        Navigator.pop(context);

        setState(() {
          _isSaved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã lưu kết quả!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Đóng loading
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}