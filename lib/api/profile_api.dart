import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../core/utils/api_config.dart';
import '../core/utils/auth_storage.dart';

class ProfileApi {
  // ==================== UPDATE PROFILE WITH FILE UPLOAD ====================
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
    required File? avatarFile, // Thay đổi từ String avatarUrl sang File
  }) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = ApiConfig.getUrlWithId(ApiConfig.usersUpdate, userId);
    print('PUT (multipart): $url');

    try {
      // Tạo multipart request
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Thêm header Authorization
      final token = await AuthStorage.getAccessToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Thêm các trường text
      request.fields['full_name'] = fullName;
      request.fields['phone'] = phone;

      // Thêm file ảnh nếu có
      if (avatarFile != null && await avatarFile.exists()) {
        final fileStream = http.ByteStream(avatarFile.openRead());
        final fileLength = await avatarFile.length();
        final fileName = path.basename(avatarFile.path);

        final multipartFile = http.MultipartFile(
          'avatar', // Tên field mà backend mong đợi
          fileStream,
          fileLength,
          filename: fileName,
        );
        request.files.add(multipartFile);
        print('Adding avatar file: $fileName (${fileLength} bytes)');
      }

      // Gửi request
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Cập nhật thông tin user trong storage
        await AuthStorage.saveAuthData(
          accessToken: token ?? '',
          userId: userId,
          email: await AuthStorage.getUserEmail() ?? '',
          fullName: fullName,
        );

        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': responseData,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Update profile error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ==================== UPDATE PROFILE WITHOUT AVATAR ====================
  Future<Map<String, dynamic>> updateProfileBasic({
    required String fullName,
    required String phone,
  }) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = ApiConfig.getUrlWithId(ApiConfig.usersUpdate, userId);
    print('PUT (JSON): $url');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode({
          'full_name': fullName,
          'phone': phone,
          // Không gửi avatar nếu chỉ update thông tin cơ bản
        }),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await AuthStorage.saveAuthData(
          accessToken: await AuthStorage.getAccessToken() ?? '',
          userId: userId,
          email: await AuthStorage.getUserEmail() ?? '',
          fullName: fullName,
        );

        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': responseData,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Update profile error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ==================== UPLOAD AVATAR ONLY ====================
  Future<Map<String, dynamic>> uploadAvatar({
    required File avatarFile,
  }) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = ApiConfig.getUrlWithId(ApiConfig.usersUpdate, userId);
    print('PUT (avatar only): $url');

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      final token = await AuthStorage.getAccessToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Nếu backend cần các field khác, bạn có thể lấy từ storage
      final currentName = await AuthStorage.getUserName() ?? '';
      final currentPhone = ''; // Lấy từ đâu đó hoặc API get profile

      request.fields['full_name'] = currentName;
      // request.fields['phone'] = currentPhone; // Nếu có

      // Thêm file ảnh
      final fileStream = http.ByteStream(avatarFile.openRead());
      final fileLength = await avatarFile.length();
      final fileName = path.basename(avatarFile.path);

      final multipartFile = http.MultipartFile(
        'avatar',
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      print('Uploading avatar: $fileName (${fileLength} bytes)');

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Avatar uploaded successfully',
          'data': responseData,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to upload avatar',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Upload avatar error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ==================== GET PROFILE ====================
  Future<Map<String, dynamic>> getProfile() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = ApiConfig.getUrlWithId(ApiConfig.usersGetById, userId);
    print('GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Cập nhật thông tin mới nhất vào storage nếu cần
        if (responseData['full_name'] != null) {
          await AuthStorage.saveAuthData(
            accessToken: await AuthStorage.getAccessToken() ?? '',
            userId: userId,
            email: responseData['email'] ?? await AuthStorage.getUserEmail() ?? '',
            fullName: responseData['full_name'],
          );
        }

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to get profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Get profile error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ==================== BLOCK PROFILE ====================
  Future<Map<String, dynamic>> blockProfile(String targetUserId, {bool block = true}) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    // Điều chỉnh endpoint này theo API thực tế
    final url = '${ApiConfig.baseUrl}/users/$targetUserId/${block ? 'block' : 'unblock'}';
    print('${block ? 'POST' : 'DELETE'}: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode({
          'action': block ? 'block' : 'unblock',
          'blocked_by': userId,
        }),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': block ? 'User blocked successfully' : 'User unblocked successfully',
          'data': responseData,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to ${block ? 'block' : 'unblock'} user',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Block profile error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }


  // ==================== DELETE PROFILE ====================
  Future<Map<String, dynamic>> deleteProfile() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = ApiConfig.getUrlWithId(ApiConfig.usersDelete, userId);
    print('DELETE: $url');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Xóa dữ liệu auth sau khi xóa tài khoản thành công
        await AuthStorage.clearAll();

        return {
          'success': true,
          'message': 'Account deleted successfully',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to delete account',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Delete profile error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ==================== GET ALL USERS (Admin) ====================
  Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final url = '${ApiConfig.getUrl(ApiConfig.usersList)}?page=$page&limit=$limit';
    print('GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to get users',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Get all users error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}