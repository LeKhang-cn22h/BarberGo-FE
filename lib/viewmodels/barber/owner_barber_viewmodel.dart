import 'dart:io';

import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/services/barber_service.dart';
import 'package:barbergofe/services/service_service.dart';
import 'package:flutter/cupertino.dart';

class OwnerBarberViewModel extends ChangeNotifier{
  final BarberService _barberService= BarberService();
  final ServiceService _serviceService= ServiceService();

  //state
bool _isLoading=false;
String? _error;

//data
BarberModel? _myBarber;
List<ServiceModel> _service=[];

//Getters
bool get isLoading=>_isLoading;
String? get error=>_error;
BarberModel? get myBarber=> _myBarber;
List<ServiceModel> get services=>_service;

bool get hasBarber=>_myBarber!=null;
/// load data
  Future<void> initialize() async {
  try{
    _error=null;
    setLoad(true);
    final userId= await AuthStorage.getUserId();
    if(userId==null) throw Exception('User not found');
    //load in4 barber của user
    await fetchMyBarber(userId);
    //load service của barber
    if(hasBarber){
      await fetchServices(myBarber!.id);
    }
    setLoad(false);
  }catch(e){
    _error=e.toString();
    setLoad(false);
    print('Error intialize: $e');
  }
}
//
Future<void> fetchMyBarber(String userId) async{
  try{
    final response= await _barberService.getBarberByUser(userId);
    if(response.barbers.isNotEmpty){
      _myBarber=response.barbers.first;
      print('BarberViewModel - fetchMyBarber: ${_myBarber?.name} loaded');
    }else{
      throw Exception('Barber not found');
    }
    notifyListeners();
  }catch(e){
    _error=e.toString();
    }
}
Future<void> fetchServices(String barberId) async{
  try{
    final response= await _serviceService.getServicesByBarber(barberId);
    _service=response.services;
    print('load ${_service.length} service');
    notifyListeners();
  }catch(e){
    print('Error fetching services: $e');
    rethrow;
  }
}
Future<bool> updateinforBarber(BarberUpdateRequest req) async{
  if (_myBarber == null) return false ;
  try{
    setLoad(true);
    final response= await _barberService.updateBarber(_myBarber!.id, req);
    if (response.success && response.barber !=null){
      _myBarber = response.barber;
      print('Barber updated');
      setLoad(false);
      return true;
    }else{
      setLoad(false);
      return false;
    }
  }catch(e){
      _error=e.toString();
      setLoad(false);
      return false;
  }
}

  Future<bool> uploadBarberImage(File imageFile) async {
    if (_myBarber == null) return false;

    try {
      setLoad(true);
      print('[VM] Uploading image for barber: ${_myBarber!.id}');

      final response = await _barberService.uploadBarberImage(
        barberId: _myBarber!.id,
        imageFile: imageFile,
      );

      if (response.success && response.barber != null) {
        _myBarber = response.barber;
        print('[VM] Image uploaded successfully');
        print('[VM] New image URL: ${_myBarber!.imagePath}');
        setLoad(false);
        notifyListeners();
        return true;
      }

      setLoad(false);
      return false;
    } catch (e) {
      _error = e.toString();
      setLoad(false);
      print(' [VM] Upload error: $e');
      return false;
    }
  }
  Future<void> updateBarberLocation( double lat, double lng){
    setLoad(true);
    _error=null;
    notifyListeners();
    try{
      return _barberService.updateBarberLocation(_myBarber!.id, lat, lng);
    }catch(e){
      _error=e.toString();
      notifyListeners();
      rethrow;
    }finally{
      setLoad(false);
      notifyListeners();
    }
  }
  Future<bool> createService(ServiceCreateRequest req) async{
  if(_myBarber==null) return false;
  try{
    setLoad(true);
    final response= await _serviceService.createService( req);
    if(response.service!=null) {
      _service.add(response.service);
      print('Service created');
      setLoad(false);
      return true;
    }
  }catch(e){
    setLoad(false);
    _error=e.toString();
    return false;

  }
  }
  Future<bool> updateService(int serviceId, ServiceUpdateRequest req) async {
    if (_myBarber == null) return false;

    try {
      setLoad(true);
      final response = await _serviceService.updateService(serviceId, req);

      if (response.service != null) {
        // Reload services
        await fetchServices(_myBarber!.id);

        print(' Service updated');
        setLoad(false);
        return true;
      }
    } catch (e) {
      _error = e.toString();
      setLoad(false);
      print(' Update service error: $e');
      return false;
    }
}
  Future<bool> deleteService(String serviceId) async {
    if (_myBarber == null) return false;

    try {
      setLoad(true);
      await _serviceService.deleteService(serviceId);

      // Reload services
      await fetchServices(_myBarber!.id);

      setLoad(false);
      return true;
    } catch (e) {
      _error = e.toString();
      setLoad(false);
      print(' Delete service error: $e');
      return false;
    }
  }

  /// Deactivate barber
  Future<bool> deactivateBarber() async {
    if (_myBarber == null) return false;

    try {
      await _barberService.deactivatedBarber(_myBarber!.id);
      print(' Barber deactivated');
      return true;
    } catch (e) {
      print(' Deactivate error: $e');
      return false;
    }
  }

  /// Refresh tất cả data
  Future<void> refresh() async {
    await initialize();
  }
void setLoad(bool stateload){
  _isLoading=stateload;
  notifyListeners();
}
}