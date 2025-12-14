
import 'dart:convert';
import '../api/auth_api.dart';
import '../models/auth/user_model.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_response.dart';
import '../core/utils/auth_storage.dart';

class AuthService {
  final AuthApi _api = AuthApi();

  // ==================== REGISTER ====================

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    print('[SERVICE] Starting registration...');

    try {
      final jsonString = await _api.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      final data = jsonDecode(jsonString);
      final response = RegisterResponse.fromJson(data);

      print('[SERVICE] Registration successful');
      print('   Email confirmed: ${response.emailConfirmed}');

      return response;

    } catch (e, stackTrace) {
      print('[SERVICE] Registration error: $e');
      print(' Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== LOGIN ====================

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    print(' [SERVICE] Starting login...');

    try {
      final jsonString = await _api.login(
        email: email,
        password: password,
      );

      final data = jsonDecode(jsonString);
      final response = LoginResponse.fromJson(data);

      // Save auth data
      await AuthStorage.saveAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        email: response.user.email,
        fullName: response.user.fullName,
      );

      print(' [SERVICE] Login successful');
      print('   User: ${response.user.fullName}');

      await AuthStorage.printAllData();

      return response;

    } catch (e, stackTrace) {
      print(' [SERVICE] Login error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<LoginResponse> loginGG({
    required String idToken,
  }) async {
    print(' [SERVICE] Starting login...');

    try {
      final jsonString = await _api.loginGG(
        id_token: idToken
      );

      final data = jsonDecode(jsonString!);
      final response = LoginResponse.fromJson(data);

      // Save auth data
      await AuthStorage.saveAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        email: response.user.email,
        fullName: response.user.fullName,
      );

      print(' [SERVICE] Login successful');
      print('   User: ${response.user.fullName}');

      await AuthStorage.printAllData();

      return response;

    } catch (e, stackTrace) {
      print(' [SERVICE] Login error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== FORGOT PASSWORD ====================

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    print('[SERVICE] Sending forgot password request...');

    try {
      final jsonString = await _api.forgotPassword(email: email);
      final data = jsonDecode(jsonString);

      print(' [SERVICE] Reset email sent');
      return data;

    } catch (e) {
      print('[SERVICE] Forgot password error: $e');
      rethrow;
    }
  }

  // ==================== RESET PASSWORD ====================

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    print('[SERVICE] Resetting password...');

    try {
      final jsonString = await _api.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      final data = jsonDecode(jsonString);

      print('[SERVICE] Password reset successful');
      return data;

    } catch (e) {
      print('[SERVICE] Reset password error: $e');
      rethrow;
    }
  }

  // ==================== RESEND CONFIRMATION ====================

  Future<Map<String, dynamic>> resendConfirmation({
    required String email,
  }) async {
    print('[SERVICE] Resending confirmation...');

    try {
      final jsonString = await _api.resendConfirmation(email: email);
      final data = jsonDecode(jsonString);

      print(' [SERVICE] Confirmation email sent');
      return data;

    } catch (e) {
      print(' [SERVICE] Resend error: $e');
      rethrow;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    print('[SERVICE] Logging out...');

    try {
      await _api.logout();
      await AuthStorage.clearAll();

      print('[SERVICE] Logout successful');

    } catch (e) {
      print(' [SERVICE] Logout error: $e');
      await AuthStorage.clearAll();
    }
  }

  // ==================== CHECK AUTH ====================

  Future<bool> isAuthenticated() async {
    final isLoggedIn = await AuthStorage.isLoggedIn();
    final token = await AuthStorage.getAccessToken();
    return isLoggedIn && token != null;
  }

  // ==================== GET CURRENT USER ====================

  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await AuthStorage.getUserId();
      final email = await AuthStorage.getUserEmail();
      final name = await AuthStorage.getUserName();

      if (userId == null || email == null || name == null) {
        return null;
      }

      return UserModel(
        id: userId,
        email: email,
        fullName: name,
        emailConfirmed: true,
      );

    } catch (e) {
      print('[SERVICE] Get current user error: $e');
      return null;
    }
  }
}