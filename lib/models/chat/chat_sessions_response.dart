import 'chat_session.dart';

class ChatSessionsResponse {
  final List<ChatSession> sessions;

  ChatSessionsResponse({required this.sessions});

  factory ChatSessionsResponse.fromJson(Map<String, dynamic> json) {
    return ChatSessionsResponse(
      sessions: (json['sessions'] as List)
          .map((e) => ChatSession.fromJson(e))
          .toList(),
    );
  }
}
