//viewmodels/acne_viewmodel.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/acne_service.dart';
import '../models/acne/acne_response.dart';

class AcneViewModel extends ChangeNotifier {
  final AcneService service = AcneService();

  File? leftImage;
  File? frontImage;
  File? rightImage;

  int captureStep = 0; // 0-left, 1-front, 2-right

  bool isLoading = false;
  AcneResponse? response;
  String? error;

  void setImage(File img) {
    if (captureStep == 0) {
      leftImage = img;
    } else if (captureStep == 1) {
      frontImage = img;
    } else if (captureStep == 2) {
      rightImage = img;
    }
    captureStep++;
    notifyListeners();
  }

  bool get isCaptureDone => captureStep >= 3;

  Future<void> detect() async {
    if (leftImage == null || frontImage == null || rightImage == null) {
      error = "Vui lòng chụp đủ 3 ảnh";
      notifyListeners();
      return;
    }
    try {
      isLoading = true;
      error = null;
      response = null;
      notifyListeners();

      response = await service.detectAcne(leftImage!, frontImage!, rightImage!);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    leftImage = null;
    frontImage = null;
    rightImage = null;
    captureStep = 0;
    isLoading = false;
    response = null;
    error = null;
    notifyListeners();
  }
}
