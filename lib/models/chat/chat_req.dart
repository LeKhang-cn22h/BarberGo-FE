  class ChatRequest {
    final String question;
    final String userId;
    final String? sessionId;
    final int topK;
    final bool returnSources;

    ChatRequest({
      required this.question,
      required this.userId,
      this.sessionId,
      this.topK = 3,
      this.returnSources = false,
    });

    Map<String, dynamic> toJson() {
      return {
        'question': question,
        'user_id': userId,
        'session_id': sessionId,
        'top_k': topK,
        'return_sources': returnSources,
      };
    }
  }
