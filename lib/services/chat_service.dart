import 'dart:async';
import 'dart:core';
import 'package:barbergofe/api/chat_api.dart';
import 'package:barbergofe/models/chat/chat_history_response.dart';
import 'package:barbergofe/models/chat/chat_req.dart';
import 'package:barbergofe/models/chat/chat_response.dart';
import 'package:barbergofe/models/chat/chat_sessions_response.dart';
import 'package:barbergofe/models/chat/create_session_request.dart';
import 'package:barbergofe/models/chat/update_session_request.dart';
class ChatService{
  final _chatApi=ChatAPI();

  //create chat
  Future<ChatResponse> createChat(ChatRequest req) async{
    try{
      return await _chatApi.createChat(req);
    }catch(e){
      print('ChatService - createChat error: $e');
      rethrow;
    }
  }
  //====session management====
//tạo session mới thủ công
Future<Map<String,dynamic>> createSession(CreateSessionRequest req) async {
  try {
    return await _chatApi.createSession(req);
  } catch (e) {
    print("ChatService - createSession error: $e");
    rethrow;
  }
}

//lấy danh sách sessions của user
Future<ChatSessionsResponse> getUserSession({
    required String UserId,
  int limit=20
}) async{
    try {
      return await _chatApi.getUserSessions(userId: UserId);
    }
    catch(e){
      print("ChatService - getUserSessions error: $e");
      rethrow;
    }
}

//lây lịch sử chat trong sesion
Future<ChatHistoryResponse> getChatHistory({
    required String sessionId,
}) async {
    try {
      return await _chatApi.getChatHistory(sessionId: sessionId);
    }
    catch(e) {
      print("ChatService - getChatHistory error: $e");
      rethrow;
    }
}
//đổi tên session
Future<Map<String,dynamic>> updateSessionTitle({
    required String sessionId,
    required UpdateSessionRequest,
}) async{
    try{
      return await _chatApi.updateSessionTitle(sessionId: sessionId, req: UpdateSessionRequest);
      }catch(e){
      print("ChatService - updateSessionTitle error: $e");
      rethrow;
    }
}
//xóa session
Future<Map<String,dynamic>> deleteSession({
    required String sessionId,
}) async{
    try{
      return await _chatApi.deleteSession(sessionId: sessionId);
    }catch(e){
      print("ChatService - deleteSession error: $e");
      rethrow;
    }
}

}