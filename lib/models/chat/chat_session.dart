class ChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
