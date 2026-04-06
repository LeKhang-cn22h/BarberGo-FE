import 'dart:convert';
import 'dart:io';

import 'package:barbergofe/api/barber_api.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:dio/dio.dart';

class BarberService {
  final BarberApi _barberApi = BarberApi();

  Future<GetAllBarbersResponse> getTopBarbers({int limit = 2}) async {
    try {
      return await _barberApi.getTopBarbers(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAreas() async {
    try {
      return await _barberApi.getAreas();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBarberLocation(
      String Bid,
      double lat,
      double lng,
      ) async {
    try {
      return await _barberApi.updateBarberLocation(
        barberId: Bid,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BarberUpdateResponse> uploadBarberImage({
    required String barberId,
    required File imageFile,
  }) async {
    try {
      print(' [SERVICE] Uploading image for barber: $barberId');
      return await _barberApi.uploadBarberImage(
        barberId: barberId,
        imageFile: imageFile,
      );
    } catch (e) {
      print(' [SERVICE] Upload error: $e');
      rethrow;
    }
  }

  Future<GetAllBarbersResponse> getBarbersByArea(String area) async {
    try {
      return await _barberApi.getBarbersByArea(area);
    } catch (e) {
      rethrow;
    }
  }

  Future<BarberGetResponse> getBarberById(String id) async {
    try {
      return await _barberApi.getBarberById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<GetAllBarbersResponse> getBarberByUser(String userId) async {
    try {
      return await _barberApi.getBarberByUser(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<BarberUpdateResponse> updateBarber(
      String barberId,
      BarberUpdateRequest request,
      ) async {
    try {
      print('🟢 [SERVICE] updateBarber called');
      print('🟢 [SERVICE] barberId: $barberId');
      print('🟢 [SERVICE] request data: ${request.toJson()}');

      //Gọi API trực tiếp với request, KHÔNG tạo FormData
      return await _barberApi.updateBarber(barberId, request);
    } catch (e) {
      print('[SERVICE] Error: $e');
      rethrow;
    }
  }

  Future<void> deactivatedBarber(String barberId) async {
    try {
      await _barberApi.deactivatedBarber(barberId);
    } catch (e) {
      rethrow;
    }
  }

  Future<GetAllBarbersResponse?> getBarberByOwnerId(String userId) async {
    try {
      // Giả sử bạn đã có API endpoint này
      final response = await _barberApi.getBarberByUser(userId);
      return response;
    } catch (e) {
      print('BarberService - getBarberByOwnerId error: $e');

      return null;
    }
  }}