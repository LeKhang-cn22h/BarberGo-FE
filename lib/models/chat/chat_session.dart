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

  /// Dùng để cập nhật local sau khi đổi tên session
  ChatSession copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, userId: $userId, title: $title, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}