class Source {
  final String content;
  final Map<String, dynamic> metadata;
  final double similarity;

  Source({
    required this.content,
    required this.metadata,
    required this.similarity,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      content: json['content'] ?? '',
      metadata: json['metadata'] ?? {},
      similarity: (json['similarity'] as num).toDouble(),
    );
  }
}
