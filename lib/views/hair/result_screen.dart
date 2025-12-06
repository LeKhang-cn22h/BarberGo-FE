import 'dart:io';
import 'dart:typed_data';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';


class ResultScreen extends StatelessWidget {
  final File originalImage;
  final HairStyleResponse resultImage;

  ResultScreen({
    required this.originalImage,
    required this.resultImage,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = resultImage.imageBase64 != null
        ? base64.decode(resultImage.imageBase64!)
        : Uint8List(0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.share),
        //     onPressed: () => _shareResult(context),
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.download),
        //     onPressed: () => _saveImage(context, bytes),
        //   ),
        // ],
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
                              image: FileImage(originalImage),
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

              SizedBox(height: 30),

              // Result details
              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Generation Details',
              //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //         ),
              //         SizedBox(height: 10),
              //         _buildDetailRow('Style', resultImage.style),
              //         if (resultImage.seed != null)
              //           _buildDetailRow('Seed', resultImage.seed.toString()),
              //         _buildDetailRow('Face Detected', resultImage.faceDetected ? 'Yes' : 'No'),
              //       ],
              //     ),
              //   ),
              // ),

              // SizedBox(height: 20),

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
                        Text('Kết quả', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _shareResult(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _saveImage(BuildContext context, Uint8List bytes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Save to gallery coming soon')),
    );
  }
}