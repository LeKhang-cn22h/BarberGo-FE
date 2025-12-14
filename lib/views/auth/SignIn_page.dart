import 'dart:ui';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:barbergofe/viewmodels/auth/sign_in_viewmodel.dart';
import 'package:barbergofe/views/auth/widgets/GlobalLoading.dart';
import 'package:barbergofe/views/auth/widgets/gg_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/core/theme/AppImages.dart';
import 'package:barbergofe/views/auth/widgets/input_field.dart';
import 'package:barbergofe/views/auth/widgets/password_field.dart';
import 'package:barbergofe/views/auth/widgets/auth_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context){
  return ChangeNotifierProvider(create:
  (_) => SignInViewModel(),
    builder: (context, child){
    return _SigninPageContent();
    },
  );
  }
}


class _SigninPageContent extends StatelessWidget {

  // ==================== LOGIN HANDLER ====================

  Future<void> _handleLogin(BuildContext context, bool mounted) async {
    // Get both ViewModels
    final signInVM = context.read<SignInViewModel>();
    final authVM = context.read<AuthViewModel>(); // ⭐ Global auth

    // Validate
    final validationPassed = await signInVM.signIn();

    if (!validationPassed) {
      print(' Validation failed');
      return;
    }

    // Call login
    print('Calling AuthViewModel.login()...');

    final success = await authVM.login(
      email: signInVM.emailController.text.trim(),
      password: signInVM.passwordController.text,
    );

    // Navigate if success
    if (success && mounted) {
      print('Login successful, navigating to home...');
      context.goNamed('home');
    } else {
      print(' Login failed');
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignInViewModel(),
      child: Consumer2<SignInViewModel, AuthViewModel>( //  Listen to both
        builder: (context, signInVM, authVM, _) {
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
                  // Decorative circles (giữ nguyên)
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

                  // Title
                  const Positioned(
                    top: 242,
                    left: 16,
                    child: Text(
                      "ĐĂNG NHẬP",
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

                  // Form
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Email",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InputField(
                                    controller: signInVM.emailController,
                                    errorText: signInVM.emailError,
                                    hint: "Nhập email của bạn",
                                    keyboardType: TextInputType.emailAddress,
                                  ),

                                  const Text(
                                    "Mật khẩu",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  PasswordField(
                                    controller: signInVM.passwordController,
                                    textError: signInVM.passwordError,
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

                                  Align(
                                    alignment: Alignment.center,
                                    child: AppButton(
                                      onPressed:() =>  _handleLogin(context, context.mounted), 
                                      text: 'ĐĂNG NHẬP',   enabled: !authVM.isLoading && !signInVM.isLoading,

                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.center,
                                    child: GgButton(authViewModel: authVM),
                                  ),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        context.pushNamed('forgot');
                                      },
                                      child: const Text(
                                        "Quên mật khẩu",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Chưa có tài khoản?",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.goNamed('signup');
                                        },
                                        child: const Text(
                                          "Đăng ký ngay",
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
                  if (authVM.isLoading)
                    const GlobalLoading(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}