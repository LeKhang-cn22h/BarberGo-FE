import 'package:flutter/material.dart';
import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/services/service_service.dart';

class ServiceViewModel extends ChangeNotifier {
  final ServiceService _serviceService = ServiceService();

  // ==================== STATE ====================
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  List<ServiceModel> _barberServices = [];
  ServiceModel? _selectedService;
  ServiceResponsePrice? _priceRange;
  bool _isLoading = false;
  bool _isLoadingPriceRange = false;
  String? _error;
  String? _searchKeyword = '';
  String? _selectedBarberId;
  Map<String,ServiceResponsePrice>_priceRangeCache={};
  ServiceResponsePrice? getPriceRange(String barberId){
    return _priceRangeCache[barberId];
  }
  String getFormattedPriceRange(String barberId){
    final priceRange=_priceRangeCache[barberId];
    if(priceRange==null) return 'dang tai...';
    return '${priceRange.minPrice.toString()} - ${priceRange.maxPrice.toString()}VND';
  }
  bool hasPriceRange(String BarberId) {
    return _priceRangeCache.containsKey(BarberId);
  }

  // ==================== GETTERS ====================
  List<ServiceModel> get allServices => _allServices;
  List<ServiceModel> get filteredServices => _filteredServices;
  List<ServiceModel> get barberServices => _barberServices;
  ServiceModel? get selectedService => _selectedService;
  ServiceResponsePrice? get priceRange => _priceRange;
  bool get isLoading => _isLoading;
  bool get isLoadingPriceRange => _isLoadingPriceRange;
  String? get error => _error;
  String? get searchKeyword => _searchKeyword;
  String? get selectedBarberId => _selectedBarberId;
  int get totalServicesCount => _allServices.length;
  int get filteredServicesCount => _filteredServices.length;
  int get barberServicesCount => _barberServices.length;


  // ==================== FETCH METHODS ====================
  ///fetch price range for a barber
  Future<void> fetchPriceRange(String barberId) async {
    if(_priceRangeCache.containsKey(barberId)){
      print('price range cached for barber $barberId');
      return;
    }
    print('fetching price range for barber $barberId');
    try{
      final response=await _serviceService.getPriceRange(barberId);
      _priceRangeCache[barberId]=response;
      notifyListeners();
    }catch(e){
      print('Error fetching price range: $e');
    }
  }
  Future<void> fetchPriceRangesForBarbers(List<String> barberIds) async{
    final ids=barberIds.where((id)=>!_priceRangeCache.containsKey(id)).toList();
    if(ids.isEmpty) return;
    //dùng để
    await Future.wait(ids.map((id)=>fetchPriceRange(id)));
  }
  void clearPriceRange() {
    _priceRange = null;
    notifyListeners();
  }
  void clearPriceRangeCache() {
    _priceRangeCache.clear();
    notifyListeners();
  }
  /// Fetch all services
  Future<void> fetchAllServices() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _serviceService.getAllServices();
      _allServices = response.services;
      _filteredServices = List.from(_allServices);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch service by ID
  Future<void> fetchServiceById(String serviceId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _serviceService.getServiceById(serviceId);
      _selectedService = response.service;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch services by barber
  Future<void> fetchServicesByBarber(String barberId) async {
    _setLoading(true);
    _error = null;
    _selectedBarberId = barberId;

    try {
      final response = await _serviceService.getServicesByBarber(barberId);
      _barberServices = response.services;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== FILTER METHODS ====================

  /// Filter services by barber
  Future<void> filterServicesByBarber(String barberId) async {
    _selectedBarberId = barberId;
    _filteredServices = await _serviceService.filterServicesByBarber(_allServices, barberId);
    notifyListeners();
  }

  /// Filter services by price range
  Future<void> filterServicesByPriceRange(int minPrice, int maxPrice) async {
    _filteredServices = await _serviceService.filterServicesByPriceRange(
      _allServices,
      minPrice,
      maxPrice,
    );
    notifyListeners();
  }

  /// Filter services by max duration
  Future<void> filterServicesByDuration(int maxDuration) async {
    _filteredServices = await _serviceService.filterServicesByDuration(
      _allServices,
      maxDuration,
    );
    notifyListeners();
  }

  /// Search services by name
  Future<void> searchServices(String keyword) async {
    _searchKeyword = keyword;
    _filteredServices = await _serviceService.searchServicesByName(
      _allServices,
      keyword,
    );
    notifyListeners();
  }

  // ==================== SORT METHODS ====================

  /// Sort services by price
  Future<void> sortServicesByPrice(bool ascending) async {
    _filteredServices = await _serviceService.sortServicesByPrice(
      _filteredServices,
      ascending,
    );
    notifyListeners();
  }

  /// Sort services by name
  Future<void> sortServicesByName(bool ascending) async {
    _filteredServices = await _serviceService.sortServicesByName(
      _filteredServices,
      ascending,
    );
    notifyListeners();
  }

  /// Sort services by duration
  Future<void> sortServicesByDuration(bool ascending) async {
    _filteredServices = await _serviceService.sortServicesByDuration(
      _filteredServices,
      ascending,
    );
    notifyListeners();
  }

  // ==================== SELECTION METHODS ====================

  /// Select a service
  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  /// Select service by ID
  void selectServiceById(String serviceId) {
    final service = _serviceService.getServiceFromList(_allServices, serviceId);
    if (service != null) {
      _selectedService = service;
      notifyListeners();
    }
  }

  /// Clear selected service
  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }

  // ==================== HELPER METHODS ====================

  /// Clear all filters
  void clearFilters() {
    _filteredServices = List.from(_allServices);
    _searchKeyword = '';
    _selectedBarberId = null;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchKeyword = '';
    _filteredServices = List.from(_allServices);
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if service exists
  bool serviceExists(String serviceId) {
    return _serviceService.serviceExists(_allServices, serviceId);
  }

  /// Get service by ID from local list
  ServiceModel? getServiceByIdFromList(String serviceId) {
    return _serviceService.getServiceFromList(_allServices, serviceId);
  }

  /// Calculate total price of selected services
  int calculateTotalPrice(List<ServiceModel> services) {
    return _serviceService.calculateTotalPrice(services);
  }

  /// Calculate total duration of selected services
  int calculateTotalDuration(List<ServiceModel> services) {
    return _serviceService.calculateTotalDuration(services);
  }

  /// Format price with thousand separators
  String formatPrice(int price) {
    return _serviceService.formatPriceWithSeparators(price);
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchAllServices();
  }

  // ==================== PRIVATE METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize with data
  Future<void> initialize() async {
    await fetchAllServices();
  }

  /// Dispose resources
  @override
  void dispose() {
    _allServices.clear();
    _filteredServices.clear();
    _barberServices.clear();
    _selectedService = null;
    _error = null;
    _searchKeyword = null;
    _selectedBarberId = null;
    _priceRange=null;
    super.dispose();
  }
}