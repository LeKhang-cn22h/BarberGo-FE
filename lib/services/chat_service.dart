import 'dart:async';
import 'package:barbergofe/api/chat_api.dart';
import 'package:barbergofe/models/chat/chat_history_response.dart';
import 'package:barbergofe/models/chat/chat_req.dart';
import 'package:barbergofe/models/chat/chat_response.dart';
import 'package:barbergofe/models/chat/chat_sessions_response.dart';
import 'package:barbergofe/models/chat/create_session_request.dart';
import 'package:barbergofe/models/chat/update_session_request.dart';
import 'package:barbergofe/models/chat/barber_search_response.dart';

class ChatService {
  final _chatApi = ChatAPI();

  // ==================== CHAT ====================

  Future<ChatResponse> createChat(ChatRequest req) async {
    try {
      return await _chatApi.createChat(req);
    } catch (e) {
      print('ChatService - createChat error: $e');
      rethrow;
    }
  }

  // ==================== SESSION ====================

  Future<Map<String, dynamic>> createSession(CreateSessionRequest req) async {
    try {
      return await _chatApi.createSession(req);
    } catch (e) {
      print('ChatService - createSession error: $e');
      rethrow;
    }
  }

  Future<ChatSessionsResponse> getUserSession({
    required String userId,
    int limit = 20,
  }) async {
    try {
      return await _chatApi.getUserSessions(userId: userId, limit: limit);
    } catch (e) {
      print('ChatService - getUserSessions error: $e');
      rethrow;
    }
  }

  Future<ChatHistoryResponse> getChatHistory({
    required String sessionId,
  }) async {
    try {
      return await _chatApi.getChatHistory(sessionId: sessionId);
    } catch (e) {
      print('ChatService - getChatHistory error: $e');
      rethrow;
    }
  }

  // FIX: tham số đúng tên
  Future<Map<String, dynamic>> updateSessionTitle({
    required String sessionId,
    required UpdateSessionRequest req,
  }) async {
    try {
      return await _chatApi.updateSessionTitle(sessionId: sessionId, req: req);
    } catch (e) {
      print('ChatService - updateSessionTitle error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteSession({
    required String sessionId,
  }) async {
    try {
      return await _chatApi.deleteSession(sessionId: sessionId);
    } catch (e) {
      print('ChatService - deleteSession error: $e');
      rethrow;
    }
  }

  // ==================== BARBER SUGGEST ====================

  Future<BarberSearchResponse> searchBarber({
    required String query,
    int topK = 3,
    double threshold = 0.5,
  }) async {
    try {
      return await _chatApi.searchBarber(
        query: query,
        topK: topK,
        threshold: threshold,
      );
    } catch (e) {
      print('ChatService - searchBarber error: $e');
      rethrow;
    }
  }
}