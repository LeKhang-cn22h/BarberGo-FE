import 'package:barbergofe/models/auth/user_model.dart';
/// ==================== LOCATION UPDATE MODEL ====================
class LocationUpdate {
  final double lat;
  final double lng;

  LocationUpdate({
    required this.lat,
    required this.lng,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
// ==================== Barber Base Model ====================
class BarberModel {
  final String id;
  final String userId;
  final String name;
  final double?lat;
  final double?lng;
  final String? area;
  final String? address;
  final String? imagePath;
  final double? rank;
  final bool? status;

  BarberModel({
    required this.id,
    required this.userId,
    required this.name,
    this.lat,
    this.lng,
    this.area,
    this.address,
    this.imagePath,
    this.rank,
    this.status,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name'] ?? '',
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      area: json['area'],
      address: json['address'],
      imagePath: json['imagepath'] ?? json['image_path'],
      rank: json['rank'] != null ? double.tryParse(json['rank'].toString()) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'lat':lat,
      'lng':lng,
      'area': area,
      'address': address,
      'imagepath': imagePath,
      'rank': rank,
      'status': status,
    };
  }

  BarberModel copyWith({
    String? id,
    String? userId,
    String? name,
    double?lat,
    double?lng,
    String? area,
    String? address,
    String? imagePath,
    double? rank,
    bool? status,
  }) {
    return BarberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      area: area ?? this.area,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
      rank: rank ?? this.rank,
      status: status ?? this.status,
    );
  }
}

// ==================== Barber Create Request ====================
class BarberCreateRequest {
  final String userId;
  final String name;
  BarberCreateRequest({
    required this.userId,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
    };
  }
}

// ==================== Barber Update Request ====================
class BarberUpdateRequest {
  final String? name;
  final LocationUpdate? location;
  final String? area;
  final String? address;
  final double? rank;
  final bool? status;

  BarberUpdateRequest({
    this.name,
    this.location,
    this.area,
    this.address,
    this.rank,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (location != null) data['location'] = location!.toJson();
    if (area != null) data['area'] = area;
    if (address != null) data['address'] = address;
    if (rank != null) data['rank'] = rank;
    if (status != null) data['status'] = status;

    return data;
  }
}

// ==================== Barber Create Response ====================
class BarberCreateResponse {
  final bool success;
  final String? message;
  final BarberModel? barber;
  final int? statusCode;

  BarberCreateResponse({
    required this.success,
    this.message,
    this.barber,
    this.statusCode,
  });

  factory BarberCreateResponse.fromJson(Map<String, dynamic> json) {
    return BarberCreateResponse(
      success: json['success'] ?? false,
      message: json['message'],
      barber: json['data'] != null ? BarberModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Barber Get Response ====================
class BarberGetResponse {
  final bool success;
  final String? message;
  final BarberModel? barber;
  final int? statusCode;

  BarberGetResponse({
    required this.success,
    this.message,
    this.barber,
    this.statusCode,
  });

  factory BarberGetResponse.fromJson(Map<String, dynamic> json) {
    return BarberGetResponse(
      success: json['success'] ?? false,
      message: json['message'],
      barber: json['data'] != null ? BarberModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Barber Update Response ====================
class BarberUpdateResponse {
  final bool success;
  final String message;
  final BarberModel? barber;
  final int? statusCode;

  BarberUpdateResponse({
    required this.success,
    required this.message,
    this.barber,
    this.statusCode,
  });

  factory BarberUpdateResponse.fromJson(Map<String, dynamic> json) {
    return BarberUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      barber: json['data'] != null ? BarberModel.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Get All Barbers Response ====================
class GetAllBarbersResponse {
  final bool success;
  final String? message;
  final List<BarberModel> barbers;
  final int? statusCode;

  GetAllBarbersResponse({
    required this.success,
    this.message,
    required this.barbers,
    this.statusCode,
  });

  factory GetAllBarbersResponse.fromJson(Map<String, dynamic> json) {
    List<BarberModel> barbersList = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        barbersList = (json['data'] as List)
            .map((barber) => BarberModel.fromJson(barber))
            .toList();
      }
    }

    return GetAllBarbersResponse(
      success: json['success'] ?? false,
      message: json['message'],
      barbers: barbersList,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Barber Search Response ====================
class BarberSearchResponse {
  final bool success;
  final String? message;
  final List<BarberModel> barbers;
  final int total;
  final int page;
  final int limit;
  final int? statusCode;

  BarberSearchResponse({
    required this.success,
    this.message,
    required this.barbers,
    required this.total,
    required this.page,
    required this.limit,
    this.statusCode,
  });

  factory BarberSearchResponse.fromJson(Map<String, dynamic> json) {
    List<BarberModel> barbersList = [];
    final data = json['data'] ?? {};

    if (data['barbers'] != null && data['barbers'] is List) {
      barbersList = (data['barbers'] as List)
          .map((barber) => BarberModel.fromJson(barber))
          .toList();
    }

    return BarberSearchResponse(
      success: json['success'] ?? false,
      message: json['message'],
      barbers: barbersList,
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      limit: data['limit'] ?? 10,
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Barber With User Response ====================
class BarberWithUserModel {
  final BarberModel barber;
  final UserModel? user;

  BarberWithUserModel({
    required this.barber,
    this.user,
  });

  factory BarberWithUserModel.fromJson(Map<String, dynamic> json) {
    return BarberWithUserModel(
      barber: BarberModel.fromJson(json),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}

// ==================== Barber Status Response ====================
class BarberStatusResponse {
  final bool success;
  final String message;
  final bool? status;
  final int? statusCode;

  BarberStatusResponse({
    required this.success,
    required this.message,
    this.status,
    this.statusCode,
  });

  factory BarberStatusResponse.fromJson(Map<String, dynamic> json) {
    return BarberStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['data']?['status'],
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Barber Delete Response ====================
class BarberDeleteResponse {
  final bool success;
  final String message;
  final int? statusCode;

  BarberDeleteResponse({
    required this.success,
    required this.message,
    this.statusCode,
  });

  factory BarberDeleteResponse.fromJson(Map<String, dynamic> json) {
    return BarberDeleteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'],
    );
  }
}

// ==================== Helper Models ====================

// For pagination
class BarberPagination {
  final List<BarberModel> barbers;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  BarberPagination({
    required this.barbers,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

// For filters
class BarberFilter {
  final String? location;
  final String? area;
  final double? minRank;
  final double? maxRank;
  final bool? status;
  final String? search;

  BarberFilter({
    this.location,
    this.area,
    this.minRank,
    this.maxRank,
    this.status,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (location != null) params['location'] = location;
    if (area != null) params['area'] = area;
    if (minRank != null) params['min_rank'] = minRank;
    if (maxRank != null) params['max_rank'] = maxRank;
    if (status != null) params['status'] = status;
    if (search != null) params['search'] = search;

    return params;
  }
}