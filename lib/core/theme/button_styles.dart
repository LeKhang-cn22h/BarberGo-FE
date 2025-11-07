import 'package:flutter/material.dart';
import '../constants/color.dart';

class AppButtonStyles {
  static final roundedButton = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  );
}
