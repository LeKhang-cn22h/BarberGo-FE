import 'dart:io';
import 'package:barbergofe/views/acne/widgets/camera/camera_preview_widget.dart';
import 'package:barbergofe/views/acne/widgets/camera/capture_button.dart';
import 'package:barbergofe/views/acne/widgets/camera/captured_preview.dart';
import 'package:barbergofe/views/acne/widgets/camera/gallery_button.dart';
import 'package:barbergofe/views/acne/widgets/camera/instruction_overlay.dart';
import 'package:barbergofe/views/acne/widgets/camera/tips_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';  // ← THÊM
import '../../viewmodels/acne/acne_viewmodel.dart';
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
  final ImagePicker _picker = ImagePicker();

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
      print(' Error picking image: $e');

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
      print(' Error: $e');

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
                    ' Đang phân tích...',
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isPermissionGranted || _permissionError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phát hiện mụn')),
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _requestPermissionAndInitCamera,
                  child: const Text('Thử lại'),
                ),
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


    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Camera không khả dụng')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Phát hiện mụn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showTipsDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreviewWidget(controller: _controller!),
          const InstructionOverlay(),
          GalleryButton(
            isProcessing: _isProcessing,
            onTap: _pickImageFromGallery,
          ),
          CaptureButton(
            isProcessing: _isProcessing,
            onTap: _captureAndDetect,
          ),
          CapturedPreview(image: _capturedImage),
        ],
      ),
    );
  }
}