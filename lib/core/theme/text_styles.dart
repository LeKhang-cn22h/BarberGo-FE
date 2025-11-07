import 'package:flutter/material.dart';
import '../constants/color.dart';

// Class AppTextStyles dùng để định nghĩa các style chữ chuẩn cho app.
// Giúp tái sử dụng, tránh lặp code và dễ dàng chỉnh sửa font size, weight, màu sắc.
class AppTextStyles {

  // Style cho tiêu đề (heading)
  static const heading = TextStyle(
    fontSize: 20,                    // cỡ chữ
    fontWeight: FontWeight.bold,     // chữ đậm
    color: AppColors.textPrimary,    // màu chữ chính
  );

  // Style cho nội dung (body text)
  static const body = TextStyle(
    fontSize: 16,                    // cỡ chữ trung bình
    color: AppColors.textPrimary,    // màu chữ chính
  );

  // Style cho chú thích, text nhỏ (caption)
  static const caption = TextStyle(
    fontSize: 14,                    // cỡ chữ nhỏ
    color: AppColors.textSecondary,  // màu chữ phụ
  );
}