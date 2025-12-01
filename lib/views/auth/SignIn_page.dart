import 'dart:ui';
import 'package:barbergofe/viewmodels/auth/sign_in_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/core/theme/AppImages.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/views/auth/widgets/input_field.dart';
import 'package:barbergofe/views/auth/widgets/password_field.dart';
import 'package:barbergofe/views/auth/widgets/auth_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignInViewModel(),
      child: Consumer<SignInViewModel>(
        builder: (context, viewModel, _) {
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
                  // Hình tròn trang trí
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
                                Text("Barber Go",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text("Style Hair",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Image.asset(AppImages.logo, width: 98, height: 83, fit: BoxFit.contain),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tiêu đề
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

                  // Form đăng nhập
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
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Email"),
                                  InputField(
                                    controller: viewModel.emailController,
                                    errorText: viewModel.emailError,
                                    hint: "Nhập email của bạn",
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  Text("Mật khẩu"),
                                  PasswordField(
                                    controller: viewModel.passwordController,
                                    textError: viewModel.passwordError,
                                  ),
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.center,
                                    child: AppButton(
                                      onPressed: () async {
                                        final isSuccess= await viewModel.signIn();
                                        if(isSuccess){
                                          context.goNamed('home');
                                        }

                                      },
                                      isLoading: viewModel.isLoading,
                                      text: 'ĐĂNG NHẬP',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(onPressed: (){
                                    context.pushNamed('forgot');
                                  }, child: const Text("Quên mật khẩu")),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Chưa có tài khoản?"),
                                      TextButton(
                                        onPressed: () { context.goNamed('signup');},
                                        child: const Text(
                                          "Đăng ký ngay",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            decoration: TextDecoration.underline,
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
      ),
    );
  }
}
