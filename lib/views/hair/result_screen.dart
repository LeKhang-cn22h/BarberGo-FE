import 'dart:io';
import 'dart:typed_data';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:barbergofe/services/hair_storage_service..dart';
import 'package:barbergofe/views/hair/%20widgets/result_hair/result_action_buttons.dart';
import 'package:barbergofe/views/hair/%20widgets/result_hair/result_comparison.dart';
import 'package:barbergofe/views/hair/%20widgets/result_hair/result_full_image.dart';
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await HairStorageService.saveHairResult(
        originalImage: widget.originalImage,
        resultImage: resultBytes,
        styleName: widget.styleName,
      );

      if (mounted) {
        Navigator.pop(context);

        setState(() => _isSaved = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Đã lưu kết quả!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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
              ResultComparison(
                originalImage: widget.originalImage,
                resultBytes: bytes,
              ),

              SizedBox(height: 20),

              // Action buttons
              ResultActionButtons(
                isSaved: _isSaved,
                onSave: () => _handleSave(bytes),
                onRetry: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                onHome: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),

              SizedBox(height: 20),

              // Full result image
              if (bytes.isNotEmpty)
                ResultFullImage(imageBytes: bytes),
            ],
          ),
        ),
      ),
    );
  }
}