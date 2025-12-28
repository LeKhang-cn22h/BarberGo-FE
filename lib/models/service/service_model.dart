// ==================== Service Base Model ====================
class ServiceModel {
  final int id;
  final String barberId;
  final String serviceName;
  final int price;
  final int durationMin;

  ServiceModel({
    required this.id,
    required this.barberId,
    required this.serviceName,
    required this.price,
    required this.durationMin,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      barberId: json['barber_id']?.toString() ?? '',
      serviceName: json['service_name'] ?? '',
      price: json['price'] ?? 0,
      durationMin: json['duration_min'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'service_name': serviceName,
      'price': price,
      'duration_min': durationMin,
    };
  }

  ServiceModel copyWith({
    int? id,
    String? barberId,
    String? serviceName,
    int? price,
    int? durationMin,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      durationMin: durationMin ?? this.durationMin,
    );
  }

  // Helper methods
  double get priceInVND => price.toDouble();
  String get formattedPrice => '${price.toString()}đ';

  String get formattedDuration {
    if (durationMin < 60) {
      return '${durationMin} phút';
    } else {
      final hours = durationMin ~/ 60;
      final minutes = durationMin % 60;
      if (minutes == 0) {
        return '${hours} giờ';
      } else {
        return '${hours} giờ ${minutes} phút';
      }
    }
  }
}

// ==================== Service Create Request ====================
class ServiceCreateRequest {
  final String barberId;
  final String serviceName;
  final int price;
  final int durationMin;

  ServiceCreateRequest({
    required this.barberId,
    required this.serviceName,
    required this.price,
    required this.durationMin,
  });

  Map<String, dynamic> toJson() {
    return {
      'barber_id': barberId,
      'service_name': serviceName,
      'price': price,
      'duration_min': durationMin,
    };
  }
}

// ==================== Service Update Request ====================
class ServiceUpdateRequest {
  final String? barberId;
  final String? serviceName;
  final int? price;
  final int? durationMin;

  ServiceUpdateRequest({
    this.barberId,
    this.serviceName,
    this.price,
    this.durationMin,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (barberId != null) data['barber_id'] = barberId;
    if (serviceName != null) data['service_name'] = serviceName;
    if (price != null) data['price'] = price;
    if (durationMin != null) data['duration_min'] = durationMin;

    return data;
  }
}

// ==================== Get All Services Response ====================
class GetAllServicesResponse {
  final List<ServiceModel> services;

  GetAllServicesResponse({
    required this.services,
  });

  factory GetAllServicesResponse.fromJson(dynamic jsonResponse) {
    List<ServiceModel> servicesList = [];

    if (jsonResponse is List) {
      // API trả về List<Service> trực tiếp
      servicesList = jsonResponse
          .map<ServiceModel>((item) => ServiceModel.fromJson(item))
          .toList();
    }
    else if (jsonResponse is Map<String, dynamic>) {
      // API trả về Map với field 'data'
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        servicesList = (jsonResponse['data'] as List)
            .map<ServiceModel>((item) => ServiceModel.fromJson(item))
            .toList();
      }
    }

    return GetAllServicesResponse(services: servicesList);
  }
}

// ==================== Get Service By ID Response ====================
class GetServiceByIdResponse {
  final ServiceModel service;

  GetServiceByIdResponse({
    required this.service,
  });

  factory GetServiceByIdResponse.fromJson(Map<String, dynamic> json) {
    return GetServiceByIdResponse(
      service: ServiceModel.fromJson(json['data'] ?? json),
    );
  }
}

// ==================== Get Services By Barber Response ====================
class GetServicesByBarberResponse {
  final List<ServiceModel> services;

  GetServicesByBarberResponse({
    required this.services,
  });

  factory GetServicesByBarberResponse.fromJson(dynamic jsonResponse) {
    List<ServiceModel> servicesList = [];

    if (jsonResponse is List) {
      // API trả về List<Service> trực tiếp
      servicesList = jsonResponse
          .map<ServiceModel>((item) => ServiceModel.fromJson(item))
          .toList();
    }
    else if (jsonResponse is Map<String, dynamic>) {
      // API trả về Map với field 'data'
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        servicesList = (jsonResponse['data'] as List)
            .map<ServiceModel>((item) => ServiceModel.fromJson(item))
            .toList();
      }
    }

    return GetServicesByBarberResponse(services: servicesList);
  }
}

// ==================== Service Create Response ====================
class ServiceCreateResponse {
  final ServiceModel service;
  final String message;

  ServiceCreateResponse({
    required this.service,
    required this.message,
  });

  factory ServiceCreateResponse.fromJson(Map<String, dynamic> json) {
    return ServiceCreateResponse(
      service: ServiceModel.fromJson(json['data'] ?? json),
      message: json['message'] ?? 'Tạo dịch vụ thành công',
    );
  }
}

// ==================== Service Update Response ====================
class ServiceUpdateResponse {
  final ServiceModel service;
  final String message;

  ServiceUpdateResponse({
    required this.service,
    required this.message,
  });

  factory ServiceUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ServiceUpdateResponse(
      service: ServiceModel.fromJson(json['data'] ?? json),
      message: json['message'] ?? 'Cập nhật dịch vụ thành công',
    );
  }
}

// ==================== Service Status Response ====================
class ServiceStatusResponse {
  final bool success;
  final String message;

  ServiceStatusResponse({
    required this.success,
    required this.message,
  });

  factory ServiceStatusResponse.fromJson(Map<String, dynamic> json) {
    return ServiceStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

// ==================== Helper for parsing response ====================
class ServiceResponseParser {
  static GetAllServicesResponse parseAllServices(dynamic response) {
    if (response is GetAllServicesResponse) return response;

    if (response is Map<String, dynamic>) {
      return GetAllServicesResponse.fromJson(response);
    }

    if (response is List) {
      return GetAllServicesResponse(
        services: response
            .map<ServiceModel>((item) => ServiceModel.fromJson(item))
            .toList(),
      );
    }

    throw FormatException('Invalid response format for services');
  }
}
class ServiceResponsePrice{
  final num minPrice;
  final num maxPrice;

  ServiceResponsePrice({
    required this.minPrice,
    required this.maxPrice,
  });
  factory ServiceResponsePrice.fromJson(Map<String, dynamic> json) {
    return ServiceResponsePrice(
      minPrice: json['min_price'] ?? 0,
      maxPrice: json['max_price'] ?? 0,
    );
  }
}