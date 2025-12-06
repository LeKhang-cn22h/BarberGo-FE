// ==================== Profile Update Response ====================
import 'package:barbergofe/models/auth/user_model.dart';

class ProfileUpdateResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final int? statusCode;

  ProfileUpdateResponse({
    required this.success,
    required this.message,
    this.user,
    this.statusCode,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['data'] != null ? UserModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Profile Get Response ====================
class ProfileGetResponse {
  final bool success;
  final String? message;
  final UserModel? user;
  final int? statusCode;

  ProfileGetResponse({
    required this.success,
    this.message,
    this.user,
    this.statusCode,
  });

  factory ProfileGetResponse.fromJson(Map<String, dynamic> json) {
    return ProfileGetResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['data'] != null ? UserModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Avatar Upload Response ====================
class AvatarUploadResponse {
  final bool success;
  final String message;
  final String? avatarUrl;
  final int? statusCode;

  AvatarUploadResponse({
    required this.success,
    required this.message,
    this.avatarUrl,
    this.statusCode,
  });

  factory AvatarUploadResponse.fromJson(Map<String, dynamic> json) {
    return AvatarUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      avatarUrl: json['data']?['avatar_url'],
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Block/Unblock Response ====================
class BlockUserResponse {
  final bool success;
  final String message;
  final int? statusCode;

  BlockUserResponse({
    required this.success,
    required this.message,
    this.statusCode,
  });

  factory BlockUserResponse.fromJson(Map<String, dynamic> json) {
    return BlockUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Delete Profile Response ====================
class DeleteProfileResponse {
  final bool success;
  final String message;
  final int? statusCode;

  DeleteProfileResponse({
    required this.success,
    required this.message,
    this.statusCode,
  });

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Get All Users Response ====================
class GetAllUsersResponse {
  final bool success;
  final String? message;
  final List<UserModel> users;
  final int? statusCode;

  GetAllUsersResponse({
    required this.success,
    this.message,
    required this.users,
    this.statusCode,
  });

  factory GetAllUsersResponse.fromJson(Map<String, dynamic> json) {
    List<UserModel> usersList = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        usersList = (json['data'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
      }
    }

    return GetAllUsersResponse(
      success: json['success'] ?? false,
      message: json['message'],
      users: usersList,
      statusCode: json['statusCode'],
    );
  }
}