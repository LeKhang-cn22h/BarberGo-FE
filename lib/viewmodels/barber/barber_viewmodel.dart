import 'package:flutter/material.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/services/barber_service.dart';

class BarberViewModel extends ChangeNotifier {
  final BarberService _barberService = BarberService();
  BarberModel? _selectedBarber;
  BarberModel? get selectedBarber => _selectedBarber;

  // State
  List<BarberModel> _topBarbers = [];
  List<String> _areas = [];
  List<BarberModel> _areaBarbers = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedArea;
  String _keyword='';
  // Getters
  List<BarberModel> get topBarbers => _topBarbers;
  List<String> get areas => _areas;
  List<BarberModel> get areaBarbers => _areaBarbers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedArea => _selectedArea;

  // Fetch top barbers
  Future<void> fetchTopBarbers({int limit = 2}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _barberService.getTopBarbers(limit: limit);
      _topBarbers = response.barbers ?? [];

      // Debug
      print('BarberViewModel - fetchTopBarbers: ${_topBarbers.length} barbers loaded');
      for (var barber in _topBarbers) {
        print('  - ${barber.name} (id: ${barber.id})');
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all areas
  Future<void> fetchAreas() async {
    _setLoading(true);
    _error = null;

    try {
      _areas = await _barberService.getAreas();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  List<String> get fillteredAreas{
    if(_keyword.isEmpty) return _areas;
    return _areas.where((area){
      return area.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();
  }
  void onAreaSearch(String value){
    _keyword=value;
    notifyListeners();
  }
  // Fetch barbers by area
  Future<void> fetchBarbersByArea(String area) async {
    _setLoading(true);
    _error = null;
    _selectedArea = area;

    try {
      final response = await _barberService.getBarbersByArea(area);
      _areaBarbers = response.barbers ?? [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  Future<void> fetchBarberById(String barberId) async {
    _setLoading (true);
    _error = null;
    notifyListeners();

    try {
      final response = await _barberService.getBarberById(barberId);

      if (response.barber != null) {
        _selectedBarber = response.barber;

        // Cũng thêm vào cache nếu chưa có
        if (!_topBarbers.any((b) => b.id == barberId)) {
          _topBarbers.add(response.barber!);
        }

        notifyListeners();
      } else {
        throw Exception('Barber not found');
      }

    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  void clearSelectedBarber() {
    _selectedBarber = null;
    notifyListeners();
  }
  void selectBarber(BarberModel barber) {
    _selectedBarber = barber;
    notifyListeners();
    print(' Selected barber: ${barber.name}');
  }
  // Select area
  void selectArea(String area) {
    _selectedArea = area;
    notifyListeners();
  }

  // Clear selected area
  void clearSelectedArea() {
    _selectedArea = null;
    _areaBarbers.clear();
    notifyListeners();
  }

  // Helper method
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  List<BarberModel> get filteredBarberAreas{
    if(_keyword.isEmpty) return _areaBarbers;
    return _areaBarbers.where((areaBarber){
      return areaBarber.name.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();
  }
  void onBarberSearch(String value) {
    _keyword = value;
    notifyListeners();
  }
}