import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';  // ← THÊM
import '../../viewmodels/acne_viewmodel.dart';
import 'acne_result_screen.dart';

class AcneCameraView extends StatefulWidget {
  const AcneCameraView({Key? key}) : super(key: key);

  @override
  State<AcneCameraView> createState() => _AcneCameraViewState();
}

class _AcneCameraViewState extends State<AcneCameraView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _permissionError;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();  // ← THÊM

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInitCamera();
  }

  // ==================== PERMISSION & CAMERA INIT ====================

  Future<void> _requestPermissionAndInitCamera() async {
    setState(() {
      _isLoading = true;
      _permissionError = null;
    });

    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      await _initCamera();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionGranted = false;
        _isLoading = false;
        _permissionError = 'Quyền camera bị từ chối vĩnh viễn. Vui lòng mở Cài đặt để cấp quyền.';
      });
    } else {
      setState(() {
        _isPermissionGranted = false;
        _isLoading = false;
        _permissionError = 'Cần quyền truy cập camera để tiếp tục.';
      });
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isLoading = false;
          _permissionError = 'Không tìm thấy camera trên thiết bị.';
        });
        return;
      }

      // Use front camera
      final frontCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _permissionError = 'Lỗi khởi tạo camera: $e';
      });
    }
  }

  // ==================== PICK IMAGE FROM GALLERY ====================

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (xFile == null) {
        // User cancelled
        return;
      }

      setState(() {
        _isProcessing = true;
      });

      // Copy to app directory
      final dir = await getApplicationDocumentsDirectory();
      final String newPath = path.join(
        dir.path,
        'acne_gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final File imageFile = await File(xFile.path).copy(newPath);

      setState(() {
        _capturedImage = imageFile;
      });

      // Save to viewmodel
      final viewModel = Provider.of<AcneViewModel>(context, listen: false);
      viewModel.setCapturedImage(imageFile);

      // Show loading dialog
      if (mounted) {
        _showLoadingDialog();
      }

      // Detect acne
      await viewModel.detect();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to result
      if (mounted && viewModel.response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AcneResultScreen(
              response: viewModel.response!,
              capturedImage: imageFile,
            ),
          ),
        ).then((_) {
          // Reset after returning from result screen
          setState(() {
            _capturedImage = null;
          });
          viewModel.reset();
        });
      } else if (mounted && viewModel.errorMessage != null) {
        _showSnackBar(viewModel.errorMessage!, Colors.red);
      }
    } catch (e) {
      print('❌ Error picking image: $e');

      if (mounted) {
        // Close loading dialog if open
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showSnackBar('Lỗi: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ==================== CAPTURE & DETECT ====================

  Future<void> _captureAndDetect() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _showSnackBar('Camera chưa sẵn sàng', Colors.red);
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture image
      final XFile xFile = await _controller!.takePicture();

      final dir = await getApplicationDocumentsDirectory();
      final String newPath = path.join(
        dir.path,
        'acne_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final File imageFile = await File(xFile.path).copy(newPath);

      setState(() {
        _capturedImage = imageFile;
      });

      // Save to viewmodel
      final viewModel = Provider.of<AcneViewModel>(context, listen: false);
      viewModel.setCapturedImage(imageFile);

      // Show loading dialog
      if (mounted) {
        _showLoadingDialog();
      }

      // Detect acne
      await viewModel.detect();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to result
      if (mounted && viewModel.response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AcneResultScreen(
              response: viewModel.response!,
              capturedImage: imageFile,
            ),
          ),
        ).then((_) {
          // Reset after returning from result screen
          setState(() {
            _capturedImage = null;
          });
          viewModel.reset();
        });
      } else if (mounted && viewModel.errorMessage != null) {
        _showSnackBar(viewModel.errorMessage!, Colors.red);
      }
    } catch (e) {
      print('❌ Error: $e');

      if (mounted) {
        // Close loading dialog if open
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showSnackBar('Lỗi: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ==================== UI HELPERS ====================

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    '🔍 Đang phân tích...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng đợi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('💡 Hướng dẫn chụp ảnh'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TipItem(icon: '✓', text: 'Rửa mặt sạch trước khi chụp'),
            _TipItem(icon: '✓', text: 'Chụp ở nơi có ánh sáng tốt'),
            _TipItem(icon: '✓', text: 'Không trang điểm'),
            _TipItem(icon: '✓', text: 'Nhìn thẳng vào camera'),
            _TipItem(icon: '✓', text: 'Khoảng cách 30-40cm'),
            _TipItem(icon: '✓', text: 'Đặt mặt vào khung hình oval'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần quyền truy cập'),
        content: const Text(
          'Ứng dụng cần quyền camera để chụp ảnh phát hiện mụn. Vui lòng mở Cài đặt để cấp quyền.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
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

    // Permission denied state
    if (!_isPermissionGranted || _permissionError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Phát hiện mụn'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  _permissionError ?? 'Cần quyền truy cập camera',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _requestPermissionAndInitCamera,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _showPermissionDialog,
                  child: const Text('Mở Cài đặt'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Camera not available
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phát hiện mụn')),
        body: const Center(
          child: Text('Camera không khả dụng'),
        ),
      );
    }

    // ✅✅✅ MAIN UI - CAMERA VIEW ✅✅✅
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Phát hiện mụn'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTipsDialog,
            tooltip: 'Hướng dẫn',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ==================== CAMERA PREVIEW ====================
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          ),

          // ==================== FACE GUIDE OVERLAY ====================
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 3,
                ),
              ),
            ),
          ),

          // ==================== INSTRUCTIONS ====================
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Đặt mặt vào khung hình',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chụp chính diện - Ánh sáng đủ - Mặt rõ ràng',
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
            left: 40,
            child: GestureDetector(
              onTap: _isProcessing ? null : _pickImageFromGallery,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isProcessing
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_library,
                  size: 30,
                  color: _isProcessing ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ),

          // ==================== CAPTURE BUTTON (CENTER) ====================
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  // Main capture button
                  GestureDetector(
                    onTap: _isProcessing ? null : _captureAndDetect,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProcessing ? Colors.grey : Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
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
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isProcessing ? 'Đang xử lý...' : 'Chụp ảnh',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== PREVIEW CAPTURED IMAGE ====================
          if (_capturedImage != null)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
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

// ==================== TIP ITEM WIDGET ====================

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
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}