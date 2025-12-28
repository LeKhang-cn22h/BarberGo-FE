import 'package:barbergofe/models/chat/chat_message.dart';
import 'package:barbergofe/models/chat/chat_req.dart';
import 'package:barbergofe/models/chat/chat_session.dart';
import 'package:barbergofe/models/chat/create_session_request.dart';
import 'package:barbergofe/services/chat_service.dart';
import 'package:flutter/foundation.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class ChatViewModel extends ChangeNotifier{
  final ChatService _chatService=ChatService();
  List<ChatSession> _sessions=[];
  List<ChatMessage> _messages=[];
  String? _sessionId='';
  bool _isLoadingSessions=false;
  bool _isLoadingMessages=false;
  bool _isSending=false;
  String?_error;

  List<ChatSession> get sessions=>_sessions;
  List<ChatMessage> get messages=>_messages;
  String? get sessionId=>_sessionId;
  bool get isLoadingSessions=>_isLoadingSessions;
  bool get isLoadingMessages=>_isLoadingMessages;
  bool get isSending=>_isSending;
  String? get error=>_error;

ChatSession? get currentSessions{
  if(_sessionId==null) return null;
  try{
    return _sessions.firstWhere((session)=>session.id==_sessionId);
  }catch(e)
  {
    return null;
  }
}
Future<void> init()async{
  await fetchSessions();
}
Future<void> fetchSessions()async{
  _setLoadingSessions(true);
  _error=null;
  notifyListeners();
  try{
    final userId= await AuthStorage.getUserId();
    if(userId==null) throw Exception('Vui lòng đăng nhập để sử dụng chat');
    final response= await _chatService.getUserSession(UserId: userId);
    _sessions=response.sessions;
    _sessions.sort((a,b)=>b.createdAt.compareTo(a.createdAt));
  }catch(e){
      _error="tai that bai session";
  }
  finally{
    _setLoadingSessions(false);
    notifyListeners();
  }
}
// 2. Chọn Session và tải lịch sử chat
  Future<void> selectSession(String sessionId) async {
    if (_sessionId == sessionId) return;

    _sessionId = sessionId;
    _messages = []; // Clear tin nhắn cũ để tránh hiển thị sai
    _setLoadingMessages(true);
    notifyListeners();

    try {
      final response = await _chatService.getChatHistory(sessionId: sessionId);
      _messages = response.messages;
      // Sắp xếp tin nhắn cũ nhất lên đầu (để listview hiển thị đúng chiều thời gian)
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      _error = "Không thể tải lịch sử chat: $e";
    } finally {
      _setLoadingMessages(false);
      notifyListeners();
    }
  }

  // 3. Tạo Session mới (Nút New Chat)
  Future<void> createNewSession() async {
    _error = null;
    try {
      final _userId= await AuthStorage.getUserId();
      if(_userId==null) throw Exception("Vui long dang nhap de su dung chat");
      final req = CreateSessionRequest(userId: _userId, title: "New Chat");
      final res = await _chatService.createSession(req);

      // Reload lại danh sách session để hiển thị session mới
      await fetchSessions();

      // Nếu API trả về ID, tự động select nó. Nếu không, select cái đầu tiên
      if (res.containsKey('id')) {
        selectSession(res['id']);
      } else if (_sessions.isNotEmpty) {
        selectSession(_sessions.first.id);
      }
    } catch (e) {
      _error = "Lỗi tạo chat mới: $e";
      notifyListeners();
    }
  }

  // 4. Gửi tin nhắn
  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    final tempSessionId = _sessionId; // Lưu lại ID hiện tại để check null

    _setSending(true);
    _error = null;

    // Optimistic UI: Thêm tin nhắn của User vào list ngay lập tức
    final userMsg = ChatMessage(
      id: "temp_user_${DateTime.now().millisecondsSinceEpoch}",
      role: "user",
      content: question,
      createdAt: DateTime.now(),
    );
    _messages.add(userMsg);
    notifyListeners();

    try {
      final _userId= await AuthStorage.getUserId();
      if(_userId==null) throw Exception("Vui long dang nhap de su dung chat");
      final req = ChatRequest(
        question: question,
        userId: _userId,
        sessionId: tempSessionId, // Nếu null, backend có thể tự tạo session mới
      );

      final response = await _chatService.createChat(req);

      // Nếu session ID thay đổi (trường hợp chat mới chưa có ID), cập nhật lại
      if (tempSessionId == null || tempSessionId != response.sessionId) {
        _sessionId = response.sessionId;
        // Reload session list để hiện session mới tạo bên sidebar
        fetchSessions();
      }

      // Tạo message từ response của AI để hiển thị
      final aiMsg = ChatMessage(
        id: "ai_${DateTime.now().millisecondsSinceEpoch}",
        role: "assistant",
        content: response.answer,
        confidence: response.confidence,
        createdAt: DateTime.now(),
      );

      _messages.add(aiMsg);

    } catch (e) {
      _error = "Gửi tin nhắn thất bại: $e";
      // Có thể xóa tin nhắn user vừa thêm nếu muốn, hoặc hiện nút retry
    } finally {
      _setSending(false);
      notifyListeners();
    }
  }

  // 5. Xóa Session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _chatService.deleteSession(sessionId: sessionId);
      // Xóa khỏi list local
      _sessions.removeWhere((s) => s.id == sessionId);

      // Nếu đang xem session bị xóa, reset về null
      if (_sessionId == sessionId) {
        _sessionId = null;
        _messages = [];
      }
      notifyListeners();
    } catch (e) {
      _error = "Xóa thất bại: $e";
      notifyListeners();
    }
  }

void _setLoadingSessions(bool load){
  _isLoadingSessions=load;
  notifyListeners();
}
void _setLoadingMessages(bool load){
  _isLoadingMessages=load;
  notifyListeners();
}
void _setSending(bool load){
  _isSending=load;
  notifyListeners();
}

void clearError(){
  _error=null;
  notifyListeners();
}
}

