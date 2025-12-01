import 'package:barbergofe/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/models/auth/user_model.dart';

class SignInViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? emailError;
  String? passwordError;

  // Validate dữ liệu nhập
  bool validateInputs() {
    bool isValid = true;

    emailError = emailController.text.isNotEmpty && emailController.text.isValidEmail
        ? null
        : "Email không hợp lệ";
    passwordError = passwordController.text.isNotEmpty
        ? null
        : "Mật khẩu không được để trống";

    if (emailError != null || passwordError != null) {
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  // Hàm đăng nhập
  Future<bool> signIn() async {
    if (!validateInputs()) return false;

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final user = User(fullName: "Demo", email: emailController.text, password: passwordController.text);

    isLoading = false;
    notifyListeners();
    return true;
  }

  void disposeController() {
    emailController.dispose();
    passwordController.dispose();
  }
}
