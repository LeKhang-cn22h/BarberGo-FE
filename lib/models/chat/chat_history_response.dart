import 'chat_message.dart';

class ChatHistoryResponse {
  final String sessionId;
  final List<ChatMessage> messages;

  ChatHistoryResponse({
    required this.sessionId,
    required this.messages,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      sessionId: json['session_id'],
      messages: (json['messages'] as List)
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
    );
  }
}
