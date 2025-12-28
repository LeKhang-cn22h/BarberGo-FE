import 'source.dart';

class ChatResponse {
  final String sessionId;
  final String answer;
  final String confidence;
  final List<Source>? sources;

  ChatResponse({
    required this.sessionId,
    required this.answer,
    required this.confidence,
    this.sources,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      sessionId: json['session_id'],
      answer: json['answer'],
      confidence: json['confidence'],
      sources: json['sources'] != null
          ? (json['sources'] as List)
          .map((e) => Source.fromJson(e))
          .toList()
          : null,
    );
  }
}
