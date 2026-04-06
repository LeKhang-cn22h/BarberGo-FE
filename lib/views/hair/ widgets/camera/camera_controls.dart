import 'dart:io';
import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final bool isProcessing;
  final bool isFrontCamera;
  final bool isFlashOn;
  final File? capturedImage;
  final VoidCallback onTakePicture;
  final VoidCallback onPickFromGallery;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleFlash;

  const CameraControls({
    super.key,
    required this.isProcessing,
    required this.isFrontCamera,
    required this.isFlashOn,
    required this.capturedImage,
    required this.onTakePicture,
    required this.onPickFromGallery,
    required this.onSwitchCamera,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gallery button (LEFT)
        Positioned(
          bottom: 40,
          left: 30,
          child: _buildSideButton(
            Icons.photo_library,
            'Chọn từ thư viện',
            onPickFromGallery,
          ),
        ),

        // Capture button (CENTER)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: _buildCaptureButton(),
          ),
        ),

        // Camera controls (RIGHT)
        Positioned(
          bottom: 40,
          right: 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSideButton(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                isFlashOn ? 'Tắt đèn flash' : 'Bật đèn flash',
                onToggleFlash,
              ),
              SizedBox(height: 20),
              _buildSideButton(
                isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                'Đổi camera',
                onSwitchCamera,
              ),
            ],
          ),
        ),

        // Captured image preview
        if (capturedImage != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  capturedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: isProcessing ? null : onTakePicture,
          child: Container(
            width: isProcessing ? 70 : 80,
            height: isProcessing ? 70 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isProcessing ? Colors.grey : Colors.white,
              border: Border.all(
                color: Colors.white,
                width: isProcessing ? 3 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isProcessing
                ? Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
                : Icon(Icons.camera_alt, size: 36, color: Colors.black),
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isProcessing ? 'Đang xử lý...' : 'Chụp ảnh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 26),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }
}