import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing camera: $e');
      _isInitialized = false;
    }
  }

  Future<File?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Camera not initialized');
      return null;
    }

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String picturePath = path.join(
        appDir.path,
        'hairstyle_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile picture = await _controller!.takePicture();
      final File imageFile = File(picture.path);

      // Copy to app directory for persistence
      await imageFile.copy(picturePath);
      return File(picturePath);
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final currentMode = _controller!.value.flashMode;
    FlashMode newMode;

    switch (currentMode) {
      case FlashMode.off:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
      case FlashMode.auto:
        newMode = FlashMode.off;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    await _controller!.setFlashMode(newMode);
  }

  Future<void> switchCamera() async {
    if (_controller == null) return;

    final cameras = await availableCameras();
    final currentCamera = _controller!.description;
    CameraDescription? newCamera;

    if (currentCamera.lensDirection == CameraLensDirection.back) {
      newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    } else {
      newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
    }

    if (newCamera != null) {
      await _controller!.dispose();
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    }
  }
}