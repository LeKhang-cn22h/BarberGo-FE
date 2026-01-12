import 'dart:io';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:barbergofe/models/hair/hairstyle_repository.dart';
import 'package:flutter/material.dart';
enum HairStyleState {
  initial,
  loading,
  loaded,
  error,
}

class HairStyleViewModel extends ChangeNotifier {
  final HairStyleRepository _repository = HairStyleRepository();

  HairStyleState _state = HairStyleState.initial;
  HairStyleResponse? _response;
  List<HairStyleInfo> _styles = [];
  String? _errorMessage;
  File? _selectedImage;

  HairStyleState get state => _state;
  HairStyleResponse? get response => _response;
  List<HairStyleInfo> get styles => _styles;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  // Load available styles
  Future<void> loadStyles() async {
    try {
      _state = HairStyleState.loading;
      _errorMessage = null;
      notifyListeners();

      _styles = await _repository.getAvailableStyles();

      _state = HairStyleState.loaded;
      notifyListeners();
    } catch (e) {
      _state = HairStyleState.error;
      _errorMessage = 'Failed to load styles: $e';
      notifyListeners();
    }
  }

  // Set selected image
  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  // Generate hairstyle
  Future<void> generateHairStyle({
    required String styleId,
    int? seed,
    int steps = 30,
    double denoisingStrength = 0.35,
    bool returnMask = false,
  }) async {
    if (_selectedImage == null) {
      _errorMessage = 'Please select an image first';
      _state = HairStyleState.error;
      notifyListeners();
      return;
    }

    try {
      _state = HairStyleState.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.generateHairStyle(
        imageFile: _selectedImage!,
        style: styleId,
        seed: seed,
        steps: steps,
        denoisingStrength: denoisingStrength,
        returnMask: returnMask,
      );

      _response = result;
      _state = HairStyleState.loaded;
      notifyListeners();
    } catch (e) {
      _state = HairStyleState.error;
      _errorMessage = 'Generation failed: $e';
      notifyListeners();
    }
  }

  // Reset state
  void reset() {
    _state = HairStyleState.initial;
    _response = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Get style by ID
  HairStyleInfo? getStyleById(String styleId) {
    try {
      return _styles.firstWhere((style) => style.id == styleId);
    } catch (e) {
      return null;
    }
  }
}