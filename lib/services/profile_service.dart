import 'dart:io';
import 'package:barbergofe/models/profile/profile_model.dart';

import '../api/profile_api.dart';


class ProfileService {
  final ProfileApi _api = ProfileApi();

  // ==================== GET PROFILE ====================
  Future<ProfileGetResponse> getProfile() async {
    try {
      final response = await _api.getProfile();
      return ProfileGetResponse.fromJson(response);
    } catch (e) {
      print('❌ [ProfileService] Get profile error: $e');
      return ProfileGetResponse(
        success: false,
        message: 'Không thể tải thông tin profile: $e',
      );
    }
  }

  // ==================== UPDATE PROFILE WITH AVATAR ====================
  Future<ProfileUpdateResponse> updateProfileWithAvatar({
    required String fullName,
    required String phone,
    required File avatarFile,
  }) async {
    try {
      print('🔵 [ProfileService] Updating profile with avatar...');
      final response = await _api.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarFile: avatarFile,
      );

      final result = ProfileUpdateResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] Profile updated with avatar successfully');
      } else {
        print('❌ [ProfileService] Failed to update profile: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Update profile error: $e');
      return ProfileUpdateResponse(
        success: false,
        message: 'Không thể cập nhật profile: $e',
      );
    }
  }

  // ==================== UPDATE PROFILE BASIC (NO AVATAR) ====================
  Future<ProfileUpdateResponse> updateProfileBasic({
    required String fullName,
    required String phone,
  }) async {
    try {
      print('🔵 [ProfileService] Updating profile (basic info only)...');
      final response = await _api.updateProfileBasic(
        fullName: fullName,
        phone: phone,
      );

      final result = ProfileUpdateResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] Profile updated successfully');
      } else {
        print('❌ [ProfileService] Failed to update profile: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Update profile error: $e');
      return ProfileUpdateResponse(
        success: false,
        message: 'Không thể cập nhật profile: $e',
      );
    }
  }

  // ==================== UPLOAD AVATAR ONLY ====================
  Future<AvatarUploadResponse> uploadAvatar({
    required File avatarFile,
  }) async {
    try {
      print('🔵 [ProfileService] Uploading avatar...');
      final response = await _api.uploadAvatar(avatarFile: avatarFile);

      final result = AvatarUploadResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] Avatar uploaded successfully');
      } else {
        print('❌ [ProfileService] Failed to upload avatar: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Upload avatar error: $e');
      return AvatarUploadResponse(
        success: false,
        message: 'Không thể tải lên avatar: $e',
      );
    }
  }

  // ==================== DELETE PROFILE ====================
  Future<DeleteProfileResponse> deleteProfile() async {
    try {
      print('🔵 [ProfileService] Deleting profile...');
      final response = await _api.deleteProfile();

      final result = DeleteProfileResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] Profile deleted successfully');
      } else {
        print('❌ [ProfileService] Failed to delete profile: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Delete profile error: $e');
      return DeleteProfileResponse(
        success: false,
        message: 'Không thể xóa tài khoản: $e',
      );
    }
  }

  // ==================== BLOCK USER ====================
  Future<BlockUserResponse> blockUser(String targetUserId) async {
    try {
      print('🔵 [ProfileService] Blocking user: $targetUserId');
      final response = await _api.blockProfile(targetUserId, block: true);

      final result = BlockUserResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] User blocked successfully');
      } else {
        print('❌ [ProfileService] Failed to block user: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Block user error: $e');
      return BlockUserResponse(
        success: false,
        message: 'Không thể chặn người dùng: $e',
      );
    }
  }

  // ==================== UNBLOCK USER ====================
  Future<BlockUserResponse> unblockUser(String targetUserId) async {
    try {
      print('🔵 [ProfileService] Unblocking user: $targetUserId');
      final response = await _api.blockProfile(targetUserId, block: false);

      final result = BlockUserResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] User unblocked successfully');
      } else {
        print('❌ [ProfileService] Failed to unblock user: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Unblock user error: $e');
      return BlockUserResponse(
        success: false,
        message: 'Không thể bỏ chặn người dùng: $e',
      );
    }
  }

  // ==================== GET ALL USERS (ADMIN) ====================
  Future<GetAllUsersResponse> getAllUsers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔵 [ProfileService] Getting all users (page: $page, limit: $limit)...');
      final response = await _api.getAllUsers(page: page, limit: limit);

      final result = GetAllUsersResponse.fromJson(response);

      if (result.success) {
        print('✅ [ProfileService] Got ${result.users.length} users');
      } else {
        print('❌ [ProfileService] Failed to get users: ${result.message}');
      }

      return result;
    } catch (e) {
      print('❌ [ProfileService] Get all users error: $e');
      return GetAllUsersResponse(
        success: false,
        message: 'Không thể tải danh sách người dùng: $e',
        users: [],
      );
    }
  }
}