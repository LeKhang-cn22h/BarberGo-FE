class ChatMessage {
  final String id;
  final String role; // user | assistant | system
  final String content;
  final String? confidence;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.confidence,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      confidence: json['confidence'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
