import 'package:flutter/material.dart';
import '../constants/color.dart';
// Class AppButtonStyles dùng để định nghĩa các style cho button.
// Giúp tái sử dụng style cho nhiều ElevatedButton trong app, tránh lặp code.
class AppButtonStyles {

  // Style cho button bo tròn (rounded) với padding và màu sắc chuẩn
  static final roundedButton = ElevatedButton.styleFrom(
    // Bo góc 12px
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

    // Padding trong button: trái-phải 24, trên-dưới 12
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

    // Màu nền button
    backgroundColor: AppColors.primary,

    // Màu chữ trên button
    foregroundColor: Colors.white,
  );
}