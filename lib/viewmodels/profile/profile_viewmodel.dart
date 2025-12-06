import 'dart:io';
import 'package:barbergofe/models/auth/user_model.dart';
import 'package:barbergofe/services/profile_service.dart';
import 'package:flutter/material.dart';


class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  // ==================== STATE ====================
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUpdating = false;

  // ==================== GETTERS ====================
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUpdating => _isUpdating;

  // ==================== SET CURRENT USER ====================
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  // ==================== LOAD PROFILE ====================
  Future<bool> loadProfile() async {
    print('🔵 [ProfileViewModel] Loading profile...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getProfile();

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _errorMessage = null;
        print('✅ [ProfileViewModel] Profile loaded successfully');
        print('   User: ${_currentUser?.fullName} (${_currentUser?.email})');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Không thể tải thông tin profile';
        print('❌ [ProfileViewModel] Failed to load profile: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi tải profile: $e';
      print('❌ [ProfileViewModel] Load profile error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE PROFILE NAME ====================
  Future<bool> updateName(String newName) async {
    if (_currentUser == null) {
      _errorMessage = 'Không tìm thấy thông tin người dùng';
      notifyListeners();
      return false;
    }

    print('🔵 [ProfileViewModel] Updating name to: $newName');
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.updateProfileBasic(
        fullName: newName,
        phone: _currentUser!.phone ?? '',
      );

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _errorMessage = null;
        print('✅ [ProfileViewModel] Name updated successfully');
        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        print('❌ [ProfileViewModel] Failed to update name: $_errorMessage');
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật tên: $e';
      print('❌ [ProfileViewModel] Update name error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE PROFILE PHONE ====================
  Future<bool> updatePhone(String newPhone) async {
    if (_currentUser == null) {
      _errorMessage = 'Không tìm thấy thông tin người dùng';
      notifyListeners();
      return false;
    }

    print('🔵 [ProfileViewModel] Updating phone to: $newPhone');
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.updateProfileBasic(
        fullName: _currentUser!.fullName,
        phone: newPhone,
      );

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _errorMessage = null;
        print('✅ [ProfileViewModel] Phone updated successfully');
        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        print('❌ [ProfileViewModel] Failed to update phone: $_errorMessage');
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật số điện thoại: $e';
      print('❌ [ProfileViewModel] Update phone error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE AVATAR ====================
  Future<bool> updateAvatar(File avatarFile) async {
    if (_currentUser == null) {
      _errorMessage = 'Không tìm thấy thông tin người dùng';
      notifyListeners();
      return false;
    }

    print('🔵 [ProfileViewModel] Updating avatar...');
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.uploadAvatar(avatarFile: avatarFile);

      if (response.success) {
        // Reload profile để lấy avatar URL mới
        await loadProfile();
        _errorMessage = null;
        print('✅ [ProfileViewModel] Avatar updated successfully');
        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        print('❌ [ProfileViewModel] Failed to update avatar: $_errorMessage');
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật avatar: $e';
      print('❌ [ProfileViewModel] Update avatar error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE FULL PROFILE WITH AVATAR ====================
  Future<bool> updateProfileWithAvatar({
    required String fullName,
    required String phone,
    required File avatarFile,
  }) async {
    print('🔵 [ProfileViewModel] Updating full profile with avatar...');
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.updateProfileWithAvatar(
        fullName: fullName,
        phone: phone,
        avatarFile: avatarFile,
      );

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _errorMessage = null;
        print('✅ [ProfileViewModel] Full profile updated successfully');
        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        print('❌ [ProfileViewModel] Failed to update profile: $_errorMessage');
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật profile: $e';
      print('❌ [ProfileViewModel] Update profile error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== DELETE PROFILE ====================
  Future<bool> deleteProfile() async {
    print('🔵 [ProfileViewModel] Deleting profile...');
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.deleteProfile();

      if (response.success) {
        _currentUser = null;
        _errorMessage = null;
        print('✅ [ProfileViewModel] Profile deleted successfully');
        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        print('❌ [ProfileViewModel] Failed to delete profile: $_errorMessage');
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa tài khoản: $e';
      print('❌ [ProfileViewModel] Delete profile error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== CLEAR ERROR ====================
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== RESET ====================
  void reset() {
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    _isUpdating = false;
    notifyListeners();
  }
}