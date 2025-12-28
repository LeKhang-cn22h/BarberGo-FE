import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapService {
  // 1. API Tìm kiếm địa điểm (Nominatim)
  Future<Map<String, dynamic>?> searchPlace(String query) async {
    if (query.isEmpty) return null;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.barbergofe'
      });
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'point': LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon'])),
            'displayName': data[0]['display_name'],
          };
        }
      }
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
    }
    return null;
  }

  // 2. API Vẽ đường (OSRM)
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
            '${start.longitude},${start.latitude};'
            '${end.longitude},${end.latitude}'
            '?overview=full&geometries=geojson');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
        return coordinates
            .map((point) => LatLng(point[1].toDouble(), point[0].toDouble()))
            .toList();
      }
    } catch (e) {
      print("Lỗi OSRM: $e");
    }
    return [];
  }

  // 3. Kiểm tra quyền GPS
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  // 4. Stream vị trí (Realtime)
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
//hàm chuyển địa chỉ LatLong sang địa chỉ chính xác
  Future<String?> getAddress(LatLng? pointStart) async {
    if (pointStart == null) return null;

    try {
      final placemarks = await placemarkFromCoordinates(
        pointStart.latitude,
        pointStart.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      // Ghép địa chỉ cho dễ đọc
      final addressParts = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ];

      // Loại bỏ null / rỗng
      return addressParts
          .where((part) => part != null && part!.isNotEmpty)
          .join(', ');
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getRouteWithInstructions(
      LatLng start,
      LatLng end,
      ) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson&steps=true';

      print(' Calling OSRM API with instructions...');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];

        // Parse coordinates
        final coordinates = route['geometry']['coordinates'] as List;
        List<LatLng> points = coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

        // Parse instructions
        List<String> instructions = [];
        final legs = route['legs'] as List;

        for (var leg in legs) {
          final steps = leg['steps'] as List;
          for (var step in steps) {
            final maneuver = step['maneuver'];
            final instruction = maneuver['instruction'] ?? '';
            final distance = step['distance'] ?? 0;

            if (instruction.isNotEmpty) {
              // Format: "Rẽ trái vào đường ABC (500m)"
              final distanceText = distance > 1000
                  ? '${(distance / 1000).toStringAsFixed(1)} km'
                  : '${distance.toInt()} m';
              instructions.add('$instruction ($distanceText)');
            }
          }
        }

        // Lấy tổng khoảng cách và thời gian
        final distance = (route['distance'] / 1000); // km
        final duration = (route['duration'] / 60).round(); // phút

        print(' Route with ${instructions.length} instructions');

        return {
          'points': points,
          'instructions': instructions,
          'distance': distance,
          'duration': '$duration phút',
        };
      }

      return {'points': <LatLng>[], 'instructions': <String>[]};
    } catch (e) {
      print(' Error getting route: $e');
      return {'points': <LatLng>[], 'instructions': <String>[]};
    }
  }
}