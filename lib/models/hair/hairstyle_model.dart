class HairStyleRequest {
  final String imagePath;
  final String style;
  final int? seed;
  final int steps;
  final double denoisingStrength;
  final bool returnMask;

  HairStyleRequest({
    required this.imagePath,
    required this.style,
    this.seed,
    this.steps = 30,
    this.denoisingStrength = 0.35,
    this.returnMask = false,
  });

  Map<String, dynamic> toJson() => {
    'steps': steps,
    'denoising_strength': denoisingStrength,
    'return_mask': returnMask,
    if (seed != null) 'seed': seed,
  };
}

class HairStyleResponse {
  final String? imageBase64;
  final String? maskBase64;
  final String style;
  final int? seed;
  final bool faceDetected;
  final Map<String, String> prompts;
  final String? error;

  HairStyleResponse({
    this.imageBase64,
    this.maskBase64,
    required this.style,
    this.seed,
    required this.faceDetected,
    required this.prompts,
    this.error,
  });

  factory HairStyleResponse.fromJson(Map<String, dynamic> json) {
    return HairStyleResponse(
      imageBase64: json['image']?.replaceFirst('data:image/png;base64,', ''),
      maskBase64: json['mask']?.replaceFirst('data:image/png;base64,', ''),
      style: json['style'] ?? 'unknown',
      seed: json['seed'],
      faceDetected: json['face_detected'] ?? false,
      prompts: Map<String, String>.from(json['prompts'] ?? {}),
      error: json['error'],
    );
  }
}

class HairStyleInfo {
  final String id;
  final String name;
  final String description;
  final String gender;
  final String category;

  HairStyleInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.gender,
    required this.category,
  });

  factory HairStyleInfo.fromJson(Map<String, dynamic> json) {
    return HairStyleInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      gender: json['gender'],
      category: json['category'],
    );
  }
}