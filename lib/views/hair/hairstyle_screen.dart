import 'dart:io';
import 'package:barbergofe/services/camera_service.dart';
import 'package:barbergofe/views/acne/widgets/camera/camera_preview_widget.dart';
import 'package:barbergofe/views/hair/%20widgets/camera/camera_controls.dart';
import 'package:barbergofe/views/hair/%20widgets/camera/camera_instructions.dart';
import 'package:barbergofe/views/hair/%20widgets/camera/camera_tips_dialog.dart';
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
        setState(() => _capturedImage = imageFile);
        await Future.delayed(Duration(milliseconds: 300));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StyleSelectionScreen(capturedImage: imageFile),
          ),
        );

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
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  Future<void> _toggleFlash() async {
    await _cameraService.toggleFlash();
    setState(() => _isFlashOn = !_isFlashOn);
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
    showCameraTipsDialog(context);
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
          // Camera Preview
          Positioned.fill(
            child: CameraPreviewWidget(controller: _cameraService.controller!),
          ),

          // Instructions
          CameraInstructions(),

          // Controls
          CameraControls(
            isProcessing: _isProcessing,
            isFrontCamera: _isFrontCamera,
            isFlashOn: _isFlashOn,
            capturedImage: _capturedImage,
            onTakePicture: _takePicture,
            onPickFromGallery: _pickImageFromGallery,
            onSwitchCamera: _switchCamera,
            onToggleFlash: _toggleFlash,
          ),
        ],
      ),
    );
  }
}