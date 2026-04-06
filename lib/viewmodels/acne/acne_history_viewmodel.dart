import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/acne/acne_response.dart';
import '../../services/acne_storage_service.dart';

class AcneHistoryViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  Future<void> loadResults() async {
    isLoading = true;
    notifyListeners();

    try {
      results = await AcneStorageService.getAllResults();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteResult(int index) async {
    final result = results[index];

    final imagePath = result['image_path'] as String?;
    final jsonPath = result['json_path'] as String?;

    if (imagePath != null) {
      final file = File(imagePath);
      if (file.existsSync()) await file.delete();
    }

    if (jsonPath != null) {
      final file = File(jsonPath);
      if (file.existsSync()) await file.delete();
    }

    results.removeAt(index);
    notifyListeners();
  }

  Future<int> clearOldResults() async {
    final count = await AcneStorageService.deleteOldResults();
    await loadResults();
    return count;
  }

  AcneResponse parseResult(Map<String, dynamic> result) {
    return AcneResponse.fromJson(result['result']);
  }
}
