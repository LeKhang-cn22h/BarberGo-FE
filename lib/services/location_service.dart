import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  // ==================== GET CURRENT LOCATION ====================

  static Future<Position?> getCurrentLocation() async {
    print('🔵 [LOCATION SERVICE] Getting current location...');

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ [LOCATION SERVICE] Location services disabled');
        throw Exception('Vui lòng bật dịch vụ vị trí');
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ [LOCATION SERVICE] Permission denied');
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ [LOCATION SERVICE] Permission denied forever');
        throw Exception('Vui lòng cấp quyền truy cập vị trí trong Cài đặt');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('✅ [LOCATION SERVICE] Location obtained');
      print('   Latitude: ${position.latitude}');
      print('   Longitude: ${position.longitude}');

      return position;

    } catch (e) {
      print('❌ [LOCATION SERVICE] Error: $e');
      rethrow;
    }
  }

  // ==================== REVERSE GEOCODING (Tọa độ → Địa chỉ) ====================

  static Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    print('🔵 [LOCATION SERVICE] Reverse geocoding...');
    print('   Lat: $latitude, Lng: $longitude');

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude
      );
      if (placemarks.isEmpty) {
        throw Exception('Không tìm thấy địa chỉ');
      }

      Placemark place = placemarks[0];

      // Format địa chỉ theo kiểu Việt Nam
      String address = _formatVietnameseAddress(place);

      print('✅ [LOCATION SERVICE] Address: $address');

      return address;

    } catch (e) {
      print('❌ [LOCATION SERVICE] Geocoding error: $e');
      rethrow;
    }
  }

  // ==================== FORMAT ADDRESS (Việt Nam style) ====================

  static String _formatVietnameseAddress(Placemark place) {
    List<String> parts = [];

    // Số nhà + đường
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }

    // Phường/Xã
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }

    // Quận/Huyện
    if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty) {
      parts.add(place.subAdministrativeArea!);
    }

    // Thành phố
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }

    // Tỉnh
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty &&
        place.administrativeArea != place.locality) {
      parts.add(place.administrativeArea!);
    }

    return parts.join(', ');
  }

  // ==================== GET LOCATION WITH ADDRESS ====================

  static Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    print('🔵 [LOCATION SERVICE] Getting location with address...');

    try {
      Position? position = await getCurrentLocation();

      if (position == null) {
        throw Exception('Không thể lấy vị trí');
      }

      String address = await getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'timestamp': position.timestamp,
      };

    } catch (e) {
      print('❌ [LOCATION SERVICE] Error: $e');
      rethrow;
    }
  }
}