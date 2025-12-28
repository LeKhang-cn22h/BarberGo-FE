
class RatingCreate {
  final String barberId;
  final String userId;
  final double score;

  RatingCreate({
    required this.barberId,
    required this.userId,
    required this.score,
  }) {
    if (score < 0 || score > 5) {
      throw ArgumentError('Điểm đánh giá phải từ 0 đến 5');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'barber_id': barberId,
      'user_id': userId,
      'score': score,
    };
  }
}

// Model cho việc cập nhật rating
class RatingUpdate {
  final double? score;

  RatingUpdate({this.score}) {
    if (score != null && (score! < 0 || score! > 5)) {
      throw ArgumentError('Điểm đánh giá phải từ 0 đến 5');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (score != null) 'score': score,
    };
  }
}

// Model cho response rating
class Rating {
  final int id;
  final String? barberId;
  final String? userId;
  final double? score;
  final DateTime? createdAt;

  Rating({
    required this.id,
    this.barberId,
    this.userId,
    this.score,
    this.createdAt,
  });
//dùng để chuyển đổi từ json sang rating
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as int,
      barberId: json['barber_id'] as String?,
      userId: json['user_id'] as String?,
      score: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
//dùng để chuyển đổi từ rating sang json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'user_id': userId,
      'score': score,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
// ==================== RESPONSE MODELS ====================

/// Response khi tạo/update rating
class RatingResponse {
  final String message;
  final Rating rating;
  final double? barberNewRank;

  RatingResponse({
    required this.message,
    required this.rating,
    this.barberNewRank,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      message: json['message'] as String,
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>),
      barberNewRank: json['barber_new_rank'] != null
          ? (json['barber_new_rank'] as num).toDouble()
          : null,
    );
  }
}

/// Rating với thông tin barber và user (cho get all, get by id)
class RatingWithDetails {
  final int id;
  final String? barberId;
  final String? userId;
  final double? score;
  final DateTime? createdAt;
  final BarberBasicInfo? barber;
  final UserBasicInfo? user;

  RatingWithDetails({
    required this.id,
    this.barberId,
    this.userId,
    this.score,
    this.createdAt,
    this.barber,
    this.user,
  });

  factory RatingWithDetails.fromJson(Map<String, dynamic> json) {
    return RatingWithDetails(
      id: json['id'] as int,
      barberId: json['barber_id'] as String?,
      userId: json['user_id'] as String?,
      score: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      barber: json['barbers'] != null
          ? BarberBasicInfo.fromJson(json['barbers'] as Map<String, dynamic>)
          : null,
      user: json['users'] != null
          ? UserBasicInfo.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Rating với thông tin user (cho get ratings by barber)
class RatingWithUser {
  final int id;
  final String? barberId;
  final String? userId;
  final double? score;
  final DateTime? createdAt;
  final UserInfo? user;

  RatingWithUser({
    required this.id,
    this.barberId,
    this.userId,
    this.score,
    this.createdAt,
    this.user,
  });

  factory RatingWithUser.fromJson(Map<String, dynamic> json) {
    return RatingWithUser(
      id: json['id'] as int,
      barberId: json['barber_id'] as String?,
      userId: json['user_id'] as String?,
      score: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      user: json['users'] != null
          ? UserInfo.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Rating với thông tin barber (cho get ratings by user)
class RatingWithBarber {
  final int id;
  final String? barberId;
  final String? userId;
  final double? score;
  final DateTime? createdAt;
  final BarberInfo? barber;

  RatingWithBarber({
    required this.id,
    this.barberId,
    this.userId,
    this.score,
    this.createdAt,
    this.barber,
  });

  factory RatingWithBarber.fromJson(Map<String, dynamic> json) {
    return RatingWithBarber(
      id: json['id'] as int,
      barberId: json['barber_id'] as String?,
      userId: json['user_id'] as String?,
      score: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      barber: json['barbers'] != null
          ? BarberInfo.fromJson(json['barbers'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Thông tin cơ bản của barber (chỉ có name)
class BarberBasicInfo {
  final String? name;

  BarberBasicInfo({this.name});

  factory BarberBasicInfo.fromJson(Map<String, dynamic> json) {
    return BarberBasicInfo(
      name: json['name'] as String?,
    );
  }
}

/// Thông tin cơ bản của user (có full_name và email)
class UserBasicInfo {
  final String? fullName;
  final String? email;

  UserBasicInfo({
    this.fullName,
    this.email,
  });

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
    );
  }
}

/// Thông tin đầy đủ của user (có thêm avatar)
class UserInfo {
  final String? fullName;
  final String? email;
  final String? avatarUrl;

  UserInfo({
    this.fullName,
    this.email,
    this.avatarUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// Thông tin đầy đủ của barber (có thêm avatar)
class BarberInfo {
  final String? name;
  final String? imagepath;

  BarberInfo({
    this.name,
    this.imagepath,
  });

  factory BarberInfo.fromJson(Map<String, dynamic> json) {
    return BarberInfo(
      name: json['name'] as String?,
      imagepath: json['imagepath'] as String?,
    );
  }
}

/// Điểm trung bình của barber
class BarberAverageRating {
  final String barberId;
  final String barberName;
  final double averageScore;
  final int totalRatings;

  BarberAverageRating({
    required this.barberId,
    required this.barberName,
    required this.averageScore,
    required this.totalRatings,
  });

  factory BarberAverageRating.fromJson(Map<String, dynamic> json) {
    return BarberAverageRating(
      barberId: json['barber_id'] as String,
      barberName: json['barber_name'] as String,
      averageScore: (json['average_score'] as num).toDouble(),
      totalRatings: json['total_ratings'] as int,
    );
  }
}

/// Response khi xóa rating
class DeleteRatingResponse {
  final String message;
  final double? barberNewRank;

  DeleteRatingResponse({
    required this.message,
    this.barberNewRank,
  });

  factory DeleteRatingResponse.fromJson(Map<String, dynamic> json) {
    return DeleteRatingResponse(
      message: json['message'] as String,
      barberNewRank: json['barber_new_rank'] != null
          ? (json['barber_new_rank'] as num).toDouble()
          : null,
    );
  }
}
enum UpdateRatingAction { update, delete, cancel }
class UpdateRatingResult {
  final UpdateRatingAction action;
  final double? newScore;
  UpdateRatingResult({required this.action, this.newScore});
}