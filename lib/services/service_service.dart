import 'package:barbergofe/api/service_api.dart';
import 'package:barbergofe/models/service/service_model.dart';

class ServiceService {
  final ServiceApi _serviceApi = ServiceApi();

  // ==================== GET ALL SERVICES ====================
  Future<GetAllServicesResponse> getAllServices() async {
    try {
      return await _serviceApi.getAllServices();
    } catch (e) {
      print('ServiceService - getAllServices error: $e');
      rethrow;
    }
  }

  // ==================== GET SERVICE BY ID ====================
  Future<GetServiceByIdResponse> getServiceById(String serviceId) async {
    try {
      return await _serviceApi.getServiceById(serviceId);
    } catch (e) {
      print('ServiceService - getServiceById error: $e');
      rethrow;
    }
  }
//get range price
  Future<ServiceResponsePrice> getPriceRange(String barberId )async {
    try {
      return await _serviceApi.getPriceRange(barberId);
    } catch (e) {
      print('ServiceService - getPriceRange error: $e');
      rethrow;
    }
  }
  // ==================== GET SERVICES BY BARBER ====================
  Future<GetServicesByBarberResponse> getServicesByBarber(String barberId) async {
    try {
      return await _serviceApi.getServicesByBarber(barberId);
    } catch (e) {
      print('ServiceService - getServicesByBarber error: $e');
      rethrow;
    }
  }

  // ==================== FILTER SERVICES ====================
  Future<List<ServiceModel>> filterServicesByBarber(
      List<ServiceModel> services,
      String barberId
      ) async {
    return services.where((service) => service.barberId == barberId).toList();
  }

  Future<List<ServiceModel>> filterServicesByPriceRange(
      List<ServiceModel> services,
      int minPrice,
      int maxPrice,
      ) async {
    return services
        .where((service) => service.price >= minPrice && service.price <= maxPrice)
        .toList();
  }

  Future<List<ServiceModel>> filterServicesByDuration(
      List<ServiceModel> services,
      int maxDuration,
      ) async {
    return services
        .where((service) => service.durationMin <= maxDuration)
        .toList();
  }

  // ==================== SEARCH SERVICES ====================
  Future<List<ServiceModel>> searchServicesByName(
      List<ServiceModel> services,
      String keyword,
      ) async {
    if (keyword.isEmpty) return services;

    final lowerKeyword = keyword.toLowerCase();
    return services
        .where((service) =>
        service.serviceName.toLowerCase().contains(lowerKeyword))
        .toList();
  }

  // ==================== SORT SERVICES ====================
  Future<List<ServiceModel>> sortServicesByPrice(
      List<ServiceModel> services,
      bool ascending,
      ) async {
    final sorted = List<ServiceModel>.from(services);
    sorted.sort((a, b) => ascending
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));
    return sorted;
  }

  Future<List<ServiceModel>> sortServicesByName(
      List<ServiceModel> services,
      bool ascending,
      ) async {
    final sorted = List<ServiceModel>.from(services);
    sorted.sort((a, b) => ascending
        ? a.serviceName.compareTo(b.serviceName)
        : b.serviceName.compareTo(a.serviceName));
    return sorted;
  }

  Future<List<ServiceModel>> sortServicesByDuration(
      List<ServiceModel> services,
      bool ascending,
      ) async {
    final sorted = List<ServiceModel>.from(services);
    sorted.sort((a, b) => ascending
        ? a.durationMin.compareTo(b.durationMin)
        : b.durationMin.compareTo(a.durationMin));
    return sorted;
  }
// ==================== CREATE SERVICE ====================
  Future<ServiceCreateResponse> createService(
      ServiceCreateRequest request) async {
    try {
      return await _serviceApi.createService(request);
    } catch (e) {
      print('ServiceService - createService error: $e');
      rethrow;
    }
  }
// ==================== UPDATE SERVICE ====================
  Future<ServiceUpdateResponse> updateService(
      String serviceId,
      ServiceUpdateRequest request,
      ) async {
    try {
      return await _serviceApi.updateService(serviceId, request);
    } catch (e) {
      print('ServiceService - updateService error: $e');
      rethrow;
    }
  }
// ==================== DELETE SERVICE (SOFT) ====================
  Future<ServiceStatusResponse> deleteService(String serviceId) async {
    try {
      return await _serviceApi.deleteService(serviceId);
    } catch (e) {
      print('ServiceService - deleteService error: $e');
      rethrow;
    }
  }
// ==================== RESTORE SERVICE ====================
  Future<ServiceStatusResponse> restoreService(String serviceId) async {
    try {
      return await _serviceApi.restoreService(serviceId);
    } catch (e) {
      print('ServiceService - restoreService error: $e');
      rethrow;
    }
  }
// ==================== TOGGLE SERVICE STATUS ====================
  Future<ServiceStatusResponse> toggleServiceStatus(String serviceId) async {
    try {
      return await _serviceApi.toggleServiceStatus(serviceId);
    } catch (e) {
      print('ServiceService - toggleServiceStatus error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get service by ID từ list local
  ServiceModel? getServiceFromList(List<ServiceModel> services, String serviceId) {
    try {
      final id = int.tryParse(serviceId);
      if (id == null) return null;

      return services.firstWhere(
            (service) => service.id == id,
        orElse: () => throw Exception('Service not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if service exists
  bool serviceExists(List<ServiceModel> services, String serviceId) {
    try {
      final id = int.tryParse(serviceId);
      if (id == null) return false;

      return services.any((service) => service.id == id);
    } catch (e) {
      return false;
    }
  }

  /// Get total price of services
  int calculateTotalPrice(List<ServiceModel> services) {
    return services.fold(0, (total, service) => total + service.price);
  }

  /// Get total duration of services
  int calculateTotalDuration(List<ServiceModel> services) {
    return services.fold(0, (total, service) => total + service.durationMin);
  }

  /// Format price with thousand separators
  String formatPriceWithSeparators(int price) {
    final priceStr = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }

    return '${buffer.toString()}đ';
  }
}