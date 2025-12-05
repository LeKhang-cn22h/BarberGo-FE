// lib/core/utils/auth_storage.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // Keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyIntroSeen = 'intro_seen';

  // ==================== INTRO TRACKING ====================

  /// Check if user has seen intro
  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIntroSeen) ?? false;
  }

  /// Mark intro as seen
  static Future<void> markIntroAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIntroSeen, true);
    print('[AUTH STORAGE] Intro marked as seen');
  }

  // ==================== SAVE DATA ====================

  static Future<void> saveAuthData({
    required String accessToken,
    String? refreshToken,
    required String userId,
    required String email,
    required String fullName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, fullName);
    await prefs.setBool(_keyIsLoggedIn, true);

    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }

    print(' [AUTH STORAGE] Auth data saved');
    print('   User ID: $userId');
    print('   Email: $email');
  }

  // ==================== GET DATA ====================

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ==================== CLEAR DATA ====================

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.setBool(_keyIsLoggedIn, false);

    print('[AUTH STORAGE] Auth data cleared');
  }

  // ==================== HELPERS ====================

  static Future<Map<String, dynamic>> getAppState() async {
    final SeenIntro = await hasSeenIntro();
    final isLoggedIn = await AuthStorage.isLoggedIn();
    final token = await getAccessToken();

    return {
      'has_seen_intro': SeenIntro,
      'is_logged_in': isLoggedIn,
      'has_token': token != null,
    };
  }

  static Future<void> printAllData() async {
    final prefs = await SharedPreferences.getInstance();
    print(' [AUTH STORAGE] Current stored data:');
    print('   intro_seen: ${prefs.getBool(_keyIntroSeen)}');
    print('   is_logged_in: ${prefs.getBool(_keyIsLoggedIn)}');
    print('   access_token: ${prefs.getString(_keyAccessToken)?.substring(0, 20) ?? "null"}...');
    print('   user_id: ${prefs.getString(_keyUserId)}');
    print('   email: ${prefs.getString(_keyUserEmail)}');
    print('   name: ${prefs.getString(_keyUserName)}');
  }
}