import 'package:flutter/material.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/chat/chat_message.dart';
import 'package:barbergofe/models/chat/chat_req.dart';
import 'package:barbergofe/models/chat/chat_session.dart';
import 'package:barbergofe/models/chat/create_session_request.dart';
import 'package:barbergofe/models/chat/update_session_request.dart';
import 'package:barbergofe/models/chat/barber_search_response.dart';
import 'package:barbergofe/services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final _service = ChatService();

  // ==================== STATE ====================

  List<ChatSession> sessions       = [];
  List<ChatMessage> messages       = [];
  String?           currentSessions;   // session đang chọn
  String?           _userId;

  bool isLoadingSessions = false;
  bool isLoadingMessages = false;
  bool isSending         = false;

  // Barber suggest
  List<BarberSearchResult> suggestResults = [];
  bool isSearching = false;

  final TextEditingController inputController = TextEditingController();

  // ==================== INIT ====================

  Future<void> init() async {
    _userId = await AuthStorage.getUserId();
    if (_userId != null) {
      await loadSessions();
    }
  }

  // ==================== SESSION ====================

  Future<void> loadSessions() async {
    if (_userId == null) return;
    isLoadingSessions = true;
    notifyListeners();

    try {
      final res = await _service.getUserSession(userId: _userId!);
      sessions = res.sessions;
    } catch (e) {
      print('ViewModel - loadSessions error: $e');
    } finally {
      isLoadingSessions = false;
      notifyListeners();
    }
  }

  Future<void> selectSession(String sessionId) async {
    currentSessions = sessionId;
    messages        = [];
    notifyListeners();
    await loadHistory(sessionId);
  }

  Future<void> loadHistory(String sessionId) async {
    isLoadingMessages = true;
    notifyListeners();

    try {
      final res = await _service.getChatHistory(sessionId: sessionId);
      messages = res.messages;
    } catch (e) {
      print('ViewModel - loadHistory error: $e');
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> createNewSession() async {
    if (_userId == null) return;

    try {
      final res = await _service.createSession(
        CreateSessionRequest(userId: _userId!, title: 'Cuộc trò chuyện mới'),
      );
      final newSessionId = res['session_id'] as String;

      await loadSessions();
      await selectSession(newSessionId);
    } catch (e) {
      print('ViewModel - createNewSession error: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _service.deleteSession(sessionId: sessionId);

      if (currentSessions == sessionId) {
        currentSessions = null;
        messages        = [];
      }
      await loadSessions();
    } catch (e) {
      print('ViewModel - deleteSession error: $e');
    }
  }

  Future<void> updateTitle(String sessionId, String newTitle) async {
    try {
      await _service.updateSessionTitle(
        sessionId: sessionId,
        req: UpdateSessionRequest(title: newTitle),
      );
      await loadSessions();
    } catch (e) {
      print('ViewModel - updateTitle error: $e');
    }
  }

  // ==================== CHAT ====================

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty || _userId == null) return;

    isSending = true;

    // Thêm message user lên UI ngay lập tức
    messages.add(ChatMessage(
      id:      DateTime.now().millisecondsSinceEpoch.toString(),
      role:    'user',
      content: question,
    ));
    inputController.clear();
    notifyListeners();

    try {
      final res = await _service.createChat(ChatRequest(
        question:  question,
        userId:    _userId!,
        sessionId: currentSessions,
      ));

      // Cập nhật sessionId nếu là lần đầu chat
      if (currentSessions == null) {
        currentSessions = res.sessionId;
        await loadSessions();
      }

      // Thêm message assistant
      messages.add(ChatMessage(
        id:         DateTime.now().millisecondsSinceEpoch.toString(),
        role:       'assistant',
        content:    res.answer,
        confidence: res.confidence,
      ));
    } catch (e) {
      messages.add(ChatMessage(
        id:      DateTime.now().millisecondsSinceEpoch.toString(),
        role:    'assistant',
        content: 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.',
      ));
      print('ViewModel - sendMessage error: $e');
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  // ==================== BARBER SUGGEST ====================

  Future<void> searchBarber(String query) async {
    if (query.trim().isEmpty) return;

    isSearching = true;
    suggestResults = [];
    notifyListeners();

    try {
      final res = await _service.searchBarber(query: query);
      suggestResults = res.results;
    } catch (e) {
      print('ViewModel - searchBarber error: $e');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clearSuggest() {
    suggestResults = [];
    notifyListeners();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}