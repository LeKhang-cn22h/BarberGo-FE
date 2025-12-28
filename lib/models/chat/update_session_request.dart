class UpdateSessionRequest {
  final String title;

  UpdateSessionRequest({required this.title});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
    };
  }
}
