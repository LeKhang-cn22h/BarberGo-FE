import 'dart:convert';
import 'package:http/http.dart' as http;
import 'endpoints/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/chat/chat_req.dart';
import '../models/chat/chat_response.dart';
import '../models/chat/create_session_request.dart';
import '../models/chat/update_session_request.dart';
import '../models/chat/chat_history_response.dart';
import '../models/chat/chat_sessions_response.dart';
import 'endpoints/chat_endpoint.dart';

class ChatAPI {
  // ==================== CHAT ====================

  /// Gửi câu hỏi tới chatbot (tự động tạo/tiếp tục session)
  Future<ChatResponse> createChat(ChatRequest req) async {
    final url = Uri.parse(ApiConfig.getUrl(ChatEndpoint.CreateChat));
    print(' POST: $url');

    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode(req.toJson()),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ChatResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to create chat');
      }
    } catch (e) {
      print(' Create chat error: $e');
      rethrow;
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Tạo session mới thủ công
  Future<Map<String, dynamic>> createSession(CreateSessionRequest req) async {
    final url = Uri.parse(ApiConfig.getUrl(ChatEndpoint.CreateChatSession));
    print(' POST: $url');

    try {
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode(req.toJson()),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to create session');
      }
    } catch (e) {
      print(' Create session error: $e');
      rethrow;
    }
  }

  /// Lấy danh sách sessions của user
  Future<ChatSessionsResponse> getUserSessions({
    required String userId,
    int limit = 20,
  }) async {
    final url = Uri.parse(
        ApiConfig.getUrlWithId(ChatEndpoint.GetSessionUser, userId)
    ).replace(queryParameters: {'limit': limit.toString()});

    print(' GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ChatSessionsResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get sessions');
      }
    } catch (e) {
      print(' Get sessions error: $e');
      rethrow;
    }
  }

  /// Lấy lịch sử chat trong session
  Future<ChatHistoryResponse> getChatHistory({
    required String sessionId,
  }) async {
    final url = Uri.parse(
        ApiConfig.getUrlWithIdAndAction(
            ChatEndpoint.GetSessionId1,
            sessionId,
            ChatEndpoint.GetSessionId2
        )
    );

    print(' GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ChatHistoryResponse.fromJson(jsonResponse);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get chat history');
      }
    } catch (e) {
      print(' Get chat history error: $e');
      rethrow;
    }
  }

  /// Đổi tên session
  Future<Map<String, dynamic>> updateSessionTitle({
    required String sessionId,
    required UpdateSessionRequest req,
  }) async {
    final url = Uri.parse(
        ApiConfig.getUrlWithId(ChatEndpoint.UpdateSessionTitle, sessionId)
    );

    print(' PUT: $url');

    try {
      final response = await http.put(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: json.encode(req.toJson()),
      ).timeout(ApiConfig.timeout);

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to update session');
      }
    } catch (e) {
      print(' Update session error: $e');
      rethrow;
    }
  }

  /// Xóa session
  Future<Map<String, dynamic>> deleteSession({
    required String sessionId,
  }) async {
    final url = Uri.parse(
        ApiConfig.getUrlWithId(ChatEndpoint.DeleteSession, sessionId)
    );

    print(' DELETE: $url');

    try {
      final response = await http.delete(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to delete session');
      }
    } catch (e) {
      print(' Delete session error: $e');
      rethrow;
    }
  }
}