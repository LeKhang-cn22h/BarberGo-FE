class BarberSearchResult {
  final int id;
  final String content;
  final Map<String, dynamic> metadata;
  final double similarity;

  BarberSearchResult({
    required this.id,
    required this.content,
    required this.metadata,
    required this.similarity,
  });

  factory BarberSearchResult.fromJson(Map<String, dynamic> json) =>
      BarberSearchResult(
        id:         json['id'] ?? 0,
        content:    json['content'] ?? '',
        metadata:   json['metadata'] ?? {},
        similarity: (json['similarity'] as num).toDouble(),
      );

  // Helper getters tiện dùng trong UI
  String get barberName => metadata['barber_name'] ?? '';
  String get area       => metadata['area'] ?? '';
  String get type       => metadata['type'] ?? '';
  String get output     => metadata['output'] ?? content;
}

class BarberSearchResponse {
  final String query;
  final int total;
  final List<BarberSearchResult> results;

  BarberSearchResponse({
    required this.query,
    required this.total,
    required this.results,
  });

  factory BarberSearchResponse.fromJson(Map<String, dynamic> json) =>
      BarberSearchResponse(
        query:   json['query'] ?? '',
        total:   json['total'] ?? 0,
        results: (json['results'] as List? ?? [])
            .map((e) => BarberSearchResult.fromJson(e))
            .toList(),
      );
}