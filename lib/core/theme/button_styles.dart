import 'package:flutter/material.dart';
import '../constants/color.dart';
// Class AppButtonStyles dùng để định nghĩa các style cho button.
// Giúp tái sử dụng style cho nhiều ElevatedButton trong app, tránh lặp code.
class AppButtonStyles {

  // Style cho button bo tròn (rounded) với padding và màu sắc chuẩn
  static final roundedButtonBold = ElevatedButton.styleFrom(
    // Bo góc 12px
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

    // Padding trong button: trái-phải 24, trên-dưới
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),

    // Màu nền button
    backgroundColor: AppColors.primary,

    // Màu chữ trên button
    foregroundColor: Colors.white,
  );
  // Style cho button bo tròn (rounded) với padding và màu sắc chuẩn v2
  static final roundedButtonBold2 = ElevatedButton.styleFrom(
    // Bo góc 12px
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.red,
    // textStyle: const TextStyle(
    //   color: AppColors.primary
    // ),
  );

}
//cách dùng style:AppButtonStyle