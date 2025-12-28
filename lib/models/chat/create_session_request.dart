class CreateSessionRequest {
  final String userId;
  final String title;

  CreateSessionRequest({
    required this.userId,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
    };
  }
}
