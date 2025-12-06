import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
// Trong home_viewmodel.dart
class HomeViewModel extends ChangeNotifier {
  final BarberViewModel _barberViewModel = BarberViewModel();

  BarberViewModel get barberViewModel => _barberViewModel;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initializeHomeData() async {
    try {
      // Fetch top barbers
      await _barberViewModel.fetchTopBarbers(limit: 2);

      // Debug
      print('HomeViewModel - Top barbers fetched: ${_barberViewModel.topBarbers.length}');

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('HomeViewModel - initializeHomeData error: $e');
      rethrow;
    }
  }

  Future<void> refreshHomeData() async {
    await _barberViewModel.fetchTopBarbers(limit: 2);
  }
}