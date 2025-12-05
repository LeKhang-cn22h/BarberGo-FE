import 'package:flutter/material.dart';

class SignInViewModel extends ChangeNotifier {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Validation errors
  String? emailError;
  String? passwordError;

  // Loading state (chỉ cho validation)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ==================== VALIDATION ====================

  bool _validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      emailError = 'Vui lòng nhập email';
      notifyListeners();
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      emailError = 'Email không hợp lệ';
      notifyListeners();
      return false;
    }

    emailError = null;
    notifyListeners();
    return true;
  }

  bool _validatePassword() {
    final password = passwordController.text;

    if (password.isEmpty) {
      passwordError = 'Vui lòng nhập mật khẩu';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      passwordError = 'Mật khẩu phải có ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }

    passwordError = null;
    notifyListeners();
    return true;
  }

  bool validateAll() {
    final emailValid = _validateEmail();
    final passwordValid = _validatePassword();
    return emailValid && passwordValid;
  }

  // ==================== SIGN IN ====================

  Future<bool> signIn() async {
    print('🔵 [SIGN IN VIEWMODEL] Validating...');

    if (!validateAll()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 200));

    _isLoading = false;
    notifyListeners();

    print('[SIGN IN VIEWMODEL] Validation passed');
    return true;
  }

  void clearErrors() {
    emailError = null;
    passwordError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}