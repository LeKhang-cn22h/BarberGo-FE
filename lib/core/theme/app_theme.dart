import 'package:flutter/material.dart';
import '../constants/color.dart';
// Class AppTheme dùng để định nghĩa các theme cho ứng dụng.
// Theme giúp chuẩn hóa màu sắc, style cho app, tránh việc set màu riêng lẻ ở nhiều nơi.
class AppTheme {

  // Light theme: theme sáng mặc định cho app
  static ThemeData lightTheme = ThemeData(
    // Màu chính của ứng dụng, dùng cho AppBar, Button, ...
    primaryColor: AppColors.primary,

    // Màu nền của Scaffold (background tổng thể của app)
    scaffoldBackgroundColor: AppColors.background,

    // Cấu hình theme cho AppBar
    appBarTheme: const AppBarTheme(
      // Màu nền AppBar
      backgroundColor: AppColors.primary,
      // Màu chữ và icon trong AppBar
      foregroundColor: Colors.white,
    ),

    // Cấu hình theme cho ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Màu nền button
        backgroundColor: AppColors.secondary,
        // Màu chữ trên button
        foregroundColor: AppColors.primary,
      ),
    ),

  );
}