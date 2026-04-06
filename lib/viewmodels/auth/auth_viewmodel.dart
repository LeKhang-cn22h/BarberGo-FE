import 'dart:async';

import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/auth/user_model.dart';
import 'package:barbergofe/services/auth_service.dart';
import 'package:barbergofe/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:barbergofe/api/auth_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthViewModel extends ChangeNotifier {
  final GoogleAuthService googleAuthService;
  AuthViewModel({required this.googleAuthService});


  final AuthService _authService = AuthService();
  final AuthApi _authApi=AuthApi();

  // ==================== STATE ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _userId;
  String? get userId => _userId;

  bool get isAuthenticated => _currentUser != null && _accessToken != null;

  // ==================== INIT ====================

  Future<void> init() async {
    print(' [AUTH VIEWMODEL] Initializing...');

    try {
      final isLoggedIn = await _authService.isAuthenticated();

      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _accessToken = await AuthStorage.getAccessToken();
        _userId = await AuthStorage.getUserId();

        print(' [AUTH VIEWMODEL] User logged in: ${_currentUser?.fullName}');
        notifyListeners();
      } else {
        print('ℹ [AUTH VIEWMODEL] No user logged in');
      }
    } catch (e) {
      print(' [AUTH VIEWMODEL] Init error: $e');
    }
  }

  // ==================== REGISTER ====================

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    print('🟦 [AUTH VIEWMODEL] Register called');

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      print('[AUTH VIEWMODEL] Registration successful');

      _setSuccess(response.message);
      _setLoading(false);

      return true;

    } catch (e) {
      print(' [AUTH VIEWMODEL] Registration failed: $e');
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== LOGIN ====================
  Future<bool> loginWithGG() async {
    _setLoading(true);
    _clearMessages();

    final completer = Completer<bool>();
    late StreamSubscription sub;

    sub = googleAuthService.authEvents.listen(
          (event) async {
        print('📡 Auth event: $event');

        if (event is! GoogleSignInAuthenticationEventSignIn) return;

        final GoogleSignInAccount account = event.user;
        print('Google account obtained');

        final email = account.email;
        final displayName = account.displayName;
        final googleId = account.id;
        final photoUrl = account.photoUrl;

        final auth = account.authentication;
        final idToken = auth.idToken;

        final payload = {
          'email': email,
          'display_name': displayName,
          'google_id': googleId,
          'photo_url': photoUrl,
          'id_token': idToken,
        };

        print('💾 SEND TO BACKEND');
        print(jsonEncode(payload));

        try {
          // Gọi API và đợi response
          final response = await _authService.loginGG(idToken: idToken.toString());

          await AuthStorage.saveAuthData(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? '',
            userId: response.user.id,
            email: response.user.email,
            fullName: response.user.fullName,
          );

          // 3. Set session vào Supabase (QUAN TRỌNG!)
          if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
            try {
              await Supabase.instance.client.auth.recoverSession(
                  '''{"access_token":"${response.accessToken}","refresh_token":"${response.refreshToken}"}'''
              );
              print('Supabase session restored');
            } catch (sessionError) {
              print('⚠Failed to set Supabase session: $sessionError');
            }
          }
          // Lưu vào state
          _currentUser = response.user;
          _accessToken = response.accessToken;
          _userId = response.user.id;

          notifyListeners();
          _setLoading(false);

          await sub.cancel();
          completer.complete(true); // Báo thành công

        } catch (e) {
          print('Backend login failed: $e');
          _setError('Đăng nhập thất bại: ${_formatErrorMessage(e)}');
          _setLoading(false);
          await sub.cancel();
          completer.complete(false); // Báo thất bại
        }
      },
      onError: (e) async {
        print('Google Sign-In error: $e');
        if (e is PlatformException && e.code == 'sign_in_canceled') {
          print(' User cancelled Google Sign-In');
          _setLoading(false);
          await sub.cancel();
          completer.complete(false);
          return;
        }

        if (e.toString().contains('canceled') ||
            e.toString().contains('cancelled')) {
          print('User cancelled Google Sign-In');
          _setLoading(false);
          await sub.cancel();
          completer.complete(false);
          return;
        }

        // Các lỗi khác mới hiển thị error message
        _setError('Đăng nhập Google thất bại');
        _setLoading(false);
        await sub.cancel();
        completer.complete(false);
      },
    );
    try {
      await googleAuthService.signIn();
    } catch (e) {
      // HANDLE: User cancel/dismiss dialog
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled') ||
          e.toString().contains('activity is cancelled by the user')) {
        print('User cancelled Google Sign-In dialog');
        _setLoading(false);
        await sub.cancel();
        return false;
      }

      // Lỗi khác
      print(' Google Sign-In failed: $e');
      _setError('Đăng nhập Google thất bại');
      _setLoading(false);
      await sub.cancel();
      return false;
    }
    return completer.future;
  }



  Future<bool> login({
    required String email,
    required String password,
  }) async {
    print('🟦 [AUTH VIEWMODEL] Login called');

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _accessToken = response.accessToken;
      _userId = response.user.id;

      print('[AUTH VIEWMODEL] Login successful');
      print('   User: ${_currentUser?.fullName}');
      print('   User ID: $_userId');

      _setLoading(false);
      notifyListeners();

      return true;

    } catch (e) {
      print('[AUTH VIEWMODEL] Login failed: $e');
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== FORGOT PASSWORD ====================

  Future<bool> forgotPassword({required String email}) async {
    print('🟦 [AUTH VIEWMODEL] Forgot password called');

    _setLoading(true);
    _clearMessages();

    try {
      final result = await _authService.forgotPassword(email: email);

      _setSuccess(result['message'] ?? 'Email đặt lại mật khẩu đã được gửi');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== RESET PASSWORD ====================

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    print('[AUTH VIEWMODEL] Reset password called');

    _setLoading(true);
    _clearMessages();

    try {
      final result = await _authService.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      _setSuccess(result['message'] ?? 'Đặt lại mật khẩu thành công');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== RESEND CONFIRMATION ====================

  Future<bool> resendConfirmation({required String email}) async {
    print('🟦 [AUTH VIEWMODEL] Resend confirmation called');

    _setLoading(true);
    _clearMessages();

    try {
      final result = await _authService.resendConfirmation(email: email);

      _setSuccess(result['message'] ?? 'Email xác nhận đã được gửi lại');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }
// ==================== LOGOUT ====================

  Future<void> logout() async {
    print('[AUTH VIEWMODEL] Logout called');

    try {
      //  1. Clear FCM token trước khi logout
      try {
        final userId = await AuthStorage.getUserId();
        if (userId != null) {
          await Supabase.instance.client
              .from('users')
              .update({'fcm_token': null})
              .eq('id', userId);
          print(' [AUTH VIEWMODEL] FCM token cleared');
        }
      } catch (fcmError) {
        print(' [AUTH VIEWMODEL] FCM cleanup error: $fcmError');
      }

      // 2. Logout từ backend
      await _authService.logout();

      // 3. Logout từ Google
      try {
        await googleAuthService.signOut();
        print(' [AUTH VIEWMODEL] Google sign out successful');
      } catch (googleError) {
        print(' [AUTH VIEWMODEL] Google sign out error: $googleError');
      }

      // 4. Clear local state
      _currentUser = null;
      _accessToken = null;
      _userId = null;
      _clearMessages();

      notifyListeners();

      print('[AUTH VIEWMODEL] Logout successful');

    } catch (e) {
      print(' [AUTH VIEWMODEL] Logout error: $e');

      // Vẫn clear local state dù có lỗi
      _currentUser = null;
      _accessToken = null;
      _userId = null;
      notifyListeners();
    }
  }

  // ==================== HELPERS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _formatErrorMessage(dynamic error) {
    String message = error.toString();
    message = message.replaceAll('Exception: ', '');

    if (message.contains('Email đã được đăng ký')) {
      return 'Email này đã được sử dụng';
    } else if (message.contains('Email hoặc mật khẩu không đúng')) {
      return 'Email hoặc mật khẩu không chính xác';
    } else if (message.contains('Email chưa được xác nhận')) {
      return 'Vui lòng xác nhận email trước khi đăng nhập';
    } else if (message.contains('timeout')) {
      return 'Không thể kết nối server';
    } else if (message.contains('SocketException')) {
      return 'Không có kết nối internet';
    }

    return message;
  }
}