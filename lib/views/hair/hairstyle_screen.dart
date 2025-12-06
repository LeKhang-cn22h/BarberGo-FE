import 'dart:io';
import 'package:barbergofe/services/camera_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

import 'style_selection_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _hasPermission = false;
  File? _capturedImage;
  bool _isFrontCamera = true;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    } else if (state == AppLifecycleState.paused) {
      _cameraService.dispose();
    }
  }

  Future<bool> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    setState(() => _isLoading = true);

    final hasPermission = await _checkCameraPermission();

    if (hasPermission) {
      await _cameraService.initializeCamera();
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraService.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final imageFile = await _cameraService.takePicture();

      if (imageFile != null) {
        setState(() {
          _capturedImage = imageFile;
        });

        // Show loading animation
        await Future.delayed(Duration(milliseconds: 300));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StyleSelectionScreen(capturedImage: imageFile),
          ),
        );

        // Reset for next capture
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _capturedImage = null;
              _isProcessing = false;
            });
          }
        });
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chụp ảnh: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  Future<void> _toggleFlash() async {
    await _cameraService.toggleFlash();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StyleSelectionScreen(capturedImage: imageFile),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('💡 Hướng dẫn chụp ảnh'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TipItem(icon: '✓', text: 'Gương mặt chiếm 70% khung hình'),
            _TipItem(icon: '✓', text: 'Chụp ở nơi có ánh sáng tốt'),
            _TipItem(icon: '✓', text: 'Nhìn thẳng vào camera'),
            _TipItem(icon: '✓', text: 'Tóc gọn gàng để thấy rõ đường viền'),
            _TipItem(icon: '✓', text: 'Không đội mũ hoặc che mặt'),
            _TipItem(icon: '✓', text: 'Khoảng cách 30-50cm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraService.controller == null || !_cameraService.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // ========== FIX: CAMERA PREVIEW FILL MÀN HÌNH ==========
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraService.controller!.value.previewSize!.height,
                height: _cameraService.controller!.value.previewSize!.width,
                child: CameraPreview(_cameraService.controller!),
              ),
            ),
          ),

          // Gradient overlay for better visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                  stops: [0.0, 0.15, 0.75, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Column(
      children: [
        // Main capture button
        GestureDetector(
          onTap: _isProcessing ? null : _takePicture,
          child: Container(
            width: _isProcessing ? 70 : 80,
            height: _isProcessing ? 70 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isProcessing ? Colors.grey : Colors.white,
              border: Border.all(
                color: Colors.white,
                width: _isProcessing ? 3 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _isProcessing
                ? Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
                : Icon(
              Icons.camera_alt,
              size: 36,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 12),
        // Label
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isProcessing ? 'Đang xử lý...' : 'Chụp ảnh',
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

  Widget _buildPermissionDeniedView() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 80, color: Colors.grey),
              SizedBox(height: 24),
              Text(
                'Cần quyền truy cập Camera',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Ứng dụng cần quyền camera để chụp ảnh tạo kiểu tóc. Vui lòng cấp quyền để tiếp tục.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _initializeCamera,
                icon: Icon(Icons.refresh),
                label: Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: openAppSettings,
                child: Text('Mở Cài đặt'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildFaceGuideCircle() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.8,
  //     height: MediaQuery.of(context).size.width * 0.9,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       border: Border.all(
  //         color: Colors.white.withOpacity(0.6),
  //         width: 3,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Đang khởi tạo camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionDeniedView();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Chụp ảnh tạo kiểu tóc',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showTipsDialog,
            tooltip: 'Hướng dẫn',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ==================== CAMERA PREVIEW ====================
          Positioned.fill(
            child: _buildCameraPreview(),
          ),

          // ==================== FACE GUIDE CIRCLE ====================
          // Center(
          //   child: _buildFaceGuideCircle(),
          // ),

          // ==================== INSTRUCTIONS ====================
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Đặt mặt vào khung hình',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chụp chính diện • Ánh sáng tốt • Mặt rõ ràng',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ==================== GALLERY BUTTON (LEFT) ====================
          Positioned(
            bottom: 40,
            left: 30,
            child: _buildSideButton(
              Icons.photo_library,
              'Chọn từ thư viện',
              _pickImageFromGallery,
            ),
          ),

          // ==================== CAPTURE BUTTON (CENTER) ====================
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCaptureButton(),
            ),
          ),

          // ==================== CAMERA CONTROLS (RIGHT) ====================
          Positioned(
            bottom: 40,
            right: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flash button
                _buildSideButton(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  _isFlashOn ? 'Tắt đèn flash' : 'Bật đèn flash',
                  _toggleFlash,
                ),
                SizedBox(height: 20),
                // Switch camera button
                _buildSideButton(
                  _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  'Đổi camera',
                  _switchCamera,
                ),
              ],
            ),
          ),

          // ==================== CAPTURED IMAGE PREVIEW ====================
          if (_capturedImage != null)
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
                    _capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String icon;
  final String text;

  const _TipItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
    }
}
