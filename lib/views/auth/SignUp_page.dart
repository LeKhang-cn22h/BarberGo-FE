import 'dart:ui';
import 'package:barbergofe/core/theme/AppImages.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/auth/signup_viewmodel.dart';
import 'package:barbergofe/views/auth/widgets/input_field.dart';
import 'package:barbergofe/views/auth/widgets/password_field.dart';
import 'package:barbergofe/views/auth/widgets/auth_button.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      // ⭐ QUAN TRỌNG: Dùng builder để có context mới
      builder: (context, child) {
        return _SignupPageContent();
      },
    );
  }
}

// ⭐ TÁCH RIÊNG CONTENT RA
class _SignupPageContent extends StatelessWidget {

  // ==================== REGISTER HANDLER ====================

  Future<void> _handleRegister(BuildContext context) async {
    // ✅ BÂY GIỜ CONTEXT NÀY ĐÃ CÓ ACCESS ĐẾN SignUpViewModel
    final signUpVM = context.read<SignUpViewModel>();
    final authVM = context.read<AuthViewModel>();

    // Validate
    print('🔵 Starting validation...');
    final validationPassed = await signUpVM.signUp();

    if (!validationPassed) {
      print('❌ Validation failed');
      return;
    }

    // Call register
    print('🔵 Calling AuthViewModel.register()...');

    final success = await authVM.register(
      email: signUpVM.emailController.text.trim(),
      password: signUpVM.passwordController.text,
      fullName: signUpVM.fullNameController.text.trim(),
      phone: null,
    );

    // Handle result
    if (success && context.mounted) {
      print('✅ Registration successful');

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Đăng ký thành công!', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(
            'Vui lòng kiểm tra email để xác nhận tài khoản trước khi đăng nhập.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog

                // Navigate to signin
                context.pushReplacementNamed(
                  'signin',
                  queryParameters: {
                    'email': signUpVM.emailController.text.trim(),
                  },
                );
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      print('❌ Registration failed');
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Consumer2<SignUpViewModel, AuthViewModel>(
      builder: (context, signUpVM, authVM, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD9D9D9), Color(0xFFEAEAEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // ==================== DECORATIVE CIRCLES ====================

                Positioned(
                  left: -229,
                  top: -58,
                  child: Container(
                    width: 580,
                    height: 580,
                    decoration: const BoxDecoration(
                      color: Color(0xFF67539D),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  left: 150,
                  top: -37,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 276,
                        height: 285,
                        decoration: const BoxDecoration(
                          color: Color(0xFF590798),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Barber Go",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Style Hair",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            AppImages.logo,
                            width: 98,
                            height: 83,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==================== TITLE ====================

                Positioned(
                  top: 242,
                  left: 16,
                  child: const Text(
                    "ĐĂNG KÝ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: 2,
                    ),
                  ),
                ),

                // ==================== REGISTER FORM ====================

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0x4DD9D9D9),
                            borderRadius: BorderRadius.circular(44),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ==================== FULL NAME ====================

                                const Text(
                                  "Họ và Tên",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InputField(
                                  controller: signUpVM.fullNameController,
                                  errorText: signUpVM.fullNameError,
                                  hint: "Nhập họ và tên của bạn",
                                  keyboardType: TextInputType.name,
                                ),

                                // ==================== EMAIL ====================

                                const Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InputField(
                                  controller: signUpVM.emailController,
                                  errorText: signUpVM.emailError,
                                  hint: "Nhập email của bạn",
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                // ==================== PASSWORD ====================

                                const Text(
                                  "Mật khẩu",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                PasswordField(
                                  controller: signUpVM.passwordController,
                                  textError: signUpVM.passwordError,
                                ),

                                // ==================== CONFIRM PASSWORD ====================

                                const Text(
                                  "Nhập lại mật khẩu",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                PasswordField(
                                  controller: signUpVM.confirmPasswordController,
                                  textError: signUpVM.confirmPasswordError,
                                ),

                                // ⭐ ERROR FROM AUTH VIEWMODEL
                                if (authVM.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              authVM.errorMessage!,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                // ==================== REGISTER BUTTON ====================

                                Align(
                                  alignment: Alignment.center,
                                  child: AppButton(
                                    onPressed: () => _handleRegister(context),
                                    enabled: !authVM.isLoading && !signUpVM.isLoading,
                                    text: 'ĐĂNG KÝ',

                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ==================== LOGIN LINK ====================

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Đã có tài khoản?",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.pushNamed('signin');
                                      },
                                      child: const Text(
                                        "Đăng nhập ngay",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}