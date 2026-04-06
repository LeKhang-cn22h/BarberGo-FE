import 'dart:io';
import 'package:barbergofe/models/acne/acne_response.dart';
import 'package:barbergofe/services/acne_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';


class ResultActionButtons extends StatelessWidget {
  final AcneResponse response;
  final File capturedImage;

  const ResultActionButtons({
    super.key,
    required this.response,
    required this.capturedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Nút Lưu kết quả
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleSaveJson(context),
              icon: const Icon(Icons.save),
              label: const Text('Lưu kết quả'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Row: Chụp lại và Trang chủ
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chụp lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Trang chủ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveJson(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final jsonPath = await AcneStorageService.saveResultAsJson(
        response: response,
        image: capturedImage,
      );

      await AcneStorageService.saveImage(capturedImage);

      if (context.mounted) {
        Navigator.pop(context); // Đóng loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(' Đã lưu kết quả!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Xem',
              textColor: Colors.white,
              onPressed: () async {
                await OpenFile.open(jsonPath);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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